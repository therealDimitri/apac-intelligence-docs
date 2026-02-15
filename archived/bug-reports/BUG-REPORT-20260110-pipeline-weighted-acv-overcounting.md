# Bug Report: Pipeline Weighted ACV Overcounting

**Date:** 10 January 2026
**Severity:** Critical (Impacts Compensation Calculations)
**Status:** Fixed
**Component:** Planning Hub / Pipeline Context

---

## Summary

The Planning Hub Performance dashboard was displaying incorrect Weighted ACV totals ($22.2M) compared to the Sales Budget Excel ($8.3M). This was caused by including ALL pipeline opportunities regardless of their "In or Out" target status.

---

## Impact

- **Compensation calculations could be incorrect** - Pipeline values are used for target tracking
- **Misleading performance metrics** - CSEs appeared to have much higher pipeline than reality
- **Dashboard showed $22.2M** when correct value is **$8.3M**

---

## Root Cause

The pipeline data import from "APAC Pipeline by Qtr (2)" sheet was including all 155 opportunities without filtering by the "In or Out" column.

**Business Rules (not implemented):**
1. "In" opportunities → Count towards Sales Budget target
2. "Out" BUT in BURC → Show but don't count towards target
3. "Out" AND NOT in BURC → Exclude entirely

---

## Fix Applied

### 1. Added `PipelineTargetStatus` Type

```typescript
export type PipelineTargetStatus = 'in_target' | 'burc_only' | 'excluded'
```

- `in_target`: Counts towards Sales Budget target/compensation
- `burc_only`: Show with badge, doesn't count towards target
- `excluded`: Filtered out entirely

### 2. Updated Pipeline Filtering Logic

```typescript
// In usePipelineOpportunities hook
salesBudgetResult.data.forEach(row => {
  const isInTarget = row.in_or_out === 'In'
  const isBurcMatched = row.burc_matched ?? false

  let targetStatus: PipelineTargetStatus
  if (isInTarget) {
    targetStatus = 'in_target'
  } else if (isBurcMatched) {
    targetStatus = 'burc_only'
  } else {
    // "Out" and not in BURC - EXCLUDE entirely
    return // Skip this opportunity
  }
  // ... add opportunity with target_status
})
```

### 3. Updated Stats Calculation

```typescript
// Only count 'in_target' opportunities for compensation metrics
const salesBudgetInTarget = opportunities.filter(
  o => o.source === 'sales_budget' && o.target_status === 'in_target'
)
const totalWeightedPipeline = salesBudgetInTarget.reduce(
  (sum, o) => sum + o.weighted_acv, 0
)
```

---

## Results

| Metric | Before | After | Excel Target |
|--------|--------|-------|--------------|
| Total Opportunities | 155 | 92 included | - |
| Excluded | 0 | 63 | - |
| Weighted ACV | $22.2M | **$8.8M** | $8.3M |

### Console Log Output
```
[usePipelineOpportunities] Sales Budget: 92 included, 63 excluded (Out + not in BURC)
[usePipelineOpportunities] Loaded 183 opportunities:
  - BURC: 91
  - Sales Budget: 92
  - In Target (counts for compensation): 179
  - BURC Only (badge, no compensation): 4
  - In-Target Weighted ACV (Sales Budget): $8.79M
```

---

## Files Changed

- `src/contexts/PlanningPortfolioContext.tsx`
  - Added `PipelineTargetStatus` type
  - Added `target_status` field to `PipelineOpportunity` interface
  - Updated `usePipelineOpportunities` hook with filtering logic
  - Updated `stats` calculation to only count 'in_target'
  - Updated `territoryPerformance` calculation to only count 'in_target'

---

## Testing

1. Build verification: `npm run build` passes
2. Console shows correct filtering counts
3. Dashboard displays $8.8M (within ~$500K of Excel $8.3M)
4. Individual CSE cards show reduced, accurate pipeline values

---

## Remaining Difference ($8.8M vs $8.3M) - RESOLVED

### Root Cause Identified

The $451K variance was caused by **one specific opportunity**:

| Opportunity | CSE | Weighted ACV | Issue |
|------------|-----|--------------|-------|
| WA Health Opal Enterprise License 2026 | John Salisbury | $450,576 | `in_or_out = "In"` but `forecast_category = "Omitted"` |

**Business Rule Discovery:** Excel excludes opportunities with `forecast_category = "Omitted"` from the target totals, even when they're marked "In". This is because "Omitted" indicates the deal has been omitted from the sales forecast/compensation calculation.

### Variance Breakdown by CSE

| CSE | Dashboard | Excel | Variance |
|-----|-----------|-------|----------|
| John Salisbury | $1,720.3K | $1,269.6K | +$450.6K |
| Laura Messing | $2,680.3K | $2,680.3K | $0 |
| Open Role | $2,484.2K | $2,484.2K | $0 |
| Tracey Bland | $1,909.3K | $1,909.3K | $0 |

### Fix Applied (Second Phase)

Updated `PipelineTargetStatus` type to include `'omitted'` status:

```typescript
export type PipelineTargetStatus = 'in_target' | 'omitted' | 'burc_only' | 'excluded'
```

Updated filtering logic:
```typescript
const isOmitted = row.forecast_category === 'Omitted'

if (isInTarget && !isOmitted) {
  targetStatus = 'in_target' // Counts towards compensation
} else if (isInTarget && isOmitted) {
  targetStatus = 'omitted' // "In" but omitted from forecast - show but doesn't count
} else if (isBurcMatched) {
  targetStatus = 'burc_only'
} else {
  return // Exclude
}
```

### Final Results

| Metric | Before Fix 1 | After Fix 1 | After Fix 2 | Excel Target |
|--------|-------------|-------------|-------------|--------------|
| Weighted ACV | $22.2M | $8.79M | **$8.34M** | $8.34M |
| Variance | +$13.9M | +$451K | **$0** | - |

**Dashboard now matches Excel exactly.**

---

## Follow-up Tasks

1. Add "BURC Only" badge to opportunities with `target_status === 'burc_only'`
2. ~~Investigate remaining $500K variance~~ **RESOLVED**
3. Add "Omitted" badge to opportunities with `target_status === 'omitted'`
4. Add data validation to ensure In/Out and Forecast Category columns are correctly mapped

---

## Commits

### Fix 1: In/Out Filtering
```
fix(pipeline): Apply correct In/Out filtering for Sales Budget pipeline
Commit: 0d63f220
```

### Fix 2: Omitted Forecast Exclusion
```
fix(pipeline): Exclude 'Omitted' forecast opportunities from in_target count
Commit: d6d8a12a
```
