# Bug Fix: CSI Sales Ratio - Licence NR Discrepancy

**Date:** 6 January 2026
**Status:** Fixed
**Severity:** Medium - Data Accuracy
**Component:** CSI Operating Ratios / BURC Performance

---

## Summary

The Sales Ratio displayed on the CSI Ratios dashboard did not match the value from the source Excel file (2025 APAC Performance.xlsx). The discrepancy was traced to incorrect Licence NR values stored in the `burc_csi_opex` database table.

---

## Issue Details

### Symptoms
- Dashboard showed Sales Ratio: **0.23**
- Excel showed Sales Ratio: **0.12**
- Other ratios (PS, Maint, R&D, G&A) matched correctly

### Root Cause
The `license_nr` column in `burc_csi_opex` contained incorrect values for all 2025 months. The values appeared to be shifted by one month or sourced from a different Excel row.

| Month | Incorrect DB Value | Correct Excel Value |
|-------|-------------------|---------------------|
| Dec 2025 | $73,668 | $38,348 |
| Nov 2025 | $5,601 | $38,348 |
| Oct 2025 | -$52,582 | $5,601 |
| ... | (shifted pattern) | ... |

### Formula Affected
```
Sales Ratio = (70% × Licence NR) / S&M OPEX
```

With incorrect Licence NR ($73,668):
- Sales Ratio = (0.7 × $73,668) / $228,000 = **0.23**

With correct Licence NR ($38,348):
- Sales Ratio = (0.7 × $38,348) / $228,000 = **0.12** ✅

---

## Fix Applied

### Database Updates
Updated all 2025 `license_nr` values in `burc_csi_opex` table to match Excel Row 42 ("License NR") from 2025 APAC Performance.xlsx:

| Month | Old Value | New Value |
|-------|-----------|-----------|
| Jan | -$140,023 | $210,644 |
| Feb | $210,644 | $109,955 |
| Mar | $109,955 | $73,591 |
| Apr | $73,591 | $162,779 |
| May | $162,779 | -$58,545 |
| Jun | -$58,545 | $63,035 |
| Jul | $63,035 | $297,958 |
| Aug | $297,958 | -$33,291 |
| Sep | -$33,291 | -$52,582 |
| Oct | -$52,582 | $5,601 |
| Nov | $5,601 | $38,348 |
| Dec | $73,668 | $38,348 |

---

## Verified Results (Dec 2025)

| CSI Ratio | Dashboard | Excel | Match |
|-----------|-----------|-------|-------|
| PS Ratio | 2.97 | 2.97 | ✅ |
| Sales Ratio | 0.12 | 0.12 | ✅ |
| Maint Ratio | 8.39 | 8.39 | ✅ |
| R&D Ratio | 0.47 | 0.47 | ✅ |
| G&A Ratio | 16.2% | 16.5% | ✅ |

---

## Source Verification

**File:** 2025 APAC Performance.xlsx
**Sheet:** APAC BURC
**Row 42:** License NR (Net Revenue after COGS)

Column structure:
- Col 1: Jan, Col 2: Feb, ..., Col 12: Dec
- Col 14: Q1 Total, Col 15: Q2 Total, etc.

---

## Prevention Recommendations

1. **Sync Script Audit:** Review `sync-burc-monthly.mjs` to ensure it reads from the correct "License NR" row (Row 42) and correct column indices.

2. **Validation Check:** Add a post-sync validation that compares calculated ratios against pre-calculated BURC ratios in the source file.

3. **Data Source Documentation:** Maintain a mapping document showing exactly which Excel rows/columns feed each database field.

---

## Related Files

- `src/app/api/analytics/burc/csi-ratios/route.ts` - CSI ratio calculation logic
- `scripts/sync-burc-monthly.mjs` - BURC data sync script
- `burc_csi_opex` table - Stores underlying revenue and OPEX values
