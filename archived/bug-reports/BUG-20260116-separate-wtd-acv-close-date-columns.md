# Enhancement Report: Separate Wtd ACV and Close Date Columns

**Date**: 16 January 2026
**Status**: Completed
**Severity**: Enhancement
**Component**: Strategic Planning Wizard - Opportunity Strategy Step

## Issue Description

The Plan Coverage table had a combined "Wtd ACV/Close Date" column that displayed both values stacked vertically. User requested:
1. Separate into two individual columns
2. Add fiscal quarter indicator to the close date

## Solution Applied

**File**: `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`

### 1. Added Fiscal Quarter Helper Function

Added a helper function to calculate the Australian fiscal quarter (July-June fiscal year):

```typescript
// Helper to get Australian fiscal quarter (July-June fiscal year)
// Q1: Jul-Sep, Q2: Oct-Dec, Q3: Jan-Mar, Q4: Apr-Jun
const getFiscalQuarter = (date: Date): string => {
  const month = date.getMonth() + 1 // 1-12
  if (month >= 7 && month <= 9) return 'Q1'
  if (month >= 10 && month <= 12) return 'Q2'
  if (month >= 1 && month <= 3) return 'Q3'
  return 'Q4' // Apr-Jun
}
```

### 2. Updated Grid Layout

Adjusted column spans to accommodate the additional column:

| Column | Before | After |
|--------|--------|-------|
| Opportunity | col-span-5 | col-span-4 |
| Stage/Source | col-span-3 | col-span-2 |
| Wtd ACV | col-span-2 (combined) | col-span-2 |
| Close Date | (combined with ACV) | col-span-2 |
| Probability | col-span-2 | col-span-2 |

Total: 12 columns (unchanged)

### 3. Updated Column Headers

```typescript
// Before
<div className="col-span-2 text-center">Wtd ACV/Close Date</div>

// After
<div className="col-span-2 text-center">Wtd ACV</div>
<div className="col-span-2 text-center">Close Date</div>
```

### 4. Split Data Cells

**Before** (combined):
```typescript
<div className="col-span-2 flex flex-col items-center justify-center text-center">
  <p>${(opp.weighted_acv / 1000).toFixed(0)}k</p>
  <p>{date}</p>
</div>
```

**After** (separate):
```typescript
{/* Weighted ACV - 2 cols */}
<div className="col-span-2 flex items-center justify-center text-center">
  <p>${(opp.weighted_acv / 1000).toFixed(0)}k</p>
</div>

{/* Close Date - 2 cols */}
<div className="col-span-2 flex items-center justify-center text-center">
  <p>{date} <span className="text-xs text-gray-500">{getFiscalQuarter(new Date(opp.close_date))}</span></p>
</div>
```

## Display Format

Close dates now display as: `15 Feb Q3`

Where the quarter uses Australian fiscal year:
- Q1: July-September
- Q2: October-December
- Q3: January-March
- Q4: April-June

## Benefits

1. **Clearer data presentation** - Each metric has its own column
2. **Fiscal context** - Quarter indicator provides immediate planning context
3. **Better alignment** - Single-line values are easier to scan
4. **Consistent grid** - Still uses 12-column grid system

## Testing

- TypeScript compilation: Passed
- Build compilation: Passed
- Visual testing: Verified in browser

## Related Commits

- `13de95bd`: fix: Separate Wtd ACV and Close Date into individual columns

## Related Files

- `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`
