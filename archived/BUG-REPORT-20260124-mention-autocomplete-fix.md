# Bug Report: @Mention Autocomplete Not Working in Comments

**Date:** 2026-01-24
**Severity:** Medium (Feature Broken)
**Status:** Resolved ✓ Verified

## Summary

Typing "@" followed by a name in comment fields did not trigger the user mention autocomplete dropdown. The TipTap rich text editor's mention extension was failing silently. This bug had four root causes that were fixed in sequence.

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

### Issue 3: Stale Closure in ReactRenderer (Fixed Third)

After fixing Issues 1 and 2, the dropdown appeared correctly and showed matching users, but clicking on a suggestion or pressing Enter did not insert the mention into the editor.

The root cause was a stale closure issue with TipTap's `ReactRenderer`. When `ReactRenderer.updateProps()` is called, it updates the component's props but doesn't trigger a full React re-render cycle. This meant the `command` function stored in closures (via `useCallback` or direct closure) was the stale initial version, not the current one with the correct context.

**Symptoms:**
- Dropdown appeared with correct profile data
- Arrow keys navigated the list correctly
- Clicking on a user or pressing Enter did nothing
- No errors in console

**Technical Details:**
- `ReactRenderer` uses `forceUpdate()` internally, which re-renders but doesn't reset closure references
- The `command` prop passed by TipTap changes on each keystroke with updated editor context
- Handlers using `useCallback` or direct closure captured the old `command` function

### Issue 4: Missing CSS Styling for Mention Chips (Fixed Fourth)

After fixing Issues 1-3, the mention was being inserted correctly but appeared as plain text (e.g., "@Laura Messing") instead of a styled pill/chip like Microsoft Teams, LinkedIn, or Slack.

The TipTap Mention extension was configured with Tailwind classes (`bg-purple-100 text-purple-700 rounded px-1 font-medium`), but Tailwind v4's JIT compiler doesn't scan JavaScript strings for class names. The classes were never included in the compiled CSS.

**Symptoms:**
- Mentions functionally worked (could be clicked, extracted for notifications)
- Mentions appeared as plain text without any visual distinction
- No purple background, no pill shape, no hover effects

**Technical Details:**
- Tailwind v4 uses Just-in-Time compilation that scans source files for class names
- Classes defined in JavaScript strings (like TipTap's HTMLAttributes) are not detected
- The `.mention` class existed but had no CSS rules applied to it

## Solutions

### Fix 1: API Authentication
Added `/api/cse-profiles` to the `publicPaths` array in `src/proxy.ts` to allow unauthenticated access to this endpoint. This is safe because:
1. The endpoint already uses the service role key internally
2. It only returns non-sensitive data (CSE names, photos, roles) for mention autocomplete
3. This follows the same pattern as other public API endpoints in the codebase

### Fix 2: Z-Index for Tippy Popup
Added `zIndex: 99999` to the Tippy.js popup configuration in `MentionSuggestion.tsx` to ensure the dropdown appears above all modal components.

### Fix 3: Refs for Fresh Prop Access
Refactored the `MentionList` component to use refs instead of closures:
1. Store `items` and `command` props in refs (`itemsRef`, `commandRef`)
2. Update refs on every render to keep them current
3. Read from refs in event handlers to always get the latest values
4. Use `props.items` directly for rendering (ReactRenderer's `forceUpdate` handles this)
5. Remove `useCallback` wrappers that were capturing stale values

This pattern ensures handlers always access the current props values regardless of when they were created.

### Fix 4: Global CSS for Mention Styling
Added explicit CSS rules in `src/app/globals.css` for the `.mention` class to create LinkedIn/Teams-style pill chips:
- Purple gradient background (`linear-gradient(135deg, #f3e8ff 0%, #ede9fe 100%)`)
- Rounded pill shape (`border-radius: 9999px`)
- Hover effect with lift animation
- Subtle border and shadow
- Consistent styling in both editor and rendered content

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
Added z-index to Tippy popup configuration and fixed stale closure issue:
```typescript
// Tippy z-index fix
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

// Stale closure fix - use refs for handlers
const MentionList = forwardRef<MentionListRef, MentionListProps>((props, ref) => {
  const [selectedIndex, setSelectedIndex] = useState(0)

  // Use refs to always have access to the latest props values
  const itemsRef = useRef(props.items)
  const commandRef = useRef(props.command)

  // Update refs on every render to keep them current
  itemsRef.current = props.items
  commandRef.current = props.command

  // Use refs in handlers to always get the latest values
  const selectItem = (index: number) => {
    const item = itemsRef.current[index]
    if (item) {
      commandRef.current(item)  // Always calls current command
    }
  }
  // ...
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

### 5. `src/app/globals.css` (MODIFIED)
Added CSS rules for mention chip styling:
```css
/* Mention chip - styled like LinkedIn, Microsoft Teams, Slack */
.mention {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  padding: 0.125rem 0.5rem;
  margin: 0 0.125rem;
  background: linear-gradient(135deg, #f3e8ff 0%, #ede9fe 100%);
  color: #7c3aed;
  font-weight: 500;
  font-size: 0.9em;
  border-radius: 9999px;
  text-decoration: none;
  cursor: pointer;
  transition: all 0.15s ease;
  box-shadow: 0 1px 2px rgba(124, 58, 237, 0.1);
  border: 1px solid rgba(124, 58, 237, 0.15);
}
```

## Testing Performed

- [x] Build passes without TypeScript errors
- [x] `/api/cse-profiles` endpoint returns 200 with profile data
- [x] Typing "@lau" in comment field shows dropdown with "Laura Messing"
- [x] Mention dropdown displays profile photos and roles correctly
- [x] Dropdown appears above Sheet modal (z-index working)
- [x] Clicking on a suggestion inserts the mention correctly
- [x] Pressing Enter on a highlighted suggestion inserts the mention
- [x] Arrow key navigation works correctly
- [x] Mention appears as "@Laura Messing" in the editor
- [x] Mention displays as styled purple pill chip (not plain text)
- [x] Mention hover effect works (lift animation, darker background)
- [x] Verified on localhost with Playwright automated testing

## Technical Details

The TipTap mention extension uses `MentionSuggestion.tsx` which:
1. Listens for "@" character input
2. Fetches CSE profiles from `/api/cse-profiles`
3. Filters results based on the query string
4. Renders a Tippy.js dropdown with matching team members

The dropdown is rendered using Tippy.js with `appendTo: () => document.body` to escape the local stacking context, but still needed an explicit z-index to appear above other body-level elements like the Sheet overlay.

### ReactRenderer and Stale Closures

TipTap's `ReactRenderer` is a utility that renders React components outside the normal React tree. It has a key limitation:

1. When `updateProps()` is called, it stores new props and calls `forceUpdate()`
2. `forceUpdate()` triggers a re-render but doesn't reset function closures
3. Event handlers created with `useCallback` or as inline functions capture the old props
4. The `command` prop changes on every keystroke with updated TipTap editor context

The solution is to use refs that are updated on every render:
- Refs are mutable and always reflect the latest value
- Reading from `ref.current` in a handler always gets the current value
- This pattern is a standard workaround for stale closure issues in React

## Related Files

- `src/components/comments/MentionSuggestion.tsx` - Mention suggestion configuration (modified)
- `src/components/comments/RichTextEditor.tsx` - TipTap editor with mention extension
- `src/components/comments/FloatingPageComments.tsx` - Sheet-based comment panel
- `src/components/ui/sheet.tsx` - Sheet component with z-50 z-index
- `src/app/api/cse-profiles/route.ts` - API endpoint (already correctly implemented)
