import json
import tempfile
import unittest
from datetime import datetime, timezone
from pathlib import Path

try:
    import pyarrow.dataset as ds
    import pyarrow.parquet as pq
except ImportError:
    ds = pq = None

from elicit_study import ValidationError, compile_study
from elicit_study.parquet import write_export
from test_contracts import answer, example


@unittest.skipIf(pq is None, 'Install elicit-study-format[parquet] to test Parquet output')
class ParquetTests(unittest.TestCase):
    def test_incremental_parts_round_trip_and_empty_tables(self):
        compiled = compile_study(example())
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / 'export'
            rows = (('likert_v1_answer', answer(compiled, record_id=f'record-{i}', trial_occurrence_id=f'occurrence-{i}')) for i in range(7))
            manifest = write_export(compiled, rows, root, snapshot_id='snapshot-1', batch_size=2)
            dataset = ds.dataset(root / 'likert_v1_answer', format='parquet')
            self.assertEqual(dataset.count_rows(), 7)
            self.assertEqual(len(list((root / 'likert_v1_answer').glob('*.parquet'))), 4)
            self.assertEqual(dataset.schema.field('occurred_at').type.tz, 'UTC')
            self.assertFalse(dataset.schema.field('choice_key').nullable)
            self.assertEqual(pq.read_table(root / 'runs').num_rows, 0)
            self.assertEqual(json.loads((root / 'manifest.json').read_text()), manifest)
            for entry in manifest['files']:
                self.assertTrue((root / entry['path']).exists())
                self.assertEqual(len(entry['sha256']), 64)
            self.assertEqual(sum(e.get('rows', 0) for e in manifest['files']), 7)
            with self.assertRaises(FileExistsError):
                write_export(compiled, [], root, snapshot_id='another')

    def test_invalid_row_does_not_publish_manifest(self):
        compiled = compile_study(example())
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / 'export'
            rows = [('likert_v1_answer', answer(compiled)), ('likert_v1_answer', answer(compiled, choice_key='invalid'))]
            with self.assertRaises(ValidationError):
                write_export(compiled, rows, root, snapshot_id='snapshot-1', batch_size=1)
            self.assertTrue(list(root.rglob('*.parquet')))
            self.assertFalse((root / 'manifest.json').exists())

    def test_list_answers_and_nullable_landmark_coordinate(self):
        cases = [
            (3, 'main/questions/one-to-three/question', 'multiple_choice_v1_answer', {'choice_keys': ['option-1', 'option-2']}),
            (8, 'main/capture/calibrate/calibration', 'face_calibration_v1_landmark', dict(sample_id='sample-1', face_index=0, landmark_index=1, x=0.1, y=0.2, z=None)),
        ]
        for number, address, table, payload in cases:
            with self.subTest(table=table), tempfile.TemporaryDirectory() as directory:
                compiled = compile_study(example(number))
                row = answer(compiled, address)
                row.pop('choice_key')
                row.update(payload)
                root = Path(directory) / 'export'
                write_export(compiled, [(table, row)], root, snapshot_id='snapshot-1')
                actual = pq.read_table(root / table).to_pylist()[0]
                for key, value in payload.items():
                    self.assertEqual(actual[key], value)

    def test_all_example_table_schemas_map_to_arrow(self):
        from elicit_study.parquet import arrow_schema
        from test_contracts import EXAMPLES
        for path in EXAMPLES:
            compiled = compile_study(json.loads(path.read_text()))
            for table in compiled['tables']:
                with self.subTest(example=path.name, table=table):
                    self.assertEqual(arrow_schema(compiled, table).names, list(compiled['tables'][table]['properties']))

    def test_timestamp_offsets_preserve_the_instant(self):
        compiled = compile_study(example())
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / 'export'
            row = answer(compiled, occurred_at='2026-11-07T04:00:00.123456-08:00')
            write_export(compiled, [('likert_v1_answer', row)], root, snapshot_id='snapshot-1')
            actual = pq.read_table(root / 'likert_v1_answer').to_pylist()[0]['occurred_at']
            self.assertEqual(actual, datetime(2026, 11, 7, 12, 0, 0, 123456, tzinfo=timezone.utc))


if __name__ == '__main__':
    unittest.main()
