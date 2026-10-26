// Run with Playwright available on NODE_PATH; Java and Flutter stay in Docker.
const { chromium } = require('playwright');
const { expect } = require('playwright/test');
const fs = require('node:fs');
const base = process.env.BROWSER_URL || 'http://localhost:18080';
const artifacts = process.env.BROWSER_ARTIFACTS || '/tmp/wordwolf-browser-artifacts';
fs.mkdirSync(artifacts, { recursive: true });
let page, browser;

(async () => {
  browser = await chromium.launch({
    executablePath: process.env.CHROMIUM_PATH || '/usr/lib/ungoogled-chromium/chromium',
    headless: true,
    args: ['--no-sandbox'],
  });
  const context = await browser.newContext({ viewport: { width: 1440, height: 1000 } });
  page = await context.newPage();
  const errors = [], flags = new Set();
  page.on('pageerror', error => errors.push(error.message));
  page.on('console', message => { if (message.type() === 'error') errors.push(message.text()); });
  let lesson, suggestion;
  page.on('response', async response => {
    if (response.url().endsWith('/api/suggest_meaning')) suggestion = await response.json();
    if (response.url().endsWith('/api/new_lesson')) lesson = await response.json();
    if (response.url().includes('flag_of_') && response.status() === 200) flags.add(response.url());
  });

  // All mutations use a new account owned by this test. Never read browser tokens.
  const username = 'Learner_' + Date.now().toString().slice(-8);
  const password = 'Local-test-' + Date.now();
  const response = await context.request.post(base + '/api/sign_up', {
    data: { username, password, email: username + '@example.test' },
  });
  const account = await response.json();
  expect(account.message).toBe('ok');
  const snapshot = () => page.locator('body').ariaSnapshot();
  const type = async (name, value) => {
    const input = page.getByRole('textbox', { name, exact: true });
    await input.click();
    // Flutter attaches its native editable on the frame after semantics focus.
    await page.waitForTimeout(250);
    await page.keyboard.press('Control+A');
    await page.keyboard.type(value, { delay: 25 });
    expect(await input.inputValue() === value).toBe(true);
  };
  const button = name => page.getByRole('button', { name, exact: true });

  const firstIcon = page.waitForResponse(response => response.url().endsWith('/icon1.jpg') && response.ok());
  const secondIcon = page.waitForResponse(response => response.url().endsWith('/icon2.jpg') && response.ok());
  await page.goto(base, { waitUntil: 'domcontentloaded' });
  await firstIcon;
  await page.waitForTimeout(100);
  const firstFrame = await page.screenshot({ path: `${artifacts}/splash-first.png` });
  await secondIcon;
  await page.waitForTimeout(550);
  const secondFrame = await page.screenshot({ path: `${artifacts}/splash-second.png` });
  expect(firstFrame.equals(secondFrame)).toBe(false);
  console.log('PASS: splash loads both icons and visibly changes before login');
  await page.locator('flt-semantics-placeholder').evaluate(element => element.click());
  await button('Sign in').waitFor();
  await page.screenshot({ path: `${artifacts}/login-1440.png`, fullPage: true });
  await button('New here? Create an account').click();
  await button('Create account').waitFor();
  await page.screenshot({ path: `${artifacts}/sign-up-1440.png`, fullPage: true });
  await button('Back').click();
  await type('Username', username);
  await type('Password', password);
  await button('Sign in').click();
  await button('OK').click();
  await button('Start a lesson').waitFor();
  for (const width of [320, 768, 1024, 1440]) {
    await page.setViewportSize({ width, height: 1000 });
    await page.waitForTimeout(200);
    await page.screenshot({ path: `${artifacts}/dashboard-${width}.png`, fullPage: true });
  }
  console.log('PASS: login and dashboard at 320, 768, 1024, 1440px');

  await button('Add word').click();
  await page.setViewportSize({ width: 1440, height: 1000 });
  await page.screenshot({ path: `${artifacts}/add-word-1440.png`, fullPage: true });
  await button('Meaning language English').click();
  await page.getByRole('menuitem', { name: 'Persian', exact: true }).click();
  await type('Word or phrase', 'book');
  await button('Suggest a meaning').click();
  await button('Use this meaning').waitFor({ timeout: 90000 });
  expect(suggestion.review.status).toBe('scored');
  expect(suggestion.review.correctnessProbability).toBeGreaterThanOrEqual(0);
  expect(suggestion.review.correctnessProbability).toBeLessThanOrEqual(1);
  await expect.poll(snapshot).toContain(`Estimated correctness: ${(suggestion.review.correctnessProbability * 100).toFixed(1)}%`);
  await page.screenshot({ path: `${artifacts}/suggestion-1440.png`, fullPage: true });
  await button('Use this meaning').click();
  const meaning = page.getByRole('textbox', { name: 'Meaning', exact: true });
  await meaning.click();
  await expect(meaning).toHaveValue('کتاب');
  expect([...flags].some(url => url.includes('flag_of_Persian.png'))).toBe(true);
  await page.setViewportSize({ width: 320, height: 1000 });
  await page.screenshot({ path: `${artifacts}/word-form-320.png`, fullPage: true });
  await button('Save word').click();
  await button('Save word').last().click();
  await expect.poll(snapshot).toContain('Word saved.');
  await button('Back').click();
  console.log('PASS: flags, Persian selection, real local suggestion, review and mobile save');

  for (const [word, meaning] of [['water', 'آب'], ['sun', 'خورشید'], ['hello', 'سلام']]) {
    const response = await context.request.post(base + '/api/add_word', {
      headers: { Authorization: account.token },
      data: { word, wordMeaning: meaning, wordLang: 'English', meaningLang: 'Persian' },
    });
    expect((await response.json()).message).toBe('ok');
  }
  await page.setViewportSize({ width: 1024, height: 1000 });
  await button('Start a lesson').click();
  await button('Reveal meaning').waitFor();
  await page.screenshot({ path: `${artifacts}/lesson-review-1024.png`, fullPage: true });
  for (let i = 0; i < lesson.words.length; i++) {
    await button('Reveal meaning').click();
    await button(i === lesson.words.length - 1 ? 'Start questions' : 'Next word').click();
    await page.waitForTimeout(100);
  }
  for (let i = 0; i < lesson.questions.length; i++) {
    const question = lesson.questions[i];
    await button(question.answers[question.correct]).click();
    await button('Check answer').click();
    await expect.poll(snapshot).toContain('That’s right.');
    if (i === 0) await page.screenshot({ path: `${artifacts}/lesson-1024.png`, fullPage: true });
    await button(i === lesson.questions.length - 1 ? 'Finish lesson' : 'Next question').click();
  }
  await expect.poll(snapshot).toContain('Practice complete');
  await page.screenshot({ path: `${artifacts}/lesson-complete-1024.png`, fullPage: true });
  await button('Done').click();
  await expect.poll(snapshot).toContain('14 XP');
  console.log('PASS: flashcards, questions, lesson completion and refreshed XP');

  await page.setViewportSize({ width: 1440, height: 1000 });
  await page.getByRole('button', { name: /Find a word Search/ }).click();
  await type('Word', 'water');
  await button('Search words').click();
  await expect.poll(snapshot).toContain('water');
  await page.getByRole('button', { name: 'Save word', exact: true }).first().waitFor();
  await page.screenshot({ path: `${artifacts}/search-1440.png`, fullPage: true });
  await button('Back').click();
  await page.getByRole('button', { name: /Popular words Discover/ }).click();
  await button('Save word').first().waitFor();
  await page.screenshot({ path: `${artifacts}/popular-words-1440.png`, fullPage: true });
  await button('Back').click();
  await page.getByRole('button', { name: /My words Revisit/ }).click();
  await button('Remove word').first().waitFor();
  await page.screenshot({ path: `${artifacts}/my-words-1440.png`, fullPage: true });
  await button('Remove word').first().click();
  await button('Remove').click();
  await expect(button('Remove word')).toHaveCount(3);
  await button('Back').click();
  await button('Explore streak levels').click();
  await expect.poll(snapshot).toContain('Your streak journey');
  await page.screenshot({ path: `${artifacts}/streak-levels-1440.png`, fullPage: true });
  await page.keyboard.press('Escape');
  await button('Account settings').click();
  await button('Save changes').waitFor();
  await page.screenshot({ path: `${artifacts}/settings-1440.png`, fullPage: true });
  await page.setViewportSize({ width: 320, height: 1000 });
  await page.screenshot({ path: `${artifacts}/settings-320.png`, fullPage: true });
  await button('Sign out').click();
  await button('Sign in').waitFor();
  console.log('PASS: search, popular words, deletion, streaks, settings and logout');
  expect(errors).toEqual([]);
  console.log('PASS: no browser console or page errors');
  await browser.close();
})().catch(async error => {
  if (page) await page.screenshot({ path: `${artifacts}/failure.png`, fullPage: true }).catch(() => {});
  console.error(error);
  if (browser) await browser.close();
  process.exit(1);
});
