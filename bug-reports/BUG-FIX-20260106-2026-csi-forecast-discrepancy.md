# Bug Fix: 2026 CSI Forecast Ratios - Database Values Mismatch

**Date:** 6 January 2026
**Status:** Fixed (Corrected)
**Severity:** High - Data Accuracy
**Component:** CSI Operating Ratios / BURC 2026 Forecast

---

## Summary

The CSI Operating Ratios displayed for FY2026 forecast did not match the values from the source Excel file (2026 APAC Performance.xlsx). The database had incorrect underlying values that were not sourced from the correct Excel data.

---

## Issue Details

### Symptoms (Before Fix)
| CSI Ratio | Database | Expected | Issue |
|-----------|----------|----------|-------|
| PS Ratio | 2.71 | ~2.4 | Wrong source data |
| Sales Ratio | 0.00 | 0.00 | OK (no license sales most months) |
| Maint Ratio | 6.72 | 5.69 | Wrong source data |
| R&D Ratio | 0.19 | 0.30 | Wrong source data |
| G&A Ratio | 14.7% | 17.7% | Wrong source data |

### Root Cause
The 2026 values were synced from incorrect rows or had data transformation issues. The correct source is the **APAC BURC sheet** with actual monthly values (rows 56-93).

### Important Clarification
- **APAC BURC sheet**: Contains actual monthly CSI ratios (Jan-Dec individual values)
- **26 vs 25 Q Comparison sheet**: Contains quarterly and FY averages of the monthly values
- The quarterly values in "26 vs 25" are averages of the monthly values from "APAC BURC"

---

## Correct Fix Applied

### Updated from APAC BURC Monthly Values
All months of 2026 in `burc_csi_opex` updated with actual monthly values from APAC BURC sheet:

| Month | License NR | PS NR | Maint NR | Maint Ratio | PS Ratio |
|-------|------------|-------|----------|-------------|----------|
| Feb | $0 | $580K | $1,164K | 4.58 | 1.89 |
| Mar | $0 | $562K | $1,245K | 4.90 | 1.83 |
| Apr | $0 | $644K | $1,300K | 5.11 | 2.10 |
| May | $0 | $727K | $1,185K | 4.66 | 2.37 |
| Jun | $0 | $735K | $1,266K | 4.98 | 2.40 |
| Jul | $19K | $645K | $1,295K | 5.09 | 2.11 |
| Aug | $1,909K | $897K | $1,230K | 4.84 | 2.93 |
| Sep | $0 | $764K | $3,937K | 15.48 | 2.49 |
| Oct | $0 | $822K | $1,309K | 5.15 | 2.68 |
| Nov | $0 | $731K | $1,216K | 4.78 | 2.39 |
| Dec | $0 | $744K | $1,448K | 5.69 | 2.43 |

Note: January has no data in Excel (budget planning period).

---

## Verified Results (Dec 2026)

| CSI Ratio | Dashboard | Excel (APAC BURC Dec) | Match |
|-----------|-----------|----------------------|-------|
| Maint Ratio | 5.69 | 5.69 | ✅ |
| Sales Ratio | 0.00 | 0.00 | ✅ |
| PS Ratio | 2.43 | 2.43 | ✅ |
| R&D Ratio | 0.30 | 0.30 (29.9%) | ✅ |
| G&A Ratio | 17.7% | 17.7% | ✅ |

---

## Source Verification

**File:** 2026 APAC Performance.xlsx
**Sheet:** APAC BURC (monthly data)

Key rows used:
- Row 56: License NR (monthly)
- Row 57: Professional Service NR (monthly)
- Row 58: Maintenance NR (monthly)
- Row 69: PS OPEX
- Row 74: Maint OPEX
- Row 80: S&M OPEX
- Row 86: R&D OPEX
- Row 93: G&A OPEX
- Rows 121-125: CSI Ratios (verification)

**Relationship to 26 vs 25 Q Comparison:**
- Q1 average = (Feb + Mar) / 2 values from APAC BURC
- FY average = weighted or simple average of all monthly values

---

## Prevention Recommendations

1. **Data Source Documentation**: The authoritative source for monthly CSI values is the APAC BURC sheet, not 26 vs 25 Q Comparison

2. **Sync Script Enhancement**: Update `scripts/sync-burc-monthly.mjs` to:
   - Read from APAC BURC sheet rows 56-93 for monthly values
   - Skip months with no data (like January in planning period)
   - Validate calculated ratios against rows 121-125

3. **Monthly vs Quarterly**: Understand that:
   - Dashboard shows individual monthly values
   - 26 vs 25 sheet shows quarterly/yearly aggregates

---

## Related Files

- `src/app/api/analytics/burc/csi-ratios/route.ts` - CSI ratio calculation logic
- `scripts/fix-2026-from-apac-burc-monthly.mjs` - Correct fix script
- `scripts/sync-burc-monthly.mjs` - BURC data sync (needs review)
- `burc_csi_opex` table - Stores underlying revenue and OPEX values

---

## Scripts Created

| Script | Purpose |
|--------|---------|
| `scripts/fix-2026-from-apac-burc-monthly.mjs` | **Correct fix** - Update from APAC BURC monthly values |
| `scripts/check-apac-burc-monthly-ratios.mjs` | Analyse APAC BURC monthly ratios |
| `scripts/fix-2026-csi-opex.mjs` | Initial fix (used FY averages - incorrect approach) |
| `scripts/check-2026-csi-structure.mjs` | Analyse Excel column structure |
| `scripts/investigate-ga-ratio.mjs` | Debug G&A ratio discrepancy |
