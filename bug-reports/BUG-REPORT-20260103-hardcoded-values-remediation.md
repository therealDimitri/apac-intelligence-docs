# Bug Report: Hardcoded Values Remediation

**Date:** 3 January 2026
**Severity:** Critical (Remediation)
**Status:** Resolved
**Related Audit:** BUG-REPORT-20260103-hardcoded-values-audit.md

---

## Summary

This report documents the remediation of 4 critical/high priority issues identified in the hardcoded values audit.

---

## Issues Fixed

### 1. NPS Analysis Page - Mock Data Replaced ✅
**File:** `src/app/(dashboard)/clients/[clientId]/nps-analysis/page.tsx`

**Before:**
```typescript
// Mock NPS Trend Data - Replace with real aggregated data from Supabase
const npsTrendData = [
  { period: 'Q1 2024', averageScore: 7.2, totalResponses: 12, promoters: 5, passives: 4, detractors: 3 },
  // ... hardcoded mock data
]
```

**After:**
```typescript
// Use real NPS trend data from Supabase
const { trendData: npsTrendData, loading: trendLoading, error: trendError } = useNPSTrend(client?.name || '')
```

**Changes:**
- Imported and now using `useNPSTrend` hook from `useNPSAnalysis.ts`
- Added loading state with spinner
- Added error state with message display
- Added empty state for clients without NPS data
- Proper null-checking for `latestPeriod` values

---

### 2. Portfolio Page - Mock Progress Data Replaced ✅
**File:** `src/app/(dashboard)/clients/[clientId]/portfolio/page.tsx`

**Before:**
```typescript
const portfolioProgressData = [
  { category: 'Training', year2024Completed: 4, year2024Total: 4, ... },
  { category: 'Integration', year2024Completed: 2, year2024Total: 3, ... },
  // ... static hardcoded data
]
```

**After:**
```typescript
// Calculate Portfolio Progress Chart Data from real initiatives
const portfolioProgressData = (() => {
  const categoryMap = new Map<string, { ... }>()

  initiatives.forEach(initiative => {
    const { category, year, status } = initiative
    // ... real aggregation logic
  })

  return Array.from(categoryMap.entries())
    .map(([category, data]) => ({ category, ...data }))
    .sort((a, b) => (b.year2024Total + b.year2025Total) - (a.year2024Total + a.year2025Total))
})()
```

**Changes:**
- Category progress now calculated from real `initiatives` data
- Added `isLoading` prop destructuring from hook
- Added loading spinner state
- Added empty state for clients without portfolio initiatives
- Proper fragment wrapping for conditional rendering

---

### 3. Forecast Section - Fallback Values Removed ✅
**File:** `src/app/(dashboard)/clients/[clientId]/components/ForecastSection.tsx`

**Before:**
```typescript
// Fallback values based on health score
const baseRenewal = client.health_score ? Math.min(95, client.health_score) : 75
const renewalProb = Math.round(prediction.predicted_year_end_score || 75)
```

**After:**
```typescript
// No prediction data available - return nulls to show "No data" state
if (!prediction) {
  return {
    renewalProbability: null,
    expansionProbability: null,
    attritionRisk: null,
    // ...
    hasPrediction: false,
    isEstimated: false,
  }
}

// Use real prediction data - only if predicted_year_end_score exists
const hasPredictedScore = prediction.predicted_year_end_score !== null && prediction.predicted_year_end_score !== undefined
const renewalProb = hasPredictedScore ? Math.round(prediction.predicted_year_end_score!) : null
```

**Changes:**
- Removed all hardcoded fallback percentages (75%, 0.8 multiplier)
- Added `hasForecastData` boolean for empty state detection
- Health indicator now shows "Insufficient Data" when no prediction
- Renewal date shows source label (BURC/Compliance) when available
- Proper null handling for all forecast metrics
- ARR projection shows "No forecast" when data missing

---

### 4. NPS Trends Section - Synthetic History Removed ✅
**File:** `src/app/(dashboard)/clients/[clientId]/components/NPSTrendsSection.tsx`

**Before:**
```typescript
// Generate 6 months of data with variation around current score (deterministic)
for (let i = 0; i < 6; i++) {
  const trend = (i / 5) * (currentNPS - (currentNPS - 15))
  const variation = ((i % 3) - 1) * 5 // Deterministic variation pattern
  const score = Math.round((currentNPS - 15) + trend + variation)
  months.push({ ... })
}
```

**After:**
```typescript
// Only use real NPS data if available
if (clientScores && clientScores.length > 0) {
  const clientNPS = clientScores.find(c => c.name.toLowerCase() === client.name.toLowerCase())
  if (clientNPS?.trendData && clientNPS.trendData.length > 0) {
    return clientNPS.trendData.slice(-6).map(...)
  }
}

// No synthetic data - return empty array to show "No data" state
return []
```

**Changes:**
- Removed synthetic 6-month history generation
- Added proper empty state UI with BarChart3 icon
- Shows current NPS score even when no trend data
- Clear messaging about when data will appear

---

## Commits

- `15d8a2e` - fix: replace hardcoded values with real data and proper empty states

---

## Validation

After deploying, verify:

1. **NPS Analysis Page:**
   - Navigate to a client with NPS data - should show real quarterly trends
   - Navigate to a client without NPS data - should show "No NPS Data Available"

2. **Portfolio Page:**
   - Client with initiatives - chart should reflect actual category breakdown
   - Client without initiatives - should show "No Portfolio Initiatives"

3. **Forecast Section:**
   - Client with ML prediction - should show real probabilities
   - Client without prediction - should show "Insufficient Data" for health forecast

4. **NPS Trends Section:**
   - Client with trend data - should show real 6-month history
   - Client without trend data - should show "No Trend Data Available"

---

## Remaining Items from Audit

The following items from the original audit (BUG-REPORT-20260103-hardcoded-values-audit.md) are **not yet addressed**:

### Medium Priority (Future Work):
- Settings page hardcoded card config (should use feature flags)
- Segmentation page hardcoded segment config (should use design tokens)
- KPICard hardcoded colour hex values (should use design tokens)
- DataInsightsWidgets hardcoded gradients (should use design tokens)

### Design System (Future Work):
- Create centralised `design-tokens.ts` file
- Update all components to use tokens instead of inline colours
- Add Storybook for design system documentation

---

## Author

Claude AI - Code remediation and documentation
