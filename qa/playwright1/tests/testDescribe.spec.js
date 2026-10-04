import { test, expect } from '@playwright/test';
import dotenv from 'dotenv';

dotenv.config();
test.describe("login test",()=>{
    test.beforeAll(async () => {
    console.log('Runs once before all tests');
  });

    test.beforeEach(async({page})=>{
        await page.goto(process.env.SITE_URL)

    })

    test.afterEach(()=>{
        console.log("test finished")
    })


    test("login success",async({page})=>{
        const usernameinput=page.locator("#username")
        const passwordinput=page.locator("#password")
        const loginBTN=page.locator("#submit-login")

        await usernameinput.fill("practice")
        await passwordinput.fill("SuperSecretPassword!")
        await loginBTN.click()
        await expect(page).toHaveURL(/\/secure$/);
    })

    test("login failed",async({page})=>{
        const usernameinput=page.locator("#username")
        const passwordinput=page.locator("#password")
        const loginBTN=page.locator("#submit-login")

        await usernameinput.fill("wrongUser")
        await passwordinput.fill("wrongpassword!")
        await loginBTN.click()
        const WrongMessage=page.getByText("Your password is invalid!")
        await expect(WrongMessage).toBeVisible()
    })

    test.afterAll(async () => {
    console.log('Runs once after all tests');
  });

})