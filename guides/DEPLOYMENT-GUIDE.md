# APAC Intelligence Hub - Deployment Guide

## SSO Authentication Status ✅

✅ **CS Connect Dashboard - Auth** app has been **APPROVED** with admin consent granted on November 25, 2025
✅ Azure AD configuration is complete and ready for production
✅ Build compiled successfully

## Prerequisites

1. **Vercel Account**: Sign up at [vercel.com](https://vercel.com)
2. **GitHub Account**: For repository hosting (optional, but recommended)
3. **Environment Variables**: Production values ready

## Deployment Steps

### Option 1: Deploy via Vercel CLI (Recommended)

1. **Install Vercel CLI** (if not already installed):

   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel**:

   ```bash
   vercel login
   ```

3. **Deploy from the project directory**:

   ```bash
   cd apac-intelligence-v2
   vercel
   ```

4. **Follow the prompts**:
   - Set up and deploy: `Y`
   - Which scope: Select your account
   - Link to existing project: `N` (first time)
   - Project name: `apac-intelligence` (or your choice)
   - Directory: `./` (current directory)
   - Override settings: `N`

5. **Configure Environment Variables**:

   ```bash
   vercel env add AZURE_AD_CLIENT_ID production
   vercel env add AZURE_AD_CLIENT_SECRET production
   vercel env add AZURE_AD_TENANT_ID production
   vercel env add NEXTAUTH_SECRET production
   vercel env add NEXT_PUBLIC_SUPABASE_URL production
   vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production
   vercel env add SUPABASE_SERVICE_ROLE_KEY production
   ```

6. **Deploy to Production**:
   ```bash
   vercel --prod
   ```

### Option 2: Deploy via GitHub Integration

1. **Push to GitHub**:

   ```bash
   git add .
   git commit -m "Initial deployment with SSO"
   git remote add origin <your-github-repo-url>
   git push -u origin main
   ```

2. **Import to Vercel**:
   - Go to [vercel.com/new](https://vercel.com/new)
   - Import your GitHub repository
   - Configure environment variables in Vercel dashboard
   - Deploy

### Option 3: Direct Upload to Vercel

1. Visit [vercel.com/new](https://vercel.com/new)
2. Select "Upload Folder"
3. Upload the `apac-intelligence-v2` folder
4. Configure environment variables
5. Deploy

## Environment Variables Configuration

In the Vercel dashboard, add these environment variables:

```env
# Azure AD (APPROVED APP)
AZURE_AD_CLIENT_ID=e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3
AZURE_AD_CLIENT_SECRET=132c54bb-7d1f-4e09-a25d-f4089f41bf51
AZURE_AD_TENANT_ID=d4066c36-17ca-4e33-95d2-0db68e44900f

# NextAuth
NEXTAUTH_SECRET=HmvIfUvhdch4AJ5vB63upBdQUMGQKGjeJSoXnpY9pGM=
NEXTAUTH_URL=https://your-app-name.vercel.app

# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://usoyxsunetvxdjdglkmn.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzb3l4c3VuZXR2eGRqZGdsa21uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA3Njk2NDksImV4cCI6MjA3NjM0NTY0OX0.jN3zCPmDaKF4PbLLcbbYfHAfbWJIuy-3pZwA_V-VDkU
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzb3l4c3VuZXR2eGRqZGdsa21uIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDc2OTY0OSwiZXhwIjoyMDc2MzQ1NjQ5fQ.zQN6yqzOXv68xNxhQa7suGssDmRBd5RXjB9s1i3z-KQ

# App Configuration
NEXT_PUBLIC_APP_NAME="APAC Client Success Intelligence Hub"
NEXT_PUBLIC_ENABLE_AI=true
NEXT_PUBLIC_ENABLE_ANALYTICS=true

# OpenAI (Optional - add if you have an API key)
OPENAI_API_KEY=
```

⚠️ **Important**: Update `NEXTAUTH_URL` with your actual Vercel deployment URL after the first deployment.

## Azure AD Configuration

### Redirect URIs to Add in Azure Portal

After deployment, add these redirect URIs to your Azure AD app registration:

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to: Azure Active Directory → App registrations → CS Connect Dashboard - Auth
3. Go to Authentication → Platform configurations → Web
4. Add these Redirect URIs:
   - `https://your-app-name.vercel.app/api/auth/callback/azure-ad`
   - `https://your-app-name.vercel.app/auth/signin`
   - `https://your-app-name.vercel.app/auth/error`

Replace `your-app-name` with your actual Vercel deployment URL.

## Post-Deployment Checklist

- [ ] Application deployed successfully
- [ ] Custom domain configured (optional)
- [ ] Environment variables set in Vercel
- [ ] Azure AD redirect URIs updated
- [ ] Test SSO login flow
- [ ] Verify Supabase connection
- [ ] Test all dashboard features
- [ ] Share access with team members

## Accessing the Deployed Application

Once deployed, your application will be available at:

- **Production**: `https://your-app-name.vercel.app`
- **Preview**: Each PR will get a preview URL

## Troubleshooting

### SSO Login Issues

- Verify Azure AD redirect URIs match your deployment URL
- Check environment variables are correctly set in Vercel
- Ensure admin consent is still granted

### Build Failures

- Check build logs in Vercel dashboard
- Ensure all dependencies are installed with `--legacy-peer-deps`
- Verify TypeScript types are correct

### Database Connection Issues

- Verify Supabase credentials are correct
- Check Supabase project is active
- Ensure service role key is properly set

## Support

For any deployment issues, check:

- Vercel deployment logs
- Browser console for client-side errors
- Network tab for API failures

## Success! 🎉

Once deployed, your APAC Client Success Intelligence Hub will be live with:

- ✅ Microsoft SSO authentication (approved!)
- ✅ Real-time NPS analytics
- ✅ Meeting insights
- ✅ Action tracking
- ✅ AI-powered recommendations
