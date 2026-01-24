# Bug Report: @Mention Autocomplete Not Working in Comments

**Date:** 2026-01-24
**Severity:** Medium (Feature Broken)
**Status:** Resolved

## Summary

Typing "@" followed by a name in comment fields did not trigger the user mention autocomplete dropdown. The TipTap rich text editor's mention extension was failing silently.

## Root Cause

The `/api/cse-profiles` endpoint was not included in the `publicPaths` list in `src/proxy.ts`. This meant the authentication middleware was intercepting requests to this endpoint and returning a 307 redirect to the signin page instead of allowing the request through to the API handler.

When the `MentionSuggestion.tsx` component's `fetchTeamMembers()` function made a fetch request to `/api/cse-profiles`, it received a redirect response instead of the CSE profile data, causing the mention dropdown to fail silently.

### Error Symptoms
- Typing "@lau" in a comment field showed no dropdown
- No visible error in the UI
- API endpoint returning 307 redirect:
  ```
  HTTP/1.1 307 Temporary Redirect
  location: /auth/dev-signin?callbackUrl=%2Fapi%2Fcse-profiles
  ```

## Solution

Added `/api/cse-profiles` to the `publicPaths` array in `src/proxy.ts` to allow unauthenticated access to this endpoint. This is safe because:
1. The endpoint already uses the service role key internally
2. It only returns non-sensitive data (CSE names, photos, roles) for mention autocomplete
3. This follows the same pattern as other public API endpoints in the codebase

## Files Modified

### 1. `src/proxy.ts` (MODIFIED)
Added `/api/cse-profiles` to the `publicPaths` array:
```typescript
const publicPaths = [
  // ... existing paths ...
  '/api/priority-matrix', // Priority matrix assignments - uses service role for cross-device sync
  '/api/cse-profiles', // CSE profiles for @mention autocomplete (uses service role)
  '/logos', // Static client logo files
  // ...
]
```

### 2. `scripts/sync-aged-accounts.ts` (MODIFIED)
Fixed a pre-existing TypeScript error unrelated to this bug (ASI issue with Object.entries type assertion).

## Testing Performed

- [x] Build passes without TypeScript errors
- [x] `/api/cse-profiles` endpoint returns 200 with profile data
- [x] Typing "@lau" in comment field shows dropdown with "Laura Messing"
- [x] Mention dropdown displays profile photos and roles correctly

## Technical Details

The TipTap mention extension uses `MentionSuggestion.tsx` which:
1. Listens for "@" character input
2. Fetches CSE profiles from `/api/cse-profiles`
3. Filters results based on the query string
4. Renders a Tippy.js dropdown with matching team members

The API endpoint (`/api/cse-profiles/route.ts`) already used the service role key to bypass RLS, but the middleware was blocking the request before it could reach the handler.

## Related Files

- `src/components/comments/MentionSuggestion.tsx` - Mention suggestion configuration
- `src/components/comments/RichTextEditor.tsx` - TipTap editor with mention extension
- `src/app/api/cse-profiles/route.ts` - API endpoint (already correctly implemented)
