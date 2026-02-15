# Enhancement Report: Context Menu Standardisation

**Date:** 2026-01-27
**Type:** Enhancement
**Status:** Completed & Deployed
**Author:** Claude Opus 4.5

---

## Overview

Standardised the right-click context menu across the Command Centre dashboard, adding snooze and dismiss functionality to both the Priority Actions Matrix (Eisenhower Matrix view) and the Predictive Alerts section.

## Background

The Swimlane view already had a context menu with snooze and dismiss options via `QuickActionsMenu`. However, the standard Priority Matrix view (`PriorityMatrix.tsx`) did not have these handlers wired up, and the new Predictive Alerts section had no context menu at all.

User request: "Standardise right-click menu for Priority Matrix as per Swimlane menu which has Snooze and Dismiss Alert options. Also add the right-click menu to Predictive Alerts tab."

## Implementation

### 1. Priority Matrix (`PriorityMatrix.tsx`)

**Changes Made:**

Added three new handler functions:

```typescript
// Snooze handler - temporarily hides item
const handleSnoozeItem = useCallback((item: MatrixItemType, days: number, label: string) => {
  const snoozedItems = JSON.parse(localStorage.getItem('matrix-snoozed-items') || '{}')
  const snoozeUntil = new Date()
  snoozeUntil.setDate(snoozeUntil.getDate() + days)
  snoozedItems[item.id] = {
    until: snoozeUntil.toISOString(),
    label,
  }
  localStorage.setItem('matrix-snoozed-items', JSON.stringify(snoozedItems))
  setFilters(prev => ({ ...prev })) // Trigger re-render
}, [])

// Dismiss handler - permanently hides item
const handleDismissItem = useCallback((item: MatrixItemType) => {
  const dismissedItems = JSON.parse(localStorage.getItem('matrix-dismissed-items') || '[]')
  if (!dismissedItems.includes(item.id)) {
    dismissedItems.push(item.id)
    localStorage.setItem('matrix-dismissed-items', JSON.stringify(dismissedItems))
  }
  setFilters(prev => ({ ...prev })) // Trigger re-render
}, [])

// Mark complete handler for context menu
const handleMarkCompleteItem = useCallback((item: MatrixItemType) => {
  markItemsComplete([item.id])
}, [markItemsComplete])
```

Updated `QuickActionsMenu` props to wire up the handlers:

```typescript
<QuickActionsMenu
  item={contextMenu.item}
  position={contextMenu.position}
  onClose={handleCloseContextMenu}
  clientIdLookup={getClientIdByName}
  clientDataLookup={getClientDataByName}
  onAssign={onAssign}
  onMultiClientAssign={onMultiClientAssign}
  onSetDepartment={handleSetDepartment}
  onMarkComplete={handleMarkCompleteItem}
  onSnooze={handleSnoozeItem}
  onDismiss={handleDismissItem}
/>
```

Updated `filteredItems` useMemo to exclude snoozed and dismissed items:

```typescript
const filteredItems = useMemo(() => {
  const dismissedItems = JSON.parse(localStorage.getItem('matrix-dismissed-items') || '[]')
  const snoozedItems = JSON.parse(localStorage.getItem('matrix-snoozed-items') || '{}')
  const now = new Date()

  return items.filter(item => {
    // Hide completed items
    if (item.tags?.includes('completed')) return false

    // Hide dismissed items
    if (dismissedItems.includes(item.id)) return false

    // Hide snoozed items until snooze expires
    const snoozeData = snoozedItems[item.id]
    if (snoozeData) {
      const snoozeUntil = new Date(snoozeData.until)
      if (now < snoozeUntil) return false
    }

    // ... rest of filters
  })
}, [items, effectiveFilters])
```

### 2. Predictive Alerts Section (`PredictiveAlertsSection.tsx`)

**New Components Added:**

Created `AlertContextMenu` component - a purpose-built context menu for alerts with:
- View Client Profile action (highlighted)
- Snooze Alert submenu with 5 duration options
- Dismiss Alert action
- Keyboard support (Escape to close)
- Click-outside to close
- Viewport edge detection

**Snooze Duration Options:**

```typescript
const SNOOZE_OPTIONS = [
  { code: '1d', name: 'Snooze for 1 day', days: 1 },
  { code: '3d', name: 'Snooze for 3 days', days: 3 },
  { code: '1w', name: 'Snooze for 1 week', days: 7 },
  { code: '2w', name: 'Snooze for 2 weeks', days: 14 },
  { code: '1m', name: 'Snooze for 1 month', days: 30 },
] as const
```

**State Management:**

Added context menu state and handlers to the main component:

