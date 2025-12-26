# Azure AD Configuration Guide

## Step 1: Register Your Application in Azure Portal

### 1.1 Navigate to Azure Portal

1. Go to https://portal.azure.com
2. Sign in with your Microsoft account
3. Search for "Azure Active Directory" in the top search bar

### 1.2 Create App Registration

1. In Azure AD, click **App registrations** in the left menu
2. Click **+ New registration** at the top
3. Fill in the registration form:
   - **Name:** `APAC Intelligence Hub`
   - **Supported account types:** Choose one:
     - ✅ "Accounts in this organizational directory only (Single tenant)" - RECOMMENDED
     - ⚪ "Accounts in any organizational directory (Multi-tenant)"
   - **Redirect URI:**
     - Platform: `Web`
     - URL: `http://localhost:3001/api/auth/callback/azure-ad`
4. Click **Register**

### 1.3 Save Your Application IDs

After registration, you'll see the overview page. Copy these values:

```
Application (client) ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Directory (tenant) ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### 1.4 Create Client Secret

1. In your app registration, click **Certificates & secrets** in the left menu
2. Click **+ New client secret**
3. Add a description: `APAC Intelligence Hub Secret`
4. Choose expiry: `24 months` (or as per your policy)
5. Click **Add**
6. **IMPORTANT:** Copy the secret VALUE immediately (not the Secret ID)
   - You won't be able to see it again!
   - It looks like: `abcDEF123!@#$%^&*()_+...`

### 1.5 Add Additional Redirect URIs

1. Go to **Authentication** in the left menu
2. Under "Platform configurations", find your Web platform
3. Add these additional Redirect URIs:
   ```
   http://localhost:3000/api/auth/callback/azure-ad
   http://localhost:3001/api/auth/callback/azure-ad
   https://your-staging-url.vercel.app/api/auth/callback/azure-ad
   https://your-production-url.com/api/auth/callback/azure-ad
   ```
4. Under "Implicit grant and hybrid flows", check:
   - ✅ ID tokens
5. Click **Save**

### 1.6 Configure API Permissions (Optional)

If you want to access Microsoft Graph API:

1. Click **API permissions** in the left menu
2. Click **+ Add a permission**
3. Choose **Microsoft Graph**
4. Choose **Delegated permissions**
5. Select:
   - `User.Read` (usually already added)
   - `Calendars.Read` (for Outlook calendar)
   - `Mail.Read` (for emails)
6. Click **Add permissions**
7. Click **Grant admin consent** (if you have admin rights)

## Step 2: Configure Your Next.js Application

### 2.1 Update .env.local

Add these values to your `.env.local` file:

```bash
# Azure AD Configuration
AZURE_AD_CLIENT_ID=paste-your-application-id-here
AZURE_AD_CLIENT_SECRET=paste-your-secret-value-here
AZURE_AD_TENANT_ID=paste-your-tenant-id-here

# NextAuth Configuration
NEXTAUTH_URL=http://localhost:3001
NEXTAUTH_SECRET=generate-a-random-32-character-string-here

# You can generate NEXTAUTH_SECRET with:
# openssl rand -base64 32
```

### 2.2 Test Your Configuration

1. Restart your development server:
   ```bash
   # Stop with Ctrl+C, then:
   npm run dev
   ```
2. Visit http://localhost:3001
3. Click "Sign In" (when we add the button)
4. You should be redirected to Microsoft login

## Step 3: Staging & Production Setup

### For Vercel Deployment:

1. Add environment variables in Vercel Dashboard:
   - Go to your project settings
   - Environment Variables tab
   - Add all the Azure AD variables
   - Different values for staging vs production

### For Production:

1. Update redirect URIs in Azure AD
2. Use production URLs for NEXTAUTH_URL
3. Ensure HTTPS is enabled

## Common Issues & Solutions

### Issue: "Invalid client secret"

- Make sure you copied the VALUE, not the ID
- Check for extra spaces or line breaks
- Try creating a new secret

### Issue: "Redirect URI mismatch"

- Ensure the URI in Azure AD exactly matches your app
- Include the full path: `/api/auth/callback/azure-ad`
- Check for http vs https

### Issue: "Tenant not found"

- Verify the tenant ID is correct
- Check if you're using the right Azure AD instance

### Issue: "Unauthorized client"

- Grant admin consent for API permissions
- Check if app registration is in the correct tenant

## Security Best Practices

1. **Never commit .env.local to git**
   - It's already in .gitignore
   - Use environment variables in production

2. **Rotate secrets regularly**
   - Set calendar reminders before expiry
   - Update in all environments

3. **Use different app registrations**
   - One for development
   - One for staging
   - One for production

4. **Limit permissions**
   - Only request what you need
   - Remove unused permissions

## Quick Test URLs

After setup, test these:

- Sign in: http://localhost:3001/api/auth/signin
- Sign out: http://localhost:3001/api/auth/signout
- Session: http://localhost:3001/api/auth/session

## Next Steps

1. ✅ Complete Azure AD app registration
2. ✅ Add credentials to .env.local
3. ⏭️ Create sign-in page
4. ⏭️ Add auth protection to routes
5. ⏭️ Test the flow

---

Need help? Common values for Altera Health:

- Tenant Name: Usually "alteradigitalhealth" or similar
- Domain: @alterahealth.com or @altera.com
