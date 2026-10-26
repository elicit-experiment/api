# Experiment frontend testing and project smoke test plan

Date: 2026-10-26
Status: M4 smoke prototype running — bootstrap and S1 pass locally; M1–M3 and M5–M6 remain in progress/planned

Implementation update (2026-10-26): `bin/test-e2e smoke` now owns disposable
PostgreSQL, service startup, private builds of both applications and storage,
logs, revision/worktree metadata, and cleanup. A pinned Chromium Playwright
runner under `test/e2e/` runs a bootstrap/CORS check and S1. A guarded Rails
setup script creates a unique synthetic study and identities per test; an
independent expected-results file checks persisted defaults, edited/restored
text, scale values, trial records/order, and completion through authenticated
researcher endpoints. No fixture HTTP endpoint is exposed. A queued startup
probe verifies the real worker executes jobs. See [harness instructions](../test/e2e/README.md)
for prerequisites, limitations, and remaining work.

Local prototype validation: 2 Chromium tests passed in 7.3 seconds after build
and startup (`tmp/e2e/smoke-8d831edfaa6a/`); owned processes, PostgreSQL and the
temporary build/storage directory were removed. S1 exposed and now covers fixes
for untouched checkbox defaults and participant-scoped answer/event restoration.
The frontend changes are committed as `3a0757c` and pinned by this API change;
merge the companion frontend PR before merging the API integration PR.
S2–S4, measurement bytes/finalization assertions, and CI remain pending. S1 waits
for text/scale acknowledgments and does not establish delayed-save navigation
or failure/recovery contracts.

Fresh fast-test baseline: API `7b4ec9a60f5ce4f235b1373de3713b130e2b39fb`,
frontend `b1de0897beff4e9c798ebc2eaaac70b32f1dae21`; Node 22.23.4,
npm 10.9.9, Ruby 3.4.4, Jest 29.7.0, TypeScript 5.7.3.
`npx jest --runInBand --watch=false` passed 16 tests with 2 skipped
(3 passing suites, accumulator suite skipped), in 0.812 seconds reported by Jest.
After the prototype changes, the same Jest command reports 19 passing tests and
2 existing skips (4 passing suites; accumulator suite still skipped), in 1.481
seconds. The invalid `module` option is removed; Models/KnockoutBindings aliases
and real HTML import support are added. The checkbox regression exercises the
actual question model and component in Node. Focused API validation reports
3 tests, 9 assertions, no failures/errors/skips. Touched frontend source/test
files pass ESLint. These are incremental foundations; M1 is not complete.

Build confidence that participants see the correct study, their answers are preserved, collected measurements reach durable storage, and completion happens only after required work succeeds. Most coverage should come from fast Jest tests that run without servers, cameras, model downloads, or cloud accounts. A small browser smoke suite should verify that the frontend, API, database, worker, and storage connect correctly.

The implementation should improve the existing TypeScript and Knockout frontend incrementally. Neither a framework migration nor a direct-to-Spaces upload migration is a prerequisite. Changes needed to expose testable boundaries should be small and accompanied by behavior tests.

## 1. Starting point

The experiment frontend lives in the separate `elicit-experiment/frontend` repository, checked out here as `docker/experiment-frontend`. Project-level orchestration belongs in `elicit-experiment/api`, which pins the frontend submodule revision and owns the backend and deployment configuration.

The inspected frontend has four Jest test files, concentrated on face-landmark configuration, compression, shared buffers, and accumulation. The accumulator suite is disabled with `xdescribe` and mocks the send method, bypassing important delivery behavior. `jest.config.js` uses the Node environment, includes an invalid top-level `module` option, and maps only some TypeScript aliases. The test command always starts watch mode. TypeScript excludes `*.spec.ts` while the existing tests use `*.test.ts`.

The earlier audit run reported 16 passing tests and two skipped tests; this is a historical baseline, not a fresh result for this plan. Establish a new baseline at implementation start, including the exact revisions and tool versions. No project browser smoke harness was found in the inspected checkout.

Relevant implementation paths, relative to the frontend repository:

- `source/application/Components/Questions/QuestionBase.ts` and individual question components.
- `source/application/Models/Question.ts`.
- `source/application/Managers/Portal/Experiment.ts` and `Cockpit.ts`.
- `source/application/Managers/CallQueue.ts` and `CallRepeater.ts`.
- `source/application/Managers/FaceLandmarkerManager.ts`.
- `source/application/Components/Questions/FaceLandmark/DatapointAccumulator.ts`, `SharedBufferManager.ts`, and `FaceLandmarkWorker.ts`.
- `source/application/Utility/TimeSeries.ts`.

