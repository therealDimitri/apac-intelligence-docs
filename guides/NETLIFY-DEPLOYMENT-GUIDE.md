# Netlify Deployment Guide

## APAC Intelligence Hub - Production Deployment with Outlook Sync

**Estimated Time:** 30 minutes
**Prerequisites:** App 1 redirect URI added in Azure Portal ✅

---

## Phase 1: Prepare Local Repository (5 minutes)

### 1. Commit Netlify Configuration

```bash
cd "/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Clients - Client Success/CS Connect Meetings/Sandbox/apac-intelligence-v2"

# Add all new files
git add netlify.toml
git add package.json package-lock.json
git add docs/NETLIFY-DEPLOYMENT-GUIDE.md

# Commit
git commit -m "Add Netlify configuration for production deployment

- netlify.toml with Next.js 15 build settings
- @netlify/plugin-nextjs installed
- Ready for deployment to apac-cs-dashboards.com
- Will use App 1 (e4c2a55f) with updated redirect URI"

# Push to GitHub
git push origin main
```

---

## Phase 2: Connect GitHub to Netlify (10 minutes)

### 1. Log in to Netlify

Go to: https://app.netlify.com

Sign in with your Netlify account

### 2. Import Your Project

1. Click **"Add new site"** → **"Import an existing project"**
2. Choose **"Deploy with GitHub"**
3. Authorize Netlify to access your GitHub account (if needed)
4. Search for: **"apac-intelligence-v2"**
5. Click on your repository

### 3. Configure Build Settings

Netlify should auto-detect these from `netlify.toml`:

```
Base directory: (leave empty)
Build command: npm run build
Publish directory: .next
```

**Don't deploy yet!** Click **"Show advanced"** to add environment variables first.

---

## Phase 3: Configure Environment Variables (10 minutes)

### Critical: Add All Environment Variables

In the Netlify dashboard, under **"Environment variables"**, add these:

#### Azure AD Configuration

```
AZURE_AD_CLIENT_ID = e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3
AZURE_AD_CLIENT_SECRET = 132c54bb-7d1f-4e09-a25d-f4089f41bf51
AZURE_AD_TENANT_ID = d4066c36-17ca-4e33-95d2-0db68e44900f
```

#### NextAuth Configuration

```
NEXTAUTH_SECRET = HmvIfUvhdch4AJ5vB63upBdQUMGQKGjeJSoXnpY9pGM=
NEXTAUTH_URL = https://apac-cs-dashboards.com
```

#### Supabase Configuration

```
NEXT_PUBLIC_SUPABASE_URL = https://usoyxsunetvxdjdglkmn.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY = [copy from .env.local]
SUPABASE_SERVICE_ROLE_KEY = [copy from .env.local]
```

**Important Notes:**

- For Supabase keys, copy the FULL values from your `.env.local` file
- `NEXTAUTH_URL` MUST be `https://apac-cs-dashboards.com`
- Double-check `AZURE_AD_CLIENT_ID` matches App 1 (e4c2a55f)

---

## Phase 4: Configure Custom Domain (5 minutes)

### 1. Set Custom Domain

In Netlify dashboard:

1. Go to **"Domain settings"**
2. Click **"Add custom domain"**
3. Enter: `apac-cs-dashboards.com`
4. Click **"Verify"**

### 2. DNS Configuration

You should already have DNS pointing to Netlify from the old dashboard.

**Verify DNS settings:**

```bash
dig apac-cs-dashboards.com +short
```

Should show Netlify IP addresses.

If not, update DNS:

```
Type: A
Name: @
Value: 75.2.60.5 (Netlify load balancer)
TTL: 3600
```

---

## Phase 5: Deploy! (5 minutes)

### 1. Click Deploy

Back in the Netlify dashboard, click **"Deploy site"**

### 2. Monitor Build

Watch the build log:

- Should see "Building Next.js app..."
- Should complete in ~2-3 minutes
- Should show "Site is live!"

### 3. Check Deploy URL

Netlify will give you a temporary URL like:
`https://apac-intelligence-v2.netlify.app`

Test this URL first before using custom domain!

---

## Phase 6: Test Authentication & Outlook Sync (10 minutes)

### Test 1: Azure AD Authentication

1. Navigate to: `https://apac-cs-dashboards.com`
2. Click **"Sign in with Microsoft"**
3. Enter your email: `dimitri.leimonitis@alterahealth.com`
4. Should redirect to Microsoft login
5. **Should NOT see consent screen** (tenant-wide approval already granted!)
6. Should redirect back to dashboard successfully
7. Verify you're logged in (see your name/email)

### Test 2: Outlook Calendar Access

1. Navigate to **Briefing Room** (Meeting Hub)
2. Click **"Import from Outlook"**
3. Should see your Outlook calendar meetings
4. Select a meeting
5. Click **"Import"**
6. Should successfully import to `unified_meetings` table
7. Verify meeting appears in Briefing Room

### Test 3: Team Member Access

1. Sign out
2. Have a team member try to log in:
   - Tracey, BoonTeck, Nikki, or another CSE
3. They should log in successfully
4. **No consent screen** (tenant-wide approval!)
5. They can import their own Outlook meetings

---

## Expected Results

### ✅ Success Indicators

1. **Authentication Works:**
   - ✅ Microsoft login completes
   - ✅ No consent prompts (tenant-wide approval)
   - ✅ User redirected to dashboard
   - ✅ User profile displays correctly

2. **Outlook Sync Works:**
   - ✅ "Import from Outlook" button appears
   - ✅ Calendar meetings load
   - ✅ Meetings import successfully
   - ✅ Data saved to Supabase
   - ✅ Meetings appear in Briefing Room

