# Mobile Responsiveness Refactoring Plan

## CS Intelligence Dashboard - Full Mobile Optimisation

**Document Version:** 1.0
**Created:** 2026-01-24
**Target Devices:** iPhone 12-16 series, Samsung Galaxy S22-S24, Google Pixel 7-8

---

## Executive Summary

This document outlines a comprehensive refactoring plan to achieve full mobile responsiveness across the CS Intelligence Dashboard. The current codebase has solid mobile foundations (MobileBottomNav, MobileDrawer, useMediaQuery hooks) but requires targeted improvements for small phone viewports, data-heavy components, and performance optimisation.

---

## 1. Current State Analysis

### 1.1 Tech Stack
| Technology | Version | Mobile Readiness |
|------------|---------|------------------|
| Next.js | 16.0.7 | ✅ Excellent (App Router, Suspense) |
| React | 19.2.1 | ✅ Excellent (Server Components) |
| Tailwind CSS | v4 | ✅ Excellent (Mobile-first utilities) |
| Radix UI | v10+ | ✅ Excellent (Touch-friendly) |
| Recharts | 3.5.1 | ⚠️ Needs mobile configuration |
| Tremor | 3.18.7 | ⚠️ Needs mobile configuration |
| TanStack Table | 8.21.3 | ❌ Requires mobile card views |

### 1.2 Existing Mobile Patterns (Strengths)
- **MobileBottomNav.tsx**: 64px touch targets, safe area insets, 5-item navigation
- **MobileDrawer.tsx**: Vaul-powered, swipe gestures, keyboard accessible
- **useMediaQuery.ts**: Responsive hooks for mobile/tablet/desktop detection
- **globals.css**: Safe area utilities, touch targets, drawer animations
- **Dynamic viewport height** (`h-dvh`) for mobile browser chrome handling

### 1.3 Current Breakpoints
```css
sm: 640px   /* Rarely used */
md: 768px   /* Primary mobile/desktop threshold */
lg: 1024px  /* Tablet/Desktop */
xl: 1280px  /* MacBook 14" */
2xl: 1536px /* Large displays */
```

### 1.4 Identified Gaps

| Component | Issue | Severity |
|-----------|-------|----------|
| Data Tables | No mobile card view | 🔴 Critical |
| Recharts | Fixed widths, hover-dependent | 🔴 Critical |
| KPI Grids | Overflow on small phones | 🟡 High |
| Filters/Toolbars | Complex multi-column layouts | 🟡 High |
| Action Cards | Dense information hierarchy | 🟡 High |
| Touch Targets | Inconsistent 44px minimum | 🟢 Medium |
| Skeleton Loaders | Not optimised for mobile | 🟢 Medium |

---

## 2. Target Device Specifications

### 2.1 Screen Dimensions

| Device | Viewport (CSS px) | Physical px | Safe Areas |
|--------|------------------|-------------|------------|
| iPhone 12 mini | 375 x 812 | 1080 x 2340 | Top: 47px, Bottom: 34px |
| iPhone 12/13/14 | 390 x 844 | 1170 x 2532 | Top: 47px, Bottom: 34px |
| iPhone 14/15 Pro | 393 x 852 | 1179 x 2556 | Top: 59px, Bottom: 34px |
| iPhone 14/15 Pro Max | 430 x 932 | 1290 x 2796 | Top: 59px, Bottom: 34px |
| iPhone 16 Pro | 402 x 874 | 1206 x 2622 | Top: 59px, Bottom: 34px |
| iPhone 16 Pro Max | 440 x 956 | 1320 x 2868 | Top: 59px, Bottom: 34px |
| Samsung S22 | 360 x 780 | 1080 x 2340 | Top: 24px, Bottom: 0px |
| Samsung S23/S24 | 360 x 780 | 1080 x 2340 | Top: 24px, Bottom: 0px |
| Pixel 7 | 411 x 914 | 1080 x 2400 | Top: 24px, Bottom: 0px |
| Pixel 8 | 411 x 914 | 1080 x 2400 | Top: 24px, Bottom: 0px |

### 2.2 Proposed Breakpoint System

```css
/* New breakpoints to add */
xs: 320px   /* Smallest phones (SE, older models) */
sm: 375px   /* iPhone mini series */
md: 428px   /* iPhone Pro Max / Large Android */
lg: 768px   /* Tablet portrait / Mobile landscape */
xl: 1024px  /* Tablet landscape / Small desktop */
2xl: 1280px /* Desktop */
3xl: 1536px /* Large desktop */
```

---

## 3. Component-by-Component Refactoring Plan

### 3.1 Data Tables (Critical Priority)

