# Bug Report: Engagement Gaps Navigation Not Working

**Date**: 2025-12-22
**Severity**: Medium
**Status**: RESOLVED

---

## Issue Summary

Clicking on clients in the Engagement Gaps list did not navigate to the client profile page. Users expected to click on a client to view their full profile, but nothing happened.

## Symptoms

- Clicking on a client row in the Engagement Gaps component had no visible effect
- URL bar did not change
- Console showed no errors
- Navigation appeared to happen (URL changed to `/clients/Client%20Name`) but displayed "Client Not Found" error

## Root Cause

**URL Encoding Mismatch**

The `EngagementGapsList` component correctly navigated using URL-encoded client names:

```tsx
const handleClientClick = (clientName: string) => {
  const encodedClientName = encodeURIComponent(clientName)
  router.push(`/clients/${encodedClientName}`)
}
```

However, the client profile pages (`page.tsx` and `v2/page.tsx`) only matched clients by:

1. Exact ID match
2. Index-based fallback (for demo)

They did **not decode** the URL parameter before trying to match by client name.

For example:

- URL: `/clients/Grampians%20Health`
- `clientId` parameter: `Grampians%20Health` (still encoded)
- Client name in database: `Grampians Health`
- Match attempt: `"Grampians%20Health" === "Grampians Health"` → **false**

## Technical Details

### Before (Broken):

```tsx
// src/app/(dashboard)/clients/[clientId]/page.tsx
const client = useMemo(() => {
  if (clients.length === 0) return null

  // Try to find by exact ID match
  const foundClient = clients.find(c => c.id === clientId)
  if (foundClient) return foundClient

  // Fallback: if clientId is index-based (for demo)
  const index = parseInt(clientId)
  if (!isNaN(index) && index < clients.length) {
    return clients[index]
  }

  return null // Always returned null for encoded client names!
}, [clientId, clients])
```

### After (Fixed):

```tsx
// src/app/(dashboard)/clients/[clientId]/page.tsx
const client = useMemo(() => {
  if (clients.length === 0) return null

  // Try to find by exact ID match
  const foundClient = clients.find(c => c.id === clientId)
  if (foundClient) return foundClient

  // Try to find by client name (supports URLs with encoded client names)
  const decodedClientId = decodeURIComponent(clientId)
  const foundByName = clients.find(c => c.name.toLowerCase() === decodedClientId.toLowerCase())
  if (foundByName) return foundByName

  // Fallback: if clientId is index-based (for demo)
  const index = parseInt(clientId)
  if (!isNaN(index) && index < clients.length) {
    return clients[index]
  }

  return null
}, [clientId, clients])
```

## Files Modified

1. **`src/app/(dashboard)/clients/[clientId]/page.tsx`**
   - Added `decodeURIComponent` call before matching
   - Added case-insensitive name matching

2. **`src/app/(dashboard)/clients/[clientId]/v2/page.tsx`**
   - Added `decodeURIComponent` call before matching
   - Updated name matching to use decoded value

## Fix Applied

**Commit**: `86a6352`

Added URL-decoded client name matching to both v1 and v2 client profile pages. The matching now:

1. First tries exact ID match (for direct database ID links)
2. Decodes the URL parameter (`%20` → ` `)
3. Matches by client name (case-insensitive)
4. Falls back to index-based matching (legacy/demo support)

## Testing

- Click on any client in Engagement Gaps list → Navigates to client profile
- URL-encoded special characters handled correctly
- Case-insensitive matching works (e.g., "GRAMPIANS HEALTH" matches "Grampians Health")
- Existing ID-based navigation still works

## Lessons Learned

1. **Always decode URL parameters** when using them for database lookups or string matching
2. **Test navigation flows end-to-end**, not just the click handler in isolation
3. **Consider all entry points** to a page - URLs can come from:
   - Direct links (may be encoded)
   - Internal navigation (may use different formats)
   - External systems (may have different casing)

## Prevention

For future dynamic routes that accept user-readable parameters:

1. Always use `decodeURIComponent()` on the URL parameter
2. Implement case-insensitive matching
3. Add fallback matching strategies for robustness
