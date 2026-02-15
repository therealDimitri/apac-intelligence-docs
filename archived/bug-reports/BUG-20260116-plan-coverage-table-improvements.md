# Enhancement Report: Plan Coverage Table Improvements

**Date**: 16 January 2026
**Status**: Completed
**Severity**: Enhancement
**Component**: Strategic Planning Wizard - Opportunity Strategy Step

## Issues Addressed

1. **Table height too small** - Only showing ~5 opportunities before scrolling
2. **Vertical alignment** - Checkbox, logo, and text not vertically aligned
3. **MEDDPICC column heading** - "Progress" renamed to "Score" for clarity

## Solutions Applied

**File**: `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`

### 1. Increased Table Height

Changed max-height from 280px to 480px to show more opportunities without scrolling.

```typescript
// Before
<div className="divide-y divide-gray-100 max-h-[280px] overflow-y-auto -mx-4">

// After
<div className="divide-y divide-gray-100 max-h-[480px] overflow-y-auto -mx-4">
```

### 2. Fixed Vertical Alignment

Changed flex alignment to center for proper vertical alignment of checkbox, logo, and text.

```typescript
// Before
<div className="col-span-5 flex items-start gap-3 min-w-0">

// After
<div className="col-span-5 flex items-center gap-3 min-w-0">
```

Also added `flex-shrink-0` to the ClientLogoDisplay to prevent logo compression:

```typescript
<ClientLogoDisplay clientName={opp.client_name} size="xs" className="flex-shrink-0" />
```

### 3. Renamed MEDDPICC Column

Changed "Progress" to "Score" in the MEDDPICC section header.

```typescript
// Before
<div className="col-span-2 text-center">Progress</div>

// After
<div className="col-span-2 text-center">Score</div>
```

## Benefits

1. **More visible opportunities** - ~10-12 opportunities visible vs ~5 previously
2. **Consistent alignment** - Checkbox, logo, and text vertically centered
3. **Clearer terminology** - "Score" more accurately describes MEDDPICC values

## Testing

- TypeScript compilation: Passed
- Build compilation: Passed
- Visual testing: Verified in browser

## Related Commits

- `55a14873`: fix: Increase Plan Coverage table height to show more opportunities
- `fc8698ba`: fix: Improve Plan Coverage alignment and rename MEDDPICC column
- `781e8f65`: fix: Vertically center checkbox, logo and text in Plan Coverage

## Related Files

- `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`
