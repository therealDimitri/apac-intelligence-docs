# Enhancement Report: 2025 Revenue Data Sync

**Date:** 3 January 2026
**Type:** Data Enhancement
**Status:** Completed
**Components Affected:** Historical Analytics, BURC Data Sync

---

## Summary

Added 2025 revenue data to the Historical Analytics dashboard by extracting client-level revenue from the "2025 APAC Performance.xlsx" BURC file. This completes the 2019-2025 historical view.

---

## Data Extracted

| Revenue Type | Amount | Records |
|-------------|--------|---------|
| Maintenance Revenue | $19.27M | 16 |
| Professional Services Revenue | $10.65M | 11 |
| License Revenue | $2.35M | 4 |
| Hardware & Other Revenue | $0.19M | 1 |
| **Total** | **$32.47M** | **32** |

---

## Top Clients by 2025 Revenue

| Client | Revenue Type | Amount |
|--------|-------------|--------|
| Minister for Health aka South Australia Health | Maintenance | $7.06M |
| Singapore Health Services Pte Ltd | Maintenance | $5.49M |
| Minister for Health aka South Australia Health | Professional Services | $5.45M |
| Gippsland Health Alliance | Professional Services | $1.81M |
| St Luke's Medical Center Global City Inc | Maintenance | $1.42M |
| Gippsland Health Alliance | Maintenance | $1.10M |

---

## Source Data

**File:** `/tmp/burc-archive/BURC/2025/2025 APAC Performance.xlsx`

**Sheets Parsed:**
- `Maint Net Rev 2025` - Column 7 (2025 Gross) per client
- `PS` - Column 1 (Client), Column 9 (USD amount) per project
- `SW` - Column 3 (Client), Column 7 (Licence Val USD) per deal
- `HW` - Monthly totals aggregated

---

## Client Name Mappings

Short codes from the 2025 file were mapped to full names matching existing historical data:

```javascript
const CLIENT_MAPPINGS = {
  'AWH': 'Albury Wodonga Health',
  'BWH': 'Barwon Health Australia',
  'EPH': 'Epworth HealthCare',
  'GHA': 'Gippsland Health Alliance',
  'Grampians': 'Grampians Health',
  'MAH': 'Mount Alvernia Hospital',
  'NCS': 'NCS PTE Ltd',
  'Parkway': 'Parkway Hospitals Singapore PTE LTD',
  'SA Health': 'Minister for Health aka South Australia Health',
  'SAPPI': 'Strategic Asia Pacific Partners, Incorporated',
  'Sing Health': 'Singapore Health Services Pte Ltd',
  'SLMC': "St Luke's Medical Center Global City Inc",
  'Waikato': 'Waikato District Health Board',
  'WA Health': 'Western Australia Department Of Health',
  'Western Health': 'Western Health',
  'RVEEH': 'The Royal Victorian Eye and Ear Hospital',
}
```

---

## Files Created/Modified

### New Script
- `scripts/sync-2025-revenue.mjs` - Extracts and syncs 2025 revenue data

### Database
- Table: `burc_historical_revenue_detail`
- 32 new records inserted for fiscal_year = 2025

---

## Technical Notes

1. **No negation required** - Unlike the 2019-2024 historical data (which used accounting convention with negative credits), the 2025 Performance file uses standard positive values for revenue.

2. **Hardware aggregated** - Hardware revenue is tracked at APAC level, not per-client.

3. **Column indices verified:**
   - Maintenance: Row 2+, Column 7 = 2025 Gross
   - PS: Row 3+, Column 1 = Client, Column 9 = USD
   - SW: Row 3+, Column 3 = Client, Column 7 = Licence Val USD

---

## Verification

Run to re-sync 2025 data:
```bash
node scripts/sync-2025-revenue.mjs
```

---

## Related Documentation

- [BURC Historical Data Display Bug Fix](./BUG-FIX-20260103-burc-historical-data-display.md)
- [BURC Historical Dashboard Enhancement](./ENHANCEMENT-20260102-burc-historical-dashboard.md)
