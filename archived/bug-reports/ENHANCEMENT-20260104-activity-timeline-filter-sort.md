# Enhancement: Activity Timeline Status Filter and Sort Controls

**Date:** 2026-01-04
**Status:** IMPLEMENTED
**Type:** Enhancement (UI/UX)

## Summary

Added status filter and sort controls to the client profile activity timeline, enabling users to filter actions by status (Not Started, In Progress, Completed, Cancelled) and sort the timeline by date, priority, or status.

## Features Added

### 1. Status Filter Dropdown

When viewing the activity timeline (on "All Activity" or "Actions" filter), users can now filter by action status:

| Status | Description |
|--------|-------------|
| All Statuses | Show all items (default) |
| Not Started | Show only actions with "open" status |
| In Progress | Show actions currently being worked on |
| Completed | Show completed actions and meetings |
| Cancelled | Show cancelled actions and meetings |

**UI Details:**
- Appears as a dropdown next to the type filters
- Shows a purple highlight when a filter is active
- Icon changes based on selected status (Circle, Clock, CheckCircle, XCircle)
- Mobile-friendly with responsive sizing

### 2. Sort Controls

Users can now sort the timeline by:

| Sort Option | Description |
|-------------|-------------|
| Newest First | Default - most recent items at top |
| Oldest First | Oldest items at top |
| By Priority | Critical → High → Medium → Low, then by date |
| By Status | Open → In Progress → Completed → Cancelled, then by date |

**UI Details:**
- ArrowUpDown icon indicates sort functionality
- Dropdown with radio-style selection
- Checkmark indicates current selection

## Implementation

### Files Modified

1. **`src/app/(dashboard)/clients/[clientId]/components/v2/ClientActionBar.tsx`**
   - Added `StatusFilter` and `SortOption` type exports
   - Added new props: `statusFilter`, `onStatusFilterChange`, `sortBy`, `onSortChange`
   - Implemented status filter dropdown UI
   - Implemented sort dropdown UI
   - Added new Lucide icons: ArrowUpDown, ChevronDown, Circle, Clock, CheckCircle2, XCircle

2. **`src/app/(dashboard)/clients/[clientId]/components/v2/CenterColumn.tsx`**
   - Added `StatusFilter` and `SortOption` type definitions
   - Added new props: `statusFilter`, `sortBy`
   - Enhanced `filteredTimeline` useMemo to apply status filtering
   - Added multi-criteria sorting logic with priority and status ordering

3. **`src/app/(dashboard)/clients/[clientId]/v2/page.tsx`**
   - Added state for `statusFilter` and `sortBy`
   - Imported `StatusFilter` and `SortOption` types from ClientActionBar
   - Passed new props to ClientActionBar and CenterColumn (both desktop and mobile layouts)

### Key Logic

**Status Filter Logic:**
```typescript
if (statusFilter !== 'all') {
  result = result.filter(item => {
    if (item.type === 'action') {
      return item.status === statusFilter
    }
    if (item.type === 'meeting') {
      if (statusFilter === 'open') return item.status === 'scheduled'
      if (statusFilter === 'completed') return item.status === 'completed'
      if (statusFilter === 'cancelled') return item.status === 'cancelled'
      return false
    }
    return false
  })
}
```

**Sort Logic:**
```typescript
const priorityOrder = { critical: 0, high: 1, medium: 2, low: 3 }
const statusOrder = { open: 0, 'in-progress': 1, scheduled: 1, completed: 2, cancelled: 3 }

result.sort((a, b) => {
  switch (sortBy) {
    case 'priority':
      const aPriority = priorityOrder[a.priority] ?? 4
      const bPriority = priorityOrder[b.priority] ?? 4
      if (aPriority !== bPriority) return aPriority - bPriority
      return b.timestamp.getTime() - a.timestamp.getTime()
    case 'status':
      const aStatus = statusOrder[a.status] ?? 4
      const bStatus = statusOrder[b.status] ?? 4
      if (aStatus !== bStatus) return aStatus - bStatus
      return b.timestamp.getTime() - a.timestamp.getTime()
    // ... other cases
  }
})
```

## UI/UX Considerations

1. **Progressive Disclosure**: Status filter only appears when relevant (on "All Activity" or "Actions" filter)
2. **Visual Feedback**: Active filters are highlighted in purple
3. **Responsive Design**: Controls adapt to screen size with abbreviated labels on mobile
4. **Accessible Dropdowns**: Click-outside-to-close behaviour, proper z-indexing
5. **Consistent Styling**: Matches existing glassmorphism design language

## Testing Checklist

- [x] TypeScript compilation passes
- [x] Status filter works for all action statuses
- [x] Status filter correctly maps meeting statuses (scheduled → open)
- [x] Sort by date ascending/descending works
- [x] Sort by priority orders correctly (critical first)
- [x] Sort by status orders correctly (open first)
- [x] Filters and sorts combine correctly
- [x] Mobile layout works correctly
- [x] Dropdowns close when clicking outside
- [x] No horizontal scrolling required

## Layout Design

### Two-Row Responsive Layout

The filter bar uses a stacked two-row design to ensure all controls are always visible:

**Row 1: Type Filters**
- SHOW label + 4 filter buttons (All, Actions, Meetings, Notes)
- `flex-1` on mobile for equal-width buttons
- Abbreviated labels on mobile (All, Acti, Meet, Note)
- Full labels on desktop (All Activity, Actions, etc.)

**Row 2: Controls**
- LEFT: Status filter dropdown + Sort dropdown
- RIGHT: Quick action buttons (icons only on desktop, FAB on mobile)
- `justify-between` for proper spacing

### Responsive Breakpoints

| Breakpoint | Type Filters | Labels | Quick Actions |
|------------|--------------|--------|---------------|
| Mobile (<sm) | Equal-width buttons | 3-4 chars | Single FAB |
| Tablet (sm-md) | Auto-width | 3-4 chars | Icon buttons |
| Desktop (md+) | Auto-width | Full labels | Icon buttons |

## Screenshots

N/A - Feature enhancement documentation

## Related Work

- Previous: BUG-REPORT-20260104-activity-stream-alias-and-refetch.md (fixed alias resolution)
- Previous: Health Score Trend card colour fix
- Follow-up: ccaa418 - Fixed horizontal scrolling issues
- Follow-up: 74a3b0f - Redesigned with two-row layout to eliminate scrolling
