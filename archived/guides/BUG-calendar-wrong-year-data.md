# Bug Report: Calendar Tiles Showing "No Events Found" for 2025 Assessment Period

**Date:** 2026-01-10
**Severity:** High
**Status:** Fixed

## Summary

The Segmentation Event Progress modal's calendar tiles were showing "No Events Found" for all months in 2025, even though the database contained complete event data (e.g., Albury Wodonga Health had 12/12 Insight Touch Points completed).

## Root Cause

The `useSegmentationEvents` hook was being called with `currentYear` (2026) instead of the assessment year (2025). Since the calendar tiles display the assessment period (Jan-Dec 2025 for unchanged clients, Sep 2025-Jun 2026 for changed clients), but the data was being fetched for 2026, no events were found.

**Problem Code:**
```typescript
// LeftColumn.tsx / RightColumn.tsx
const { events: segmentationEvents } = useSegmentationEvents(client.name, currentYear)
// currentYear = 2026, but calendar shows 2025 months
```

## Fix Applied

Changed both LeftColumn.tsx and RightColumn.tsx to fetch events for BOTH the assessment year (2025) and current year (2026), then combine them:

```typescript
const currentYear = new Date().getFullYear() // 2026
const assessmentYear = currentYear - 1 // 2025

// Fetch events for BOTH years to cover full assessment periods
const { events: segmentationEventsPrior } = useSegmentationEvents(client.name, assessmentYear)
const { events: segmentationEventsCurrent } = useSegmentationEvents(client.name, currentYear)

// Combine events from both years for calendar display
const segmentationEvents = React.useMemo(() => {
  return [...(segmentationEventsPrior || []), ...(segmentationEventsCurrent || [])]
}, [segmentationEventsPrior, segmentationEventsCurrent])
```

This ensures that:
- For clients WITHOUT segment change: Events from Jan-Dec 2025 are displayed
- For clients WITH segment change (Sep 2025): Events from Sep 2025-Jun 2026 are displayed

## Files Changed

1. `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
   - Added `assessmentYear` calculation
   - Changed to dual-year event fetching
   - Combined events in useMemo

2. `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`
   - Same changes as LeftColumn.tsx

3. `src/hooks/useSegmentChange.ts`
   - Updated to accept `assessmentYear` parameter for segment change detection

## Additional Fix: Realistic AI Recommendations

**Problem:** AI was recommending unrealistic actions like "Schedule 8 Insight Touch Point events within 2 weeks".

**Solution:** Updated `useCompliancePredictions.ts` to calculate appropriate cadence based on:
- Number of events remaining
- Months remaining until deadline
- Events per month rate

Now provides context-aware recommendations like:
- "Schedule 12 Insight Touch Point events (approximately 1 per month over 12 months)"
- "Catch-up needed: Schedule 8 events - aim for 2 per month to meet compliance"

## Files Changed for AI Recommendations

1. `src/hooks/useCompliancePredictions.ts`
   - Updated STEP 6 (AI Recommendations) with realistic scheduling logic
   - Bumped cache version to `predictions_v2_realistic` to invalidate old predictions

## Testing

1. Open client detail page for Albury Wodonga Health
2. Click the compliance score to open the Segmentation Event Progress modal
3. Verify calendar tiles show events for Jan-Dec 2025
4. Verify overall compliance score matches Excel data (12/12 = 100%)
5. Check AI recommendations are realistic and time-appropriate

## Related Files

- `src/hooks/useSegmentationEvents.ts` - Hook that fetches events by client/year
- `src/hooks/useEventCompliance.ts` - Compliance calculation with assessment period logic
- `docs/guides/FEATURE-compliance-modal-improvements.md` - Feature documentation
