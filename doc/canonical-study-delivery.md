# Canonical study delivery

The v2 API delivers the canonical format from end to end: stage a whole definition, validate/publish it asynchronously, import complete result batches, then request one-participant or all-participant Parquet ZIP exports. There is no client-side graph construction or result pagination.

The server invokes the same Python package used for offline authoring, with file arguments and no shell interpolation. Definitions and compiled result contracts are immutable and stored together. Imports return `runtime_status: definition_only`: the existing v1 participant runtime and its historical results need an explicit compatibility adapter. The API does not pretend those studies are runnable or export legacy data as canonical results. Canonical studies are hidden from the public study list, and v1 mutations return `409`.

For authoring fields and typed rows, see the [schema reference](../study-format/docs/schema.md). For local validation/export functions, the client API and CLI, see the [Python library guide](../study-format/docs/python.md).

## Run locally with SQLite

Use the project's normal Ruby setup and environment variables, then install the worker dependency and prepare both databases:

```bash
python3 -m venv study-format/.venv
study-format/.venv/bin/pip install -e './study-format[parquet]'
export STUDY_FORMAT_PYTHON="$PWD/study-format/.venv/bin/python"
export DATABASE_ADAPTER=sqlite3
export SQLITE_DATABASE_DIR=storage
export STUDY_TRANSFER_STORAGE_SERVICE=local
bundle exec rails db:prepare
```

Python must be 3.10 or later. Start the API and `bin/jobs` in separate terminals with the same environment. The existing Solid Queue configuration consumes `study_transfers`; its recurring recovery job repairs committed submissions that were not enqueued and reclaims worker attempts after their lease expires. Docker includes managed Python and installs the package with PyArrow. Production uses the configured Active Storage service by default; `STUDY_TRANSFER_STORAGE_SERVICE` can select an existing storage service without changing other application uploads.

For S3-compatible delivery, use the existing `digital_ocean` service and its `AWS_ACCESS_ID`, `AWS_SECRET_ACCESS_KEY`, and `DO_BUCKET_NAME` configuration. Keep the bucket private. Local storage serves files through authenticated API routes. S3 responses include five-minute signed object URLs, refreshed by polling the stable operation resource. No cloud credentials are sent to the Python client.

## Authentication and requests

Use the existing OAuth bearer token with `public` scope, belonging to an investigator or administrator. Investigators can only access their own studies and operations; administrators can access all. Authorization is checked on submission, worker publication, polling, revision retrieval, link refresh and download.

Every submission requires an `Idempotency-Key` of 1–200 characters. Repeating the same body, target and options returns the same operation. Reusing the key for a different request returns `409`. Keys are scoped to the requesting user. Uploads currently have a 512 MiB limit; larger inputs can be divided into complete batches of separate runs. Processing has a 15-minute subprocess time limit per compiler stage, with renewed 30-minute worker leases and fencing at publication.

| Request | Body / behavior |
| --- | --- |
| `POST /api/v2/study-imports` | Complete study JSON; create a new hidden study and its first revision |
| `POST /api/v2/studies/:study_id/revision-imports?expected_revision_id=:digest` | Complete replacement definition; reject stale bases during publication |
| `GET /api/v2/studies/:study_id/revisions/:digest` | Normalized canonical definition |
| `GET /api/v2/studies/:study_id/revisions/:digest/result-schema` | Stored compiled contract, including table schemas and component bindings |
| `POST /api/v2/studies/:study_id/revisions/:digest/result-imports` | NDJSON result batch using `application/x-ndjson` |
| `POST /api/v2/studies/:study_id/revisions/:digest/result-exports` | `{}` for all imported participants, or `{"participant_ids":["participant-1"]}` |
| `GET /api/v2/study_operations/:id` | Durable status, phase, diagnostics, result and fresh download resources |
| `POST /api/v2/study_operations/:id/retry` | Retry a failed operation with its original staged input |
| `GET /api/v2/study_operations/:id/artifacts/:artifact_id` | Authorized download, or short-lived redirect to object storage |

Submissions return `202 Accepted` and a `Location` header. Semantic validation happens in the worker; invalid documents produce a failed operation with JSON Pointer diagnostics and no partially published revision/results/artifact. Syntax errors in HTTP JSON or invalid options can fail immediately. Status is `queued`, `running`, `succeeded` or `failed`; phases distinguish validation, snapshotting, Parquet writing and uploading. Corrected input is a new submission/key; retry is for a failed attempt whose original input should be processed again.

