# BURC Excel Cell Reference Mapping

**Source file**: `{FISCAL_YEAR} APAC Performance.xlsx`
**Path**: `BURC_MASTER_FILE` from `scripts/lib/onedrive-paths.mjs`

> When the Excel sheet structure changes, update this document and the corresponding sync scripts. Scripts now use **label-based row lookup** — row numbers below are for reference only.

## APAC BURC Sheet — Annual Financials

Found by label in column A. Read from columns U (Forecast) and W (Target).

| Row Label | Current Row | Col U (Forecast) | Col W (Target) | DB Table | DB Column |
|-----------|-------------|-------------------|----------------|----------|-----------|
| Total Gross Revenue | 36 | Gross Revenue Forecast | Gross Revenue Target | `burc_annual_financials` | `gross_revenue`, `target_gross_revenue` |
| Ending ARR / Maintenance ARR | 60 | Maintenance ARR Forecast | Maintenance ARR Target | `burc_annual_financials` | `ending_arr`, `target_arr` |
| EBITA | 101 | EBITA Forecast | EBITA Target | `burc_annual_financials` | `ebita`, `target_ebita` |

## APAC BURC Sheet — Monthly Data (Columns C-N = Jan-Dec)

| Section | Row Range | Row Labels | DB Table | Sync Function |
|---------|-----------|------------|----------|---------------|
| Gross Revenue | 28-36 | License, PS, Maintenance, Hardware, Total | `burc_gross_revenue_monthly` | `syncGrossRevenueMonthly` |
| COGS | 38-56 | License, PS, Maintenance, Hardware, Total | `burc_cogs_monthly` | `syncCogsData` |
| Net Revenue | 58-66 | License, PS, Maintenance, Hardware, Total | `burc_net_revenue_monthly` | `syncNetRevenueData` |
| OPEX | 71-98 | CS, R&D, PS, Sales, G&A, Total | `burc_opex_monthly` | `syncOpexData` |
| EBITA | 100-101 | EBITA value, EBITA % of Net Revenue | `burc_ebita_monthly` | `syncEbitaData` |
| CSI Ratios | 122-126 | Maintenance, Sales, R&D, PS, G&A | `burc_csi_ratios` | `syncCSIRatios` |

### Detailed Row-to-Column Mapping

**Gross Revenue** — `burc_gross_revenue_monthly`

| Row | Excel Label | DB Column |
|-----|------------|-----------|
| 28 | License Revenue | `license_revenue` |
| 30 | PS Revenue | `ps_revenue` |
| 33 | Maintenance Revenue | `maintenance_revenue` |
| 35 | Hardware Revenue | `hardware_revenue` |
| 36 | Total Gross Revenue | `total_gross_revenue` |

**COGS** — `burc_cogs_monthly`

| Row | Excel Label | DB Column |
|-----|------------|-----------|
| 38 | License COGS | `license_cogs` |
| 40 | PS COGS | `ps_cogs` |
| 44 | Maintenance COGS | `maintenance_cogs` |
| 47 | Hardware COGS | `hardware_cogs` |
| 56 | Total COGS | `total_cogs` |

**Net Revenue** — `burc_net_revenue_monthly`

| Row | Excel Label | DB Column |
|-----|------------|-----------|
| 58 | License Net Revenue | `license_net` |
| 60 | PS Net Revenue | `ps_net` |
| 63 | Maintenance Net Revenue | `maintenance_net` |
| 65 | Hardware Net Revenue | `hardware_net` |
| 66 | Total Net Revenue | `total_net_revenue` |

**OPEX** — `burc_opex_monthly`

| Row | Excel Label | DB Column |
|-----|------------|-----------|
| 71 | CS (Customer Service) | `cs_opex` |
| 76 | R&D | `rd_opex` |
| 82 | PS (Professional Services) | `ps_opex` |
| 88 | Sales & Marketing | `sales_opex` |
| 95 | G&A (General & Administrative) | `ga_opex` |
| 98 | Total OPEX | `total_opex` |

**EBITA** — `burc_ebita_monthly`

| Row | Excel Label | DB Column |
|-----|------------|-----------|
| 100 | EBITA Value | `actual_ebita` |
| 101 | EBITA % of Net Revenue | `ebita_percent` |

**CSI Ratios** — `burc_csi_ratios`

| Row | Excel Label | Target | DB Column |
|-----|------------|--------|-----------|
| 122 | Customer Service | > 4.0 | `maintenance_ratio` |
| 123 | Sales & Marketing | > 1.0 | `sales_ratio` |
| 124 | R&D | > 1.0 | `rd_ratio` |
| 125 | Professional Services | > 2.0 | `ps_ratio` |
| 126 | Administration | ≤ 20% | `ga_ratio` |

### Column Mapping (Months)

| Column | Month |
|--------|-------|
| C | Jan |
| D | Feb |
| E | Mar |
| F | Apr |
| G | May |
| H | Jun |
| I | Jul |
| J | Aug |
| K | Sep |
| L | Oct |
| M | Nov |
| N | Dec |
| U | FY Forecast Total |
| W | FY Target/Budget |

