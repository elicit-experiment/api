"""Bounded-batch local artifact writer; an async server job can upload its output.

The manifest is written last. A failed export has no manifest and is not committed.
The caller owns snapshot selection and must supply immutable, consistently read rows.
"""

import copy
import hashlib
import json
from datetime import datetime
from pathlib import Path

from .compiler import validate_row


def _arrow_field(pa, name, schema):
    schema = copy.deepcopy(schema)
    nullable = False
    if 'anyOf' in schema:
        nullable = any(s.get('type') == 'null' for s in schema['anyOf'])
        schema = next(s for s in schema['anyOf'] if s.get('type') != 'null')
    kind = schema['type']
    if isinstance(kind, list):
        nullable = 'null' in kind
        kind = next(t for t in kind if t != 'null')
    primitive = {'string': pa.string(), 'integer': pa.int64(), 'number': pa.float64(), 'boolean': pa.bool_(), 'null': pa.null()}
    if kind == 'array':
        dtype = pa.list_(_arrow_field(pa, 'item', schema['items']))
    elif kind == 'object':
        dtype = pa.struct([_arrow_field(pa, k, s) for k, s in schema['properties'].items()])
    elif schema.get('format') == 'date-time':
        dtype = pa.timestamp('us', tz='UTC')
    else:
        dtype = primitive[kind]
    return pa.field(name, dtype, nullable=nullable or kind == 'null')


def arrow_schema(compiled, table):
    import pyarrow as pa
    return pa.schema([_arrow_field(pa, key, schema) for key, schema in compiled['tables'][table]['properties'].items()], metadata={
        b'elicit.revision_id': compiled['revision_id'].encode(),
        b'elicit.result_contract_id': compiled['result_contract_id'].encode(),
        b'elicit.table': table.encode(),
    })


def _checksum(path):
    digest = hashlib.sha256()
    with path.open('rb') as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def write_export(compiled, rows, destination, *, snapshot_id, batch_size=65536):
    """Write (table_name, row) pairs without accumulating the entire dataset.

    destination must not exist. No S3 or live database access occurs here. Unique
    record IDs, referential integrity between rows and snapshot consistency are
    upstream responsibilities; this writer validates each row's local contract.
    """
    import pyarrow as pa
    import pyarrow.parquet as pq

    if batch_size < 1:
        raise ValueError('batch_size must be positive')
    if not isinstance(snapshot_id, str) or not snapshot_id:
        raise ValueError('snapshot_id is required')
    destination = Path(destination)
    destination.mkdir(parents=True, exist_ok=False)
    schemas = {table: arrow_schema(compiled, table) for table in compiled['tables']}
    buffers = {table: [] for table in schemas}
    parts = {table: 0 for table in schemas}
    artifacts = []

    def record(path, count=None, table=None):
        entry = {'path': path.relative_to(destination).as_posix(), 'bytes': path.stat().st_size, 'sha256': _checksum(path)}
        if count is not None:
            entry.update(table=table, rows=count)
        artifacts.append(entry)

    def flush(table):
        path = destination / table / f'part-{parts[table]:05d}.parquet'
        path.parent.mkdir(exist_ok=True)
        batch = pa.Table.from_pylist(buffers[table], schema=schemas[table])
        pq.write_table(batch, path, compression='zstd', row_group_size=batch_size)
        record(path, batch.num_rows, table)
        parts[table] += 1
        buffers[table].clear()

    pending = 0
    for table, row in rows:
        validate_row(compiled, table, row)
        row = copy.deepcopy(row)
        for key, value in row.items():
            if value is not None and schemas[table].field(key).type == pa.timestamp('us', tz='UTC'):
                row[key] = datetime.fromisoformat(value.replace('Z', '+00:00'))
        buffers[table].append(row)
        pending += 1
        if pending >= batch_size:
            # Flush the largest buffer. Total buffered rows remains bounded even
            # when many component table types are interleaved.
            largest = max(buffers, key=lambda name: len(buffers[name]))
            pending -= len(buffers[largest])
            flush(largest)
    for table in schemas:
        if buffers[table] or parts[table] == 0:
            flush(table)  # Emit typed empty tables, too.
    for filename, value in [('study-definition.json', compiled['definition']), ('result-contract.json', compiled)]:
        path = destination / filename
        path.write_text(json.dumps(value, indent=2, ensure_ascii=False, allow_nan=False) + '\n')
        record(path)
    manifest = {'format_version': '1', 'revision_id': compiled['revision_id'], 'result_contract_id': compiled['result_contract_id'], 'snapshot_id': snapshot_id, 'files': artifacts}
    temporary = destination / '.manifest.tmp'
    temporary.write_text(json.dumps(manifest, indent=2) + '\n')
    temporary.replace(destination / 'manifest.json')
    return manifest
