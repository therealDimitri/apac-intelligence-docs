# CSI Dashboard UI/UX Quick Reference Guide

**Quick access guide for implementation team**
**Full analysis:** See `ui-ux-analysis-csi-dashboard.md`

---

## Critical Changes (Do These First)

### 1. Accessibility Fixes (WCAG Violations)

**Problem:** Red/green colour-only communication fails WCAG 1.4.1
**Fix:** Add text labels + icons to all status indicators

```tsx
// Add to forecast box:
{forecastAtTarget ? (
  <>
    <CheckCircle2 className="w-4 h-4" />
    <span>On Track</span>
  </>
) : (
  <>
    <AlertTriangle className="w-4 h-4" />
    <span>Below Target</span>
  </>
)}
```

**Problem:** No keyboard navigation
**Fix:** Add `tabIndex={0}` and focus indicators

```tsx
<div
  tabIndex={0}
  className="focus:ring-2 focus:ring-purple-500 focus:ring-offset-2"
  aria-label={`${config.name}: ${value}, ${status}`}
>
```

---

### 2. Visual Hierarchy

**Problem:** Everything same size; can't find primary value quickly
**Fix:** 3-tier typography scale

```tsx
// Tier 1: Primary value
<span className="text-4xl font-bold">2.34</span>  // 40px

// Tier 2: Status/trend
<span className="text-base font-medium">On track</span>  // 16px

// Tier 3: Labels
<span className="text-xs font-normal">PS Ratio</span>  // 12px
```

---

### 3. Reduce Clutter

**Problem:** Formula displayed on every card
**Fix:** Move to tooltip on info icon

```tsx
// Before: Always visible
<div className="text-xs italic">{config.definition}</div>

// After: Tooltip only
<Tooltip>
  <TooltipTrigger><Info className="w-4 h-4" /></TooltipTrigger>
  <TooltipContent>{config.definition}</TooltipContent>
</Tooltip>
```

---

## Recommended Card Structure

```
┌─────────────────────────────────────┐
│ PS Ratio                         ⓘ │  ← 12px label + tooltip
│                                     │
│ 2.34                                │  ← 40px bold (primary)
│ ● On track  ↑ 7%                    │  ← 16px badge (status)
│                                     │
│ ▁▂▃▅▇█▇▅▃▂▁                         │  ← Sparkline (grey)
│ ┄┄┄┄┄┄┄ target: 2.0                │  ← Threshold line
│                                     │
│ Plan: 2.10 → Forecast: 2.34         │  ← 12px compact comparison
│ Actual Dec 2025                     │  ← 10px metadata
└─────────────────────────────────────┘

Height: ~280px (vs current 380px)
```

---

## Colour System Changes

### Before (Current)
- Red/green sparklines indicate status
- Full background colours on Plan/Forecast boxes
- Ratio-specific colours (orange, purple, pink)

