import copy
import json
import math
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from elicit_study import ValidationError, compile_study, validate_row, validate_study
from elicit_study.compiler import REGISTRY, STUDY_SCHEMA, components
from elicit_study.schema import study_schema

ROOT = Path(__file__).resolve().parents[1]
EXAMPLES = sorted((ROOT / 'examples').glob('*.study.json'))


def example(number=1):
    return json.loads(EXAMPLES[number - 1].read_text())


def component(study, pi=0, hi=0, ti=0, ci=0):
    return study['protocols'][pi]['phases'][hi]['trials'][ti]['components'][ci]


def answer(compiled, address='main/ratings/baseline/rating', **changes):
    protocol, phase, trial, _ = address.split('/')
    row = dict(revision_id=compiled['revision_id'], participant_id='participant-1', run_id='run-1', protocol_key=protocol, phase_key=phase, trial_key=trial, trial_occurrence_id='occurrence-1', component_path=address, record_id='record-1', sequence=0, occurred_at='2026-11-07T12:00:00Z', choice_key='option-1')
    row.update(changes)
    return row


class ContractTests(unittest.TestCase):
    def test_all_nine_examples_compile_without_mutating_input(self):
        self.assertEqual(len(EXAMPLES), 9)
        for path in EXAMPLES:
            with self.subTest(path=path.name):
                source = json.loads(path.read_text())
                original = copy.deepcopy(source)
                compiled = compile_study(source)
                self.assertEqual(source, original)
                self.assertEqual(compiled, compile_study(source))
                self.assertEqual(compiled, compile_study(compiled['definition']))
                self.assertEqual(len(compiled['revision_id']), 64)

    def test_catalog_covers_every_fixture_and_registry_component(self):
        catalog = json.loads((ROOT / 'examples/catalog.json').read_text())
        self.assertEqual({item['file'] for item in catalog['examples']}, {p.name for p in EXAMPLES})
        used = {c['type'] for p in EXAMPLES for _, c in components(json.loads(p.read_text()))}
        self.assertEqual(set(REGISTRY), used)

    def test_checked_in_editor_schema_matches_registry(self):
        self.assertEqual(STUDY_SCHEMA, study_schema())

    def test_editor_location_and_object_property_order_do_not_change_identity(self):
        source = example()
        compiled = compile_study(source)
        source['$schema'] = 'elsewhere/study.schema.json'
        source = dict(reversed(list(source.items())))
        self.assertEqual(compiled, compile_study(source))

    def test_definition_and_contract_change_when_choices_change(self):
        source = example()
        before = compile_study(source)
        component(source, ci=1)['config']['choices'][0]['key'] = 'changed'
        after = compile_study(source)
        self.assertNotEqual(before['revision_id'], after['revision_id'])
        self.assertNotEqual(before['result_contract_id'], after['result_contract_id'])

    def assert_invalid(self, source, code=None):
        with self.assertRaises(ValidationError) as caught:
            validate_study(source)
        self.assertTrue(caught.exception.issues[0]['path'].startswith('/'))
        if code:
            self.assertIn(code, [issue['code'] for issue in caught.exception.issues])

    def test_unknown_component_version_and_config_properties_rejected(self):
        for field, value in [('type', 'plugin_not_installed'), ('type_version', '99')]:
            source = example()
            component(source)[field] = value
            self.assert_invalid(source, 'schema')
        source = example()
        component(source)['config']['typo'] = 'value'
        self.assert_invalid(source, 'schema')

    def test_duplicate_keys_and_missing_order_references(self):
        source = example()
        phase = source['protocols'][0]['phases'][0]
        phase['trials'][1]['key'] = phase['trials'][0]['key']
        self.assert_invalid(source, 'duplicate_key')
        source = example()
        source['protocols'][0]['phase_order'] = ['does-not-exist']
        self.assert_invalid(source, 'phase_order')
        source = example()
        source['protocols'][0]['phases'][0]['order']['sequence'] = ['does-not-exist']
        self.assert_invalid(source, 'trial_order')

    def test_choice_keys_assets_layout_and_sampling(self):
        source = example()
        choices = component(source, ci=1)['config']['choices']
        choices[1]['key'] = choices[0]['key']
        self.assert_invalid(source, 'duplicate_key')
        source = example()
        component(source)['stimuli'] = ['missing']
        self.assert_invalid(source, 'unknown_asset')
        source = example()
        component(source)['layout'] = {'columns': [30, 30]}
        self.assert_invalid(source, 'layout')
        source = example(9)
        del source['protocols'][0]['phases'][1]['order']['count']
        self.assert_invalid(source, 'required')

    def test_range_cardinality_pattern_and_nonfinite_numbers(self):
        source = example(5)
        component(source)['config']['min'] = 2
        self.assert_invalid(source, 'range')
        source = example(3)
        component(source)['config']['max_selections'] = 100
        self.assert_invalid(source, 'cardinality')
        source = example(4)
        component(source)['config']['validation_pattern'] = '['
        self.assert_invalid(source, 'pattern')
        source = example(5)
        component(source)['config']['max'] = math.inf
        self.assert_invalid(source, 'non_finite')

    def test_end_marker_cannot_be_shuffled(self):
        source = example()
        source['protocols'][0]['phases'][-1]['order']['mode'] = 'shuffle'
        self.assert_invalid(source, 'end_order')

    def test_scoped_keys_and_multiple_protocols(self):
        source = example()
        other = copy.deepcopy(source['protocols'][0])
        other['key'] = 'other'
        source['protocols'].append(other)
        compiled = compile_study(source)
        self.assertIn('other/ratings/baseline/rating', compiled['bindings'])
        self.assertIn('main/ratings/baseline/rating', compiled['bindings'])

    def test_answer_choice_and_address_are_validated(self):
        compiled = compile_study(example())
        row = answer(compiled)
        validate_row(compiled, 'likert_v1_answer', row)
        for changes in [{'choice_key': 'unknown'}, {'component_path': 'unknown'}, {'revision_id': 'another'}, {'trial_key': 'wrong'}, {'sequence': -1}, {'occurred_at': '2026-11-07T12:00:00'}, {'occurred_at': '2026-11-07T12:00:00.1234567Z'}, {'extra': 1}]:
            with self.subTest(changes=changes), self.assertRaises(ValidationError):
                validate_row(compiled, 'likert_v1_answer', {**row, **changes})

    def test_specialized_answer_constraints(self):
        cases = [
            (3, 'main/questions/one-to-three/question', 'multiple_choice_v1_answer', {'choice_keys': ['option-1']}, {'choice_keys': []}),
            (3, 'main/questions/one-to-three/question', 'multiple_choice_v1_answer', {'choice_keys': ['option-1']}, {'choice_keys': ['option-1', 'option-1']}),
            (4, 'main/questions/ones/ones', 'free_text_v1_answer', {'text': '111'}, {'text': 'abc'}),
            (5, 'main/ratings/position/scale', 'scale_1d_v1_answer', {'position': 0.5}, {'position': 2}),
        ]
        for number, address, table, valid, invalid in cases:
            with self.subTest(table=table, invalid=invalid):
                compiled = compile_study(example(number))
                row = answer(compiled, address)
                row.pop('choice_key')
                validate_row(compiled, table, {**row, **valid})
                with self.assertRaises(ValidationError):
                    validate_row(compiled, table, {**row, **invalid})

    def test_disabled_streams_are_not_emitted(self):
        source = example(8)
        config = component(source, ti=1)['config']
        config.update(landmarks=False, blendshapes=False)
        compiled = compile_study(source)
        tables = compiled['bindings']['main/capture/calibrate/calibration']
        self.assertEqual(list(tables), ['face_calibration_v1_calibration'])

    def test_attached_media_events_are_bound_to_the_declared_asset(self):
        compiled = compile_study(example())
        row = answer(compiled, 'main/ratings/audio/rating')
        row.pop('choice_key')
        row.update(asset_key='piano', action='play', position_seconds=0)
        validate_row(compiled, 'attached_media_v1_event', row)
        with self.assertRaises(ValidationError):
            validate_row(compiled, 'attached_media_v1_event', {**row, 'asset_key': 'another'})
        with self.assertRaises(ValidationError):
            validate_row(compiled, 'attached_media_v1_event', {**row, 'component_path': 'main/ratings/baseline/rating'})

    def test_completion_codes_cannot_be_randomized(self):
        source = example(9)
        source['protocols'][0]['phases'][2]['order']['mode'] = 'shuffle'
        self.assert_invalid(source, 'end_order')

    def test_repeated_trial_answers_keep_separate_occurrences(self):
        compiled = compile_study(example(9))
        a = answer(compiled, 'main/repeated/trial-1/answer')
        b = {**a, 'trial_occurrence_id': 'occurrence-2', 'record_id': 'record-2'}
        for row in (a, b):
            validate_row(compiled, 'single_choice_v1_answer', row)
        self.assertNotEqual(a['trial_occurrence_id'], b['trial_occurrence_id'])

    def test_cli_reports_json_errors_and_nonzero_exit(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'invalid.json'
            path.write_text('{}')
            result = subprocess.run([sys.executable, '-m', 'elicit_study', 'validate', str(path)], capture_output=True, text=True)
            self.assertEqual(result.returncode, 1)
            self.assertFalse(json.loads(result.stderr)['valid'])


if __name__ == '__main__':
    unittest.main()