## 2. Test pyramid and boundaries

| Layer | Main responsibility | Real components | Replaced boundaries |
| --- | --- | --- | --- |
| Many Jest unit tests | Algorithms, state transitions, validation, serialization, queues | The function or class under test | Clock, randomness, transport, detector, browser capabilities as needed |
| Focused Jest integration tests | Cooperating modules and rendered question behavior | Knockout observables, question models/view-models, templates, collection and delivery modules | Network, media hardware, worker execution where unavailable |
| Few project browser smoke tests | Correct wiring and persisted research results | Built frontend, real API, PostgreSQL, worker where required, isolated storage | External media/detector input; transport faults only in explicit fault scenarios |
| Optional compatibility checks | Browser media/worker behavior and actual Spaces integration | Selected browser and provider integrations | Only unrelated external dependencies |

There is no target ratio of test counts. Add each assertion at the lowest layer that can prove it. A browser test should cover a meaningful integration boundary rather than repeat a matrix already covered by Jest.

The default Jest suite must have no external network access or service dependencies. Fail unexpected network requests. DOM integration tests can use jsdom; reserve layout, media playback, and actual worker/browser capability assertions for browser checks.

## 3. Phase one — Make the Jest harness dependable

Owner: experiment frontend. This phase can start immediately.

- [ ] Record the current pass/skip/failure baseline and inventory supported question types and experimental features.
- [ ] Keep the existing Jest major initially; select compatible `ts-jest`, TypeScript, and jsdom environment dependencies rather than combining test adoption with a broad dependency upgrade.
- [ ] Separate Node unit tests and jsdom integration tests through named Jest projects or explicit environment selection.
- [ ] Remove invalid Jest configuration and align module aliases with the production TypeScript configuration, including `Models` and `KnockoutBindings`.
- [ ] Give tests their own TypeScript configuration and type-check them. Exclude both test filename patterns from the application build without suppressing diagnostics in the test project.
- [ ] Support HTML imports so component integration tests bind actual templates. Stub images/styles in tests; avoid empty-template mocks for rendering assertions.
- [ ] Provide typed builders for study definitions, questions, prior answers, detector results, and CHAOS responses. Prefer minimal synthetic fixtures over large recordings.
- [ ] Add controlled adapters for PortalClient, fetch, clock, detector, worker creation, and navigation as needed. Do not import the application entry point merely to construct one question.
- [ ] Reset DOM, component registrations where needed, singleton state, mocks, timers, and subscriptions between cases. Tests must pass independently and in a complete run.
- [ ] Add non-mutating lint, non-watch tests, coverage, and test type-check commands. Keep autofix and watch commands separate.

Suggested frontend command contract, to be implemented rather than assumed to exist:

```sh
npm run test:unit
npm run test:integration
npm run test:ci
npm run test:coverage
npm run typecheck:test
npm run lint:check
```

Exit criterion: a fresh frontend checkout can execute all fast checks without Rails, PostgreSQL, a physical camera, or Spaces credentials. Known skips have a named owner and linked issue; new unexplained skips and focused tests fail CI.

## 4. Phase two — Cover research behavior with Jest

Owner: experiment frontend, with API collaboration for delivery contracts. Start with data preservation and question correctness, then broaden to supported components.

### Unit test work packages

| Priority | Area | Required cases and observable outcomes |
| --- | --- | --- |
| P1 | Accumulation and delivery | Empty batch; rate-limit boundaries and jitter; accepted versus intentionally skipped samples; acknowledgment before removal; network failure; retry; ambiguous acknowledgment; overlapping sends; bounded pending data; final partial batch |
| P1 | Completion lifecycle | Pending compression or upload delays completion; last batch drains; repeated completion is safe; terminal failure exposes a recoverable error; no success redirect on failed completion |
| P1 | Question answers | Defaults, preselected checkbox values without user interaction, restored answers, empty answers, required fields, minimum/maximum selection rules, deselection, serialization, and preservation of legitimate zero/false values |
| P1 | Queues and retry policy | Ordering within a stream, independence between streams, fatal versus retryable failure, backoff, cancellation, callback exactly once, and drain behavior |
| P1 | Experiment progression | Trial order, previous/next rules, validation gates, last trial, missing/invalid definitions, load errors, refresh/resume contract, and preview behavior |
| P2 | Compression and buffers | Configuration combinations, precision/tolerance, timestamps, empty/no-face frames, invalid input, full/oversized buffers, buffer ownership and release, worker errors, and non-shared-buffer fallback |
| P2 | Resource lifecycle | Stop/restart and repeated disposal release timers, observable subscriptions, workers, and media tracks; late callbacks cannot mutate disposed state |

