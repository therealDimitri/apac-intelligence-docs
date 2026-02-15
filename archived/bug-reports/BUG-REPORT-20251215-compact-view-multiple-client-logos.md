# Bug Report: Compact View Not Displaying Multiple Client Logos

**Date:** 2025-12-15
**Status:** FIXED
**Commit:** 92b21a9

## Issue Summary

The Priority Matrix compact view did not display client logos when an insight affected multiple clients. The UI only showed a single client logo even when the `item.clients` array contained multiple entries.

## Root Cause

The `MatrixItemCompact` component only rendered a single `ClientLogoDisplay` component using `item.client` (singular), and didn't have logic to handle the `item.clients` array (plural) that contains multiple affected clients.

## Solution

Created a new `ClientLogoStack` component that displays client logos in a stacked avatar style (similar to GitHub contributors):

### Key Changes

1. **New Component: `ClientLogoStack.tsx`**
   - Displays overlapping circular logos
   - Shows up to `maxVisible` logos (default: 4)
   - Displays "+N" badge for overflow (e.g., "+3" if 3 more clients exist)
   - Supports size variants: `sm` (24px), `md` (32px), `lg` (40px)
   - Includes `MiniClientLogo` helper for smaller sizes than main `ClientLogoDisplay`

2. **Updated: `MatrixItemCompact.tsx`**
   - Added conditional rendering: uses `ClientLogoStack` for multiple clients, `ClientLogoDisplay` for single client
   - Fixed React lint error about dynamic component creation in `ItemIcon`
   - Moved helper functions before component definitions to resolve hoisting issues

### Implementation Details

```tsx
{
  /* Client Logo(s) */
}
{
  item.clients && item.clients.length > 0 ? (
    <div className="flex-shrink-0">
      <ClientLogoStack clients={item.clients} maxVisible={3} size="sm" />
    </div>
  ) : item.client ? (
    <div className="flex-shrink-0">
      <ClientLogoDisplay clientName={item.client} size="sm" className="w-6 h-6" />
    </div>
  ) : null
}
```

## Files Changed

- `src/components/priority-matrix/ClientLogoStack.tsx` (NEW)
- `src/components/priority-matrix/MatrixItemCompact.tsx` (MODIFIED)

## Design Pattern

The stacked logo pattern is commonly used in:

- GitHub contributor avatars
- Slack channel member previews
- Google Drive shared file participants

Visual representation:

```
[Logo1][Logo2][Logo3][+2]
       ↑ overlapping circles with ring border
```

## Testing

1. Navigate to Priority Matrix page (`/priority-matrix`)
2. View insights in compact mode that affect multiple clients
3. Verify stacked logos appear with "+N" badge for overflow
4. Hover over logos to see client name tooltips
5. Hover over "+N" badge to see list of remaining clients

## Related Issues

- TypeScript error: `Type 'number' is not assignable to type '"sm" | "md" | "lg" | "xl"'` - Fixed by creating custom `MiniClientLogo` component instead of using `ClientLogoDisplay` with numeric sizes
- ESLint error: `Cannot create components during render` - Fixed by using conditional rendering in `ItemIcon` instead of dynamic component assignment
