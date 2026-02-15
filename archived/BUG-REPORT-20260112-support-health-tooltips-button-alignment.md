# Bug Report: Support Health Tooltips and Button Alignment

**Date:** 2026-01-12
**Severity:** Low (UX improvement)
**Status:** Resolved

## Summary
Two issues were identified and resolved on the Support Health page:
1. Export and Refresh buttons were not horizontally aligned
2. Missing tooltips on expandable client row cards made metrics unclear to users

## Issue 1: Button Alignment

### Problem
The Export dropdown and Refresh button in the Support Health page header were not horizontally aligned, causing visual inconsistency.

### Root Cause
The button container was using incorrect flex layout structure.

### Resolution
Restructured the flex container hierarchy in `page.tsx`:
```tsx
<div className="flex flex-col items-end gap-1 print:hidden">
  <div className="flex items-center gap-2">
    {/* Export and Refresh buttons now horizontally aligned */}
  </div>
  {/* Timestamp positioned below buttons */}
</div>
```

## Issue 2: Missing Tooltips on Metric Cards

### Problem
The expandable client row content (ExpandableRowContent.tsx) displayed metrics without explanations:
- Open Cases by Priority
- Case Age Distribution
- SLA & Satisfaction (Response SLA, Resolution SLA, CSAT Score, Survey Response)
- Health Score Breakdown (SLA Compliance, CSAT Score, Aging Penalty, Critical Cases)

Users had no context for what each metric measured or what targets they should aim for.

### Root Cause
Component lacked tooltip implementations for metric definitions.

### Resolution
Added comprehensive tooltips to all metric cards in `ExpandableRowContent.tsx`:

1. **Section Headers** - Each section now has a HelpCircle icon with tooltip explaining the section purpose

2. **Individual Metrics** - Each metric card is now wrapped in Tooltip with:
   - Metric name
   - Concise definition
   - Target thresholds where applicable

3. **Health Score Breakdown** - Each component shows:
   - What the metric measures
   - How it's calculated
   - Its weight in the overall score

### Example Tooltip Content
```tsx
<TooltipContent>
  <p className="font-semibold">Resolution SLA</p>
  <p>Percentage of cases resolved within contracted timeframe.
     This is the primary SLA metric. Target: ≥95%.</p>
</TooltipContent>
```

## Files Modified

1. `src/app/(dashboard)/support/page.tsx`
   - Fixed button alignment in header

2. `src/components/support/ExpandableRowContent.tsx`
   - Added Tooltip imports
   - Added TooltipProvider wrapper
   - Added HelpCircle icons to all section headers
   - Wrapped all metric cards with Tooltip components
   - Added descriptive tooltip content for each metric

## Testing Performed

- [x] Build passes without TypeScript errors
- [x] Tooltips appear on hover
- [x] Buttons are horizontally aligned
- [x] No console errors
- [x] Responsive layout maintained

## Related Commits

- `4e8b88cb` - feat(support-health): Add tooltips and fix button alignment

## Notes

Trend badges for individual client metrics (as mentioned in original request) would require API modifications to pass previous period comparison data to the ExpandableRowContent component. This enhancement is noted for future consideration but was not included in this fix as it requires significant backend changes.
