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
   - Segment activity details shown below when clicking a month
   - Activity Summary card when no specific month is selected
   - Close button (X) to dismiss the selected month view

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

- Verified click interaction on monthly bubbles shows detailed completion status
- Verified Next Event panel stays visible when viewing segment activities
- Verified progress arcs render correctly on all monthly bubbles
- Build passes with no TypeScript errors
- Deployed successfully to production

## Bug Fix: Hover-to-Click Interaction (29 Jan 2026)

**Problem:** The original hover-based interaction (`onMouseEnter`/`onMouseLeave`) was too fragile. The segment activity card would disappear immediately when the mouse cursor moved away from the small (~15px radius) bubble. Users couldn't read the card before it vanished.

**Root Cause:**
- Small SVG target elements (10-18px radius) make it difficult to keep cursor in place
- `onMouseLeave` fires instantly when cursor moves even 1px outside the element
- Moving toward the detail card naturally takes the cursor away from the bubble

**Solution:**
- Changed from hover-based (`hoveredMonth`) to click-based (`selectedMonth`) state
- Click on bubble toggles selection (click again to deselect)
- Added close button (X) to the SegmentActivityCard header for easy dismissal
- Selection now persists until user explicitly clicks elsewhere or the close button

**Commit:** `210d3997` - fix(operating-rhythm): change segment activity from hover to click-based selection

## Feature: Client Mini-Orbit (29 Jan 2026)

Added drill-down capability to see individual client completion status for each activity type.

**Flow:**
1. Click month bubble → Shows segment activity card with activity list
2. Click activity type (EVP, On-Site, Insight, SLA Review) → Shows client mini-orbit

**Client Mini-Orbit Features:**
- Radial layout showing all clients assigned to that activity
- Green bubbles = completed (with checkmark badge)
- Amber bubbles = outstanding
- Client initials displayed on each bubble
- Hover tooltip shows: client name, completion date (if completed), segment tier
- Back button returns to activity list
- Legend showing Completed/Outstanding indicators

**Commits:**
- `3d928984` - feat(operating-rhythm): add client mini-orbit for activity completion tracking

## Real Client Data Integration (29 Jan 2026)

**Problem:** The client mini-orbit was using hardcoded `MOCK_CLIENTS` array instead of real client data from the database.

**Solution:**
- Created `/api/clients/segments` API endpoint to fetch clients from `nps_clients` table
- Added `ClientData` interface for typed client data
- `AnnualOrbitView` now accepts `clients` prop for real data
- Operating Rhythm page fetches clients on mount and passes to component
- Short names auto-generated from client names (first letters of each word)

**API Response:**
```json
{
  "success": true,
  "clients": [
    { "name": "Albury Wodonga Health", "shortName": "AWH", "tier": "Leverage" },
    { "name": "Barwon Health Australia", "shortName": "BHA", "tier": "Maintain" },
    ...
  ],
  "clientCounts": {
    "Giant": 1, "Sleeping Giant": 2, "Collaboration": 2,
    "Nurture": 2, "Leverage": 5, "Maintain": 6
  },
  "totalClients": 18
}
```

**Files Changed:**
- `src/app/api/clients/segments/route.ts` (new)
- `src/components/operating-rhythm/AnnualOrbitView.tsx`
- `src/components/operating-rhythm/index.ts`
- `src/app/(dashboard)/operating-rhythm/page.tsx`

**Commits:**
- `c2ed1e54` - feat(operating-rhythm): connect client mini-orbit to real nps_clients data

## Future Considerations

- Create database table for tracking actual activity completions
- Add ability for users to mark activities as completed
- Add click-through from client bubble to client profile page
- Fix short name generation for clients with parentheses (e.g., "GHA(" from "Gippsland Health Alliance (GHA)")
