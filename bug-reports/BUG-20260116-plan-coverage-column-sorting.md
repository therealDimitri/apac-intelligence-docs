# Enhancement Report: Plan Coverage Column Sorting

**Date**: 16 January 2026
**Status**: Completed
**Severity**: Enhancement
**Component**: Strategic Planning Wizard - Opportunity Strategy Step

## Issue Description

The Plan Coverage table lacked sorting functionality, making it difficult to organise and analyse opportunities by different criteria.

## Solution Applied

**File**: `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`

### Added Sort State and Logic

```typescript
// Sort state for Plan Coverage table
const [sortColumn, setSortColumn] = useState<
  'opportunity' | 'stage' | 'acv' | 'closeDate' | 'probability' | null
>(null)
const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('asc')

// Handle column sort click
const handleSort = useCallback(
  (column: 'opportunity' | 'stage' | 'acv' | 'closeDate' | 'probability') => {
    if (sortColumn === column) {
      // Toggle direction or clear sort
      if (sortDirection === 'asc') {
        setSortDirection('desc')
      } else {
        setSortColumn(null)
        setSortDirection('asc')
      }
    } else {
      setSortColumn(column)
      setSortDirection('asc')
    }
  },
  [sortColumn, sortDirection]
)
```

### Sort Behaviour

| Click | Action |
|-------|--------|
| 1st | Sort ascending (A-Z, lowest first) |
| 2nd | Sort descending (Z-A, highest first) |
| 3rd | Clear sort (return to default order) |

### Sortable Columns

| Column | Sort Type |
|--------|-----------|
| Opportunity | Alphabetical by name |
| Stage | Alphabetical by stage name |
| Wtd ACV | Numeric (lowest to highest) |
| Close Date | Chronological (earliest first) |
| Probability | Numeric (lowest to highest) |

### Sort Indicators

- **Unsorted**: `ArrowUpDown` icon (muted)
- **Ascending**: `ArrowUp` icon
- **Descending**: `ArrowDown` icon

### Additional Fix: Probability Dropdown Width

Increased dropdown width from 150px to 170px to prevent "Medium (40-69%)" text from being cut off.

```typescript
// Before
className={`w-[150px] mx-auto ...`}

// After
className={`w-[170px] mx-auto ...`}
```

## Benefits

1. **Better organisation** - Sort by ACV to prioritise high-value deals
2. **Date management** - Sort by close date to track upcoming deadlines
3. **Qualification focus** - Sort by probability to identify deals needing attention
4. **Category analysis** - Sort by stage to group similar opportunities

## Testing

- TypeScript compilation: Passed
- Build compilation: Passed
- Sort functionality: Verified in browser

## Related Commits

- `903a394d`: fix: Centre Close Date and Probability columns in Plan Coverage
- `8d51a96d`: feat: Add column sorting to Plan Coverage table

## Related Files

- `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`
