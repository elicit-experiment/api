# PostgreSQL and SQLite

PostgreSQL remains the default. Existing deployments keep their database names,
credentials, schema, JSONB columns, and primary keys. Setting `DATABASE_ADAPTER=sqlite3`
selects SQLite for both the application and Solid Queue. This is an opt-in path
for local use and new single-host production installations; it does not convert
or move an existing database. The smoke-harness PR is independent of this change.

## Select a backend

Keep the existing PostgreSQL environment and commands unchanged, or explicitly set:

```sh
DATABASE_ADAPTER=postgresql bin/rails db:prepare
```

For SQLite, retain the non-database application environment from the normal setup,
then run:

```sh
export DATABASE_ADAPTER=sqlite3
# Optional; defaults to storage/ relative to the application root.
export SQLITE_DATABASE_DIR=/absolute/path/to/persistent/data
bin/rails db:prepare
bin/rails server
# In another process, with the same environment and shared directory:
bin/jobs
```

SQLite does not require `POSTGRES_USER`, `POSTGRES_PASSWORD`, or `POSTGRES_DB`.
`DATABASE_URL`/`PRIMARY_DATABASE_URL` and `QUEUE_DATABASE_URL` retain Rails' normal
connection override behavior; their adapter must agree with `DATABASE_ADAPTER`.
If no explicit adapter is set, a SQLite URL also selects the SQLite schema files.
Do not leave a PostgreSQL URL in the environment when switching to SQLite.

The default files are `storage/development.sqlite3` and
`storage/development_queue.sqlite3`, with separate `test` and `production` pairs.
The same directory must be visible to the web process and jobs process. Do not
use in-memory databases for this multiprocess setup. Use the locked sqlite3 gem
and SQLite 3.35 or newer: the answer endpoint needs `INSERT ... RETURNING` to
return every inserted event ID. Rails 7.2 configures WAL and foreign keys; the
connection timeout is explicitly 5000 ms. The compatibility tests verify these
SQLite settings on real file databases.

## Production

For a new SQLite installation, set `RAILS_ENV=production`, `DATABASE_ADAPTER=sqlite3`,
and an absolute `SQLITE_DATABASE_DIR` on persistent local disk. Set
`ENABLE_SOLID_QUEUE=true` to use the existing production queue integration and run
`bin/jobs` alongside the web process with the same configuration. Normal production
secrets, authentication, frontend origins, and attachment storage still need their
existing configuration. Database selection does not change those services.

Run one active database host, with the application and worker sharing its local
volume. Multiple processes are supported, but writes to each SQLite database are
serialized. Keep transactions short and measure ingestion/finalization contention.
Mount the volume persistently across deployments; the existing PostgreSQL Compose
stack remains unchanged and is not a SQLite deployment template.

Litestream setup, restore automation, and PostgreSQL-to-SQLite data migration are
separate follow-ups. Before using SQLite for real research, define the acceptable
backup lag, monitor replication, test restoration, and protect attachment files
as well as database files. An S3 copy of the database does not protect the current
local in-progress measurement files. The existing `docker:db:backup` and
`docker:db:restore` tasks are PostgreSQL-only and reject SQLite explicitly.

## Schemas and migrations

The repository predates a complete creation-migration history. Bootstrap a new
database through `db:prepare`/`db:schema:load`, rather than replaying the incomplete
historical migrations against an empty database.

Rails uses native per-database `schema_dump` settings:

| Backend | Application schema | Queue schema |
| --- | --- | --- |
| PostgreSQL | `db/schema.rb` | `db/queue_schema.rb` |
| SQLite | `db/sqlite_schema.rb` | `db/sqlite_queue_schema.rb` |

The PostgreSQL snapshots are unchanged. SQLite's snapshots use generated integer
primary keys and JSON columns. There is no runtime rewrite of PostgreSQL SQL or
schema definitions. The former custom dump task that always rewrote `db/schema.rb`
is removed so normal Rails dumping respects the configured filenames.

For a schema change, write the migration to support both adapters. Prefer ordinary
Rails column types and Arel queries. If JSONB is specifically needed, select JSONB
on PostgreSQL and JSON on SQLite in that migration, without changing existing
PostgreSQL columns. Migrate and dump **both** backends, and commit both affected
snapshots:

```sh
DATABASE_ADAPTER=postgresql bin/rails db:migrate db:schema:dump
DATABASE_ADAPTER=sqlite3 bin/rails db:migrate db:schema:dump
```

Use separate database instances/files and remove conflicting database URL overrides
when switching. CI compares the loaded logical schemas (column names, normalized
types, nullability, defaults, primary keys, indexes, and foreign keys). PostgreSQL
JSONB and SQLite JSON normalize to the same logical type; storage-specific integer
widths and extensions are intentionally excluded. CI will detect a missing column
or index in either committed snapshot. It does not prove migration behavior on an
existing production dataset; test each nontrivial migration separately.

## Application behavior and verification

Search uses adapter-aware Arel predicates with explicit wildcard escaping:
PostgreSQL retains `ILIKE`; SQLite uses its native `LIKE`. ASCII case-insensitive
search and literal percent, underscore, and backslash matching are covered on both.
Unicode case folding depends on the database/collation: SQLite's ordinary `LIKE`
does not provide PostgreSQL's locale-aware non-ASCII behavior. Full Unicode search
parity would require a separate normalization/collation design.

The finalization-age predicate uses a qualified timestamp bound instead of
PostgreSQL interval SQL. Answer-event insertion uses Rails' native bulk insert with
returned IDs, preserving the response contract on SQLite as well as PostgreSQL.
No model validation/callback layer is added to this previously unvalidated bulk path.

Run the same checks against each configured backend:

```sh
RAILS_ENV=test bin/rails db:prepare
RAILS_ENV=test bin/rails test test/database/configuration_test.rb test/database/compatibility_test.rb test/commands/finalize_timeseries_command_test.rb test/controllers/ChaosApi/V6/answer_controller_test.rb
RAILS_ENV=test bin/rails test test/controllers/api/v1/users_controller_test.rb -n /search/
RAILS_ENV=test bin/rails runner test/database/worker_probe.rb
RAILS_ENV=test bin/rails runner test/database/schema_signature.rb tmp/schema.json
```

`.github/workflows/database-compatibility.yml` runs this focused matrix and compares
schema signatures. It does not claim the unrelated full Rails suite is green.
Local validation found the same existing full-suite issues on both backends: two
username-sort tests assume fixture usernames are never nil, and the HTML client
controller test needs built frontend assets. The focused data, search, finalization,
queue and configuration checks pass independently of those prerequisites.
