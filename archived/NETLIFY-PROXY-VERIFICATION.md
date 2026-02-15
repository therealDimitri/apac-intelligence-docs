# Netlify Proxy Verification & Troubleshooting Guide

**Date:** November 26, 2025
**Issue:** Corporate firewall still blocking after Netlify proxy setup
**Status:** 🔍 TROUBLESHOOTING

## Quick Verification Steps

### 1. Check Netlify Deployment Status

Visit your Netlify dashboard:

```
https://app.netlify.com/sites/apac-cs-dashboards/deploys
```

Look for:

- ✅ Latest deploy should show "Published"
- ✅ Deploy time should be recent (after we pushed \_redirects)
- ✅ No build errors

### 2. Verify \_redirects File is Deployed

Check if the redirect file is actually deployed:

```bash
curl -I https://apac-cs-dashboards.com/_redirects
```

If working, you should get:

- 404 (file shouldn't be publicly accessible)
- NOT the old dashboard HTML

### 3. Test the Proxy Directly

From your personal computer (not corporate network):

```bash
# Check if redirect is working
curl -I -L https://apac-cs-dashboards.com

# Should show:
# - Location header pointing to Vercel OR
# - Content from Vercel app
```

### 4. Check Browser Network Tab

1. Open Chrome DevTools (F12)
2. Go to Network tab
3. Visit https://apac-cs-dashboards.com
4. Look for:
   - Initial request to apac-cs-dashboards.com
   - Any redirect responses (301/302)
   - Final destination URL

## The Problem: Why It's Still Blocked

The issue is that Netlify's 200 proxy (`/*  https://apac-intelligence-v2.vercel.app/:splat  200`) still reveals the Vercel domain in:

- JavaScript bundle URLs
- API calls
- WebSocket connections

Corporate firewall is likely doing **deep packet inspection** and blocking when it sees Vercel URLs in the content.

## Solution: Netlify Edge Functions (Better Approach)

Let me create a proper edge function that will fully proxy the content:

### Step 1: Create Netlify Edge Function

Create this file structure in your `cs-connect-dashboard_sandbox` repo:
