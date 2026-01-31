# Bug Report: ChaSen Action Context Not Persisting

**Date:** 26 December 2025
**Status:** Fixed
**Commit:** e8e5b62

## Summary

ChaSen AI-generated context for actions linked to meetings was not persisting to the database, causing the context to not display when re-opening an action.

## Symptoms

1. User generates ChaSen context for an action from a meeting
2. Context displays correctly after generation
3. User closes the action modal
4. User re-opens the action modal
5. Context does not display - shows "Generate Context" button instead

Console errors observed:
- Nested button HTML validation warning
- ActionId showing as "ACT-1766021645597-TX0H1" (string) instead of numeric ID

## Root Cause

**Two issues identified:**

### Issue 1: Wrong ID Type
The `Action` interface in `useActions.ts` had an `id` field that mapped to `Action_ID` (a string like "ACT-xxx"), not the database primary key `id` (an integer).

When passing `action.id` to the `ActionMeetingContext` component, it was sending the string Action_ID. The API endpoint used `parseInt()` on this value, which converted "ACT-xxx" to `NaN`, causing the database query to fail silently.

### Issue 2: Nested Button HTML Error
The collapsible header in `ActionMeetingContext.tsx` used a `<button>` element containing another `<button>` for the regenerate action. This is invalid HTML and caused React hydration warnings.

## Fix Applied

### 1. Added `numericId` to Action interface (`src/hooks/useActions.ts`)
```typescript
export interface Action {
  id: string
  numericId: number // Database primary key (integer) - used for API calls
  // ...
}
```

### 2. Fetched `id` column from database
Added `id` to the select query:
```typescript
.select(`
  id,
  Action_ID,
  // ...
`)
```

### 3. Mapped numeric ID in data processing
```typescript
return {
  id: action.Action_ID || `action-${Date.now()}-${Math.random()}`,
  numericId: action.id, // Database primary key (integer)
  // ...
}
```

### 4. Updated ActionMeetingContext prop type
Changed from `actionId: string` to `actionId: number`

### 5. Updated ActionDetailModal
Changed from `actionId={action.id}` to `actionId={action.numericId}`

### 6. Fixed nested button
Changed outer `<button>` to `<div role="button">` with proper accessibility attributes

## Files Changed

1. `src/hooks/useActions.ts` - Added numericId field and mapping
2. `src/components/ActionMeetingContext.tsx` - Changed prop type, fixed nested button
3. `src/components/ActionDetailModal.tsx` - Pass numericId instead of id

## Testing

1. Open an action that was created from a meeting
2. Generate ChaSen context
3. Close the modal
4. Re-open the modal
5. **Expected:** Context displays with "ChaSen AI Context" header and saved data
6. **Actual (after fix):** Context displays correctly

## Prevention

- Always verify ID types when passing between components and API endpoints
- Database integer IDs (`id`) should be kept separate from business identifiers (`Action_ID`)
- Use TypeScript strictly to catch type mismatches
- Avoid nesting interactive elements (buttons inside buttons)
