# 🔧 Azure AD Redirect URI Configuration Fix

**Error:** AADSTS50011
**Date:** November 26, 2025
**Status:** ACTION REQUIRED - Azure Portal Configuration

## ✅ Quick Fix Instructions

### Step 1: Access Azure Portal

1. **Go to:** https://portal.azure.com
2. **Sign in** with your admin account

### Step 2: Navigate to App Registration

1. Click **Azure Active Directory** (or search for it)
2. Click **App registrations** in the left menu
3. Search for: **APAC Intelligence Hub** or use App ID: `e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3`
4. Click on the application

### Step 3: Add the Redirect URI

1. Click **Authentication** in the left menu
2. Under **Platform configurations**, find **Web**
3. Click **Add URI** under Redirect URIs
4. **Add this EXACT URI:**
   ```
   https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad
   ```
5. **IMPORTANT:** Make sure there's no trailing slash!
6. Click **Save** at the top

### Step 4: Verify All Required URIs

Ensure ALL of these URIs are registered (add any missing ones):

✅ **Required Redirect URIs:**

```
https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad
https://cs-connect-dashboard.netlify.app/api/auth/callback/microsoft
https://cs-connect-dashboard.netlify.app/api/auth/signin
```

✅ **Optional (for backup/testing):**

```
https://apac-cs-dashboards.com/api/auth/callback/azure-ad
http://localhost:3001/api/auth/callback/azure-ad
```

## 📸 Visual Guide

### What You Should See:

1. **App registrations page:**
   - Your app: APAC Intelligence Hub
   - Application ID: e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3

2. **Authentication page:**
   - Platform: Web
   - Redirect URIs section with "Add URI" button

3. **After adding:**
   - All URIs listed above should be present
   - Save button clicked and changes saved

## ⚠️ Common Mistakes to Avoid

❌ **DON'T:**

- Add trailing slashes (wrong: `.../azure-ad/`)
- Use http instead of https
- Misspell "netlify" as "netify"
- Add spaces before or after the URI
- Forget to click Save

✅ **DO:**

- Copy and paste the exact URI from above
- Double-check for typos
- Ensure https:// protocol
- Save your changes

## 🔄 After Adding the URI

1. **Wait:** 1-2 minutes for Azure AD to propagate changes
2. **Clear browser cache:** Cmd+Shift+Delete (Mac) or Ctrl+Shift+Delete (Windows)
3. **Test again:** https://cs-connect-dashboard.netlify.app
4. **Click:** Sign In

## ✨ Expected Result

After adding the redirect URI:

- ✅ No more AADSTS50011 error
- ✅ Successful Microsoft authentication
- ✅ Redirect back to dashboard
- ✅ Dashboard loads with your data

## 🚨 If It Still Doesn't Work

### Check These:

1. **Exact Match:** The URI must match EXACTLY (case-sensitive)
2. **No Spaces:** Ensure no leading/trailing spaces
3. **Saved Changes:** Confirm you clicked Save in Azure Portal
4. **Wait Time:** Allow 2-3 minutes for propagation
5. **Browser Cache:** Try incognito/private mode

### Still Having Issues?

If the error persists after adding the URI:

1. **Double-check the error message** - it shows exactly what URI is being sent
2. **Compare with Azure Portal** - ensure they match character-for-character
3. **Check for duplicates** - remove and re-add if necessary
4. **Try a different browser** - to rule out caching issues

## 📊 Why This Happened

Our previous fix successfully resolved the proxy header issue, and the application is now correctly sending the Netlify subdomain in the redirect URI. However, Azure AD needs to have this exact URI registered to accept the authentication request.

**Progress:**

- ✅ AADSTS900971 fixed (no redirect URI sent → now sending correctly)
- 🔧 AADSTS50011 (redirect URI sent but not registered in Azure AD)
- ✅ Will work after Azure AD configuration

## 🎯 Summary

**What to do:** Add the redirect URI to Azure AD
**Where:** Azure Portal → App Registrations → Authentication
**What to add:** `https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad`
**Time required:** 2 minutes
**Difficulty:** Easy - just copy and paste!

---

This is the final step to get SSO working through the Netlify proxy!
