import { test, expect } from '@playwright/test';
import { login } from '../pages/LoginPage';
import { testData } from '../data/testData';

test("test number 1",async ({page})=>{
    const loginpage=new login(page)
    await loginpage.goto()
    await loginpage.login(testData.validUser.username, testData.validUser.password)
    await expect(page).toHaveURL(/\/secure$/);
})