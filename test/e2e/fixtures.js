const { test: base, expect } = require('@playwright/test');
const { execFile } = require('node:child_process');
const { promisify } = require('node:util');
const { readFile } = require('node:fs/promises');
const path = require('node:path');
const { randomUUID } = require('node:crypto');

const test = base.extend({
  study: async ({}, use, testInfo) => {
    const file = path.join(process.env.ELICIT_E2E_ROOT, `fixture-${randomUUID()}.json`);
    try {
      await promisify(execFile)('bundle', ['exec', 'rails', 'runner', 'test/e2e/seed.rb'], {
        cwd: process.env.ELICIT_E2E_API_ROOT,
        env: { ...process.env, ELICIT_E2E_FIXTURE_FILE: file },
        timeout: 60_000,
      });
    } catch (error) {
      await testInfo.attach('fixture-setup', {
        body: `${error.stdout || ''}\n${error.stderr || ''}`, contentType: 'text/plain',
      });
      throw error;
    }
    const study = JSON.parse(await readFile(file, 'utf8'));
    const { researcher, ...manifest } = study;
    await testInfo.attach('synthetic-study-manifest', {
      body: JSON.stringify(manifest, null, 2), contentType: 'application/json',
    });
    await use(study);
    // The wrapper owns this run's whole database; individual tests never reset it.
  },
  page: async ({ page }, use, testInfo) => {
    const events = [];
    page.on('console', message => {
      if (message.type() === 'error') events.push({ type: 'console', text: message.text() });
    });
    page.on('pageerror', error => events.push({ type: 'pageerror', text: error.message }));
    page.on('requestfailed', request => events.push({
      type: 'requestfailed', url: request.url(), failure: request.failure(),
    }));
    await use(page);
    await testInfo.attach('browser-errors', {
      body: JSON.stringify(events, null, 2), contentType: 'application/json',
    });
    expect(events.filter(event => event.type === 'pageerror'), 'uncaught browser exceptions').toEqual([]);
  },
});

module.exports = { test, expect };
