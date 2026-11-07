"""Assemble the self-contained editor schema from the component registry."""

import copy
import json
from importlib.resources import files


def object_schema(properties, required=None, **annotations):
    return dict(type='object', properties=properties, required=list(properties) if required is None else required, additionalProperties=False, **annotations)


def study_schema():
    registry = json.loads(files('elicit_study').joinpath('contracts/components.json').read_text())['components']
    key = {'type': 'string', 'pattern': '^[a-z][a-z0-9_-]*$', 'minLength': 1, 'maxLength': 100}
    string = {'type': 'string'}

    def array(items, **kwargs):
        return dict(type='array', items=items, **kwargs)

    layout = object_schema({'columns': array({'type': 'number', 'exclusiveMinimum': 0, 'maximum': 100}, minItems=1, maxItems=4)})
    components = []
    for name, contract in registry.items():
        components.append(object_schema({
            'key': key, 'type': {'const': name}, 'type_version': {'const': contract['version']},
            'config': contract['config_schema'], 'stimuli': array(key, uniqueItems=True, default=[]), 'layout': layout,
        }, ['key', 'type', 'type_version', 'config'], title=contract['title'], description=contract['description']))
    order = object_schema({'mode': {'type': 'string', 'enum': ['fixed', 'shuffle', 'sample_with_replacement']}, 'sequence': array(key, minItems=1), 'count': {'type': 'integer', 'minimum': 1}}, ['mode', 'sequence'])
    trial = object_schema({'key': key, 'title': string, 'components': array({'oneOf': components}, minItems=1)}, ['key', 'components'])
    phase = object_schema({'key': key, 'title': string, 'trials': array(trial, minItems=1), 'order': order}, ['key', 'trials', 'order'])
    protocol = object_schema({'key': key, 'title': string, 'phases': array(phase, minItems=1), 'phase_order': array(key, minItems=1, uniqueItems=True)}, ['key', 'phases', 'phase_order'])
    asset = object_schema({'key': key, 'kind': {'type': 'string', 'enum': ['image', 'audio', 'video']}, 'uri': {'type': 'string', 'minLength': 1}, 'mime_type': {'type': 'string', 'minLength': 1}})
    schema = object_schema({
        '$schema': string, 'schema_version': {'const': '1'}, 'key': key, 'title': {'type': 'string', 'minLength': 1},
        'description': {'type': 'string', 'default': ''},
        'settings': object_schema({'allow_anonymous': {'type': 'boolean', 'default': False}, 'allow_previous': {'type': 'boolean', 'default': False}, 'lock_answers': {'type': 'boolean', 'default': True}}, []),
        'assets': array(asset, default=[]), 'protocols': array(protocol, minItems=1),
    }, ['schema_version', 'key', 'title', 'protocols'], title='Elicit study definition v1', description='Portable authored study. Keys are scoped to their containing object; assets are scoped to the study.')
    schema['$schema'] = 'http://json-schema.org/draft-07/schema#'
    schema['$id'] = 'https://elicit-experiment.com/schemas/study-v1.json'
    return copy.deepcopy(schema)
