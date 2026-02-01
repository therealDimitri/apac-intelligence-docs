# Bug Report: Total ARR Expand Not Working

**Date:** 2026-02-02
**Status:** Fixed
**Component:** BURC Executive Dashboard
**File:** `src/components/burc/BURCExecutiveDashboard.tsx`

## Issue

Clicking the Total ARR card ($29.9M) on the BURC Executive Dashboard did not expand to show the ARR breakdown by client. The card showed as expanded (active state) but no client data appeared.

## Root Cause

Two issues combined to cause this bug:

1. **RLS Policy Missing:** Row Level Security (RLS) was enabled on the `burc_historical_revenue_detail` table but no policies existed. This meant the anon key client (used by the dashboard) could not read any rows - RLS defaults to denying all access when no policies match.

2. **Aggregate Data in FY2026:** FY2026 only had aggregate entries like "APAC Total", "Baseline", "Hosting to APAC Profit Share" - not individual client data. The code found 4 rows but they were all aggregates, so no client breakdown could be displayed.

## Fix Applied

### 1. Added RLS Policies (Database Migration)

```sql
-- Allow authenticated read access
CREATE POLICY "Allow authenticated read access"
ON burc_historical_revenue_detail
FOR SELECT
TO authenticated
USING (true);

-- Allow anon read access (for dashboard)
CREATE POLICY "Allow anon read access"
ON burc_historical_revenue_detail
FOR SELECT
TO anon
USING (true);
```

### 2. Filter Aggregate Entries and Fallback to FY2025

```typescript
// Aggregate entries to exclude (not individual client data)
const aggregateNames = ['APAC Total', 'Total', 'Grand Total', 'All Clients', 'Baseline', 'Hosting to APAC Profit Share']

// First try current year, excluding aggregate entries
let { data: revenueData } = await supabase
  .from('burc_historical_revenue_detail')
  .select('client_name, amount_usd')
  .eq('fiscal_year', currentFY)
  .not('client_name', 'is', null)

// Filter out aggregate entries
if (revenueData) {
  revenueData = revenueData.filter(d => !aggregateNames.includes(d.client_name))
}

// If no individual client data for current year, try previous year
if (!revenueData || revenueData.length === 0) {
  const { data: fallbackData } = await supabase
    .from('burc_historical_revenue_detail')
    .select('client_name, amount_usd')
    .eq('fiscal_year', currentFY - 1)
    .not('client_name', 'is', null)
  revenueData = fallbackData?.filter(d => !aggregateNames.includes(d.client_name)) || null
}
```

## Verification

- FY2026: 4 rows raw → 0 after filtering (all aggregates)
- FY2025: 450 rows raw → 420 after filtering → 23 unique clients displayed
- Tested locally and on production (https://apac-cs-dashboards.com/burc)

## Lessons Learned

1. **Always check RLS policies** when client-side Supabase queries return 0 rows but direct SQL shows data exists
2. **Tables with RLS enabled but no policies** will block all access by default
3. **Aggregate entries** in revenue tables should be filtered when displaying client-level breakdowns

## Commit

`751652b2` - fix(BURC): Total ARR expand now shows client breakdown
