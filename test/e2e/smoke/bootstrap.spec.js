const { test, expect } = require('../fixtures');

// Infrastructure check only. S1 must additionally verify a completed study's saved answers.
test('built applications and cross-origin API are reachable', async ({ page, study }) => {
  await page.goto('/login');
  await expect(page.locator('input[type="password"]')).toBeVisible();

  // The frontend redirects an empty launch to the participant portal by design.
  const take = await page.request.get(
    `/api/v1/study_definitions/${study.study_id}/protocol_definitions/${study.protocol_id}/take`,
    { headers: { Accept: 'application/json' } },
  );
  expect(take.ok()).toBeTruthy();
  await page.goto((await take.json()).url);
  await expect(page.locator('.shell')).toBeVisible();
  // Browser fetch exercises the real CORS boundary; Node request clients bypass it.
  const result = await page.evaluate(async api => {
    const response = await fetch(`${api}/api/v1/participant/anonymous_protocols?public=true`, {
      credentials: 'include',
    });
    return { status: response.status, body: await response.json() };
  }, process.env.ELICIT_E2E_API_URL);
  expect(result.status).toBe(200);
  expect(result.body).toEqual([]);
});
