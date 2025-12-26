# ⚠️ CRITICAL: Azure AD Configuration Fix for AADSTS50011

**Date:** November 26, 2025
**Error:** AADSTS50011 - Redirect URI mismatch
**Status:** URGENT ACTION REQUIRED

## 🔴 The Problem

The application is sending the redirect URI:

```
https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad
```

Azure AD is rejecting it saying it doesn't match the configured URIs for application ID: `e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3`

## 🎯 Critical Configuration Steps

### Step 1: Access Azure Portal

1. Go to: https://portal.azure.com
2. Navigate to: **Azure Active Directory** → **App registrations**
3. Find app: **APAC Intelligence Hub** (ID: e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3)

### Step 2: Verify Platform Configuration

1. Click **Authentication** in the left menu
2. Check that you have a **Web** platform configured
3. If no Web platform exists:
   - Click **+ Add a platform**
   - Select **Web**
   - Add the redirect URIs below

### Step 3: EXACT URIs to Configure

⚠️ **CRITICAL**: Copy these EXACTLY - case-sensitive, no trailing slashes!

```
https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad
```

### Step 4: Additional URIs (Optional but Recommended)

Add these as well for complete functionality:

```
https://cs-connect-dashboard.netlify.app/api/auth/callback/microsoft
https://cs-connect-dashboard.netlify.app/api/auth/signin
https://cs-connect-dashboard.netlify.app/api/auth/error
```

### Step 5: Check for Common Issues

#### ❌ Common Mistakes That Cause AADSTS50011:

1. **Wrong Platform Type**
   - ❌ SPA (Single Page Application)
   - ✅ Web

2. **Case Mismatch**
   - ❌ `/api/auth/callback/Azure-AD`
   - ❌ `/api/auth/callback/AZURE-AD`
   - ✅ `/api/auth/callback/azure-ad` (all lowercase)

3. **Trailing Slash**
   - ❌ `https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad/`
   - ✅ `https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad`

4. **Protocol Mismatch**
   - ❌ `http://cs-connect-dashboard.netlify.app/...`
   - ✅ `https://cs-connect-dashboard.netlify.app/...`

5. **Subdomain Issues**
   - ❌ `https://www.cs-connect-dashboard.netlify.app/...`
   - ✅ `https://cs-connect-dashboard.netlify.app/...`

### Step 6: Save and Wait

1. Click **Save** at the top of the Authentication page
2. Wait **3-5 minutes** for changes to propagate
3. Clear browser cache completely

## 🔍 Verification Checklist

Before testing, verify ALL of these:

- [ ] Platform type is **Web** (not SPA)
- [ ] URI is exactly: `https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad`
- [ ] No trailing slash at the end
- [ ] All lowercase `azure-ad` (not Azure-AD)
- [ ] Protocol is `https://` not `http://`
- [ ] No `www.` subdomain
- [ ] Changes have been **saved** in Azure Portal
- [ ] Waited 3-5 minutes for propagation

## 🚨 If Still Not Working

### Option 1: Check Actual Registered URIs

In Azure Portal, look at the **exact** URIs that are registered:

1. Are there any extra spaces before or after?
2. Is there a duplicate with wrong case?
3. Are they under the correct platform (Web)?

### Option 2: Delete and Re-add

Sometimes Azure AD caches incorrectly:

1. Delete ALL redirect URIs
2. Save (with no URIs)
3. Wait 2 minutes
4. Add the URIs again (copy from above)
5. Save again
6. Wait 5 minutes

### Option 3: Check Application Manifest

1. In Azure Portal, click **Manifest** in the left menu
2. Search for `"replyUrlsWithType"`
3. It should look like:

```json
"replyUrlsWithType": [
    {
        "url": "https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad",
        "type": "Web"
    }
]
```

4. If it doesn't match, edit directly in the manifest
5. Save the manifest

## 📸 What You Should See

In the Authentication page, under **Web** platform:

**Redirect URIs:**

- ✅ `https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad`

**Front-channel logout URL:** (leave empty)

**Implicit grant and hybrid flows:** (uncheck all)

## 🔄 Testing After Configuration

1. **Clear everything:**
   - Browser cache: `Cmd+Shift+Delete`
   - Cookies for all sites
   - Close all browser tabs

2. **Test in incognito/private mode:**
   - Open new incognito window
   - Navigate to: https://cs-connect-dashboard.netlify.app
   - Click "Sign In"

3. **Expected result:**
   - Microsoft login page appears
   - After authentication, redirects back to app
   - No AADSTS50011 error

## 💡 Why This Keeps Happening

The AADSTS50011 error is very strict about exact matches. Even these tiny differences will cause it to fail:

- Extra space: `"https://... "` vs `"https://..."`
- Case difference: `azure-AD` vs `azure-ad`
- Slash: `.../azure-ad/` vs `.../azure-ad`

## 🆘 Emergency Contact

If none of the above works, the issue might be:

1. Azure AD tenant restrictions
2. Conditional access policies
3. Application permissions

In this case, contact your Azure AD administrator with:

- Application ID: `e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3`
- Exact error: AADSTS50011
- Redirect URI needed: `https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad`

---

**Remember:** The URI must match EXACTLY. Even one character difference will cause the error!
