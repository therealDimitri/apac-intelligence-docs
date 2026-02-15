# Bug Fix: NPS Historical Trend Chart Not Displaying Data

**Date:** 2025-12-20
**Status:** Fixed
**Type:** Bug Fix
**Priority:** Medium

## Issue Description

The NPS Trend chart on the Analytics dashboard was only showing a single data point instead of historical NPS data, despite 199 NPS responses existing in the Supabase database.

### Root Cause

Two issues were identified:

1. **Trends API (`/api/analytics/trends`)**: The `analyzeNPSTrend` function was querying for `response_date` column, but NPS responses in Supabase use the `period` field (e.g., "Q4 24", "Q2 25") for historical organisation. The `response_date` column was often null.

2. **Dashboard API (`/api/analytics/dashboard`)**: The `fetchNPSAnalytics` function was attempting to call `.substring()` on `response_date` values that were null, causing a 500 error: `TypeError: Cannot read properties of null (reading 'substring')`.

## Solution

### Fix 1: Update Trends API (`src/app/api/analytics/trends/route.ts`)

- Modified `analyzeNPSTrend` to query NPS responses with `score, period, created_at` instead of `response_date, score`
- Added query to `nps_period_config` table for proper period ordering
- Created new `groupByPeriod` helper function that:
  - Groups NPS responses by `period` field
  - Falls back to `response_date` if period is unavailable
  - Parses period codes (e.g., "Q4 24") to generate proper date ordering
  - Sorts periods chronologically

### Fix 2: Update Dashboard API (`src/app/api/analytics/dashboard/route.ts`)

- Modified NPS monthly trend calculation to:
  - Use `period` field as primary grouping key
  - Fall back to `response_date` only if available
  - Skip records with no date/period data
  - Sort periods chronologically using quarter parsing logic

### Fix 3: Update TrendAnalysisChart Component (`src/components/TrendAnalysisChart.tsx`)

- Added `label` field to `TrendPoint` interface for period labels
- Updated X-axis labels to display period names (e.g., "Q4 24") instead of parsed dates
- Updated forecast label text to say "periods" instead of "weeks" for NPS data

## Files Modified

```
src/app/api/analytics/trends/route.ts
src/app/api/analytics/dashboard/route.ts
src/components/TrendAnalysisChart.tsx
```

## Testing

1. Navigate to `/meetings` and click the "Analytics" tab
2. Verify NPS Trend chart displays multiple data points
3. Verify X-axis shows period labels (e.g., "2023", "Q4 24", "Q4 25")
4. Verify Current Value and Growth Rate are calculated correctly
5. Verify forecast checkbox shows "periods" instead of "weeks"

## NPS Data Structure Reference

The `nps_responses` table in Supabase has:
- `score` (integer): NPS score 0-10
- `period` (text): Quarterly period like "Q4 24", "Q2 25"
- `response_date` (unknown/null): Often null
- `created_at` (text): Record creation timestamp

The `nps_period_config` table provides:
- `period_code` (text): Period identifier
- `sort_order` (integer): Chronological order
- `survey_start_date` (text): Survey date for the period

## Verification Screenshot

NPS Trend chart now displays:
- Multiple quarterly data points on X-axis
- Proper Y-axis scale (4.0 to 8.0)
- Current Value: 6.9
- Growth Rate: +2.5%
- Trend: Stable
- Key insights about NPS performance
