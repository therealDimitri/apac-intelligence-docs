# Bug Report: Operating Rhythm Auto-Completion Issue

**Date:** 2 February 2026
**Status:** Fixed
**Severity:** Medium
**Component:** Operating Rhythm - Activity Completion Tracking

## Summary

The Operating Rhythm orbit view was showing activities as completed based on event dates rather than actual completion status from the Segmentation Progress page.

## Root Cause

In `src/hooks/useOperatingRhythmData.ts`, the event counting logic at lines 76-88 counted all events by date presence without checking if they were actually marked as completed.

The data flow:
1. Events are stored in `segmentation_events` table with a `completed` boolean field
2. The `event_compliance_summary` materialized view aggregates this data, filtering to `completed = true`
3. `useOperatingRhythmData` transforms this for the orbit display
4. However, the code counted events without verifying the `completed` flag as a defensive measure

**Location:** `src/hooks/useOperatingRhythmData.ts:76-88`

```typescript
// Before (buggy) - counted all events by date
for (const event of eventCompliance.events || []) {
  if (!event.event_date) continue

  const eventDate = new Date(event.event_date)
  const eventMonth = eventDate.getMonth()
  const eventYear = eventDate.getFullYear()

  if (eventYear === year) {
    completionMap[activityId][eventMonth].completed += 1
  }
}
```

## Fix Applied

Added defensive check to only count events where `completed === true`:

```typescript
// After (fixed) - only count completed events
for (const event of eventCompliance.events || []) {
  if (!event.event_date) continue
  // Defensive check: only count if completed flag is true
  if (event.completed !== true) continue

  const eventDate = new Date(event.event_date)
  const eventMonth = eventDate.getMonth()
  const eventYear = eventDate.getFullYear()

  if (eventYear === year) {
    completionMap[activityId][eventMonth].completed += 1
  }
}
```

Also updated the `SegmentationEvent` interface in `src/hooks/useEventCompliance.ts` to explicitly include `completed` and `completed_date` fields for type safety.

## Files Changed

- `src/hooks/useOperatingRhythmData.ts` - Added completion status check
- `src/hooks/useEventCompliance.ts` - Added `completed` and `completed_date` to SegmentationEvent interface

## Verification

1. Build passes with zero TypeScript errors
2. All 118 tests pass
3. Operating Rhythm orbit now correctly reflects completion status from Segmentation Progress page

## Related Context

The materialized view `event_compliance_summary` already filters to `completed = true` events in its SQL definition. The defensive check in the frontend ensures correctness even if:
- The materialized view has stale data (refreshes every 5 minutes via cron)
- The JSON structure includes unexpected data
- Future changes modify the view behaviour
