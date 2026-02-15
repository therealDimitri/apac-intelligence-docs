# Bug Report: Operating Rhythm Auto-Completing Activities Based on Dates

**Date:** 2 February 2026
**Status:** Fixed
**Commit:** e852e07f

## Summary

The Operating Rhythm page was automatically showing client activities as "completed" based on whether the month had passed, rather than checking actual completion status from the database. Past months showed 70-100% completion rates even when no activities had been logged.

## Root Cause

The `AnnualOrbitView` component had two code paths for displaying activity completions:

1. **Real data path**: When `activityCompletions` prop is passed, use that data
2. **Mock data path**: When prop is not passed, generate deterministic fake data

The problem was that the Operating Rhythm page **never passed** the `activityCompletions` prop, so the mock data generator always ran.

### Bug Location: `src/components/operating-rhythm/AnnualOrbitView.tsx` (lines 126-177)

```typescript
const completionsByMonth = useMemo(() => {
  if (activityCompletions) {
    // Use provided completion data ← THIS PATH WAS NEVER TAKEN
    ...
  }

  // Generate deterministic mock data ← THIS ALWAYS RAN
  if (monthData.month < currentMonth) {
    // Past months: 70-100% completion ← FALSE COMPLETIONS!
    const completionRate = 0.7 + seededRandom(seed) * 0.3
    ...
  }
}, [activityCompletions, monthlyActivities, currentMonth])
```

### Additional Issue: Limited Activity Types

The `SEGMENT_ACTIVITIES` array only had 4 hardcoded activities, when the database stores 12 activity types from the APAC Client Segmentation Activity Register.

## Fix Applied

### 1. Expanded Activity Types (`segment-activities.ts`)

Updated `SEGMENT_ACTIVITIES` from 4 to all 12 activity types:
- President/Group Leader Engagement
- EVP Engagement
- Strategic Ops Plan Meeting
- Satisfaction Action Plan
- SLA/Service Review Meeting
- CE On-Site Attendance
- Insight Touch Point
- Health Check (Opal)
- Upcoming Release Planning
- Whitespace Demos (Sunrise)
- APAC Client Forum / User Group
- Updating Client 360

Added `EVENT_CODE_TO_ACTIVITY_ID` mapping to translate database event codes (e.g., `PGL_ENGAGE`) to UI activity IDs (e.g., `pgl-engagement`).

### 2. New Data Hook (`useOperatingRhythmData.ts`)

Created a hook that:
- Fetches compliance data using existing `useAllClientsCompliance` hook
- Transforms per-client, per-event-type data into monthly activity summaries
- Extracts individual event dates to count completions by month
- Returns `ActivityCompletion[]` format expected by `AnnualOrbitView`

### 3. Page Integration (`operating-rhythm/page.tsx`)

- Added `useOperatingRhythmData` hook call
- Passed `activityCompletions` to `AnnualOrbitView` component

## Files Changed

- `src/components/operating-rhythm/segment-activities.ts` - Expanded from 4 to 12 activities
- `src/hooks/useOperatingRhythmData.ts` - New hook for data transformation
- `src/app/(dashboard)/operating-rhythm/page.tsx` - Hook integration

## Data Flow (After Fix)

```
segmentation_events (actual completions)
          ↓
event_compliance_summary (materialized view)
          ↓
useAllClientsCompliance (fetches view data)
          ↓
useOperatingRhythmData (transforms by month)
          ↓
AnnualOrbitView (renders real data)
```

## Testing Notes

- Activities now show completion only when logged via:
  - Dashboard "Log Event" button on Segmentation Progress page
  - Excel Activity Register file sync
- Empty months show 0% completion (not mock 70-100%)
- All 12 activity types display in the orbit view

## Related Design Document

- `docs/plans/2026-02-02-operating-rhythm-sync-design.md`

## Future Considerations

The design document outlines a more complete solution including:
- Real-time Excel sync with file watcher
- Deduplication logic for Excel + Dashboard entries
- Database-driven activity requirements (using existing `tier_event_requirements` table)

The current fix addresses the immediate auto-completion bug. The Excel sync feature can be implemented as a follow-up.
