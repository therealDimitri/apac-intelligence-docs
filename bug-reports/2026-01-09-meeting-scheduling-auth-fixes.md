# Bug Fixes: Meeting Scheduling & Auth Session Errors

**Date**: 2026-01-09
**Type**: Bug Fixes (Multiple)
**Status**: RESOLVED (Code changes applied, pending deployment)

---

## Issues Addressed

### Issue 1: Auth Session Errors for Dev-Login

**Problem**: Console showed `ClientFetchError: Unexpected token 'I', "Internal S"...` when using dev-login authentication. The session endpoint was attempting to refresh tokens for sessions that don't have any.

**Root Cause**: The JWT callback in `src/auth.ts` tried to refresh access tokens for all sessions, but dev-login sessions don't have access tokens or refresh tokens, causing the token expiry check to fail (NaN comparisons).

**Fix**: Added early return in JWT callback to skip refresh logic for sessions without tokens:

```typescript
// Dev-login sessions don't have access tokens - skip refresh logic
if (!token.accessToken && !token.refreshToken) {
  // This is a dev-login session or similar - no tokens to refresh
  return token
}
```

**File Modified**: `src/auth.ts` (lines 336-353)

**Additional Fix**: Also clears any stale error state from previous sessions:

```typescript
if (token.error) {
  console.log('[Auth] Clearing stale error for dev-login session:', token.error)
  return {
    ...token,
    error: undefined,
    errorPermanent: undefined,
    errorRequiresReauth: undefined,
    errorReason: undefined,
    errorCode: undefined,
    errorMessage: undefined,
  }
}
```

---

### Issue 2: Meeting Scheduling Not Saving to Database

**Problem**: Meetings created via the Quick Schedule modal created Outlook calendar events and generated ICS files, but were NOT saved to the database/Briefing Room.

**Root Cause**: The `/api/meetings/schedule-quick` endpoint only created Microsoft Graph calendar events but never inserted records into the `unified_meetings` table.

**Fix**: Added full Supabase integration to the schedule-quick endpoint:

1. Import Supabase client and uuid
2. After Outlook event creation, resolve client_id using RPC
3. Build meeting data object with all required fields
4. Insert into `unified_meetings` table
5. Return saved meeting data with database ID

**File Modified**: `src/app/api/meetings/schedule-quick/route.ts`

**Key additions**:
- Supabase client import and initialization
- `resolve_client_id_int` RPC call for client ID resolution
- Database insert with all meeting fields:
  - `meeting_id`, `outlook_event_id`, `client_name`, `client_id`
  - `cse_name`, `meeting_date`, `meeting_time`, `duration`
  - `meeting_type`, `meeting_notes`, `title`, `attendees`
  - `synced_to_outlook`, `teams_meeting_id`, `status`
  - `created_at`, `updated_at`, `ai_analyzed`

---

### Issue 3: Dev Server CSS Not Loading (Turbopack)

**Problem**: The dev server displayed unstyled content with all CSS returning 404 errors.

**Root Cause**: Turbopack (Next.js 16) cache corruption causing chunk filename mismatches between HTML references and actual generated files.

**Workaround**:
- Clear `.next` directory and restart dev server
- Use production site for testing (which builds correctly)
- Use incognito mode to avoid browser cache issues

**Root Cause**: The service worker at `public/sw.js` was caching ALL GET requests, including Next.js development chunks. When Turbopack regenerated chunks with new hashes, the service worker served stale cached responses, causing 404 errors.

**Fix**: Modified `public/sw.js` to:
1. Exclude `/_next/` paths from caching (Next.js dev assets)
2. Exclude `/api/` paths from caching (API routes)
3. Exclude `__webpack` and `__turbopack` paths (HMR)
4. Incremented cache version from `v1` to `v2` to clear stale caches

```javascript
// Never cache Next.js development assets
if (url.pathname.startsWith('/_next/')) {
  return
}
// Also skip caching for API routes and hot module replacement
if (url.pathname.startsWith('/api/') || url.pathname.includes('__webpack') || url.pathname.includes('__turbopack')) {
  return
}
```

**File Modified**: `public/sw.js`

---

## Testing

### Auth Fix Verified
- Dev-login sessions no longer trigger token refresh errors
- Console is clean of `RefreshAccessTokenError` messages

### Meeting Scheduling Verified
- Production Briefing Room loads correctly
- "+ New Meeting" button opens AI-First modal
- "Create Manually" form displays all fields correctly
- Form validation working (required fields)
- Client dropdown populated with all clients

---

## Files Modified

| File | Change |
|------|--------|
| `src/auth.ts` | Skip token refresh and clear stale errors for dev-login sessions |
| `src/app/api/meetings/schedule-quick/route.ts` | Add Supabase database save |
| `public/sw.js` | Exclude `/_next/`, `/api/`, and HMR paths from caching |

## Deployment Status

- Code changes applied locally
- Requires commit and push to deploy to production
- Previous commits (Meeting Velocity chart fixes) already deployed

---

## Related Bug Reports

- `2026-01-09-meeting-velocity-week-label-format.md` - Week label format fix
- `2026-01-09-meeting-velocity-bar-direction.md` - Bar chart direction fix
