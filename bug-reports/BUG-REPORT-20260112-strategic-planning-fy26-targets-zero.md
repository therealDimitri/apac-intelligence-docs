# Bug Report: Strategic Planning Page FY26 ACV Target, Pipeline and Coverage Showing $0

**Date:** 12 January 2026
**Severity:** High
**Status:** Resolved
**Affected Files:**
- `src/app/(dashboard)/planning/strategic/new/page.tsx`

## Problem Description

The Strategic Planning page (New Territory Overview) was displaying $0 for:
- FY26 ACV Target
- Pipeline (Weighted)
- Coverage (showing 0.00x)

This occurred when selecting any CSE/CAM owner.

### Root Cause Analysis

1. **Pipeline query using wrong filter**: The pipeline query was filtering by `client_name` but needed to filter by `cse_name` for reliable matching with the owner's portfolio
2. **Missing pipeline filters**: Pipeline opportunities were not filtered by `in_or_out = 'In'` or excluding `Omitted` forecast category
3. **Targets query using `.single()`**: The `cse_cam_targets` table stores quarterly records (Q1-Q4), but the query was using `.single()` which fails when multiple records exist
4. **Wrong column name**: Code referenced `total_acv_target` but the actual column is `weighted_acv_target`

## Solution Applied

### 1. Pipeline Query Fix
**Before:**
```typescript
const { data: pipelineData } = await supabase
  .from('sales_pipeline_opportunities')
  .select('*')
  .eq('client_name', ownerName)
  .order('weighted_acv', { ascending: false })
```

**After:**
```typescript
const { data: pipelineData } = await supabase
  .from('sales_pipeline_opportunities')
  .select('*')
  .eq('cse_name', ownerName)
  .eq('in_or_out', 'In') // Only count "In" opportunities
  .neq('forecast_category', 'Omitted') // Exclude "Omitted" opportunities
  .order('weighted_acv', { ascending: false })
```

### 2. Targets Query Fix
**Before:**
```typescript
const { data: targets } = await supabase
  .from('cse_cam_targets')
  .select('*')
  .eq('cse_cam_name', ownerName)
  .eq('fiscal_year', 2026)
  .single()

setFormData(prev => ({
  ...prev,
  targets: {
    fy26_tcv_target: targets?.total_acv_target || 0,
    // ...
  }
}))
```

**After:**
```typescript
// Load targets - aggregate quarterly targets for the full year
const { data: quarterlyTargets } = await supabase
  .from('cse_cam_targets')
  .select('quarter, weighted_acv_target, tcv_target')
  .eq('cse_cam_name', ownerName)
  .eq('fiscal_year', 2026)

// Sum up quarterly targets for FY26 totals
const fy26TcvTarget = quarterlyTargets?.reduce((sum, t) => sum + (t.tcv_target || 0), 0) || 0
const fy26AcvTarget = quarterlyTargets?.reduce((sum, t) => sum + (t.weighted_acv_target || 0), 0) || 0
const pipelineTotal = pipeline?.reduce((sum, p) => sum + (p.acv || 0), 0) || 0
const pipelineWeighted = pipeline?.reduce((sum, p) => sum + (p.weighted_acv || 0), 0) || 0
const coverage = fy26AcvTarget > 0 ? pipelineWeighted / fy26AcvTarget : 0

setFormData(prev => ({
  ...prev,
  targets: {
    fy26_tcv_target: fy26TcvTarget,
    fy26_acv_target: fy26AcvTarget,
    pipeline_total: pipelineTotal,
    pipeline_weighted: pipelineWeighted,
    coverage: coverage,
  },
}))
```

## Database Schema Reference

### `cse_cam_targets` table columns:
- `cse_cam_name` - The CSE/CAM name
- `fiscal_year` - Fiscal year (e.g., 2026)
- `quarter` - Quarter (Q1, Q2, Q3, Q4)
- `weighted_acv_target` - ACV target (NOT `total_acv_target`)
- `tcv_target` - TCV target

### `sales_pipeline_opportunities` table columns:
- `cse_name` - The CSE name (use this for matching, not `client_name`)
- `in_or_out` - Whether opportunity is 'In' or 'Out'
- `forecast_category` - Category including 'Omitted'
- `weighted_acv` - Weighted ACV value
- `acv` - ACV value

## Testing Performed

1. TypeScript compilation: Passed
2. Production build: Passed
3. Netlify deployment: Successful
4. Manual verification: Confirmed values now display correctly
   - FY26 ACV Target: $1,269,626.91
   - Pipeline (Weighted): $1,269,626.91
   - Coverage: 1.00x

## Verification Steps

1. Navigate to `/planning/strategic/new`
2. Select a CSE/CAM from the dropdown (e.g., "John Salisbury")
3. Navigate to "Portfolio & Health" step
4. Verify:
   - FY26 ACV Target shows a non-zero value
   - Pipeline (Weighted) shows a non-zero value
   - Coverage shows a non-zero multiplier (e.g., 1.00x)

## Related Commits

- `f78bd60f` - Fix FY26 ACV Target, Pipeline and Coverage showing $0 on strategic planning page

## Lessons Learned

1. **Always verify column names** against `docs/database-schema.md` before writing queries
2. **Understand table structure** - check if data is stored quarterly vs annually
3. **Use correct filter columns** - `cse_name` for CSE matching, not `client_name`
4. **Include business logic filters** - pipeline opportunities need `in_or_out = 'In'` filter
5. **Don't use `.single()` without verification** - check if table returns multiple rows
