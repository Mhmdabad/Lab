// @ts-check
import { test, expect } from '@playwright/test';

test.describe("automationexercise site",()=>{
   test('Register User',async ({page})=>{
    await page.goto("https://automationexercise.com/")
   await expect(page).toHaveTitle('Automation Exercise');  
   await page.getByRole('link', { name: 'Signup / Login' }).click();
   await expect(page.getByText("New User Signup!")).toBeVisible() 
   await page.locator('[data-qa="signup-name"]').fill("mohammed111test")
   await page.locator('[data-qa="signup-email"]').fill("mohammed111test@randommail1111.com")
   await page.locator('[data-qa="signup-button"]').click()
   await expect(page.getByText("ENTER ACCOUNT INFORMATION")).toBeVisible()
   await page.locator("#id_gender1").check()
   await page.locator('#password').fill("asd123")
   await page.locator("#days").selectOption("5")
   await page.locator('#months').selectOption({ label: 'May' });
   await page.locator('#years').selectOption('2003');
   await page.locator('#newsletter').check();
   await page.locator('#optin').check();
   await page.locator("#first_name").fill("mohammed")
   await page.locator("#last_name").fill("123")
   await page.locator("#address1").fill("haifa")
   await page.locator("#address2").fill("haifa 2")
   await page.locator("#country").selectOption("United States")
   await page.locator("#state").fill("new york")
   await page.locator("#city").fill("new york city")
   await page.locator("#zipcode").fill("12345")
   await page.locator("#mobile_number").fill("987654321")
   await page.locator('[data-qa="create-account"]').click()
   await expect(page.getByText('ACCOUNT CREATED!')).toBeVisible()
   await page .getByRole('link',{name: 'Continue'}).click()
   await expect(page.getByText('Logged in as mohammed111test')).toBeVisible()
   await page .getByRole('link',{name: 'Delete Account'}).click()
   await expect(page.getByText('ACCOUNT DELETED!')).toBeVisible()
   await page .getByRole('link',{name: 'Continue'}).click()


   
   })

   test('Login User with correct email and password',async({page})=>{
      await page.goto("https://automationexercise.com/")
      await expect(page).toHaveURL('https://automationexercise.com/');
      await page.getByRole("link",{name: ' Signup / Login'}).click()
      await expect(page.getByText("Login to your account")).toBeVisible()
      await page.locator('[data-qa="login-email"]').fill("mohammedTest12345@test.com")
      await page.locator('[data-qa="login-password"]').fill("passwordtest12345")
      await page.locator('[data-qa="login-button"]').click()
      await expect(page.getByText("Logged in as mohammedTest12345")).toBeVisible()
    await page .getByRole('link',{name: 'Delete Account'}).click()
     await expect(page.getByText('ACCOUNT DELETED!')).toBeVisible()   })


})