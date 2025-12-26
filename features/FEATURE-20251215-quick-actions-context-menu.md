# Feature: Quick Actions Context Menu for Priority Matrix

**Date:** 2025-12-15
**Status:** IMPLEMENTED
**Type:** UX Enhancement

## Overview

Added a context menu (right-click) feature to Priority Matrix items that provides quick actions to reduce the number of clicks required to navigate from alerts to client details.

## Problem

Users navigating from Priority Matrix alerts to client segmentation details required 5+ clicks:

1. Click alert in Priority Matrix
2. Land on filtered Client Profiles page
3. Scroll to find specific client
4. Click client card
5. Navigate to client detail page
6. Find and expand Compliance Section

## Solution

Implemented a contextual quick actions menu that appears on right-click, reducing navigation to 1-2 clicks.

### Quick Actions Available

| Action                        | Description                                                               | Clicks Saved |
| ----------------------------- | ------------------------------------------------------------------------- | ------------ |
| **Open Most Urgent Client**   | Deep links directly to client profile with compliance section auto-opened | 4 clicks     |
| **View All Affected Clients** | Opens filtered client profiles page                                       | 2 clicks     |
| **Bulk Schedule Events**      | Opens meetings page with pre-selected clients                             | 3 clicks     |
| **Export Client List**        | Downloads CSV of affected clients                                         | N/A          |
| **View Full Details**         | Uses existing action href                                                 | 1 click      |

### Deep Linking

URLs now support section parameters for direct navigation:

```
/clients/{id}/v2?section=compliance&highlight=Insight%20Touch%20Point
```

This auto-opens the compliance modal when the page loads.

## Files Modified

### New Files

- `src/components/priority-matrix/QuickActionsMenu.tsx` - Context menu component

### Modified Files

- `src/components/priority-matrix/MatrixItem.tsx` - Added onContextMenu handler
- `src/components/priority-matrix/MatrixItemCompact.tsx` - Added onContextMenu handler
- `src/components/priority-matrix/MatrixQuadrant.tsx` - Added onItemContextMenu prop
- `src/components/priority-matrix/PriorityMatrix.tsx` - Added context menu state and rendering
- `src/components/priority-matrix/index.ts` - Added QuickActionsMenu export
- `src/app/(dashboard)/clients/[clientId]/v2/page.tsx` - Added URL param handling
- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` - Added autoOpenCompliance prop

## Usage

### For Users

- **Right-click** on any item in the Priority Matrix to open the quick actions menu
- **Hover** over items to see the hint: "Right-click for quick actions"
- Press **Escape** to close the menu

### For Multi-Client Alerts

When an alert affects multiple clients (e.g., "42 incomplete Insight Touch Points"):

- "Open Most Urgent Client" opens the first/worst client directly
- "View All Affected Clients" shows the filtered list
- "Export Client List" downloads a CSV of all affected clients

## Technical Details

### Context Menu Position

- Auto-adjusts to stay within viewport boundaries
- Opens at cursor position

### Client ID Lookup

- Uses `useClients` hook to map client names to IDs
- Falls back to client profiles search if ID not found

### State Management

```typescript
const [contextMenu, setContextMenu] = useState<{
  item: MatrixItemType
  position: { x: number; y: number }
} | null>(null)
```

## Related Features

- Priority Matrix (Eisenhower-style task management)
- Client Profiles deep linking
- Compliance modal auto-opening

## Future Enhancements

- Keyboard navigation within menu
- Long-press support for mobile devices
- Customisable quick actions per user role
