"""File-based worker bridge shared by Rails and the offline client.

Result imports are complete append-only batches: referenced run and occurrence
rows must be present in the same batch. SQLite indexes keep validation bounded
in memory even when children precede their parents in the append log.
"""

import argparse
import hashlib
import json
import sqlite3
import sys
import tempfile
import zipfile
from pathlib import Path

from .compiler import ValidationError, compile_study, validate_row


def _error(path, code, message):
    raise ValidationError([{'path': path, 'code': code, 'message': message}])


def _entries(path):
    with Path(path).open() as source:
        for line_number, line in enumerate(source, 1):
            if not line.strip():
                continue
            try:
                entry = json.loads(line)
            except ValueError:
                _error(f'/lines/{line_number}', 'json', 'Invalid JSON record')
            if not isinstance(entry, dict) or set(entry) != {'table', 'row'} or not isinstance(entry['table'], str):
                _error(f'/lines/{line_number}', 'record', 'Expected exactly table and row fields')
            yield line_number, entry['table'], entry['row']


def validate_batch(compiled, source, destination):
    with tempfile.TemporaryDirectory() as directory:
        db = sqlite3.connect(Path(directory) / 'references.sqlite3')
        try:
            db.executescript('''
                CREATE TABLE runs (run TEXT PRIMARY KEY, participant TEXT);
                CREATE TABLE trials (run TEXT, occurrence TEXT, participant TEXT,
                    protocol TEXT, phase TEXT, trial TEXT, sequence INTEGER,
                    PRIMARY KEY(run, occurrence), UNIQUE(run, sequence));
                CREATE TABLE children (run TEXT, occurrence TEXT, participant TEXT,
                    protocol TEXT, phase TEXT, trial TEXT, component TEXT,
                    table_name TEXT, sequence INTEGER,
                    UNIQUE(run, occurrence, component, table_name, sequence));
                CREATE TABLE identities (table_name TEXT, identity TEXT,
                    PRIMARY KEY(table_name, identity));
            ''')
            count = 0
            with Path(destination).open('w') as output:
                for line, table, row in _entries(source):
                    try:
                        validate_row(compiled, table, row)
                    except ValidationError as exc:
                        for issue in exc.issues:
                            issue['path'] = f'/lines/{line}/row' + issue['path']
                        raise
                    run, participant = row['run_id'], row['participant_id']
                    if table == 'runs':
                        identity = [run]
                    elif table == 'trial_occurrences':
                        identity = [run, row['trial_occurrence_id']]
                    else:
                        identity = [run, row['record_id']]
                    row_key = hashlib.sha256(json.dumps(identity, separators=(',', ':')).encode()).hexdigest()
                    try:
                        db.execute('INSERT INTO identities VALUES (?, ?)', (table, row_key))
                        if table == 'runs':
                            db.execute('INSERT INTO runs VALUES (?, ?)', (run, participant))
                        elif table == 'trial_occurrences':
                            db.execute('INSERT INTO trials VALUES (?, ?, ?, ?, ?, ?, ?)', (
                                run, row['trial_occurrence_id'], participant, row['protocol_key'],
                                row['phase_key'], row['trial_key'], row['sequence']))
                        else:
                            db.execute('INSERT INTO children VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', (
                                run, row['trial_occurrence_id'], participant, row['protocol_key'],
                                row['phase_key'], row['trial_key'], row['component_path'], table, row['sequence']))
                    except sqlite3.IntegrityError:
                        _error(f'/lines/{line}', 'duplicate', 'Duplicate identity or sequence within its scope')
                    output.write(json.dumps({'table': table, 'row': row, 'row_key': row_key}, allow_nan=False) + '\n')
                    count += 1
                    if count % 10000 == 0:
                        db.commit()
            if not count:
                _error('/', 'empty_batch', 'A result batch must contain at least one run')
            bad_trial = db.execute('''SELECT t.run FROM trials t LEFT JOIN runs r ON t.run = r.run
                WHERE r.run IS NULL OR r.participant != t.participant LIMIT 1''').fetchone()
            bad_child = db.execute('''SELECT c.run FROM children c LEFT JOIN trials t
                ON c.run = t.run AND c.occurrence = t.occurrence
                WHERE t.run IS NULL OR c.participant != t.participant OR c.protocol != t.protocol
                    OR c.phase != t.phase OR c.trial != t.trial LIMIT 1''').fetchone()
            if bad_trial or bad_child:
                _error('/', 'result_reference', 'Every result must reference a matching run and trial occurrence in this batch')
            return count
        finally:
            db.close()


def export_archive(compiled, source, destination, snapshot_id):
    from .parquet import write_export

    with tempfile.TemporaryDirectory() as directory:
        dataset = Path(directory) / 'dataset'
        rows = ((table, row) for _, table, row in _entries(source))
        manifest = write_export(compiled, rows, dataset, snapshot_id=snapshot_id)
        # Parquet is already compressed. ZIP_STORED preserves its bytes and ZIP64
        # supports exports larger than 4 GiB.
        with zipfile.ZipFile(destination, 'w', compression=zipfile.ZIP_STORED, allowZip64=True) as archive:
            for entry in manifest['files']:
                archive.write(dataset / entry['path'], entry['path'])
            archive.write(dataset / 'manifest.json', 'manifest.json')
        return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['compile', 'validate-results', 'export'])
    parser.add_argument('document', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--rows', type=Path)
    parser.add_argument('--snapshot-id')
    args = parser.parse_args()
    try:
        if args.command == 'compile':
            compiled = compile_study(json.loads(args.document.read_text()))
            args.output.write_text(json.dumps(compiled, ensure_ascii=False, allow_nan=False))
        else:
            # Export/import against the stored compiler output, not a freshly
            # recompiled definition that may change after a compiler deployment.
            compiled = json.loads(args.document.read_text())
            if args.command == 'validate-results':
                validate_batch(compiled, args.rows, args.output)
            else:
                export_archive(compiled, args.rows, args.output, args.snapshot_id)
    except ValidationError as exc:
        sys.stderr.write(json.dumps({'issues': exc.issues}) + '\n')
        return 2
    except (ValueError, OSError) as exc:
        sys.stderr.write(json.dumps({'issues': [{'path': '/', 'code': 'input', 'message': str(exc)}]}) + '\n')
        return 2
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
