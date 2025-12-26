# Bug Fix: Action Owner Name with Comma Being Incorrectly Split

## Issue Summary

**Date:** 2025-12-23
**Severity:** Medium
**Status:** Fixed

## Problem Description

When adding or editing an action owner from the Briefing Room or Actions page, owner names containing commas (e.g., "Leimonitis, Dimitri" in "Last, First" format) were being incorrectly split into multiple separate owners.

### Root Cause

The codebase was using comma (`,`) as the delimiter for separating multiple owners. However, Azure AD and many enterprise systems use "Last, First" name format, which contains a comma within a single name.

### Example of the Bug

- Input: Owner "Leimonitis, Dimitri"
- Expected: Single owner "Leimonitis, Dimitri"
- Actual (before fix): Two owners - "Leimonitis" and "Dimitri"

## Solution

Changed the owner delimiter from comma (`,`) to semicolon (`;`) across the entire codebase. This allows names with commas to be stored and parsed correctly while still supporting multiple owners.

### Backward Compatibility

The fix includes fallback logic: if no semicolon exists in the owner string, the entire string is treated as a single owner. This ensures existing data with single owners (stored without any delimiter) continues to work correctly.

## Files Modified

### Hooks

- `src/hooks/useActions.ts` - Owner parsing and saving logic
- `src/hooks/useOwnersDropdown.ts` - Owner dropdown population

### Components

- `src/components/EditActionModal.tsx` - Owner normalization helper
- `src/components/ActionDetailModal.tsx` - Owner save logic
- `src/components/CreateActionModal.tsx` - Owner save logic (2 locations)
- `src/components/MeetingDetailTabs.tsx` - Owner display parsing

### API Routes

- `src/app/api/assignment/route.ts` - Owner parsing and saving
- `src/app/api/actions/outlook/route.ts` - Owner parsing for Outlook sync
- `src/app/api/actions/teams/route.ts` - Owner parsing for Teams notifications
- `src/app/api/actions/reminders/route.ts` - Owner parsing (added helper function)
- `src/app/api/chasen/chat/route.ts` - Owner parsing for CSE analytics

### Pages

- `src/app/(dashboard)/actions/page.tsx` - Owner parsing for assignment modal (2 locations)

## Code Pattern Used

### Before (Incorrect)

```typescript
const owners = action.Owners?.split(',') || []
```

### After (Correct)

```typescript
const ownersString = action.Owners || ''
const owners = ownersString.includes(';')
  ? ownersString
      .split(';')
      .map((o: string) => o.trim())
      .filter(Boolean)
  : ownersString
    ? [ownersString.trim()].filter(Boolean)
    : []
```

### For Saving

```typescript
// Before
Owners: formData.owners.join(', ')

// After
Owners: formData.owners.join('; ')
```

## Testing

1. Build verified: `npm run build` - Success
2. TypeScript check: `npx tsc --noEmit` - No errors

## Notes

- The user name parsing for Azure AD login (converting "Last, First" to "First Last" for display) was NOT changed, as that is intentional comma parsing for a different purpose
- Any existing data with comma-separated multiple owners will need to be updated to use semicolons
- New entries will automatically use semicolons
