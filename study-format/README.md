# Canonical study format and asynchronous delivery

This package is the contract foundation on top of the SQLite migration. It rewrites nine representative client-api workflows as complete, portable study documents and compiles them into typed result contracts. It runs without Rails, a database, credentials, network access, or participant accounts.

The branch includes asynchronous canonical definition/result uploads, durable operation polling, participant-filtered Parquet ZIP exports, and authorized local or signed S3-compatible downloads. See [the delivery API guide](../doc/canonical-study-delivery.md) and [Python example](examples/deliver.py).

The existing participant runtime still requires a compatibility adapter. Canonical imports return `runtime_status: definition_only`; they store a versioned definition and typed results but do not create runnable v1 protocol graphs. Historical v1 result conversion and the editor UI are separate work. V1 mutation of canonical studies is blocked so it cannot bypass their revision contract.

## Try the examples

From the repository root:

```bash
python -m pip install -e './study-format[parquet]'
elicit-study validate study-format/examples/01-likert.study.json
elicit-study normalize study-format/examples/01-likert.study.json --output /tmp/normalized-study.json
elicit-study compile study-format/examples/01-likert.study.json --output /tmp/result-contract.json
python -m unittest discover -s study-format/tests -v
```

The base install needs `fastjsonschema`; `pyarrow` is optional unless exporting Parquet. Once installed, validation and compilation are entirely offline. Tests explicitly skip Parquet checks when that optional dependency is absent; CI installs it and executes those checks.

See [examples/README.md](examples/README.md) for the selection and legacy source mapping. JSON documents replace executable graph-building scripts; no investigator IDs, user creation, API hosts, or enrolment records appear in them. Asset URIs may point to remote content, but validation never downloads it. The example media references are illustrative links retained from the old examples, without availability guarantees.

## Authoring contract and editor support

[components.json](elicit_study/contracts/components.json) is the versioned registry of component configuration schemas and output payload schemas. [study.schema.json](elicit_study/contracts/study.schema.json) is the generated, self-contained JSON Schema draft-07 document for editors and other languages. Every example has a relative `$schema` reference, so an editor can provide completion and structural validation using local files. Neither file contains remote `$ref` dependencies.

Generate the editor schema after changing the registry:

```bash
elicit-study schema --output study-format/elicit_study/contracts/study.schema.json
```

CI detects drift. Unknown fields, types and component versions are rejected. Do not widen a published component contract in place: the format is currently an experimental v1 proposal; freeze/version contracts before production use.

The offline compiler additionally checks scoped key uniqueness, references, ordering, layout percentages, selection bounds, scale bounds, and terminal component placement. Diagnostics include JSON Pointer paths, error codes and messages. A future editor must run these semantic checks as well as generic JSON Schema validation. Component titles, descriptions, field schemas, choices and defaults are available locally; an editor can build a component palette and forms without consulting the running application. Rich text rendering, asset previews and a JavaScript/WASM semantic validator remain later work. Free-text regular expressions currently follow the Python validator's behavior; use simple shared-dialect patterns until cross-language conformance is added.

Identity rules:

- Protocol keys are unique within a study; phase keys within a protocol; trial keys within a phase; component keys within a trial. Asset keys are unique within the study. Keys cannot contain `/`.
- A component address is `protocol/phase/trial/component`. Labels can change without changing addresses.
- Phase order includes every phase exactly once. Each trial sequence names every trial exactly once. `fixed` executes it in order; `shuffle` permutes it without replacement; `sample_with_replacement` draws `count` occurrences from it with equal probability. Separate phases express practice, randomized assessment, and completion. Completion/end components are outside randomized phases.
- Authored document → deep copy → explicit defaults → normalized definition. Compilation never samples random orders or generates completion codes. Those are per-run runtime decisions, which must be recorded in results.
- `revision_id` is SHA-256 of UTF-8 canonicalized normalized JSON (sorted keys, compact separators, literal Unicode, no non-finite numbers). The editor's `$schema` location is excluded. Arrays remain ordered. This is a Python compiler identity, not a claim of RFC 8785 canonicalization across languages.
- `result_contract_id` additionally covers compiler version, derived tables and component bindings. Repeated compilation is deterministic. Store both identities with runs and exports.

## Result tables and Parquet

`compile_study()` returns the normalized definition, revision/contract identities, table row schemas and per-component output bindings. Output types come from the registry; constraints such as choice enums, text patterns, scale limits and face indices are specialized from configuration. Nothing is inferred from observed results.

The logical tables are:

| Table | Row meaning |
| --- | --- |
| `runs` | Participant run and lifecycle status |
| `trial_occurrences` | Actual trial presentation, including its execution sequence and status |
| `<component>_v1_answer` | Response occurrence with typed payload columns |
| `<component>_v1_event`, `attached_media_v1_event` | Standalone or attached-media lifecycle event |
| `<component>_v1_mouse`, `_keyboard` | Enabled monitoring outputs |
| `<component>_v1_landmark`, `_blendshape`, `_calibration` | Typed face capture/calibration observations |

All component rows carry participant, run, revision, definition address, trial occurrence, record ID, timestamp and sequence. Repeating the same trial creates different occurrence IDs, never an implicit last-answer overwrite. Answers contain actual responses; skipped or unfinished trials are represented by occurrence status, not synthetic answers. Revising an answer emits another response occurrence with a new record ID/sequence; analytical views must declare how they select responses. Trial occurrence sequence is scoped to a run; component row sequence is scoped to component/output within a trial occurrence. Timestamp strings must include a timezone and at most six fractional second digits; Parquet stores UTC microseconds without silently truncating finer timestamps. Mouse and calibration coordinates are CSS pixels; landmark coordinates use MediaPipe normalized space. `sample_id` connects landmarks/blendshapes from one capture, with `face_index` identifying the face.

No participant-wide pivot, derived correctness score, duration aggregation, or generic JSON `value` field is implicit in this contract. The compiler declares possible outputs; it does not guarantee every table has rows. Attached-media events use `attached_media_v1_event`, with an `asset_key` restricted to that component's declared stimuli. Component-independent system events still need explicit contracts in the runtime branch.

The local writer accepts a lazy iterable of `(table_name, row)` pairs:

```python
from elicit_study import compile_study
from elicit_study.parquet import write_export

compiled = compile_study(study_document)
manifest = write_export(
    compiled, rows, '/tmp/new-export',
    snapshot_id='snapshot-123', batch_size=65536,
)
```

`write_export` validates rows before writing, buffers at most `batch_size` rows across tables, and emits finalized Zstandard-compressed Parquet parts. Large individual rows are not byte-bounded by this setting. Every declared table gets a typed empty part when necessary. The destination must not already exist; retries use a fresh staging destination. Partial files have no committed manifest.

The writer copies definition/contract metadata and publishes `manifest.json` last through a local atomic rename. It lists relative paths, sizes, row counts and SHA-256 checksums. It does not enforce cross-row foreign keys, unique record IDs, timestamp ordering, completeness, or snapshot consistency; the extraction layer must enforce those. It is a bounded-memory local generator, not yet a resumable export engine. A production worker should tune part sizes independently of extraction batch size and compact small parts before publication.

For an NDJSON bridge into the local CLI, each input line is `{"table": "likert_v1_answer", "row": {...}}`:

```bash
elicit-study export study-format/examples/01-likert.study.json \
  --rows /tmp/rows.ndjson --snapshot-id snapshot-123 --output /tmp/new-export
```

Read a table in Python:

```python
import pyarrow.dataset as ds

answers = ds.dataset('/tmp/new-export/likert_v1_answer', format='parquet')
selected = answers.to_table(
    columns=['participant_id', 'trial_occurrence_id', 'choice_key'],
    filter=ds.field('participant_id') == 'participant-1',
)
```

## Runtime compatibility boundary

The next branch should use these fixtures as acceptance inputs for a legacy-runtime compiler and immutable revision persistence. The existing opaque `definition_data` fields must become projections of a validated revision; v1 mutation must not bypass that revision boundary. Both incoming results and export adapters must validate against the run's pinned result contract. A deployed server must use this compiler or a conformance-tested implementation; simply loading the editor schema omits semantic checks.

The [delivery implementation](../doc/canonical-study-delivery.md) already provides full-document staging, immutable revision publication, result batch validation, snapshot export, ZIP packaging, operation recovery and authorized download links. Exports are explicitly scoped to one revision; consumers can request several revision exports when needed. Legacy result extraction and runtime rendering remain the compatibility boundary.

A schema-based offline editor can precede that server branch: edit a portable document, validate it locally, inspect its generated result contract, save it, then submit the same document when connected. The runtime compiler and rendering preview remain necessary before claiming behavioral parity with the old examples.
