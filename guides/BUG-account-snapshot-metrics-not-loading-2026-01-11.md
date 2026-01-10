# Bug Report: Account Snapshot Metrics Not Loading

**Date:** 11 January 2026
**Page:** `/planning/account/new`
**Severity:** High

---

## Issue

Account Snapshot metrics (Health Score, NPS Score, Segment, ARR) were showing N/A or $0 for all clients when selected in the Account Plan workflow.

---

## Root Cause

The code was querying a non-existent table `client_health_scores_materialized` instead of the correct table `client_health_summary`.

Additionally, the code referenced a column `latest_nps` which doesn't exist - the correct column is `nps_score`.

**Error from Supabase:**
```
code: 'PGRST205'
hint: "Perhaps you meant the table 'public.client_health_summary'"
message: "Could not find the table 'public.client_health_scores_materialized' in the schema cache"
```

---

## Fix Applied

### Change 1: Correct Table Name
```typescript
// Before (incorrect)
supabase
  .from('client_health_scores_materialized')
  .select('client_name, health_score, latest_nps, segment')

// After (correct)
supabase
  .from('client_health_summary')
  .select('client_name, health_score, nps_score, segment')
```

### Change 2: Correct Column Name
```typescript
// Before (incorrect)
latest_nps: health?.latest_nps,

// After (correct)
latest_nps: health?.nps_score,
```

---

## Verified Data

After fix, Albury Wodonga Health correctly shows:
- **Health Score:** 55
- **NPS Score:** 0
- **Segment:** Leverage
- **Status:** Critical

---

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/planning/account/new/page.tsx` | Fixed table name and column reference |

---

## Testing Checklist

- [x] Build passes with zero TypeScript errors
- [x] Albury Wodonga Health shows Health Score 55
- [x] NPS Score displays correctly (0)
- [x] Segment displays correctly (Leverage)
- [x] Other clients also load their metrics correctly

---

## Prevention

1. Always verify table and column names against `docs/database-schema.md`
2. Test data loading with actual database queries before assuming schema
3. Check Supabase error messages in browser console for hints about correct table names
