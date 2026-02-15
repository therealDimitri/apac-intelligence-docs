# Azure AD Redirect URI Verification Guide

**Purpose:** Verify which redirect URIs are approved for the Azure AD app before migrating to Netlify

**Critical for:** Outlook sync to work on Day 1 without IT approval

---

## Your Azure AD App Details

From your `.env.local`:

```bash
# Azure AD Authentication - USING ALREADY APPROVED APP!
# This app "CS Connect Dashboard - Auth" already has admin approval
AZURE_AD_CLIENT_ID=e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3
AZURE_AD_CLIENT_SECRET=132c54bb-7d1f-4e09-a25d-f4089f41bf51
AZURE_AD_TENANT_ID=d4066c36-17ca-4e33-95d2-0db68e44900f
```

**App Name:** CS Connect Dashboard - Auth
**Client ID:** e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3
**Tenant ID:** d4066c36-17ca-4e33-95d2-0db68e44900f

---

## Step 1: Access Azure Portal

1. Go to: https://portal.azure.com
2. Sign in with your Altera account (dimitri.leimonitis@alterahealth.com)
3. Search for "Azure Active Directory" in the top search bar
4. Click on "Azure Active Directory"

---

## Step 2: Find Your App Registration

1. In the left sidebar, click **"App registrations"**
2. Click **"All applications"** tab at the top
3. Search for: **"CS Connect Dashboard - Auth"** OR search by Client ID: **e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3**
4. Click on the app to open its configuration

---

## Step 3: Check Redirect URIs

1. In the left sidebar of your app, click **"Authentication"**
2. Look at the **"Redirect URIs"** section
3. You should see a list of approved redirect URIs

### What to Look For:

**Check if ANY of these are listed:**

#### Option A: Netlify Subdomain

- ✅ `https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad`

#### Option B: Custom Domain (Netlify)

- ✅ `https://apac-cs-dashboards.com/api/auth/callback/azure-ad`

#### Option C: Old Dashboard (if exists)

- ⚠️ Any other domain with `/api/auth/callback/azure-ad`

**Take a screenshot of this page!** We need to know EXACTLY which URIs are approved.

---

## Step 4: Check API Permissions

While you're in the Azure portal:

1. Click **"API permissions"** in the left sidebar
2. Verify these Microsoft Graph permissions are granted:
   - ✅ `User.Read` (Read user profile)
   - ✅ `Calendars.Read` (Read user calendars) ← **CRITICAL for Outlook sync**
   - ✅ `offline_access` (Maintain access to data)

3. Check the **"Status"** column - should say **"Granted for [Your Organization]"**

**If you see "Admin consent required":**

- This means Outlook sync WON'T work
- Need to get IT to click "Grant admin consent"

---

## Step 5: Report Findings

**Tell me which redirect URIs you found:**

### Example Response Format:

**Approved Redirect URIs:**

```
✅ https://apac-cs-dashboards.com/api/auth/callback/azure-ad
✅ https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad
❌ https://apac-intelligence-v2.vercel.app/api/auth/callback/azure-ad (not listed)
```

**API Permissions Status:**

```
✅ User.Read - Granted
✅ Calendars.Read - Granted
✅ offline_access - Granted
```

---

## What This Means for Migration

### Scenario 1: Netlify URIs ARE Approved ✅

**Best case scenario!**

- Deploy to `apac-cs-dashboards.com` or `cs-connect-dashboard.netlify.app`
- Set `NEXTAUTH_URL` to the approved domain
- Azure AD OAuth works immediately
- **Outlook sync works on Day 1** 🎉

### Scenario 2: Only Old Dashboard URI Approved ⚠️

**We can work with this:**

- Deploy new app to same domain as old dashboard
- Replace old dashboard entirely
- Azure AD OAuth works (same domain)
- **Outlook sync works on Day 1** ✅

### Scenario 3: No Netlify URIs Approved ❌

**Need to add redirect URI:**

- Option A: Add the Netlify URI to existing app (requires IT approval)
- Option B: Check if you have admin consent permissions
- Option C: Use custom JWT bypass (no Outlook sync until approved)

---

## Next Steps Based on Results

**Once you tell me which URIs are approved, I'll:**

1. ✅ Configure deployment to the correct Netlify domain
2. ✅ Set environment variables with correct `NEXTAUTH_URL`
3. ✅ Deploy and test Azure AD authentication
4. ✅ Verify Outlook sync works
5. ✅ Provide migration completion report

---

## Quick Verification (5 minutes)

**Just need 3 pieces of information:**

1. **Approved Redirect URIs:** (copy/paste from Azure portal)
2. **API Permissions Status:** (Granted or Not Granted)
3. **Netlify Domain:** (which domain do you want to use?)

**Then we're ready to migrate!**

---

## Troubleshooting

**Can't find the app?**

- Try searching by Client ID instead of name
- Check if you're in the correct Azure AD tenant
- Verify you have permissions to view App Registrations

**No redirect URIs listed?**

- Might be configured as a different app type
- Check "Supported account types" section
- Might need to check "Authentication" → "Platform configurations"

**Permissions not granted?**

- Need admin to click "Grant admin consent for [Organization]"
- Without this, Outlook sync won't work
- This is separate from redirect URI approval

---

## Current Status

**What We Know:**

- ✅ You have an approved Azure AD app (CS Connect Dashboard - Auth)
- ✅ App has been working with previous dashboard
- ⚠️ Need to verify which domains are approved
- ⚠️ Need to verify Calendars.Read permission is granted

**What We Need:**

- List of approved redirect URIs
- Confirmation of API permissions status
- Decision on which Netlify domain to use

Once verified, deployment will take ~15 minutes and Outlook sync should work immediately!
