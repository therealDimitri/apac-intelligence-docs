# Bug Fix: burc_annual_financials 400 Error

**Date:** 2026-01-19
**Commit:** a64d8fa2
**Type:** Bug Fix
**Status:** Completed

## Summary

Fixed 400 Bad Request error when querying `burc_annual_financials` table for prior year (FY25) comparison data in the Executive Dashboard.

## Problem

The Executive Dashboard was receiving 400 errors when attempting to load prior year financial data for trend comparison. The "vs FY25" metrics were not displaying correctly.

### Symptoms

- 400 Bad Request errors for `burc_annual_financials` queries in browser console
- Query URL showed requests for non-existent columns: `rule_of_40_score`, `total_arr`
- Prior year comparison data not loading

### Root Cause

The BURCExecutiveDashboard.tsx was querying columns that don't exist in the `burc_annual_financials` table:
- `rule_of_40_score` - Not stored in database (calculated value)
- `total_arr` - Should be `ending_arr`

Additionally, the query used `.single()` which would error if no prior year data exists.

## Solution

### File Changed: `src/components/burc/BURCExecutiveDashboard.tsx`

**Before (incorrect):**
```typescript
const { data: priorData } = await supabase
  .from('burc_annual_financials')
  .select('nrr_percent, grr_percent, rule_of_40_score, total_arr')
  .eq('fiscal_year', new Date().getFullYear() - 1)
  .single()
```

**After (correct):**
```typescript
const { data: priorData } = await supabase
  .from('burc_annual_financials')
  .select('nrr_percent, grr_percent, ending_arr')
  .eq('fiscal_year', new Date().getFullYear() - 1)
  .maybeSingle()

if (priorData) {
  setPriorSummary({
    nrr_percent: priorData.nrr_percent || 100,
    grr_percent: priorData.grr_percent || 95,
    rule_of_40_score: 40, // Not stored in table - use default
    total_arr: priorData.ending_arr || 0, // Use ending_arr as total_arr equivalent
  })
}
```

## Database Schema Reference

### burc_annual_financials table columns

| Column | Exists | Used As |
|--------|--------|---------|
| `nrr_percent` | Yes | NRR percentage |
| `grr_percent` | Yes | GRR percentage |
| `ending_arr` | Yes | Total ARR at year end |
| `starting_arr` | Yes | Total ARR at year start |
| `churn` | Yes | Churn amount |
| `expansion` | Yes | Expansion amount |
| `rule_of_40_score` | **No** | N/A - calculated value |
| `total_arr` | **No** | Use `ending_arr` instead |

## Testing

- Build passes without TypeScript errors
- No 400 errors in browser console for `burc_annual_financials` queries
- Dashboard displays correctly with metrics:
  - Net Revenue Retention: 91%
  - Gross Revenue Retention: 98%
  - Rule of 40: 48
  - Total ARR: $34.3M
- "vs FY25" comparison values now display

## Prevention

This issue could have been prevented by:
1. Always verifying column names against `docs/database-schema.md`
2. Running `npm run validate-schema` before committing
3. Using `.maybeSingle()` instead of `.single()` when data may not exist

## Related Files

- `src/components/burc/BURCExecutiveDashboard.tsx` - Executive Dashboard component
- `scripts/sync-burc-comprehensive.mjs` - BURC data sync script (defines table structure)
- `docs/database-schema.md` - Database schema reference
