# Bug Report: PeopleSearchInput Auth Error Logging

**Date:** 30 December 2025
**Type:** Bug Fix
**Status:** Resolved
**Commit:** 07bc094

## Issue

Console was showing "Search failed" error messages when users weren't authenticated with Microsoft Graph API.

## Error Message

```
Search failed
at PeopleSearchInput.useCallback[searchUsers]
```

## Root Cause

The `PeopleSearchInput` component was throwing and logging errors for 401 (Unauthorised) and 403 (Forbidden) responses from the `/api/organization/people` endpoint. These are expected responses when users haven't signed in with Microsoft.

## Solution

Updated error handling in `searchUsers` callback to:
1. Silently handle 401/403 responses without throwing errors
2. Clear search results and return early for auth failures
3. Only log unexpected errors to console

## Code Changes

**File:** `src/components/PeopleSearchInput.tsx`

```typescript
// Before
if (!response.ok) {
  throw new Error(`Search failed: ${response.status}`)
}

// After
if (!response.ok) {
  // Silently handle auth errors - user just needs to sign in
  if (response.status === 401 || response.status === 403) {
    setSearchResults([])
    return
  }
  throw new Error(`Search failed: ${response.status}`)
}

// Also updated catch block to filter auth-related errors from logging
catch (err) {
  if (err instanceof Error && !err.message.includes('401') && !err.message.includes('403')) {
    console.error('User search failed:', err)
  }
  setSearchResults([])
}
```

## Testing

1. Open Create Action or Edit Action modal
2. Click on Owners field and type to search
3. If not authenticated with MS Graph:
   - No console errors should appear
   - Search results should be empty
4. If authenticated:
   - Search should work normally
   - Results from organisation should appear

## Impact

- Eliminates console noise for unauthenticated users
- No functional impact - search still works when authenticated
- Better user experience with cleaner console output
