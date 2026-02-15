# Bug Report: AADSTS50011 Persistent Redirect URI Mismatch

**Date:** November 26, 2025
**Component:** Azure AD SSO Authentication
**Error Code:** AADSTS50011
**Severity:** CRITICAL - BLOCKING
**Status:** UNRESOLVED - Requires Azure AD Admin Action

## Executive Summary

Despite multiple code fixes and deployment attempts, the AADSTS50011 error persists. The application is correctly sending the redirect URI `https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad`, which the user has confirmed is registered in Azure AD. This indicates an Azure AD configuration issue rather than a code problem.

## Current Status

### Error Details

```
AADSTS50011: The redirect URI 'https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad'
specified in the request does not match the redirect URIs configured for the
application 'e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3'.
```

### What's Been Done

#### Code Fixes Deployed (All Completed)

1. **Commit 4d1e188:** Added proxy-aware authentication with trustHost: true
2. **Commit 8e6e1ef:** Removed explicit redirect_uri to let NextAuth handle automatically
3. **Commit 2d1f0d9:** Added explicit provider ID and redirect callback

#### Configuration Verified

- ✅ NEXTAUTH_URL correctly set to `https://cs-connect-dashboard.netlify.app`
- ✅ Provider ID explicitly set to "azure-ad"
- ✅ Trust host enabled for proxy headers
- ✅ Redirect callback implemented for URL consistency
- ✅ Debug mode enabled

#### URI Being Sent (Confirmed Correct)

```
https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad
```

## Root Cause Analysis

### The Code is Working Correctly

Evidence that the application code is functioning properly:

1. Error progressed from AADSTS900971 (no redirect URI) to AADSTS50011 (URI mismatch)
2. The exact URI in the error matches what we expect
3. No trailing slashes, correct case, proper protocol
4. Deployment successful and changes verified in git

### The Issue is in Azure AD Configuration

Despite user confirmation that the URI is registered, Azure AD is still rejecting it. Possible causes:

#### 1. Platform Type Mismatch

- **Common Issue:** URI registered under SPA instead of Web platform
- **Required:** Must be under **Web** platform configuration
- **Check:** Azure Portal → Authentication → Platform configurations

#### 2. Exact Character Mismatch

Even tiny differences cause failure:

- Extra space: `"https://...azure-ad "` (space at end)
- Case difference: `azure-AD` vs `azure-ad`
- Hidden characters: Copy/paste from some sources adds invisible characters

#### 3. Multiple App Registrations

- The app ID `e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3` might have duplicates
- URIs might be registered in a different app registration
- Check all app registrations in the tenant

#### 4. Manifest Sync Issues

- Azure Portal UI and manifest can get out of sync
- Direct manifest editing might be required

## Recommended Actions

### Immediate Actions (For Azure AD Admin)

1. **Verify Exact Configuration**

   ```
   Platform: Web (NOT SPA)
   Redirect URI: https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad
   No trailing slash, all lowercase, no spaces
   ```

2. **Delete and Re-add URIs**
   - Remove all redirect URIs
   - Save with empty configuration
   - Wait 2 minutes
   - Add URIs again (copy exactly from above)
   - Save and wait 5 minutes

3. **Check Application Manifest**
   - Navigate to Manifest in Azure Portal
   - Search for `"replyUrlsWithType"`
   - Verify it contains:

   ```json
   {
     "url": "https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad",
     "type": "Web"
   }
   ```

4. **Check for Duplicates**
   - Search all app registrations for this app ID
   - Verify no conflicting configurations exist

### If Still Failing

#### Option 1: Create New App Registration

- Create fresh app registration
- Configure redirect URIs correctly from start
- Update application with new client ID

#### Option 2: Check Tenant Restrictions

- Conditional access policies might be blocking
- IP restrictions might be in place
- Contact Azure AD administrator

#### Option 3: Try Alternative Callback Path

- Register: `https://cs-connect-dashboard.netlify.app/api/auth/callback/microsoft`
- Update code to use "microsoft" as provider ID instead of "azure-ad"

## Files Created During Troubleshooting

1. `AZURE-AD-REDIRECT-URI-FIX.md` - Initial configuration guide
2. `PROXY-AUTH-VERIFICATION-GUIDE.md` - Testing guide
3. `AZURE-AD-CRITICAL-CONFIGURATION-FIX.md` - Detailed fix instructions
4. `check-auth-config.js` - Diagnostic script
5. Multiple bug reports documenting each fix attempt

## Timeline of Events

1. **Initial Error:** AADSTS900971 - No reply address provided
2. **Fix Applied:** Proxy-aware configuration
3. **New Error:** AADSTS50011 - Redirect URI mismatch
4. **User Feedback:** URIs already configured in Azure AD
5. **Multiple Fixes:** Provider ID, redirect callback, etc.
6. **Current Status:** Error persists despite all code fixes

## Conclusion

The application code is correctly configured and sending the proper redirect URI. The persistent AADSTS50011 error indicates an Azure AD configuration issue that requires administrative action in the Azure Portal. The exact URI being sent matches what should be registered, suggesting a platform type mismatch, hidden character issue, or manifest sync problem in Azure AD.

## Next Steps

1. **Azure AD Admin Action Required:** Follow the recommended actions above
2. **Alternative:** Create new app registration with correct configuration
3. **Last Resort:** Contact Microsoft support with app ID and error details

---

**Status:** Awaiting Azure AD configuration correction
**Code Status:** All fixes deployed and verified
**Blocker:** Azure AD configuration mismatch
