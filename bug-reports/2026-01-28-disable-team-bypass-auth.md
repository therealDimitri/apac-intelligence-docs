# Security Fix: Disable Team Bypass Authentication

**Date:** 2026-01-28
**Type:** Security Hardening
**Status:** Completed & Deployed
**Author:** Claude Opus 4.5

---

## Summary

Disabled the team-bypass authentication route (`/api/auth/team-bypass`) because it accepted any `@alterahealth.com` email address without verifying the account exists or is active in Azure AD. Now that Azure AD OAuth is fully operational, the bypass is no longer needed.

## Security Issue

The team-bypass route validated only:
1. Email ends with `@alterahealth.com` (domain check)
2. Email matches a basic regex format
3. Rate limiting (5 attempts/minute/IP)

It did **not** verify:
- Whether the email corresponds to an active Azure AD account
- Whether the employee is still with the organisation
- Any form of multi-factor authentication

This meant any string matching `*@alterahealth.com` — including former employees, typos, or fabricated addresses — would receive a valid encrypted JWE session.

## Changes Made

### File 1: `src/app/api/auth/team-bypass/route.ts`
- Replaced entire route with a stub that returns 403 "disabled" for all requests
- Removed all session creation, rate limiting, and role determination code

### File 2: `src/app/auth/signin/page.tsx`
- Removed the "Team Authentication (Altera Employees Only)" button
- Removed the "Alternative Sign-In Available" info box
- Removed the `handleTeamBypass` function
- Sign-in page now only shows the Azure AD SSO button

### File 3: `src/app/auth/bypass/page.tsx`
- Replaced the authentication form with a "Team Bypass Disabled" message
- Added a link back to the SSO sign-in page

### File 4: `src/lib/session-validator.ts`
- Removed legacy plain JWT verification fallback (`verifyBypassToken`)
- Removed `getSessionToken` helper (no longer needed)
- Removed `jsonwebtoken` import
- Simplified `validateSession()` to NextAuth-only flow
- `isBypassSession` now always returns `false`

### File 5: `src/auth.ts`
- Removed `bypassAuth` flag passthrough from session callback
- Removed `isBypassSession` from session callback debug log

## Re-enabling

If Azure AD experiences another outage and bypass is needed again, restore from git commit `f1c4a031` which contains the working JWE-encrypted bypass implementation.

## Commits

- `6c081ee5` — Disable team-bypass authentication for security
