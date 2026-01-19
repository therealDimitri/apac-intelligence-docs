# Bug Report: Performance Page Data Discrepancies

## Date
2026-01-19

## Summary
Analysis of the CSE/CAM Performance Dashboard revealed several data display discrepancies and one CSE name mismatch that was preventing target matching.

## Discrepancies Identified

### 1. CSE Name Mismatch (FIXED)
**Issue**: "Open Role" in clients table did not match "New Asia CSE" in cse_cam_targets table.

**Impact**: Asia+Guam territory showed $0 target.

**Fix Applied**: Added "Open Role" entry to cse_cam_targets with same target values as "New Asia CSE":
- Weighted ACV Target: $2,485,028
- Total ACV Target: $7,919,399

### 2. Achievement vs Pipeline Coverage Display
**Issue**: The "Wgt ACV Target" section displays `quarterly_actual / quarterly_target` where `quarterly_actual` comes from `cse_cam_targets.weighted_acv_actual` (booked revenue), NOT pipeline.

**Current Display**:
- Shows "$0 / $1.9M" for Tracey Bland
- Shows "0% achieved" for all CSEs

**Root Cause**: The `weighted_acv_actual` column in cse_cam_targets is 0 for all CSEs because no closed deals have been recorded.

**Expected Behaviour Options**:
1. **Option A**: Populate `weighted_acv_actual` with actual closed/booked revenue from closed opportunities
2. **Option B**: Change display to show "Pipeline Coverage" (pipeline vs target) instead of "Achievement" (actual vs target)
3. **Option C**: Show both metrics - Achievement AND Coverage

### 3. Tracey Bland's $19k Gap (NOT A BUG)
**Analysis**: This is a real gap between pipeline and target.
- Target: $1,928,636
- Pipeline (In-Target Weighted ACV): $1,909,347
- Gap: $19,289 (0.99% coverage)

This is accurate data reflecting her actual pipeline status.

## Current Pipeline vs Target Status

| CSE | Target | Pipeline | Coverage | Gap |
|-----|--------|----------|----------|-----|
| Tracey Bland | $1,928,636 | $1,909,347 | 99.0% | $19,289 |
| John Salisbury | $1,269,625 | $1,269,627 | 100.0% | -$2 |
| Laura Messing | $2,675,260 | $2,680,288 | 100.2% | -$5,028 |
| Open Role | $2,485,028 | $2,484,209 | 100.0% | $819 |
| **Total** | **$8,358,549** | **$8,343,471** | **99.8%** | **$15,078** |

## Duplicate Entries to Consider Removing

The following targets have no pipeline matches and appear to be duplicates:
1. **Johnathan Salisbury** - Use "John Salisbury" instead
2. **New Asia CSE** - Use "Open Role" instead

These can be kept as aliases or removed to avoid confusion.

## Files Involved

- `/src/contexts/PlanningPortfolioContext.tsx` - Data loading and aggregation
- `/src/components/planning/CSEPerformanceDashboard.tsx` - Display component
- `/supabase/migrations/20260119_update_cse_targets_fy2026.sql` - Target data

## Recommendations

### Short-term
1. ✅ Add "Open Role" to targets (DONE)
2. Consider adding a "Pipeline Coverage" metric to the dashboard that shows pipeline vs target

### Long-term
1. Implement automated syncing of `weighted_acv_actual` from closed opportunities
2. Add data quality checks for CSE name consistency between clients, targets, and pipeline tables
3. Consider using a CSE master list with aliases for name matching

## Verification Query

```sql
-- Check target matching after fix
SELECT
  t.cse_cam_name,
  t.weighted_acv_target,
  COALESCE(SUM(p.weighted_acv), 0) as pipeline_weighted_acv,
  ROUND(COALESCE(SUM(p.weighted_acv), 0) / t.weighted_acv_target * 100, 1) as coverage_pct
FROM cse_cam_targets t
LEFT JOIN sales_pipeline_opportunities p
  ON t.cse_cam_name = p.cse_name
  AND p.in_or_out = 'In'
  AND p.forecast_category != 'Omitted'
WHERE t.fiscal_year = 2026 AND t.role_type = 'CSE'
GROUP BY t.cse_cam_name, t.weighted_acv_target
ORDER BY t.cse_cam_name;
```
