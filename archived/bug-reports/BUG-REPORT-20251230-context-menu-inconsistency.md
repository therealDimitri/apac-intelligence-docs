# Bug Report: Context Menu Inconsistency Across Views

**Date:** 30 December 2025
**Status:** Fixed
**Severity:** Medium (UX inconsistency)

---

## Issue Summary

Right-click context menus displayed inconsistent options and styling between the Actions list view and Kanban board view. This violated the core principle of the unified actions system.

---

## Problem Details

### Symptoms
- Different menu items available in list view vs Kanban view
- Different styling and visual appearance
- Different functionality and behaviour
- Users confused by inconsistent experience

### Root Cause
Two separate context menu implementations existed:
1. **Actions page**: Inline JSX with custom styling (lines 2264-2388 in `/actions/page.tsx`)
2. **KanbanBoard**: Used `ActionContextMenu.tsx` component

Neither used the unified `UnifiedContextMenu` component that was designed for consistency.

---

## Solution Applied

### 1. Created LegacyContextMenuAdapter

New adapter component that wraps `UnifiedContextMenu` for use with the legacy `Action` type:

**File:** `src/components/unified-actions/LegacyContextMenuAdapter.tsx`

```typescript
export function LegacyContextMenuAdapter({
  action,        // Legacy Action type
  position,
  onClose,
  onViewDetails,
  onEdit,
  onStatusChange,
  onPriorityChange,
  onAssign,
  onDuplicate,
  onDelete,
}: LegacyContextMenuAdapterProps) {
  // Converts legacy Action to UnifiedAction
  const unifiedAction = legacyToUnified(action)

  // Wraps callbacks to convert back to legacy types
  return <UnifiedContextMenu action={unifiedAction} /* ... */ />
}
```

### 2. Updated KanbanBoard

**File:** `src/components/KanbanBoard.tsx`

- Changed import from `ActionContextMenu` to `LegacyContextMenuAdapter`
- Updated props to match new interface

### 3. Updated Actions Page

**File:** `src/app/(dashboard)/actions/page.tsx`

- Removed inline context menu JSX (120+ lines)
- Replaced with `LegacyContextMenuAdapter` component
- Wired up all callbacks (status, priority, assign, delete, etc.)

---

## Unified Context Menu Features

The `UnifiedContextMenu` now provides consistent features across all views:

| Feature | Before (List) | Before (Kanban) | After (Both) |
|---------|---------------|-----------------|--------------|
| Quick Actions Bar | ❌ | ❌ | ✅ Start/Done/Duplicate |
| View Details | ✅ | ✅ | ✅ |
| Edit | ✅ | ✅ | ✅ |
| Status Submenu | ❌ Inline buttons | ✅ | ✅ |
| Priority Submenu | ❌ | ✅ | ✅ |
| Assign to... | ✅ | ❌ | ✅ |
| Set Reminder | ❌ | ❌ | ✅ |
| Link to Meeting | ❌ | ❌ | ✅ |
| Add to Initiative | ❌ | ❌ | ✅ |
| Delete | ❌ | ✅ | ✅ |
| Dark Mode Support | ❌ | ❌ | ✅ |
| Footer with ID | ❌ | ❌ | ✅ |

---

## Files Changed

1. `src/components/unified-actions/index.ts` - Added export
2. `src/components/unified-actions/LegacyContextMenuAdapter.tsx` - New file
3. `src/components/KanbanBoard.tsx` - Updated to use adapter
4. `src/app/(dashboard)/actions/page.tsx` - Replaced inline menu

---

## Testing Verification

- TypeScript compilation: Passes
- List view context menu: Uses unified menu
- Kanban view context menu: Uses unified menu
- All menu options functional
- Consistent appearance across views

---

## Prevention

To maintain consistency going forward:

1. **Always use `LegacyContextMenuAdapter`** when adding context menus to components using the `useActions` hook
2. **Use `UnifiedContextMenu` directly** when working with `useUnifiedActions` hook
3. **Never create inline context menus** - always use the unified components
4. **Check design system docs** at `docs/features/UNIFIED-ACTIONS-SYSTEM.md`

---

## Related Files

- `src/components/unified-actions/UnifiedContextMenu.tsx` - Source of truth for context menu design
- `docs/features/UNIFIED-ACTIONS-SYSTEM.md` - Documentation

