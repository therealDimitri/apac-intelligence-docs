# Bundle Optimisation for Mobile

**Date:** 25 January 2025
**Type:** Enhancement
**Status:** Resolved

## Summary

Optimised bundle size and code splitting for mobile users to improve initial page load performance.

## Changes Made

### 1. Updated next.config.ts - Enhanced Package Optimisation

Added additional packages to `optimizePackageImports` for better tree-shaking:

```typescript
optimizePackageImports: [
  // Icon libraries
  'lucide-react',
  '@radix-ui/react-icons',
  // Chart and visualisation libraries
  'recharts',
  '@tremor/react',
  // Date utilities
  'date-fns',
  // Animation
  'framer-motion',
  // UI primitives
  '@radix-ui/react-dialog',
  '@radix-ui/react-dropdown-menu',
  '@radix-ui/react-popover',
  '@radix-ui/react-select',
  '@radix-ui/react-tabs',
  '@radix-ui/react-tooltip',
  // Utilities
  'clsx',
  'class-variance-authority',
]
```

### 2. Created Enhanced Charts Barrel File (src/components/charts/index.ts)

Created a barrel file with both direct exports and lazy-loading exports:

**Direct exports** (for above-the-fold components):
- RadialHealthGauge, NPSDonut, StackedAgingBar (with skeletons)

**Lazy exports** (for below-the-fold or modal/tab content):
- LazyHealthTrendChart
- LazyNPSTrendChart
- LazyPortfolioProgressChart
- LazyInitiativeTimelineChart
- LazySentimentPieChart

Each lazy export uses `next/dynamic` with appropriate ChartSkeleton loading states and `ssr: false`.

### 3. Dynamic jsPDF Imports

Converted static `import jsPDF from 'jspdf'` (~700KB) to dynamic imports in client-side components:

**Files updated:**
- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
- `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`
- `src/app/(dashboard)/clients/[clientId]/v2/page.tsx`
- `src/app/(dashboard)/financials/page.tsx`
- `src/components/FloatingChaSenAI.tsx`

**Pattern used:**
```typescript
// Before
import jsPDF from 'jspdf'
const pdf = new jsPDF()

// After
const { jsPDF } = await import('jspdf')
const pdf = new jsPDF()
```

### 4. Updated Pages to Use Lazy Chart Components

**src/app/(dashboard)/clients/[clientId]/portfolio/page.tsx:**
- Replaced static imports with `LazyPortfolioProgressChart` and `LazyInitiativeTimelineChart`

**src/app/(dashboard)/clients/[clientId]/nps-analysis/page.tsx:**
- Replaced static imports with `LazyNPSTrendChart` and `LazySentimentPieChart`

## Bundle Size Impact

| Change | Estimated Savings |
|--------|-------------------|
| jsPDF dynamic import (5 files) | ~700KB per page |
| Chart code splitting | ~30-50KB per chart |
| Radix UI tree-shaking | ~20-30KB |
| Additional optimizePackageImports | Variable |

## Testing

- Build passes with zero TypeScript errors
- All routes generate successfully (156 static pages)
- Dynamic imports load correctly when triggered

## Files Modified

1. `/next.config.ts`
2. `/src/components/charts/index.ts`
3. `/src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
4. `/src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`
5. `/src/app/(dashboard)/clients/[clientId]/v2/page.tsx`
6. `/src/app/(dashboard)/clients/[clientId]/portfolio/page.tsx`
7. `/src/app/(dashboard)/clients/[clientId]/nps-analysis/page.tsx`
8. `/src/app/(dashboard)/financials/page.tsx`
9. `/src/components/FloatingChaSenAI.tsx`

## Best Practices for Future Development

1. **Use lazy exports for charts** that are not immediately visible on page load
2. **Dynamic import heavy libraries** like jsPDF, xlsx, etc. only when user triggers the action
3. **Leverage the existing ChartSkeleton component** for loading states
4. **Keep the charts barrel file updated** when adding new chart components
