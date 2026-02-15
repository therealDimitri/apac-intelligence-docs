# Vercel Environment Variables for APAC Intelligence Hub v2

## Required Environment Variables

Copy and paste these into your Vercel project settings at:
https://vercel.com/therealDimitri/apac-intelligence-v2/settings/environment-variables

### 1. Azure AD Authentication

```env
AZURE_AD_CLIENT_ID=e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3
AZURE_AD_CLIENT_SECRET=132c54bb-7d1f-4e09-a25d-f4089f41bf51
AZURE_AD_TENANT_ID=d4066c36-17ca-4e33-95d2-0db68e44900f
```

### 2. NextAuth Configuration

```env
NEXTAUTH_SECRET=HmvIfUvhdch4AJ5vB63upBdQUMGQKGjeJSoXnpY9pGM=
NEXTAUTH_URL=https://apac-intelligence-v2.vercel.app
```

**Note:** Replace `apac-intelligence-v2.vercel.app` with your actual Vercel domain if different.

### 3. Supabase Database

```env
NEXT_PUBLIC_SUPABASE_URL=https://usoyxsunetvxdjdglkmn.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzb3l4c3VuZXR2eGRqZGdsa21uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA3Njk2NDksImV4cCI6MjA3NjM0NTY0OX0.jN3zCPmDaKF4PbLLcbbYfHAfbWJIuy-3pZwA_V-VDkU
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzb3l4c3VuZXR2eGRqZGdsa21uIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDc2OTY0OSwiZXhwIjoyMDc2MzQ1NjQ5fQ.zQN6yqzOXv68xNxhQa7suGssDmRBd5RXjB9s1i3z-KQ
```

## How to Add to Vercel

### Method 1: Via Vercel Dashboard (Recommended)

1. Go to your project: https://vercel.com/therealDimitri/apac-intelligence-v2
2. Click on "Settings" tab
3. Click on "Environment Variables" in the left sidebar
4. For each variable above:
   - Enter the Key (e.g., `AZURE_AD_CLIENT_ID`)
   - Enter the Value (e.g., `e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3`)
   - Select environments: Production, Preview, and Development
   - Click "Add"

### Method 2: Via Vercel CLI

```bash
cd /Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC\ Clients\ -\ Client\ Success/CS\ Connect\ Meetings/Sandbox/apac-intelligence-v2

# Add each variable
vercel env add AZURE_AD_CLIENT_ID production
vercel env add AZURE_AD_CLIENT_SECRET production
vercel env add AZURE_AD_TENANT_ID production
vercel env add NEXTAUTH_SECRET production
vercel env add NEXTAUTH_URL production
vercel env add NEXT_PUBLIC_SUPABASE_URL production
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production
vercel env add SUPABASE_SERVICE_ROLE_KEY production
```

## Complete .env.local for Local Development

Create a `.env.local` file in your project root with:

```env
# Azure AD Authentication
AZURE_AD_CLIENT_ID=e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3
AZURE_AD_CLIENT_SECRET=132c54bb-7d1f-4e09-a25d-f4089f41bf51
AZURE_AD_TENANT_ID=d4066c36-17ca-4e33-95d2-0db68e44900f

# NextAuth
NEXTAUTH_SECRET=HmvIfUvhdch4AJ5vB63upBdQUMGQKGjeJSoXnpY9pGM=
NEXTAUTH_URL=http://localhost:3001

# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://usoyxsunetvxdjdglkmn.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzb3l4c3VuZXR2eGRqZGdsa21uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA3Njk2NDksImV4cCI6MjA3NjM0NTY0OX0.jN3zCPmDaKF4PbLLcbbYfHAfbWJIuy-3pZwA_V-VDkU
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzb3l4c3VuZXR2eGRqZGdsa21uIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDc2OTY0OSwiZXhwIjoyMDc2MzQ1NjQ5fQ.zQN6yqzOXv68xNxhQa7suGssDmRBd5RXjB9s1i3z-KQ
```

## Post-Deployment Configuration

### 1. Update Azure AD Redirect URIs

After deployment, add these redirect URIs to your Azure AD app:

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to: Azure Active Directory → App Registrations
3. Select: "CS Connect Dashboard - Auth"
4. Go to: Authentication
5. Add these redirect URIs:
   - `https://apac-intelligence-v2.vercel.app/api/auth/callback/azure-ad`
   - `https://your-custom-domain.com/api/auth/callback/azure-ad` (if using custom domain)

### 2. Update NEXTAUTH_URL

If your Vercel deployment URL is different than `apac-intelligence-v2.vercel.app`:

1. Go to Vercel Dashboard → Settings → Environment Variables
2. Find `NEXTAUTH_URL`
3. Update it to your actual deployment URL
4. Redeploy for changes to take effect

### 3. Verify Deployment

After adding all environment variables:

1. Trigger a redeploy from Vercel Dashboard
2. Check build logs for any errors
3. Visit your deployment URL
4. Test SSO login with Microsoft account

## Security Notes

⚠️ **IMPORTANT**:

- Never commit these values to Git
- Keep `.env.local` in `.gitignore`
- Rotate secrets periodically
- Use different values for production vs development when possible

## Troubleshooting

If authentication fails after deployment:

1. **Check NEXTAUTH_URL**: Must match your exact deployment URL
2. **Verify Azure redirect URIs**: Must include `/api/auth/callback/azure-ad`
3. **Check build logs**: Look for missing environment variable warnings
4. **Test locally first**: Ensure it works with `.env.local`
5. **Clear cookies**: Sometimes old auth cookies cause issues

## Support Resources

- [Vercel Environment Variables Guide](https://vercel.com/docs/environment-variables)
- [NextAuth.js Azure AD Provider](https://next-auth.js.org/providers/azure-ad)
- [Supabase Environment Variables](https://supabase.com/docs/guides/getting-started/quickstarts/nextjs)

---

**Created**: November 26, 2025
**Project**: APAC Intelligence Hub v2
**Status**: Ready for deployment configuration
