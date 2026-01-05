# Bug Report: Multiple Context Menus Opening Simultaneously in Pipeline Card View

**Date:** 6 January 2026
**Status:** Fixed
**Severity:** Medium
**Component:** Pipeline View - Card Mode

---

## Problem Description

When using the Pipeline view in Card mode, right-clicking on different deal cards would open multiple context menus simultaneously. Each menu would remain open until manually closed, cluttering the UI and causing confusion.

### Steps to Reproduce (Before Fix)
1. Navigate to `/financials`
2. Click on the "Pipeline" tab
3. Switch to "Card view" mode
4. Right-click on Deal Card 1 → Context menu opens
5. Right-click on Deal Card 2 → Second context menu opens (first remains open)
6. Right-click on Deal Card 3 → Third context menu opens (first two remain open)

### Expected Behaviour
Only one context menu should be visible at any time. Opening a new context menu should automatically close any existing one.

---

## Root Cause Analysis

Each `DealCard` component managed its own `showContextMenu` state independently:

```typescript
// DealCard.tsx - BEFORE (problematic)
export function DealCard({ ... }) {
  const [showContextMenu, setShowContextMenu] = useState(false)
  // Each card tracks its own menu state independently
}
```

When right-clicking a different card, there was no mechanism to close other open menus because each card only knew about its own state.

---

## Solution Implemented

### Pattern: Lifted State for Single-Active-Component Behaviour

The fix implements a controlled component pattern where the parent (`PipelineView`) manages which context menu is currently active across all cards.

### Changes Made

**1. `src/components/pipeline/DealCard.tsx`**
- Added new props for controlled state:
  ```typescript
  interface DealCardProps {
    // ... existing props
    activeContextMenuId?: string | null
    onContextMenuChange?: (dealId: string | null, position?: { x: number; y: number }) => void
  }
  ```
- Component now supports both controlled and uncontrolled modes:
  ```typescript
  const isControlled = onContextMenuChange !== undefined
  const showContextMenu = isControlled ? activeContextMenuId === id : localShowContextMenu
  ```

**2. `src/components/pipeline/PipelineSection.tsx`**
- Added passthrough props for controlled context menu state
- Updated `DealCard` usage to pass `activeContextMenuId` and `onContextMenuChange`

**3. `src/components/pipeline/PipelineView.tsx`**
- Added state management at top level:
  ```typescript
  const [activeCardContextMenuId, setActiveCardContextMenuId] = useState<string | null>(null)

  const handleCardContextMenuChange = (dealId: string | null) => {
    setActiveCardContextMenuId(dealId)
  }
  ```
- Passes controlled state to all `PipelineSection` components

---

## Testing Verification

Automated test confirmed the fix:

```javascript
// Test Results:
{
  cardsFound: 73,
  menusAfterClick1: 1,  // ✓ One menu after first right-click
  menusAfterClick2: 1,  // ✓ Still one menu after second right-click
  menusAfterClick3: 1,  // ✓ Still one menu after third right-click
  success: true,
  message: "SUCCESS: Only one context menu is open at a time!"
}
```

Additionally verified that the "Assign Owner" action from the context menu correctly opens the modal.

---

## Files Modified

| File | Changes |
|------|---------|
| `src/components/pipeline/DealCard.tsx` | Added controlled state props, dual-mode logic |
| `src/components/pipeline/PipelineSection.tsx` | Added passthrough props, updated DealCard usage |
| `src/components/pipeline/PipelineView.tsx` | Added top-level state management, updated type |

---

## Backwards Compatibility

The fix maintains backwards compatibility:
- When `onContextMenuChange` prop is not provided, the component falls back to local state management (uncontrolled mode)
- Existing usages of `DealCard` continue to work without modification

---

## Related Issues

- Previous fix for "Assign Owner modal not appearing" (commit `5eb224e`) addressed the event handler timing issue but did not solve the multiple-menus problem

---

## Follow-up Fix: Context Menu Z-Index/Stacking Issue

### Problem

After implementing the single-menu fix, the context menu was appearing **behind** the deal cards. The menu text was partially visible but obscured by other cards.

### Root Cause

CSS stacking context issue:
- `DealCard` has `hover:-translate-y-0.5` which creates a new stacking context
- `DealContextMenu` was rendered **inside** `DealCard`
- Despite having `z-index: 9999`, the z-index was relative to the card's stacking context, not the document root
- Cards later in the DOM or with transforms would appear above the menu

### Solution: React Portal

Used `createPortal` from `react-dom` to render the context menu at `document.body` level, escaping the card's stacking context:

```typescript
// DealCard.tsx - AFTER (fixed)
import { createPortal } from 'react-dom'

// In the render:
{showContextMenu &&
  typeof document !== 'undefined' &&
  createPortal(
    <DealContextMenu {...props} />,
    document.body
  )}
```

### Verification

```javascript
// Test Results:
{
  menuInfo: {
    zIndex: "9999",
    position: "fixed",
    parentTagName: "BODY",
    isInBody: true,  // ✓ Rendered at document root
    isVisible: true
  },
  message: "SUCCESS: Context menu is rendered in document.body via Portal - z-index issue FIXED!"
}
```

### Files Modified

| File | Changes |
|------|---------|
| `src/components/pipeline/DealCard.tsx` | Added `createPortal` import, wrapped `DealContextMenu` in portal |
