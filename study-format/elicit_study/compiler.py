"""Pure, deterministic study compilation. No server state is consulted."""

import copy
import hashlib
import json
import math
import re
from importlib.resources import files
from functools import lru_cache

import fastjsonschema

COMPILER_VERSION = '1'


def contract(name):
    return json.loads(files('elicit_study').joinpath('contracts', name).read_text())


REGISTRY_DOCUMENT = contract('components.json')
REGISTRY = REGISTRY_DOCUMENT['components']
STUDY_SCHEMA = contract('study.schema.json')
_STRUCTURAL = fastjsonschema.compile(STUDY_SCHEMA, use_default=False)


class ValidationError(ValueError):
    def __init__(self, issues):
        self.issues = issues
        super().__init__('; '.join(f"{i['path']}: {i['message']}" for i in issues))


def _pointer(parts):
    return '/' + '/'.join(str(p).replace('~', '~0').replace('/', '~1') for p in parts)


@lru_cache(maxsize=1024)
def _validator(serialized_schema):
    return fastjsonschema.compile(json.loads(serialized_schema), use_default=False)


def _check(schema, value):
    try:
        _validator(json.dumps(schema, sort_keys=True))(value)
    except fastjsonschema.JsonSchemaException as exc:
        raise ValidationError([{'path': _pointer(exc.path[1:]), 'code': 'schema', 'message': exc.message}]) from exc


def _finite(value, path=()):
    if isinstance(value, float) and not math.isfinite(value):
        raise ValidationError([{'path': _pointer(path), 'code': 'non_finite', 'message': 'Numbers must be finite'}])
    if isinstance(value, dict):
        for key, child in value.items():
            _finite(child, (*path, key))
    elif isinstance(value, list):
        for index, child in enumerate(value):
            _finite(child, (*path, index))


def _defaults(schema, value):
    value = copy.deepcopy(value)
    if schema.get('type') == 'object':
        for key, prop in schema['properties'].items():
            if key not in value and 'default' in prop:
                value[key] = copy.deepcopy(prop['default'])
            if key in value:
                value[key] = _defaults(prop, value[key])
    elif schema.get('type') == 'array':
        value = [_defaults(schema['items'], item) for item in value]
    return value


def components(study):
    """Yield stable scoped addresses and components in authored order."""
    for protocol in study['protocols']:
        for phase in protocol['phases']:
            for trial in phase['trials']:
                for component in trial['components']:
                    yield '/'.join([protocol['key'], phase['key'], trial['key'], component['key']]), component


