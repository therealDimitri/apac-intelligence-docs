# Feature Report: Sales Budget Pipeline Integration (Phase 2B)

**Date:** 10 January 2026
**Type:** Feature Implementation
**Status:** Deployed
**Phase:** 2B of Planning Hub Enhancement

---

## Summary

Integrated Sales Budget pipeline data and actual CSE/CAM targets from the APAC 2026 Sales Budget Excel file. This creates a unified pipeline view combining both BURC and Sales Budget data sources with cross-reference tracking.

---

## Implementation Details

### 1. Database Schema

**New Table: `sales_pipeline_opportunities`**

Created to store pipeline opportunities from the Sales Budget Excel, separate from the BURC pipeline to maintain both data sources.

Key columns:
- `opportunity_name`, `account_name` - Core identification
- `cse_name`, `cam_name` - Assignment tracking
- `fiscal_period`, `forecast_category` - Classification
- `in_or_out`, `is_under_75k`, `is_upside`, `is_focus_deal` - Sales Budget flags
- `total_acv`, `tcv`, `weighted_acv`, `acv_net_cogs`, `bookings_forecast` - Financials
- `burc_pipeline_id`, `burc_matched`, `burc_match_confidence` - Cross-reference tracking

### 2. CSE/CAM Targets Updated

Replaced placeholder seed data with actual targets from Sales Budget "CSE Summary Wgt ACV" sheet:

| CSE/CAM | Role | Annual Weighted ACV | Quarterly Target |
|---------|------|---------------------|------------------|
| John Salisbury | CSE | $1,269,627 | $317,407 |
| Laura Messing | CSE | $2,680,288 | $670,072 |
| Tracey Bland | CSE | $1,909,347 | $477,337 |
| Open Role | CSE | $2,484,209 | $621,052 |
| Anu Pradhan | CAM | $5,859,261 | $1,464,815 |
| Nikki Wei | CAM | $2,484,209 | $621,052 |

### 3. Pipeline Import

**Source:** "APAC Pipeline by Qtr (2)" sheet in APAC 2026 Sales Budget Excel

**Results:**
- Total opportunities parsed: **155**
- Total ACV: **$46.30M**
- Weighted ACV: **$22.22M**

**By Quarter:**
- Q1-2026: 42 opportunities
- Q2-2026: 68 opportunities
- Q3-2026: 30 opportunities
- Q4-2026: 15 opportunities

**By CSE:**
| CSE | Opportunities | Pipeline Value |
|-----|--------------|----------------|
| Open Role | 56 | $10.9M |
| Tracey Bland | 37 | $5.1M |
| Laura Messing | 33 | $4.1M |
| John Salisbury | 29 | $2.1M |

### 4. BURC Cross-Reference

Implemented fuzzy matching between Sales Budget and BURC pipeline opportunities:

- **Total Matched:** 23 (14.8%)
  - Exact matches: 10
  - Fuzzy matches: 13
- **Unmatched:** 132

Matching algorithm:
1. Exact match on opportunity name
2. Fuzzy match combining opportunity name (70% weight) and client name (30% weight)
3. ACV match bonus for confirmed matches

---

## Scripts Created

### `scripts/sync-sales-budget-pipeline.mjs`

Imports pipeline data from Sales Budget Excel with:
- Multi-row header detection (row 5)
- CSE/CAM name normalisation
- BURC cross-reference matching
- Dry-run and verbose modes

```bash
# Usage
node scripts/sync-sales-budget-pipeline.mjs --dry-run   # Preview
node scripts/sync-sales-budget-pipeline.mjs             # Live sync
node scripts/sync-sales-budget-pipeline.mjs --verbose   # Detailed output
```

### `scripts/setup-sales-pipeline-table.mjs`

Creates the `sales_pipeline_opportunities` table via Supabase API.

---

## Context Updates

**`PlanningPortfolioContext.tsx`**

Updated `usePipelineOpportunities` hook to:
1. Fetch from BOTH `pipeline_opportunities` (BURC) and `sales_pipeline_opportunities` (Sales Budget)
2. Add `source` field to track origin ('burc' | 'sales_budget')
3. Use Sales Budget as authoritative source for financial metrics (avoids double-counting)

Updated `PipelineOpportunity` interface with:
- `source` field
- `burc_matched`, `burc_match_confidence` fields
- `is_upside`, `oracle_quote_number`, `oracle_quote_status`, `bookings_forecast` fields

---

## Hierarchy Structure

Bottom-up financial hierarchy now implemented:

```
CSE/CAM (Individual targets)
    ↓
Territory (VIC + NZ, WA + VIC, SA, Asia + Guam)
    ↓
Region (Australia+NZ, Asia+Guam)
    ↓
BU (APAC)
```

**Views created:**
- `territory_targets_rollup` - CSE → Territory aggregation
- `region_targets_rollup` - Territory → Region/BU aggregation
- `apac_bu_targets` - Total APAC targets
- `combined_pipeline_view` - Unified view of both pipeline sources

---

## Dashboard Display

**Planning Hub Performance Tab now shows:**

- Total Pipeline: $22.2M (weighted ACV from Sales Budget)
- CSE cards with individual pipeline values
- CAM partnership display (e.g., "CAM: Anu Pradhan")
- Quarterly targets from Sales Budget
- Gap to target calculations

**Region View now shows:**

- APAC Regional Overview with total targets
- Australia+NZ: $5.9M quarterly target (70% of APAC)
- Asia+Guam: $2.5M quarterly target (30% of APAC)
- Region comparison table

---

## Files Changed

- `src/contexts/PlanningPortfolioContext.tsx` - Dual pipeline source, updated types
- `supabase/migrations/20260110_sales_budget_pipeline.sql` - Table, targets, views
- `scripts/sync-sales-budget-pipeline.mjs` - Pipeline import script (new)
- `scripts/setup-sales-pipeline-table.mjs` - Table creation script (new)

---

## Testing

1. ✅ Build verification: `npm run build` passes
2. ✅ Pipeline loading: Console shows "Loaded 246 opportunities (BURC: 91, Sales Budget: 155)"
3. ✅ CSE cards display correct pipeline values
4. ✅ Region view shows hierarchy aggregation
5. ✅ Targets display correctly per CSE/quarter

---

## Screenshots

- `/Users/jimmy.leimonitis/.playwright-mcp/planning-hub-sales-budget-pipeline-loaded.png`
- `/Users/jimmy.leimonitis/.playwright-mcp/planning-hub-region-view-hierarchy.png`

---

## Next Steps

1. ~~Update APAC Goals page with BU targets~~ (pending)
2. ~~Update Business Units page~~ (pending)
3. Add BURC match badge display on pipeline opportunities
4. Implement scheduled sync for regular data updates
5. Add AI recommendations based on gap analysis
