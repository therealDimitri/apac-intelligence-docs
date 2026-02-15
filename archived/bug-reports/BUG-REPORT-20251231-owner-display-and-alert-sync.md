# Bug Report: Owner Display and Alert-Action Sync Fixes

**Date:** 31 December 2025
**Status:** ✅ RESOLVED
**Severity:** Medium
**Components:** Actions Page, Kanban Board, Alert-Action Sync

## Problem Summary

Multiple issues were identified and fixed:

1. **Actions page showed first names only** - Owner column displayed only first names (e.g., "John", "Kenny") without profile photos
2. **Kanban board showed first names only** - Same issue in the drag-and-drop Kanban view
3. **Alert-Action links were broken** - Alerts used string `Action_ID` (e.g., "S13") in `linked_action_id` instead of numeric `id`

## Root Causes

### Issue 1 & 2: First Name Only Display

The `getFirstName` function was extracting just the first name for compact display:

```typescript
// BEFORE
const getFirstName = (name: string) => name.split(' ')[0]
```

### Issue 3: Alert-Action Link Mismatch

The `linked_action_id` column in alerts stored the string `Action_ID` (e.g., "S13", "ACT-MJSDHAY9-CT37LQ") instead of the numeric `id` (e.g., 356, 449). This caused lookups to fail.

```
Alert linked_action_id: "S13"  ← String Action_ID
Action id: 356                  ← Numeric ID
Action Action_ID: "S13"         ← Matching string, but wrong field linked
```

## Solutions Applied

### Fix 1: Actions Page Owner Display

**File:** `src/app/(dashboard)/actions/page.tsx`

1. Renamed `getFirstName` to `getDisplayOwnerName` (returns full name)
2. Added `useCSEProfiles` hook import
3. Added `EnhancedAvatar` component for profile photos
4. Increased owner column width from `w-[70px]` to `w-[140px]`

```typescript
// AFTER
{action.owners.length > 0 ? (
  <>
    <EnhancedAvatar
      src={getPhotoURL(action.owners[0])}
      name={action.owners[0]}
      size="xs"
    />
    <span className="truncate text-gray-700">
      {action.owners.length > 1
        ? `${getDisplayOwnerName(action.owners[0])} +${action.owners.length - 1}`
        : getDisplayOwnerName(action.owners[0])}
    </span>
  </>
) : (
  <span className="truncate text-gray-400">Unassigned</span>
)}
```

### Fix 2: Kanban Board Owner Display

**File:** `src/components/KanbanBoard.tsx`

1. Added `useCSEProfiles` hook import
2. Added `EnhancedAvatar` component import
3. Added `getPhotoURL` prop to `DroppableColumn` and `DraggableCard` components
4. Updated owner display to show full names with profile photos

### Fix 3: Alert-Action Link Correction

**Script:** `scripts/fix-alert-action-links.mjs`

1. Mapped string `Action_ID` to numeric `id` for each linked action
2. Updated `linked_action_id` on all 10 alerts to use numeric ID
3. Verified `source_alert_id` was already correctly set on actions

## Verification Results

```
=== SUMMARY ===
Total alerts with actions: 10
Total actions with source_alert_id: 10

All 10 pairs verified:
✅ Bidirectional link confirmed
✅ Priority in sync
```

## Files Modified

- `src/app/(dashboard)/actions/page.tsx` - Owner display with avatars
- `src/components/KanbanBoard.tsx` - Owner display with avatars
- Database: `alerts.linked_action_id` updated to numeric IDs

## Scripts Created

- `scripts/fix-alert-action-links.mjs` - One-time fix for existing data
- `scripts/check-alert-action-sync.mjs` - Verification script
- `scripts/debug-alert-action-link.mjs` - Debugging script

## Testing Checklist

- [x] TypeScript check passes (`npx tsc --noEmit`)
- [x] Actions page shows full owner names with profile photos
- [x] Kanban view shows full owner names with profile photos
- [x] All 10 alert-action pairs have bidirectional links
- [x] All priorities are in sync between alerts and actions

## Before/After

### Actions Page Owner Column

| Before | After |
|--------|-------|
| "John" | [Photo] John Salisbury |
| "Kenny" | [Photo] Kenny Gan |
| "Dimitri" | [Photo] Dimitri Leimonitis |

### Alert-Action Links

| Before | After |
|--------|-------|
| linked_action_id: "S13" | linked_action_id: "356" |
| linked_action_id: "ACT-MJSDHAY9-CT37LQ" | linked_action_id: "449" |
