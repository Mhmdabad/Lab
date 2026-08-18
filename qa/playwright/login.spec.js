const { test, expect } = require('@playwright/test');

test.describe('homepage', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto('https://www.saucedemo.com/');
        const title = await page.title();
        console.log(`we are testing the page: ${title}`);
    });

    test.describe('Login Success', () => {
        test('complete login flow and take screenshots', async ({ page }) => {
            const usernameInput = page.getByPlaceholder('Username');
            await usernameInput.fill('standard_user');

            const passwordInput = page.getByPlaceholder('Password');
            await passwordInput.fill('secret_sauce');

            const loginButton = page.getByRole('button', { name: 'Login' });
            await loginButton.click();

            await expect(page).toHaveURL(/.*inventory.html/);

            await page.screenshot({ path: 'screenshots/after-login.png', fullPage: true });
        });
    });

    test.describe('Login Failure', () => {
        test('shows error message with invalid credentials', async ({ page }) => {
            const usernameInput = page.getByPlaceholder('Username');
            await usernameInput.fill('locked_out_user');

            const passwordInput = page.getByPlaceholder('Password');
            await passwordInput.fill('secret_sauce');

            const loginButton = page.getByRole('button', { name: 'Login' });
            await loginButton.click();

            const errorMessage = page.locator('[data-test="error"]');
            await expect(errorMessage).toBeVisible();
            await expect(errorMessage).toContainText('Sorry, this user has been locked out.');

            await page.screenshot({ path: 'screenshots/login-error.png', fullPage: true });
        });
    });
});