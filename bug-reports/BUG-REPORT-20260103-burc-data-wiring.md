# Bug Report: BURC Dashboard Data Connection

**Date:** 3 January 2026
**Status:** Fixed
**Priority:** High

## Summary

The BURC Performance (Financials) dashboard was not displaying data from the comprehensive BURC sync that captured 3,875+ records across 14+ tables from all BURC source files (2023-2026).

## Root Cause

The API route `/api/analytics/burc/route.ts` was querying old/incorrect table names that didn't match the newly synced BURC data tables:

| Old Table Name | New Table Name |
|----------------|----------------|
| `burc_ebita_monthly` | `burc_monthly_metrics` |
| `burc_quarterly` | `burc_quarterly_data` |
| `burc_client_maintenance` | `burc_revenue_detail` (filtered by type) |
| `burc_ps_pipeline` | `burc_pipeline_detail` + `burc_business_cases` |
| `burc_revenue_streams` | `burc_revenue_detail` (grouped by type) |
| `client_name` | `customer_name` (in historical_revenue) |
| `fy19_revenue` | `year_2019` (in historical_revenue) |

## Changes Made

### 1. Updated API Route Interfaces

Updated `src/app/api/analytics/burc/route.ts`:

```typescript
// Updated MonthlyMetric interface
interface MonthlyMetric {
  fiscal_year: number
  month_num: number
  month_name: string
  metric_name: string
  metric_category: string
  value: number
  source_file: string
}

// Updated HistoricalRevenue interface
interface HistoricalRevenue {
  id: number
  parent_company: string
  customer_name: string  // Not client_name
  revenue_type: string
  year_2019: number      // Not fy19_revenue
  year_2020: number
  // ... etc
}
```

### 2. Updated Table Queries

- **EBITA Section**: Now queries `burc_monthly_metrics` and filters for EBITA-related metrics
- **Waterfall Section**: Added fallback logic for missing fiscal year data
- **Quarterly Section**: Now queries `burc_quarterly_data`
- **Maintenance Section**: Queries `burc_revenue_detail` filtered by `revenue_type = 'Maint'`
- **Pipeline Section**: Combines `burc_pipeline_detail` and `burc_business_cases`
- **Revenue Streams**: Aggregates from `burc_revenue_detail` grouped by type
- **Historical Revenue**: Maps database columns to frontend-expected format

### 3. Added Data Transformation

For historical revenue, added transformation to maintain frontend compatibility:

```typescript
const clients = historical.map(h => ({
  client_code: h.customer_name?.substring(0, 10) || '',
  client_name: h.customer_name || '',
  parent_company: h.parent_company || '',
  fy19: h.year_2019 || 0,
  fy20: h.year_2020 || 0,
  // ... etc
}))
```

### 4. Fixed Waterfall Data

Updated NULL fiscal_year values in `burc_waterfall` table:

```sql
UPDATE burc_waterfall SET fiscal_year = 2026 WHERE fiscal_year IS NULL;
```

## Data Verification

After fix, all data sections return correctly:

| Table | Records (FY26) |
|-------|----------------|
| Monthly Metrics | 966 |
| Waterfall | 13 |
| Quarterly | 78 |
| Revenue Detail | 182 |
| Historical Revenue | 65 |
| Attrition | 22 |
| Business Cases | 121 |

## Files Modified

- `src/app/api/analytics/burc/route.ts` - Main API route with all data queries

## Testing

1. Dev server started on port 3002
2. Navigated to `/financials` page
3. Verified API returns 200 OK for all sections
4. Confirmed dashboard displays connected data
5. CSI ratios and insights generating correctly

## Prevention

- Always verify table names exist in database before updating queries
- Run `npm run introspect-schema` after migrations to update schema docs
- Test API endpoints with database verification scripts before UI testing
