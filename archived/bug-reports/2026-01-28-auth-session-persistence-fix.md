# Bug Report: Auth Session Persistence on Production (Netlify)

**Date:** 2026-01-28
**Type:** Bug Fix
**Status:** Completed & Deployed
**Author:** Claude Opus 4.5

---

## Summary

Auth sessions created via team-bypass authentication were dropping on page navigation in production (Netlify). Users could sign in successfully but were redirected back to the signin page when navigating between pages.

## Root Cause

The team-bypass API route (`/api/auth/team-bypass`) was creating **plain JWT tokens** (signed with `jsonwebtoken` using HS256), but NextAuth v5 (`@auth/core`) expects **encrypted JWE tokens** (A256CBC-HS512).

### What happened:

1. User signs in via team-bypass -> plain JWT stored in `__Secure-authjs.session-token` cookie
2. Dashboard loads -> middleware sees cookie (presence check only) -> allows access
3. `SessionProvider` calls `/api/auth/session` -> NextAuth tries to decrypt cookie as JWE -> **fails** -> returns null session
4. NextAuth **overwrites the cookie** with a new empty/invalid JWE token
5. Next navigation -> middleware doesn't find valid cookie -> redirects to signin

### Why it worked on localhost (sometimes):

- Development mode uses different cookie prefix (`authjs.session-token` vs `__Secure-authjs.session-token`)
- Dev-login credentials provider creates proper NextAuth JWE sessions
- The race condition between SessionProvider's `/api/auth/session` call and the cookie overwrite was less noticeable with faster local responses

## Fix Applied

### File 1: `src/app/api/auth/team-bypass/route.ts`

Replaced `jsonwebtoken` (plain JWT) with `@auth/core/jwt` `encode()` function to create proper encrypted JWE tokens that NextAuth can decode.

**Before:**
```typescript
import jwt from 'jsonwebtoken'
const token = jwt.sign({ sub, email, name, bypassAuth: true, ... }, secret, { algorithm: 'HS256' })
```

**After:**
```typescript
import { encode } from '@auth/core/jwt'
const token = await encode({
  token: { sub, email, name, bypassAuth: true, ... },
  secret,
  salt: cookieName, // Must match cookie name for decryption
  maxAge: 86400,    // 24 hours
})
```

### File 2: `src/auth.ts`

Added `bypassAuth` flag passthrough in the session callback so consumers can distinguish bypass vs OAuth sessions.

### File 3: `src/lib/session-validator.ts`

Updated documentation and `validateSession()` to detect bypass sessions from the decoded token's `bypassAuth` claim. Kept legacy plain JWT verification as a fallback for any old tokens still in circulation.

## Verification

- **localhost:** Signed in via team-bypass, navigated `/` -> `/client-profiles` -> `/meetings` — session persisted across all navigations
- **Build:** `npm run build` passed cleanly
- **Production:** Deployed via git push to Netlify

## Key Insight

NextAuth v5 uses JWE (JSON Web Encryption) not just JWS (JSON Web Signature) for session tokens. The `salt` parameter in `encode()` must match the cookie name because it's used to derive the encryption key. Any token not encrypted with the same algorithm and salt will be unreadable by NextAuth and will be overwritten, effectively logging the user out.

## Commits

- `f1c4a031` — Fix auth session persistence: use NextAuth JWE encoding for team-bypass tokens
