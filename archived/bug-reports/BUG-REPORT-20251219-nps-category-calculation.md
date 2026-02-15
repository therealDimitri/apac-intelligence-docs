# Bug Report: NPS Category Calculation Using Database Field Instead of Score

**Date**: 2025-12-19
**Status**: RESOLVED
**Severity**: High
**Component**: NPS Data Hooks - Category Calculation

---

## Issue Summary

NPS promoter/passive/detractor counts were being calculated by filtering on a `category` database field which may not be populated correctly, instead of calculating the category from the actual NPS score.

## Symptoms

- Incorrect NPS scores displayed (e.g., -67 when it should be different)
- Promoter/Passive/Detractor counts didn't match expected values based on scores
- Inconsistent NPS data across different views

## Root Cause

Multiple hooks were relying on the `response.category` field from the database instead of calculating the category from the `response.score` using standard NPS methodology:

- Score 9-10 = Promoter
- Score 7-8 = Passive
- Score 0-6 = Detractor

**Affected Files:**

1. `src/hooks/useNPSAnalysis.ts` - `useNPSTrend` function
2. `src/hooks/useNPSData.ts` - Multiple filter operations

**Before (incorrect):**

```typescript
const currentPromoters = responses.filter(r => r.category === 'promoter').length
const currentDetractors = responses.filter(r => r.category === 'detractor').length
```

**After (correct):**

```typescript
// Helper functions added
function isPromoter(r: { score: number }): boolean {
  return r.score >= 9
}
function isPassive(r: { score: number }): boolean {
  return r.score >= 7 && r.score < 9
}
function isDetractor(r: { score: number }): boolean {
  return r.score < 7
}

// Usage
const currentPromoters = responses.filter(isPromoter).length
const currentDetractors = responses.filter(isDetractor).length
```

## Changes Made

### 1. useNPSAnalysis.ts

- Updated `useNPSTrend` function to calculate categories from score instead of relying on database field

### 2. useNPSData.ts

- Added helper functions: `getNPSCategory()`, `isPromoter()`, `isPassive()`, `isDetractor()`
- Updated all category filter operations to use helper functions
- Fixed 6 instances of category filtering

## Impact

- NPS scores now accurately reflect the true promoter/detractor breakdown
- Consistent NPS calculation across all client profile views
- Client NPS cards show correct category counts

## Verification

After fix:

- NPS score is calculated as: `((Promoters - Detractors) / Total) * 100`
- Categories are determined solely from score values
- All views use the same calculation methodology

---

## Standard NPS Methodology Reference

| Score | Category  |
| ----- | --------- |
| 9-10  | Promoter  |
| 7-8   | Passive   |
| 0-6   | Detractor |

**NPS Formula:** `NPS = (% Promoters) - (% Detractors)`

---

## Lessons Learned

1. **Never rely on pre-calculated fields** - Always calculate from source data when possible
2. **Standard methodology** - Use industry-standard NPS score ranges consistently
3. **Single source of truth** - Category calculation should be centralized in helper functions
