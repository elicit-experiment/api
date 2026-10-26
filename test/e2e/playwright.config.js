const { defineConfig, devices } = require('@playwright/test');

if (!process.env.ELICIT_E2E_API_URL || !process.env.ELICIT_E2E_FRONTEND_URL) {
  throw new Error('Run browser tests through bin/test-e2e smoke (owned, isolated services required).');
}

module.exports = defineConfig({
  testDir: './smoke',
  forbidOnly: true,
  workers: 1,
  retries: 0,
  timeout: 30_000,
  globalTimeout: 300_000,
  expect: { timeout: 10_000 },
  outputDir: process.env.ELICIT_E2E_ARTIFACTS + '/test-results',
  reporter: [
    ['list'],
    ['html', { outputFolder: process.env.ELICIT_E2E_ARTIFACTS + '/report', open: 'never' }],
  ],
  use: {
    baseURL: process.env.ELICIT_E2E_API_URL,
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    ...devices['Desktop Chrome'],
  },
  projects: [{ name: 'chromium' }],
});
