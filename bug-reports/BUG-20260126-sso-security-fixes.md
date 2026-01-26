# Bug Report: SSO Security Vulnerabilities Fixed

**Date:** 2026-01-26
**Severity:** Critical
**Status:** Resolved
**Component:** Authentication System (`auth.ts`, `middleware.ts`, `team-bypass/route.ts`)

---

## Summary

Security review identified three critical vulnerabilities in the SSO authentication system that could expose sensitive data or allow unauthorised access:

1. Debug logging enabled in production
2. Admin routes lack JWT signature validation
3. Team bypass missing rate limiting and input sanitisation

---

## Vulnerabilities Identified

### 1. Debug Mode Enabled in Production (Critical)

**File:** `src/auth.ts:483`

**Before (Vulnerable):**
```typescript
// Enable debug logging in both dev and production for SSO troubleshooting
// TODO: Disable debug after SSO issue is resolved
debug: true,
```

**Risk:** NextAuth debug mode logs sensitive information including:
- Access tokens and refresh tokens
- Session data and user information
- OAuth state and PKCE verifiers
- Full error stack traces

This data would appear in server logs (Netlify Functions logs), potentially accessible to anyone with log access.

**After (Fixed):**
```typescript
// Debug logging - only enabled in development to prevent sensitive data leakage
// SECURITY: Never enable debug in production - it logs tokens, secrets, and session data
debug: process.env.NODE_ENV === 'development',
```

---

### 2. Admin Routes Missing JWT Validation (Critical)

**File:** `src/middleware.ts:71-82`

**Before (Vulnerable):**
```typescript
if (adminPaths.some(path => pathname.startsWith(path))) {
  if (!hasSessionCookie) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }
  return NextResponse.next()  // Only checks cookie existence!
}
```

**Risk:** An attacker could forge a session cookie with any value. The middleware only checked if a cookie named `authjs.session-token` existed, not whether it contained a valid, signed JWT.

**After (Fixed):**
```typescript
if (adminPaths.some(path => pathname.startsWith(path))) {
  if (!hasSessionCookie) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  // SECURITY: Validate JWT signature for admin endpoints
  const sessionToken = getSessionToken(allCookies)
  if (sessionToken) {
    const isValid = await validateJwtSignature(sessionToken)
    if (!isValid) {
      console.warn(`[Middleware] Invalid JWT signature for admin access: ${pathname}`)
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }
  }

  return NextResponse.next()
}
```

Added helper functions:
- `getSessionToken()` - Extracts token from cookies (handles both prefixes and chunked cookies)
- `validateJwtSignature()` - Uses `jose` library to verify HMAC-SHA256 signature with `NEXTAUTH_SECRET`

---

### 3. Team Bypass Security Hardening (Medium)

**File:** `src/app/api/auth/team-bypass/route.ts`

**Issues Fixed:**

| Issue | Risk | Fix |
|-------|------|-----|
| No rate limiting | Brute force attacks | Added 5 attempts per minute per IP |
| Weak email validation | Injection/bypass | Added regex validation |
| Name injection risk | XSS via logs/display | Added sanitisation, removed `<>` |
| Token in response body | Token exposure in network logs | Removed token from response |
| Wrong cookie prefix | Sessions not recognised | Changed to `authjs.session-token` |
| Development secret fallback | Weak signing in production | Error if no `NEXTAUTH_SECRET` in production |

**Key Changes:**
```typescript
// Rate limiting
if (!checkRateLimit(ip)) {
  return createErrorResponse('RATE_LIMITED', 'Too many authentication attempts.', 429)
}

// Strict email validation
const emailRegex = /^[a-zA-Z0-9._%+-]+@alterahealth\.com$/i
if (!emailRegex.test(email)) {
  return createErrorResponse('VALIDATION_ERROR', 'Invalid email format.', 400)
}

// Name sanitisation
const sanitisedName = name.trim().replace(/[<>]/g, '')

// Production secret requirement
if (!secret && process.env.NODE_ENV === 'production') {
  return createErrorResponse('SERVER_ERROR', 'Authentication service unavailable.', 500)
}

// Correct cookie prefix for NextAuth v5
const cookieName = isProduction ? '__Secure-authjs.session-token' : 'authjs.session-token'
```

---

## Files Modified

| File | Changes |
|------|---------|
| `src/auth.ts` | Conditional debug logging based on NODE_ENV |
| `src/middleware.ts` | Added JWT signature validation for admin routes, helper functions |
| `src/app/api/auth/team-bypass/route.ts` | Rate limiting, input validation, correct cookie prefix |

---

## Testing

### Manual Verification:

1. **Debug Logging:**
   - Deploy to production
   - Trigger OAuth flow
   - Check Netlify function logs - should NOT contain tokens or session data

2. **JWT Validation:**
   - Create a forged cookie: `document.cookie = "authjs.session-token=fake.token.here"`
   - Attempt to access `/api/admin/data-sync`
   - Should receive 401 Unauthorized

3. **Rate Limiting:**
   - Attempt 6+ team bypass logins within 60 seconds
   - 6th attempt should return 429 Too Many Requests

4. **Input Sanitisation:**
   - Submit name with `<script>` tags via team bypass
   - Verify tags are stripped from saved name

---

## Security Recommendations (Future)

1. **Add audit logging** for admin endpoint access
2. **Consider IP allowlisting** for admin endpoints
3. **Implement session rotation** on privilege escalation
4. **Add CAPTCHA** to team bypass if abuse is detected
5. **Review and remove** team bypass once Azure AD SSO is stable

---

## Related

- SSO Configuration: `docs/bugs/BUG-2026-01-25-SSO-Configuration-Error.md`
- Auth Configuration: `src/auth.ts`
- Middleware: `src/middleware.ts`
