# 2026 Forecast Opportunities in Pipeline Card

**Date:** 2026-01-19
**Commit:** 8e2b75f6
**Type:** Enhancement
**Status:** Completed

## Summary

Added planned close dates for 2026 forecast opportunities to the Pipeline card on the Executive Dashboard. The opportunities are sourced from the APAC 2026 Sales Budget Excel import stored in the `sales_pipeline_opportunities` Supabase table.

## Changes Made

### File: `src/components/burc/BURCExecutiveDashboard.tsx`

1. **Added ForecastOpportunity Interface** (lines 81-91):
   - Defined interface for forecast opportunity data with fields:
     - `id`, `opportunity_name`, `account_name`, `close_date`
     - `total_acv`, `weighted_acv`, `fiscal_period`
     - `forecast_category`, `cse_name`

2. **Added State for Forecast Opportunities** (line 247-248):
   - New state: `forecastOpportunities` to store opportunities in the 2026 forecast

3. **Added Fetch Logic** (lines 411-423):
   - Queries `sales_pipeline_opportunities` table
   - Filters by `in_or_out = 'In'` (opportunities in the forecast)
   - Orders by `close_date` ascending (nulls last)
   - Selects relevant fields for display

4. **Added Opportunities List UI** (lines 1122-1171):
   - New section in Pipeline card expanded view
   - Displays each opportunity with:
     - Client name (account_name)
     - Opportunity name
     - Total ACV value formatted as currency
     - Close date in Australian format (e.g., "15 Mar 2026")
     - Fiscal period badge (e.g., "Q1-2026")
     - CSE name when available
   - Scrollable container with max height of 256px

## Data Source

- **Table:** `sales_pipeline_opportunities`
- **Original Source:** APAC 2026 Sales Budget 14Jan2026 v0.1.xlsx
- **Migration:** `supabase/migrations/20260110_sales_budget_pipeline.sql`

## Visual Design

- Header: "2026 FORECAST OPPORTUNITIES" with calendar icon
- Cards: White background with cyan border, hover effect
- Layout: Two-column with client/opportunity on left, value/date on right
- Badges: Cyan for fiscal period, grey for CSE name
- Date format: Australian (DD Mon YYYY)

## Testing

- Build passes without TypeScript errors
- Pushed to main branch, triggers Netlify deployment
- UI displays in Pipeline card expanded view when opportunities exist

## Related Files

- `supabase/migrations/20260110_sales_budget_pipeline.sql` - Table schema
- `src/app/api/pipeline/2026/route.ts` - Alternative API endpoint for Excel direct read
