# New Relic Agent Update Plan

## Branch
`update-newrelic-agents` (branched from `master`)

---

## Current State

### Ruby Agent (`newrelic_rpm`)
- **Current version:** `9.16.1` (Gemfile specifies `~> 9.16`)
- **Latest version:** `10.5.0` (released May 14, 2026)
- **Gap:** ~6 months old; major version behind (9.x → 10.x)

### Node.js Agent (`newrelic`)
- **Current version:** **NOT installed** in `docker/experiment-frontend/package.json`
- **Config remnants present:**
  - `docker/experiment-frontend/newrelic.js` (configuration file)
  - `docker/experiment-frontend/README.md` references `"newrelic": "^5.6.3"`
  - Root `.eslintrc.js` declares `newrelic` as a global
- **Latest version:** `14.0.0` (released May 18, 2026)
- **Gap:** The package appears to have been removed from dependencies at some point but leftover files remain.

---

## Investigation Summary

### Ruby Agent (Primary)

**Compatibility check:** ✅ Compatible
- Ruby version: Project uses `3.4.4`, agent 10.x requires `>= 2.6.0` ✅
- Puma version: Project uses `~> 6.4`, agent 10.x requires `>= 3.9.0` ✅
- Rails version: Project uses `~> 7`, fully supported ✅

**Custom API usage check:** ✅ None found
- No `NewRelic::Agent` API calls found in the Ruby codebase
- No deprecated `cross_application_tracer.enabled` config in `newrelic.yml`
- No `SqlSampler#notice_sql` or `Datastores` custom instrumentation found

**Config compatibility:** ✅ Compatible
- `newrelic.yml` uses standard options only
- Distributed Tracing is already enabled (required since CAT was removed)
- No removed configuration options detected

**Breaking changes that may affect us:**
1. **ActiveJob metrics renamed** — Custom dashboards or alerts using ActiveJob metrics may need updating:
   - Old: `Ruby/ActiveJob/<QueueName>/<Method>`
   - New: `Ruby/ActiveJob/<QueueName>/<ClassName>/<Method>`
2. **`bin/newrelic` renamed to `bin/newrelic_rpm`** — Any deployment scripts or CI using the old CLI name will break.
3. **`newrelic deployments` CLI removed** — Any deployment recording via the agent CLI will no longer work. Use New Relic's Change Tracking instead.

### Node.js Agent (Frontend)

**Status:** The `newrelic` npm package is **not currently a dependency** in `docker/experiment-frontend/package.json`, despite a config file existing.

**Decision needed:** Either:
- **Option A:** Re-install the Node.js agent (if monitoring is desired)
- **Option B:** Clean up leftover config files (`newrelic.js`, README reference, `.eslintrc.js` global)

If re-installing, note that v14.0.0 drops support for Node.js 20. Our current Node.js version is `v22.13.1`, so that is compatible. However, a jump from v5 → v14 is extremely large and would require significant migration effort. It may be safer to install the latest v13 (e.g., `13.20.0`) first, or just skip the Node.js agent unless it's actively needed.

---

## Recommended Plan

### Phase 1: Ruby Agent Update (Primary Goal)

1. **Update Gemfile**
   - Change `gem 'newrelic_rpm', '~> 9.16'` to `gem 'newrelic_rpm', '~> 10.5'`

2. **Update bundle**
   - Run `bundle update newrelic_rpm` to update `Gemfile.lock`

3. **Verify no API regressions**
   - Search again for any `NewRelic::Agent` API usage that might have been missed
   - Confirm no custom scripts reference `bin/newrelic`

4. **Check deployment scripts**
   - Search for any references to `newrelic deployments` or `bin/newrelic` in CI/CD or deployment scripts
   - Update to `bin/newrelic_rpm` if found

5. **Test locally**
   - Boot the Rails application in production mode (or with `NEWRELIC_LICENSE_KEY` set)
   - Verify agent starts without errors in `log/newrelic_agent.log`
   - Confirm Distributed Tracing still works

6. **Update dashboards (if applicable)**
   - If any New Relic dashboards or alerts reference ActiveJob metrics, update them to the new format

### Phase 2: Node.js Agent Cleanup (Secondary)

**Recommended:** Clean up remnants since the package is not installed.

1. **Remove `docker/experiment-frontend/newrelic.js`**
2. **Update `docker/experiment-frontend/README.md`** to remove the New Relic section
3. **Remove `newrelic` from `.eslintrc.js` globals** (line 13)

*Alternative:* If the Node.js agent is actually needed, install `newrelic@latest` and update `newrelic.js` config to match v14 format. This would be a separate, larger task.

### Phase 3: Validation & Rollout

1. **Run test suite**
   - Ensure all tests pass with the updated agent present
   - Note: Agent only loads in `:production` group, so most tests won't exercise it directly

2. **Staging deployment**
   - Deploy the branch to staging first
   - Monitor `log/newrelic_agent.log` for any warnings or errors
   - Verify APM data continues to flow in New Relic dashboard

3. **Production rollout**
   - Merge the branch after staging validation
   - Monitor New Relic dashboard for any anomalies post-deployment

---

## Risk Assessment

| Risk | Level | Mitigation |
|------|-------|------------|
| ActiveJob metric dashboards break | Low | We don't appear to have custom dashboards in repo; verify in NR UI before/after |
| Deployment scripts use `bin/newrelic` | Low | Search codebase for references; update to `bin/newrelic_rpm` |
| Agent fails to start in production | Low | Test in staging first; config is already compatible |
| Node.js cleanup removes needed config | Low | Confirm `newrelic` is not in `package.json` or `package-lock.json` first |

---

## Quick Commands (for implementation)

```bash
# Ruby agent update
bundle update newrelic_rpm

# Verify agent loads
RAILS_ENV=production NEWRELIC_LICENSE_KEY=<key> bundle exec rails runner "puts NewRelic::Agent::VERSION"

# Search for legacy CLI references
grep -r "bin/newrelic" --include="*.sh" --include="*.yml" --include="*.yaml" .
grep -r "newrelic deployments" --include="*.sh" --include="*.rb" .
```
