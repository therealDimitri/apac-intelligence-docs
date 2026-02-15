# BURC Sync Pipeline

## Source File

`/OneDrive/APAC Leadership Team - General/Performance/Financials/BURC/2026/2026 APAC Performance.xlsx`

Accessed via: `BURC_MASTER_FILE` from `scripts/lib/onedrive-paths.mjs`

## Data Flow

```
Excel (2026 APAC Performance.xlsx)
    | [XLSX library reads]
Parse Worksheets: "APAC BURC", "26 vs 25 Q", etc.
    | [sync-burc-data-supabase.mjs]
Extract cells (direct references: U36, U60, U101, W36, W60, W101)
    |
Supabase INSERT/UPSERT
    | [12 tables populated]
    |-- burc_annual_financials (FY totals - AUTHORITATIVE)
    |-- burc_csi_ratios
    |-- burc_ebita_monthly
    |-- burc_opex_monthly
    |-- burc_cogs_monthly
    |-- burc_net_revenue_monthly
    |-- burc_gross_revenue_monthly
    |-- burc_quarterly_comparison
    |-- burc_waterfall_data
    |-- burc_client_maintenance
    |-- burc_ps_pipeline
    |-- burc_revenue_streams
    |
burc_sync_log (audit trail)
```

## Critical Rule

**Always use `burc_annual_financials` for totals. Never sum detail tables.**

Detail tables (`burc_waterfall_data`, `burc_revenue_streams`, etc.) contain breakdowns that don't cleanly sum to totals due to double-counting and category overlaps.

## Tables Populated

| Table | Source Sheet | Key Columns |
|-------|-------------|-------------|
| `burc_annual_financials` | "APAC BURC" + "26 vs 25 Q" | fiscal_year, gross_revenue, maintenance_arr, ebita, target_revenue |
| `burc_ebita_monthly` | "APAC BURC" Rows 100-101 | client_name, month, ebita_amount |
| `burc_opex_monthly` | "APAC BURC" Rows 71-98 | year, month, cs_opex, rd_opex, ps_opex, sales_opex, ga_opex, total_opex |
| `burc_cogs_monthly` | "APAC BURC" Rows 38-56 | year, month, license_cogs, ps_cogs, maintenance_cogs, hardware_cogs, total_cogs |
| `burc_net_revenue_monthly` | "APAC BURC" Rows 58-66 | year, month, license_net, ps_net, maintenance_net, hardware_net, total_net_revenue |
| `burc_gross_revenue_monthly` | "APAC BURC" detail rows | year, month, license_revenue, ps_revenue, maintenance_revenue, hardware_revenue, total_gross_revenue |
| `burc_client_maintenance` | "APAC BURC" maint section | client_name, arr_usd, forecast_usd |
| `burc_ps_pipeline` | "APAC BURC" pipeline section | opportunity_id, deal_name, forecast |
| `burc_csi_ratios` | "APAC BURC" KPI section | csi_gross, csi_renewal, csi_maintenance |

## Validation

### Pre-Sync Validation
**Script**: `scripts/burc-validate-sync.mjs`
- Revenue bounds: 0-50M per line item
- Spike detection: >2x previous month = warning
- Headcount anomalies: >500 per dept
- Fiscal year validation: 2020-2030 range
- Exit codes: 0 (pass), 1 (fail), 2 (warnings)

### Reconciliation Scripts
- `scripts/reconcile-financials.mjs` — Verify Excel totals match DB
- `scripts/reconcile-burc-source.mjs` — Check cell references against source
- `scripts/detailed-reconcile.mjs` — Deep audit of all line items

### Data Quality API
`GET /api/admin/data-quality/` monitors:
- Orphaned records (no client_uuid)
- Stale data warnings (BURC: 7d warning, 30d critical)
- Name mismatches (unresolved client names)

## Known Fragility Points

| Risk | Impact | Status |
|------|--------|--------|
| Excel cell references hardcoded (see row map below) | Sheet restructure silently fails | Active risk — last updated 2026-02-11 |
| Hard-coded fiscal year 2026 | Future years require code updates | Active risk |
| launchd only on macOS | Other OS dev machines won't auto-sync | By design |
| No duplicate detection in some tables | Re-running can insert duplicates | Partial (UPSERT on most) |
| OneDrive path changes | Resolved via `onedrive-paths.mjs` | Fixed |

## APAC BURC Sheet Row Map (updated 2026-02-11)

Row numbers in `sync-burc-data-supabase.mjs` must match the live Excel sheet. Finance restructures the sheet periodically (inserting pipeline rows, business case breakdowns, headers). When the sync fails, dump column A to find new row positions.

| Section | Rows | Notes |
|---------|------|-------|
| Gross Revenue | 10 (License), 12 (PS), 18 (Maint), 27 (HW), 36 (Total) | Was 28/30/33/35/36 before Feb 2026 |
| COGS | 38, 40, 44, 47, 56 | Unchanged |
| Net Revenue | 58 (License), 59 (PS), 60 (Maint), 61 (HW), 66 (Total) | PS/Maint/HW shifted from 60/63/65 |
| OPEX | 71 (PS), 76 (Maint), 83 (S&M), 89 (R&D), 96 (G&A), 99 (Total) | Last 4 shifted +1 |
| EBITA | 101 (value), 102 (% margin) | Shifted from 100/101 |
| CSI Ratios | 123-127 (Maint, S&M, R&D, PS, Admin) | Shifted from 122-126 (header inserted) |
| Annual financials | Uses `findRows()` regex — more resilient to row shifts | Pattern: `/^Gross Revenue/i` |

## Orchestration

**Script**: `scripts/burc-sync-orchestrator.mjs`
- Coordinates multi-sheet BURC sync
- Called by launchd plist
- Delegates to `sync-burc-data-supabase.mjs` for actual data extraction

## Manual Sync API

**Route**: `POST /api/analytics/burc/sync`
- **Production (Netlify)**: Returns last sync info from DB only
- **Local dev**: Spawns child process (timeout: 55s)
