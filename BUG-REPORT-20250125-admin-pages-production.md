# Bug Report: Admin Pages Not Displaying in Production

**Date:** 25 January 2026
**Status:** Partially Resolved
**Severity:** High (Admin functionality blocked)

## Summary

Admin pages were not loading in production, displaying "Failed to fetch" errors while working correctly in development.

## Symptoms

1. Admin API endpoints returning 401 Unauthorized in production
2. User Management page showing "Unauthorized" alert
3. Data Quality, Data Sync, Audit Log pages not loading data
4. Console errors: `Failed to load resource: 401`

## Root Cause

The Next.js middleware file was incorrectly named `proxy.ts` instead of `middleware.ts`. Next.js only loads middleware from files named `middleware.ts` (or `.js`), so the authentication middleware was not running at all.

**Commit that caused the issue:** `07ba4d49` - renamed `src/middleware.ts` → `src/proxy.ts`

## Files Modified

| File | Changes |
|------|---------|
| `src/proxy.ts` → `src/middleware.ts` | Renamed back to correct filename |
| `src/middleware.ts` | Simplified auth logic to use cookie presence check |

## Solution

### Fix 1: Rename middleware file
```bash
mv src/proxy.ts src/middleware.ts
```

### Fix 2: Simplified middleware logic
The original middleware called `auth()` from NextAuth in Edge runtime, which doesn't work correctly because Edge middleware doesn't have access to the full request context.

Changed to simple cookie presence check:
```typescript
// Check for session cookies
const devSession = request.cookies.get('next-auth.session-token')
const secureSession = request.cookies.get('__Secure-next-auth.session-token')
const hasSessionCookie = !!(devSession || secureSession)

if (hasSessionCookie) {
  return NextResponse.next()
}
```

## Related Issue: SSO Failing

During testing, discovered that Azure AD SSO sign-in is failing with error:
```
"There is a problem with the Azure AD configuration"
Error code: Configuration
```

This is a **separate issue** that needs investigation:
- Check Netlify environment variables for Azure AD credentials
- Verify NEXTAUTH_URL is set correctly
- Check NEXTAUTH_SECRET is configured
- Review Azure AD app registration in Azure Portal

## Testing

1. ✅ Middleware file renamed and recognized by Next.js build
2. ✅ Build shows "ƒ Proxy (Middleware)" in output
3. ⚠️ SSO sign-in failing (separate issue)
4. ⏳ Admin pages need testing with valid session

## Commits

- `533d0855` - Fix admin pages not loading in production (rename)
- `dc1ad064` - Fix middleware auth check for Edge runtime
- `41706726` - Simplify middleware for production stability

## Prevention

- Never rename `middleware.ts` to anything else
- Middleware must be at project root or in `src/` directory
- Test authentication flows after any middleware changes
- Add middleware presence check to CI/CD pipeline
