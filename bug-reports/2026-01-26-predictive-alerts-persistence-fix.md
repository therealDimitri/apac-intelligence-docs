# Bug Fix Report: Predictive Alerts Persistence Failure

**Date:** 2026-01-26
**Type:** Bug Fix
**Status:** Fixed & Deployed
**Author:** Claude Opus 4.5

---

## Issue

The predictive alerts detection was working correctly (detecting 8 alerts across 5 clients), but persistence to the database was failing with 8 errors. The alerts were never saved to the `alerts` table.

## Root Cause

Two issues contributed to the failure:

### 1. Missing `churn_prediction` Category in Database Constraint

The `alerts` table had a CHECK constraint on the `category` column that didn't include `churn_prediction`. This was fixed in a previous session by:
- Creating an admin endpoint (`/api/admin/add-alert-category`) to update the constraint
- Using direct PostgreSQL connection via `postgres` package to execute DDL

### 2. `persistAlert` Function Not Handling Errors Properly

The `persistAlert` function in `alert-system.ts` was:
1. Not checking for errors from the `alert_fingerprints` table query
2. Attempting manual deduplication logic that was failing silently
3. Not using the database's built-in `upsert_alert` RPC function

## Solution

Modified `persistAlert` to:

1. **Use Database RPC Function First**: Call `upsert_alert` stored procedure which handles deduplication atomically
2. **Fallback to Direct Insert**: If RPC fails (function may not exist), use direct Supabase insert with proper error handling
3. **Return Detailed Errors**: Include actual error messages in API response for debugging

### Code Change

```typescript
// Before: Manual fingerprint checking with silent failures
const { data: existingFp } = await supabase
  .from('alert_fingerprints')
  .select('...')
  .single()  // ❌ No error handling

// After: Use database RPC with fallback
const { data: upsertResult, error: upsertError } = await supabase.rpc('upsert_alert', {
  p_alert_id: alert.id,
  p_category: alert.category,
  // ... all parameters
})

if (upsertError) {
  // Fall back to direct insert if RPC fails
  return await persistAlertDirect(supabase, alert, autoCreateAction)
}
```

## Files Changed

- `src/lib/alert-system.ts` - Rewrote `persistAlert` to use RPC function
- `src/app/api/alerts/predictive/route.ts` - Added error details to API response

## Testing

### Before Fix
```json
{
  "detection": { "alertsDetected": 8 },
  "persistence": { "persisted": 0, "errors": 8 }
}
```

### After Fix
```json
{
  "detection": { "alertsDetected": 8 },
  "persistence": { "persisted": 8, "newAlerts": 8, "errors": 0 }
}
```

### Verified
- GET `/api/alerts/predictive` now returns 13 alerts (5 existing + 8 new)
- Breakdown: 5 churn_risk, 5 engagement_decline, 1 health_trajectory, 1 peer_underperformance, 1 expansion_opportunity

## Technical Notes

### Why Use Database RPC Function?

The `upsert_alert` stored procedure (defined in `20251231_alerts_table_and_action_linking.sql`) provides:

1. **Atomic Deduplication**: Fingerprint check and insert in single transaction
2. **Consistent Hashing**: Uses `generate_alert_fingerprint()` SQL function
3. **Auto-Action Creation**: Can create linked actions for critical alerts
4. **Reliability**: No race conditions between fingerprint check and insert

### Why Fallback to Direct Insert?

The RPC function may not exist if the migration hasn't been run. The fallback:
- Uses proper error handling for fingerprint table
- Ignores fingerprint errors (deduplication is nice-to-have)
- Still creates alerts even without deduplication

---

## Related Issues

- Previous fix for `churn_prediction` category constraint (same session)
- Timeout fix documented in `2026-01-26-predictive-alerts-timeout-fix.md`