A successful definition import returns the numeric study ID and a SHA-256 revision digest. Each export targets exactly one such revision. Use the original immutable document and stored result contract even after publishing newer definitions.

## Result uploads

Each line has exactly these fields:

```json
{"table":"likert_v1_answer","row":{"revision_id":"...","participant_id":"participant-1","run_id":"run-1","protocol_key":"main","phase_key":"ratings","trial_key":"baseline","trial_occurrence_id":"occurrence-1","component_path":"main/ratings/baseline/rating","record_id":"answer-1","sequence":0,"occurred_at":"2026-11-07T12:01:00Z","choice_key":"option-1"}}
```

The same batch must contain its referenced `runs` and `trial_occurrences` rows. They may appear in any order. Table names and payload fields come from the revision's compiled contract; unknown fields, unsupported outputs, invalid choices and cross-participant/mismatched occurrence references fail validation. Participant IDs are opaque investigator-assigned strings up to 200 characters, not application account IDs.

Imports are append-only, whole-run batches. New batches can add new runs, including further runs for the same participant. Existing run/record identities cannot be replaced or extended through a second batch; duplicate identities fail atomically. This matches the intended once-per-user/run bulk transfer workflow. Streaming collection and revision-pinned v1 ingestion remain future runtime adapter work.

The worker uses a temporary SQLite index for bounded-memory cross-record validation, then atomically inserts all validated records into the configured primary database. A crash or validation/uniqueness failure cannot expose half a batch. The same implementation works with the project's SQLite/PostgreSQL storage configuration.

## Export and download

The export worker reads committed immutable records in a consistent database snapshot (SQLite read transaction or PostgreSQL repeatable read), materializes a temporary NDJSON stream, and releases the database snapshot before conversion/upload. Participant filtering applies to every table. An explicitly requested participant with no imported run fails validation, while an all-participant export with no results produces correctly typed empty tables.

The resulting ZIP uses storage mode around already compressed Parquet files. It contains all table parts, `study-definition.json`, `result-contract.json`, and `manifest.json`. The manifest names every part and records its SHA-256, size and row count. The operation also records the archive SHA-256 and a stable snapshot ID. Later result imports never change an existing export.

An archive is uploaded before its attachment and successful operation state are committed. Worker claim fencing prevents a superseded attempt from publishing its output. Duplicate job execution is harmless. Downloads are exposed only for successful operations. Failed attempts can be retried; input staging and completed artifacts are currently retained until operator cleanup. Storage retention automation, multipart direct uploads and per-object dataset download links are not implemented in this iteration. No HTTP request remains open while Parquet conversion runs.

The Python client streams uploads/downloads, polls operations, refreshes expired download URLs, verifies the archive checksum, and atomically publishes the downloaded file. It never forwards the API bearer token to a different origin, including on storage redirects.

```python
from elicit_study.client import Client

client = Client('http://localhost:3000', token)
study = client.wait(client.import_study('study-format/examples/01-likert.study.json'))
client.wait(client.import_results(study['study_id'], study['revision_id'], 'results.ndjson'))
export = client.wait(client.export_results(
    study['study_id'], study['revision_id'], participants=['participant-1'],
))
client.download(export, 'results.zip')
```

For a command-line example, see [deliver.py](../study-format/examples/deliver.py). Once unpacked, read the tables through PyArrow, pandas, Polars or DuckDB as normal Parquet datasets.

## Verification

The SQLite HTTP integration test uses real compiler subprocesses and real Parquet ZIPs, imports all nine study definitions, checks all/single-participant downloads, verifies checksums, authorization, immutable publication, result references, duplicate identities, stale revisions, retries, recovery and the signed-storage delivery branch. The cloud branch is mocked; live S3 connectivity and the Docker image build require a connected deployment environment.

The separate queue probe exercises committed records through real Solid Queue worker processes, including a definition import, a participant result import and an export:

```bash
RAILS_ENV=test bundle exec rails test test/integration/study_delivery_test.rb
RAILS_ENV=test bundle exec rails runner test/database/study_delivery_probe.rb
python -m unittest discover -s study-format/tests -v
```

Run the queue probe only against a dedicated test database. CI runs it for both database adapters, alongside the existing database compatibility checks.
