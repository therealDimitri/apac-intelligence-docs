# Bug Report: KPI Card Chevron Visibility Issue

**Date:** 21 December 2025
**Status:** ✅ Resolved
**Commit:** `91d8847`

## Issue Summary

The expand/collapse chevron indicator on expandable KPI cards was not visible on the "Total AR Outstanding" card in the Aging Accounts Compliance dashboard.

## Symptoms

- The chevron icon at the bottom right of the KPI card was hidden or cut off
- Users could not see visual indication that cards were expandable
- The issue persisted despite multiple flexbox-based layout attempts

## Root Cause

The flexbox layout used `justify-between` and `items-stretch` which caused spacing issues when combined with variable content heights and sparkline positioning. The chevron was being pushed off-screen or hidden behind other elements.

## Solution Applied

Changed from flexbox-based chevron positioning to **absolute positioning**:

```tsx
{
  /* Expand indicator - absolute positioned bottom right */
}
{
  isExpandable && (
    <div
      className={`
      absolute bottom-4 right-4
      p-1 rounded-full transition-colors ${ANIMATIONS.fast}
      ${isExpanded ? 'bg-purple-100 text-purple-600' : 'bg-gray-100 text-gray-400'}
    `}
    >
      {isExpanded ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
    </div>
  )
}
```

The parent container was given `relative` positioning to anchor the absolute element:

```tsx
<div className={`${SPACING.card} relative`}>
```

## Files Modified

- `src/app/(dashboard)/aging-accounts/compliance/components/KPICard.tsx`

## Testing Performed

1. Verified chevron is visible on all expandable KPI cards
2. Confirmed expand/collapse functionality works correctly
3. Tested card displays breakdown data when expanded:
   - Under 60 days
   - 61-90 days
   - Over 90 days

## Lessons Learned

- Absolute positioning is more reliable for fixed-position UI indicators
- Flexbox layouts with variable content can cause unpredictable element positioning
- Always test expandable components in both collapsed and expanded states
