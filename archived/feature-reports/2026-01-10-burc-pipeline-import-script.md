# Feature Report: BURC Pipeline Import Script (Phase 2)

**Date:** 10 January 2026
**Type:** Feature Implementation
**Status:** Deployed
**Phase:** 2 of Planning Hub Enhancement

---

## Summary

Implemented a comprehensive BURC Excel import script that synchronises pipeline opportunities from the 2026 APAC Performance.xlsx file into the `pipeline_opportunities` database table with intelligent cross-reference logic.

---

## Script Details

**Location:** `scripts/sync-burc-pipeline-opportunities.mjs`

### Features

1. **Multi-Sheet Parsing**
   - "Rats and Mice Only" - Small deals <$50k
   - "Dial 2 Risk Profile Summary" - Larger deals ≥$50k with probability sections

2. **Intelligent Client Cross-Referencing**
   - Extracts client names from opportunity name prefixes (e.g., "AWH" → "Albury Wodonga Health")
   - Matches against `nps_clients` table using CLIENT_PREFIX_MAP
   - Sets `burc_match = true/false` for tracking match success

3. **CSE/CAM Assignment**
   - Maps CSEs from database client records
   - Uses CSE_TERRITORY_MAP for territory assignments
   - Auto-assigns CAM based on territory

4. **Probability Mapping**
   - Section-based probability (Green=90%, Yellow=50%, Red=20%, Pipeline=30%)
   - Forecast category fallback (Best Case=90%, Backlog=100%, Pipeline=30%)

5. **Opportunity Classification**
   - `rats_and_mice` - Deals <$50k
   - `focus_deal` - Large deals ≥$500k in Green/Yellow sections
   - `in_target` - Green section or Best Case/Commit forecast

---

## Usage

```bash
# Preview only (no database changes)
node scripts/sync-burc-pipeline-opportunities.mjs --dry-run

# Live sync
node scripts/sync-burc-pipeline-opportunities.mjs

# Detailed output
node scripts/sync-burc-pipeline-opportunities.mjs --verbose
```

---

## Results

**Initial Sync Results:**
- Total opportunities parsed: 91
- Matched to database: 87 (95.6%)
- Unmatched: 4 (internal/product entries)

**By Source Sheet:**
- Rats and Mice Only: 28
- Dial 2 Risk Profile: 63

**Classification:**
- In Target: 21
- Focus Deals: 0 (none met ≥$500k threshold in Green/Yellow)

**Financials:**
- Total ACV: $19.00M
- Total Weighted ACV: $4.85M

**By CSE:**
| CSE | Opportunities | Pipeline Value |
|-----|--------------|----------------|
| Laura Messing | 21 | $6.40M |
| Tracey Bland | 31 | $5.06M |
| Open Role | 19 | $4.05M |
| John Salisbury | 16 | $3.17M |

---

## Client Prefix Mappings

The script includes comprehensive client prefix mappings:

```javascript
const CLIENT_PREFIX_MAP = {
  'AWH': 'Albury Wodonga Health',
  'MAH': 'Mount Alvernia Hospital',
  'SA Health': 'SA Health (iPro)',
  'SLMC': "Saint Luke's Medical Centre (SLMC)",
  'WA Health': 'WA Health',
  'SingHealth': 'SingHealth',
  'Mindef': 'NCS/MinDef Singapore',
  'GHA': 'Gippsland Health Alliance (GHA)',
  'GRMC': 'Guam Regional Medical City (GRMC)',
  'Epworth': 'Epworth Healthcare',
  'BWH': 'Barwon Health Australia',
  // ... and more
}
```

---

## Database Updates

The script populates the `pipeline_opportunities` table created in Phase 1:
- Deletes existing BURC-imported records (where `burc_source_sheet IS NOT NULL`)
- Inserts new opportunities in batches of 100
- Triggers `weighted_acv` recalculation (generated column)

---

## Dashboard Integration

After sync, the Planning Hub Performance Dashboard now displays:
- **Total Pipeline: $4.8M** (weighted ACV)
- Individual CSE pipeline values on CSE cards
- Correct opportunity attribution by territory

---

## Files Changed

- `scripts/sync-burc-pipeline-opportunities.mjs` - New import script (638 lines)

---

## Next Steps

1. **Schedule regular sync** - Add to cron or GitHub Action
2. **Phase 6:** AI recommendation engine for gap analysis
3. **Enhancement:** Add MEDDPICC score import from BURC
4. **Enhancement:** Focus deal threshold configuration

---

## Testing

1. Dry-run verification: `--dry-run` flag shows preview
2. Build verification: `npm run build` passes
3. Dashboard verification: Pipeline values display correctly
4. Match rate: 95.6% (exceeds 95% target)

---

## Screenshots

Screenshot saved to:
- `/Users/jimmy.leimonitis/.playwright-mcp/planning-pipeline-data-loaded.png`