### After (Recommended)
- **Sparklines:** Always grey (#9CA3AF) + dashed target line
- **Status badges:** Green dot = on track, Red dot = below target
- **Plan/Forecast:** Neutral background, compact text format

**Semantic Palette:**
```tsx
const STATUS_COLOURS = {
  success: { bg: 'bg-green-50', text: 'text-green-700', dot: 'bg-green-500' },
  error: { bg: 'bg-red-50', text: 'text-red-700', dot: 'bg-red-500' },
  warning: { bg: 'bg-amber-50', text: 'text-amber-700', dot: 'bg-amber-500' }
}
```

---

## Status Indicator Consolidation

### Before (Current)
5 overlapping indicators:
1. Trend icon (checkmark/warning)
2. Trend text ("improving")
3. Sparkline colour (green/red)
4. Forecast box colour (green/red background)
5. Progress bar colour

### After (Recommended)
1 clear indicator:
- **Single badge:** `● On track  ↑ 7%`
- **Neutral sparkline:** Grey with target line
- **No progress bar:** Redundant information

---

## Responsive Grid

### Current Issue
```tsx
// 6 columns on 1280px screens = 213px cards (too narrow)
<div className="xl:grid-cols-6 gap-4">
```

### Recommended
```tsx
// 6 columns only on very wide screens
<div className="grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 2xl:grid-cols-6 gap-6">
```

**Breakpoint logic:**
- < 640px: 1 column (mobile)
- 640px-1024px: 2 columns (tablet)
- 1024px-1536px: 3 columns (desktop)
- 1536px+: 6 columns (ultra-wide)

---

## Key Interactions

### Hover States
```tsx
// Card elevation on hover
className="hover:shadow-lg hover:-translate-y-0.5"

// Sparkline tooltip on hover
<div className="group relative">
  <Sparklines />
  <div className="hidden group-hover:block absolute">
    Range: {min} - {max}
  </div>
</div>
```

### Keyboard Navigation
```tsx
// Focus on Tab key
tabIndex={0}

// Activate on Enter/Space
onKeyDown={(e) => {
  if (e.key === 'Enter' || e.key === ' ') {
    expandCard()
  }
}}
```

---

## Performance Optimisations

### 1. Lazy Load Sparklines
```tsx
import { lazy, Suspense } from 'react'

const Sparklines = lazy(() => import('react-sparklines'))

<Suspense fallback={<SparklineSkeleton />}>
  <Sparklines data={data} />
</Suspense>
```

**Impact:** Reduces initial bundle by ~8KB

### 2. Memoize Calculations
```tsx
const sparklineData = useMemo(
  () => analysis.rollingAverages.slice(-12).map(r => r.value),
  [analysis.rollingAverages]
)
```

**Impact:** Prevents re-calculation on every render

---

## Accessibility Checklist

Before launching:
- [ ] All cards keyboard accessible (Tab/Enter/Space)
- [ ] Focus indicators visible on all interactive elements
- [ ] Screen reader announces: ratio name, value, status, trend
- [ ] Colour contrast ≥ 4.5:1 for all text
- [ ] Icons have text alternatives
- [ ] Sparklines have `role="img"` and `aria-label`
- [ ] Progress removed or has `role="progressbar"` with aria-* attributes

**Test with:**
- Chrome Lighthouse (target: 100 accessibility score)
- axe DevTools (target: 0 violations)
- Screen reader (NVDA/VoiceOver)
- Keyboard only (no mouse)

---

## Testing Commands

```bash
# Accessibility audit
npm run test:a11y

# Visual regression test
npm run test:visual

# Storybook component library
npm run storybook

# Lighthouse performance
npm run lighthouse -- --url=/financials
```

---

## Industry Patterns Referenced

### Stripe Dashboard
- **Primary metric dominance:** One large number (40px+)
- **Progressive disclosure:** Details in tooltips
- **Monochrome base:** Colour only for status

### Linear Metrics
- **Clear typography scale:** 12px/16px/28px hierarchy
- **Status badges:** Small pills instead of full backgrounds
- **Keyboard focus:** All cards fully navigable

### Datadog APM
- **Sparkline context:** Target threshold lines
- **Hover annotations:** Min/max on hover
- **Alert badges:** Small red pill when threshold breached

### Mixpanel Insights
- **Smart colours:** Green = positive trend, Red = negative trend
- **Micro-interactions:** Value count-up animations
- **Responsive grid:** Graceful mobile stacking

---

## Quick Wins (1-Day Implementations)

### Win 1: Bigger Primary Values
```tsx
// Change from text-2xl (32px) to text-4xl (40px)
<span className="text-4xl font-bold">{value}</span>
```
**Impact:** Immediate scannability improvement

### Win 2: Formula Tooltips
```tsx
// Hide inline formula, show on hover
<Tooltip><Info /></Tooltip>
```
**Impact:** 30% less visual clutter

### Win 3: Status Badge
```tsx
// Replace multiple indicators with single badge
<div className="flex items-center gap-1.5 px-2 py-1 rounded-full bg-green-50">
  <div className="w-2 h-2 rounded-full bg-green-500" />
  <span>On track</span>
</div>
```
**Impact:** Clearer status communication

---

## Common Pitfalls to Avoid

### 1. Don't Rely on Colour Alone
❌ `<div className="text-red-600">Below target</div>`
✅ `<div><AlertTriangle /> Below target</div>`

### 2. Don't Skip Keyboard Navigation
❌ `<div onClick={handleClick}>`
✅ `<div tabIndex={0} onClick={handleClick} onKeyDown={handleKeyboard}>`

### 3. Don't Ignore Loading States
❌ `{data && <RatioCard data={data} />}`
✅ `{loading ? <Skeleton /> : <RatioCard data={data} />}`

### 4. Don't Overcomplicate Cards
❌ 5 status indicators + progress bar + sparkline + boxes
✅ 1 badge + neutral sparkline + compact text

---

## File Locations

**Component:**
`/src/components/csi/CSIOverviewPanel.tsx` (lines 108-321)

**Types:**
`/src/types/csi-insights.ts`

**Tests (to create):**
`/tests/csi/CSIOverviewPanel.test.tsx`

**Storybook (to create):**
`/src/components/csi/CSIOverviewPanel.stories.tsx`

---

## Support Resources

**Full Analysis:** `/docs/ui-ux-analysis-csi-dashboard.md`
**Implementation Roadmap:** See Phase 1-4 in full analysis
**Code Examples:** See "Before & After" section in full analysis
**Accessibility Standards:** [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

**Last Updated:** 6 January 2026
**Status:** Ready for implementation
**Next Step:** Review with team → Create Figma mockups → User testing
