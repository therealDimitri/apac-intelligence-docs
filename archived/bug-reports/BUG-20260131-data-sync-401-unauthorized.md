# Bug Report: Data Sync Manual Triggers Failing with 401 Unauthorized

**Date:** 2026-01-31
**Severity:** High
**Status:** Fixed
**Component:** Admin / Data Sync Status

## Summary

All manual data sync operations (health_snapshots, aged_accounts) were failing with 401 Unauthorized errors despite CRON_SECRET being correctly configured in Netlify environment variables.

## Symptoms

- Data Sync Status page showing multiple failed syncs
- Sync history showing 0s duration, +0 records
- Error message: `401 - {"success":false,"error":{"code":"UNAUTHORIZED","message":"Unauthorized"}}`
- Direct curl calls to cron endpoints with CRON_SECRET worked correctly

## Root Cause

**Plain object HeadersInit doesn't reliably pass headers in fetch()**

The data-sync route was building headers using a plain object:

```typescript
// BEFORE (broken)
const cronHeaders: HeadersInit = {
  'Content-Type': 'application/json',
}
if (cronSecret) {
  cronHeaders['Authorization'] = `Bearer ${cronSecret}`
}
```

Dynamic property assignment to a `HeadersInit` typed object doesn't reliably pass the header when used in `fetch()`. This is a subtle JavaScript/TypeScript quirk where the object property is set correctly but isn't properly serialised when passed to fetch.

## Solution

Use the `Headers` constructor with `.set()` method:

```typescript
// AFTER (fixed)
const cronHeaders = new Headers({
  'Content-Type': 'application/json',
})
if (cronSecret) {
  cronHeaders.set('Authorization', `Bearer ${cronSecret}`)
}
```

The `Headers` API properly manages HTTP headers and ensures they're correctly passed to `fetch()`.

## Files Modified

- `src/app/api/admin/data-sync/route.ts` - Changed from plain object to Headers object

## Verification

1. Navigate to Settings → Data Sync Status
2. Click "Sync Now" on Health Snapshots or Aged Accounts
3. Sync should complete successfully with records created
4. Sync history should show "success" status

## Diagnostic Approach

1. Verified CRON_SECRET was set in Netlify: `netlify env:get CRON_SECRET`
2. Tested cron endpoints directly with curl - both worked
3. Added debug logging to trace where auth was failing
4. Identified that `fetch()` wasn't receiving the Authorization header
5. Changed to `Headers` object - syncs started working

## Related

- Cron endpoints: `src/app/api/cron/health-snapshot/route.ts`, `src/app/api/cron/aged-accounts-snapshot/route.ts`
- Data sync UI: `src/app/(dashboard)/admin/data-sync/page.tsx`

## Prevention

When building headers for `fetch()` calls that include authorization:
- Always use `new Headers()` with `.set()` method
- Avoid dynamic property assignment on plain objects typed as `HeadersInit`