**Current State:**
- `data-table.tsx` renders standard HTML tables
- No mobile-specific rendering
- Horizontal scroll on mobile (poor UX)

**Proposed Solution:** Card-based mobile view with progressive disclosure

```
+------------------------------------------+
| Client: Acme Corp                        |
| Health: ● 85 (Healthy)                   |
| Owner: Sarah Smith    Due: Jan 24, 2026  |
| [View Details]                           |
+------------------------------------------+
```

**Implementation:**
1. Create `MobileDataCard.tsx` component
2. Add `useMobileView` hook to `DataTable`
3. Render cards when `isMobile` is true
4. Support swipe-to-reveal actions
5. Implement virtual scrolling for long lists

**Files to modify:**
- `src/components/data-table/data-table.tsx`
- `src/components/data-table/data-table-mobile-card.tsx` (new)
- `src/components/ui/VirtualList.tsx` (integrate)

### 3.2 Charts & Data Visualisation (Critical Priority)

**Current Issues:**
- Recharts uses fixed pixel widths
- Hover-dependent tooltips don't work on touch
- Complex charts become illegible on mobile
- Legend overlaps chart area

**Solutions by Chart Type:**

#### NPSDonut.tsx
| Current | Mobile Adaptation |
|---------|-------------------|
| Fixed 120px diameter | Responsive: `clamp(80px, 20vw, 120px)` |
| Horizontal legend | Stacked vertical legend |
| Hover interactions | Tap-to-select segments |

#### HealthTrendChart.tsx / LineCharts
| Current | Mobile Adaptation |
|---------|-------------------|
| Full date labels | Abbreviated dates (Jan, Feb) |
| Multiple series | Selectable single-series view |
| Legend below | Swipeable legend tabs |
| Fixed height | Responsive aspect ratio |

#### StackedAgingBar.tsx / BarCharts
| Current | Mobile Adaptation |
|---------|-------------------|
| Horizontal bars | Vertical bars on mobile |
| Dense labels | Fewer data points (top 5) |
| Complex tooltips | Bottom sheet detail view |

**Implementation Pattern:**
```tsx
// src/hooks/useChartDimensions.ts
export function useChartDimensions() {
  const isMobile = useIsMobile()
  return {
    width: isMobile ? '100%' : 400,
    height: isMobile ? 200 : 300,
    margin: isMobile
      ? { top: 10, right: 10, bottom: 30, left: 30 }
      : { top: 20, right: 30, bottom: 50, left: 60 },
  }
}
```

### 3.3 Dashboard Layout (High Priority)

**Current State:**
- `src/app/(dashboard)/page.tsx` uses `sm:px-6` padding
- KPI grids use 4-column layout
- PortfolioHealthStats may overflow

**Proposed Changes:**

| Component | Desktop | Mobile |
|-----------|---------|--------|
| KPI Grid | 4 columns | 2 columns |
| Header | Horizontal layout | Stacked vertical |
| Client Filter | Toggle buttons | Bottom sheet selector |
| Greeting | Full text | Abbreviated |
| Subtitle | Full text | Hidden or truncated |

**Mobile KPI Grid Layout:**
```
+----------+ +----------+
| Health   | | NPS      |
| Score    | | Score    |
+----------+ +----------+
+----------+ +----------+
| Actions  | | Meetings |
| Due      | | This Week|
+----------+ +----------+
```

### 3.4 ActionableIntelligenceDashboard.tsx (High Priority)

**Current State:**
- 62KB complex component
- Priority Matrix with multi-view
- Dense information cards
- Multi-column layouts

**Proposed Changes:**
1. **Priority Matrix Mobile Mode**
   - Single-column scrollable list
   - Quick actions via swipe gestures
   - Floating action button for add/filter

2. **Alert Cards Mobile Optimisation**
   - Collapsible sections
   - Priority-sorted single column
   - Tap to expand details

3. **Filter Bar**
   - Collapse to filter icon on mobile
   - Bottom sheet with full filter options
   - Active filter count badge

### 3.5 Forms & Inputs (Medium Priority)

**Touch Target Audit:**
| Element | Current | Required |
|---------|---------|----------|
| Buttons | Variable | 44px minimum |
| Checkboxes | 16px | 24px with 44px tap area |
| Select dropdowns | 36px | 44px |
| Text inputs | 40px | 44px |
| Icon buttons | 24px | 44px tap area |

**Implementation:**
```tsx
// src/components/ui/button.tsx - Add mobile variant
const buttonVariants = cva(
  'touch-target', // Ensures 44px minimum
  {
    variants: {
      size: {
        default: 'h-10 px-4 py-2', // 40px
        sm: 'h-9 px-3', // 36px
        lg: 'h-11 px-8', // 44px
        mobile: 'h-12 px-4 py-3 min-h-[48px]', // NEW: 48px
      }
    }
  }
)
```

