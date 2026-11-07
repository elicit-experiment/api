# Try Elicit with SQLite and Docker

This standalone stack runs the Rails API/admin application, the experiment frontend,
and a Solid Queue worker. It needs Docker with Compose v2 or newer and network access
for the initial image/dependency build. Ruby, Node, Rust, PostgreSQL, Redis, a cloud
storage account, certificates and an `.env` file are not required on your computer.

From the repository root:

```sh
git submodule update --init --recursive
docker compose -f compose.demo.yml up --build -d --wait
docker compose -f compose.demo.yml exec app ruby docker/demo/boot.rb credentials
```

The first build compiles both frontends, including the Rust/WebAssembly module, and
can take several minutes. The last command displays the generated admin password.

1. Open <http://localhost:8080/admin> and sign in as `admin@elicit.com` (or `admin`)
   with that password.
2. Create a study through the admin interface. The repository's `experiment_xmls/`
   directory contains small question examples you can use while exploring.
3. Open a study's preview/participant link to use the experiment frontend at
   <http://localhost:5505>. API documentation is at
   <http://localhost:8080/apidocs/v1/swagger.json>.

Fresh databases are prepared and seeded automatically. The demo starts with users
and OAuth clients; it does not contain participant results or a preloaded study.
Do not run `db:seed` after startup: upstream seeds are not idempotent. The generated
admin password is also used for the seeded `pi` account. Seeded `subject1` through
`subject5` accounts have a separate generated subject password stored in the same
private credentials file. The public browser OAuth client values are deliberately
fixed in this demo image; they do not replace user authentication.

## Everyday commands

```sh
# Show status and logs
docker compose -f compose.demo.yml ps
docker compose -f compose.demo.yml logs -f app jobs experiment

# Stop and remove containers, retaining all local data
docker compose -f compose.demo.yml down

# Start again using the existing images and data
docker compose -f compose.demo.yml up -d --wait

# Build and run HTTP, authentication, upload/download, live worker and restart checks
bin/demo-smoke
```

SQLite primary/queue files, Active Storage uploads, and generated credentials live
in the `elicit-demo_demo-storage` named volume. Legacy CarrierWave uploads live in
`elicit-demo_demo-uploads`. Both are shared by the application and worker and survive
container recreation and image rebuilds. No host source directories are mounted.
The image runs Rails and the worker as an unprivileged user.

To deliberately erase this demo, including accounts, passwords, uploads and results:

```sh
docker compose -f compose.demo.yml down --volumes
```

Starting again after erasure creates fresh passwords and keys. Keep using the same
Compose project name to retain the existing volumes. Do not run two copies of the
web service against these files during initialization.

## Change ports

The default ports avoid the normal development servers. If either is occupied, use
these variables consistently for build and startup; generated participant links and
experiment API configuration must agree with the host ports:

```sh
ELICIT_DEMO_PORT=8081 ELICIT_DEMO_EXPERIMENT_PORT=5506 \
  docker compose -f compose.demo.yml up --build -d --wait
```

The experiment API address is compiled into its image, so changing the API port or
`ELICIT_DEMO_HOST` requires `--build`. Published ports bind to `127.0.0.1` only. For a
remote Docker host, keep `localhost` as the configured browser host and use SSH:

```sh
ssh -L 8080:127.0.0.1:8080 -L 5505:127.0.0.1:5505 your-docker-host
```

## Scope

This is a local evaluation setup. It uses HTTP and local disk, disables outgoing
email (including the contact form), and has no production backup/TLS configuration.
Password-reset emails are not delivered. Some experiment components load external
models or third-party services and may need browser network access. Camera and
microphone components work with browser permissions on localhost.

The existing PostgreSQL deployment is unchanged. SQLite does not convert an existing
PostgreSQL database. For backend details and research deployment considerations, see
[database-backends.md](database-backends.md).

## Validation

`bin/demo-smoke` checks the built containers, compiled assets, generated admin
credentials with both OAuth clients, authenticated API access, local file delivery,
a real queued job in the separate worker, and credential persistence across restart.
It leaves services running and does not delete data. It requires Docker daemon access.

Native validation of this implementation passed 25 focused SQLite tests / 247
assertions, including the new local-file and demo-email checks, plus the separate
worker probe. Both production frontend builds passed, including real WebAssembly
(the bundlers reported asset-size warnings). Fresh production SQLite preparation,
repeat preparation with stable credentials, and asset precompilation passed. The
production integration probe verified both OAuth clients, authenticated API requests,
admin assets, local uploads/downloads, and execution by a separate jobs process. Container build/runtime validation must be run where Docker's
daemon is accessible; the editing sandbox denies its socket. The unrelated baseline
username-sort errors in the full Rails suite are described in database-backends.md.
