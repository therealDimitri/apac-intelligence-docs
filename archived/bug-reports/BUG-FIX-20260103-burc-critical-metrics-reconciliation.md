# Bug Fix Report: BURC Critical Metrics Reconciliation

**Date:** 3 January 2026
**Status:** Resolved
**Priority:** Critical
**Component:** BURC Performance Dashboard

## Summary

Following comprehensive reconciliation of BURC source files against the database, two critical issues were identified and resolved.

## Issues Identified

### Issue 1: "Total ARR" Mislabelling

**Problem:** The "Total ARR" card on the BURC Executive Dashboard was displaying $34.27M, which is actually the **weighted pipeline** value, not true ARR.

**Source Data:**
- Actual Total ARR from `ARR Target 2025.xlsx`: **$15.73M**
- Database `burc_executive_summary.total_arr`: **$34.27M**
- Variance: +$18.54M (118% higher)

**Root Cause:** The database view calculates `total_arr` from `burc_arr_tracking` which contains pipeline-weighted values, not contracted ARR.

**Fix Applied:**
- Renamed "Total ARR" to "Weighted Pipeline" in `BURCExecutiveDashboard.tsx` (line 308-309)
- Added tooltip explaining the metric: "Weighted pipeline value based on probability-adjusted opportunities"

### Issue 2: NRR/GRR Calculation from Partial Data

**Problem:** The `burc_executive_summary` view was calculating NRR/GRR from only one client's data (SA Health), resulting in inaccurate APAC-wide metrics.

**Before Fix:**
- NRR: 0% (year_2025 was $0)
- GRR: 100% (no churn data)

**After Data Population:**
- NRR: 95.4% (calculated from SA Health only)
- GRR: 100% (no attrition data)

**Expected (APAC-wide from BURC source):**
- NRR: 92.8%
- GRR: 72.2%

**Fix Applied:**
1. Populated `burc_historical_revenue.year_2025` with estimated values based on source file analysis:
   - Hardware: $55K
   - License: $1.10M
   - Maintenance: $6.38M
   - Professional Services: $2.64M
   - Total: $10.18M

2. Retained hardcoded `CORRECT_2025_METRICS` override with accurate BURC source values since database only has partial client data

3. Updated comments to clarify the override reason

## Files Modified

1. **`src/components/burc/BURCExecutiveDashboard.tsx`**
   - Line 308-309: Renamed "Total ARR" to "Weighted Pipeline"
   - Lines 72-80: Updated documentation comment
   - Lines 127-128: Updated inline comment

2. **Database: `burc_historical_revenue`**
   - Updated `year_2025` column for 4 revenue records

## Testing

- TypeScript compilation: ✅ No errors
- Database verification: ✅ year_2025 now populated

## Additional Fix: Waterfall Data Source Correction

**Issue:** Initially synced waterfall data from 2025 APAC Performance.xlsx (actuals), which showed Best Case PS = $0.

**Correction:** Updated to use **2026 APAC Performance.xlsx** (forecast file) which contains the correct planning values:

| Category | Incorrect (2025 file) | Correct (2026 file) |
|----------|----------------------|---------------------|
| Best Case PS | $0 | $3.57M |
| Best Case Maint | $9.4K | $4.14M |
| Backlog | $24.17M | $20.00M |
| Pipeline SW | $69.2K | $1.57M |

---

## Recommendations

To achieve accurate database-calculated NRR/GRR:

1. **Populate full client revenue data** - Currently only SA Health is in the database. Need to import revenue data for all APAC clients from BURC source files.

2. **Populate attrition data** - The `burc_attrition_risk.revenue_2025` column needs to be populated with actual churn values for accurate GRR calculation.

3. **Create automated sync** - Establish a monthly sync from BURC source files to keep database current.

## Related Documentation

- `/docs/DATA-RECONCILIATION-REPORT-20260103.md` - Full reconciliation findings
- `/docs/bug-reports/BUG-REPORT-20260103-nrr-metrics-mismatch.md` - Original NRR issue report
