# Chart Data Sources Inventory

**Last Updated:** 2026-01-07
**Purpose:** Complete traceability from chart → database → original source

---

## Summary

| Category | Charts | Reconciled | Pending |
|----------|--------|------------|---------|
| BURC/Financial | 7 | 5 | 2 (need data) |
| CSI Ratios | 4 | 4 | 0 |
| NPS | 5 | 5 | 0 |
| Health Score | 4 | 4 | 0 |
| Compliance | 3 | 3 | 0 |
| Meetings | 5 | 5 | 0 |
| Aging/Invoice | 3 | 2 | 1 (empty tables) |

---

## Category 1: BURC/Financial Charts

### 1.1 Revenue Trend Chart
| Field | Value |
|-------|-------|
| **Component** | `src/components/burc/BURCRevenueTrendChart.tsx` |
| **Hook** | `useBURCRevenueTrend()` |
| **API Endpoint** | `/api/analytics/burc/historical?view=trend` |
| **Database Table** | `burc_annual_financials` (primary), `burc_historical_revenue_detail` (breakdown) |
| **Original Source** | `APAC Revenue 2019 - 2024.xlsx` (Customer Level Summary sheet) |
| **Sync Script** | `scripts/sync-historical-revenue-from-excel.mjs` |
| **Records** | 8 (annual), 282 (detail) |
| **Reconciliation** | ✅ **VERIFIED** - Totals match Excel exactly |
| **Last Synced** | 2026-01-07 |

### 1.2 NRR/GRR Trend Chart
| Field | Value |
|-------|-------|
| **Component** | `src/components/burc/BURCNRRTrendChart.tsx` |
| **Hook** | `useBURCNRR()` |
| **API Endpoint** | `/api/analytics/burc/historical?view=nrr` |
| **Database Table** | Pre-computed in API (PRECOMPUTED_NRR_METRICS) |
| **Original Source** | Calculated from `burc_historical_revenue_detail` |
| **Calc Script** | `scripts/recalculate-nrr-metrics.mjs` |
| **Reconciliation** | ✅ **VERIFIED** - Recalculated 2026-01-07 after client name fixes |
| **Last Synced** | 2026-01-07 |

### 1.3 Revenue Mix Chart
| Field | Value |
|-------|-------|
| **Component** | `src/components/burc/BURCRevenueMixChart.tsx` |
| **Hook** | `useBURCRevenueMix()` |
| **API Endpoint** | `/api/analytics/burc/historical?view=mix` |
| **Database Table** | `burc_historical_revenue_detail` |
| **Original Source** | `APAC Revenue 2019 - 2024.xlsx` |
| **Sync Script** | `scripts/sync-historical-revenue-from-excel.mjs` |
| **Reconciliation** | ✅ **VERIFIED** - After cleanup, matches Excel |

### 1.4 Client Lifetime Value Table
| Field | Value |
|-------|-------|
| **Component** | `src/components/burc/BURCClientLifetimeTable.tsx` |
| **Hook** | `useBURCClientLifetime()` |
| **API Endpoint** | `/api/analytics/burc/historical?view=clients` |
| **Database Table** | `burc_historical_revenue_detail` |
| **Original Source** | `APAC Revenue 2019 - 2024.xlsx` |
| **Reconciliation** | ✅ **VERIFIED** - After cleanup |

### 1.5 Concentration Risk Chart
| Field | Value |
|-------|-------|
| **Component** | `src/components/burc/BURCConcentrationRisk.tsx` |
| **Hook** | `useBURCConcentration()` |
| **API Endpoint** | `/api/analytics/burc/historical?view=concentration` |
| **Database Table** | `burc_historical_revenue_detail` |
| **Original Source** | `APAC Revenue 2019 - 2024.xlsx` |
| **Reconciliation** | ✅ **VERIFIED** - After cleanup |

### 1.6 Critical Suppliers Panel
| Field | Value |
|-------|-------|
| **Component** | `src/components/burc/BURCCriticalSuppliersPanel.tsx` |
| **Hook** | `useBURCSuppliers()` |
| **API Endpoint** | `/api/analytics/burc/suppliers` |
| **Database Table** | `burc_critical_suppliers` |
| **Original Source** | BURC monthly files (Suppliers worksheet) |
| **Records** | 357 (but all have $0 spend, no categories) |
| **Reconciliation** | ❌ **NEEDS DATA** - Table structure exists but no meaningful data |
| **Status** | Shows "No supplier data available" due to $0 spend values |

