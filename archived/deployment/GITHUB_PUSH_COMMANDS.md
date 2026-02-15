# GitHub Push Commands

After creating your repository on GitHub, run these commands:

```bash
# Navigate to your project
cd "/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Clients - Client Success/CS Connect Meetings/Sandbox/apac-intelligence-v2"

# Add GitHub as remote (replace YOUR_GITHUB_USERNAME)
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/apac-intelligence-v2.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## If you get authentication errors:

GitHub now requires personal access tokens instead of passwords.

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate a new token with "repo" scope
3. Use the token as your password when prompted

## Alternative: Use SSH

```bash
# Add SSH remote instead
git remote set-url origin git@github.com:YOUR_GITHUB_USERNAME/apac-intelligence-v2.git

# Then push
git push -u origin main
```