3. **Dashboard Functions:**
   - ✅ All pages load (Clients, NPS, Meetings, Actions, AI)
   - ✅ Data loads from Supabase
   - ✅ Charts and tables render
   - ✅ Navigation works
   - ✅ No console errors

---

## Troubleshooting

### Issue: AADSTS50011 (Redirect URI Mismatch)

**Symptom:** Azure AD shows redirect URI error

**Solution:**

1. Verify you added: `https://apac-cs-dashboards.com/api/auth/callback/azure-ad`
2. Check NEXTAUTH_URL in Netlify environment variables
3. Make sure it's EXACTLY: `https://apac-cs-dashboards.com` (no trailing slash!)

### Issue: Build Fails

**Symptom:** Netlify build fails with errors

**Solutions:**

1. Check build log for specific error
2. Verify all environment variables are set
3. Make sure Supabase keys are correct
4. Try clearing build cache: Settings → Build & deploy → Clear cache

### Issue: Outlook Import Doesn't Work

**Symptom:** "Import from Outlook" fails or shows no meetings

**Solutions:**

1. Verify Calendars.Read permission in Azure AD
2. Check that permission has admin consent granted
3. Verify user has calendar events in Outlook
4. Check browser console for errors
5. Verify Supabase connection works

### Issue: Environment Variables Not Working

**Symptom:** App shows errors about missing configuration

**Solutions:**

1. Go to Netlify dashboard → Site settings → Environment variables
2. Verify all variables are set correctly
3. Click **"Trigger deploy"** to rebuild with new variables
4. Check for typos in variable names (case-sensitive!)

---

## Rollback Plan

If deployment fails or has critical issues:

### Option 1: Revert to Vercel

1. Keep Vercel deployment running
2. Point DNS back to Vercel
3. Fix issues in staging
4. Re-attempt Netlify deployment later

### Option 2: Use Team Bypass

If Azure AD fails:

1. Users can access via: `https://apac-cs-dashboards.com/auth/bypass`
2. Enter name and @alterahealth.com email
3. Temporary access while fixing Azure AD

### Option 3: Rollback GitHub Commit

```bash
git revert HEAD
git push origin main
```

Netlify will automatically deploy the previous version.

---

## Post-Deployment Checklist

### Day 1 (Immediate)

- [ ] Test Azure AD authentication with your account
- [ ] Test Outlook calendar import with your account
- [ ] Verify all pages load correctly
- [ ] Check console for errors
- [ ] Test on mobile device

### Day 2-3 (Team Testing)

- [ ] Have 2-3 CSEs test authentication
- [ ] Have them import Outlook meetings
- [ ] Gather feedback on any issues
- [ ] Verify Supabase data is saving correctly

### Week 1 (Full Rollout)

- [ ] All team members test access
- [ ] Monitor error logs
- [ ] Check performance metrics
- [ ] Verify Outlook sync working for everyone

---

## Success Metrics

### Authentication

- **Target:** 100% successful logins
- **Current:** 0% (not yet deployed)
- **Post-Deploy:** Should be 100% (tenant-wide approval)

### Outlook Sync

- **Target:** 100% of users can import meetings
- **Current:** 0% (not yet deployed)
- **Post-Deploy:** Should be 100% (Calendars.Read granted)

### Performance

- **Target:** Page load < 2 seconds
- **Target:** Build time < 3 minutes
- **Target:** Zero critical errors

---

## Environment Variable Reference

**Full list for copy/paste into Netlify:**

```env
# Azure AD (App 1 - Production)
AZURE_AD_CLIENT_ID=e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3
AZURE_AD_CLIENT_SECRET=132c54bb-7d1f-4e09-a25d-f4089f41bf51
AZURE_AD_TENANT_ID=d4066c36-17ca-4e33-95d2-0db68e44900f

# NextAuth
NEXTAUTH_SECRET=HmvIfUvhdch4AJ5vB63upBdQUMGQKGjeJSoXnpY9pGM=
NEXTAUTH_URL=https://apac-cs-dashboards.com

# Supabase (copy full keys from .env.local)
NEXT_PUBLIC_SUPABASE_URL=https://usoyxsunetvxdjdglkmn.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=[PASTE_FROM_ENV_LOCAL]
SUPABASE_SERVICE_ROLE_KEY=[PASTE_FROM_ENV_LOCAL]
```

---

## Deployment Timeline

**Total Time:** ~40 minutes

1. ✅ Azure AD redirect URI added (completed)
2. ⏱️ Commit and push to GitHub (5 minutes)
3. ⏱️ Connect GitHub to Netlify (10 minutes)
4. ⏱️ Configure environment variables (10 minutes)
5. ⏱️ Set custom domain (5 minutes)
6. ⏱️ Deploy and test (10 minutes)

---

## Contact & Support

**Issues During Deployment:**

- Check Netlify build logs
- Check browser console errors
- Reference this guide's troubleshooting section

**Azure AD Issues:**

- Verify redirect URI in Azure portal
- Check App 1 has Calendars.Read permission
- Verify tenant-wide admin consent is granted

**Supabase Issues:**

- Verify connection strings
- Check service role key is correct
- Test in Supabase SQL editor

---

## Next Steps After Deployment

1. **Announce to Team:**
   - Send email with new URL: `https://apac-cs-dashboards.com`
   - Instructions for Microsoft SSO login
   - How to import Outlook meetings

2. **Monitor for 1 Week:**
   - Watch for authentication errors
   - Track Outlook sync success rate
   - Gather user feedback

3. **Decommission Vercel:**
   - After 1 week of stable Netlify deployment
   - Archive Vercel project
   - Update documentation

---

**Status:** Ready for deployment!
**Next Step:** Push code to GitHub and import to Netlify
**ETA to Live:** ~40 minutes from starting Phase 1

🚀 Let's deploy!
