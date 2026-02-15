# Feature Report: Revenue Targets Auto-Population

**Date:** 10 January 2026
**Component:** Planning Hub / Territory Strategy / Revenue Targets
**Status:** Implemented

---

## Summary

The Revenue Targets step in Territory Strategy planning has been updated to auto-populate quarterly targets from the Sales Budget Excel data, replacing manual input fields.

---

## Before vs After

### Before (Manual Entry)
| Quarter | Renewal Target | Growth Target | Total | Confidence |
|---------|---------------|---------------|-------|------------|
| Q1 2026 | $ (manual)    | $ (manual)    | $0    | Medium     |

**Issues:**
- CSEs had to manually enter targets
- No alignment with official Sales Budget
- Pipeline Status manually entered
- "Renewal" and "Growth" didn't align with business metrics

### After (Auto-Populated)
| Quarter | Total ACV | Wgt ACV Target | Wgt ACV Pipeline | ACV Net COGS | Coverage | Confidence |
|---------|-----------|----------------|------------------|--------------|----------|------------|
| Q1 2026 | $500,000 (auto) | $317,407 (auto) | $285,000 (auto) | $118,029 (auto) | 0.90x | Medium (auto→editable) |

**Improvements:**
- Targets auto-loaded from `cse_cam_targets` table
- Pipeline calculated from `sales_pipeline_opportunities`
- **Total ACV** added - full contract value before probability weighting
- Coverage ratio auto-calculated with colour coding
- Confidence auto-set based on coverage (user can override)
- ACV Net COGS for EBITDA alignment
- Enhanced tooltips with metric definitions on all column headers

---

## Metrics Alignment

| Metric | Business Purpose | Source |
|--------|-----------------|--------|
| **Total ACV Target** | Full contract value before probability weighting | `cse_cam_targets.total_acv_target` |
| **Wgt ACV Target** | Primary CSE compensation metric (probability-adjusted) | `cse_cam_targets.weighted_acv_target` |
| **Wgt ACV Pipeline** | Sales forecasting (probability-adjusted) | Sum of `sales_pipeline_opportunities.weighted_acv` WHERE `in_or_out='In'` AND `forecast_category != 'Omitted'` |
| **ACV Net COGS Target** | EBITDA/profitability alignment (gross margin) | `cse_cam_targets.acv_net_cogs_target` |
| **Coverage** | Pipeline health indicator | Wgt ACV Pipeline / Wgt ACV Target |

**Note:** For Term License deals, Weighted ACV may exceed Total ACV as the weighting calculation differs.

---

## Coverage Colour Coding

| Coverage | Colour | Meaning |
|----------|--------|---------|
| ≥ 1.0x | Green | Target covered |
| 0.5x - 1.0x | Amber | Partial coverage |
| < 0.5x | Red | Insufficient pipeline |

**Best Practice:** 3.0x coverage for predictable target achievement

---

## Pipeline Status (Now Auto-Calculated)

The Current Pipeline Status section is now read-only and displays 4 cards:
- **Total ACV Pipeline** - Full contract value (unweighted) of all 'In' opportunities
- **Weighted ACV Pipeline** - Probability-adjusted sum of all 'In' opportunities
- **Coverage Ratio** - Overall FY pipeline / target (colour-coded)
- **Avg Deal Size** - Based on active opportunities

---

## Data Flow

```
CSE Selection
     ↓
Load cse_cam_targets (by CSE name, FY2026, role='CSE')
     ↓
Load sales_pipeline_opportunities (by CSE name, in_or_out='In', forecast_category != 'Omitted')
     ↓
Group pipeline by fiscal_period (Q1, Q2, Q3, Q4)
     ↓
Calculate coverage for each quarter
     ↓
Auto-set confidence (High ≥1.0x, Medium ≥0.5x, Low <0.5x)
     ↓
Populate form with auto-calculated values
```

---

## Files Changed

- `src/app/(dashboard)/planning/territory/new/page.tsx`
  - Updated `QuarterlyTarget` interface
  - New data loading from `cse_cam_targets` and `sales_pipeline_opportunities`
  - Updated UI with new metric columns
  - Auto-calculated Pipeline Status
  - Updated AI Coach prompts

- `src/components/planning/CSEPerformanceDashboard.tsx`
  - Added `totalAcvNetCogs` prop support

- `src/contexts/PlanningPortfolioContext.tsx`
  - Added `totalAcvNetCogs` to `PlanningStats` interface

---

## Database Tables Used

### cse_cam_targets
```sql
SELECT quarter, weighted_acv_target, acv_net_cogs_target, total_acv_target
FROM cse_cam_targets
WHERE fiscal_year = 2026
  AND cse_cam_name = '{cseName}'
  AND role_type = 'CSE'
```

### sales_pipeline_opportunities
```sql
SELECT fiscal_period, total_acv, weighted_acv, acv_net_cogs, opportunity_name, account_name
FROM sales_pipeline_opportunities
WHERE cse_name = '{cseName}'
  AND in_or_out = 'In'
  AND forecast_category != 'Omitted'
```

---

## User Experience

1. **Informational Banner** - Blue info box explaining auto-population
2. **Read-Only Targets** - Values loaded from official sources
3. **Editable Confidence** - User can override auto-set confidence
4. **Visual Indicators** - Colour-coded coverage badges
5. **Summary Cards** - Pipeline Status displayed as read-only cards

---

## Testing

1. Build verification: `npm run build` passes
2. CSE selection loads targets correctly
3. Pipeline values match Sales Budget Excel
4. Coverage calculations accurate
5. Confidence auto-sets based on coverage
6. AI Coach prompts include new metrics

---

## Commits

```
feat(planning): Auto-populate Revenue Targets from Sales Budget
Commit: 270d9f7d
```

```
feat(planning): Add Total ACV column to Revenue Targets table
Commit: c481b4e1
- Added totalAcv field to QuarterlyTarget interface
- Reordered columns: Quarter, Total ACV, Wgt ACV Target, Wgt ACV Pipeline, ACV NET COGS, Coverage, Confidence
- Enhanced tooltips with metric definitions
- Added Total ACV Pipeline card to Current Pipeline Status (now 4 cards)
```