### 3.6 Navigation Components

**MobileBottomNav.tsx** - Already well-implemented
- 64px height ✅
- Safe area insets ✅
- 44px+ touch targets ✅

**Improvements:**
- Add haptic feedback support (where available)
- Implement navigation gestures (swipe left/right between tabs)
- Add "scroll to top" on current tab re-tap

**MobileDrawer.tsx** - Well-implemented
- Vaul gestures ✅
- Safe area handling ✅
- Spring animations ✅

**Improvements:**
- Add search/filter at top
- Implement recent pages section
- Add offline indicator

---

## 4. Performance Optimisation Strategy

### 4.1 Target Metrics

| Metric | Target | Current (Estimate) |
|--------|--------|-------------------|
| First Contentful Paint (FCP) | < 1.5s | ~2.5s |
| Largest Contentful Paint (LCP) | < 2.5s | ~3.5s |
| Time to Interactive (TTI) | < 3.5s | ~5.0s |
| Cumulative Layout Shift (CLS) | < 0.1 | ~0.15 |
| First Input Delay (FID) | < 100ms | ~150ms |

### 4.2 Optimisation Techniques

#### Image Optimisation
- Already using Next.js Image with AVIF/WebP ✅
- Add `priority` to above-fold images
- Implement blur placeholders for charts

#### Code Splitting
- Already lazy-loading `FloatingChaSenAI` ✅
- Add lazy loading for:
  - Chart components (load on scroll into view)
  - Modal/drawer content
  - Below-fold dashboard sections

#### Data Loading
- Implement `stale-while-revalidate` for React Query
- Reduce initial data payload (pagination, partial hydration)
- Add optimistic updates for actions

#### Bundle Size
- Current optimisations look good ✅
- Consider dynamic imports for Recharts/Tremor
- Tree-shake unused Lucide icons

### 4.3 Mobile-Specific Optimisations

```typescript
// src/lib/mobile-performance.ts
export const mobileConfig = {
  // Reduce animation complexity on mobile
  reduceMotion: prefersReducedMotion || isMobile,

  // Limit data points in charts
  chartDataLimit: isMobile ? 7 : 30,

  // Simplify table rendering
  virtualizeThreshold: isMobile ? 20 : 100,

  // Defer non-critical loads
  deferredComponents: ['AIInsights', 'DetailedMetrics'],
}
```

---

## 5. Accessibility Considerations (WCAG 2.1 Level AA)

### 5.1 Touch Target Compliance
- All interactive elements: 44x44px minimum ✅ (after implementation)
- Adequate spacing between targets (8px minimum)

### 5.2 Colour Contrast
- Text contrast ratios maintained (already using semantic colours)
- Chart colours to be verified for colour blindness

### 5.3 Screen Reader Support
- ARIA labels on all interactive elements
- Semantic HTML structure
- Focus management for modals/drawers

### 5.4 Reduced Motion
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## 6. Testing Strategy

### 6.1 Device Testing Matrix

| Device | OS Version | Browser | Priority |
|--------|------------|---------|----------|
| iPhone 14 Pro | iOS 17 | Safari | 🔴 Critical |
| iPhone 12 | iOS 16 | Safari | 🔴 Critical |
| Samsung S24 | Android 14 | Chrome | 🔴 Critical |
| Pixel 8 | Android 14 | Chrome | 🟡 High |
| iPhone SE 3 | iOS 16 | Safari | 🟡 High |
| Samsung S22 | Android 13 | Samsung Browser | 🟢 Medium |

### 6.2 Testing Approach

1. **Playwright E2E Tests**
   - Already configured at port 3001
   - Add mobile viewport tests
   - Touch interaction tests

2. **Real Device Testing**
   - BrowserStack/Sauce Labs for device farm
   - Physical devices for critical flows

3. **Manual Testing Checklist**
   - [ ] Bottom navigation accessibility
   - [ ] Drawer swipe gestures
   - [ ] Chart touch interactions
   - [ ] Form input keyboard handling
   - [ ] Portrait/landscape orientation
   - [ ] Safe area rendering on notched devices

### 6.3 Performance Testing

```bash
# Lighthouse CI configuration
npm run lighthouse:mobile -- --preset=mobile
```

---

## 7. Implementation Phases

### Phase 1: Foundation (Week 1)
- [ ] Add new breakpoint utilities to globals.css
- [ ] Create `useChartDimensions` hook
- [ ] Implement `MobileDataCard` component
- [ ] Update touch target sizes globally

