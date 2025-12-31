# Bug Report: Priority Matrix Auto-Scroll Not Working

**Date:** 31 December 2025
**Status:** Fixed
**Severity:** Medium (UX/Usability)
**Component:** Priority Matrix

## Summary

When clicking on a Priority Matrix card after scrolling down the page, the detail panel would open but the user had to manually scroll back up to see it. The auto-scroll function was not working.

## Root Cause

The auto-scroll logic was using `window.scrollTo()` which doesn't work in this application because:

1. The `window` itself has no scroll - `window.scrollY` always returns 0
2. The actual scrollable container is the `<main>` element with `overflow-y-auto` CSS class
3. The main element has `scrollHeight: 6456, clientHeight: 997` (scrollable content)

The previous fix in `SlideOverDetail.tsx` was targeting the wrong component - the Priority Matrix doesn't use `SlideOverDetail`, it uses an inline `DetailPanel` with `react-resizable-panels`.

## Solution

Updated `PriorityMatrix.tsx` to scroll the `<main>` element instead of `window`:

### Fix 1: handleItemClick function (lines 417-436)

```tsx
const handleItemClick = useCallback(
  (itemId: string) => {
    setSelectedItemId(itemId)
    // Update URL with item parameter
    const params = new URLSearchParams(searchParams.toString())
    params.set('item', itemId)
    router.push(`?${params.toString()}`, { scroll: false })

    // Scroll to top so user can see the detail panel
    // The main element has overflow-y-auto, not the window
    const mainElement = document.querySelector('main')
    if (mainElement) {
      mainElement.scrollTo({ top: 0, behavior: 'smooth' })
    } else {
      // Fallback to window scroll
      window.scrollTo({ top: 0, behavior: 'smooth' })
    }
  },
  [router, searchParams]
)
```

### Fix 2: URL sync useEffect (lines 108-131)

Same pattern applied - scroll the main element when opening an item from URL parameters.

### Fix 3: Scroll back to card on panel close (lines 444-464)

When the detail panel is closed, scroll back to the originating card so the user doesn't need to manually scroll down to find where they were:

```tsx
const handleCloseDetail = useCallback(() => {
  // Store the current item ID before clearing so we can scroll back to it
  const previousItemId = selectedItemId

  setSelectedItemId(null)
  // Remove item parameter from URL
  const params = new URLSearchParams(searchParams.toString())
  params.delete('item')
  const newUrl = params.toString() ? `?${params.toString()}` : window.location.pathname
  router.push(newUrl, { scroll: false })

  // Scroll back to the originating card after a short delay to allow React to re-render
  if (previousItemId) {
    setTimeout(() => {
      const cardElement = document.querySelector(`[data-item-id="${previousItemId}"]`)
      if (cardElement) {
        cardElement.scrollIntoView({ behavior: 'smooth', block: 'center' })
      }
    }, 100)
  }
}, [router, searchParams, selectedItemId])
```

This required adding `data-item-id` attributes to card components for DOM selection.

## Files Modified

| File | Change |
|------|--------|
| `src/components/priority-matrix/PriorityMatrix.tsx` | Scroll to top on open, scroll back to card on close |
| `src/components/priority-matrix/MatrixItem.tsx` | Added `data-item-id` attribute for DOM selection |
| `src/components/priority-matrix/MatrixItemCompact.tsx` | Added `data-item-id` attribute for DOM selection |

## Testing Performed

Using Playwright browser automation:

### Test 1: Scroll to top when opening panel
1. Navigated to Command Centre at `http://localhost:3002/`
2. Scrolled main element to position 3000 (simulating user at bottom of page)
3. Clicked on "Prepare RVEEH renewal" card
4. Verified main element scroll position returned to 0
5. Detail panel visible at top of viewport

**Result:** PASS

### Test 2: Scroll back to card when closing panel
1. With detail panel open (scroll at 0)
2. Clicked "Close detail panel" button
3. Verified scroll position changed to 125 (to centre the card)
4. Verified card is fully visible (`isCardVisible: true`)
5. Card positioned at 381-616px in 0-997px viewport (roughly centred)

**Result:** PASS

## Key Learning

When debugging scroll issues in React applications:

1. Check which element actually has the scroll - often it's not `window`
2. Look for `overflow-y: auto` or `overflow-y: scroll` in the CSS
3. Use browser DevTools or Playwright to evaluate:
   ```javascript
   window.scrollY  // Often 0 if window isn't scrollable
   document.querySelector('main').scrollTop  // Check container elements
   ```

## Deployment

- **Commit:** (pending)
- **Message:** "fix: Auto-scroll to top when opening Priority Matrix card"
- **Deployed to:** https://apac-cs-dashboards.com