def validate_study(study):
    """Return a deep-copied normalized definition or structured diagnostics."""
    _finite(study)
    try:
        _STRUCTURAL(study)
    except fastjsonschema.JsonSchemaException as exc:
        raise ValidationError([{'path': _pointer(exc.path[1:]), 'code': 'schema', 'message': exc.message}]) from exc
    study = copy.deepcopy(study)
    study.pop('$schema', None)  # Editor location is not part of definition identity.
    study.setdefault('description', '')
    study['settings'] = _defaults(STUDY_SCHEMA['properties']['settings'], study.get('settings', {}))
    study.setdefault('assets', [])
    issues = []

    def error(path, code, message):
        issues.append({'path': _pointer(path), 'code': code, 'message': message})

    def keys(items, path):
        seen = set()
        for index, item in enumerate(items):
            if item['key'] in seen:
                error((*path, index, 'key'), 'duplicate_key', f"Duplicate key {item['key']!r}")
            seen.add(item['key'])
        return seen

    asset_keys = keys(study['assets'], ('assets',))
    keys(study['protocols'], ('protocols',))
    for pi, protocol in enumerate(study['protocols']):
        pp = ('protocols', pi)
        phase_keys = keys(protocol['phases'], (*pp, 'phases'))
        if set(protocol['phase_order']) != phase_keys:
            error((*pp, 'phase_order'), 'phase_order', 'Phase order must contain every phase key exactly once')
        for hi, phase in enumerate(protocol['phases']):
            hp = (*pp, 'phases', hi)
            trial_keys = keys(phase['trials'], (*hp, 'trials'))
            order = phase['order']
            if set(order['sequence']) != trial_keys or len(order['sequence']) != len(trial_keys):
                error((*hp, 'order', 'sequence'), 'trial_order', 'Sequence must contain every trial key exactly once; use replacement mode to repeat')
            if order['mode'] == 'sample_with_replacement' and 'count' not in order:
                error((*hp, 'order', 'count'), 'required', 'Replacement sampling requires a draw count')
            if order['mode'] != 'sample_with_replacement' and 'count' in order:
                error((*hp, 'order', 'count'), 'unexpected', 'Draw count is only valid for replacement sampling')
            for ti, trial in enumerate(phase['trials']):
                tp = (*hp, 'trials', ti)
                keys(trial['components'], (*tp, 'components'))
                for ci, component in enumerate(trial['components']):
                    cp = (*tp, 'components', ci)
                    kind = component['type']
                    config = _defaults(REGISTRY[kind]['config_schema'], component['config'])
                    component['config'] = config
                    component.setdefault('stimuli', [])
                    refs = component['stimuli'] + ([config['asset']] if kind == 'media' else [])
                    for ref in refs:
                        if ref not in asset_keys:
                            error(cp, 'unknown_asset', f"Unknown asset {ref!r}")
                    if component['stimuli'] and kind in ('media', 'monitor', 'face_landmark', 'face_calibration', 'end'):
                        error((*cp, 'stimuli'), 'unsupported_stimuli', 'This component does not support attached stimuli')
                    if 'layout' in component and not math.isclose(sum(component['layout']['columns']), 100, abs_tol=1e-6):
                        error((*cp, 'layout', 'columns'), 'layout', 'Column percentages must sum to 100')
                    if kind in ('likert', 'single_choice', 'multiple_choice'):
                        keys(config['choices'], (*cp, 'config', 'choices'))
                    if kind == 'multiple_choice':
                        maximum = config.setdefault('max_selections', len(config['choices']))
                        if config['min_selections'] > maximum or maximum > len(config['choices']):
                            error((*cp, 'config'), 'cardinality', 'Require min_selections <= max_selections <= number of choices')
                    if kind == 'scale_1d':
                        if config['min'] >= config['max']:
                            error((*cp, 'config'), 'range', 'Scale minimum must be less than maximum')
                        for index, tick in enumerate(config['ticks']):
                            if not config['min'] <= tick['value'] <= config['max']:
                                error((*cp, 'config', 'ticks', index), 'range', 'Tick is outside scale bounds')
                    if kind == 'free_text' and 'validation_pattern' in config:
                        try:
                            re.compile(config['validation_pattern'])
                        except re.error:
                            error((*cp, 'config', 'validation_pattern'), 'pattern', 'Invalid regular expression')
                    if kind in ('end', 'completion_code') and order['mode'] != 'fixed':
                        error(cp, 'end_order', 'Completion and end components require fixed-order phases')
                    if kind == 'end' and (order['sequence'][-1] != trial['key'] or protocol['phase_order'][-1] != phase['key']):
                        error(cp, 'end_order', 'End components must be in the last trial of the final phase')
    if issues:
        raise ValidationError(issues)
    return study


def _object(properties):
    return {'type': 'object', 'properties': properties, 'required': list(properties), 'additionalProperties': False}


def _string(**kwargs):
    return {'type': 'string', **kwargs}


def _hash(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(',', ':'), ensure_ascii=False, allow_nan=False).encode()).hexdigest()