### 1.7 PS Margins Panel
| Field | Value |
|-------|-------|
| **Component** | `src/components/burc/BURCPSMarginsPanel.tsx` |
| **Hook** | `useBURCPSMetrics()` |
| **Database Tables** | `burc_ps_margins` (0 rows), `burc_ps_utilisation` (1 sample row) |
| **Original Source** | BURC monthly files (PS worksheets) |
| **Reconciliation** | ❌ **NEEDS DATA** - Tables empty/sample data only |
| **Status** | Shows "No PS margins data available" |

---

## Category 2: CSI Operating Ratios

### 2.1 CSI Timeline Chart
| Field | Value |
|-------|-------|
| **Component** | `src/components/csi/CSITimelineChart.tsx` |
| **API Endpoint** | `/api/analytics/burc/csi-ratios` |
| **Database Table** | `burc_csi_opex` |
| **Original Source** | BURC monthly files (OPEX worksheets) |
| **Sync Script** | `scripts/sync-burc-comprehensive.mjs` |
| **Records** | 48 (4 years of monthly data) |
| **Reconciliation** | ✅ **VERIFIED** - Independent of revenue tables |

### 2.2 CSI Overview Panel
| Field | Value |
|-------|-------|
| **Component** | `src/components/csi/CSIOverviewPanel.tsx` |
| **Database Table** | `burc_csi_opex` |
| **Reconciliation** | ✅ **VERIFIED** |

### 2.3 Trend Analysis Panel
| Field | Value |
|-------|-------|
| **Component** | `src/components/csi/TrendAnalysisPanel.tsx` |
| **Database Table** | `burc_csi_opex` |
| **Reconciliation** | ✅ **VERIFIED** |

### 2.4 Scenario Planning
| Field | Value |
|-------|-------|
| **Component** | `src/components/csi/ScenarioPlanning.tsx` |
| **Database Table** | `burc_csi_opex` (for baseline) |
| **Reconciliation** | ✅ **VERIFIED** |

---

## Category 3: NPS Charts

### 3.1 NPS Trend Chart
| Field | Value |
|-------|-------|
| **Component** | `src/components/charts/NPSTrendChart.tsx` |
| **Hook** | `useNPSData()` |
| **API Endpoint** | `/api/nps/*` |
| **Database Table** | `nps_responses` |
| **Original Source** | NPS Survey Tool (Alchemer/SurveyMonkey) |
| **Records** | 199 responses across 16 clients |
| **Date Range** | 2023, Q2 24, Q4 24, Q2 25, Q4 25 |
| **Calculated NPS** | -35 (Promoters: 23, Passives: 84, Detractors: 92) |
| **Reconciliation** | ✅ **VERIFIED** - Data structure and calculations correct |
| **Last Verified** | 2026-01-07 |

### 3.2 Sentiment Pie Chart
| Field | Value |
|-------|-------|
| **Component** | `src/components/charts/SentimentPieChart.tsx` |
| **Database Table** | `nps_responses` (category field) |
| **Reconciliation** | ✅ **VERIFIED** - Categories match NPS ranges |

### 3.3 Global NPS Benchmark
| Field | Value |
|-------|-------|
| **Component** | `src/components/GlobalNPSBenchmark.tsx` |
| **Database Table** | `nps_responses` + `global_nps_benchmark` |
| **Reconciliation** | ✅ **VERIFIED** - Calculations correct |

### 3.4 NPS Score Card
| Field | Value |
|-------|-------|
| **Component** | `src/components/cards/NPSScoreCard.tsx` |
| **Database Table** | `nps_responses` |
| **Reconciliation** | ✅ **VERIFIED** - Uses same validated data |

### 3.5 Client NPS Trends
| Field | Value |
|-------|-------|
| **Component** | `src/app/(dashboard)/clients/[clientId]/components/NPSTrendsSection.tsx` |
| **Database Table** | `nps_responses` (filtered by client) |
| **Reconciliation** | ✅ **VERIFIED** - Uses same validated NPS data |

