# CSI Operating Ratios Verification Report

**Date:** 3 January 2026
**Status:** Verified - Data Accurate
**Priority:** Informational

## Summary

User reported Sales Ratio showing 0.00 and Forecast Confidence at 6%. Investigation confirmed these values are **accurate reflections of the underlying BURC data**, not bugs.

## Findings

### 1. Sales Ratio = 0.00 (Jan 2026)

**Root Cause:** No licence deals closed for most of 2026.

The Sales Ratio formula is:
```
Sales Ratio = (0.7 × License Net Revenue) ÷ S&M OPEX
```

**Source Data (burc_csi_opex table):**

| Month | License NR | S&M OPEX | Calculated Ratio |
|-------|-----------|----------|------------------|
| Jan | $0 | $220k | 0.00 |
| Feb | $0 | $220k | 0.00 |
| Mar | $0 | $220k | 0.00 |
| Apr | $0 | $220k | 0.00 |
| May | $0 | $220k | 0.00 |
| **Jun** | **$19k** | $221k | **0.06** |
| **Jul** | **$1,909k** | $277k | **4.83** |
| Aug | $0 | $220k | 0.00 |
| Sep | $0 | $220k | 0.00 |
| Oct | $0 | $220k | 0.00 |
| Nov | $0 | $220k | 0.00 |
| Dec | $0 | $220k | 0.00 |

**Conclusion:** Only June ($19k) and July ($1.9M) have licence revenue recorded. This is accurate - no other licence deals have been booked/closed yet.

### 2. Data Coverage: 48 Months ✓

| Year | Records |
|------|---------|
| 2023 | 12 months |
| 2024 | 12 months |
| 2025 | 12 months |
| 2026 | 12 months |
| **Total** | **48 months** |

### 3. Forecast Confidence: 6%

**Explanation:** Forecast confidence is calculated as Average R² × 100 across all 5 ratios.

With Sales Ratio having 10/12 months at 0, the linear regression cannot establish a meaningful trend, resulting in R² ≈ 0 for that ratio. This drags down the overall average.

**This is expected behaviour** - the model correctly indicates low confidence when data patterns are sparse or inconsistent.

### 4. All CSI Ratios Verification (Jan 2026)

| Ratio | Actual | Plan | Target | Status | Notes |
|-------|--------|------|--------|--------|-------|
| PS | 1.89 | 2.38 | ≥2.0 | 🟠 Amber | Slightly below target |
| Sales | 0.00 | 0.44 | ≥1.0 | 🔴 Red | No licence revenue Jan |
| Maint | 4.58 | 5.99 | ≥4.0 | 🟢 Green | Meeting target |
| R&D | 0.24 | 0.38 | ≥1.0 | 🔴 Red | Low due to minimal licence rev |
| G&A | 22.30% | 17.58% | ≤20% | 🟠 Amber | Slightly above target |

### 5. Year-over-Year Comparison

| Year | Avg PS | Avg Sales | Avg Maint | Avg R&D | Avg G&A |
|------|--------|-----------|-----------|---------|---------|
| 2023 | 1.50 | 0.36 | 11.26 | 1.87 | 16.79% |
| 2024 | 2.52 | 0.26 | 7.31 | 0.34 | 15.19% |
| 2025 | 1.92 | 0.26 | 7.00 | 0.32 | 13.62% |
| 2026 | 2.34 | 0.41 | 5.87 | 0.36 | 17.96% |

## Resolution

**No code changes required.** The dashboard is correctly displaying the actual financial data from BURC source files.

### Recommendations

1. **Sales Ratio will improve** as licence deals close throughout 2026 (July already shows $1.9M)
2. **Forecast Confidence will increase** as more consistent monthly data becomes available
3. Consider adding a tooltip explaining that 0 values indicate no licence revenue for that period

## Files Reviewed

- `src/app/api/analytics/burc/csi-ratios/route.ts` - Ratio calculation logic
- `src/lib/csi-analytics.ts` - Forecast confidence calculation
- `scripts/check-csi-ratios.mjs` - Verification script

## Verification Script

Created `scripts/check-csi-ratios.mjs` which verifies:
- burc_csi_ratios table data
- burc_csi_opex source data
- License revenue metrics
- Quarterly data

Run with: `node --env-file=.env.local scripts/check-csi-ratios.mjs`
