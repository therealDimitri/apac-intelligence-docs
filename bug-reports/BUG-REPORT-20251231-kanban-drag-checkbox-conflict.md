# Bug Report: Kanban Drag Handle/Checkbox Conflict

**Date:** 31 December 2025
**Status:** ✅ RESOLVED
**Severity:** High
**Component:** Kanban Board (KanbanBoard.tsx)

## Problem Summary

Two UX issues in the Kanban board:

1. **Checkbox replacing drag handle** - On hover, the batch selection checkbox completely replaced the drag handle, making it impossible to drag cards between columns
2. **Card animation causing layout shift** - The `transition-all` CSS class caused the entire card to animate when the checkbox appeared, creating a distracting visual effect

## Root Cause

### Issue 1: Conditional Rendering

The code used an either/or pattern:

```typescript
{showCheckbox ? (
  <button>Checkbox</button>  // ← No drag listeners!
) : (
  <button {...listeners}>Drag handle</button>  // ← Hidden on hover!
)}
```

When hovering, `showCheckbox` became true and the drag handle was completely removed from the DOM.

### Issue 2: Overly Broad Transitions

```typescript
className="... transition-all ..."
```

The `transition-all` animated every CSS property change, including layout shifts when elements appeared/disappeared.

## Solution Applied

### Fix 1: Side-by-Side Layout

Changed from either/or to side-by-side with a fixed-width container:

```typescript
<div className="flex items-center gap-0.5 flex-shrink-0 w-[38px]">
  {/* Checkbox - appears on hover */}
  {showCheckbox && (
    <button onClick={handleCheckboxClick}>...</button>
  )}

  {/* Drag handle - ALWAYS rendered */}
  <button {...listeners}>
    <GripVertical />
  </button>
</div>
```

### Fix 2: Specific Transitions

Changed from `transition-all` to specific properties:

```typescript
// BEFORE
className="... transition-all ..."

// AFTER
className="... transition-shadow transition-colors ..."
```

### Fix 3: Visual Feedback Without Layout Shift

- Fixed container width (`w-[38px]`) prevents layout shift
- Drag handle uses opacity change (`opacity-40` → `opacity-100`) instead of appearing/disappearing
- Removed `scale-105` from dragging state to prevent card size animation

## Visual Comparison

### Before
```
┌────────────────────────────────┐
│ ⋮⋮  Title                     │  ← Drag handle visible
└────────────────────────────────┘

┌────────────────────────────────┐
│ ☐   Title                     │  ← On hover: checkbox REPLACES drag handle
└────────────────────────────────┘    (Can't drag!)
```

### After
```
┌────────────────────────────────┐
│    ⋮⋮  Title                  │  ← Drag handle (40% opacity)
└────────────────────────────────┘

┌────────────────────────────────┐
│ ☐ ⋮⋮  Title                   │  ← On hover: BOTH visible, drag handle 100%
└────────────────────────────────┘    (Can still drag!)
```

## Files Modified

- `src/components/KanbanBoard.tsx` - DraggableCard component

## UX Pattern Reference

This fix follows the **Linear/Asana pattern** where:
- Drag handle is always available
- Batch selection checkbox appears on hover without displacing other controls
- Fixed-width container prevents layout shift

## Testing Checklist

- [x] TypeScript check passes (`npx tsc --noEmit`)
- [x] Checkbox appears on hover without hiding drag handle
- [x] Cards can be dragged while checkbox is visible
- [x] No layout shift when hovering over cards
- [x] Selected cards show both checkbox (checked) and drag handle
