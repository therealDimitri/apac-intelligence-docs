# Bug Report: Total ARR Card Not Expanding

**Date**: 7 January 2026
**Status**: Fixed
**Severity**: Medium
**Component**: BURC Executive Dashboard

## Issue

The Total ARR card on the Executive Dashboard was not displaying client breakdown when expanded. Clicking the expand button showed an empty list.

## Root Cause

The ARR by client data was being fetched from the `burc_client_maintenance` table which was completely empty (0 rows). This table was never populated.

**Original Code** (lines 396-420):
```typescript
const { data: maintenanceData } = await supabase
  .from('burc_client_maintenance')
  .select('client_name, annual_total')
  .eq('category', 'Backlog')
  .neq('client_name', 'Lost')
  .neq('client_name', 'Bus Case')
  .order('annual_total', { ascending: false })
```

## Solution

Modified the code to fetch ARR data from `burc_historical_revenue_detail` table instead, which contains revenue data for FY2019-2025 with 17 active clients.

**Fixed Code**:
```typescript
// Fetch ARR by client from burc_historical_revenue_detail
// Uses the most recent fiscal year with data (2025 or current year)
const currentFY = new Date().getFullYear()

// First try current year, then fallback to previous year
let { data: revenueData } = await supabase
  .from('burc_historical_revenue_detail')
  .select('client_name, amount_usd')
  .eq('fiscal_year', currentFY)
  .not('client_name', 'is', null)

// If no data for current year, try previous year
if (!revenueData || revenueData.length === 0) {
  const { data: fallbackData } = await supabase
    .from('burc_historical_revenue_detail')
    .select('client_name, amount_usd')
    .eq('fiscal_year', currentFY - 1)
    .not('client_name', 'is', null)
  revenueData = fallbackData
}
```

## Files Modified

- `src/components/burc/BURCExecutiveDashboard.tsx` - Updated ARR by client query

## Data Verification

**burc_historical_revenue_detail (FY2025)**:
| Client | ARR |
|--------|-----|
| SA Health (iPro) | $10.51M |
| SingHealth | $4.45M |
| Gippsland Health Alliance | $3.04M |
| Saint Luke's Medical Centre | $1.91M |
| WA Health | $1.76M |
| Guam Regional Medical City | $1.32M |
| NCS/MinDef Singapore | $0.51M |
| Parkway Hospitals Singapore | $0.44M |
| Barwon Health Australia | $0.43M |
| Mount Alvernia Hospital | $0.35M |
| And 7 more clients... | |

**Total: 17 clients with $26.4M total ARR**

## Testing

1. Navigate to BURC Performance > Executive Summary
2. Click on the Total ARR card to expand
3. Verify client breakdown displays with correct values

## Notes

- The `burc_client_maintenance` table remains empty but is no longer used
- FY2026 data will be used automatically when available
- Fallback to FY2025 ensures the card always has data to display
