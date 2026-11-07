import json
import tempfile
import unittest
from pathlib import Path

from elicit_study import ValidationError, compile_study
from elicit_study.delivery import validate_batch
from test_contracts import answer, example


class BatchTests(unittest.TestCase):
    def setUp(self):
        self.compiled = compile_study(example())
        row = answer(self.compiled)
        identity = {key: row[key] for key in ('revision_id', 'participant_id', 'run_id')}
        occurrence = {key: row[key] for key in ('revision_id', 'participant_id', 'run_id', 'protocol_key', 'phase_key', 'trial_key', 'trial_occurrence_id')}
        self.rows = [
            {'table': 'likert_v1_answer', 'row': row},  # Child may precede parent.
            {'table': 'trial_occurrences', 'row': {**occurrence, 'sequence': 0, 'status': 'completed', 'started_at': row['occurred_at'], 'completed_at': row['occurred_at']}},
            {'table': 'runs', 'row': {**identity, 'status': 'in_progress', 'started_at': row['occurred_at'], 'completed_at': None}},
        ]

    def validate(self, rows):
        with tempfile.TemporaryDirectory() as directory:
            source, output = Path(directory) / 'rows.ndjson', Path(directory) / 'validated.ndjson'
            source.write_text('\n'.join(json.dumps(row) for row in rows))
            validate_batch(self.compiled, source, output)
            return [json.loads(line) for line in output.read_text().splitlines()]

    def test_out_of_order_batch_is_validated_and_gets_stable_record_identities(self):
        validated = self.validate(self.rows)
        self.assertEqual(len(validated), 3)
        self.assertEqual(validated, self.validate(self.rows))
        self.assertTrue(all(len(entry['row_key']) == 64 for entry in validated))

    def test_missing_run_and_cross_participant_references_fail(self):
        with self.assertRaises(ValidationError):
            self.validate(self.rows[:-1])
        self.rows[-1]['row']['participant_id'] = 'different'
        with self.assertRaises(ValidationError):
            self.validate(self.rows)

    def test_repeated_identity_and_sequence_are_rejected(self):
        with self.assertRaises(ValidationError):
            self.validate(self.rows + [self.rows[0]])
        other = json.loads(json.dumps(self.rows[0]))
        other['row']['record_id'] = 'another'
        with self.assertRaises(ValidationError):
            self.validate(self.rows + [other])

    def test_unknown_envelope_fields_and_empty_batch_fail(self):
        with self.assertRaises(ValidationError):
            self.validate([{**self.rows[0], 'unvalidated': True}])
        with self.assertRaises(ValidationError):
            self.validate([])


if __name__ == '__main__':
    unittest.main()
