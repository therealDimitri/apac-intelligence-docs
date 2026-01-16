# Enhancement Report: ACV Performance Card Layout Redesign

**Date**: 16 January 2026
**Status**: Completed
**Severity**: Enhancement
**Component**: Strategic Planning Wizard - Opportunity Strategy Step

## Issue Description

The ACV Performance card in the left navigation rail needed:
1. Layout change to show plan first, then forecast (was showing forecast first)
2. Conditional colour coding on forecast values to visually indicate whether targets are being met

## Solution Applied

**File**: `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`

### Design Changes

1. **Reordered display**: Plan value now appears first, followed by forecast
2. **Conditional colour coding**:
   - Green (emerald-600) when forecast meets or exceeds plan
   - Red (red-600) when forecast is below plan

### Technical Changes

```typescript
// Before: forecast first, then plan (static colours)
<span className="text-xs font-semibold text-indigo-600 tabular-nums">
  ${(selectionStats.selectedTotal / 1000000).toFixed(1)}M
</span>
<span className="text-[9px] text-gray-400">forecast</span>
<span className="text-gray-300">·</span>
<span className="text-xs font-medium text-gray-500 tabular-nums">
  ${(totalAcvTarget / 1000000).toFixed(1)}M
</span>
<span className="text-[9px] text-gray-400">plan</span>

// After: plan first, then forecast (conditional colours)
<span className="text-xs font-medium text-gray-500 tabular-nums">
  ${(totalAcvTarget / 1000000).toFixed(1)}M
</span>
<span className="text-[9px] text-gray-400">plan</span>
<span className="text-gray-300">·</span>
<span className={`text-xs font-semibold tabular-nums ${
  selectionStats.selectedTotal >= totalAcvTarget ? 'text-emerald-600' : 'text-red-600'
}`}>
  ${(selectionStats.selectedTotal / 1000000).toFixed(1)}M
</span>
<span className="text-[9px] text-gray-400">forecast</span>
```

### Visual Display

| Metric | Format |
|--------|--------|
| Total ACV | $X.XM plan · $X.XM forecast |
| Weighted ACV | $X.XM plan · $X.XM forecast |

### Colour Coding Logic

| Condition | Forecast Colour |
|-----------|-----------------|
| Forecast ≥ Plan | emerald-600 (green) |
| Forecast < Plan | red-600 (red) |

## Benefits

1. **Clearer baseline**: Plan value shown first establishes the target
2. **Immediate visual feedback**: Colour coding instantly shows whether on track
3. **Consistent with industry patterns**: Plan/target shown before actual/forecast
4. **Reduced cognitive load**: No need to read gap indicator to understand status

## Testing

- TypeScript compilation: Passed
- Build compilation: Passed
- Visual testing: Verified in browser
- Conditional logic: Verified green when meeting target, red when below

## Related Files

- `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx` - ACV Performance card
- `src/app/(dashboard)/planning/strategic/new/page.tsx` - Target calculation fix (uses TCV for Total ACV plan)

## Related Commits

- `26767d40`: fix: Update ACV Performance card layout and target calculation
