# Bug Report: formatCurrency Crash on Undefined Values

**Date:** 2026-01-09
**Severity:** High (Causes page crashes)
**Status:** Resolved

## Summary
Multiple planning page components crashed with `TypeError: Cannot read properties of undefined (reading 'toFixed')` when the `formatCurrency` utility function received `undefined` or `null` values instead of numbers.

## Error Message
```
TypeError: Cannot read properties of undefined (reading 'toFixed')
    at formatCurrency
    at TerritoryRow
    at TerritoryRollupTable
    at BusinessUnitPlanningPage
```

## Root Cause
The `formatCurrency` function across 11 files was defined as:
```typescript
const formatCurrency = (value: number, decimals = 1): string => {
  if (value >= 1000000) return `$${(value / 1000000).toFixed(decimals)}M`
  if (value >= 1000) return `$${(value / 1000).toFixed(decimals)}K`
  return `$${value.toFixed(0)}`
}
```

This function assumed `value` would always be a valid number, but when API responses returned data with missing or undefined numeric fields, the function crashed.

## Resolution
Updated all `formatCurrency` functions to handle undefined/null values defensively:

```typescript
const formatCurrency = (value: number | undefined | null, decimals = 1): string => {
  const num = value ?? 0
  if (typeof num !== 'number' || isNaN(num)) return '$0'
  if (num >= 1000000) return `$${(num / 1000000).toFixed(decimals)}M`
  if (num >= 1000) return `$${(num / 1000).toFixed(decimals)}K`
  return `$${num.toFixed(0)}`
}
```

Key changes:
1. Accept `undefined | null` in type signature
2. Use nullish coalescing (`??`) to default to 0
3. Check for invalid number types and NaN
4. Return '$0' for invalid inputs instead of crashing

## Files Modified
- `src/components/planning/TerritoryRollupTable.tsx`
- `src/components/planning/BUContributionsTable.tsx`
- `src/components/planning/APACRiskSummary.tsx`
- `src/components/planning/BusinessUnitSummaryWidgets.tsx`
- `src/components/planning/BUSegmentDistribution.tsx`
- `src/components/planning/APACRevenueProgress.tsx`
- `src/components/planning/GapClosureAnalysis.tsx`
- `src/components/planning/TerritoryComplianceOverview.tsx`
- `src/components/planning/TerritoryFinancialDashboard.tsx`
- `src/components/planning/AccountPlanFinancialSection.tsx`
- `src/app/(dashboard)/planning/business-unit/page.tsx`

## Verification
- Build: Successful (`npm run build` passes)
- Dev server: Running without errors
- Pages load without crashing

## Prevention
When creating utility functions for formatting:
1. Always accept `undefined | null` in addition to the expected type
2. Use nullish coalescing (`??`) for default values
3. Validate inputs before operations that can fail (like `.toFixed()`)
4. Return sensible defaults instead of throwing errors
5. Run full build and test all affected pages after changes

## Additional Issues Fixed in Same Session
- Fixed `@supabase/ssr` module not found (see BUG-REPORT-20260109-supabase-ssr-module-not-found.md)
- Fixed APAC page `.single()` query issue returning null for empty tables
- Fixed session-manager.ts OneDrive sync conflict filename
