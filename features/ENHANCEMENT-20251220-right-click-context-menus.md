# Enhancement: Right-Click Context Menus

**Date:** 20 December 2025
**Status:** Completed
**Component:** Multiple Pages

## Overview

Added right-click context menus with quick actions to all major dashboard pages, providing users with fast access to common operations.

## Pages Enhanced

### 1. Meetings Page (`/meetings`)

**File:** `src/app/(dashboard)/meetings/page.tsx`

**Context Menu Actions:**

- View Details
- Edit Meeting (E)
- Mark Complete (C)
- Mark Scheduled (S)
- Mark Cancelled (X)
- Delete Meeting (Del)

### 2. Alerts Page (`/alerts`)

**File:** `src/components/AlertCenter.tsx`

**Context Menu Actions:**

- View/Hide Details
- Quick Actions (from alert - Send Email, Schedule Meeting, Create Action, Escalate)
- View Client Profile

### 3. NPS Analytics Page (`/nps`)

**File:** `src/app/(dashboard)/nps/page.tsx`

**Context Menu Actions:**

- View NPS Feedback
- View Client Profile
- Create Action
- View Meetings
- Export Report

### 4. Client Profiles Page (`/client-profiles`)

**File:** `src/app/(dashboard)/client-profiles/page.tsx`

**Context Menu Actions:**

- View Full Profile
- Health Insights
- View Meetings
- Create Action
- View NPS Data

## Implementation Pattern

Each page follows a consistent pattern:

### 1. State Management

```typescript
const [contextMenu, setContextMenu] = useState<{ entity: EntityType; x: number; y: number } | null>(
  null
)
```

### 2. Event Handlers

```typescript
const handleContextMenu = (e: React.MouseEvent, entity: EntityType) => {
  e.preventDefault()
  e.stopPropagation()
  setContextMenu({ entity, x: e.clientX, y: e.clientY })
}

const closeContextMenu = () => {
  setContextMenu(null)
}
```

### 3. Click Outside Detection

```typescript
useEffect(() => {
  const handleClickOutside = () => closeContextMenu()
  if (contextMenu) {
    document.addEventListener('click', handleClickOutside)
    return () => document.removeEventListener('click', handleClickOutside)
  }
}, [contextMenu])
```

### 4. Trigger on Element

```jsx
<div onContextMenu={e => handleContextMenu(e, entity)}>{/* content */}</div>
```

### 5. Context Menu Rendering

```jsx
{
  contextMenu && (
    <div
      className="fixed z-[200] bg-white rounded-lg shadow-xl border border-gray-200 py-1 min-w-[200px]"
      style={{
        left: Math.min(contextMenu.x, window.innerWidth - 220),
        top: Math.min(contextMenu.y, window.innerHeight - 300),
      }}
      onClick={e => e.stopPropagation()}
    >
      {/* menu items */}
    </div>
  )
}
```

## Visual Style

- White background with subtle shadow
- Rounded corners (rounded-lg)
- Dividers between action groups
- Icons for each action
- Keyboard shortcuts displayed (where applicable)
- Hover state with grey background
- Smart positioning to avoid viewport edges

## Files Modified

- `src/app/(dashboard)/meetings/page.tsx`
- `src/components/AlertCenter.tsx`
- `src/app/(dashboard)/nps/page.tsx`
- `src/app/(dashboard)/client-profiles/page.tsx`

## Notes

- All context menus close when clicking outside
- Menus are positioned to avoid going off-screen
- Existing Actions page already had context menu (unchanged)
- Keyboard shortcuts shown where relevant
