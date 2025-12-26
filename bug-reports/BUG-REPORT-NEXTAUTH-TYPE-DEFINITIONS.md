# Bug Report: NextAuth Type Definitions Missing

**Date**: 2025-11-28
**Severity**: Critical
**Status**: Fixed
**Impact**: Production build failing - deployment blocked

---

## Issue Summary

Production build was failing with TypeScript compilation error when attempting to deploy the organisation search restoration changes. The error occurred in the newly created `/api/organisation/people` endpoint.

---

## Error Message

```
./src/app/api/organisation/people/route.ts:25:19
Type error: Property 'accessToken' does not exist on type 'Session'.

  23 |     const session = await auth()
  24 |
> 25 |     if (!session?.accessToken) {
     |                   ^
  26 |       console.log('[API /organisation/people] No access token - returning 401')
  27 |       return NextResponse.json(
  28 |         { error: 'Not authenticated. Please sign in.' },
```

---

## Root Cause Analysis

### Problem: TypeScript Type Mismatch

**Root Cause**: NextAuth v5's default `Session` interface doesn't include `accessToken` property, even though our auth.ts configuration adds it to the session object in the session callback.

**Why This Failed**:

- In `src/auth.ts`, the `session` callback returns an object with `accessToken`:
  ```typescript
  async session({ session, token }: any) {
    return {
      ...session,
      accessToken: token.accessToken,  // ← Added at runtime
      error: token.error,
      user: { ...session.user }
    }
  }
  ```
- TypeScript doesn't know about these runtime additions
- When `/api/organisation/people/route.ts` tries to access `session.accessToken`, TypeScript throws compilation error
- This blocks production builds

**Why It Worked in Development**:

- Development mode uses looser type checking
- `any` types are sometimes inferred
- Runtime JavaScript works fine - it's purely a TypeScript compile-time issue

---

## Solution

### Created TypeScript Declaration File

**File**: `src/types/next-auth.d.ts`

Used **TypeScript declaration merging** to extend NextAuth's module types:

```typescript
import { DefaultSession } from 'next-auth'

declare module 'next-auth' {
  interface Session {
    accessToken?: string
    error?: string
    user: {
      email?: string | null
      name?: string | null
      image?: string | null
    } & DefaultSession['user']
  }
}

declare module 'next-auth/jwt' {
  interface JWT {
    accessToken?: string
    refreshToken?: string
    accessTokenExpires?: number
    error?: string
  }
}
```

### How Declaration Merging Works

1. **TypeScript sees existing `Session` interface** in `next-auth` module
2. **Merges our new properties** into the existing interface
3. **TypeScript now knows** that `Session` objects can have `accessToken` and `error` properties
4. **Compilation succeeds** because types align with runtime behavior

---

## Files Changed

### Created

- `src/types/next-auth.d.ts` - TypeScript type declarations for NextAuth extensions

### Verified (No Changes Needed)

- `src/auth.ts` - Already adds accessToken to session (lines 115-126)
- `src/app/api/organisation/people/route.ts` - Now compiles correctly

---

## Testing Results

### Before Fix

```bash
npm run build

❌ Failed to compile.

./src/app/api/organisation/people/route.ts:25:19
Type error: Property 'accessToken' does not exist on type 'Session'.
```

### After Fix

```bash
npm run build

✓ Compiled successfully in 1681.4ms
✓ Running TypeScript ...
✓ Collecting page data ...
✓ Generating static pages (20/20)

Route (app)
├ ƒ /api/organisation/people  ← Now compiles successfully
└ ... (all 20 routes generated)
```

---

## Why This Issue Occurred

### Timeline of Events

1. **Initial Code** (months ago): Used dev-mode authentication that didn't require Microsoft Graph
2. **Previous Fix** (earlier): Added People.Read permission, restored organisation search
3. **Today's Deployment**: Pushed organisation search restoration changes
4. **Build Failure**: TypeScript found the type mismatch

The issue **wasn't present before** because:

- The `/api/organisation/people` route was using a deprecation notice (not accessing session.accessToken)
- We just restored the full implementation that accesses `session.accessToken`
- This is the **first production build** since adding that access

---

## Impact

### Before Fix

- ❌ Production builds failing
- ❌ Deployment blocked
- ❌ Organization search can't be deployed
- ❌ Users can't benefit from People.Read permission

### After Fix

- ✅ Production build succeeds (1.6s compile)
- ✅ TypeScript compilation passes
- ✅ All 20 routes generated
- ✅ Deployment unblocked
- ✅ Organization search ready for production

---

## Prevention Strategies

### 1. Always Extend Types When Augmenting Objects

**Pattern**: If you add properties to objects in callbacks, extend the TypeScript types:

```typescript
// ❌ Don't just add properties without types
async session({ session, token }) {
  return { ...session, customProp: token.value }  // TypeScript doesn't know!
}

// ✅ Do extend the types
// In auth.ts:
async session({ session, token }) {
  return { ...session, customProp: token.value }
}

// In types/next-auth.d.ts:
declare module "next-auth" {
  interface Session {
    customProp?: string
  }
}
```

### 2. Test Production Builds Locally

Before pushing:

```bash
npm run build  # Catches TypeScript errors before deployment
```

### 3. Use Strict TypeScript Config

Ensure `tsconfig.json` has:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true
  }
}
```

### 4. Document Type Extensions

When extending third-party library types, add comments explaining why:

```typescript
// Extends NextAuth Session to include Microsoft Graph access token
// Added by auth.ts session callback (line 118)
interface Session {
  accessToken?: string // Microsoft Graph API access token
  error?: string // Auth error (e.g., "RefreshAccessTokenError")
}
```

---

## Related Issues

- Original organisation search worked before People.Read permission was granted
- This is the **first production build** since enabling Microsoft Graph integration
- Similar pattern exists in other API routes using `session.accessToken`:
  - `/api/outlook/events` - Already had access token handling
  - `/api/user/photo` - Already had access token handling

Those routes likely worked because they used `any` types or the production builds weren't run since they were added.

---

## Commits

1. **6918851** - feat: restore organisation search with People.Read permission
   - Added organisation search code
   - Triggered TypeScript error on build

2. **6b21def** - fix: add NextAuth type definitions for accessToken
   - Created src/types/next-auth.d.ts
   - Extended Session and JWT interfaces
   - Fixed TypeScript compilation
   - Unblocked deployment

---

## Deployment Notes

### Netlify Auto-Deployment

After pushing commit `6b21def`:

1. Netlify detects new commit on `main` branch
2. Runs `npm run build` in cloud environment
3. Build succeeds (1.6s compile)
4. Deployment completes successfully
5. Changes live at https://apac-cs-dashboards.com

### User Actions Required

After successful deployment, users must:

1. **Sign out** of the application
2. **Sign back in** with Azure AD
3. Get new access token with People.Read scope
4. Test organisation search in meeting scheduler

---

## Conclusion

**Issue**: TypeScript compilation error blocking deployment due to missing type definitions
**Root Cause**: NextAuth Session type not extended to include accessToken property
**Solution**: Created type declaration file using TypeScript module augmentation
**Result**: ✅ Build succeeds, deployment unblocked, organisation search ready for production

**Status**: Fixed and deployed successfully
