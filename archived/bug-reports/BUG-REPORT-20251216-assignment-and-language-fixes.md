# Bug Fixes: Assignment System and Language Updates

**Date:** 16 December 2025
**Type:** Bug Fix / Enhancement
**Status:** Completed

## Issues Addressed

### 1. AssigneeSuggestions Overlapping Text and Photo Display

**Problem:** In the assignment menu, helper text (CSE, Me, Recent badges) was overlapping with assignee names, and profile photos weren't displaying correctly.

**Root Cause:**

- Badge used absolute positioning (`-bottom-0.5`) causing overlap with name
- Photo and fallback initials were both rendered simultaneously, with fallback on top

**Fix:** Updated `AssigneeSuggestions.tsx`:

- Moved badge to natural flexbox flow (no longer absolutely positioned)
- Used React state to track image load errors
- Conditionally render photo OR fallback (not both)
- Added proper z-index ordering
- Added `minWidth` for consistent button sizing

### 2. Alarmist Language Updates

**Problem:** Dashboard language used negative, alarmist terms like "severely behind schedule", "overdue", "at-risk" which doesn't support a positive coaching culture.

**Fix:** Updated multiple files with constructive language:

| Original                             | Updated                                                           |
| ------------------------------------ | ----------------------------------------------------------------- |
| "severely behind schedule"           | "opportunity to accelerate progress"                              |
| "behind schedule"                    | "ready to advance"                                                |
| "days overdue. Blocking progress..." | "days past scheduled date. Ready to complete for client success." |
| "NPS score declining"                | "NPS score trending - engagement opportunity"                     |
| "Attrition Risk"                     | "Renewal Focus"                                                   |
| "Overdue Task"                       | "Task Ready to Complete"                                          |
| "at-risk clients"                    | "focus clients"                                                   |
| "Immediate action required"          | "Priority focus"                                                  |

### 3. Misleading Multi-Client Event Count

**Problem:** Multi-client events showed portfolio-wide counts (e.g., "Complete 30 Insight Touch Point events") which was misleading when displayed for individual clients.

**Fix:** Updated `ActionableIntelligenceDashboard.tsx`:

- Changed task language from "Complete X events" to "Schedule [Event Name] events"
- Updated recommended action to show client count: "X clients require this event"

### 4. Multi-Client Assignment Badge Not Displaying

**Problem:** When assigning multi-client items via the MultiClientAssignmentModal, the assigned badge didn't appear on the matrix item.

**Root Cause:** The `handleMultiClientAssignSubmit` function didn't dispatch the `matrixItemAssigned` custom event that triggers the badge update.

**Fix:** Added event dispatch after successful multi-client assignment:

```typescript
// After successful assignments
const assignees = [...new Set(results.filter(r => r.success).map(r => r.assigneeName))]
const ownerLabel = assignees.length === 1 ? assignees[0] : `${assignees.length} CSEs`

window.dispatchEvent(
  new CustomEvent('matrixItemAssigned', {
    detail: { itemId: multiClientModal.item.id, owner: ownerLabel },
  })
)
```

### 5. Assigned Badge Not Clearing When Action Deleted

**Problem:** When an action linked to an alert was deleted, the "Assigned to" badge persisted on the matrix item because the owner data was stored in localStorage.

**Root Cause:** localStorage owner entries were never cleaned up when the underlying items were deleted.

**Fix:** Added `cleanupStalePersistedData()` function to `MatrixContext.tsx`:

- Called during `applyPersistedData()` to remove stale entries
- Removes owner and position entries for item IDs that no longer exist
- Logs cleanup actions for debugging

```typescript
function cleanupStalePersistedData(currentItemIds: Set<string>) {
  const owners = loadPersistedOwners()
  Object.keys(owners).forEach(itemId => {
    if (!currentItemIds.has(itemId)) {
      console.log('[MatrixContext] Removing stale owner for deleted item:', itemId)
      delete owners[itemId]
    }
  })
  localStorage.setItem(STORAGE_KEY_OWNERS, JSON.stringify(owners))
}
```

## Files Modified

- `src/components/assignment/AssigneeSuggestions.tsx` - Photo display and badge layout
- `src/components/ActionableIntelligenceDashboard.tsx` - Language updates, multi-client badge fix
- `src/components/priority-matrix/utils.ts` - Alert type labels
- `src/components/priority-matrix/MatrixContext.tsx` - Stale data cleanup
- `src/components/ChasenWelcomeModal.tsx` - Suggestion text
- `src/app/(dashboard)/priority-matrix-demo/page.tsx` - Demo data language
- `src/app/api/assignment/route.ts` - Clean action titles from aggregate counts
- `src/app/api/assignment/bulk/route.ts` - Clean action titles from aggregate counts

## Testing Verification

- TypeScript compilation: Passed
- All changes maintain backward compatibility
- Badge now displays for both single-client and multi-client assignments
- Badge is automatically removed when linked item is deleted
- Language is consistent across dashboard components

## Notes

- The compact view badge issue was verified to use the same data source as comfortable view
- Debug logging remains in place for ongoing monitoring
- Multi-client assignments now show "X CSEs" when multiple assignees are involved
- Stale localStorage entries are automatically cleaned up when items no longer exist

### 6. Assignment Badges Not Persisting Across Quadrants on Refresh

**Problem:** Assignment badges were being cleared on page refresh, not persisting across all quadrants.

**Root Cause:** The `cleanupStalePersistedData()` function was running during initial render when `initialItems` was empty (data still loading), causing it to delete ALL saved owner data from localStorage.

**Fix:** Added guard to skip cleanup when no items exist:

```typescript
// Don't clean up if no items exist yet (data still loading)
if (currentItemIds.size === 0) {
  console.log('[MatrixContext] Skipping cleanup - no items to compare against (data loading)')
  return
}
```

This ensures cleanup only runs when there's actual data to compare against, preventing premature deletion of valid localStorage entries

### 7. Action Titles Using Aggregate Counts for Individual Clients

**Problem:** Actions created from multi-client alerts displayed aggregate counts in titles (e.g., "Re-engage dormant clients (10) - Barwon Health Australia") which is misleading for individual client actions.

**Root Cause:** The API routes creating actions from Priority Matrix assignments passed the original multi-client alert title directly to the action description without stripping aggregate count indicators.

**Fix:** Added `cleanEventTitleForClient()` function to both assignment API routes:

- `src/app/api/assignment/route.ts`
- `src/app/api/assignment/bulk/route.ts`

```typescript
// Clean event title by removing aggregate counts for individual client actions
// e.g., "Re-engage dormant clients (10)" -> "Re-engage dormant client"
// e.g., "Sustain improvement momentum (3 clients)" -> "Sustain improvement momentum"
function cleanEventTitleForClient(title: string): string {
  // Remove patterns like "(10)", "(3 clients)", "(X clients)"
  let cleaned = title
    .replace(/\s*\(\d+\s*clients?\)/gi, '') // "(10)", "(3 clients)"
    .replace(/\s*\(\d+\)/g, '') // Just "(10)"
    .trim()

  // Make "clients" singular if it appears at the end
  if (cleaned.endsWith('clients')) {
    cleaned = cleaned.replace(/clients$/, 'client')
  }

  return cleaned
}
```

The function is applied when creating new action records to ensure individual client actions have accurate, non-misleading titles
