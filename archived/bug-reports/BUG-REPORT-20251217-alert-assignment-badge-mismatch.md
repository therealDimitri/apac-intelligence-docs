# Bug Report: Alert Assignment Badge Shows but Modal Cannot Clear

**Date**: 17 December 2024
**Status**: Fixed
**Severity**: Medium

## Issue

Alert cards displayed an "Assigned to CSE" badge but when opening the assignment modal, no CSEs were shown as assigned and the "Clear Assignment" button was not available.

## Root Cause

When matrix items were created from data sources:

1. **Priority Actions** included `owner` in their metadata (from database)
2. **Critical Alerts** did NOT include `owner` in their metadata (no owner field in source data)

However, when an assignment was made:

1. The owner was stored in localStorage (`priority-matrix-item-owners`)
2. The owner was also sent to the database

On subsequent page loads/renders:

1. The badge displayed correctly because it read from `item.metadata?.owner`
2. BUT - for critical alerts, this was always `undefined` because the source data didn't have an owner field
3. The localStorage owner was stored but NOT merged back into the item metadata

This resulted in a **mismatch**:

- Badge showed the owner (from localStorage in some views, or cached data)
- Modal showed no owner (reading from `item.metadata.owner` which was `undefined`)

## Solution

Modified `createMatrixItems()` in `src/components/priority-matrix/utils.ts` to:

1. Load stored owners from localStorage after creating items
2. Merge localStorage owners into items that don't have one in their metadata

```typescript
function loadStoredOwners(): Record<string, string> {
  if (typeof window === 'undefined') return {}
  try {
    return JSON.parse(localStorage.getItem('priority-matrix-item-owners') || '{}')
  } catch {
    return {}
  }
}

export function createMatrixItems(...): MatrixItem[] {
  const items = [
    ...criticalAlertsToMatrixItems(criticalAlerts),
    ...priorityActionsToMatrixItems(priorityActions),
    ...aiRecommendationsToMatrixItems(aiRecommendations),
    ...smartInsightsToMatrixItems(smartInsights),
  ]

  // Merge localStorage owners into items that don't have one
  const storedOwners = loadStoredOwners()
  return items.map(item => {
    const storedOwner = storedOwners[item.id]
    if (storedOwner && !item.metadata?.owner) {
      return {
        ...item,
        metadata: {
          ...item.metadata,
          owner: storedOwner,
        },
      }
    }
    return item
  })
}
```

## Files Modified

- `src/components/priority-matrix/utils.ts`
  - Added `loadStoredOwners()` function
  - Modified `createMatrixItems()` to merge localStorage owners

## Testing

1. Navigate to Priority Matrix or Actionable Intelligence Dashboard
2. Right-click an alert and assign to a CSE
3. Refresh the page
4. Verify the badge still shows the assigned CSE
5. Right-click the same alert
6. Verify the modal shows "Currently assigned to: [CSE Name]"
7. Verify the "Clear Assignment" button is visible
8. Click "Clear Assignment" and verify it removes the assignment

## Notes

- The debug logging in `MatrixItem.tsx` (lines 47-51) was helpful in identifying this issue
- The logging shows `MISMATCH: YES` when localStorage has an owner but `item.metadata.owner` is empty
- This fix ensures consistency between the badge display and modal data

---

## Follow-up Fix: Multi-Client Assignments

**Issue**: The initial fix only handled single-owner items. Multi-client assignments (stored in `priority-matrix-client-assignments`) were not being merged.

**Additional Changes**:

- Added `loadStoredClientAssignments()` to load per-client assignments
- Added `deriveOwnerFromClientAssignments()` to create owner label ("X CSEs" or single name)
- Extended `createMatrixItems()` to check both storage locations

**Commit**: `947141d`

---

## Additional Fix: Duplicate "View Client Profile" Links

**Issue**: Attrition alerts showed duplicate "View Client Profile" action buttons.

**Root Cause**: The actions array in attrition alerts had two "View Client Profile" entries - one pointing to `/client-profiles` and another to `/clients`.

**Fix**: Removed the duplicate entry in `ActionableIntelligenceDashboard.tsx`.

**Commit**: `dddb30b`

---

## Additional Fix: "Clear All" Button Not Clearing Assignments

**Issue**: In the multi-client assignment modal, clicking "Clear all" only cleared the local state but did not persist the clear to localStorage. The Assign button was disabled when there were no assignments, preventing users from saving the cleared state.

**Root Cause**:

1. `handleClearAll` in MultiClientAssignmentModal only cleared component state, not localStorage
2. The Assign button was disabled when `assignedCount === 0`, preventing submission of cleared state
3. `handleMultiClientAssignSubmit` only processed assignments where `assignee !== null`

**Solution**:

- Added `onClearAll` prop to `MultiClientAssignmentModal`
- Implemented `handleClearAllAssignments` in `ActionableIntelligenceDashboard.tsx`
- Clear handler calls `clearItemOwner(itemId)` to clear both localStorage keys
- Dispatches event to update matrix item metadata (removes owner badge)
- "Clear all" button now shows when there are saved OR local assignments
- Shows loading state while clearing

**Files Modified**:

- `src/components/assignment/MultiClientAssignmentModal.tsx`
  - Added `onClearAll` prop
  - Added `isClearing` state
  - Added `hasSavedAssignments` computed value
  - Updated "Clear all" button to show loading state and persist changes
- `src/components/ActionableIntelligenceDashboard.tsx`
  - Added `clearItemOwner` import
  - Added `handleClearAllAssignments` handler
  - Passed `onClearAll` prop to modal

**Commit**: `a629e8d`
