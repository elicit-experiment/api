"""Offline command line interface. Diagnostics are machine-readable JSON."""

import argparse
import json
import sys
from pathlib import Path

from .compiler import ValidationError, compile_study, validate_study
from .schema import study_schema


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['validate', 'normalize', 'compile', 'schema', 'export'])
    parser.add_argument('document', nargs='?', type=Path)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--rows', type=Path, help='NDJSON input: one {"table": ..., "row": ...} per line')
    parser.add_argument('--snapshot-id')
    args = parser.parse_args()
    if args.command != 'schema' and args.document is None:
        parser.error('document is required')
    if args.command == 'export' and not (args.output and args.rows and args.snapshot_id):
        parser.error('export requires --output, --rows and --snapshot-id')
    try:
        if args.command == 'schema':
            result = study_schema()
        else:
            study = json.loads(args.document.read_text())
            if args.command == 'validate':
                validate_study(study)
                result = {'valid': True}
            elif args.command == 'normalize':
                result = validate_study(study)
            elif args.command == 'compile':
                result = compile_study(study)
            else:
                from .parquet import write_export

                def rows():
                    with args.rows.open() as source:
                        for line in source:
                            entry = json.loads(line)
                            yield entry['table'], entry['row']

                result = write_export(compile_study(study), rows(), args.output, snapshot_id=args.snapshot_id)
        text = json.dumps(result, indent=2, ensure_ascii=False, allow_nan=False) + '\n'
        if args.output and args.command != 'export':
            args.output.write_text(text)
        else:
            sys.stdout.write(text)
    except ValidationError as exc:
        sys.stderr.write(json.dumps({'valid': False, 'issues': exc.issues}) + '\n')
        return 1
    except (OSError, ValueError, KeyError, ImportError) as exc:
        sys.stderr.write(json.dumps({'error': str(exc)}) + '\n')
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
