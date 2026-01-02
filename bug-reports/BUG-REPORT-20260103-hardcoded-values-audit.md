# Bug Report: Dashboard Hardcoded Values & Data Integrity Audit

**Date:** 3 January 2026
**Severity:** High
**Status:** Documented - Awaiting Remediation
**Scope:** Platform-wide dashboard components

---

## Executive Summary

A comprehensive audit of dashboard components identified **16 issues** across the platform where hardcoded values, mock data, or inconsistent data sources may cause:
- Inaccurate metrics displayed to users
- Data that doesn't reconcile between pages
- Styling inconsistencies affecting UX
- Missing real data masked by fallback values

---

## Critical Issues (Immediate Action Required)

### 1. NPS Analysis Page - Entirely Mock Data
**File:** `src/app/(dashboard)/clients/[clientId]/nps-analysis/page.tsx`
**Lines:** 19-26

**Problem:** Complete mock NPS quarterly data with hardcoded values:
```typescript
const npsTrendData = [
  { period: 'Q1 2024', averageScore: 7.2, totalResponses: 12, promoters: 5, passives: 4, detractors: 3 },
  { period: 'Q2 2024', averageScore: 7.8, totalResponses: 18, promoters: 10, passives: 5, detractors: 3 },
  // ... all mock
]
```

**Impact:** Users see fake NPS trends regardless of actual client data

**Fix Required:**
```typescript
// Replace with real query
const { data: npsTrendData } = useQuery({
  queryKey: ['nps-trends', clientId],
  queryFn: () => supabase
    .from('nps_responses')
    .select('score, period, response_date')
    .eq('client_name', clientName)
    .order('response_date', { ascending: true })
});

// Aggregate into quarters
const quarterlyData = aggregateNPSByQuarter(npsTrendData);
```

---

### 2. Portfolio Page - Hardcoded Progress Metrics
**File:** `src/app/(dashboard)/clients/[clientId]/portfolio/page.tsx`
**Lines:** 40-83

**Problem:** Static portfolio progress data shows same metrics for ALL clients:
```typescript
const portfolioProgressData = [
  { category: 'Training', year2024Completed: 4, year2024Total: 4, ... },
  { category: 'Integration', year2024Completed: 2, year2024Total: 3, ... },
  // ... all hardcoded
]
```

**Impact:** All clients appear to have identical initiative progress

**Fix Required:** Use `usePortfolioInitiatives` hook with real database aggregation

---

### 3. Forecast Section - Hardcoded Fallback Values
**File:** `src/app/(dashboard)/clients/[clientId]/components/ForecastSection.tsx`
**Lines:** 40, 69

**Problem:** Multiple hardcoded fallback percentages:
- Line 40: `const baseRenewal = client.health_score ? Math.min(95, client.health_score) : 75`
- Line 69: `Math.round(prediction.predicted_year_end_score || 75)`
- Line 70: Hardcoded multiplier `0.8`

**Impact:** Missing prediction data masked by "reasonable" defaults

**Fix Required:** Show "No data" state instead of fake numbers

---

## High Priority Issues

### 4. Segment Section - Estimated Growth Rate
**File:** `src/app/(dashboard)/clients/[clientId]/components/SegmentSection.tsx`
**Line:** 84

**Problem:** Hardcoded 15% default growth rate when BURC data unavailable
```typescript
const growthRate = growthPercentage ??
  (client.health_score ? Math.max(0, Math.min(30, (client.health_score - 50) / 2)) : 15)
```

**Impact:** Clients without BURC data show invented growth metrics

---

### 5. NPS Trends Section - Synthetic History
**File:** `src/app/(dashboard)/clients/[clientId]/components/NPSTrendsSection.tsx`
**Lines:** 42-55

**Problem:** Generates fake 6-month NPS history:
```typescript
const variation = ((i % 3) - 1) * 5 // Deterministic variation pattern
const score = Math.round((currentNPS - 15) + trend + variation)
```

**Impact:** Users see synthetic trends, not real data

---

### 6. Quick Actions Footer - Default CSE Email
**File:** `src/app/(dashboard)/clients/[clientId]/components/QuickActionsFooter.tsx`
**Line:** 160

**Problem:** `const cseEmail = client.cse_name || 'support@company.com'`

**Impact:** Generic email used when CSE data missing

---

## Medium Priority Issues

