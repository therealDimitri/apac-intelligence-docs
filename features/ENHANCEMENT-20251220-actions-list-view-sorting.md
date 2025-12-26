# Enhancement: Actions List View Sorting & Date Format

**Date:** 20 December 2025
**Status:** Completed
**Component:** Actions Page
**File:** `src/app/(dashboard)/actions/page.tsx`

## Enhancement Description

Updated the Actions list view to match the sorting behaviour of the grid/status view, and standardised all date displays to use dd/mm/yyyy format.

## Changes Made

### 1. Date Format (dd/mm/yyyy)

Updated `formatDate()` function to consistently return dates in Australian/British format:

**Before:** `12/25/2025` (MM/DD/YYYY - American format)
**After:** `25/12/2025` (dd/mm/yyyy - Australian format)

The function now:

- Detects existing date formats and converts to dd/mm/yyyy
- Handles ISO date strings from the database
- Assumes ambiguous dates are already in dd/mm/yyyy format

### 2. List View Sorting

The list view now uses the same sorting logic as the grid/status view:

**Sort Priority:**

1. **Status Group Order:**
   - Open (first)
   - In Progress
   - Completed
   - Cancelled (last)

2. **Assigned Clients First** - Within each status group, user's assigned clients appear before others

3. **Date Sorting by Status:**
   - **Outstanding (Open/In Progress):** Due date ascending (earliest/overdue first)
   - **Completed/Cancelled:** Due date descending (most recently completed first)

## Code Changes

### formatDate Function

```typescript
// Before: returned MM/DD/YYYY
return `${month}/${day}/${year}` // MM/DD/YYYY format

// After: returns dd/mm/yyyy
return `${day}/${month}/${year}` // dd/mm/yyyy format
```

### filteredActions Sorting

```typescript
const statusOrder: Record<string, number> = {
  open: 0,
  'in-progress': 1,
  completed: 2,
  cancelled: 3,
}

filtered.sort((a, b) => {
  // Priority 1: Status group
  const aStatusOrder = statusOrder[a.status] ?? 4
  const bStatusOrder = statusOrder[b.status] ?? 4
  if (aStatusOrder !== bStatusOrder) {
    return aStatusOrder - bStatusOrder
  }

  // Priority 2: Assigned clients first
  // ...

  // Priority 3: Date sorting based on status
  if (a.status === 'completed' || a.status === 'cancelled') {
    return bDate - aDate // Descending for completed
  }
  return aDate - bDate // Ascending for outstanding
})
```

## Behaviour Summary

| View          | Outstanding Actions    | Completed Actions       |
| ------------- | ---------------------- | ----------------------- |
| Grid (Status) | Due date ↑ (ascending) | Due date ↓ (descending) |
| List          | Due date ↑ (ascending) | Due date ↓ (descending) |

Both views now display dates in `dd/mm/yyyy` format.

## Additional Fix: Grouping Functions

The initial implementation didn't work because the grouping functions (`groupSimilarActions` and `getUngroupedActions`) were overriding the sorting.

**Root Cause:** These functions created groups/ungrouped lists but then sorted them with their own logic, ignoring the pre-sorted input.

**Solution:** Added `sortDirection` parameter to both functions:

- `'asc'` - for outstanding actions (earliest due date first)
- `'desc'` - for completed/cancelled actions (most recent first)

```typescript
// Updated function signatures
const groupSimilarActions = (actions: Action[], sortDirection: 'asc' | 'desc' = 'asc')
const getUngroupedActions = (actions: Action[], sortDirection: 'asc' | 'desc' = 'asc')

// Usage in completed section
groupSimilarActions(actionsByStatus.completed, 'desc')
getUngroupedActions(actionsByStatus.completed, 'desc')

// Usage in cancelled section
groupSimilarActions(actionsByStatus.cancelled, 'desc')
getUngroupedActions(actionsByStatus.cancelled, 'desc')
```

## Comment Count Integration

Added integration with the unified comments system to show actual comment counts per action.

### New Hook: useCommentCounts

Created `src/hooks/useCommentCounts.ts` to efficiently fetch comment counts for multiple entities:

```typescript
const { getCount, refetch } = useCommentCounts({
  entityType: 'action',
  entityIds: actionIds,
  enabled: actionIds.length > 0,
})
```

### UI Changes

- Comment icon now **always visible** on every action row
- **Purple with count badge** when action has comments (shows actual count)
- **Grey/muted** when action has no comments
- Badge shows count (or "99+" for large counts)
- Comment counts refresh when detail modal closes

### Example

```jsx
{/* Comments indicator - always visible */}
const commentCount = getCommentCount(action.id)
<MessageSquare />
{hasComments && (
  <span className="badge">{commentCount}</span>
)}
```

## Files Modified

- `src/app/(dashboard)/actions/page.tsx`
- `src/hooks/useCommentCounts.ts` (new)
