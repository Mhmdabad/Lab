# Ansible Vault

Ansible Vault lets you encrypt sensitive data (passwords, API keys, tokens) so you can safely commit them to Git without exposing secrets in plain text.

---

## 1. Core Commands

### Encrypt a file
```bash
ansible-vault encrypt secrets.yml
```
It will ask you to set a vault password. After encryption, the file content becomes unreadable gibberish.

### View encrypted file
```bash
ansible-vault view secrets.yml
```

### Edit encrypted file
```bash
ansible-vault edit secrets.yml
```

### Decrypt a file (back to plain text)
```bash
ansible-vault decrypt secrets.yml
```

### Change the vault password
```bash
ansible-vault rekey secrets.yml
```

---

## 2. Running a Playbook with Vault Secrets

When your playbook loads an encrypted file, you need to provide the vault password at runtime:

### Option A: Prompt for password
```bash
ansible-playbook deploy-app.yml --ask-vault-pass
```

### Option B: Password from a file (no prompt)
```bash
echo "myvaultpassword" > .vault_pass
ansible-playbook deploy-app.yml --vault-password-file .vault_pass
```
> Add `.vault_pass` to `.gitignore` so you never commit the password file.

---

## 3. Workflow

```
1. Create secrets.yml with plain text secrets
2. Run: ansible-vault encrypt secrets.yml
3. secrets.yml is now encrypted → safe to commit to Git
4. In your playbook, load it like any other vars file:
     vars_files:
       - secrets.yml
5. Run playbook with: ansible-playbook deploy-app.yml --ask-vault-pass
```