```typescript
const [contextMenu, setContextMenu] = useState<ContextMenuState | null>(null)
const [filterTrigger, setFilterTrigger] = useState(0) // For re-render after snooze/dismiss

const handleContextMenu = useCallback((e: React.MouseEvent, alert: PredictiveAlert) => {
  e.preventDefault()
  setContextMenu({
    alert,
    position: { x: e.clientX, y: e.clientY },
  })
}, [])

const handleSnoozeAlert = useCallback((alert: PredictiveAlert, days: number, label: string) => {
  const snoozedAlerts = JSON.parse(localStorage.getItem('alerts-snoozed-items') || '{}')
  const snoozeUntil = new Date()
  snoozeUntil.setDate(snoozeUntil.getDate() + days)
  snoozedAlerts[alert.id] = { until: snoozeUntil.toISOString(), label }
  localStorage.setItem('alerts-snoozed-items', JSON.stringify(snoozedAlerts))
  setFilterTrigger(prev => prev + 1)
}, [])

const handleDismissAlert = useCallback((alert: PredictiveAlert) => {
  const dismissedAlerts = JSON.parse(localStorage.getItem('alerts-dismissed-items') || '[]')
  if (!dismissedAlerts.includes(alert.id)) {
    dismissedAlerts.push(alert.id)
    localStorage.setItem('alerts-dismissed-items', JSON.stringify(dismissedAlerts))
  }
  setFilterTrigger(prev => prev + 1)
}, [])
```

**Updated AlertCard:**

Added `onContextMenu` prop to AlertCard component:

```typescript
function AlertCard({
  alert,
  isExpanded,
  onToggle,
  onContextMenu,
}: {
  alert: PredictiveAlert
  isExpanded: boolean
  onToggle: () => void
  onContextMenu: (e: React.MouseEvent) => void
})
```

## Technical Details

### localStorage Keys

| Key | Data Type | Purpose |
|-----|-----------|---------|
| `matrix-snoozed-items` | `Record<string, { until: string; label: string }>` | Priority Matrix snoozed items |
| `matrix-dismissed-items` | `string[]` | Priority Matrix dismissed item IDs |
| `alerts-snoozed-items` | `Record<string, { until: string; label: string }>` | Predictive Alerts snoozed items |
| `alerts-dismissed-items` | `string[]` | Predictive Alerts dismissed item IDs |

### Snooze Expiration

Snoozed items automatically reappear after their snooze period expires. The filtering logic checks the current time against the `until` timestamp on each render.

### Context Menu Styling

Both context menus use consistent styling:
- White background with rounded corners (`rounded-xl`)
- Shadow (`shadow-2xl`)
- Border (`border-gray-200`)
- Fade-in animation (`animate-in fade-in slide-in-from-top-2`)
- Viewport edge detection to prevent overflow

## User Interface

### Priority Matrix Context Menu

Right-clicking any item in the Priority Matrix now shows the full QuickActionsMenu with:
- Open Client Profile (highlighted)
- Choose Client to Open (multi-client items)
- View All Affected Clients (multi-client items)
- Change Status
- Create Meeting
- Add Comment
- Assign to Team Member
- Set Department
- **Mark as Complete** (new)
- **Snooze Alert** (new, with duration submenu)
- **Dismiss Alert** (new)

### Predictive Alerts Context Menu

Right-clicking any alert card shows a streamlined menu:
- View Client Profile (highlighted)
- Snooze Alert (with duration submenu)
- Dismiss Alert

## Testing

### Verified Functionality

- [x] Priority Matrix: Right-click menu opens with snooze/dismiss options
- [x] Priority Matrix: Snooze hides item until expiration
- [x] Priority Matrix: Dismiss permanently hides item
- [x] Priority Matrix: Snoozed/dismissed items persist across page refresh
- [x] Predictive Alerts: Right-click menu opens on alert cards
- [x] Predictive Alerts: Snooze submenu shows all duration options
- [x] Predictive Alerts: Snoozed alerts are filtered out
- [x] Predictive Alerts: Dismissed alerts are filtered out
- [x] Both: Escape key closes context menu
- [x] Both: Clicking outside closes context menu
- [x] Both: Menu repositions near viewport edges

---

## Related Files

- `src/components/priority-matrix/PriorityMatrix.tsx` - Matrix view with snooze/dismiss
- `src/components/priority-matrix/QuickActionsMenu.tsx` - Shared context menu component
- `src/components/priority-matrix/PriorityMatrixMultiView.tsx` - Swimlane view (already had functionality)
- `src/components/PredictiveAlertsSection.tsx` - Alerts section with new context menu
- `docs/bug-reports/2026-01-27-predictive-alerts-dashboard-section.md` - Related Predictive Alerts enhancement
