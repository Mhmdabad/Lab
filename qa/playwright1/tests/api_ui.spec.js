import { test, expect } from '@playwright/test';

test('create user with API, verify in UI', async ({ request, page }) => {

  // 1. Create user through API
  const response = await request.post('/api/users', {
    data: {
      name: 'Mohammed',
      email: 'test@example.com'
    }
  });

  expect(response.status()).toBe(201);

  const user = await response.json();

  // 2. Open UI
  await page.goto(`/users/${user.id}`);

  // 3. Verify UI shows the same data
  await expect(
    page.getByText('Mohammed')
  ).toBeVisible();

  await expect(
    page.getByText('test@example.com')
  ).toBeVisible();
});