# Bug Report: Command Centre Duplicate UI Elements

**Date:** 31 December 2025
**Status:** Resolved
**Severity:** Medium
**Component:** Priority Matrix / Command Centre

## Summary

The Command Centre page displayed duplicate headers, filter bars, and toggle controls when rendering the Priority Matrix in matrix view mode.

## Root Cause

`PriorityMatrixMultiView` embeds `PriorityMatrix` when the matrix view is selected. Both components independently rendered their own:
- Header with title and item count
- Density toggle (Compact/Comfortable)
- Filter bar with search and dropdowns

Additionally, the density state was not shared between components, causing the toggle to appear non-functional.

## Symptoms

1. Two "Priority Matrix (40)" headers appeared
2. Two filter bars with identical controls
3. Compact/Comfortable toggles didn't affect the matrix view
4. Expand/Collapse and Bulk Select buttons were initially hidden after first fix attempt

## Solution

### 1. Added `hideHeader` prop to `PriorityMatrix`

```typescript
interface PriorityMatrixProps {
  hideHeader?: boolean
  externalDensity?: DensityMode
}
```

When `hideHeader={true}`:
- Title, count, and density toggle are hidden (parent provides these)
- Filter bar is hidden (parent provides this)
- Expand/Collapse and Bulk Select buttons remain visible

### 2. Added `externalDensity` prop for shared state

```typescript
// In PriorityMatrix
const effectiveDensity = externalDensity ?? density
```

When embedded, the parent's density state controls the matrix display.

### 3. Updated `PriorityMatrixMultiView` to pass props

```tsx
<OriginalPriorityMatrix
  hideHeader
  externalDensity={density}
/>
```

## Files Modified

- `src/components/priority-matrix/PriorityMatrix.tsx`
  - Added `hideHeader` and `externalDensity` props
  - Conditionally render header elements
  - Use `effectiveDensity` for display

- `src/components/priority-matrix/PriorityMatrixMultiView.tsx`
  - Pass `hideHeader` and `externalDensity` to embedded matrix
  - Cleaned up unused imports

## Testing

1. Navigate to Command Centre (/priority-matrix)
2. Verify single header with view switcher and density toggle
3. Verify single filter bar
4. Verify Compact/Comfortable toggle changes item display
5. Verify Expand/Collapse buttons work
6. Verify Bulk Select mode works
7. Switch between Matrix/Swimlane/Agenda/List views

## Commits

- `a367141` - fix: Remove duplicate header and filter bar in Command Centre
- `c7eebc1` - fix: Restore expand/collapse and bulk select buttons in embedded matrix
- `db19e0e` - fix: Wire up density toggle to embedded PriorityMatrix
