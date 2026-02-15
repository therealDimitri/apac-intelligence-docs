# Security Report: Critical Vulnerabilities Fixed

**Date**: 25 January 2026
**Severity**: Critical
**Status**: Fixed
**Commit**: 0efdcd20

---

## Summary

Code review identified 3 critical security vulnerabilities that have been fixed:

1. **Authentication Bypass in Production** - Dev bypass endpoint was accessible in production
2. **XSS via User-Generated Content** - HTML comments rendered without sanitisation
3. **Unprotected Admin Endpoints** - Admin API routes had no authentication checks

## Vulnerabilities & Fixes

### 1. Authentication Bypass in Production

**Location**: `src/app/api/auth/dev-bypass/route.ts`

**Problem**: The `/api/auth/dev-bypass` endpoint was intentionally left enabled in production with a comment stating it was needed while waiting for Azure AD admin approval. This allowed anyone to authenticate as a hardcoded user without credentials.

Additionally, the endpoint exposed `SUPABASE_ANON_KEY` in the response body.

**Risk**: Complete authentication bypass - any user who discovered this endpoint could authenticate without credentials.

**Fix**:
- Added production environment check that returns 403 Forbidden
- Removed sensitive keys from response body
- Set `secure: false` on cookie (development-only endpoint)

```typescript
// SECURITY: Only allow bypass in development mode
if (process.env.NODE_ENV === 'production') {
  console.warn('[AUTH BYPASS] Attempted access in production - blocked')
  return NextResponse.json(
    { error: 'This endpoint is disabled in production' },
    { status: 403 }
  )
}
```

### 2. XSS via User-Generated Content

**Location**: `src/components/comments/CommentItem.tsx:198`

**Problem**: Comment content (stored as HTML from TipTap rich text editor) was rendered directly without any sanitisation, allowing stored XSS attacks.

**Risk**: Attackers could inject malicious scripts through comment content that would execute in other users' browsers.

**Fix**:
- Created `src/lib/sanitise-html.ts` using DOMPurify
- Configured allowlist of safe HTML tags and attributes
- Updated CommentItem to sanitise content before rendering

**Sanitisation Configuration**:
- Allowed tags: Text formatting, headings, lists, links, tables
- Forbidden tags: `script`, `style`, `iframe`, `object`, `embed`, `form`, `input`
- Forbidden attributes: `onerror`, `onload`, `onclick`, `onmouseover`, etc.

### 3. Unprotected Admin Endpoints

**Location**: `src/app/api/admin/*` (17 routes)

**Problem**: Admin endpoints that execute database migrations, run SQL, and manage system configuration had no authentication checks. The proxy.ts file only handled general authentication but didn't specifically protect admin routes.

**Risk**: Unauthenticated users could potentially execute database migrations or access sensitive admin functionality.

**Fix**: Updated `src/proxy.ts` to add explicit protection for admin routes with session validation.

## Additional Fix: Debug Mode

**Location**: `src/auth.ts:480`

**Problem**: NextAuth debug mode was unconditionally enabled (`debug: true`), potentially exposing sensitive information in production logs.

**Fix**: Made debug mode environment-conditional:

```typescript
debug: process.env.NODE_ENV === 'development',
```

## Files Changed

1. `src/app/api/auth/dev-bypass/route.ts` - Block production access
2. `src/lib/sanitise-html.ts` - New DOMPurify sanitisation utility
3. `src/components/comments/CommentItem.tsx` - Use sanitisation
4. `src/proxy.ts` - Add admin route protection
5. `src/auth.ts` - Conditional debug mode
6. `package.json` - Add @types/dompurify

## Verification

- [x] Build passes (`npm run build`)
- [x] All 56 tests pass (`npm test`)
- [x] Deployed to Netlify
- [x] Manual testing of dev-bypass endpoint in production (returns 403)

## Recommendations

1. **Regular Security Reviews**: Schedule periodic code reviews focusing on security
2. **Security Testing**: Add E2E tests for authentication bypass attempts
3. **Rate Limiting**: Upgrade in-memory rate limiting to Redis for production
4. **XSS Audit**: Review all uses of innerHTML rendering in codebase
