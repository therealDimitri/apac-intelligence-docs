# Bug Report: Historical Client Revenue Data Sync from APAC Revenue 2019-2024.xlsx

**Date:** 2026-01-07
**Status:** Resolved
**Priority:** High
**Component:** BURC Historical Revenue / Financial Analytics

---

## Issue Summary

The `burc_historical_revenue_detail` table contained only ~40-60% of the actual client revenue data for years 2019-2024. The authoritative source file "APAC Revenue 2019 - 2024.xlsx" had not been synced to the database.

---

## Root Cause

**Two issues identified:**

### Issue 1: Missing Data Source
The database had 38,802 records with `source_file = null`, populated from an unknown source with incomplete data. The authoritative Excel file "APAC Revenue 2019 - 2024.xlsx" had never been synced.

### Issue 2: Client Name Mismatch
Excel client names didn't match database canonical names:

| Excel Name | Database Canonical Name |
|------------|------------------------|
| Minister for Health aka South Australia Health | SA Health (iPro) |
| Singapore Health Services Pte Ltd | SingHealth |
| Strategic Asia Pacific Partners, Incorporated | Guam Regional Medical City (GRMC) |
| NCS PTE Ltd | NCS/MinDef Singapore |
| St Luke's Medical Center Global City Inc | Saint Luke's Medical Centre (SLMC) |
| Western Australia Department Of Health | WA Health |
| Waikato District Health Board | Te Whatu Ora Waikato |

---

## Data Discrepancy Before Fix

| Year | Expected (Excel) | Database (Before) | Gap |
|------|-----------------|-------------------|-----|
| 2019 | $23.92M | $13.55M | -$10.37M (44%) |
| 2020 | $24.12M | $17.06M | -$7.06M (29%) |
| 2021 | $28.98M | $9.64M | -$19.34M (67%) |
| 2022 | $28.08M | $12.29M | -$15.79M (56%) |
| 2023 | $28.88M | $15.88M | -$13.00M (45%) |
| 2024 | $33.04M | $1.07M | -$31.97M (97%) |

---

## Solution Implemented

### New Sync Script

Created `scripts/sync-historical-revenue-from-excel.mjs` to:

1. Read "APAC Revenue 2019 - 2024.xlsx" Customer Level Summary sheet
2. Map Excel client names to database canonical names
3. Extract revenue by year and revenue type
4. Insert records with `source_file = 'APAC Revenue 2019 - 2024.xlsx'`

### Client Name Mapping

```javascript
const CLIENT_NAME_MAP = {
  'Minister for Health aka South Australia Health': 'SA Health (iPro)',
  'Singapore Health Services Pte Ltd': 'SingHealth',
  'Strategic Asia Pacific Partners, Incorporated': 'Guam Regional Medical City (GRMC)',
  'NCS PTE Ltd': 'NCS/MinDef Singapore',
  'St Luke\'s Medical Center Global City Inc': 'Saint Luke\'s Medical Centre (SLMC)',
  'Western Australia Department Of Health': 'WA Health',
  'Waikato District Health Board': 'Te Whatu Ora Waikato',
  // ... and others
};
```

---

## Data After Fix

| Year | Excel Source (Synced) | Match |
|------|----------------------|-------|
| 2019 | $23.92M | ✓ |
| 2020 | $24.12M | ✓ |
| 2021 | $28.98M | ✓ |
| 2022 | $28.08M | ✓ |
| 2023 | $28.88M | ✓ |
| 2024 | $33.04M | ✓ |

**250 records inserted** with correct client name mappings.

---

## Files Created/Modified

| File | Purpose |
|------|---------|
| `scripts/sync-historical-revenue-from-excel.mjs` | Main sync script |
| `scripts/compare-revenue.mjs` | Comparison tool for auditing |
| `scripts/verify-revenue-totals.mjs` | Verification script |
| `scripts/check-sa-health-revenue.mjs` | Client-specific debug script |

---

## Usage

### Dry Run (Preview Only)
```bash
node scripts/sync-historical-revenue-from-excel.mjs --dry-run
```

### Full Sync
```bash
node scripts/sync-historical-revenue-from-excel.mjs
```

---

## Source File Location

```
OneDrive-AlteraDigitalHealth/
  APAC Leadership Team - General/
    Performance/
      Financials/
        BURC/
          APAC Revenue 2019 - 2024.xlsx    ← Authoritative source
```

### Worksheet Structure

- **Customer Level Summary** - Pivot table with client revenue by year
  - Column A: Parent Company
  - Column B: Customer Name
  - Column C: Altera PnL Rollup (revenue type)
  - Columns D-I: Years 2019-2024
  - Column J: Grand Total

- **Data** - 84,901 raw GL transaction records

---

## Verification

```bash
# Verify totals match
node scripts/verify-revenue-totals.mjs

# Compare Excel vs Database
node scripts/compare-revenue.mjs
```

---

## Lessons Learned

1. **Source verification**: Always verify database data against authoritative Excel sources
2. **Client name mapping**: Maintain explicit mappings between source names and canonical names
3. **Source tracking**: Use `source_file` column to track data provenance
4. **Dry-run first**: Always test with `--dry-run` before making changes

---

## Related Files

- `burc_historical_revenue_detail` table - Historical client revenue
- `client_name_aliases` table - Client name mapping
- `src/lib/client-logos-local.ts` - Logo mappings with canonical names
