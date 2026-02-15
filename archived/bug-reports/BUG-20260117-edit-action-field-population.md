# Bug Report: Edit Action Fields Not Populating Correctly

**Date**: 17 January 2026
**Severity**: Medium
**Status**: Fixed
**Affected Areas**: Account Plan wizard - Actions step (ActionNarrativeStep)

---

## Summary

When clicking the Edit button on an action in the Account Plan Actions step, the edit form fields were not being populated with the existing action data. Fields like Action Description, Client, and Priority showed empty or default values instead of the actual data.

---

## Root Causes

### 1. Legacy Field Names Not Handled
**File**: `src/app/(dashboard)/planning/strategic/new/steps/ActionNarrativeStep.tsx`
**Function**: `startEditAction`

Actions stored in the database may have different field names depending on when/how they were created:

| Expected Field | Legacy Alternatives |
|----------------|---------------------|
| `action` | `description`, `title` |
| `client` | `clientName`, `client_name` |
| `status` | `pending` (should be `not_started`) |

The `startEditAction` function was doing a simple spread (`{...action}`) without normalising these field names.

### 2. Due Date Format Issues
**File**: `src/app/(dashboard)/planning/strategic/new/steps/ActionNarrativeStep.tsx`

Dates stored with ISO timestamp format (e.g., `2026-01-26T00:00:00.000Z`) were not being converted to the `YYYY-MM-DD` format required by HTML date inputs.

### 3. Display Mode Also Affected
The client name in the action row display only checked `action.client`, missing data stored in legacy field names.

---

## Solution

### Updated `startEditAction` Function
```typescript
const startEditAction = useCallback((action: Action) => {
  const legacyAction = action as Action & {
    description?: string
    title?: string
    clientName?: string
    client_name?: string
  }
  const rawStatus = action.status as string

  setEditingActionId(action.id)
  setEditingAction({
    ...action,
    // Ensure action field is populated (handle legacy fields)
    action: action.action || legacyAction.description || legacyAction.title || '',
    // Ensure client is populated (handle various field names)
    client: action.client || legacyAction.clientName || legacyAction.client_name || '',
    // Normalize status (handle legacy 'pending' → 'not_started')
    status: rawStatus === 'pending' ? 'not_started' : action.status,
    // Ensure priority is set
    priority: action.priority || 'medium',
    // Ensure owner is set
    owner: action.owner || ownerName || '',
    // Ensure dueDate is properly formatted for input (YYYY-MM-DD)
    dueDate: action.dueDate
      ? (action.dueDate.includes('T') ? action.dueDate.split('T')[0] : action.dueDate)
      : '',
  })
}, [ownerName])
```

### Updated Display Mode
```typescript
const legacyData = action as Action & {
  description?: string
  title?: string
  clientName?: string
  client_name?: string
}
const actionText = action.action || legacyData.description || legacyData.title || 'No description'
const clientName = action.client || legacyData.clientName || legacyData.client_name || ''
```

---

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/planning/strategic/new/steps/ActionNarrativeStep.tsx` | Added legacy field name handling in `startEditAction` and display mode |

---

## Verification Steps

1. Navigate to Planning Hub
2. Open an existing Account Plan
3. Go to the Actions step
4. Click the Edit button on any action
5. Verify:
   - Action Description is populated correctly
   - Client dropdown shows the correct client selected
   - Priority dropdown shows the correct priority
   - Due Date shows the correct date
   - Status dropdown shows the correct status
   - Owner(s) field shows the correct owner(s)

---

## Related Commits

- `93d1b3a9` - Fix edit action field population and add edit functionality

---

## Prevention

To prevent similar issues:
1. Use TypeScript strict mode and define explicit interfaces for all data structures
2. When reading data from database, normalise field names at the API level
3. Add data migration scripts when changing field names
4. Add unit tests for form population with various data formats
