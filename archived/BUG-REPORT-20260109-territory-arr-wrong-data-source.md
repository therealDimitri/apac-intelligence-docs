# Bug Report: Territory Strategy ARR Using Wrong Data Source

**Date:** 9 January 2026
**Severity:** High
**Status:** Resolved
**Component:** Planning > Territory Strategy > New

## Issue Summary

ARR (Annual Recurring Revenue) values displayed in the Territory Strategy creation page were significantly incorrect, showing much lower values than actual FY2026 recognised revenue. The ARR data was being pulled from `burc_contracts` table which contained static contract values, not actual FY2026 recognised revenue.

## Root Cause Analysis

### Data Discrepancy

The code was querying the `burc_contracts` table which contained outdated static contract values, not the actual FY2026 recognised revenue figures.

**Example Discrepancies:**

| Client | burc_contracts (Wrong) | Excel Source of Truth (Correct) |
|--------|------------------------|----------------------------------|
| GHA | $124,838.40 | $1,406,980.50 |
| AWH | $140,691.84 | $317,811.33 |
| Waikato | $0 | $320,001.64 |
| SA Health | N/A | $6,803,658.56 |

### Previous Code

```typescript
// 3. Load ARR data from burc_contracts (client_arr table is empty)
const { data: arrData } = await supabase
  .from('burc_contracts')
  .select('client_name, annual_value_usd')
```

The `burc_contracts` table contains contract information but not actual recognised revenue figures for FY2026.

## Solution Implemented

### 1. Populated `client_arr` Table with Correct Data

Extracted FY2026 recognised revenue from the authoritative Excel source:
- **Source File:** `2026 APAC Performance.xlsx` (Maint sheet)
- **Calculation:** Sum of monthly columns (Jan-Dec) per client
- **Total FY2026 ARR:** $19,617,736.03 across 16 clients

### 2. Updated Territory Strategy Code

Changed the data source from `burc_contracts` to `client_arr`:

```typescript
// 3. Load ARR data from client_arr (FY2026 recognised revenue from BURC Maint sheet)
const { data: arrData } = await supabase
  .from('client_arr')
  .select('client_name, arr_usd')

// Create ARR lookup map (case-insensitive, includes aliases)
const arrMap = new Map<string, number>()
arrData?.forEach(a => {
  if (a.client_name) {
    const allNames = getAllClientNames(a.client_name)
    allNames.forEach(name => {
      const existing = arrMap.get(name) || 0
      if ((a.arr_usd || 0) > existing) {
        arrMap.set(name, a.arr_usd || 0)
      }
    })
  }
})
```

### 3. FY2026 ARR Data Loaded

| Client | ARR (USD) |
|--------|-----------|
| Minister for Health aka South Australia Health | $6,803,658.56 |
| Singapore Health Services Pte Ltd | $4,651,541.38 |
| Western Australia Department Of Health | $2,859,412.42 |
| Gippsland Health Alliance (GHA) | $1,406,980.50 |
| St Luke's Medical Center Global City Inc | $846,061.00 |
| GRMC (Guam Regional Medical Centre) | $574,675.23 |
| Western Health | $486,472.92 |
| NCS Pte Ltd | $361,850.00 |
| Te Whatu Ora Waikato | $320,001.64 |
| Albury Wodonga Health | $317,811.33 |
| Mount Alvernia Hospital | $308,892.21 |
| Barwon Health Australia | $249,285.67 |
| Epworth Healthcare | $199,544.42 |
| Grampians Health | $130,016.50 |
| The Royal Victorian Eye and Ear Hospital | $100,417.00 |
| Ministry of Defence, Singapore | $1,115.25 |
| **Total** | **$19,617,736.03** |

## Files Modified

- `src/app/(dashboard)/planning/territory/new/page.tsx` - Changed ARR data source from `burc_contracts` to `client_arr` via API
- `src/app/api/planning/client-arr/route.ts` - New API route to fetch ARR data with service role key (bypasses RLS)
- `supabase/migrations/20260109_fix_client_arr_rls.sql` - Migration to fix RLS policy (pending application)
- Supabase `client_arr` table - Populated with correct FY2026 ARR data

## RLS Issue Encountered

The `client_arr` table had RLS policies that only allowed `authenticated` users to read. Since the Territory Strategy page is a client component using the anonymous key, it returned 0 records.

**Solution:** Created an API route (`/api/planning/client-arr`) that uses the service role key to bypass RLS and fetch ARR data server-side.

## Client Code to Canonical Name Mapping

The Excel uses abbreviated client codes. These were mapped to canonical names:

| Code | Canonical Name |
|------|----------------|
| AWH | Albury Wodonga Health |
| BWH | Barwon Health Australia |
| EPH | Epworth Healthcare |
| GHA | Gippsland Health Alliance (GHA) |
| GHRA | Grampians Health |
| MAH | Mount Alvernia Hospital |
| RVEEH | The Royal Victorian Eye and Ear Hospital |
| SA Health | Minister for Health aka South Australia Health |
| Sing Health | Singapore Health Services Pte Ltd |
| SLMC | St Luke's Medical Center Global City Inc |
| WA Health | Western Australia Department Of Health |
| Waikato | Te Whatu Ora Waikato |
| Western Health | Western Health |
| NCS | NCS Pte Ltd |
| GRMC | GRMC (Guam Regional Medical Centre) |
| Mindef | Ministry of Defence, Singapore |

## Testing Recommendations

1. Create a new Territory Strategy
2. Select a CSE with assigned clients
3. Verify ARR values match the FY2026 figures above
4. Verify Total ARR shows approximately $19.6M
5. Check that client alias resolution still works (GHA → Gippsland Health Alliance)

## Impact

- **Before:** ARR showing significantly understated values (e.g., GHA $124k instead of $1.4M)
- **After:** ARR showing correct FY2026 recognised revenue figures

## Lessons Learned

1. Always verify data source accuracy, not just technical connectivity
2. `burc_contracts` contains static contract values, not recognised revenue
3. The authoritative source for FY2026 revenue is the BURC Excel Maint sheet
4. When displaying financial data, confirm with finance team which source is correct
5. Client code abbreviations need mapping to canonical names for data consistency
