const { test, expect } = require('../fixtures');
const expected = require('../data/expected-v1.json');

async function json(response) {
  expect(response.ok(), `${response.url()}: ${response.status()} ${await response.text()}`).toBeTruthy();
  return response.json();
}

function waitForAnswer(page, questionId, expected) {
  return page.waitForResponse(async response => {
    if (new URL(response.url()).pathname !== '/v6/Answer/Set') return false;
    const request = response.request();
    if (request.method() !== 'POST') return false;
    // PortalClient sends multipart FormData, just as the deployed participant app does.
    const data = await new Response(request.postDataBuffer(), {
      headers: { 'Content-Type': request.headers()['content-type'] },
    }).formData();
    if (data.get('questionId') !== questionId) return false;
    const output = JSON.parse(data.get('output'));
    return Object.entries(expected).every(([key, value]) => String(output[key]) === String(value));
  });
}

test('S1: default answers, edits, trial order and completion persist', async ({ page, browser, study }, testInfo) => {
  expect(study.version).toBe(expected.version);
  await testInfo.attach('expected-results', {
    body: JSON.stringify(expected, null, 2), contentType: 'application/json',
  });

  await page.goto('/login');
  await page.getByPlaceholder('Enter email', { exact: true }).fill(study.researcher.email);
  await page.getByPlaceholder('Enter password', { exact: true }).fill(study.researcher.password);
  const [login] = await Promise.all([
    page.waitForResponse(response => response.url().endsWith('/api/v1/oauth/token') &&
      response.request().method() === 'POST'),
    page.getByRole('button', { name: /Login$/ }).click(),
  ]);
  const token = await json(login);
  expect(token.access_token).toBeTruthy();
  const headers = { Authorization: `Bearer ${token.access_token}` };
  await page.goto('/admin/studies');
  await expect(page.getByText(study.title, { exact: true })).toBeVisible();

  // A fresh context keeps researcher identity out of the anonymous participant journey.
  const participant = await browser.newContext();
  const participantPage = await participant.newPage();
  const errors = [];
  const networkErrors = [];
  participantPage.on('pageerror', error => errors.push(error.message));
  participantPage.on('console', message => {
    if (message.type() === 'error') networkErrors.push({ type: 'console', text: message.text() });
  });
  participantPage.on('requestfailed', request => networkErrors.push({
    type: 'requestfailed', url: request.url(), failure: request.failure(),
  }));
  const visited = [];
  participantPage.on('request', request => {
    const url = new URL(request.url());
    if (url.pathname === '/v6/Question/Get') visited.push(Number(url.searchParams.get('index')));
  });
  try {
    const session = await json(await participant.request.get(
      `${process.env.ELICIT_E2E_API_URL}/api/v1/study_definitions/${study.study_id}` +
      `/protocol_definitions/${study.protocol_id}/take`, { headers: { Accept: 'application/json' } },
    ));
    expect(session.url).toBeTruthy();
    await participantPage.goto(session.url);
    await expect(participantPage.getByRole('checkbox', { name: 'Default choice', exact: true })).toBeChecked();
    // Deliberately leave the default untouched.
    await participantPage.getByRole('button', { name: 'Next', exact: true }).click();
    const text = participantPage.getByRole('textbox');
    await expect(text).toBeVisible();
    const textQuestionId = `${study.study_id}:${study.trials.text.component_id}`;
    const [firstSave] = await Promise.all([
      waitForAnswer(participantPage, textQuestionId, { Text: expected.initialText }),
      text.fill(expected.initialText),
    ]);
    await json(firstSave);
    await participantPage.getByRole('button', { name: 'Next', exact: true }).click();
    await expect(participantPage.getByRole('slider')).toBeVisible();
    await participantPage.getByRole('button', { name: 'Previous', exact: true }).click();
    await expect(text).toHaveValue(expected.initialText);
    const [editSave] = await Promise.all([
      waitForAnswer(participantPage, textQuestionId, expected.answers.text),
      text.fill(expected.answers.text.Text),
    ]);
    await json(editSave);
    await participantPage.getByRole('button', { name: 'Next', exact: true }).click();
    const slider = participantPage.getByRole('slider');
    const [scaleSave] = await Promise.all([
      waitForAnswer(participantPage, `${study.study_id}:${study.trials.scale.component_id}`, expected.answers.scale),
      (async () => {
        await slider.fill(String(expected.answers.scale.Position));
        // Knockout's range binding commits on change, as a real slider interaction does.
        await slider.dispatchEvent('change');
      })(),
    ]);
    await json(scaleSave);
    await participantPage.getByRole('button', { name: 'Next', exact: true }).click();
    await expect(participantPage.getByRole('button', { name: 'Close', exact: true })).toBeVisible();
    await participantPage.getByRole('button', { name: 'Close', exact: true }).click();
    await expect(participantPage).toHaveURL(`${process.env.ELICIT_E2E_API_URL}/participant`);

    const result = (await json(await page.request.get(
      `/api/v1/study_results?study_definition_id=${study.study_id}`, { headers },
    ))).find(result => result.user_id === study.participant_id);
    expect(result).toBeTruthy();
    const base = `/api/v1/study_results/${result.id}`;
    await expect.poll(async () => {
      const experiments = await json(await page.request.get(`${base}/experiments`, { headers }));
      return experiments.find(experiment => experiment.protocol_user_id === study.protocol_user_id)?.completed_at;
    }).toBeTruthy();
    const points = await json(await page.request.get(
      `${base}/data_points?protocol_user_id=${study.protocol_user_id}&page_size=100`, { headers },
    ));
    const states = points.filter(point => point.point_type === 'State');
    await testInfo.attach('saved-states', { body: JSON.stringify(states, null, 2), contentType: 'application/json' });
    for (const [key, answer] of Object.entries(expected.answers)) {
      const matches = states.filter(point => point.component_id === study.trials[key].component_id);
      expect(matches, `one durable state for ${key}`).toHaveLength(1);
      const saved = JSON.parse(matches[0].value);
      if (key === 'scale') {
        expect(Math.abs(Number(saved.Position) - Number(answer.Position))).toBeLessThan(expected.numericTolerance);
      } else {
        expect(saved).toEqual(answer);
      }
    }
    expect(visited).toEqual([0, 1, 2, 1, 2, 3]);
    const experiments = await json(await page.request.get(`${base}/experiments`, { headers }));
    const trialResults = await json(await page.request.get(
      `${base}/trial_results?experiment_id=${experiments[0].id}`, { headers },
    ));
    expect(trialResults.map(result => result.trial_definition_id).sort((a, b) => a - b)).toEqual(
      expected.trialOrder.map(key => study.trials[key].trial_id).sort((a, b) => a - b),
    );
    for (const result of trialResults) expect(result.completed_at).toBeTruthy();
    expect(errors).toEqual([]);
  } catch (error) {
    if (!participantPage.isClosed()) {
      const screenshot = await participantPage.screenshot().catch(() => null);
      if (screenshot) {
        await testInfo.attach('participant-screenshot', { body: screenshot, contentType: 'image/png' });
      }
    }
    throw error;
  } finally {
    await testInfo.attach('participant-errors', { body: JSON.stringify(errors), contentType: 'application/json' });
    await testInfo.attach('participant-network-errors', {
      body: JSON.stringify(networkErrors, null, 2), contentType: 'application/json',
    });
    await participant.close().catch(() => {}); // Browser teardown may already have closed it after a timeout.
  }
});