For `CallQueue`, explicitly distinguish replaceable answer-state updates from append-only measurement batches. Characterize existing coalescing behavior and agree which operations may be coalesced; do not encode accidental sample loss as the expected contract.

Use fake timers for backoff and rate limiting, deterministic randomness for ordering, deferred promises to control acknowledgment, and small fixtures with independently computed expected results. Advance one event at a time instead of relying on wall-clock sleeps or unbounded timer draining.

Compression tests should assert schema, units, time origin, selected fields, and numerical tolerance against known fixtures. A round trip alone can pass when encoder and decoder share the same error.

### Jest integration work packages

1. **Question model, view-model, and template:** render representative checkbox, radio, text, and scale questions with actual Knockout bindings. Interact with controls and assert the answer model, validation state, and serialized payload. Include untouched preselected values and prior-answer restoration.
2. **Collection to acknowledgment:** run the real accumulator, compression path, and transport adapter together against a scripted fake transport. Verify accepted sample IDs/timestamps and payload contents across delayed and failed responses. Do not mock `sendQueuedDataPoints` or the queue being tested.
3. **Experiment navigation and saving:** connect the real progression and answer modules to a fake PortalClient boundary. Assert that navigation respects the agreed save policy, errors preserve answers, and old requests cannot overwrite a newer trial's state.
4. **Tracker lifecycle:** connect the manager and accumulator to a deterministic detector and media adapter. Assert start/stop, drain, cleanup, permission-denied behavior, and late worker responses.

Delivery semantics must be agreed with the API. A response lost after a successful write is different from a request that never reached the server. Require no loss and no duplication for acknowledged logical batches through a stable batch identity and server deduplication, or document the current limitation and add the regression alongside the implementation. Retrying append requests blindly does not provide exactly-once results.

Exit criterion: these behavior contracts are exercised without services, the accumulator suite runs, and every corrected production defect has a regression at the lowest useful layer. Known broken behavior should be fixed with its test, not preserved to obtain a green suite.

## 5. Phase three — Establish the project smoke harness

Owner: API repository for orchestration; frontend repository for stable UI hooks and deterministic media/detector adapters.

Use Playwright as the proposed browser runner. Keep configuration, project fixtures, and browser specifications under a new `test/e2e/` directory in the API repository, with runner dependencies declared explicitly. Keep the fast Jest suite in the frontend repository. Pin browser tooling and initialize submodules so every run identifies the actual frontend revision under test.

### Environment and fixtures

- Build and serve the experiment frontend and administration assets, start Rails, provision disposable PostgreSQL databases, and run a real worker for finalization scenarios. Use explicit readiness checks, bounded timeouts, and teardown; do not reuse arbitrary developer servers in CI.
- Mirror participant/API origin boundaries so cookies, CORS, routing, and asset URLs are exercised. Avoid a test-only proxy that hides cross-origin failures.
- Use isolated local storage initially, including explicit overrides for in-progress attachments that currently hardcode the `local` service. Keep the actual HTTP ingestion, file writes, compression, job execution, and result retrieval real.
- Seed a versioned synthetic study with known trial order, default selections, text/scale answers, a small mouse trace, and deterministic landmark frames. Create a unique participant and isolated data namespace per test or worker.
- Seed through supported application operations where practical. A small test-environment-only setup helper may create fixtures; normal API/browser flows must perform the behavior being tested. Never enable unrestricted fixture/reset endpoints in a deployed environment.
- Share a versioned fixture contract between fast tests and smoke tests, with independent expected result files. A manifest should state accepted sample count, expected IDs/timestamps, intentional rate-limit omissions, answer values, and numeric tolerances.
- Verify persisted results through an authenticated researcher export/download path after worker completion. Read and decompress the actual saved bytes; a successful browser screen or POST response is insufficient.
- Use web-first assertions and bounded polling for observable conditions instead of fixed sleeps. Capture browser trace, screenshot, console errors, failed requests, Rails/worker logs, and the synthetic-result manifest on failure.

### Initial smoke scenarios

Keep the required suite to the following four scenarios. Use Chromium first; keep fault matrices in Jest.

