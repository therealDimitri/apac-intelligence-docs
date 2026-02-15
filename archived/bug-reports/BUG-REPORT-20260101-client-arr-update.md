# Bug Report: Client ARR Data Update from BURC 2026

**Date:** 1 January 2026
**Status:** Fixed
**Severity:** Medium (Data accuracy)
**Component:** client_arr table

## Issue Description

The `client_arr` table contained sample/placeholder ARR values that didn't match the actual BURC 2026 maintenance data. This caused inaccurate revenue reporting in ChaSen AI and dashboard analytics.

## Root Cause

When the ARR feature was originally implemented (Phase 4.2), sample data was inserted. This was never updated with real maintenance revenue data from the BURC system.

## Solution

Created script to sync ARR values from `burc_client_maintenance` table to `client_arr` table.

### Client Name Mapping
```javascript
const CLIENT_MAPPING = {
  'SA Health': 'Minister for Health aka South Australia Health',
  'Sing Health': 'Singapore Health Services Pte Ltd',
  'Grampians Health Alliance': 'Grampians Health Alliance',
  'WA Health': 'Western Australia Department Of Health',
  "St Luke's Medical Centre": 'St Luke\'s Medical Center Global City Inc',
  'GRMC': 'GRMC (Guam Regional Medical Centre)',
  'Epworth Healthcare': 'Epworth Healthcare',
  'Waikato': 'Te Whatu Ora Waikato',
  'Barwon Health': 'Barwon Health Australia',
  'Western Health': 'Western Health',
  'Royal Victorian Eye & Ear': 'The Royal Victorian Eye and Ear Hospital',
  'GHA Regional': 'Gippsland Health Alliance',
}
```

### Currency Conversion
- BURC data is in AUD
- client_arr stores values in USD
- Applied 0.65 AUD→USD exchange rate

## Changes Made

### Updated Clients (12)

| Client | Old USD | New USD | Change |
|--------|---------|---------|--------|
| SA Health | 680,000 | 4,251,264 | +525% |
| Singapore Health Services | 850,000 | 3,048,193 | +259% |
| Grampians Health Alliance | 220,000 | 1,070,926 | +387% |
| WA Health | 450,000 | 852,886 | +90% |
| St Luke's Medical Center | 720,000 | 549,940 | -24% |
| GRMC | 180,000 | 401,310 | +123% |
| Epworth Healthcare | 420,000 | 273,210 | -35% |
| Te Whatu Ora Waikato | 650,000 | 208,001 | -68% |
| Barwon Health | 380,000 | 162,036 | -57% |
| Gippsland Health Alliance | 235,000 | 117,876 | -50% |
| Western Health | 210,000 | 99,796 | -53% |
| Royal Victorian Eye & Ear | 285,000 | 50,333 | -82% |

### Unchanged Clients (4)
These clients were not in the BURC maintenance data:
- Ministry of Defence, Singapore: USD 520,000
- Mount Alvernia Hospital: USD 310,000
- Albury Wodonga Health: USD 245,000
- Department of Health - Victoria: USD 195,000

### Missing from client_arr (3)
These clients exist in BURC but not in client_arr:
- Northern Health: AUD 528,145
- Austin Health: AUD 308,387
- Mercy Aged Care: AUD 302,672

## Final State

**Total ARR**: USD 12,355,771 (up from USD 6,550,000)

## Files Created

- `scripts/check-burc-arr.mjs` - Script to view BURC ARR data
- `scripts/update-client-arr-from-burc.mjs` - Script to sync ARR from BURC

## Database Tables

- Source: `burc_client_maintenance` (annual_total column)
- Target: `client_arr` (arr_usd column)

## Future Considerations

1. **Add missing clients**: Northern Health, Austin Health, Mercy Aged Care should be added to `client_arr`
2. **Automate sync**: Consider a scheduled job to sync ARR values from BURC data
3. **Exchange rate**: Current 0.65 rate is hardcoded - could be dynamic
4. **Currency field**: Updated records now show `currency: 'AUD'` for transparency

## Testing

1. Navigate to ChaSen AI
2. Ask: "What's our total ARR across APAC?"
3. Verify response shows approximately USD 12.3M
4. Check individual client ARR values match the updated table above
