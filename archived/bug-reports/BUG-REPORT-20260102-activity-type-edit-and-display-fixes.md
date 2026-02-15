# Bug Report: Activity Type Dropdown and Display Fixes

**Date:** 2026-01-02
**Severity:** Medium
**Status:** Fixed

## Summary

Two related issues with Activity Type handling:
1. The Activity Type dropdown in EditActionModal showed "Select activity type..." (empty) even when the action had an activity type set
2. The ActivityDetailSlideOver displayed raw codes like `HEALTH_CHECK` instead of friendly names like "Health Check"

## Issue 1: EditActionModal Dropdown Not Pre-Selecting

### Symptoms
- Slideover shows Activity Type as `HEALTH_CHECK`
- Click Edit button
- Modal opens with Activity Type dropdown showing "Select activity type..." (empty)
- User had to manually re-select the activity type to save without losing the value

### Root Cause

**Malformed JavaScript syntax in getInitialFormData function**

The previous edit to fix a React state race condition left malformed code with:
1. Inconsistent indentation within the function
2. A stray `)` after the return object's closing brace

The code structure was:
```typescript
const getInitialFormData = () => {
  return {
    title: action.title,
    // ...object with mixed indentation...
    activityTypeCode: action.activityTypeCode || '',
  })  // <-- Stray ) here caused issues
```

This caused the function to not properly initialise form data, resulting in empty values.

### Fix Applied

Fixed the function syntax to use proper arrow function with implicit return:
```typescript
const getInitialFormData = () => ({
  title: action.title,
  description: stripHtml(action.description),
  clients: action.client
    ? action.client.split(',').map(c => c.trim()).filter(Boolean)
    : [],
  owners: normalizeOwnersToArray(action.owners),
  // ... consistently indented properties ...
  activityTypeCode: action.activityTypeCode || '',
  crossFunctional: action.crossFunctional || false,
  impactedClientIds: [] as number[],
  impactArea: '',
  impactDescription: '',
})
```

## Issue 2: Slideover Displaying Raw Activity Type Codes

### Symptoms
- Slideover displays `HEALTH_CHECK` or `SUPPORT` instead of "Health Check" or "Support"
- Raw database codes shown to users instead of human-readable names

### Root Cause

The ActivityDetailSlideOver component was directly rendering `actionData.activityTypeCode` without looking up the friendly name from the activity_types reference table.

```typescript
// Before - displays raw code
{actionData.activityTypeCode}
```

### Fix Applied

Added the `useActivityTypes` hook to look up the friendly name:

```typescript
import { useActivityTypes } from '@/hooks/useActivityTypes'

// Inside component:
const { activityTypes } = useActivityTypes()

// Helper to get friendly activity type name from code
const getActivityTypeName = useCallback(
  (code: string) => {
    const activityType = activityTypes.find(at => at.code === code)
    return activityType?.name || code.replace(/_/g, ' ')
  },
  [activityTypes]
)

// Usage:
{getActivityTypeName(actionData.activityTypeCode)}
```

The helper function:
1. Looks up the activity type by code in the fetched list
2. Returns the friendly name if found
3. Falls back to formatting the code (replacing underscores with spaces) if not found

## Files Modified

| File | Changes |
|------|---------|
| `src/components/EditActionModal.tsx` | Fixed `getInitialFormData()` function syntax and indentation |
| `src/components/ActivityDetailSlideOver.tsx` | Added `useActivityTypes` hook and `getActivityTypeName` helper to display friendly names |

## Verification

After the fix:
1. EditActionModal Activity Type dropdown correctly displays the selected value when opening the Edit modal
2. ActivityDetailSlideOver displays friendly activity type names like "Health Check" instead of raw codes

## Prevention

- When editing arrow functions with implicit returns `() => ({})`, ensure the syntax remains valid
- Use consistent indentation throughout object literals
- Always format database codes for user-facing displays by looking up reference data or applying formatting rules

## Related

- Previous bug report: `BUG-REPORT-20260102-activity-type-dropdown-not-populated.md` documented the React state race condition (which was correctly identified but the fix was incomplete)
- Department field in the same slideover uses `.replace(/_/g, ' ')` for formatting - consistent approach now applied to Activity Type
