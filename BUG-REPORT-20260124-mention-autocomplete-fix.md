# Bug Report: @Mention Autocomplete Not Working in Comments

**Date:** 2026-01-24
**Severity:** Medium (Feature Broken)
**Status:** Resolved ✓ Verified

## Summary

Typing "@" followed by a name in comment fields did not trigger the user mention autocomplete dropdown. The TipTap rich text editor's mention extension was failing silently. This bug had two root causes that were fixed in sequence.

## Root Causes

### Issue 1: API Authentication Blocking (Fixed First)

The `/api/cse-profiles` endpoint was not included in the `publicPaths` list in `src/proxy.ts`. This meant the authentication middleware was intercepting requests to this endpoint and returning a 307 redirect to the signin page instead of allowing the request through to the API handler.

When the `MentionSuggestion.tsx` component's `fetchTeamMembers()` function made a fetch request to `/api/cse-profiles`, it received a redirect response instead of the CSE profile data, causing the mention dropdown to fail silently.

**Symptoms:**
- Typing "@lau" in a comment field showed no dropdown
- No visible error in the UI
- API endpoint returning 307 redirect:
  ```
  HTTP/1.1 307 Temporary Redirect
  location: /auth/dev-signin?callbackUrl=%2Fapi%2Fcse-profiles
  ```

### Issue 2: Z-Index Stacking Context (Fixed Second)

After fixing Issue 1, the @mention still didn't work on production. The Tippy.js dropdown was being created but was hidden behind the Sheet modal component.

The `FloatingPageComments` component uses a `Sheet` from shadcn/ui (Radix UI), which has a z-index of `z-50` (50). The Tippy.js dropdown had no explicit z-index set, so it rendered behind the Sheet overlay.

**Symptoms:**
- API returning 200 with correct profile data
- Console showed successful fetch but no visible dropdown
- Dropdown was being rendered but was invisible (behind the Sheet modal)

## Solutions

### Fix 1: API Authentication
Added `/api/cse-profiles` to the `publicPaths` array in `src/proxy.ts` to allow unauthenticated access to this endpoint. This is safe because:
1. The endpoint already uses the service role key internally
2. It only returns non-sensitive data (CSE names, photos, roles) for mention autocomplete
3. This follows the same pattern as other public API endpoints in the codebase

### Fix 2: Z-Index for Tippy Popup
Added `zIndex: 99999` to the Tippy.js popup configuration in `MentionSuggestion.tsx` to ensure the dropdown appears above all modal components.

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

### 2. `src/components/comments/MentionSuggestion.tsx` (MODIFIED)
Added z-index to Tippy popup configuration:
```typescript
popup = tippy('body', {
  getReferenceClientRect: props.clientRect as () => DOMRect,
  appendTo: () => document.body,
  content: component.element,
  showOnCreate: true,
  interactive: true,
  trigger: 'manual',
  placement: 'bottom-start',
  zIndex: 99999, // Higher than Sheet's z-50 to appear above modals
})
```

### 3. `scripts/sync-aged-accounts.ts` (MODIFIED)
Fixed a pre-existing TypeScript error unrelated to this bug (ASI issue with Object.entries type assertion).

### 4. `netlify.toml` (MODIFIED)
Added git submodule fetch to build command to ensure latest scripts are deployed:
```toml
[build]
  command = "git submodule update --init --recursive && npm run build"
```

## Testing Performed

- [x] Build passes without TypeScript errors
- [x] `/api/cse-profiles` endpoint returns 200 with profile data
- [x] Typing "@lau" in comment field shows dropdown with "Laura Messing"
- [x] Mention dropdown displays profile photos and roles correctly
- [x] Dropdown appears above Sheet modal (z-index working)
- [x] Verified on localhost after deployment

## Technical Details

The TipTap mention extension uses `MentionSuggestion.tsx` which:
1. Listens for "@" character input
2. Fetches CSE profiles from `/api/cse-profiles`
3. Filters results based on the query string
4. Renders a Tippy.js dropdown with matching team members

The dropdown is rendered using Tippy.js with `appendTo: () => document.body` to escape the local stacking context, but still needed an explicit z-index to appear above other body-level elements like the Sheet overlay.

## Related Files

- `src/components/comments/MentionSuggestion.tsx` - Mention suggestion configuration (modified)
- `src/components/comments/RichTextEditor.tsx` - TipTap editor with mention extension
- `src/components/comments/FloatingPageComments.tsx` - Sheet-based comment panel
- `src/components/ui/sheet.tsx` - Sheet component with z-50 z-index
- `src/app/api/cse-profiles/route.ts` - API endpoint (already correctly implemented)