def compile_study(study):
    study = validate_study(study)
    revision = _hash(study)
    timestamp = _string(
        format='date-time',
        pattern=r'^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]{1,6})?(Z|[+-][0-9]{2}:[0-9]{2})$',
    )
    identity = {'revision_id': _string(const=revision), 'participant_id': _string(minLength=1), 'run_id': _string(minLength=1)}
    occurrence = {**identity, 'protocol_key': _string(), 'phase_key': _string(), 'trial_key': _string(), 'trial_occurrence_id': _string(minLength=1)}
    status = _string(enum=['in_progress', 'completed', 'skipped', 'abandoned'])
    tables = {
        'runs': _object({**identity, 'status': status, 'started_at': timestamp, 'completed_at': {'anyOf': [timestamp, {'type': 'null'}]}}),
        'trial_occurrences': _object({**occurrence, 'status': status, 'sequence': {'type': 'integer', 'minimum': 0}, 'started_at': timestamp, 'completed_at': {'anyOf': [timestamp, {'type': 'null'}]}}),
    }
    bindings = {}
    for address, component in components(study):
        kind, config = component['type'], component['config']
        outputs = copy.deepcopy(REGISTRY[kind]['outputs'])
        if kind == 'monitor':
            outputs = {name: schema for name, schema in outputs.items() if config[name]}
        if kind in ('face_landmark', 'face_calibration'):
            if not config['landmarks']:
                outputs.pop('landmark', None)
            if not config['blendshapes']:
                outputs.pop('blendshape', None)
        if component['stimuli']:
            outputs['stimulus_event'] = copy.deepcopy(REGISTRY_DOCUMENT['attached_media_output'])
        for channel, payload in outputs.items():
            table = 'attached_media_v1_event' if channel == 'stimulus_event' else f'{kind}_v1_{channel}'
            common = {**occurrence, 'component_path': _string(), 'record_id': _string(minLength=1), 'sequence': {'type': 'integer', 'minimum': 0}, 'occurred_at': timestamp}
            tables.setdefault(table, _object({**common, **copy.deepcopy(payload['properties'])}))
            specialized = _object({**common, **payload['properties']})
            props = specialized['properties']
            props['component_path'] = _string(const=address)
            for field, value in zip(('protocol_key', 'phase_key', 'trial_key'), address.split('/')[:3]):
                props[field] = _string(const=value)
            if kind in ('likert', 'single_choice') and channel == 'answer':
                props['choice_key']['enum'] = [choice['key'] for choice in config['choices']]
            if kind == 'multiple_choice' and channel == 'answer':
                props['choice_keys'].update(minItems=max(config['min_selections'], int(config['required'])), maxItems=config['max_selections'])
                props['choice_keys']['items']['enum'] = [choice['key'] for choice in config['choices']]
            if kind == 'free_text' and channel == 'answer':
                if config['required']:
                    props['text']['minLength'] = 1
                if 'max_length' in config:
                    props['text']['maxLength'] = config['max_length']
                if 'validation_pattern' in config:
                    props['text']['pattern'] = config['validation_pattern']
            if kind == 'scale_1d' and channel == 'answer':
                props['position'].update(minimum=config['min'], maximum=config['max'])
            if channel in ('landmark', 'blendshape'):
                props['face_index']['maximum'] = config['number_of_faces'] - 1
            if channel == 'landmark' and not config['include_z']:
                props['z'] = {'type': 'null'}
            if channel == 'stimulus_event':
                props['asset_key']['enum'] = component['stimuli']
            bindings.setdefault(address, {})[table] = specialized
    compiled = {'format_version': '1', 'compiler_version': COMPILER_VERSION, 'revision_id': revision, 'definition': study, 'tables': tables, 'bindings': bindings}
    compiled['result_contract_id'] = _hash(compiled)
    return compiled


def validate_row(compiled, table, row):
    """Validate before serialization, including component-specific constraints."""
    _finite(row)
    schema = compiled['tables'].get(table)
    if schema is None:
        raise ValidationError([{'path': '/', 'code': 'unknown_table', 'message': table}])
    _check(schema, row)
    if table not in ('runs', 'trial_occurrences'):
        specialized = compiled['bindings'].get(row['component_path'], {}).get(table)
        if specialized is None:
            raise ValidationError([{'path': '/component_path', 'code': 'unknown_output', 'message': 'Component does not emit this output'}])
        _check(specialized, row)
    if table == 'trial_occurrences':
        protocol = next((p for p in compiled['definition']['protocols'] if p['key'] == row['protocol_key']), None)
        phase = next((p for p in protocol['phases'] if p['key'] == row['phase_key']), None) if protocol else None
        if phase is None or row['trial_key'] not in {t['key'] for t in phase['trials']}:
            raise ValidationError([{'path': '/trial_key', 'code': 'unknown_trial', 'message': 'Unknown trial address'}])
    return row
