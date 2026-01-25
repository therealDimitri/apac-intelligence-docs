# Bug Report: SSO Configuration Error After Azure AD Changes

**Date**: 2026-01-25
**Priority**: Critical
**Status**: Workaround Deployed

## Summary

Azure AD SSO authentication fails with "Configuration" error after Azure AD app settings were modified during debugging.

## Root Cause

Azure AD is redirecting the OAuth authorization code to the wrong URL:
- **Expected**: `https://apac-cs-dashboards.com/api/auth/callback/azure-ad?code=...`
- **Actual**: `https://apac-cs-dashboards.com/?code=...` (bare root path)

This causes PKCE verification to fail because:
1. Azure AD redirects code to wrong URL after MFA (DeviceAuthTls/reprocess flow)
2. Middleware intercepts and redirects to callback URL
3. But PKCE verifier cookie isn't available at the new URL
4. Token exchange fails with "Configuration" error

## Azure AD Changes Made During Debugging

1. **Unchecked "ID tokens (used for implicit and hybrid flows)"** - This may affect the OAuth flow
2. App was tagged as `singlePageApp` which has different redirect behavior

## Fix Required (Azure AD Portal)

1. Go to **Azure AD Portal** → **App Registrations** → **CS Connect Dashboard - Auth**
2. Navigate to **Authentication** section
3. **RE-ENABLE "ID tokens (used for implicit and hybrid flows)"**
4. Verify platform is configured as **"Web"** (not SPA)
5. Verify redirect URIs include:
   - `https://apac-cs-dashboards.com/api/auth/callback/azure-ad`

## Workaround Deployed

Team bypass authentication is now visible to all users on the signin page. Users can access the dashboard using secure team authentication while the Azure AD configuration is being fixed.

## Technical Details

### Middleware Fix Attempted
Added middleware to intercept OAuth code at root path and redirect to callback:
```typescript
if (pathname === '/' && searchParams.has('code') && (searchParams.has('state') || searchParams.has('session_state'))) {
  const callbackUrl = new URL('/api/auth/callback/azure-ad', request.url)
  searchParams.forEach((value, key) => callbackUrl.searchParams.set(key, value))
  return NextResponse.redirect(callbackUrl)
}
```

### Provider Migration
Migrated from deprecated `AzureADProvider` to `MicrosoftEntraID` provider for NextAuth v5 compatibility.

### Environment Variables Verified
- `AZURE_AD_CLIENT_ID`: e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3 ✓
- `AZURE_AD_TENANT_ID`: d4066c36-17ca-4e33-95d2-0db68e44900f ✓
- `AZURE_AD_CLIENT_SECRET`: DGy8Q~... (APAC Intelligence Hub - Production) ✓
- `NEXTAUTH_URL`: https://apac-cs-dashboards.com ✓
- `NEXTAUTH_SECRET`: Set ✓

## Commits Related to This Issue

- `5a78b65c` - Fix OAuth redirect: intercept misdirected code at root path
- `11ca7e7e` - Fix OAuth intercept: check for session_state, not just state
- `d3b5c9d3` - Add client-side fallback for misdirected OAuth code
- `61f4717b` - Switch to MicrosoftEntraID provider (non-deprecated)
- `20ddb5c8` - Enable team bypass button for all users during SSO issues

## Resolution

Awaiting user to restore Azure AD settings (re-enable ID tokens).