| Scenario | Browser journey | Result assertion |
| --- | --- | --- |
| S1 — Representative study | Researcher logs in and views the fixture study; participant launches it, leaves a preselected checkbox untouched, answers text/scale questions, navigates back, and completes | Researcher retrieves the participant's results; defaults, edits, order, and completion match the fixture |
| S2 — Measurements and final drain | Feed known synthetic detector frames and mouse data, then finish while the final upload is deliberately delayed | Completion waits for required delivery; after finalization, downloaded data contains every accepted sample once, with correct schema and timestamps |
| S3 — Transient delivery failure | Interrupt one measurement upload before it reaches the API, restore connectivity, and complete through the supported recovery behavior | Saved samples match the manifest; pending data survives the failure and no silent success is shown while delivery remains unresolved |
| S4 — Session and access boundaries | Refresh midway through a study and exercise its agreed resume behavior; attempt researcher result access with an unauthorized identity | Saved answers survive according to the defined contract; unauthorized result retrieval fails without exposing content or signed URLs |

S2 and S3 use the real API and storage; only external detector input and the deliberate network fault are controlled. Keep response-loss-after-write and duplicate-delivery matrices in API contract tests and Jest, with one browser regression added if those boundaries prove fragile.

Start with S1 as a passing baseline. Add S2–S4 with the necessary behavior fixes; each becomes required once supported and stable. Do not disable assertions to accommodate the current accumulator's dropped batches or premature completion. If refresh/resume is unsupported, first specify the intended behavior and track the implementation dependency rather than silently treating a restart as a successful resume.

Exit criterion: the suite starts from a clean checkout, provisions its own data, runs against real services, verifies stored results, and leaves no orphaned processes or test files. It must not require a live researcher account, physical webcam, or production dataset.

## 6. Optional browser and Spaces compatibility checks

These checks supplement the pyramid; they should not make local Jest dependent on hardware or the internet.

### Browser media and worker checks

- Exercise camera acquisition with checked-in synthetic video on a browser that supports the selected fake-camera setup. Use bundled model assets if exercising actual MediaPipe; keep detector-fixture tests separate from actual model-output assertions.
- Verify permission denial, no-device behavior, Web Worker startup, compression support, and shared-buffer/fallback behavior in real browsers. Serve required isolation headers when testing shared buffers.
- Use tolerant assertions for actual detector output; keep exact record-count assertions on deterministic injected detector data.
- Expand representative smoke coverage to supported Firefox/WebKit configurations on a scheduled or release workflow after Chromium is stable. Match the matrix to declared browser support and available media-test capabilities.

### Direct-to-Spaces upload option

The current server shim remains the baseline. If direct uploads are adopted, keep collection/acknowledgment tests independent of the transport and add adapter contract coverage for presigning, part/object numbering, retry, checksum/integrity handling, completion, and abort/recovery.

For S3 multipart upload, test unknown total length, the final short part, renewed expired URLs, ambiguous upload responses, ordered part/ETag completion, and incomplete-upload recovery. For small independent objects, test the manifest and missing/duplicate batches. Test logical sample identity independently of compressed byte boundaries.

Use a local S3-compatible service for routine protocol integration if useful, but do not treat it as proof of Spaces compatibility. Run a separate opt-in/release test against a dedicated private Spaces bucket with scoped credentials and unique prefixes. Verify actual presigned browser PUTs, CORS/ETag exposure, completion, download integrity, and cleanup. The test owns and deletes only its prefix/upload IDs, including failed runs. Live checks require an explicit environment flag and should never execute as part of the default unit suite.

## 7. CI and feedback budgets

The following durations are initial budgets to validate on CI, not measurements of current performance. Report timings before increasing infrastructure or parallelism.

| Check | Trigger | Initial budget | Failure policy |
| --- | --- | --- | --- |
| Jest unit and integration, test type check, non-mutating lint | Every frontend PR; API changes to the pinned frontend also run the relevant checks | Fast suite under 60 seconds after dependencies are installed | Required; no automatic test retries |
| Frontend production build | Every frontend PR and integrated API revision | Under 3 minutes | Required; confirms templates/assets/workers bundle |
| Project smoke S1–S4 as enabled | API integration PRs, frontend candidate revisions, main branch | Under 5 minutes after image/build preparation | Required once stable; preserve first failure evidence |
| Supported-browser/media compatibility | Scheduled and before releases | Separate measured budget | Visible failures triaged before declaring support |
| Live Spaces compatibility, if applicable | Explicit dispatch and release validation | Bounded timeout and cleanup | Required for storage-transport releases |

