# Bug Fix: Production 404 Chunk Errors & MacBook Layout Optimisation

## Issue Summary

**Date:** 9 January 2026
**Severity:** Critical (Production Down) + Medium (UI/UX)
**Status:** Fixed

## Problem Description

### Issue 1: Production 404 Errors (Critical)

The production site at https://apac-cs-dashboards.com was completely broken, returning 404 errors for all JavaScript chunks. Users could not access any functionality.

#### Root Cause

1. Stale build artifacts in the `.next` directory from interrupted dev server processes
2. Lock files preventing clean production builds
3. Zombie Next.js processes holding file locks during deployment attempts

### Issue 2: MacBook Layout Problems (Medium)

The Command Centre dashboard displayed incorrectly on 14" and 16" MacBook Pro screens:
- KPI cards had awkward text wrapping
- Cards didn't use available space efficiently
- Labels like "Net Revenue Retention" were breaking across multiple lines

#### Root Cause

- CSS media queries didn't account for MacBook-specific viewport sizes (1280px-1919px)
- KPI card labels were too long for narrower screen widths

## Solution

### Production Fix

1. Killed zombie Next.js processes holding build locks
2. Completely removed corrupted `.next` directory
3. Built fresh production build locally
4. Deployed to Netlify production with clean build artifacts

### MacBook Layout Fix

1. Added CSS media query breakpoints specifically for MacBook displays
2. Shortened KPI labels for better fit on smaller screens

## Files Modified

### CSS Changes

**`src/app/globals.css`**

Added media queries for MacBook screen sizes:

```css
/* 14" MacBook Pro (1280px - 1599px) */
@media (min-width: 1280px) and (max-width: 1599px) {
  .macbook-kpi-grid { ... }
  .macbook-kpi-card { ... }
}

/* 16" MacBook Pro (1600px - 1919px) */
@media (min-width: 1600px) and (max-width: 1919px) {
  .macbook-kpi-grid { ... }
  .macbook-kpi-card { ... }
}
```

### Component Changes

**`src/components/burc/BURCExecutiveDashboard.tsx`**

Shortened KPI labels:
- "Net Revenue Retention" → "NRR" (on smaller screens)
- "Gross Revenue Retention" → "GRR" (on smaller screens)
- "FY26 Full Year (Actuals + Forecasts)" → "FY26 Actuals + Forecast"
- "Overdue & Upcoming Renewals" → "Renewals"
- Reduced card padding for better space utilisation

## Testing

### Build Verification
```bash
npm run build  # Success - no TypeScript errors
```

### Production Deployment
```bash
netlify deploy --prod  # Success - deployed to https://apac-cs-dashboards.com
```

### Layout Testing (Both Passed)

| Screen Size | Dimensions | Result |
|-------------|------------|--------|
| 14" MacBook Pro | 1440x900 | ✅ KPI cards in single row, no text wrapping |
| 16" MacBook Pro | 1680x1050 | ✅ KPI cards in single row, good spacing |

## Prevention Measures

### For Deployment Issues

1. Always kill dev server before deploying: `pkill -f "next dev"`
2. Clear `.next` directory before production builds: `rm -rf .next`
3. Verify no lock files exist before building

### For Layout Issues

1. Test all UI changes on multiple screen sizes before deployment
2. Required testing matrix:
   - Desktop (1920x1080)
   - 16" MacBook (1680x1050)
   - 14" MacBook (1440x900)
   - Laptop (1366x768)
   - Tablet (768x1024)

## Related Documentation

- `docs/QUALITY_STANDARDS.md` - Full quality checklist created after this incident
- `docs/guides/NETLIFY-DEPLOYMENT-GUIDE.md` - Deployment procedures

## Commands Reference

```bash
# Kill zombie processes
pkill -f "next dev"
pkill -9 -f "mcp-chrome"

# Clean build
rm -rf .next
npm run build

# Deploy to production
netlify deploy --prod --message "Description of changes"
```
