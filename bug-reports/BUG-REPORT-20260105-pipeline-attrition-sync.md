# Bug Report: Pipeline and Attrition Data Sync

**Date:** 2026-01-05
**Severity:** High
**Status:** Resolved
**Component:** BURC Dashboard / Data Sync

---

## Summary

The BURC Executive Dashboard was showing $0 for Pipeline, Revenue at Risk, and Net Revenue Impact metrics. Investigation revealed the data wasn't being synced from the correct source sheets in the 2026 APAC Performance.xlsx file.

---

## Root Cause

1. **Missing Data Sources**: Pipeline data was not being extracted from the correct sheets:
   - "Rats and Mice Only" (for <$50K items)
   - "Dial 2 Risk Profile Summary" (for >=50K items)

2. **Incorrect Probability Weighting**: The original approach used forecast category (Best Case/Business Case/Pipeline) for probability weighting, but the correct approach is to use section COLOUR in the Dial 2 sheet:
   - **Green** = 90% probability (high likelihood to close)
   - **Yellow** = 50% probability (mid-range)
   - **Red** = 20% probability (unlikely)

3. **Missing Reversal Items**: Items with negative values (reversals like "WA Health Renewal - Reversal Component") were being incorrectly filtered out by the `totalRevenue === 0` check.

4. **Database Schema Issues**: The `burc_pipeline_detail` table was missing required columns for weighted calculations.

---

## Changes Made

### New Script: `scripts/sync-pipeline-and-attrition.mjs`

Created a new sync script that:
- Extracts pipeline data from both R&M and Dial 2 sheets
- Tracks section colours (Green/Yellow/Red) for probability weighting
- Allows negative values (reversals) while skipping zero-revenue items
- Deduplicates items between sheets
- Syncs attrition data from the "Attrition" sheet

### Database Schema Updates

**Migration:** `docs/migrations/20260105_fix_pipeline_and_attrition_sources.sql`

Added columns to `burc_pipeline_detail`:
- `weighted_revenue` - Revenue * probability
- `probability` - Section-based probability (0.2-0.9)
- `oracle_agreement` - Oracle contract reference

Added columns to `burc_attrition`:
- `risk_type` - Full/Partial attrition
- `forecast_date` - When attrition is expected
- `revenue_2025` through `revenue_2028` - Multi-year impact
- `total_at_risk` - Total revenue at risk across all years

### View Updates

Updated `burc_executive_summary` view to calculate:
- `total_pipeline` - Sum of all pipeline revenue
- `weighted_pipeline` - Sum of probability-weighted revenue
- `total_at_risk` - Sum of 2026 attrition revenue

---

## Verification

### Before Fix
| Metric | Value |
|--------|-------|
| Total Pipeline | $0 |
| Weighted Pipeline | $0 |
| Revenue at Risk | $0 |
| Net Revenue Impact | $0 |

### After Fix
| Metric | Value |
|--------|-------|
| Total Pipeline | $23,315,061 |
| Weighted Pipeline | $13,140,313 |
| Revenue at Risk | $675,000 |
| Net Revenue Impact | $12,465,313 |

### Pipeline by Category
| Category | Items | Revenue |
|----------|-------|---------|
| Best Case | 24 | (high probability) |
| Business Case | 8 | (medium probability) |
| Pipeline | 44 | (lower probability) |
| **Total** | **76** | **$23,315,061** |

### Probability Weighting by Section
| Section | Probability | Items | Total | Weighted |
|---------|-------------|-------|-------|----------|
| GREEN | 90% | 16 | $7,929,421 | $7,136,479 |
| YELLOW/BC | 50% | 32 | $7,235,195 | $3,617,595 |
| PIPELINE | 30% | 44 | $7,561,491 | $2,268,447 |
| RED | 20% | 1 | $588,960 | $117,792 |

---

## Files Modified

1. `scripts/sync-pipeline-and-attrition.mjs` - New sync script
2. `docs/migrations/20260105_fix_pipeline_and_attrition_sources.sql` - Schema changes
3. `docs/migrations/20260105_add_retention_columns.sql` - NRR/GRR columns

---

## Prevention

1. **Data Validation**: The sync script now outputs category counts to verify all items are captured
2. **Source Documentation**: Added comments in the script documenting the correct data sources
3. **Section Tracking**: Implemented proper section tracking for colour-based probability weighting

---

## Related Tickets

- BURC Dashboard showing incorrect metrics
- NRR/GRR calculation implementation
- Rule of 40 calculation fix