Frontend PRs need a project integration workflow that checks out the candidate frontend commit into the API harness; testing only the API repository's old submodule pin would miss regressions. API PRs test their pinned frontend and modified backend. Record all revisions in artifacts and define who owns the integration workflow across repositories.

Allow at most one diagnostic browser retry initially, report retry-only passes as flaky, and require an owner and repair issue. Flakiness is not a reason to silently drop a smoke test. Prefer deterministic fixtures and narrower assertions before adding retries.

Collect branch coverage for delivery, completion, progression, and validation modules. Establish a baseline, then require changed branches and listed failure paths to be covered; ratchet module thresholds as suites mature. Avoid an arbitrary repository-wide percentage or tests that merely mirror implementation details.

Suggested project command contract, also to be implemented:

```sh
bin/test-e2e smoke
bin/test-e2e compatibility
bin/test-e2e spaces
```

The wrapper should own environment setup, test selection, logs, and cleanup. Document first-run dependency/browser installation separately from routine execution.

## 8. Delivery order and reviewable milestones

| Milestone | Deliverable | Completion evidence |
| --- | --- | --- |
| M1 | Jest configuration, fixture builders, boundary adapters, command contract | Clean fast checks; no servers or external network; skip inventory |
| M2 | Answer/default regression tests, queue/retry and accumulator tests; associated fixes | Untouched checkbox defaults persist; delayed/failed delivery tests pass; accumulator suite enabled |
| M3 | Completion and resource-lifecycle integration tests; associated fixes | Pending work blocks successful completion; cleanup and late-callback cases pass |
| M4 | Disposable project harness and S1 | Fresh checkout starts services, completes a study, downloads expected answers, and tears down |
| M5 | S2–S4 and delivery/API contract tests | Stored measurement manifest matches after final drain and fault recovery; access/resume behavior verified |
| M6 | CI enforcement and supported-browser/provider checks | Candidate frontend revisions tested with API; failure artifacts and owners established |

M4 can proceed after M1 while data-delivery work continues. M5 depends on explicit API deduplication and completion contracts where required. Add broader question/component matrices to Jest continuously rather than expanding the browser suite for every component.

Keep harness changes, behavioral tests/fixes, project orchestration, and CI wiring in reviewable changes. Each milestone should update developer instructions and link its regression cases to the owning issue.

## 9. Ownership and existing tickets

- Frontend delivery and completion: [frontend#51](https://github.com/elicit-experiment/frontend/issues/51).
- Frontend testing/tooling foundations: [frontend#52](https://github.com/elicit-experiment/frontend/issues/52). Expand into focused implementation tickets for this plan rather than treating lint cleanup as sufficient testing work.
- API concurrency, retries, and finalization: [api#43](https://github.com/elicit-experiment/api/issues/43).
- CI orchestration: [api#46](https://github.com/elicit-experiment/api/issues/46).
- Jobs and recovery: [api#45](https://github.com/elicit-experiment/api/issues/45).
- Access isolation: [api#40](https://github.com/elicit-experiment/api/issues/40) and [api#41](https://github.com/elicit-experiment/api/issues/41).
- Overall audit: [overview#2](https://github.com/elicit-experiment/overview/issues/2).

Assign one frontend maintainer to fast-test infrastructure and one API maintainer to the integrated environment. The feature author owns relevant regression coverage. Before implementation, agree the save-before-navigation policy, resume behavior, retry/deduplication contract, supported browser matrix, and worker/storage test configuration through small documented decisions.

## 10. Plan acceptance checklist

- [ ] Most new behavioral coverage runs in Jest without external dependencies.
- [ ] Actual question models, Knockout bindings, queues, and lifecycle code are exercised rather than mocked away.
- [ ] Every accepted measurement is accounted for by the fixture manifest, including explicit intentional sampling omissions.
- [ ] A few browser smoke tests prove end-to-end wiring and actual stored results.
- [ ] Camera/model and live-provider checks remain separate from the default fast loop.
- [ ] Existing shim and potential direct-upload paths share the same research-data correctness contract.
- [ ] CI tests candidate frontend revisions, exposes failures, and publishes actionable artifacts.
- [ ] Commands, ownership, isolation, cleanup, and skip/flakiness policies are documented.

## References

- [Jest configuration](https://github.com/jestjs/jest/blob/main/docs/Configuration.md): project and test-environment configuration. Consult the installed Jest major's documentation during implementation.
- [Playwright web server orchestration](https://playwright.dev/docs/test-webserver): launching and checking application servers.
- [Playwright test configuration](https://playwright.dev/docs/test-configuration): browser projects, focused-test protection, and tracing.
