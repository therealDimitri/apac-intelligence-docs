# Bug Report: Context Menu Cut Off on Right Side of Screen

**Date:** 22 December 2024
**Status:** Fixed
**Component:** ActionContextMenu.tsx, KanbanBoard.tsx

---

## Problem Description

Right-click context menu on action cards in the Kanban board was being cut off when clicking items in the Completed column (right side of screen). The submenus for "Change Status" and "Change Priority" would overflow off the right edge of the viewport.

## Root Cause

The submenus were hardcoded to always open to the right using CSS class `left-full`, regardless of the menu's position relative to the viewport edge.

## Solution

Added viewport boundary detection to dynamically position submenus:

1. **Added detection logic** to check if the menu is near the right edge:

```typescript
const openSubmenuLeft =
  typeof window !== 'undefined' && position.x + menuWidth + submenuWidth > window.innerWidth
```

2. **Updated submenu positioning** to conditionally open left or right:

```tsx
className={`absolute top-0 ... ${
  openSubmenuLeft ? 'right-full mr-1' : 'left-full ml-1'
}`}
```

3. **Added visual indicator** - chevron icon rotates 180° when submenus open to the left:

```tsx
<ChevronRight
  className={`h-4 w-4 text-gray-400 transition-transform ${openSubmenuLeft ? 'rotate-180' : ''}`}
/>
```

## Files Modified

- `src/components/ActionContextMenu.tsx` - Added viewport detection and conditional positioning

## Testing

- Right-click on items in Completed column (right side) → submenus open to the left
- Right-click on items in Not Started column (left side) → submenus open to the right (default)
- Build passes successfully

## Prevention

For future context menus or dropdown components, always implement viewport boundary detection to ensure menus remain fully visible regardless of trigger position.
