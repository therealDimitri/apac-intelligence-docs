# Enhancement Report: MacBook Display Optimisation - Left Rail Metrics Redesign

**Date**: 16 January 2026
**Status**: Completed
**Severity**: Enhancement
**Component**: Strategic Planning Wizard - Opportunity Strategy Step

## Issue Description

The Opportunity Strategy page had a sticky horizontal metrics bar that:
1. Contained 8 metrics competing for horizontal space
2. Caused content clipping on 14" MacBook displays (probability legend "Low (<40%)" was cut off)
3. Created information overload with no clear hierarchy
4. Duplicated metrics between sticky bar and left rail "Quick Stats"

## Solution Applied

**File**: `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`

### Design Changes

Consolidated all metrics from the sticky header into an expanded left navigation rail, following design patterns from Linear, Stripe, Notion, and Figma.

### New Left Rail Structure (Final Design)

1. **Section Progress** (at top)
   - Percentage complete with progress bar
   - "X/Y sections" subtitle

2. **Section Navigation** (directly under progress)
   - AI Tips, Coverage, MEDDPICC, StoryBrand buttons
   - Active state highlighting with chevron indicator
   - Status text below each label

3. **Pipeline Metrics**
   - Deals Included (X/Y with compact layout)
   - Focus Deals (X/Y with amber highlighting)

4. **ACV Performance**
   - Total ACV, Weighted ACV, Target values
   - Gap Indicator with semantic colouring

5. **MEDDPICC Score**
   - Score/40 with percentage

### Technical Changes

```typescript
// Rail width optimised for compact display
// Before: w-48 (192px)
// Final: w-52 (208px) - narrower than initial redesign

// Compact spacing throughout
<div className="sticky top-32 space-y-2 max-h-[calc(100vh-160px)] overflow-y-auto scrollbar-thin scrollbar-thumb-gray-300 pr-1">

// Removed sticky metrics bar entirely (was ~80 lines of code)
```

### Visual Hierarchy (Compact)

- **Section headers**: `text-[10px] font-semibold uppercase tracking-wider text-gray-400`
- **Metric labels**: `text-[10px] text-gray-500`
- **Primary values**: `text-sm font-semibold tabular-nums` with semantic colours
- **Progress bars**: `h-1.5 rounded-full` with colour coding
- **Navigation buttons**: `text-xs` labels with `text-[10px]` status text

### Semantic Colouring

| State | Colour | Usage |
|-------|--------|-------|
| Positive gap | emerald-50/200/700 | Target met or exceeded |
| Negative gap | red-50/200/700 | Below target |
| Deals included | blue-500 | Progress bar |
| Focus deals | amber-500/600 | Highlight strategic deals |
| Total ACV | indigo-500/600 | Financial primary |
| Weighted ACV | emerald-500/600 | Financial weighted |
| MEDDPICC | purple-500/600 | Qualification metric |
| MEDDPICC empty | gray-300/400 | Empty state |
| MEDDPICC low | amber-500/600 | Warning state (<50%) |

## Benefits

1. **More vertical space** - Removed horizontal sticky bar
2. **No content clipping** - Probability legend fully visible
3. **Clear hierarchy** - Metrics grouped by category
4. **Better scannability** - Progress bars provide visual context
5. **MacBook optimised** - Works on 14" (1512px) and 16" (1728px) displays
6. **Reduced redundancy** - No duplicate metrics between areas

## Testing

- TypeScript compilation: Passed
- Build compilation: Passed
- Visual testing: Verified on browser
- Responsive: Works on 14" and 16" MacBook displays

## Related Files

- `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`
