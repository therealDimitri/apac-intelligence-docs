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

### Phase 1: Completion Status Check

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

### Phase 2: Future Date Validation

After the initial fix, a second issue was discovered: May 2026 was showing 19/5 (380% complete) despite being a future month. Investigation revealed 19 events for "SA Health (Sunrise)" with `event_date = 2026-05-15` incorrectly marked as `completed = true`.

**Data Fix Applied:**
```sql
UPDATE segmentation_events
SET completed = false, completed_date = null
WHERE event_date > '2026-02-02' AND completed = true;
-- Fixed 19 events
```

**Defensive Code Added:**
```typescript
// Cannot count future events as completed
// This prevents bad data from showing impossible completion percentages
const now = new Date()
if (eventDate > now) continue
```

## Files Changed

- `src/hooks/useOperatingRhythmData.ts` - Added completion status check AND future date validation
- `src/hooks/useEventCompliance.ts` - Added `completed` and `completed_date` to SegmentationEvent interface

## Data Cleanup

- 19 events in `segmentation_events` table were incorrectly marked as completed before their scheduled date
- All 19 events were for "SA Health (Sunrise)" with `event_date = 2026-05-15`
- Events were created between 2025-11-14 and 2026-01-10 (likely test/seed data)
- Fixed by setting `completed = false` and `completed_date = null`

## Verification

1. Build passes with zero TypeScript errors
2. All 118 tests pass
3. Operating Rhythm orbit now correctly reflects completion status from Segmentation Progress page
4. May 2026 now shows 0% complete (as expected for a future month)

## Related Context

The materialized view `event_compliance_summary` already filters to `completed = true` events in its SQL definition. The defensive checks in the frontend ensure correctness even if:
- The materialized view has stale data (refreshes every 5 minutes via cron)
- The JSON structure includes unexpected data
- Future changes modify the view behaviour
- Data integrity issues exist (events incorrectly marked as completed before their date)
