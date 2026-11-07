# Python library and CLI

Install distribution `elicit-study-format`; import package `elicit_study`. Python 3.10+ is required. The base dependency is `fastjsonschema`; install the `parquet` extra for Arrow schemas, Parquet writing and ZIP export. Authoring and local export do not need Rails, a database service, API credentials or network access after installation.

This is the canonical-format library, separate from the existing `pyelicit` v1 SDK. It does not execute experiments or translate historical v1 data. [Schema semantics](schema.md), [examples](../examples/README.md) and [HTTP delivery](../../doc/canonical-study-delivery.md) describe those boundaries.

## Installation

Run from the repository root:

```sh
python3 -m venv study-format/.venv
study-format/.venv/bin/pip install -e './study-format[parquet]'
. study-format/.venv/bin/activate
```

Use `python -m pip install ./study-format` for an ordinary base installation, or keep `[parquet]` for export support. The JSON contracts are packaged resources, so installed code works outside the checkout. Offline execution assumes dependencies are already installed; installation itself can need network access.

## Complete local workflow

Save the minimal definition from [schema.md](schema.md#a-minimal-complete-definition) as `study.json` in your working directory. This program compiles it, validates a complete result batch, writes Parquet and reads the answer back. It uses temporary output so repeated runs do not collide.

```python
import json
import tempfile
from pathlib import Path

import pyarrow.dataset as ds

from elicit_study import compile_study, validate_row
from elicit_study.delivery import validate_batch, export_archive
from elicit_study.parquet import write_export

study = json.loads(Path('study.json').read_text(encoding='utf-8'))
compiled = compile_study(study)
identity = {
    'revision_id': compiled['revision_id'],
    'participant_id': 'participant-1',
    'run_id': 'run-1',
}
occurrence = {
    **identity,
    'protocol_key': 'main',
    'phase_key': 'assessment',
    'trial_key': 'confidence',
    'trial_occurrence_id': 'run-1-trial-1',
}
rows = [
    ('runs', {
        **identity,
        'status': 'in_progress',
        'started_at': '2026-11-07T12:00:00Z',
        'completed_at': None,
    }),
    ('trial_occurrences', {
        **occurrence,
        'status': 'completed',
        'sequence': 0,
        'started_at': '2026-11-07T12:00:00Z',
        'completed_at': '2026-11-07T12:01:00Z',
    }),
    ('likert_v1_answer', {
        **occurrence,
        'component_path': 'main/assessment/confidence/rating',
        'record_id': 'answer-1',
        'sequence': 0,
        'occurred_at': '2026-11-07T12:01:00Z',
        'choice_key': 'high',
    }),
]
for table_name, row in rows:
    validate_row(compiled, table_name, row)

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    source = root / 'results.ndjson'
    source.write_text(
        ''.join(json.dumps({'table': table, 'row': row}) + '\n'
                for table, row in rows),
        encoding='utf-8',
    )
    # This checks relationships and identities across the whole batch.
    assert validate_batch(compiled, source, root / 'validated.ndjson') == 3
    manifest = write_export(
        compiled, iter(rows), root / 'dataset',
        snapshot_id='offline-snapshot-1', batch_size=2,
    )
    answers = ds.dataset(root / 'dataset' / 'likert_v1_answer', format='parquet')
    assert answers.to_table(columns=['choice_key']).to_pylist() == [
        {'choice_key': 'high'}
    ]
    assert manifest['revision_id'] == compiled['revision_id']
    # The archive helper uses the original table/row NDJSON envelope.
    export_archive(compiled, source, root / 'results.zip', 'offline-snapshot-1')
    print('Validated three rows and exported a Parquet dataset and ZIP.')
```

For persistent output, choose a new destination directory outside the temporary context. Preserve the compiled contract with the results. Existing revisions on the server provide their stored contract through the result-schema endpoint; avoid recompiling an old document with a different compiler deployment.

## Definition API

These names are exported from `elicit_study`:

| Call | Return and behavior |
| --- | --- |
| `validate_study(study)` | New normalized dictionary with explicit defaults and semantic validation; input is unchanged |
| `compile_study(study)` | Compiled dictionary containing normalized definition, identities, general table schemas and specialized component bindings |
| `validate_row(compiled, table, row)` | The same row after validation; no row normalization or cross-row checking |
| `ValidationError` | `ValueError` subclass exposing `.issues`, a list of `{path, code, message}` diagnostics |

`study` and `row` are parsed Python dictionaries. Version values remain strings. Rows must contain timestamp strings, not `datetime` instances. A valid table name alone does not authorize an output: `validate_row` also verifies the component binding and its configuration-dependent restrictions.

Catch diagnostics without parsing an exception message:

```python
from elicit_study import ValidationError, validate_study

try:
    validate_study({})
except ValidationError as error:
    assert error.issues
    assert all({'path', 'code', 'message'} <= issue.keys()
               for issue in error.issues)
    print(error.issues[0]['path'], error.issues[0]['code'])
```

Paths use JSON Pointer escaping. Structural validation may report one schema error; semantic checks can accumulate multiple issues. Treat codes as diagnostic categories and messages as human-readable explanations.

`elicit_study.schema.study_schema()` returns the self-contained editor schema assembled from the registry. Access installed resources without checkout-relative paths:

```python
import json
from importlib.resources import files

registry = json.loads(
    files('elicit_study').joinpath('contracts/components.json')
    .read_text(encoding='utf-8')
)
assert 'likert' in registry['components']
```

Internal helpers, module globals and names beginning with `_` are implementation details. Public helpers are described here; the package is experimental and does not yet promise a frozen cross-version API.

## Batch and export API

| Import / call | Contract |
| --- | --- |
| `elicit_study.delivery.validate_batch(compiled, source, destination)` | Read table/row NDJSON, validate row and cross-record constraints, write validated NDJSON, return row count |
| `elicit_study.parquet.arrow_schema(compiled, table)` | Return a `pyarrow.Schema` with revision, result-contract and table metadata |
| `elicit_study.parquet.write_export(compiled, rows, destination, *, snapshot_id, batch_size=65536)` | Consume `(table_name, row)` pairs and return the committed manifest |
| `elicit_study.delivery.export_archive(compiled, source, destination, snapshot_id)` | Read table/row NDJSON, create a storage-mode ZIP around the Parquet dataset, return its manifest |

Paths can be strings or `Path` objects. `rows` can be a generator. `validate_batch` uses a temporary on-disk SQLite index instead of holding every relationship in memory. It permits blank lines and children before parents, but requires a nonempty batch with all referenced runs and occurrences. Its output adds an internal `row_key`; do not submit that validated envelope back to the HTTP import API. Keep source and destination paths distinct. Its destination can be partial on error; use it only after the call returns successfully.

`write_export` validates each row and requires a new destination directory and nonempty string snapshot ID. It does not enforce uniqueness, batch references or establish a source snapshot. `batch_size` caps buffered row count across tables, not bytes or total disk use. Every declared table receives a typed part even if empty. Use temporary destinations for attempts; a valid export has `manifest.json` published last. The snapshot ID identifies a snapshot established by your extraction layer; assigning the string alone does not create one.

`export_archive` has the same per-row validation and source-consistency boundary as the writer. Validate imported batches first. The helper opens its archive destination for writing and can overwrite an existing file; use a fresh path. The HTTP worker uses a fresh staging directory and database snapshots before this step.

The physical mapping uses signed 64-bit integers, 64-bit floating-point numbers, booleans, UTF-8 strings, lists/structs, nullable fields and UTC microsecond timestamps. Ensure numeric values fit the physical type. Type inference is not based on sample rows. Read a local export with `pyarrow.dataset`, or use another Parquet reader. Definition and result-contract JSON metadata remain separate from the table data.

## Async HTTP client

`Client` wraps the durable operation API. Submission methods return immediately with an operation dictionary; `wait` performs polling. Read bearer credentials from your environment:

```python
import os
from elicit_study.client import Client

client = Client(os.environ['ELICIT_API_URL'], os.environ['ELICIT_TOKEN'])
study_operation = client.import_study(
    'study.json', key='confidence-study-import-1',
)
study_result = client.wait(study_operation)
results_operation = client.import_results(
    study_result['study_id'], study_result['revision_id'], 'results.ndjson',
    key='confidence-study-results-1',
)
client.wait(results_operation)
export_operation = client.export_results(
    study_result['study_id'], study_result['revision_id'],
    participants=['participant-1'], key='confidence-study-export-1',
)
completed_export = client.wait(export_operation)
client.download(completed_export, 'results.zip')
```

The server needs an investigator/admin token with the existing `public` OAuth scope. Use the revision digest returned by the import in your result rows; for this example it matches local compilation of the same definition with the same compiler contract. `participants=None` exports all imported participants; an empty list is invalid. Canonical definitions are stored but are not yet executable by the v1 participant runner.

| Method | Details |
| --- | --- |
| `Client(base_url, token, *, timeout=60)` | API origin, bearer token, per-HTTP-request timeout in seconds |
| `import_study(document, *, key=None)` | Upload complete definition file; return queued operation |
| `import_results(study_id, revision_id, document, *, key=None)` | Upload table/row NDJSON file; return queued operation |
| `export_results(study_id, revision_id, *, participants=None, key=None)` | Request participant-filtered export; return queued operation |
| `wait(operation, *, timeout=1800, interval=1)` | Poll for completion; return successful operation or raise |
| `download(operation, destination)` | Refresh metadata, stream and verify an export archive, return destination `Path` |
| `submit(path, document, *, key=None, content_type='application/json')` | Lower-level operation submission, accepting bytes or a `Path`; dictionaries must be JSON-encoded first |

When omitted, `key` becomes a new UUID for that submission. For deliberate retries, preserve a supplied idempotency key and send the same document/target/options. The client does not automatically retry HTTP failures. It streams files, keeps bearer tokens on the API origin, removes them on cross-origin redirects and does not print them.

`download` is for a successful **export** operation. The destination parent directory must already exist. The client refreshes signed URLs before downloading, verifies the archive SHA-256 and publishes atomically without overwriting an existing destination. Failed downloads clean up their temporary file. Cloud URLs may expire; call `download` again to get a fresh one.

HTTP failures propagate as `urllib.error.HTTPError`; connection failures as `URLError` or underlying I/O errors. Failed async operations cause `wait` to raise `ValueError` containing serialized diagnostics. A polling deadline raises `TimeoutError`; it does not cancel the server operation. Save the submitted operation dictionary so polling can resume. `download` can raise `ValueError` for checksum/state errors and `FileExistsError` for an occupied destination.

There is no dedicated revision/retry convenience method yet. Use `submit` for those endpoints, then `wait`; the [HTTP guide](../../doc/canonical-study-delivery.md) specifies their URLs, expected-base check and retry semantics. Corrected invalid input needs a new submission/key, while retrying a failed operation reuses its staged source.

For a ready command-line uploader, see [examples/deliver.py](../examples/deliver.py).

## Command-line interface

After installation, `elicit-study` and `python -m elicit_study` are equivalent. Run commands from the repository root when using these example paths:

| Command | Output |
| --- | --- |
| `elicit-study validate study-format/examples/01-likert.study.json` | `{"valid": true}` |
| `elicit-study normalize study-format/examples/01-likert.study.json --output /tmp/normalized.json` | Normalized definition JSON |
| `elicit-study compile study-format/examples/01-likert.study.json --output /tmp/contract.json` | Compiled result contract JSON |
| `elicit-study schema --output /tmp/editor.schema.json` | Assembled editor JSON Schema; no document argument |
| `elicit-study export study-format/examples/01-likert.study.json --rows /tmp/results.ndjson --snapshot-id offline-1 --output /tmp/new-dataset` | Parquet dataset and manifest; manifest also printed to stdout |

For non-export commands, omit `--output` to write JSON to stdout. The export destination must not exist. A successful command exits `0`; validation/runtime input errors caught by the CLI exit `1` with JSON diagnostics on stderr. Argument parser errors exit `2`. The local `export` command performs per-row validation, not whole-batch reference checks; use `validate_batch` before exporting an imported batch. The library example above uses a different definition/address than `01-likert`, so create row data for the definition you actually export.

`python -m elicit_study.delivery` is the Rails worker's file protocol, separate from the user-facing CLI. Its `compile` command takes an authored definition; `validate-results` and `export` take a **stored compiled contract**. Treat this as an integration surface and use the Python functions or `Client` for normal application code.

## Development checks

```sh
elicit-study schema --output study-format/elicit_study/contracts/study.schema.json
python -m unittest discover -s study-format/tests -v
```

Run with the Parquet extra installed and inspect skip counts. Server changes additionally require the Rails integration and real worker checks in [AGENTS.md](../../AGENTS.md). See the [package instructions](../AGENTS.md) before editing a contract or physical mapping.
