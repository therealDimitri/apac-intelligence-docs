# Bug Report: React Hydration Mismatch in Orbit SVG Visualisations

**Date Reported:** 29 January 2026
**Date Fixed:** 29 January 2026
**Severity:** Medium
**Component:** Operating Rhythm - AnnualOrbitView, CSEOrbitView
**Commit:** `bc74e8a0`

## Summary

React hydration mismatch errors occurred in the Operating Rhythm orbit visualisations due to floating-point precision differences between server-side rendering (SSR) and client-side rendering (CSR).

## Symptoms

Console error message:
```
A tree hydrated but some attributes of the server rendered HTML didn't match the client properties.
Server: x="-104.99999999999997"
Client: x={-104.99999999999996}
```

The error appeared on initial page load but did not break functionality visually. However, it indicated a potential for unpredictable rendering behaviour and degraded React performance.

## Root Cause

SVG coordinate calculations using `Math.cos()` and `Math.sin()` produce floating-point numbers with slight precision differences between Node.js (SSR) and browser (CSR) JavaScript engines. Even differences at the 15th decimal place (e.g., `...997` vs `...996`) cause React's hydration comparison to fail.

**Affected calculations:**
- `getOrbitPosition()` - Event node positioning
- Month label and indicator dot positions
- Quarter arc path coordinates
- Monthly activity indicator positions
- Progress arc calculations in `createProgressArc()`
- Client mini-orbit bubble positions

## Solution

Added a `round()` utility function to both affected files that rounds floating-point numbers to 2 decimal places:

```typescript
const round = (n: number): number => Math.round(n * 100) / 100
```

Applied this function to all SVG coordinate calculations:

```typescript
// Before
const x = Math.cos((angle * Math.PI) / 180) * radius

// After
const x = round(Math.cos((angle * Math.PI) / 180) * radius)
```

2 decimal places provides:
- Sufficient precision for SVG rendering (sub-pixel accuracy unnecessary)
- Deterministic values regardless of JS engine differences
- Zero visual impact on the visualisations

## Files Changed

| File | Change |
|------|--------|
| `src/components/operating-rhythm/AnnualOrbitView.tsx` | Added `round()` function, applied to all coordinate calculations |
| `src/components/operating-rhythm/CSEOrbitView.tsx` | Added `round()` function, applied to `getPosition()` function |

## Testing

1. Built successfully with `npm run build` - no TypeScript errors
2. Tested with Playwright:
   - Loaded `/operating-rhythm` page
   - Verified no console errors
   - Switched to "By CSE" view
   - Verified no console errors
3. Deployed to Netlify production - successful

## Prevention

When creating SVG visualisations with dynamic coordinate calculations:

1. Always round floating-point coordinates to a consistent precision
2. Use a shared utility function for coordinate calculations
3. Test hydration by checking console errors on page load
4. Consider using integer coordinates when possible (multiply/divide by a scale factor)

## Related

- Previous commit `7a1e2bcd` added CSE Orbit View feature
- This fix was applied immediately after the hydration error was reported
