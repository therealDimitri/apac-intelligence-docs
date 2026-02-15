# Bug Report: Development Authentication Cookie Issue

## Issue Summary

Pages were loading but redirecting to `/auth/dev-signin` preventing data from being displayed. The authentication middleware was not recognising the session cookies set by the dev-login API route.

## Date Reported

November 26, 2025

## Severity

**Critical** - All authenticated pages were inaccessible, preventing any data from being displayed

## Affected Components

- All dashboard pages (`/clients`, `/nps`, `/meetings`, `/actions`, `/ai`)
- Authentication middleware (`src/middleware.ts`)
- Dev login API route (`src/app/api/auth/dev-login/route.ts`)
- Dev signin page (`src/app/auth/dev-signin/page.tsx`)

## Root Cause

Multiple issues with the development authentication flow:

1. **Cookie Persistence Timing**: The client-side redirect was happening before cookies were fully persisted
2. **Single Cookie Dependency**: Middleware only checked for `next-auth.session-token` which was sometimes not persisting correctly
3. **Immediate Redirect**: No delay between cookie setting and navigation

### Problematic Flow

1. User submits login form
2. API sets `next-auth.session-token` cookie
3. Client immediately redirects with `window.location.href`
4. Middleware checks for cookie (not yet persisted)
5. User redirected back to signin page

## Error Messages

```
GET /auth/dev-signin?callbackUrl=%2Fclients 200
GET /auth/dev-signin?callbackUrl=%2Fnps 200
GET /auth/dev-signin?callbackUrl=%2Fmeetings 200
```

## Fix Applied

### 1. Added Additional Cookie Check (src/middleware.ts:23)

```typescript
// Check for multiple session cookies
const devSession = request.cookies.get('next-auth.session-token')
const devAuthSession = request.cookies.get('dev-auth-session') // NEW
const authSession = request.cookies.get('__Secure-next-auth.session-token')

if (devSession || devAuthSession || authSession) {
  return NextResponse.next()
}
```

### 2. Set Dual Cookies (src/app/api/auth/dev-login/route.ts:46-53)

```typescript
// Set the main session token
cookieStore.set('next-auth.session-token', token, {
  httpOnly: true,
  secure: false,
  sameSite: 'lax',
  path: '/',
  maxAge: 60 * 60 * 24,
})

// Set a simpler dev auth session cookie (NEW)
cookieStore.set('dev-auth-session', email, {
  httpOnly: true,
  secure: false,
  sameSite: 'lax',
  path: '/',
  maxAge: 60 * 60 * 24,
})
```

### 3. Added Redirect Delay (src/app/auth/dev-signin/page.tsx:31-34)

```typescript
if (response.ok) {
  const params = new URLSearchParams(window.location.search)
  const callbackUrl = params.get('callbackUrl') || '/'

  // Small delay to ensure cookies are set (NEW)
  setTimeout(() => {
    window.location.href = callbackUrl
  }, 100)
}
```

## Impact

### Before Fix

- All pages redirecting to `/auth/dev-signin`
- No data visible on any dashboard page
- Continuous authentication loop
- User reported: "most pages are foucing and I cant see data"

### After Fix

- All pages loading successfully (200 status)
- Authentication persists correctly
- Data loading properly on all pages
- Server logs confirm: `GET /clients 200`, `GET /nps 200`, etc.

## Testing Verification

```bash
# Server logs showing successful page loads after fix
GET /clients 200 in 75ms
GET /nps 200 in 171ms
GET /meetings 200 in 174ms
GET /actions 200 in 163ms
GET /ai 200 in 175ms
```

## Lessons Learned

1. **Cookie Persistence**: Always add a small delay after setting cookies before navigation
2. **Multiple Fallbacks**: Use multiple cookie names for better reliability in development
3. **Middleware Checks**: Check for multiple possible session indicators
4. **Client-Server Timing**: Account for asynchronous cookie setting in browser

## Related Enhancements

This issue occurred after implementing:

- Client-side caching with TTL
- Pagination for meetings
- Real-time subscriptions
- Actual NPS calculations

## Prevention

To prevent similar issues in the future:

1. Test authentication flow thoroughly after any middleware changes
2. Use multiple session indicators for development authentication
3. Add proper delays for cookie persistence
4. Consider using server-side redirects instead of client-side
5. Test with browser dev tools network throttling to catch timing issues
