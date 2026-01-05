# Bug Fix: 2026 CSI Forecast Ratios - Database Values Mismatch

**Date:** 6 January 2026
**Status:** Fixed
**Severity:** High - Data Accuracy
**Component:** CSI Operating Ratios / BURC 2026 Forecast

---

## Summary

The CSI Operating Ratios displayed for FY2026 forecast did not match the values from the source Excel file (2026 APAC Performance.xlsx). All five CSI ratios were affected due to incorrect underlying values in the `burc_csi_opex` database table.

---

## Issue Details

### Symptoms
| CSI Ratio | Before (DB) | After (Excel) | Discrepancy |
|-----------|-------------|---------------|-------------|
| PS Ratio | 2.71 | 2.70 | Minor |
| Sales Ratio | 0.00 | 1.87 | **Critical** |
| Maint Ratio | 6.72 | 8.49 | Significant |
| R&D Ratio | 0.19 | 0.71 | Significant |
| G&A Ratio | 14.7% | 8.87% | Significant |

### Root Cause
Two issues identified:

1. **Wrong Source Data**: The 2026 monthly values were synced from the APAC BURC sheet (budget/plan monthly breakdown) instead of the "26 vs 25 Q Comparison" sheet (official forecast values).

2. **Missing Total NR Component**: The G&A ratio calculation was missing Business Case NR (~$2.25M annually), which is included in Excel's Net Revenue total.

### Data Source Comparison

| Metric | Database Total | APAC BURC Sheet | 26 vs 25 (Correct) |
|--------|----------------|-----------------|-------------------|
| License NR | $2,677,586 | $1,927,832 | **$1,908,790** |
| PS NR | $9,744,197 | $7,851,587 | **$2,482,649** |
| Maintenance NR | $16,834,915 | $16,594,362 | **$6,475,993** |
| Total/Net Revenue | $905,619 | N/A | **$13,117,948** |

---

## Fix Applied

### 1. Updated Monthly Values
All 12 months of 2026 in `burc_csi_opex` updated with monthly averages from Excel FY totals:

| Field | Monthly Value | FY Total (Excel) |
|-------|---------------|------------------|
| license_nr | $159,066 | $1,908,790 |
| ps_nr | $206,887 | $2,482,649 |
| maintenance_nr | $539,666 | $6,475,993 |
| ps_opex | $76,630 | $919,564 |
| sm_opex | $59,662 | $715,949 |
| maintenance_opex | $54,031 | $648,373 |
| rd_opex | $181,614 | $2,179,371 |
| ga_opex | $96,991 | $1,163,897 |

### 2. Corrected Total NR
Updated `total_nr` to include Business Case NR:
- Previous: $905,619/month (sum of License + PS + Maint only)
- Corrected: $1,093,162/month (Excel Net Revenue / 12)

---

## Verified Results (FY 2026)

| CSI Ratio | Dashboard | Excel | Target | Status |
|-----------|-----------|-------|--------|--------|
| PS Ratio | 2.70 | 2.70 | ≥2.0 | ✅ Green |
| Sales Ratio | 1.87 | 1.87 | ≥1.0 | ✅ Green |
| Maint Ratio | 8.49 | 8.49 | ≥4.0 | ✅ Green |
| R&D Ratio | 0.71 | 0.71 | ≥1.0 | 🟡 Amber |
| G&A Ratio | 8.87% | 8.87% | ≤20% | ✅ Green |

---

## Source Verification

**File:** 2026 APAC Performance.xlsx
**Sheet:** 26 vs 25 Q Comparison
**Column 5:** FY 2026 Totals

Key rows used:
- Row 22: License NR ($1,908,790)
- Row 23: Professional Service NR ($2,482,649)
- Row 24: Maintenance NR ($6,475,993)
- Row 27: Net Revenue ($13,117,948)
- Row 29-33: OPEX values (PS, Maint, S&M, R&D, G&A)
- Rows 65-69: CSI Ratios (verification)

---

## Note on R&D Ratio Display

Excel displays R&D Ratio as "70.85%" in the CSI section (Row 67), but this represents the decimal value 0.7085 (not a percentage). The dashboard correctly shows this as 0.71.

---

## Prevention Recommendations

1. **Data Source Documentation**: Clearly document which Excel sheet/rows are the authoritative source for CSI calculations:
   - Use "26 vs 25 Q Comparison" sheet FY totals
   - NOT "APAC BURC" monthly breakdown

2. **Sync Script Enhancement**: Update `scripts/sync-burc-monthly.mjs` to:
   - Read from correct sheet for forecast data
   - Include Business Case NR in Total NR calculation
   - Validate calculated ratios against Excel CSI ratio rows

3. **Validation Check**: Add post-sync validation comparing:
   - Dashboard ratios vs Excel Row 65-69 values
   - Alert if any ratio differs by >1%

---

## Related Files

- `src/app/api/analytics/burc/csi-ratios/route.ts` - CSI ratio calculation logic
- `scripts/fix-2026-csi-opex.mjs` - Fix script created
- `scripts/sync-burc-monthly.mjs` - BURC data sync (needs review)
- `burc_csi_opex` table - Stores underlying revenue and OPEX values

---

## Scripts Created

| Script | Purpose |
|--------|---------|
| `scripts/fix-2026-csi-opex.mjs` | Update 2026 values from Excel FY totals |
| `scripts/check-2026-csi-structure.mjs` | Analyse Excel column structure |
| `scripts/get-2026-opex-values.mjs` | Extract OPEX values from Excel |
| `scripts/investigate-ga-ratio.mjs` | Debug G&A ratio discrepancy |
| `scripts/check-2026-monthly-values.mjs` | Compare monthly vs FY values |
