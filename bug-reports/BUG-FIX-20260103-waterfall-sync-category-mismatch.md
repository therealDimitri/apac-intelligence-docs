# Bug Fix Report: Waterfall Sync Category Name Mismatch

**Date:** 3 January 2026
**Status:** Resolved
**Priority:** Critical
**Component:** BURC Sync Script

## Summary

The `sync-burc-monthly.mjs` script was silently failing to update waterfall data because it was matching on display names instead of database category names.

## Root Cause

The sync script used display names (e.g., `'Backlog/Runrate'`) in the `.eq('category', ...)` clause, but the database stores categories as snake_case field names (e.g., `'backlog_runrate'`).

**Before (incorrect):**
```javascript
const fieldMappings = {
  backlog_runrate: 'Backlog/Runrate',  // Display name
  // ...
}
.eq('category', category)  // Matched on 'Backlog/Runrate' - no rows found
```

**After (correct):**
```javascript
const fieldMappings = {
  backlog_runrate: 'Backlog/Runrate',  // Display name for logging only
  // ...
}
.eq('category', field)  // Match on 'backlog_runrate' - correct
```

## Impact

- Waterfall data was not being updated during sync operations
- Old/stale values persisted in database
- Sync appeared successful (no errors) but no data was changed

## Fix Applied

**File:** `scripts/sync-burc-monthly.mjs`

1. Changed `.eq('category', category)` to `.eq('category', field)` (line 240)
2. Updated variable naming from `category` to `displayName` for clarity
3. Fixed success detection to check `updated.length` instead of `count`

```javascript
const { data: updated, error } = await supabase
  .from('burc_waterfall')
  .update({ amount: data[field], updated_at: new Date().toISOString() })
  .eq('category', field)  // Use field name (snake_case) as that's what DB stores
  .select()

if (!updated || updated.length === 0) {
  console.log(`  ⚠️ ${displayName}: No matching row found`)
}
```

## Verification

After fix, sync correctly updates all 7 waterfall categories:

| Category | Source Value | DB Value (after sync) |
|----------|--------------|----------------------|
| backlog_runrate | $20.00M | $20.00M ✅ |
| committed_gross_rev | $20.59M | $20.59M ✅ |
| best_case_ps | $3.57M | $3.57M ✅ |
| best_case_maint | $4.14M | $4.14M ✅ |
| pipeline_sw | $1.57M | $1.57M ✅ |
| pipeline_ps | $2.25M | $2.25M ✅ |
| target_ebita | $5.53M | $5.53M ✅ |

## Lessons Learned

1. Always verify database column values match expected query parameters
2. Supabase updates return empty arrays (not errors) when no rows match
3. Add explicit row count verification after UPDATE operations
