# Bug Report: Priority Matrix Default View Changed to Collapsed

**Date:** 2026-01-07
**Status:** Resolved
**Priority:** Low
**Component:** Priority Matrix

---

## Issue Summary

The Priority Matrix quadrants were defaulting to expanded view on page load. User requested the default view be changed to collapsed for a cleaner initial display.

---

## Root Cause

The `collapsedQuadrants` state was initialised with an empty Set, causing all quadrants to be expanded by default:

```typescript
const [collapsedQuadrants, setCollapsedQuadrants] = useState<Set<QuadrantType>>(new Set())
```

---

## Solution Implemented

Changed the initial state to include all quadrant types, making all quadrants collapsed by default.

### Changes Made

**File:** `src/components/priority-matrix/PriorityMatrix.tsx`

**Before:**
```typescript
const [collapsedQuadrants, setCollapsedQuadrants] = useState<Set<QuadrantType>>(new Set())
```

**After:**
```typescript
// Default all quadrants to collapsed view for cleaner initial display
const [collapsedQuadrants, setCollapsedQuadrants] = useState<Set<QuadrantType>>(
  new Set(Object.keys(QUADRANT_CONFIGS) as QuadrantType[])
)
```

---

## User Experience

| State | Description |
|-------|-------------|
| **Before** | All 4 quadrants expanded on page load, showing all items |
| **After** | All 4 quadrants collapsed on page load, showing only headers with item counts |

Users can still:
- Click "Expand" button to expand all quadrants
- Click individual quadrant headers to expand/collapse them
- The Expand/Collapse toggle buttons continue to work as expected

---

## Files Modified

| File | Changes |
|------|---------|
| `src/components/priority-matrix/PriorityMatrix.tsx` | Changed initial state for `collapsedQuadrants` to include all quadrants |

---

## Testing Verification

- [x] TypeScript compilation passes (`npx tsc --noEmit`)
- [x] All quadrants collapsed on initial load
- [x] Expand button expands all quadrants
- [x] Collapse button collapses all quadrants
- [x] Individual quadrant headers toggle correctly

---

## Related Files

- `src/components/priority-matrix/types.ts` - QUADRANT_CONFIGS definition
- `src/components/priority-matrix/MatrixQuadrant.tsx` - Quadrant rendering with collapse state
