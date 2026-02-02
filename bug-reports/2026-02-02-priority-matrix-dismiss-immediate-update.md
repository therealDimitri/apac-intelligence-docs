# Bug Report: Priority Matrix Dismiss Not Updating Immediately

**Date:** 2 February 2026
**Status:** Fixed
**Severity:** Low
**Component:** Priority Matrix - Alert Dismissal

## Summary

When dismissing an alert on the Priority Matrix, the item didn't disappear immediately and required a browser refresh to update the UI.

## Root Cause

The `filteredItems` useMemo in `PriorityMatrix.tsx` was reading dismissed and snoozed items directly from `localStorage`, which is not reactive in React. The handler attempted to force a re-render with `setFilters(prev => ({ ...prev }))`, but this doesn't work because:

1. `localStorage` is not a React-reactive data source
2. The shallow copy of filters doesn't change any values, so React's memo comparison sees no difference
3. The useMemo dependency array `[items, effectiveFilters]` didn't include any state that tracks localStorage changes

**Location:** `src/components/priority-matrix/PriorityMatrix.tsx`

```typescript
// Before (buggy) - reading directly from localStorage in useMemo
const filteredItems = useMemo(() => {
  const dismissedItems: string[] = JSON.parse(
    localStorage.getItem('matrix-dismissed-items') || '[]'
  )
  // ...
}, [items, effectiveFilters]) // localStorage not tracked
```

## Fix Applied

Introduced React state variables to track dismissed and snoozed items, making the UI reactive:

1. **Added state variables:**
   ```typescript
   const [dismissedIds, setDismissedIds] = useState<string[]>([])
   const [snoozedItemsState, setSnoozedItemsState] = useState<
     Record<string, { until: string; label: string }>
   >({})
   ```

2. **Added useEffect to initialise from localStorage on mount:**
   ```typescript
   useEffect(() => {
     const savedDismissed = JSON.parse(
       localStorage.getItem('matrix-dismissed-items') || '[]'
     )
     setDismissedIds(savedDismissed)
     // Similar for snoozed items
   }, [])
   ```

3. **Updated useMemo to use state instead of localStorage:**
   ```typescript
   const filteredItems = useMemo(() => {
     // Use state variables (reactive)
     if (dismissedIds.includes(item.id)) {
       return false
     }
     // ...
   }, [items, effectiveFilters, dismissedIds, snoozedItemsState])
   ```

4. **Updated handlers to update both state and localStorage:**
   ```typescript
   const handleDismissItem = useCallback((item: MatrixItemType) => {
     setDismissedIds(prev => {
       if (prev.includes(item.id)) return prev
       const updated = [...prev, item.id]
       localStorage.setItem('matrix-dismissed-items', JSON.stringify(updated))
       return updated
     })
   }, [])
   ```

## Files Changed

- `src/components/priority-matrix/PriorityMatrix.tsx` - Added reactive state for dismissed/snoozed items

## Key Insight

localStorage is not reactive in React. When using localStorage values in useMemo or any computed values, you must:
1. Mirror the localStorage data in React state
2. Include the state in the dependency array
3. Update both state AND localStorage in handlers

The state update triggers React's re-render cycle, while localStorage provides persistence across sessions.

## Verification

1. Build passes with zero TypeScript errors
2. All 118 tests pass
3. Dismissing an alert now removes it from the UI immediately
4. Snoozed items also update immediately when snoozing
5. Changes persist across page refreshes (localStorage still works)
