# Project browser smoke harness

This is the M4 prototype from [the testing plan](../../doc/experiment-frontend-testing-plan.md).
It runs two Chromium tests against built applications, real PostgreSQL, and Solid Queue:

- **Bootstrap:** load the administration login, launch a real participant session,
  and perform a credentialed browser fetch across the normal CORS boundary.
- **S1:** log in as a synthetic researcher and view the study; launch an anonymous
  participant in a separate browser context; leave the preselected checkbox untouched;
  answer text and scale questions; go back and edit the restored text; complete;
  retrieve persisted answer states, trial records, and completion through the
  authenticated researcher API and compare them with independent expected results.

## First run

Use the repository Ruby version, Node 22, Python 3, Docker Compose v2, Cargo,
wasm-pack, and the wasm32-unknown-unknown Rust target. Install API Ruby and JS
build dependencies using the repository setup instructions, then:

```sh
git submodule update --init --recursive
rustup target add wasm32-unknown-unknown
npm ci --prefix test/e2e
cd test/e2e
npx playwright install chromium
cd ../..
bin/test-e2e smoke
```

Validation used wasm-pack 0.13.1. If needed, install it using
`cargo install wasm-pack --version 0.13.1 --locked`. On Linux, browser system
libraries may also require Playwright's `install --with-deps chromium`.
Browser installation is separate from routine runs. The runner checks installed
API gems and launches Chromium before provisioning services, so missing
prerequisites fail before application builds. If Ruby reports missing gems,
check that `GEM_HOME`/`GEM_PATH` belong to the active repository Ruby installation.

The runner and browser revision are pinned by the dedicated npm lockfile; API
administration dependencies continue to use the repository's existing tooling.
The participant's locked dependencies are installed in its private build directory;
initial runs need registry access and the Rust/WebAssembly build tools.

## Routine use

```sh
bin/test-e2e smoke
bin/test-e2e smoke --grep bootstrap
bin/test-e2e smoke --grep S1
```

The wrapper copies the API source and installed administration dependencies into
an owned temporary directory, then starts a uniquely named PostgreSQL Compose
project with an ephemeral filesystem and random loopback port. Rails provisions
primary and queue databases there. Both administration and participant assets
compile privately, including the real WebAssembly bundle. Rails, Solid Queue,
and a static participant server run on owned processes. HTTP readiness and an
actual queued job must succeed before browser tests start. No running developer
servers are reused and no checkout assets or frontend configuration are rewritten.
Browser assets compile with `NODE_ENV=production`; Rails uses `RAILS_ENV=test`.

API and participant origins use separate random ports and the normal CORS middleware.
No proxy, fixture HTTP endpoints, camera, cloud bucket, or production account is
required. The test-only `ELICIT_E2E` configuration selects real queued jobs and
redirects both normal and explicitly `local` attachments into the temporary root.
Inherited database URL overrides are removed before starting Rails. Local libpq
GSS encryption is disabled: this stack uses password authentication and does not
need Kerberos initialization in forked macOS workers.

The wrapper tears down owned process groups and the Compose project on success,
failure, timeout, SIGINT, or SIGTERM, and removes its private build/storage directory.
SIGKILL or a host crash cannot run cleanup: use the project name recorded in
`tmp/e2e/<run>/revisions.json` with `docker compose -p <run> -f test/e2e/compose.yml down`.

Each run retains `tmp/e2e/<run>/`: setup/build output, Rails/worker/frontend and
PostgreSQL logs, revision/tool metadata and worktree status, HTML report, and
failure traces/screenshots. The fixture's synthetic study manifest, independent
expected answers, retrieved states, browser errors, and failed requests are
attached to the report. Metadata records commit IDs and dirty paths, rather than
an archival snapshot of local source edits. There are no automatic retries;
focused tests always fail discovery.

## Fixtures and behavior regressions

`data/study-v1.json` describes the study; `data/expected-v1.json` independently
specifies expected answer values, order, and numeric tolerance. Change their
versions together when changing the contract. `seed.rb` creates a unique researcher,
participant, study, explicit trial order, and browser OAuth client through Rails
models for each test. It runs through `rails runner`, checks the owned test
environment and output directory, and exposes no fixture/reset HTTP route. Every
browser action and result query uses the normal application endpoints. Tests share
only the synthetic OAuth client and never reset each other's data.

The prototype fixes checkbox defaults and restoration in the frontend submodule
and answer/event restoration on the API. The frontend regression is
`CheckBoxGroup.spec.ts`; the API regression is
`test/controllers/ChaosApi/V6/question_controller_test.rb`. This API change pins
frontend commit `3a0757c`; merge the companion frontend PR before the API PR.
A checkout of the previous frontend pin lacks the checkbox fix.

## Remaining milestones

- S2 measurements, delayed final drain, and assertions on downloaded compressed
  bytes. The startup probe proves a real worker executes jobs; S1 proves saved
  answers and completion, without claiming measurement finalization correctness.
- S3 failure/recovery and S4 access/resume behavior after agreeing delivery,
  deduplication, completion, and resume contracts. S1 waits for text/scale save
  acknowledgments; it does not test navigation while a save is delayed or failing.
- Candidate frontend revision selection, cross-repository CI, and artifact upload.
- `compatibility` and `spaces` intentionally fail with a usage error until their
  explicit opt-in suites exist.

Configuration follows [Playwright's test configuration](https://playwright.dev/docs/test-configuration).
The Python wrapper owns service orchestration so cleanup also covers database and
build setup failures before Playwright starts.
