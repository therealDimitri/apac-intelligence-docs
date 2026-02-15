# Bug Report: BURC Historical Revenue Duplicate Records

**Date:** 6 January 2026
**Severity:** Critical
**Status:** Resolved
**Affected Area:** BURC Performance Dashboard, Revenue Trend Charts

---

## Issue Summary

The `burc_historical_revenue_detail` table contained **46,130 duplicate records**, causing revenue totals to be massively inflated (approximately 2-3x the actual values).

---

## Root Cause

Data import processes had inserted the same revenue records multiple times, likely due to:
1. Multiple import runs without deduplication
2. Re-processing of source files without clearing existing data
3. Monthly BURC files containing cumulative data being imported additively

Example of duplicate severity found:
- GRMC FY2024 Maintenance Revenue: 26 identical records of $-3,565.61
- SA Health FY2024 PS Revenue: 10 identical records of $-33.33
- St Luke's FY2024 Maintenance: Multiple identical line items

---

## Impact

| Metric | Before Fix | After Fix | Over-Counted |
|--------|------------|-----------|--------------|
| Total Records | 84,932 | 38,802 | 46,130 (54%) |
| FY2024 Total | $33,090,198 | $20,326,121 | $12,764,077 |
| FY2023 Total | $30,827,992 | $15,875,520 | $14,952,472 |
| FY2022 Total | $26,644,178 | $12,294,258 | $14,349,921 |

This caused:
- Revenue trend charts showing inflated historical values
- Incorrect YoY growth calculations
- Misleading dashboard metrics

---

## Resolution

### Step 1: Identified Duplicates
Created `scripts/find-duplicates.mjs` to identify records with identical:
- client_name
- fiscal_year
- revenue_type
- amount_usd

### Step 2: Cleaned Up Duplicates
Created `scripts/cleanup-duplicates.mjs` to:
- Keep one record per unique combination
- Delete 46,130 duplicate records
- Verify final totals

### Step 3: Updated Annual Financials
Updated `burc_annual_financials` table with correct source-verified values:

| Year | Gross Revenue | Source |
|------|--------------|--------|
| FY2019 | $13,545,239.22 | Detail records (aggregated) |
| FY2020 | $17,058,722.00 | Detail records (aggregated) |
| FY2021 | $9,636,901.29 | Detail records (aggregated) |
| FY2022 | $12,294,257.67 | Detail records (aggregated) |
| FY2023 | $15,875,520.08 | Detail records (aggregated) |
| FY2024 | $29,351,719.00 | 2024 APAC Performance.xlsx |
| FY2025 | $26,344,602.19 | 2026 APAC Performance.xlsx |
| FY2026 | $33,738,278.35 | 2026 APAC Performance.xlsx |

---

## Known Remaining Issues

1. **FY2024 Detail Gap**: Detail records ($20.3M) only represent 69.3% of the source total ($29.4M). Missing ~$9M in detail records.

2. **Historical Data Quality**: FY2019-2023 totals are from deduplicated detail records but may still be incomplete compared to original source files.

3. **FY2026 Budget**: No detail records exist for FY2026 (budget year) - only annual total available.

---

## Prevention Measures

1. **Add Unique Constraint**: Consider adding a unique constraint on `(client_name, fiscal_year, revenue_type, amount_usd, month)` to prevent future duplicates.

2. **Import Validation**: Implement pre-import checks to detect duplicates before insertion.

3. **Source File Tracking**: Add `import_batch_id` column to track which import session created each record.

---

## Scripts Created

| Script | Purpose |
|--------|---------|
| `scripts/find-duplicates.mjs` | Identify duplicate records |
| `scripts/cleanup-duplicates.mjs` | Remove duplicate records |
| `scripts/compare-totals.mjs` | Compare detail vs annual totals |
| `scripts/update-all-annual-financials.mjs` | Populate annual totals |

---

## Verification

Run `node scripts/compare-totals.mjs` to verify current state:

```
Year     | Detail Records | Detail Total      | Annual Record     | Source Truth
FY2024  |           6763 | $  20,326,121.09 | $     29,351,719 | $     29,351,719
FY2025  |             32 | $  26,344,602.19 | $  26,344,602.19 | $  26,344,602.19
FY2026  |              0 | $              0 | $  33,738,278.35 | $  33,738,278.35
```

Dashboard should now use `burc_annual_financials.gross_revenue` for accurate trend display.
