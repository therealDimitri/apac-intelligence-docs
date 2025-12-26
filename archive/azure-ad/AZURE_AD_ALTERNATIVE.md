# Alternative: Create Personal App Registration

Since the company app requires admin approval, you can create your own app registration for development:

## Steps to Create Your Own App Registration:

### 1. Go to Azure Portal

- https://portal.azure.com
- Navigate to Azure Active Directory → App registrations

### 2. Create New Registration

- Click "+ New registration"
- Name: `APAC Dashboard Dev - [Your Name]`
- Supported account types: **Single tenant** (your organization only)
- Redirect URI:
  - Platform: Web
  - URL: `http://localhost:3001/api/auth/callback/azure-ad`
- Click "Register"

### 3. Copy Your New IDs

After creation, copy:

- Application (client) ID: (new value)
- Directory (tenant) ID: (same as before: d4066c36-17ca-4e33-95d2-0db68e44900f)

### 4. Create Client Secret

- Go to "Certificates & secrets"
- Click "+ New client secret"
- Description: "Dev Secret"
- Expiry: 24 months
- Click "Add"
- **COPY THE VALUE** (not the ID!)

### 5. Configure Permissions (Basic Only)

- Go to "API permissions"
- You should already have `User.Read` (basic profile)
- That's all you need for authentication!

### 6. Update Your .env.local

Replace the values with your new app registration:

```bash
AZURE_AD_CLIENT_ID=your-new-app-id
AZURE_AD_CLIENT_SECRET=your-new-secret
AZURE_AD_TENANT_ID=d4066c36-17ca-4e33-95d2-0db68e44900f
```

## Why This Works:

- Personal app registrations usually don't require admin consent
- Basic permissions (User.Read) are pre-approved in most organizations
- You own the app, so you control it
- Perfect for development and testing

## Important Notes:

- This is just for LOCAL DEVELOPMENT
- For production, you'll still need the official app with admin approval
- Keep your personal app registration separate from the production one
- Delete it when you're done with development

This approach lets you continue development while waiting for admin approval on the main app!
