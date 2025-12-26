# Complete Netlify Proxy Setup & Verification Guide

**Date:** November 26, 2025
**Status:** ✅ DEPLOYED - Awaiting Verification

## What We've Done

### 1. Created Proxy Configuration Files

✅ **\_redirects file** (created and pushed)

- Location: `/cs-connect-dashboard_sandbox/_redirects`
- Proxies all routes to Vercel backend
- Uses 200 status code to hide the proxy

✅ **netlify.toml update** (modified and pushed)

- Added explicit proxy rules at the top
- Force=true to override existing rules
- Covers API, auth, static assets, and all dashboard routes

### 2. Pushed to GitHub

✅ **Git Commit:** 62119f4

- Message: "Add Netlify proxy configuration to bypass corporate firewall"
- Pushed to: https://github.com/therealDimitri/apac-cs-intelligence.git
- Branch: main

## How to Verify It's Working

### Step 1: Check Netlify Deployment Status

1. Go to: https://app.netlify.com/sites/apac-cs-dashboards/deploys
2. Look for the latest deployment
3. Should show:
   - **Status:** Published ✅
   - **Commit:** 62119f4
   - **Time:** Recent (within last few minutes)

### Step 2: Quick Test from Browser

**From your corporate network:**

1. Clear browser cache completely:
   - Mac: `Cmd + Shift + R`
   - Windows: `Ctrl + Shift + R`

2. Visit: https://apac-cs-dashboards.com

3. What you should see:
   - ✅ New APAC Intelligence Hub v2 login page (purple gradient)
   - ✅ NOT the old dashboard
   - ✅ NOT a firewall blocking page

### Step 3: Check Browser DevTools

1. Open Chrome DevTools (`F12`)
2. Go to **Network** tab
3. Refresh the page
4. Look at the requests:
   - ✅ All URLs should be `apac-cs-dashboards.com/*`
   - ❌ NO URLs should contain `vercel.app`

### Step 4: Test Specific Routes

Try these URLs directly:

- https://apac-cs-dashboards.com/ (should show login)
- https://apac-cs-dashboards.com/auth/signin (sign-in page)
- https://apac-cs-dashboards.com/api/auth/providers (should return JSON)

## If It's Still Blocked

### Possible Issues & Solutions

#### 1. Netlify Hasn't Deployed Yet

- **Check:** Netlify dashboard for deployment status
- **Solution:** Wait 2-3 minutes for deployment to complete

#### 2. Browser Cache

- **Check:** Try incognito/private browsing mode
- **Solution:** Clear all browser data for apac-cs-dashboards.com

#### 3. DNS Cache

- **Check:** Try from a different browser
- **Solution:**

  ```bash
  # Mac
  sudo dscacheutil -flushcache

  # Windows
  ipconfig /flushdns
  ```

#### 4. Still Showing Old Dashboard

The proxy might be working but you're seeing cached content.

- **Solution:** Add a query parameter to force refresh:
  https://apac-cs-dashboards.com/?v=new

#### 5. Firewall Still Detecting Vercel

If the firewall is still blocking, it might be doing deeper inspection.

- **Next Step:** We'll need to create a Netlify Edge Function (more advanced proxy)

## Quick Diagnostics

Run this from your terminal to check if the proxy is active:

```bash
# Check if redirect is working (should return HTML, not redirect)
curl -I https://apac-cs-dashboards.com

# Check API proxy (should return JSON)
curl https://apac-cs-dashboards.com/api/auth/providers
```

## What Success Looks Like

When the proxy is working correctly:

1. **URL Bar:** Shows `apac-cs-dashboards.com`
2. **Page Content:** New purple APAC Intelligence Hub v2 login
3. **Network Tab:** No `vercel.app` URLs visible
4. **Console:** No CORS or fetch errors
5. **Firewall:** No blocking message

## Next Steps After Verification

Once the proxy is confirmed working:

1. ✅ Update NEXTAUTH_URL in Vercel to `https://apac-cs-dashboards.com`
2. ✅ Update Azure AD redirect URIs
3. ✅ Test SSO authentication
4. ✅ Verify all dashboard features work through proxy

## Support

If you're still having issues after trying all verification steps:

1. Check Netlify build logs for errors
2. Verify the GitHub push was successful
3. Try accessing from a personal device to isolate the issue
4. Share the browser console errors for debugging

---

**Files Created:**

- `_redirects` - Netlify proxy rules
- `netlify.toml` - Updated configuration

**GitHub Commit:** 62119f4
**Repository:** apac-cs-intelligence
**Netlify Site:** apac-cs-dashboards

The proxy configuration is now live and should bypass the corporate firewall. Please verify from your corporate network and report back!
