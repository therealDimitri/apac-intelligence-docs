# Bug Report: Activity Slideover Status Dropdown Empty & Edit Button Hidden

**Date:** 2026-01-02
**Severity:** Medium
**Status:** Fixed
**Commit:** 5dd28c7

## Summary

Two issues in the ActivityDetailSlideOver component:
1. Status dropdown showing empty instead of the action's current status
2. Edit button in footer hidden behind ChaSen floating AI icon

## Symptoms

### Issue 1: Status Dropdown Empty
- Status dropdown appeared but showed no selected value
- Selecting a status didn't show the previous selection correctly
- Affected all actions viewed in the slideover panel

### Issue 2: Edit Button Hidden
- The purple Edit button in the bottom-right footer was partially or fully obscured
- ChaSen floating AI icon overlapped the button area
- Users couldn't easily access the edit functionality

## Root Cause

### Issue 1: Status Value Mismatch
The `statusOptions` array in `ActivityDetailSlideOver.tsx` used different values than the actual Action status values:

**Dropdown options used:**
```javascript
{ value: 'not_started', label: 'Not Started' }
{ value: 'in_progress', label: 'In Progress' }  // Note: underscore
{ value: 'blocked', label: 'Blocked' }
{ value: 'completed', label: 'Completed' }
```

**Actual Action status values:**
```typescript
status: 'open' | 'in-progress' | 'completed' | 'cancelled'
```

When `item.status` was `'open'` or `'in-progress'` (with hyphen), the EnhancedSelect couldn't find a matching option, resulting in an empty display.

### Issue 2: No Footer Padding
The footer had `px-6` padding on both sides, but the ChaSen floating icon is positioned at `bottom-6 right-6`, causing overlap with the Edit button.

## Fix Applied

### Fix 1: Aligned Status Options
```typescript
// Before
const statusOptions = [
  { value: 'not_started', label: 'Not Started' },
  { value: 'in_progress', label: 'In Progress' },
  { value: 'blocked', label: 'Blocked' },
  { value: 'completed', label: 'Completed' },
]

// After - matching Action status values
const statusOptions = [
  { value: 'open', label: 'Not Started' },
  { value: 'in-progress', label: 'In Progress' },
  { value: 'completed', label: 'Completed' },
  { value: 'cancelled', label: 'Cancelled' },
]
```

Also updated:
- `getStatusColour()` function to handle correct status values
- Default value from `'not_started'` to `'open'`

### Fix 2: Added Right Padding
```tsx
// Before
<div className="px-6 py-4 border-t ...">

// After - extra right padding to clear floating icon
<div className="px-6 pr-24 py-4 border-t ...">
```

## Files Modified

| File | Changes |
|------|---------|
| `src/components/ActivityDetailSlideOver.tsx` | Updated statusOptions, getStatusColour, default value, and footer padding |

## Data Linkage Verification

Verified that action data is properly linked across tables:
- `actions.meeting_id` → `unified_meetings.meeting_id` (meeting association)
- `actions.client` / `actions.client_uuid` → client identification
- `actions.Status` field stores values: Open, In Progress, Completed, Cancelled
- `LegacyAction.status` (lowercase) stores: open, in-progress, completed, cancelled

The `useActions` hook properly converts database Status to lowercase with hyphens.

## Prevention

- When creating dropdown options for database-backed fields, always verify the exact values used in the database and TypeScript types
- Test status changes roundtrip (view → change → save → reload → verify)
- Consider using shared constants for status values across components
