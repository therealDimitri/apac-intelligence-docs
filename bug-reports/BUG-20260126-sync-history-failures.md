# Bug Report: Sync History Items Failing

**Date:** 2026-01-26
**Severity:** Medium
**Status:** Resolved
**Component:** Data Sync Status Page (`/admin/data-sync`)

---

## Summary

All manual sync operations triggered from the Data Sync Status page were failing with:
- Status: `failed`
- Duration: `N/A`
- Records: `+0 ~0`
- Triggered By: `Unknown`

---

## Root Causes Identified

### 1. Missing CRON_SECRET Authorization Header (Critical)

The `/api/admin/data-sync` route was calling cron endpoints **without** the required authorization header:

**Before (Broken):**
```typescript
const agingResponse = await fetch(
  `${baseUrl}/api/cron/aged-accounts-snapshot`,
  {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    // Missing Authorization header!
  }
)
```

**The cron endpoints require authentication:**
```typescript
// health-snapshot/route.ts
if (cronSecret && authHeader !== `Bearer ${cronSecret}`) {
  return createErrorResponse('UNAUTHORIZED', 'Unauthorized', 401)
}
```

**Result:** All cron endpoint calls returned 401 Unauthorized, causing sync to fail.

### 2. Missing User Email in Frontend Request

The frontend was not passing the user's email when triggering a sync:

**Before:**
```typescript
body: JSON.stringify({ source: sourceId })
```

**Result:** `triggered_by_user` always showed "Unknown" in sync history.

### 3. No Duration/Records Tracking

The sync_history entry was not being updated with:
- `duration_ms` - Time taken for sync
- `records_created` / `records_processed` - Number of records synced

---

## Fixes Applied

### Fix 1: Add Authorization Header to Cron Calls

```typescript
// Get CRON_SECRET for authenticating with cron endpoints
const cronSecret = process.env.CRON_SECRET
const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3001'

// Build headers with authorization
const cronHeaders: HeadersInit = {
  'Content-Type': 'application/json',
}
if (cronSecret) {
  cronHeaders['Authorization'] = `Bearer ${cronSecret}`
}

// Use headers in fetch calls
const healthResponse = await fetch(`${baseUrl}/api/cron/health-snapshot`, {
  method: 'POST',
  headers: cronHeaders,  // Now includes Authorization
})
```

### Fix 2: Pass User Email from Session

```typescript
// page.tsx - Added useSession hook
const { data: session } = useSession()

// Pass email in API call
body: JSON.stringify({
  source: sourceId,
  userEmail: session?.user?.email || 'Unknown',
})
```

### Fix 3: Track Duration and Record Counts

```typescript
const startTime = Date.now()

// ... perform sync ...

const durationMs = Date.now() - startTime

// Update sync history with results
await supabase
  .from('sync_history')
  .update({
    status: syncResult.success ? 'success' : 'failed',
    completed_at: new Date().toISOString(),
    error_message: syncResult.success ? null : syncResult.message,
    duration_ms: durationMs,
    records_created: syncResult.records || 0,
    records_processed: syncResult.records || 0,
  })
  .eq('id', syncEntry.id)
```

### Fix 4: Better Error Handling

Added proper HTTP response status checking and error logging:

```typescript
if (!healthResponse.ok) {
  const errorText = await healthResponse.text()
  console.error('[data-sync] health_snapshots failed:', healthResponse.status, errorText)
  syncResult = {
    success: false,
    message: `Health snapshot sync failed: ${healthResponse.status} - ${errorText.slice(0, 200)}`,
  }
}
```

---

## Files Modified

| File | Changes |
|------|---------|
| `src/app/api/admin/data-sync/route.ts` | Added auth headers, duration tracking, error handling |
| `src/app/(dashboard)/admin/data-sync/page.tsx` | Added useSession, pass userEmail |

---

## Testing

After fix deployment:

1. Navigate to `/admin/data-sync`
2. Click "Sync Now" on Health Snapshots or Aged Accounts
3. Verify:
   - Status shows `success` (not `failed`)
   - Duration shows actual time (e.g., `3s`)
   - Records shows count (e.g., `+45 ~0`)
   - Triggered By shows user email

---

## Notes

- **Outlook Meetings** sync is intentionally disabled on this page - it requires user's Microsoft OAuth token and should be triggered from the Meetings page
- **NPS Responses** sync is not available - NPS data is imported via survey uploads
- **Outlook Actions** are auto-extracted from meetings, not synced separately

---

## Related

- Migration: `docs/migrations/20260124_create_sync_history_table.sql`
- Cron endpoints: `/api/cron/health-snapshot`, `/api/cron/aged-accounts-snapshot`
