# Working on Elicit

## Project map

- `app/`, `config/`, `db/`: Rails API, authentication, persistence, Active Storage and Solid Queue.
- `app/javascript/`: administration/participant portal frontend.
- `docker/experiment-frontend/`: experiment UI Git submodule. Read its own `AGENTS.md` before changing it; make changes in that repository and deliberately update the submodule pointer.
- `study-format/`: shared Python definition compiler, JSON Schema contracts, offline tools and Parquet export. Read [its instructions](study-format/AGENTS.md) for changes there.
- `compose.demo.yml`, `docker/demo/`: standalone SQLite evaluation stack.

Start with [README.md](README.md), [database setup](doc/database-backends.md), [canonical schema](study-format/docs/schema.md), [Python library](study-format/docs/python.md) and [delivery API](doc/canonical-study-delivery.md), as relevant to the task.

## Working tree and compatibility

Check `git status`, the current branch and worktrees before editing. Keep unrelated local work intact. Respect a stacked PR's declared base so parent changes do not enter the child diff. Do not commit credentials, generated databases, uploaded research data, local environments or build output.

PostgreSQL remains the default backend. SQLite is opt-in and uses separate primary and queue files. Add portable migrations and keep both adapter-specific schema snapshots current; do not replace the PostgreSQL snapshot with a SQLite dump. Preserve existing v1/CHAOS behavior unless the task explicitly changes it.

Canonical imports currently report `runtime_status: definition_only`. They do not create runnable v1 graphs or convert historical v1 results. Keep this distinction explicit in APIs, examples and documentation. Do not bypass immutable revisions through v1 mutations.

## Definition and result invariants

Use the same Python compiler for offline authoring and server processing. Do not introduce an independent permissive server validator or infer result columns from observed responses. Preserve stable scoped definition keys, explicit execution occurrence IDs, immutable compiled contracts and the manifest publication boundary.

Process uploads and exports through durable operations. Recheck authorization when publishing and delivering artifacts. Keep queue retries/idempotency, claim fencing, snapshot consistency and participant filtering intact. Generate storage URLs from configured services; never forward API bearer credentials to another origin or place research payloads/credentials in diagnostics.

## Verification

Use the project's configured Ruby version (`Gemfile`) and existing development/test environment. Install the Python package with its Parquet extra before delivery tests:

```sh
python3 -m venv study-format/.venv
study-format/.venv/bin/pip install -e './study-format[parquet]'
export STUDY_FORMAT_PYTHON="$PWD/study-format/.venv/bin/python"
study-format/.venv/bin/python -m unittest discover -s study-format/tests -v
```

With required application environment variables configured, use dedicated test databases:

```sh
export RAILS_ENV=test DATABASE_ADAPTER=sqlite3 SQLITE_DATABASE_DIR=tmp/agent-checks
bundle exec rails db:prepare
bundle exec rails test test/integration/study_delivery_test.rb test/database/demo_storage_test.rb test/database/configuration_test.rb test/database/compatibility_test.rb test/commands/finalize_timeseries_command_test.rb test/controllers/ChaosApi/V6/answer_controller_test.rb
bundle exec rails runner test/database/study_delivery_probe.rb
```

Check for existing `DATABASE_URL`, `PRIMARY_DATABASE_URL` and `QUEUE_DATABASE_URL` overrides before running those commands. Test preparation loads fixtures; never use a real research database. The worker probe uses committed records and separate worker processes and belongs only in a dedicated test environment. For persistence changes, verify PostgreSQL as well or report that coverage is pending; CI runs both adapters.

For Compose changes, run `docker compose -f compose.demo.yml config --quiet`. `bin/demo-smoke` builds and starts containers, leaves them running and requires a working Docker daemon. Do not delete volumes to perform a routine check. For Ruby changes run targeted RuboCop checks using `.rubocop.yml`; finish with `git diff --check`. Scale checks to the change: documentation edits need accurate examples and links, not a full application rebuild.
