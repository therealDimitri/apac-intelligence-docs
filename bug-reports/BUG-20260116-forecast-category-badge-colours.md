# Enhancement Report: Forecast Category Badge Colour Coding

**Date**: 16 January 2026
**Status**: Completed
**Severity**: Enhancement
**Component**: Strategic Planning Wizard - Opportunity Strategy Step

## Issue Description

The Plan Coverage table displayed all forecast category badges in the same grey colour, making it difficult to quickly identify opportunity categories at a glance.

## Solution Applied

**File**: `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`

### Added Colour-Coded Badge Helper Function

```typescript
// Helper to get forecast category badge colours
// Best Case = Green, Bus Case = Blue, Pipeline = Purple
const getCategoryBadgeColors = (
  stage: string,
  isIncluded: boolean
): { bg: string; text: string } => {
  if (!isIncluded) {
    return { bg: 'bg-gray-200/50', text: 'text-gray-500' }
  }

  const stageLower = stage.toLowerCase()

  if (stageLower.includes('best case') || stageLower === 'best_case') {
    return { bg: 'bg-emerald-100', text: 'text-emerald-700' }
  }
  if (
    stageLower.includes('bus case') ||
    stageLower.includes('business case') ||
    stageLower === 'business_case'
  ) {
    return { bg: 'bg-blue-100', text: 'text-blue-700' }
  }
  if (stageLower.includes('pipeline')) {
    return { bg: 'bg-purple-100', text: 'text-purple-700' }
  }
  if (stageLower.includes('backlog')) {
    return { bg: 'bg-amber-100', text: 'text-amber-700' }
  }

  // Default gray for other stages
  return { bg: 'bg-gray-100', text: 'text-gray-700' }
}
```

### Colour Mapping

| Category | Background | Text | Visual |
|----------|------------|------|--------|
| Best Case | bg-emerald-100 | text-emerald-700 | 🟢 Green |
| Bus Case / Business Case | bg-blue-100 | text-blue-700 | 🔵 Blue |
| Pipeline | bg-purple-100 | text-purple-700 | 🟣 Purple |
| Backlog | bg-amber-100 | text-amber-700 | 🟠 Amber |
| Other | bg-gray-100 | text-gray-700 | ⚪ Gray |
| Excluded | bg-gray-200/50 | text-gray-500 | ⚪ Muted Gray |

### Updated Badge Rendering

```typescript
{/* Stage/Source - 2 cols */}
<div className="col-span-2 flex flex-col items-center justify-center text-center gap-1">
  {(() => {
    const colors = getCategoryBadgeColors(opp.stage, isIncluded)
    return (
      <span
        className={`text-xs px-2.5 py-1 rounded-full font-medium whitespace-nowrap ${colors.bg} ${colors.text}`}
      >
        {opp.stage.replace('_', ' ').replace(/\b\w/g, c => c.toUpperCase())}
      </span>
    )
  })()}
  {opp.is_burc && (
    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ...`}>
      BURC
    </span>
  )}
</div>
```

## Data Source

The `forecast_category` value is loaded from the `sales_pipeline_opportunities` table in Supabase, which is populated from the **2026 APAC Performance.xlsx** Excel file via the pipeline sync process.

## Benefits

1. **Quick visual scanning** - Instantly identify opportunity categories
2. **Consistent with BURC reporting** - Colours align with BURC matrix categories
3. **Excluded state handling** - Excluded opportunities show muted colours
4. **Flexible matching** - Handles various naming conventions (underscores, different cases)

## Testing

- TypeScript compilation: Passed
- Build compilation: Passed
- Visual testing: Verified in browser

## Related Commits

- `d3a15159`: feat: Color-code forecast category badges in Plan Coverage

## Related Files

- `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`
- `src/app/(dashboard)/planning/strategic/new/page.tsx` (loads forecast_category from database)