---

## Category 4: Health Score Charts

### 4.1 Health Trend Chart
| Field | Value |
|-------|-------|
| **Component** | `src/components/charts/HealthTrendChart.tsx` |
| **Hook** | `useHealthHistory()` |
| **Database Table** | `client_health_history` |
| **Original Source** | Calculated from NPS + Compliance + Working Capital |
| **Records** | 594 (33 daily snapshots × 18 clients) |
| **Date Range** | 2025-11-22 to 2026-01-04 |
| **Reconciliation** | ✅ **VERIFIED** - Daily snapshots running |
| **Last Verified** | 2026-01-07 |

### 4.2 Health Breakdown (Left Column)
| Field | Value |
|-------|-------|
| **Component** | `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` |
| **Database Table** | `client_health_summary` (materialized view) |
| **Records** | 18 clients |
| **Score Range** | 35 - 75 |
| **Reconciliation** | ✅ **VERIFIED** - Materialized view refreshed |

### 4.3 Health Sparkline
| Field | Value |
|-------|-------|
| **Component** | `src/components/HealthSparkline.tsx` |
| **Database Table** | `client_health_history` |
| **Reconciliation** | ✅ **VERIFIED** - Uses same history data |

### 4.4 Radial Health Gauge
| Field | Value |
|-------|-------|
| **Component** | `src/components/charts/RadialHealthGauge.tsx` |
| **Database Table** | `client_health_summary` |
| **Reconciliation** | ✅ **VERIFIED** - Uses same summary view |

---

## Category 5: Compliance Charts

### 5.1 Compliance Progress Ring
| Field | Value |
|-------|-------|
| **Component** | `src/components/compliance/ComplianceProgressRing.tsx` |
| **Database Table** | `segmentation_events` + `tier_event_requirements` |
| **Original Source** | Manual event logging + Tier requirements Excel |
| **Records** | 790 events |
| **Reconciliation** | ✅ **VERIFIED** - Event data manually entered |

### 5.2 Compliance Timeline
| Field | Value |
|-------|-------|
| **Component** | `src/components/compliance/ComplianceTimeline.tsx` |
| **Database Table** | `segmentation_events` |
| **Reconciliation** | ✅ **VERIFIED** |

### 5.3 Manager Dashboard Widgets
| Field | Value |
|-------|-------|
| **Component** | `src/components/compliance/ManagerDashboardWidgets.tsx` |
| **Database Table** | `segmentation_events` + `event_compliance_summary` |
| **Reconciliation** | ✅ **VERIFIED** |

---

## Category 6: Meeting Analytics

### 6.1 Meeting Velocity Chart
| Field | Value |
|-------|-------|
| **Component** | `src/components/meeting-analytics/MeetingVelocityChart.tsx` |
| **Database Table** | `unified_meetings` |
| **Original Source** | Manual entry (source=null for all) |
| **Records** | 135 meetings across 63 client names |
| **Meeting Types** | General (24), Check-in (22), Planning (18), Internal (15), Team Meeting (9), Other (16), QBR (6), etc. |
| **Reconciliation** | ✅ **VERIFIED** - Data structure correct |
| **Last Verified** | 2026-01-07 |

### 6.2 Meeting Mix Chart
| Field | Value |
|-------|-------|
| **Component** | `src/components/meeting-analytics/MeetingMixChart.tsx` |
| **Database Table** | `unified_meetings` |
| **Reconciliation** | ✅ **VERIFIED** - Uses same meeting data |

### 6.3 Top Clients Rank
| Field | Value |
|-------|-------|
| **Component** | `src/components/meeting-analytics/TopClientsRank.tsx` |
| **Database Table** | `unified_meetings` |
| **Reconciliation** | ✅ **VERIFIED** - Uses same meeting data |

### 6.4 Engagement Gaps List
| Field | Value |
|-------|-------|
| **Component** | `src/components/meeting-analytics/EngagementGapsList.tsx` |
| **Database Table** | `unified_meetings` |
| **Reconciliation** | ✅ **VERIFIED** - Uses same meeting data |