## Comparison Sheet — Prior Year

Sheet name: `{FY_SHORT} vs {PREV_FY_SHORT} Q Comparison` (e.g. "26 vs 25 Q Comparison")

| Cell | Description | DB Table | DB Column |
|------|-------------|----------|-----------|
| P14 | Prior FY Gross Revenue Actual | `burc_annual_financials` | `gross_revenue` (prior FY row) |
| A14 | Row label (for logging) | — | — |

## CSI Underlying Rows (Revenue & OPEX)

Used by `sync-2026-csi-from-excel.mjs` and `check-excel-csi.mjs`:

| Row | Description | Category |
|-----|-------------|----------|
| 56 | License Net Revenue | Revenue |
| 57 | PS Net Revenue | Revenue |
| 58 | Maintenance Net Revenue | Revenue |
| 59 | HW/Other Net Revenue | Revenue |
| 69 | PS OPEX | OPEX |
| 74 | Maintenance OPEX | OPEX |
| 80 | S&M OPEX | OPEX |
| 86 | R&D OPEX | OPEX |
| 93 | G&A OPEX | OPEX |

## Quarterly Comparison Rows

Used by `check-apac-burc-monthly-ratios.mjs`:

| Row Range | Description |
|-----------|-------------|
| 121-125 | CSI Ratio rows (monthly) |
| 128-129 | Quarterly comparison summary |

## Maint Pivot Sheet

Parsed via `sheet_to_json`. Column A = client code or category header.
Columns B–M (indices 1–12) = Jan–Dec monthly values. → `burc_client_maintenance`

**Category headers**: `Run Rate`, `Best Case`, `Pipeline`, `Business Case`, `Backlog`, `Lost`

Known client codes are defined in `scripts/seed-client-name-aliases.mjs` and
the `client_name_aliases` DB table. Only parent-level rows (matching known client codes)
are synced; child detail rows (project names, CPI breakdowns) are skipped.

## PS Pivot Sheet

Parsed via `sheet_to_json`. Hierarchical structure → `burc_ps_pipeline`:

1. **Category header** row (e.g. `Backlog`, `Best Case`, `Pipeline`, `Business Case`, `Reversal`)
2. **Client code** row (non-project name under a category)
3. **Project name** row (contains spaces, under a client)

Columns B–M (indices 1–12) = Jan–Dec monthly values.

## Waterfall Data Sheet

Row-indexed from `sheet_to_json` (0-indexed array). Column B (index 1) = amounts. → `burc_waterfall`

| Index | Category Key | Description |
|-------|-------------|-------------|
| 1 | `backlog_runrate` | PS Backlog and Maintenance Run Rate Gross Revenue |
| 4 | `committed_gross_rev` | PS Backlog, Intraco payments and Maint Run Rate |
| 6 | `best_case_ps` | Best Case Professional Services |
| 7 | `best_case_maint` | Best Case Maintenance |
| 8 | `other_rev` | Other Revenue |
| 9 | `pipeline_sw` | Pipeline Software (not in committed) |
| 10 | `pipeline_ps` | Pipeline PS (not in committed) |
| 12 | `forecast_cogs` | Forecast COGS |
| 13 | `cogs_reduction` | COGS Reduction Target |
| 15 | `forecast_opex` | Forecast OPEX |
| 16 | `opex_savings` | OPEX Savings Target |
| 17 | `fx_headwinds` | FX Headwinds |
| 19 | `target_ebita` | Target EBITA |

## Validation Rules

| Metric | Valid Range | Flag If |
|--------|-----------|---------|
| Revenue line item | $0 - $50M | > $50M |
| Monthly spike | — | > 2x previous month |
| Headcount per dept | 0 - 500 | > 500 |
| Fiscal year | 2020 - 2030 | Outside range |
| EBITA margin | -100% to +100% | Outside range |

## Scripts That Read These Cells

| Script | Cells Used | Notes |
|--------|-----------|-------|
| `sync-burc-data-supabase.mjs` | All above (label-based lookup) | Main sync — **uses findRows()** |
| `sync-2026-csi-from-excel.mjs` | Rows 56-59, 69-93 | CSI ratios sync |
| `check-excel-csi.mjs` | Rows 56-59, 69-93, 121-129 | Validation script |
| `check-apac-burc-monthly-ratios.mjs` | Rows 56-93, 121-125 | Ratio validation |
| `fix-2026-from-apac-burc-monthly.mjs` | Rows 56-93 | One-off fix script |
| `burc-validate-sync.mjs` | Various | Pre-sync validation |

## Upgrading for New Fiscal Year

When transitioning to a new FY (e.g. 2026 → 2027):

1. The new Excel file should be at `BURC/{YEAR}/{YEAR} APAC Performance.xlsx`
2. Run with `--year 2027` or set `FISCAL_YEAR=2027` env var
3. Verify the comparison sheet name matches the pattern `{FY} vs {PREV_FY} Q Comparison`
4. Check that row labels haven't changed (the label-based lookup will throw if they have)
5. Update CSI scripts that still use hardcoded row numbers
