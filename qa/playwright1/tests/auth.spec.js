import { test, expect } from '@playwright/test';

test.describe('Authentication example', () => {

  // We need serial mode because test 2 depends on auth.json
  // being created by test 1.
  test.describe.configure({ mode: 'serial' });


  test('1 - login and save storage', async ({ page }) => {
    await page.goto('/login');

    await page.getByLabel('Email').fill('test@example.com');
    await page.getByLabel('Password').fill('123456');

    await page
      .getByRole('button', { name: 'Login' })
      .click();

    await expect(page).toHaveURL(/dashboard/);

    // Save this context's cookies + localStorage
    await page.context().storageState({
      path: 'auth.json'
    });
  });


  test.describe('Tests using saved login', () => {

    // Every test inside THIS describe
    // starts with auth.json loaded
    test.use({
      storageState: 'auth.json'
    });


    test('2 - open profile already logged in', async ({ page }) => {

      // No login needed
      await page.goto('/profile');

      await expect(
        page.getByText('My Profile')
      ).toBeVisible();
    });

  });

});