### Phase 2: Core Components (Week 2)
- [ ] Refactor DataTable for mobile
- [ ] Optimise chart components
- [ ] Update dashboard layout breakpoints
- [ ] Implement mobile filter bottom sheets

### Phase 3: Performance (Week 3)
- [ ] Add lazy loading for charts
- [ ] Implement virtual scrolling everywhere
- [ ] Optimise bundle for mobile
- [ ] Add skeleton loaders for mobile

### Phase 4: Polish & Testing (Week 4)
- [ ] Playwright mobile viewport tests
- [ ] Real device testing
- [ ] Performance benchmarking
- [ ] Accessibility audit
- [ ] Bug fixes and refinements

---

## 8. Before/After Mockup Reference Points

### Key Screens for Mockups

1. **Command Centre Dashboard** (375px / 768px / 1440px)
   - KPI grid layout transformation
   - Header stacking behaviour

2. **Client Profiles Table** (375px / 768px / 1440px)
   - Table to card transformation
   - Filter toolbar adaptation

3. **Priority Matrix** (375px / 768px / 1440px)
   - Quadrant to list transformation
   - Action card layout

4. **NPS Analytics** (375px / 768px / 1440px)
   - Chart sizing and legend placement
   - Response table adaptation

---

## 9. Questions Resolved

### Q: What's the acceptable performance threshold on mobile networks?
**A:** Target <3s initial load on 4G connection (≈10 Mbps). Implement progressive loading with skeleton states. Core functionality must work on 3G (≈1.5 Mbps).

### Q: Are there specific features lower priority for mobile?
**A:** Based on typical mobile usage patterns:
- **Lower Priority:** AI Assistant (ChaSen), Complex analytics, Bulk operations
- **Higher Priority:** Quick status checks, Meeting notes, Action completion, Client lookup

### Q: What's the current user analytics for mobile vs desktop?
**A:** To be gathered - recommend adding analytics events for device type tracking.

### Q: Are there accessibility requirements (WCAG 2.1 Level AA)?
**A:** Yes, recommended. Implementation should include:
- 44px touch targets
- 4.5:1 contrast ratios
- Screen reader compatibility
- Reduced motion support

---

## 10. Trade-offs Acknowledged

| Desktop Feature | Mobile Adaptation | Rationale |
|-----------------|-------------------|-----------|
| Multi-column data tables | Card-based list view | Horizontal scroll is poor UX |
| Complex chart interactions | Simplified with drill-down | Touch precision limitations |
| Hover tooltips | Tap-to-reveal | No hover on touch devices |
| Dense KPI grids | 2-column maximum | Screen width constraints |
| Floating AI Assistant | Hidden or minimised | Screen real estate |
| Simultaneous filters | Sequential filter sheets | Avoid overwhelming interface |

---

## Appendix A: File Modification Summary

### New Files to Create
- `src/components/data-table/data-table-mobile-card.tsx`
- `src/hooks/useChartDimensions.ts`
- `src/hooks/useTouchGestures.ts`
- `src/components/ui/MobileFilterSheet.tsx`
- `src/lib/mobile-performance.ts`
- `tests/e2e/mobile-viewport.spec.ts`

### Files to Modify
- `src/app/globals.css` (new breakpoints, utilities)
- `src/components/data-table/data-table.tsx` (mobile view toggle)
- `src/components/charts/*.tsx` (responsive dimensions)
- `src/app/(dashboard)/page.tsx` (layout adaptations)
- `src/components/ActionableIntelligenceDashboard.tsx` (mobile optimisations)
- `src/components/ui/button.tsx` (mobile size variant)
- All form input components (touch target sizing)

---

## Appendix B: CSS Utility Additions

```css
/* Add to globals.css */

/* Extra-small phone breakpoint */
@media (max-width: 374px) {
  .xs-hidden { display: none; }
  .xs-text-sm { font-size: 0.875rem; }
  .xs-p-2 { padding: 0.5rem; }
}

/* Small phone optimisations (375-427px) */
@media (min-width: 375px) and (max-width: 427px) {
  .phone-grid-2 { grid-template-columns: repeat(2, 1fr); }
  .phone-text-balance { text-wrap: balance; }
}

/* Large phone / phablet (428-767px) */
@media (min-width: 428px) and (max-width: 767px) {
  .phablet-grid-3 { grid-template-columns: repeat(3, 1fr); }
}

/* Touch-friendly spacing */
.touch-spacing { gap: 12px; }
.touch-padding { padding: 16px; }
```

---

**Document prepared by:** Claude (AI-assisted development)
**Review required by:** Development team lead
**Implementation owner:** TBD
