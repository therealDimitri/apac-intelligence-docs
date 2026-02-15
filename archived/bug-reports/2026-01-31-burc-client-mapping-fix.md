# Bug Report: BURC Client ARR Mapping Errors

**Date:** 2026-01-31
**Severity:** High
**Status:** Resolved

## Summary

Client ARR values from BURC data were incorrect due to:
1. Missing client codes in the sync script
2. Incorrect CLIENT_MAPPING target names in the update script
3. Not properly handling the pivot table structure (summary vs data sections)

## Symptoms

- WA Health showing $2.8M instead of $3.5M (missing "Lost" category revenue)
- Grampians Health showing $130k instead of $1.2M (was receiving GHA Regional's data)
- Gippsland Health Alliance showing $1.4M instead of $130k (was receiving Grampians' data)
- Albury Wodonga Health, Mount Alvernia Hospital, NCS Pte Ltd showing no ARR

## Root Cause

### 1. Pivot Table Structure Not Handled

The "Maint Pivot" sheet has two sections:
- **Rows 1-5**: Summary totals (categories as column headers)
- **Rows 7+**: Data section (categories as row headers, clients nested underneath)

The sync script was hitting category headers in both sections, causing incorrect categorisation. The "Lost" category at Row 5 (summary) was being processed instead of the "Lost" at Row 132 (data section).

### 2. CLIENT_MAPPING Mismatches

The `update-client-arr-from-burc.mjs` had incorrect target names:

| BURC Name | Old Mapping | Correct Mapping |
|-----------|-------------|-----------------|
| WA Health | Western Australia Department Of Health | WA Health |
| Grampians Health Alliance | Grampians Health Alliance | Grampians Health |
| GHA Regional | Gippsland Health Alliance | Gippsland Health Alliance (GHA) |
| Albury Wodonga Health | null | Albury Wodonga Health |
| Mount Alvernia Hospital | null | Mount Alvernia Hospital |
| NCS/MinDef | null | NCS Pte Ltd |

### 3. Missing Client Codes

The `sync-burc-data.mjs` was missing these client codes:
- Sing Health
- Waikato
- Western Health
- GRMC

## Fix Applied

### scripts/sync-burc-data.mjs

1. Added logic to skip rows until "Row Labels" is found (marks start of data section)
2. Only process known client codes (avoiding detail sub-item rows)
3. Added missing client codes to CLIENT_NAMES mapping
4. Changed `annualTotal > 0` to `annualTotal !== 0` to capture negative "Lost" values

### scripts/update-client-arr-from-burc.mjs

1. Fixed all CLIENT_MAPPING entries to use actual `client_arr` names
2. Removed null mappings for clients that do exist in client_arr

## Verification

After fix, client ARR values now match BURC totals:

| Client | Before | After | Change |
|--------|--------|-------|--------|
| WA Health | $2,859,412 | $3,520,818 | +23% |
| Grampians Health | $130,016 | $1,210,610 | +831% |
| Gippsland Health Alliance | $1,406,980 | $130,017 | -91% |
| Albury Wodonga Health | - | $317,811 | New |
| Mount Alvernia Hospital | - | $308,892 | New |
| NCS Pte Ltd | - | $361,850 | New |

Total ARR now correctly shows **$20,577,202**

## Files Changed

- `scripts/sync-burc-data.mjs` - Fixed pivot table parsing logic
- `scripts/update-client-arr-from-burc.mjs` - Fixed CLIENT_MAPPING names

## Lessons Learned

1. **Verify data mappings against actual table contents** - Don't assume names match; always query both tables and compare
2. **Excel pivot tables have complex structures** - Summary and data sections can use the same labels differently
3. **Silent failures in mappings** - When a lookup fails, the record is simply skipped, making bugs hard to detect without verification queries
