# Post-Domain Setup Verification Guide

**APAC Intelligence Hub - Production Testing Checklist**

**Created:** November 26, 2025
**Domain:** https://apac-cs-dashboards.com
**Estimated Time:** 10 minutes

---

## What Just Happened

You just added `apac-cs-dashboards.com` as a custom domain to your Netlify project.

**What Netlify is Doing Now:**

- ✅ Configuring DNS routing to your site
- ✅ Provisioning SSL/HTTPS certificate (Let's Encrypt)
- ✅ Updating CDN edge nodes

**Expected Wait Time:** 1-2 minutes for HTTPS certificate

---

## Step 1: Wait for HTTPS Certificate (2 minutes)

### Check SSL Status in Netlify

1. Go to Netlify dashboard → Your site → **Domain settings**
2. Look for `apac-cs-dashboards.com` in the domains list
3. Wait for status to show: **"HTTPS enabled"** with green checkmark

**While Waiting:**

- Status will show "Certificate provisioning" or similar
- This is normal and automatic
- DO NOT navigate to the site yet (will show SSL error)

**When Ready:**

- ✅ Green checkmark next to domain
- ✅ "HTTPS" badge visible
- ✅ "Secure" indicator in browser

---

## Step 2: Test Azure AD Authentication (3 minutes)

### Test 1: Initial Navigation

1. Open browser (Chrome/Edge recommended)
2. Navigate to: `https://apac-cs-dashboards.com`
3. **Expected:** Sign-in page loads with "Sign in with Microsoft" button
4. **If shows SSL error:** Wait another minute, certificate still provisioning

### Test 2: Microsoft Sign-In

1. Click **"Sign in with Microsoft"**
2. Enter your email: `dimitri.leimonitis@alterahealth.com`
3. Enter your password

**CRITICAL SUCCESS INDICATOR:**

- ✅ **NO consent screen should appear** (tenant-wide admin consent already granted!)
- ✅ You should be redirected directly back to dashboard
- ✅ Your name/email should appear in top right

**If You See Consent Screen:**

- ⚠️ This is unexpected (App 1 should have tenant-wide approval)
- Accept it for now
- Document this for investigation

### Test 3: Verify Authentication

**Check these indicators:**

- [ ] Browser URL changed from `/auth/signin` to `/` (dashboard)
- [ ] Your name appears in navigation (top right)
- [ ] No error messages in browser console (F12 → Console tab)
- [ ] Dashboard content loads (charts, tables, etc.)

---

## Step 3: Test Outlook Sync (3 minutes)

### Navigate to Briefing Room

1. Click **"Meetings"** in sidebar navigation
2. Look for **"Briefing Room"** or **"Meeting Hub"** tab
3. Click **"Import from Outlook"** button

### Test Calendar Access

**Expected Flow:**

1. Button opens Microsoft Graph API calendar picker
2. You see your Outlook calendar meetings
3. Can select meetings to import
4. Import saves to Supabase `unified_meetings` table

**Success Indicators:**

- [ ] Calendar meetings load from Outlook
- [ ] Can select individual meetings
- [ ] Import button works
- [ ] Imported meeting appears in Briefing Room list
- [ ] Meeting data includes: client name, date, time, notes

**If Import Fails:**

- Check browser console for errors (F12 → Console)
- Verify you granted calendar permission during sign-in
- Try signing out and back in
- Check Supabase connection in browser console

---

## Step 4: Verify All Dashboard Pages (2 minutes)

### Quick Navigation Test

Visit each page and verify it loads:

- [ ] **Home/Dashboard** - Overview stats and charts
- [ ] **Clients** - Client list and health scores
- [ ] **NPS** - NPS analytics and trends
- [ ] **Meetings** - Briefing Room with meetings
- [ ] **Actions** - Action items and tasks
- [ ] **AI** - AI assistant or analytics

### Check for Errors

Open browser console (F12 → Console tab):

- [ ] No red error messages
- [ ] Supabase connection successful
- [ ] Data loads correctly
- [ ] Charts render properly

---

## Expected Results Summary

### ✅ Authentication Success

```
1. Navigate to https://apac-cs-dashboards.com ✅
2. Click "Sign in with Microsoft" ✅
3. NO consent screen appears ✅ (tenant-wide approval)
4. Redirected to dashboard ✅
5. User profile displays correctly ✅
```

### ✅ Outlook Sync Success

```
1. "Import from Outlook" button visible ✅
2. Calendar meetings load ✅
3. Can import meetings ✅
4. Data saves to Supabase ✅
5. Meetings appear in Briefing Room ✅
```

### ✅ Dashboard Functions

```
1. All pages load (6 sections) ✅
2. Data loads from Supabase ✅
3. Charts and tables render ✅
4. Navigation works ✅
5. No console errors ✅
```

---

## Troubleshooting

### Issue: HTTPS Certificate Not Provisioning

**Symptom:** "Not secure" warning in browser after 5+ minutes

**Solutions:**

1. Check Netlify dashboard → Domain settings → SSL status
2. Try "Renew certificate" button if available
3. Verify DNS is pointing to Netlify (run `dig apac-cs-dashboards.com +short`)
4. Wait up to 10 minutes (Let's Encrypt can be slow)

### Issue: Still Getting AADSTS50011 Error

**Symptom:** Redirect URI mismatch error from Azure AD

**Possible Causes:**

1. NEXTAUTH_URL environment variable incorrect
2. Accessing via wrong URL (use https://apac-cs-dashboards.com, not Netlify subdomain)
3. Browser cache (clear cookies and retry)

**Solutions:**

1. Verify in Netlify: Environment variables → NEXTAUTH_URL = https://apac-cs-dashboards.com
2. Clear browser cache and cookies
3. Try incognito/private browsing window
4. Verify redirect URI in Azure Portal matches exactly

### Issue: Outlook Sync Not Working

**Symptom:** "Import from Outlook" fails or shows no meetings

**Solutions:**

1. Verify in Azure Portal: App 1 has Calendars.Read permission
2. Check permission has "GRANTED for Altera Digital Health" status
3. Sign out and sign in again to refresh tokens
4. Check browser console for specific error messages
5. Verify you have calendar events in Outlook

### Issue: Environment Variables Not Working

**Symptom:** App shows errors about missing configuration

**Solutions:**

1. Go to Netlify → Site settings → Environment variables
2. Verify all variables are set:
   - AZURE_AD_CLIENT_ID
   - AZURE_AD_CLIENT_SECRET
   - AZURE_AD_TENANT_ID
   - NEXTAUTH_SECRET
   - NEXTAUTH_URL
   - NEXT_PUBLIC_SUPABASE_URL
   - NEXT_PUBLIC_SUPABASE_ANON_KEY
   - SUPABASE_SERVICE_ROLE_KEY
3. Click **"Trigger deploy"** to rebuild with new variables
4. Wait for new deployment to complete

---

## Success Metrics

### Authentication

- **Target:** 100% successful logins without consent prompts
- **Current:** Testing in progress

### Outlook Sync

- **Target:** 100% of users can import meetings on Day 1
- **Current:** Testing in progress

### Performance

- **Target:** Page load < 2 seconds
- **Target:** No critical errors
- **Current:** Testing in progress

---

## What to Report Back

### If Everything Works ✅

Report:

1. ✅ Authentication successful (no consent screen)
2. ✅ Outlook sync works (meetings imported)
3. ✅ All pages load correctly
4. ✅ No console errors

**Next Step:** Announce to team that dashboard is live at https://apac-cs-dashboards.com

### If Issues Found ❌

Report:

1. Which test failed (authentication, Outlook, dashboard pages)
2. Exact error message (screenshot or copy/paste)
3. Browser console errors (F12 → Console → screenshot)
4. Which browser you're using

**Next Step:** We'll debug the specific issue together

---

## Timeline

**Phase 1: SSL Provisioning** (1-2 minutes)

- Netlify provisions HTTPS certificate
- Wait for green checkmark in domain settings

**Phase 2: Authentication Test** (3 minutes)

- Navigate to https://apac-cs-dashboards.com
- Sign in with Microsoft
- Verify no consent screen
- Check dashboard loads

**Phase 3: Outlook Sync Test** (3 minutes)

- Open Briefing Room
- Click "Import from Outlook"
- Select and import a meeting
- Verify it appears in the list

**Phase 4: Dashboard Verification** (2 minutes)

- Visit all 6 main pages
- Check for errors
- Verify data loads

**Total Time:** ~10 minutes

---

## Post-Verification Actions

### If All Tests Pass

1. **Test with Team Member:**
   - Have 1-2 CSEs (Tracey, BoonTeck, Nikki) try logging in
   - Verify they can import their Outlook meetings
   - Confirm no consent screen appears for them either

2. **Monitor for 24 Hours:**
   - Watch for authentication errors
   - Track Outlook sync success rate
   - Gather user feedback

3. **Announce to Full Team:**
   - Send email with URL: https://apac-cs-dashboards.com
   - Instructions for Microsoft SSO login
   - How to import Outlook meetings

### If Issues Found

1. **Document the Issue:**
   - Screenshot of error
   - Browser console log
   - Steps to reproduce

2. **Debug Together:**
   - Check environment variables
   - Verify Azure AD configuration
   - Test Supabase connection

3. **Implement Fix:**
   - Update configuration as needed
   - Redeploy if necessary
   - Retest

---

## Contact & Support

**For Deployment Issues:**

- Check this guide's troubleshooting section
- Review Netlify build logs
- Check browser console errors

**For Azure AD Issues:**

- Verify redirect URI in Azure portal
- Check App 1 permissions (Calendars.Read)
- Verify tenant-wide admin consent is granted

**For Supabase Issues:**

- Verify connection strings in environment variables
- Check service role key is correct
- Test in Supabase SQL editor

---

**Status:** Ready for testing!
**Next Step:** Wait for HTTPS certificate, then test authentication
**ETA to Verification Complete:** ~10 minutes

🚀 **Once the SSL certificate is ready, start with Step 2!**
