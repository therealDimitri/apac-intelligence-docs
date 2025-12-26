# Bug Report: Working Capital Not Displaying for Aggregated Clients

**Date:** 2025-12-19
**Status:** Fixed
**Severity:** High
**Affected Clients:** SingHealth, GRMC, SLMC

## Problem Description

Working Capital Health data was not displaying for clients whose invoices are recorded under different entity names in the aging accounts system:

- **SingHealth**: Invoices recorded under "Singapore Health Services Pte Ltd", "Changi General Hospital", "National Cancer Centre Of Singapore Pte Ltd", etc.
- **GRMC**: Invoices recorded under "Strategic Asia Pacific Partners, Incorporated", "GUAM Regional Medical City"
- **SLMC**: Invoices recorded under "St Luke's Medical Center Global City Inc"

### Symptoms

1. Client profile Working Capital Health card showed "No aging data available for this client"
2. Health score calculation did not include Working Capital component (defaulting to 10/10)
3. Ageing Accounts Detailed View search returned no results when searching for "SingHealth", "GRMC", or "SLMC"

## Root Cause

1. **Database materialized view** (`client_health_summary`) joined `aging_accounts` on `client_name` instead of `client_name_normalized`, and did not aggregate related entities
2. **UI component** (`LeftColumn.tsx`) searched for exact client name matches without aggregation logic
3. **Ageing Accounts page** search filter did not recognize aggregation aliases

## Fix Applied

### 1. Database Migration (`docs/migrations/20251219_fix_aging_client_name_matching.sql`)

Updated the materialized view to:
- Join on `client_name_normalized` for mapped names
- Aggregate all related entities using ILIKE patterns
- Use SUM() to combine bucket amounts from multiple entities

```sql
-- Working Capital now aggregates all related entities
LEFT JOIN LATERAL (
  SELECT
    ...
  FROM aging_accounts a
  WHERE (
    a.client_name_normalized = c.client_name
    OR a.client_name = c.client_name
    OR (c.client_name = 'SingHealth' AND (
      a.client_name ILIKE '%Singapore%Health%'
      OR a.client_name ILIKE '%Singapore General Hospital%'
      ...
    ))
    OR (c.client_name ILIKE '%Guam%' AND ...)
    OR (c.client_name ILIKE '%Luke%' AND ...)
  )
  HAVING SUM(a.total_outstanding) IS NOT NULL
) working_capital_metrics ON true
```

### 2. UI Component (`src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`)

Added `isAggregatedClient()` function that recognizes related entities and aggregates their bucket data in the UI.

### 3. Ageing Accounts Page (`src/app/(dashboard)/aging-accounts/page.tsx`)

Added `matchesAggregatedClient()` function to the search filter so searching for "SingHealth" shows all Singapore hospitals.

## Results After Fix

| Client | Working Capital % | Total Outstanding | Health Score |
|--------|------------------|-------------------|--------------|
| SingHealth | 61% | $300,753.63 | 46 |
| GRMC | 83% | $1,063,915.01 | 59 |
| SLMC | 96% | $143,716.20 | 80 |

## Files Modified

- `docs/migrations/20251219_fix_aging_client_name_matching.sql` (new)
- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
- `src/app/(dashboard)/aging-accounts/page.tsx`

## Testing Checklist

- [x] SingHealth Working Capital card shows aggregated data
- [x] GRMC Working Capital card shows aggregated data
- [x] SLMC Working Capital card shows aggregated data
- [x] Health scores reflect Working Capital component
- [x] Ageing Accounts search for "SingHealth" shows all Singapore entities
- [x] Ageing Accounts search for "GRMC" shows GRMC and Strategic Asia Pacific
- [x] Ageing Accounts search for "SLMC" shows St Luke's variations
- [x] Build compiles without errors

## Prevention

For future clients with multiple billing entities, add entries to:
1. The SQL materialized view aggregation rules
2. The `isAggregatedClient()` function in `LeftColumn.tsx`
3. The `matchesAggregatedClient()` function in `aging-accounts/page.tsx`
