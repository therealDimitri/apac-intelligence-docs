# Enhancement: Segment Activity Completion Tracking

**Date:** 29 January 2026  
**Type:** Enhancement  
**Component:** Operating Rhythm - AnnualOrbitView  
**Status:** Completed

## Summary

Enhanced the Operating Rhythm segment activity layer to keep the Next Event panel visible when viewing segment activities, and added completion tracking to show which activities are completed vs outstanding.

## User Request

1. Keep the "Next Event" panel visible when clicking segment activities (not disappear)
2. Show which activities are completed vs outstanding
3. Retain the orbit design

## Implementation (Option C + D Combined)

### Option C: Pinned Next Event
- Next Event card now stays fixed at the top of the right panel
- Visible regardless of what's selected on the orbit
- Compact horizontal layout to save space

### Option D: Progress Indicators on Orbit
- Each monthly touchpoint bubble on the inner ring shows a progress arc
- Green arc indicates completion percentage
- Amber colour for past months with incomplete activities
- Checkmark (✓) displayed when 100% complete

## Changes Made

### `src/components/operating-rhythm/AnnualOrbitView.tsx`
- Added `ActivityCompletion` interface for tracking completion data
- Added `completionsByMonth` calculation with deterministic mock data
- Modified segment activity bubbles to show progress arcs
- Restructured right panel:
  - Pinned Next Event card at top (always visible)
  - Context panel below for event details or segment activity details
- Enhanced `SegmentActivityCard` to show:
  - Overall progress bar with percentage
  - Per-activity progress bars
  - Completed vs outstanding counts for each activity type
- Added new `ActivitySummaryCard` component showing:
  - Year-to-date progress
  - Monthly progress breakdown
  - Annual target touchpoints

### `src/components/operating-rhythm/index.ts`
- Exported `ActivityCompletion` type

## Visual Changes

1. **Orbit Inner Ring**: Monthly bubbles now have progress arcs around them
   - Grey background arc (total)
   - Green/emerald arc overlay (completed portion)
   - Amber fill for past months with incomplete activities
   - Green fill with checkmark for 100% complete months

2. **Right Panel Layout**:
   - Compact Next Event card pinned at top
   - Segment activity details shown below when hovering
   - Activity Summary card when no specific month is hovered

3. **Activity Detail View**:
   - Overall completion percentage with progress bar
   - Per-activity breakdown with individual progress bars
   - "X completed" (green) and "Y outstanding" (amber) labels

## Data Model

The `ActivityCompletion` interface allows real completion data to be passed from a database:

```typescript
export interface ActivityCompletion {
  activityId: string
  month: number
  completed: number
  total: number
}
```

Currently uses deterministic mock data for demonstration. In production, this should be replaced with actual completion tracking from a database table.

## Testing

- Verified hover interaction on monthly bubbles shows detailed completion status
- Verified Next Event panel stays visible when viewing segment activities
- Verified progress arcs render correctly on all monthly bubbles
- Build passes with no TypeScript errors
- Deployed successfully to production

## Future Considerations

- Create database table for tracking actual activity completions
- Add ability for users to mark activities as completed
- Consider adding drill-down to see which specific clients have completed/outstanding activities
