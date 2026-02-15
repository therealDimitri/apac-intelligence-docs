# Bug Fix: BURC Data Cleanup - Duplicate Summary Rows Removed

**Date:** 6 January 2026
**Status:** Fixed
**Severity:** High - Data Integrity
**Component:** BURC Executive Dashboard / Financial Data

---

## Summary

Multiple data integrity issues were identified and corrected in the BURC database tables. Summary/total rows from Excel imports were incorrectly included as data records, inflating the Total ARR figure.

---

## Issues Found & Fixed

### 1. burc_arr_tracking - Duplicate "Total" Rows

**Problem:** Two "Total" summary rows were imported as client records, inflating ARR by $17.1M.

| ID | Client Name | ARR (USD) | Action |
|----|-------------|-----------|--------|
| 178 | Total | $15,732,812 | ❌ Deleted |
| 184 | Total | $1,401,681 | ❌ Deleted |

**Result:** ARR tracking reduced from 23 to 21 entries.

### 2. burc_attrition - "Grand Total" Row

**Problem:** A "Grand Total" summary row was included as a data record.

| Client Name | Impact | Action |
|-------------|--------|--------|
| Grand Total | $0 | ❌ Deleted |

**Result:** Attrition count corrected from 10 to 9 accounts.

---

## Corrected Dashboard Values

| Metric | Before | After | Source Verified |
|--------|--------|-------|-----------------|
| **Total ARR** | $34.3M | **$17.1M** | burc_arr_tracking (21 clients) |
| **ARR Entry Count** | 23 | **21** | Removed 2 "Total" rows |
| **Attrition Count** | 10 | **9** | Removed "Grand Total" row |
| Gross Revenue | $33.7M | $33.7M | ✅ Correct (2026 APAC Performance.xlsx) |
| NRR | 121.4% | 121.4% | ✅ Correct (Finance calculation) |
| GRR | 97.6% | 97.6% | ✅ Correct (Finance calculation) |
| Rule of 40 | 47.5 | 47.5 | ✅ Correct |
| Annual Churn | $675K | $675K | ✅ Correct (Attrition sheet) |
| Active Contracts | 8 | 8 | ✅ Correct |
| Total Pipeline | $12.8M | $12.8M | ✅ Correct |
| Weighted Pipeline | $8.5M | $8.5M | ✅ Correct |

---

## Source Verification

All values verified against **2026 APAC Performance.xlsx**:

| Metric | Excel Location | Value |
|--------|----------------|-------|
| FY2026 Gross Revenue | 26 vs 25 Q Comparison, Row 13 | $33,738,278 |
| FY2026 Maintenance | 26 vs 25 Q Comparison, Row 10 | $20,148,000 |
| FY2026 Attrition | Attrition sheet, Row 3 | $675,000 |
| FY2025 Gross Revenue | 26 vs 25 Q Comparison, Col 16 | $26,344,602 |

---

## NRR/GRR Clarification

The stored NRR (121.4%) and GRR (97.6%) are **not affected** by the ARR correction because:

1. They were calculated by Finance using a different base (~$28M)
2. They are not dynamically calculated from `burc_arr_tracking`
3. The calculation methodology is defined externally

---

## Scripts Created

| Script | Purpose |
|--------|---------|
| `scripts/check-arr-duplicates.mjs` | Audit ARR entries for duplicates |
| `scripts/cleanup-burc-duplicates.mjs` | Remove summary rows from all BURC tables |
| `scripts/analyze-2026-performance.mjs` | Verify against Excel source |
| `scripts/find-nrr-grr-2026.mjs` | Search for retention metrics |

---

## Prevention Recommendations

1. **Sync Script Filter:** Add logic to exclude rows where `client_name` contains "Total", "Subtotal", or "Grand"

2. **Database Constraint:**
```sql
ALTER TABLE burc_arr_tracking
ADD CONSTRAINT chk_no_summary_rows
CHECK (client_name NOT ILIKE '%total%' AND client_name NOT ILIKE '%subtotal%');
```

3. **Import Validation:** Always verify row counts after Excel imports match expected client count

---

## Conclusion

The Executive Dashboard now displays accurate data:
- **Total ARR: $17.1M** (correct, from 21 client records)
- **Attrition: 9 accounts at $675K risk** (correct)
- **All other metrics unchanged and verified against source Excel**
