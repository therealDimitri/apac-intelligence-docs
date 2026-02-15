# Enhancement: Working Capital Navigation Button

**Date:** 2026-01-02
**Status:** Implemented
**Severity:** Low (Enhancement)
**Component:** Client Profile V2 - RightColumn

## User Request

> "Add button that navs to Working Capital>Detailed View on the Working Capital Health card for all client profiles."

## Implementation

Added a clickable navigation link to the Working Capital status pill in the Client Status Summary section. Clicking the pill now navigates users directly to the Aging Accounts (Working Capital) detailed view.

### Changes Made

1. **Added Link import** from `next/link`
2. **Added ExternalLink icon** from `lucide-react`
3. **Converted Working Capital div to Link component** with:
   - Navigation to `/aging-accounts`
   - Hover effects (shadow, scale, background colour change)
   - External link icon indicator
   - Title tooltip "View Working Capital Details"

### Visual Changes

- Working Capital pill now shows an external link icon (→)
- Hover state: subtle scale up (1.02x), shadow, darker background
- Cursor changes to pointer on hover
- Maintains existing colour coding (green for On Track, red for At Risk)

## Code Changes

**File:** `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`

```typescript
// BEFORE: Static div
<div className={`flex items-center gap-2 px-2.5 py-1.5 rounded-lg border ${...}`}>
  <DollarSign />
  <span>WC: On Track</span>
</div>

// AFTER: Clickable Link with hover effects
<Link
  href="/aging-accounts"
  className={`flex items-center gap-2 px-2.5 py-1.5 rounded-lg border
    transition-all hover:shadow-sm hover:scale-[1.02] cursor-pointer ${...}`}
  title="View Working Capital Details"
>
  <DollarSign />
  <span>WC: On Track</span>
  <ExternalLink className="h-3 w-3" />
</Link>
```

## Files Modified

- `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`
  - Lines 5: Added `Link` import
  - Lines 44: Added `ExternalLink` to lucide-react imports
  - Lines 658-679: Converted Working Capital div to Link component

## Testing Verification

1. **TypeScript compilation**: Passes
2. **Visual verification**: Working Capital pill displays external link icon
3. **Navigation**: Clicking navigates to `/aging-accounts`

## UX Improvement

This enhancement allows users to quickly access detailed Working Capital information directly from the client profile overview, reducing the number of clicks needed to investigate aging receivables issues.
