# Bug Report: Priority Matrix Search/Filter Not Applied to Quadrants

**Date:** 31 December 2025
**Status:** ✅ RESOLVED
**Severity:** High
**Component:** Priority Matrix, Command Centre

## Problem Summary

The Priority Matrix search bar and filter options on the Command Centre page were not filtering the displayed items in the quadrants. The header count updated correctly, but all quadrants continued to show unfiltered data.

### Symptoms

1. Search bar input updated header count (e.g., "(1)") but quadrants showed original counts
2. Filter dropdowns (Owner, Client, Priority, Type) had no effect on displayed items
3. Quadrants continued to show "10 items", "15 items" etc. regardless of active filters

### Example

User searched for "cus":
- **Header:** Correctly showed "(1)"
- **DO NOW quadrant:** Incorrectly showed "10 items" (should show "1 item")
- **PLAN quadrant:** Incorrectly showed "15 items" (should show "0 items")
- **Other quadrants:** Also showed unfiltered counts

## Root Cause

The `PriorityMatrixMultiView` component embedded `PriorityMatrix` with a `hideHeader` prop to avoid duplicate headers. However, both components maintained their own separate filter state:

```
┌─────────────────────────────────────────────────────────────┐
│  PriorityMatrixMultiView                                     │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  filters state ← MatrixFilterBar updates this        │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  PriorityMatrix (embedded, hideHeader=true)          │    │
│  │  ┌─────────────────────────────────────────────┐    │    │
│  │  │  SEPARATE filters state ← never updated!     │    │    │
│  │  │  filteredItems uses THIS state               │    │    │
│  │  └─────────────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

When `PriorityMatrixMultiView` rendered the `OriginalPriorityMatrix`:
- The visible filter bar updated `PriorityMatrixMultiView`'s filter state
- But `PriorityMatrix` used its own internal filter state (which remained empty)
- Result: Header showed filtered count, quadrants showed unfiltered items

## Solution Applied

### 1. Added `externalFilters` prop to `PriorityMatrix`

```typescript
interface PriorityMatrixProps {
  // ... existing props
  /** External filters control (used when embedded in MultiView) */
  externalFilters?: MatrixFilters
}
```

### 2. Use effective filters pattern

```typescript
export function PriorityMatrix({
  // ...
  externalFilters,
}: PriorityMatrixProps) {
  // Internal filter state (used when component is standalone)
  const [filters, setFilters] = useState<MatrixFilters>({
    owners: [],
    clients: [],
    priorities: [],
    types: [],
    searchQuery: '',
  })

  // Use external filters when provided (embedded), otherwise use internal state
  const effectiveFilters = externalFilters ?? filters

  // Apply filters using effectiveFilters
  const filteredItems = useMemo(() => {
    return items.filter(item => {
      if (effectiveFilters.owners.length > 0) {
        // ... filter logic
      }
      // ... rest of filters
    })
  }, [items, effectiveFilters])
}
```

### 3. Pass filters from parent

```typescript
// In PriorityMatrixMultiView.tsx
{currentView === 'matrix' && (
  <OriginalPriorityMatrix
    onItemMove={onItemMove}
    onAssign={onAssign}
    onMultiClientAssign={onMultiClientAssign}
    hideHeader
    externalDensity={density}
    externalFilters={filters}  // ← NEW: Pass parent's filter state
  />
)}
```

## Files Modified

- `src/components/priority-matrix/PriorityMatrix.tsx` - Added `externalFilters` prop and `effectiveFilters` pattern
- `src/components/priority-matrix/PriorityMatrixMultiView.tsx` - Pass `externalFilters` to embedded matrix

## Data Flow After Fix

```
┌─────────────────────────────────────────────────────────────┐
│  PriorityMatrixMultiView                                     │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  filters state ← MatrixFilterBar updates this        │    │
│  └──────────────────────┬──────────────────────────────┘    │
│                         │                                    │
│                         ▼ externalFilters={filters}          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  PriorityMatrix (embedded, hideHeader=true)          │    │
│  │  ┌─────────────────────────────────────────────┐    │    │
│  │  │  effectiveFilters = externalFilters ?? filters│    │    │
│  │  │  filteredItems uses effectiveFilters ✓        │    │    │
│  │  └─────────────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Verification

After fix, searching for "cus" on Command Centre:
- **Header:** "(1)" ✓
- **DO NOW:** "1 item" ✓ (shows "Reviewing performance of Custom Reports")
- **PLAN:** "0 items" ✓
- **OPPORTUNITIES:** "0 items" ✓
- **INFORM:** "0 items" ✓

## Testing Checklist

- [x] TypeScript check passes (`npx tsc --noEmit`)
- [x] Search bar correctly filters quadrant items
- [x] Header count matches total filtered items across quadrants
- [x] Standalone `/priority-matrix` page still works (uses internal filters)
- [x] Embedded matrix in Command Centre uses external filters

## Design Pattern

This fix uses the "controlled vs uncontrolled" component pattern common in React:
- **Standalone mode:** Component manages its own filter state (uncontrolled)
- **Embedded mode:** Parent controls filter state via props (controlled)

The `effectiveFilters = externalFilters ?? filters` pattern allows the component to work in both modes without breaking existing usage.
