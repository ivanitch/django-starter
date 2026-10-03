# CI/CD Setup (GitHub Actions)

The project comes with a ready-made pipeline that automatically checks the code with linters, runs tests against a real PostgreSQL 18 database, and deploys changes to the server.

For the deployment to work, you need to give GitHub Actions secure access to your server (VPS).

## Step 1: Generate an SSH Key on the Server

Connect to your VPS and create a dedicated SSH key without a passphrase (`passphrase` must be empty). This key will be used only by the GitHub bot.

```bash
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github_actions -N ""
```

## Step 2: Add the Key to Authorized Keys

Allow login to the server using this key:

```shell
cat ~/.ssh/github_actions.pub >> ~/.ssh/authorized_keys
```

## Step 3: Copy the Private Key

Print the private key to the console and copy it in full, including the `-----BEGIN...` and `-----END...` lines:

```shell
cat ~/.ssh/github_actions
```

## Step 4: Configure Secrets in GitHub

Open the repository on GitHub and go to `Settings` ➡ `Secrets and variables` ➡ `Actions` ➡ `New repository secret`.
Add 3 variables:

- `SERVER_HOST` — the IP address of your server (for example, 63.183.77.237).
- `SERVER_USER` — the server username (for example, root).
- `SERVER_PORT` — the port connection (for example, 2222).
- `SSH_PRIVATE_KEY` — the private key copied from Step 3.
