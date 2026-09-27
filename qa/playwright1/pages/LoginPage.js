export class login{
    constructor(page){
        this.page=page
        this.usernameInput=this.page.locator('#username')
        this.passwordInput=this.page.locator('#password')
        this.loginButton=this.page.locator('#submit-login')
    }
    async goto(){
        await this.page.goto("https://practice.expandtesting.com/login")
    }

    async login(username,password)
    {
        await this.usernameInput.fill(username)
        await this.passwordInput.fill(password)
        await this.loginButton.click()
    }

}