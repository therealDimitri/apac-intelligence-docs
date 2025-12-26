# Bug Fix: Action Edits Not Persisting

**Date**: 2025-12-23
**Type**: Bug Fix
**Status**: RESOLVED

---

## Problem Description

When editing actions through the `ActionDetailModal` (the inline edit view), changes were not being saved to the database. The user would click "Save Changes" but the action would revert to its original values.

## Root Cause

The `ActionDetailModal` component was using the `updateAction` function from `useActions.ts` which makes direct client-side Supabase calls. These calls were likely being blocked by Row Level Security (RLS) policies on the `actions` table.

Meanwhile, the separate `EditActionModal` component was working correctly because it uses the API route (`/api/actions/[id]`) which bypasses RLS via the service role key.

### Code Before (Not Working)

```typescript
// ActionDetailModal.tsx - handleSaveChanges
import { Action, updateAction } from '@/hooks/useActions'

const handleSaveChanges = async () => {
  setSaving(true)
  try {
    await updateAction(action.id, {
      title: editTitle,
      client: editClient,
      // ...
    })
    // Update would silently fail due to RLS
  }
}
```

The `updateAction` function in `useActions.ts` uses the client Supabase instance:

```typescript
const { error, data } = await supabase // Client instance - subject to RLS
  .from('actions')
  .update(dbUpdates)
  .eq('Action_ID', actionId)
```

## Solution

Updated `ActionDetailModal` to use the API route (`/api/actions/[id]`) instead of direct Supabase calls, matching the approach used by `EditActionModal`.

### Code After (Working)

```typescript
// ActionDetailModal.tsx - handleSaveChanges
import { Action } from '@/hooks/useActions'
import { cache } from '@/lib/cache'

const handleSaveChanges = async () => {
  setSaving(true)
  try {
    // Use API route to update action (bypasses RLS via service role)
    const response = await fetch(`/api/actions/${action.id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        Action_Description: editTitle,
        // ... database column format
      })
    })

    if (!response.ok) {
      const errorData = await response.json()
      throw new Error(errorData.error || 'Failed to update action')
    }

    // Clear cache to force refresh
    cache.delete('actions')
    toast.success('Action updated successfully')
  }
}
```

## Files Modified

1. **`src/components/ActionDetailModal.tsx`**
   - Changed import from `{ Action, updateAction }` to `{ Action }`
   - Added import for `cache` from `@/lib/cache`
   - Updated `handleSaveChanges` function to use API route instead of `updateAction`
   - Updated `updateOwnerStatus` function to use API route for status changes
   - Added proper date format conversion (YYYY-MM-DD → DD/MM/YYYY)
   - Added proper status normalisation for database format

## Technical Details

### Date Format Conversion

The HTML date input uses `YYYY-MM-DD` format, but the database stores dates in `DD/MM/YYYY` format:

```typescript
let dbDueDate = editDueDate
if (editDueDate && editDueDate.includes('-')) {
  const [year, month, day] = editDueDate.split('-')
  dbDueDate = `${day}/${month}/${year}`
}
```

### Status Normalisation

The frontend uses lowercase status values, but the database uses capitalised format:

```typescript
const statusMap: Record<string, string> = {
  open: 'Open',
  'in-progress': 'In Progress',
  completed: 'Completed',
  cancelled: 'Cancelled',
}
```

## Testing

1. Open any action via the ActionDetailModal
2. Click the edit (pencil) icon to enter edit mode
3. Make changes to any field (title, status, priority, etc.)
4. Click "Save Changes"
5. Close and reopen the modal - changes should persist
6. Verify in the database that the changes were saved

## Related Components

- `EditActionModal.tsx` - Full edit modal (already using API route - working)
- `ActionDetailModal.tsx` - Quick view modal with inline editing (fixed)
- `useActions.ts` - Contains `updateAction` function (client-side, subject to RLS)
- `/api/actions/[id]/route.ts` - API route using service role (bypasses RLS)

## Notes

- The `updateAction` function in `useActions.ts` is still available but should be avoided for operations that may be blocked by RLS
- For reliable database updates, always use the API routes which have service role access
- Cache clearing (`cache.delete('actions')`) is essential to ensure the UI reflects the updated data
