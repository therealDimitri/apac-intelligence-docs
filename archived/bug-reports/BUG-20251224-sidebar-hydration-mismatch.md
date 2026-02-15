# Bug Report: Sidebar User Initials Hydration Mismatch

**Date:** 24 December 2025
**Status:** Fixed
**Severity:** Low (Recoverable)
**Component:** Layout > Sidebar

---

## Problem Description

React hydration error in the Sidebar component when rendering user initials. The server rendered "U" (default) but the client rendered "DL" (actual user initials), causing a hydration mismatch warning.

### Error Message

```
Hydration failed because the server rendered text didn't match the client.
+  DL
-  U
```

---

## Root Cause Analysis

The user session data (`useSession()`) is not available during server-side rendering (SSR), so the component defaults to "User" on the server. Once the client hydrates and the session loads, the actual user name ("Dimitri Leimonitis") is available, causing the initials to change from "U" to "DL".

### Affected Code (Before Fix)

**src/components/layout/sidebar.tsx:**

```tsx
// On server: session is null, rawUserName = 'User'
// On client: session has data, rawUserName = 'Leimonitis, Dimitri'
const rawUserName = session?.user?.name || 'User'

// Initials differ between server ('U') and client ('DL')
const userInitials = userName
  .split(' ')
  .map(n => n[0])
  .join('')
  .toUpperCase()
  .slice(0, 2)
```

---

## Solution Implemented

Added `suppressHydrationWarning` attribute to the elements displaying user-specific content. This is React's recommended approach for content that intentionally differs between server and client (like user session data).

### Changes Made

```tsx
<div
  className="h-8 w-8 rounded-full bg-purple-500 ..."
  style={{ display: userImage ? 'none' : 'flex' }}
  suppressHydrationWarning
>
  {userInitials}
</div>

<p className="text-sm font-medium text-white" suppressHydrationWarning>
  {userName}
</p>
```

---

## Files Changed

| File                                | Changes                                                                       |
| ----------------------------------- | ----------------------------------------------------------------------------- |
| `src/components/layout/sidebar.tsx` | Added `suppressHydrationWarning` to user initials div and user name paragraph |

---

## Why suppressHydrationWarning?

This is the correct solution because:

1. User session data is inherently client-side (unavailable during SSR)
2. The mismatch is expected and harmless
3. React will still update to the correct value on client
4. Alternative approaches (mounted state) are blocked by ESLint rules

---

## Testing Steps

1. Start dev server: `npm run dev`
2. Open browser DevTools console
3. Navigate to any dashboard page
4. Verify no hydration mismatch errors in console
5. Verify user initials display correctly in sidebar

---

## Related Documentation

- [React Hydration Mismatch](https://react.dev/link/hydration-mismatch)
- [suppressHydrationWarning](https://react.dev/reference/react-dom/client/hydrateRoot#suppressing-unavoidable-hydration-mismatch-errors)
