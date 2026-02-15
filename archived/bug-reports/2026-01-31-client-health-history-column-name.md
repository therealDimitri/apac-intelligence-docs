# Bug Report: Client Health History Query Using Wrong Column Name

**Date:** 2026-01-31
**Severity:** Medium
**Status:** Resolved
**Component:** AI Recommendations Page (`/sales-hub/recommendations`)

## Summary

The `useClientContext` hook was using `recorded_at` as the order column for the `client_health_history` table, but the actual column name is `snapshot_date`, causing a 400 error from Supabase.

## Symptoms

- Browser console showed: `Failed to load resource: the server responded with a status of 400`
- Request URL: `client_health_history?select=client_name,health_score,status&order=recorded_at.desc`
- Health scores were not displaying on client cards in the recommendations page

## Root Cause

The `useClientContext.ts` hook at line 57 had:
```typescript
.order('recorded_at', { ascending: false })
```

But the `client_health_history` table schema has:
- `snapshot_date` (text) - the actual date column
- No `recorded_at` column exists

## Resolution

Changed the order clause to use the correct column name:
```typescript
.order('snapshot_date', { ascending: false })
```

**Commit:** `123a49e1` - fix: correct column name in client health history query

## Verification

After deployment:
- No console errors on page load
- Health scores now display correctly on client cards (82, 81, 66, etc.)
- Recommendations generate successfully when selecting a client

## Lessons Learned

1. Always verify column names against `docs/database-schema.md` before writing queries
2. Supabase `select()` fails silently with wrong columns, but `order()` throws 400 errors
3. The validation script (`npm run validate-schema`) should be extended to check `order()` clauses

## Related Files

- `src/hooks/useClientContext.ts` - Fixed
- `docs/database-schema.md` - Reference (client_health_history table)
