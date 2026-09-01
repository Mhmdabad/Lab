const { test, expect } = require('@playwright/test');

test.describe('API Mocking Examples', () => {

  test('mock fruit API with custom JSON response', async ({ page }) => {

    //create fake api,so every time we call this api it will return this result instade of calling the original server
    await page.route('*/**/api/v1/fruits', async (route) => {
      const mockFruits = [
        { name: 'Mocked Dragonfruit', id: 101 },
        { name: 'Mocked Golden Apple', id: 102 },
      ];
      //the result that will be returned
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify(mockFruits),
      });
    });

    await page.goto('https://demo.playwright.dev/api-mocking');

    await expect(page.getByText('Mocked Dragonfruit')).toBeVisible();
    await expect(page.getByText('Mocked Golden Apple')).toBeVisible();
  });

  test('simulate a 500 server error', async ({ page }) => {
    await page.route('*/**/api/v1/fruits', async (route) => {
      await route.fulfill({
        status: 500,
        contentType: 'application/json',
        body: JSON.stringify({ error: 'Internal Server Error' }),
      });
    });

    await page.goto('https://demo.playwright.dev/api-mocking');

    await expect(page.getByText('Mocked Dragonfruit')).not.toBeVisible();
  });

  test('modify real API response (Spy and Modify)', async ({ page }) => {
    await page.route('*/**/api/v1/fruits', async (route) => {
      const response = await route.fetch();
      const json = await response.json();

      json.push({ name: 'Injected Strawberry', id: 999 });

      await route.fulfill({ response, json });
    });

    await page.goto('https://demo.playwright.dev/api-mocking');

    await expect(page.getByText('Injected Strawberry')).toBeVisible();
  });

});