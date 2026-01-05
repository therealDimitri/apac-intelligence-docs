# Bug Report: NPS Score Card Restyle

**Date:** 5 January 2026
**Status:** ✅ Verified
**Component:** `src/components/cards/NPSScoreCard.tsx`

---

## Problem

The NPS Score card had inconsistent styling compared to other cards on the client detail page:

- Plain white background with no gradient header
- Icon in a coloured pill instead of directly in header
- Different card structure (`p-5` padding throughout vs header/content sections)
- Did not visually communicate NPS sentiment (good/bad) at a glance

### Screenshot (Before)
- White card with purple icon pill
- Trend badge in coloured background (emerald/red/gray)
- No visual indicator of NPS sentiment in card chrome

---

## Solution

Restyled the NPS Score card to match other dashboard cards (Revenue, Health Trend) with:

1. **Dynamic Gradient Header** based on NPS score
2. **White Pill Trend Badge** matching Revenue card style
3. **Proper Card Structure** with header/content sections
4. **Updated Skeleton** loading state

---

## Technical Changes

### File Modified
`src/components/cards/NPSScoreCard.tsx`

### New Function Added
```typescript
/**
 * Get gradient colours based on NPS score
 * Matches the design pattern of other cards (Revenue, Health Trend)
 */
function getNPSGradient(npsScore: number): string {
  if (npsScore >= 50) {
    return 'from-emerald-500 to-green-500' // Excellent
  } else if (npsScore >= 0) {
    return 'from-amber-500 to-yellow-500' // Good/Neutral
  } else {
    return 'from-red-500 to-rose-500' // Poor
  }
}
```

### Card Structure Change

**Before:**
```tsx
<div className="bg-white rounded-xl border border-gray-200 p-5">
  {/* Header inside white card */}
  <div className="flex items-center justify-between mb-4">
    <div className="h-8 w-8 rounded-lg" style={{ backgroundColor: purple50 }}>
      <MessageSquare />
    </div>
    ...
  </div>
  {/* Content */}
</div>
```

**After:**
```tsx
<div className="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm">
  {/* Gradient Header */}
  <div className={`px-4 py-2.5 bg-gradient-to-r ${gradient}`}>
    <MessageSquare className="text-white" />
    <h3 className="text-white">NPS Score</h3>
    {/* White pill trend badge */}
  </div>
  {/* Content */}
  <div className="p-4">
    ...
  </div>
</div>
```

### Trend Badge Change

**Before:** Coloured background pill (`bg-emerald-50 text-emerald-700`)

**After:** White pill with coloured text (matches Revenue card)
```tsx
<span className="bg-white text-xs font-semibold rounded-full shadow-sm">
  <TrendingUp className="h-3 w-3" />
  {trend > 0 ? '+' : ''}{trend}
</span>
```

---

## Gradient Colour Logic

| NPS Score | Gradient | Meaning |
|-----------|----------|---------|
| ≥ 50 | `from-emerald-500 to-green-500` | Excellent |
| 0 to 49 | `from-amber-500 to-yellow-500` | Good/Neutral |
| < 0 | `from-red-500 to-rose-500` | Poor |

---

## NPS Score Calculation

The gradient is based on the calculated NPS score:

```typescript
const npsScore = total > 0
  ? Math.round(((promoters - detractors) / total) * 100)
  : 0
```

For the example in the screenshot:
- Promoters: 0 (0%)
- Passives: 5 (45%)
- Detractors: 6 (55%)
- **NPS = 0% - 55% = -55** → Red gradient

---

## Skeleton Update

The loading skeleton was also updated to match the new structure:

```tsx
<div className="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm">
  {/* Gradient Header skeleton */}
  <div className="px-4 py-2.5 bg-gradient-to-r from-gray-300 to-gray-400 animate-pulse">
    ...
  </div>
  {/* Content skeleton */}
  <div className="p-4">
    ...
  </div>
</div>
```

---

## Design Consistency

The NPS Score card now matches the design pattern of:

| Card | Header Gradient Logic |
|------|----------------------|
| **Revenue** | Green (↑ YoY) / Red (↓ YoY) / Gray (flat) |
| **Health Trend** | Green (healthy) / Amber (at-risk) / Red (critical) |
| **NPS Score** | Green (≥50) / Amber (0-49) / Red (<0) |

---

## Verification

- ✅ Build passes
- ✅ TypeScript compilation successful
- ✅ User verified visual appearance
- ✅ Gradient correctly shows red for -55 NPS score

---

## Files Changed

| File | Change |
|------|--------|
| `src/components/cards/NPSScoreCard.tsx` | Restyled card with gradient header |

---

## Related

- Revenue card: `src/components/client/ClientRevenueCard.tsx`
- Health Trend card: `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