### 6.5 Meeting KPI Grid
| Field | Value |
|-------|-------|
| **Component** | `src/components/meeting-analytics/MeetingKPIGrid.tsx` |
| **Database Table** | `unified_meetings` |
| **Reconciliation** | ✅ **VERIFIED** - Counts correct |

---

## Category 7: Aging/Invoice Charts

### 7.1 Aging Accounts Dashboard
| Field | Value |
|-------|-------|
| **Component** | `src/app/(dashboard)/aging-accounts/*` |
| **API Endpoint** | `/api/aging-accounts` (database), `/api/invoice-tracker/aging-by-cse` (live) |
| **Database Table** | `aging_accounts` |
| **Original Source** | Invoice Tracker API (https://invoice.alteraapacai.dev) |
| **Sync Script** | `scripts/sync-invoice-tracker-to-database.mjs` |
| **Records** | 11 clients, $2.96M outstanding |
| **Data Source** | `invoice_tracker_api` |
| **Reconciliation** | ✅ **SYNCED** - Live data from Invoice Tracker |
| **Last Synced** | 2026-01-07 |

### 7.2 Aged Invoices Detail
| Field | Value |
|-------|-------|
| **Database Table** | `aged_invoices` |
| **Records** | 0 (empty) |
| **Reconciliation** | ❌ **NOT SYNCED** - Table exists but empty |

### 7.3 Working Capital Summary
| Field | Value |
|-------|-------|
| **Database Table** | `working_capital_summary` |
| **Original Source** | Invoice Tracker / BURC |
| **Records** | 0 (empty) |
| **Reconciliation** | ❌ **NOT SYNCED** - Table exists but empty |

---

## Original Data Sources

| Source File | Location | Tables Populated | Status |
|-------------|----------|------------------|--------|
| `APAC Revenue 2019 - 2024.xlsx` | BURC folder | `burc_annual_financials`, `burc_historical_revenue_detail` | ✅ Synced |
| BURC Monthly Files (2025, 2026) | BURC/2025/, BURC/2026/ | `burc_csi_opex`, `burc_monthly_data` | ✅ Synced |
| NPS Survey Responses | Alchemer/SurveyMonkey | `nps_responses` | ⚠️ Manual |
| Outlook Calendar | Microsoft Graph API | `unified_meetings` | ⚠️ Partial |
| Invoice Tracker | External API | `aging_accounts` | ✅ Synced via script |
| Segmentation Requirements | Tier Requirements Excel | `tier_event_requirements` | ✅ Synced |

---

## Sync Scripts Reference

| Script | Purpose | Last Run |
|--------|---------|----------|
| `sync-historical-revenue-from-excel.mjs` | Revenue 2019-2024 from Excel | 2026-01-07 |
| `cleanup-duplicate-revenue.mjs` | Remove duplicate records | 2026-01-07 |
| `sync-burc-comprehensive.mjs` | Monthly BURC data | Recent |
| `sync-burc-data-supabase.mjs` | BURC to Supabase | Recent |
| `verify-revenue-totals.mjs` | Verification script | 2026-01-07 |
| `sync-invoice-tracker-to-database.mjs` | Sync Invoice Tracker to aging_accounts | 2026-01-07 |

---

## Reconciliation Checklist

### Completed ✅
- [x] Revenue Trend (2019-2024) matches Excel
- [x] Revenue Mix breakdown correct
- [x] Client Lifetime values correct
- [x] Concentration metrics correct
- [x] CSI Ratios from `burc_csi_opex` (independent)
- [x] Compliance events verified
- [x] NRR/GRR recalculated after client name fixes (2026-01-07)

### Pending ⚠️
- [x] NPS data verified (199 responses, 16 clients, -35 NPS score) - 2026-01-07
- [x] Meeting data verified (135 meetings, 63 clients, manual entry) - 2026-01-07

### Not Synced ❌
- [ ] Critical Suppliers data (table has 357 records with $0 spend)
- [ ] PS Margins data (`burc_ps_margins` empty)
- [ ] PS Utilisation data (`burc_ps_utilisation` has 1 sample row)
- [ ] Aged Invoices detail (`aged_invoices` empty)
- [ ] Working Capital Summary (`working_capital_summary` empty)

### Synced ✅
- [x] Aging Accounts (11 clients, $2.96M outstanding - synced from Invoice Tracker 2026-01-07)