### 7. Settings Page - Hardcoded Card Config
**File:** `src/app/(dashboard)/settings/page.tsx`
**Lines:** 14-37

Should use feature flags from Supabase instead of hardcoded array.

---

### 8. Segmentation Page - Hardcoded Segment Config
**File:** `src/app/(dashboard)/segmentation/page.tsx`
**Lines:** 54-100

Segment colours/icons should be in centralised design tokens.

---

### 9. KPI Card - Hardcoded Colour Hex Values
**File:** `src/app/(dashboard)/aging-accounts/compliance/components/KPICard.tsx`
**Lines:** 59-64

```typescript
const statusColours = {
  healthy: '#16A34A',    // Should use design token
  warning: '#F59E0B',
  critical: '#DC2626',
  neutral: '#6B7280',
}
```

---

### 10. Data Insights Widget - Hardcoded Gradients
**File:** `src/components/dashboard/DataInsightsWidgets.tsx`

Multiple hardcoded Tailwind colour classes throughout component.

---

## Data Source Inconsistencies

### Issue: NPS Data Calculated 3 Different Ways

| Component | Source | Method |
|-----------|--------|--------|
| NPSTrendsSection | `useNPSData()` | Hook with synthetic fallback |
| NPS Analysis Page | Hardcoded mock | Static array |
| HealthBreakdown | `client.nps_score` | Direct property |

**Result:** Same metric shows different values on different pages!

---

### Issue: Forecast Probability Fallback Chain

```
1. Real prediction from useCompliancePredictions (preferred)
   ↓ (if missing)
2. Health score-based estimation
   ↓ (if missing)
3. Hardcoded 75%
```

Complex fallback logic masks data quality issues.

---

## Styling Inconsistencies

| Issue | Location | Problem |
|-------|----------|---------|
| Colour scheme varies | Multiple components | No centralised design tokens |
| Spacing inconsistent | Dashboard sections | Mixed `p-3`, `p-4`, `px-6 py-4` |
| Button colours hardcoded | QuickActionsFooter | Purple/blue/green/yellow/gray inline |

---

## Remediation Plan

### Phase 1: Critical Data Fixes (Week 1)

| Task | File | Effort | Priority |
|------|------|--------|----------|
| Replace NPS mock data | nps-analysis/page.tsx | Medium | CRITICAL |
| Replace Portfolio mock data | portfolio/page.tsx | Medium | CRITICAL |
| Remove forecast fallbacks | ForecastSection.tsx | Low | HIGH |

### Phase 2: Data Unification (Week 2)

| Task | Description | Effort |
|------|-------------|--------|
| Create `useNPSTrends()` | Single NPS hook for all components | Medium |
| Create `useClientForecast()` | Real predictions, proper error states | Medium |
| Create `usePortfolioProgress()` | Real initiative aggregation | Medium |

### Phase 3: Design System (Week 3)

| Task | Description | Effort |
|------|-------------|--------|
| Create `design-tokens.ts` | Centralise colours, spacing | Medium |
| Update components | Use tokens instead of hardcoded | High |
| Add Storybook | Document design system | Medium |

---

## Validation Checklist

Before each release, verify:

- [ ] Run `npm run validate-schema` - no column mismatches
- [ ] Check NPS values match between NPS Analytics page and client profiles
- [ ] Verify forecast percentages come from real predictions
- [ ] Confirm portfolio progress varies by client
- [ ] Check no "support@company.com" appearing in UI
- [ ] Verify colour scheme consistent across pages

---

## Supabase Tables Reference

| Table | Used For | Components |
|-------|----------|------------|
| `nps_responses` | NPS trends, scores | NPSTrendsSection, NPS Analysis |
| `portfolio_initiatives` | Initiative progress | Portfolio page |
| `compliance_predictions` | Forecast probabilities | ForecastSection |
| `burc_historical_revenue_detail` | Growth rates | SegmentSection |
| `cse_profiles` | CSE contact info | QuickActionsFooter |
| `feature_flags` | Feature availability | Settings page |

---

## Summary

**Total Issues Found:** 16
- Critical: 3
- High: 3
- Medium: 4
- Low: 6

**Root Causes:**
1. Rapid prototyping with mock data not replaced
2. No centralised design system
3. Missing error states causing fallback to hardcoded values
4. Multiple data sources for same metrics

**Estimated Remediation Effort:** 2-3 weeks
