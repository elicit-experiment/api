# Study and result schema reference

The canonical document describes authored study structure. Compilation adds explicit defaults, validates references and derives the possible result tables. It does not execute the study, choose random trial orders, generate participant completion codes or download media.

[Python usage](python.md), [nine complete workflows](../examples/README.md), [component contracts](../elicit_study/contracts/components.json), [generated editor schema](../elicit_study/contracts/study.schema.json) and [HTTP delivery](../../doc/canonical-study-delivery.md) cover the adjacent interfaces.

## A minimal complete definition

This valid document contains one protocol, phase, trial and two-choice question:

```json
{
  "schema_version": "1",
  "key": "confidence-study",
  "title": "Confidence study",
  "protocols": [
    {
      "key": "main",
      "phase_order": ["assessment"],
      "phases": [
        {
          "key": "assessment",
          "order": {"mode": "fixed", "sequence": ["confidence"]},
          "trials": [
            {
              "key": "confidence",
              "components": [
                {
                  "key": "rating",
                  "type": "likert",
                  "type_version": "1",
                  "config": {
                    "prompt": "How confident are you?",
                    "choices": [
                      {"key": "low", "label": "Low"},
                      {"key": "high", "label": "High"}
                    ]
                  }
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

Save it as `study.json`, then run `elicit-study validate study.json`. A terminal/end component is optional; when present it must occupy the final trial of the final fixed-order phase.

## Document fields

Unknown fields are rejected at each object level. Keys match `^[a-z][a-z0-9_-]*$` and contain at most 100 characters. Version fields are strings, not integers.

| Object | Required fields | Optional fields/defaults |
| --- | --- | --- |
| Study | `schema_version: "1"`, `key`, nonempty `title`, nonempty `protocols` | `$schema` editor hint, `description: ""`, `settings`, `assets: []` |
| Settings | None | `allow_anonymous: false`, `allow_previous: false`, `lock_answers: true` |
| Protocol | `key`, nonempty `phases`, `phase_order` | `title` |
| Phase | `key`, nonempty `trials`, `order` | `title` |
| Trial | `key`, nonempty `components` | `title` |
| Component | `key`, `type`, `type_version: "1"`, `config` | `stimuli: []`, `layout` |
| Asset | `key`, `kind`, nonempty `uri`, nonempty `mime_type` | None |

Study settings describe authored behavior. Accounts, investigator IDs, enrolment and live allocation state belong to the server and are not portable definition fields.

Keys are scoped to their container: protocols within a study, phases within a protocol, trials within a phase and components within a trial. Assets are scoped to the study. Choice keys are unique within their question. Reusing `rating` in another trial is valid; duplicating it within the same trial is not. A component address joins its keys: `main/assessment/confidence/rating`. Display labels are not identifiers.

## Ordering, assets and layout

`phase_order` must contain every phase key exactly once. An order's `sequence` must contain every trial key in its phase exactly once, regardless of mode:

| Mode | Meaning | Additional fields |
| --- | --- | --- |
| `fixed` | Execute the sequence in order | No `count` |
| `shuffle` | Permute the sequence without replacement | No `count` |
| `sample_with_replacement` | Draw uniformly from the listed trials, allowing repetitions | Required positive integer `count` |

These are declarative runtime rules. Compilation does not select a sequence. Record actual execution in trial occurrences. Put completion codes in fixed-order phases; end components must additionally be in the final trial and final phase. These rules describe the intended new runtime; the existing v1 runner still needs its adapter.

Asset `kind` is `image`, `audio` or `video`. `uri` can refer to local or remote content; current validation only requires a nonempty string and does not verify availability or MIME/content agreement. A standalone `media` component names an asset in `config.asset`. An instrument can attach study assets using `stimuli: ["asset-key"]`; `media`, `monitor`, face components and `end` do not accept attached stimuli.

`layout` currently contains `columns`, an array of one to four positive percentages no greater than 100; they must sum to 100. It is a presentation contract, not a claim of exact legacy rendering parity.

## Component catalogue

The registry is the precise field/type/default authority. This table summarizes its current v1 contracts; optional config fields must still match the registry.

| Type | Required config | Important optional config/defaults | Output payloads |
| --- | --- | --- | --- |
| `text` | `text` | None | No direct output |
| `likert` | `prompt`, at least two `choices` | `required: true`, `show_feedback: false`, `answer_once: false` | `answer`: `choice_key` |
| `single_choice` | `prompt`, at least two `choices` | Same choice flags as Likert | `answer`: `choice_key` |
| `multiple_choice` | `prompt`, at least two `choices` | Choice flags; `min_selections: 0`; `max_selections` defaults to choice count | `answer`: unique `choice_keys` list |
| `free_text` | `prompt` | `required: true`, `rows: 4`, optional `max_length`, `validation_pattern` | `answer`: `text` |
| `scale_1d` | `prompt` | `min: -1`, `max: 1`, `required: true`, `ticks: []` | `answer`: numeric `position` |
| `media` | `asset` | `optional: true`, `pausable: true`, `replayable: true`, `autoplay: false`, optional `max_replays` | `event`: `action`, nullable `position_seconds` |
| `monitor` | None (`config: {}` is valid) | `mouse: true`, `keyboard: false`, `max_rate_hz: 30` | Enabled `mouse` and/or `keyboard` outputs |
| `face_landmark` | None | `number_of_faces: 1`, `landmarks: true`, `blendshapes: false`, `include_z: false`, `max_rate_hz: 30` | Enabled `landmark` and/or `blendshape` outputs |
| `face_calibration` | None | Face flags above, plus `duration_seconds: 5` | `calibration`, plus enabled face outputs |
| `completion_code` | None | `prefix: ""`, `length: 8` | `answer`: `text` generated at runtime |
| `end` | None | `message: "Thank you for participating."` | No direct output |

Each choice has `key` and `label`; optional `correct` defaults to false. Multiple-choice result cardinality respects configured bounds, and a required response has at least one selection. Scale minimum must be below maximum and ticks must lie within its range. Free-text patterns currently use the Python validator's behavior; cross-language regex parity is not guaranteed.

Media event actions are `render`, `play`, `pause`, `ended` and `error`. Mouse/calibration coordinates are CSS pixels with viewport dimensions. Landmark rows contain `sample_id`, `face_index`, `landmark_index`, `x`, `y`, `z`; blendshape rows contain `sample_id`, `face_index`, `category`, `score`. Landmark coordinates use MediaPipe normalized space. `z` is required but must be null when `include_z` is false. Calibration rows contain `point_key`, `x`, `y` and viewport dimensions. Mouse/keyboard and face output tables are omitted when the corresponding capture is disabled.

## Normalization and identity

`validate_study` returns a deep copy with defaults; it does not mutate the input. The editor-only `$schema` field is removed. Object property ordering and the editor schema's location do not affect identity; authored array order does. Choice/default configuration changes can change the normalized definition and revision identity.

`compile_study` returns:

| Field | Meaning |
| --- | --- |
| `format_version` | Compiled contract format, currently `"1"` |
| `compiler_version` | Compiler contract version, currently `"1"` |
| `revision_id` | SHA-256 of normalized definition JSON |
| `definition` | Normalized definition |
| `tables` | Table name → general JSON Schema for a row |
| `bindings` | Component address → table name → configuration-specialized row schema |
| `result_contract_id` | SHA-256 covering the compiled artifact before this identity field is added |

The hash encoding sorts object keys, uses compact separators and literal Unicode, and rejects non-finite floating-point values. It is the Python implementation's canonicalization, not RFC 8785 interoperability. Preserve stored compiled contracts when reading existing results; do not regenerate them implicitly with a newer compiler.

## Results and execution identity

All rows require `revision_id`, nonempty `participant_id` (at most 200 characters) and `run_id`. A participant ID is investigator-assigned and need not name an application account.

| Table | Additional identity/context | Payload |
| --- | --- | --- |
| `runs` | Run identity | `status`, `started_at`, nullable `completed_at` |
| `trial_occurrences` | `protocol_key`, `phase_key`, `trial_key`, `trial_occurrence_id` | `status`, nonnegative `sequence`, `started_at`, nullable `completed_at` |
| Component outputs | Trial occurrence context above, `component_path`, `record_id` | Nonnegative `sequence`, `occurred_at`, plus typed component payload |

Statuses are `in_progress`, `completed`, `skipped` or `abandoned`. Timestamps use an uppercase `T`, timezone (`Z` or offset), and at most six fractional second digits. Parquet stores UTC microseconds. Row schemas do not enforce timestamp chronology or lifecycle completeness.

Ordinary output table names are `<type>_v1_<channel>`, such as `likert_v1_answer` or `face_landmark_v1_landmark`. Attached stimuli add `attached_media_v1_event` to that instrument's bindings, with `asset_key` restricted to its declared stimuli and the media event fields.

A trial definition can occur repeatedly. Each presentation needs a distinct `trial_occurrence_id`; never pivot or overwrite it implicitly. Trial sequence is scoped to a run. Component sequence is scoped to run, occurrence, component and output table. A later answer within one complete batch uses a new `record_id` and sequence.

`tables` describe shared physical shapes; `bindings` add exact addresses, allowed choice keys, selection counts, text constraints, numeric bounds and configured face indices. Use `validate_row`, which checks both. Checking only the table schema misses component-specific constraints.

## Batch integrity and serialization

A result upload is NDJSON with exactly `table` and `row` on each line. The same batch must include every referenced run and occurrence, in any order. Batch validation rejects mismatched participants/addresses and duplicate identities or scoped sequences. Record identity is `(table, run_id)` for runs, `(table, run_id, trial_occurrence_id)` for trials, and `(table, run_id, record_id)` for component outputs. Stored batches are append-only: a later import can add new runs, but cannot replace or extend an already imported run.

A self-contained batch does not require a `completed` status: current validation permits `in_progress` runs. Because a published run cannot be extended through another import, collect all rows you intend to retain before uploading that run.

Local `write_export` only validates individual rows. Batch integrity and consistent snapshot selection must be established separately. Its manifest commits finalized Parquet parts, typed empty tables, the normalized definition and stored compiled contract. The manifest records paths, byte sizes, SHA-256 values and per-part row counts. A failed export can leave files but has no committed manifest. See [the Python guide](python.md) for a complete validated batch and export example.

## Offline editors and version changes

Point a JSON Schema-aware editor at the checked-in schema. The nine examples use a relative `$schema` hint. For a document at another location, adjust the hint; the schema's HTTPS `$id` is an identifier, not a required network service. All structural schema resources are local and self-contained.

Generic editor validation provides types and completion; semantic checks such as uniqueness, references and ordering still require the compiler. Inspect the generated bindings to preview the result contract. Do not equate schema validity with a rendered/runnable legacy experiment.

For contract changes, edit the registry or assembler, regenerate the editor schema, update examples/docs and verify valid/invalid cases. The format is experimental; freeze contracts before release and version incompatible changes thereafter. Document schema version, component version, compiler version and export version have different roles. See [contributor instructions](../AGENTS.md).
