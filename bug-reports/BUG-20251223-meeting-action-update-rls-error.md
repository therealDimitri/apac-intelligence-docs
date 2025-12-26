# Bug Report: Meeting and Action Update/Delete Fails Due to RLS Policies

**Date:** 23 December 2025
**Status:** Fixed
**Severity:** High
**Component:** Client Profile > Timeline, useMeetings, useActions

> **Update:** Also fixed meeting deletion not removing items from timeline - was using status update instead of proper delete endpoint.

---

## Problem Description

Update and delete operations for meetings and actions in the Client Profile timeline failed silently. The console showed:

```
Failed to update meeting:
Object

Failed to delete:
Object
```

The empty object error indicates RLS (Row-Level Security) policies were blocking the operations.

---

## Root Cause Analysis

Both `useMeetings.ts` and `useActions.ts` were using the **client-side Supabase instance** to perform update operations. This instance uses the anonymous key which is subject to RLS policies that block updates.

### Affected Code (Before Fix)

**useMeetings.ts - updateMeeting:**

```tsx
const { error, data } = await supabase // Client-side instance
  .from('unified_meetings')
  .update(dbUpdates)
  .eq('meeting_id', meetingId)
  .select()
  .single()
```

**useActions.ts - updateAction:**

```tsx
const { error, data } = await supabase // Client-side instance
  .from('actions')
  .update(dbUpdates)
  .eq('Action_ID', actionId)
  .select()
  .single()
```

### API Endpoints Already Existed

Both tables already had API endpoints that use the **service role key** to bypass RLS:

- `PATCH /api/meetings/[id]` - for meeting updates
- `PATCH /api/actions/[id]` - for action updates

The hooks simply weren't using them.

---

## Solution Implemented

Updated both `updateMeeting` and `updateAction` functions to call their respective API endpoints instead of using the client-side Supabase instance directly.

### useMeetings.ts - updateMeeting (After Fix)

```tsx
// Use API endpoint which has service role key (bypasses RLS)
const response = await fetch(`/api/meetings/${meetingId}`, {
  method: 'PATCH',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(dbUpdates),
})

const result = await response.json()

if (!response.ok || result.error) {
  throw new Error(result.error || 'Failed to update meeting')
}
```

### useActions.ts - updateAction (After Fix)

```tsx
// Use API endpoint which has service role key (bypasses RLS)
const response = await fetch(`/api/actions/${actionId}`, {
  method: 'PATCH',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(dbUpdates),
})

const result = await response.json()

if (!response.ok || result.error) {
  throw new Error(result.error || 'Failed to update action')
}
```

---

## Files Changed

| File                                                                    | Changes                                                                                                             |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `src/hooks/useMeetings.ts`                                              | Changed `updateMeeting` to use `/api/meetings/[id]` PATCH endpoint                                                  |
| `src/hooks/useActions.ts`                                               | Changed `updateAction` to use `/api/actions/[id]` PATCH endpoint                                                    |
| `src/app/(dashboard)/clients/[clientId]/components/v2/CenterColumn.tsx` | Changed meeting delete to use `/api/meetings/delete` endpoint (sets `deleted=true` instead of `status='cancelled'`) |

---

## Architecture Pattern

This fix follows the same pattern used throughout the codebase:

1. **Client-side hooks** (`useMeetings`, `useActions`, etc.) - Use anonymous Supabase key for READ operations (subject to RLS)
2. **API endpoints** (`/api/meetings/[id]`, `/api/actions/[id]`, etc.) - Use service role key for WRITE operations (bypasses RLS)

### Why This Pattern?

- RLS policies are designed to restrict anonymous/user access for security
- Server-side API routes can safely use the service role key (never exposed to browser)
- This provides secure write operations while maintaining RLS protection

---

## Testing Steps

1. Navigate to Client Profile
2. Change the status of a meeting using the dropdown (e.g., scheduled → completed)
3. Verify status updates successfully (no console errors)
4. Change the status of an action using the dropdown
5. Verify status updates successfully
6. Delete a meeting or action from the timeline
7. Verify deletion works (item removed, no console errors)

---

## Related Bugs

- `BUG-20251223-add-note-rls-error.md` - Same pattern issue with AddNoteModal
- `BUG-20251223-unified-notes-and-mentions.md` - Comprehensive notes system fixes
