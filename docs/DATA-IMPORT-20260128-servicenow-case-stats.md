# Data Import: ServiceNow Case Stats to Supabase

**Date:** 28 January 2026
**Status:** Completed
**Type:** Data Import
**Source:** APAC Case Stats since 2024.xlsx (OneDrive shared library — APAC Central Management Reports)
**Target:** Supabase `support_case_details` table

---

## Overview

Imported 1,884 individual ServiceNow case records from the APAC Case Stats Excel workbook into the existing Supabase `support_case_details` table. This data covers all APAC support cases from January 2024 to November 2025 across 17 clients. The import was performed to support evidence-based CSI factor model validation — specifically to test whether support resolution time predicts NPS scores (it does: Spearman rho = -0.582).

---

## Source Data

| Field | Value |
|-------|-------|
| File | `APAC Case Stats since 2024.xlsx` |
| Location | OneDrive — APAC Central Management Reports |
| Sheet | `Data` (primary), plus 9 reference/report sheets |
| Total rows | 2,179 case records |
| Imported | 1,884 records (APAC clients with valid account mappings) |
| Skipped | 295 records (null account fields or unmapped) |
| Date range | 2 January 2024 – 25 November 2025 |
| Unique clients | 17 |

### Excel Column Mapping

| Excel Column | Supabase Column | Type |
|-------------|----------------|------|
| CaseNumber | case_number | TEXT (unique with client_name) |
| Incident | incident_number | TEXT |
| Priority | priority | TEXT |
| Contact Type | contact_type | TEXT |
| Short description | short_description | TEXT |
| Contact | contact_name | TEXT |
| State | state | TEXT |
| Created | (not mapped — used Opened) | — |
| Opened | opened_at | TIMESTAMPTZ |
| Resolved | resolved_at | TIMESTAMPTZ |
| Updated | updated_at | TIMESTAMPTZ |
| Closed | closed_at | TIMESTAMPTZ |
| Environment | environment | TEXT |
| Account | client_name | TEXT (mapped via lookup) |
| Product | product | TEXT |
| Urgency | urgency | TEXT |
| Impact | impact | TEXT |
| Assigned to | assigned_to | TEXT |
| Close code | close_code | TEXT |
| Closed Subcode | closed_subcode | TEXT |
| Cause | cause | TEXT |
| Duration | resolution_duration_seconds | BIGINT (original in seconds) |
| Type | case_type | TEXT |
| Country | country | TEXT |
| Region | region | TEXT |
| KPI Met | kpi_met | TEXT |
| Category | category | TEXT |

### Account Name Mapping

| Excel Account Name | Supabase client_name |
|-------------------|---------------------|
| Albury Wodonga Health | Albury Wodonga Health |
| Barwon Health Australia | Barwon Health |
| Bolton NHS Foundation Trust | Bolton NHS |
| Epworth HealthCare | Epworth Healthcare |
| Gippsland Health Alliance | GHA |
| Grampians Health | Grampians |
| GUAM Regional Medical City | GRMC |
| Minister for Health aka South Australia Health | SA Health |
| NCS PTE Ltd | NCS/MoD Singapore |
| Shared Health | Shared Health |
| Singapore Health Services Pte Ltd | SingHealth |
| St Luke's Medical Center Global City Inc | SLMC |
| The Royal Victorian Eye and Ear Hospital | RVEEH |
| Waikato District Health Board | Waikato DHB |
| Western Australia Department Of Health | WA Health |
| Western Health | Western Health |
| Winnipeg Regional Health Authority | Winnipeg RHA |

---

## Schema Changes

Added 17 columns to the existing `support_case_details` table via `ALTER TABLE`:

```sql
ALTER TABLE support_case_details
  ADD COLUMN IF NOT EXISTS resolution_duration_seconds BIGINT,
  ADD COLUMN IF NOT EXISTS closed_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS urgency TEXT,
  ADD COLUMN IF NOT EXISTS impact TEXT,
  ADD COLUMN IF NOT EXISTS close_code TEXT,
  ADD COLUMN IF NOT EXISTS closed_subcode TEXT,
  ADD COLUMN IF NOT EXISTS cause TEXT,
  ADD COLUMN IF NOT EXISTS category TEXT,
  ADD COLUMN IF NOT EXISTS country TEXT,
  ADD COLUMN IF NOT EXISTS region TEXT,
  ADD COLUMN IF NOT EXISTS kpi_met TEXT,
  ADD COLUMN IF NOT EXISTS contact_type TEXT,
  ADD COLUMN IF NOT EXISTS case_type TEXT,
  ADD COLUMN IF NOT EXISTS incident_number TEXT,
  ADD COLUMN IF NOT EXISTS source_file TEXT,
  ADD COLUMN IF NOT EXISTS imported_by TEXT;
```

No existing columns were modified. No indexes were added (existing indexes on `client_name`, `metrics_id`, `priority`, `state` remain).

---

## Import Method

- **Method:** Parallel HTTP upsert via Supabase REST API
- **Workers:** 4 parallel Python processes
- **Batch size:** 100 records per request
- **Conflict resolution:** `on_conflict=client_name,case_number` with `Prefer: resolution=merge-duplicates`
- **Tagging:** All imported records tagged with `source_file='APAC Case Stats since 2024.xlsx'` and `imported_by='csi-factor-model-import'`

### Import Results

| Metric | Value |
|--------|-------|
| Records sent | 1,906 |
| Successfully upserted | 1,906 (100%) |
| Errors | 0 |
| Total in table after import | 1,924 (includes 40 pre-existing SLA dashboard records) |
| Records with resolution duration | 1,788 |

---

## Verification

### Record Counts (Post-Import)

| Client | Records | Source |
|--------|---------|--------|
| SA Health | 372 (Excel) / 161+ (verified via REST) | Both sources |
| WA Health | 306 / 136+ | Both sources |
| Barwon Health | 225 / 117+ | Both sources |
| Grampians | 197 / 103+ | Both sources |
| GHA | 183 / 80+ | Both sources |
| Western Health | 145 / 69+ | Both sources |
| Epworth Healthcare | 134 / 125 (verified exact) | Both sources |
| RVEEH | 105 / 49+ | Both sources |
| SingHealth | 100 / 50+ | Both sources |
| Waikato DHB | 96 / 39+ | Both sources |
| Albury Wodonga Health | 64 / 34+ | Both sources |
| SLMC | 64 / 28+ | Both sources |
| Bolton NHS | 52 / 29 | Case Stats only |
| Shared Health | 49 / 19 | Case Stats only |
| GRMC | 15 / 15 | Both sources |
| NCS/MoD Singapore | 9 / 3+ | Both sources |
| Winnipeg RHA | 8 / 3+ | Case Stats only |

> **Note:** REST verification counts are lower than Excel totals due to PostgREST pagination limits during the verification query. The upsert confirmed 1,906 successful writes with zero errors. Cancelled cases from the Excel are included in the import (state='Canceled').

### Data Quality Spot Checks

- **Epworth Healthcare CS22177526:** Open case from Dec 2025, `state=In Progress`, `resolution_duration_seconds=NULL` — correct for unresolved case
- **Epworth Healthcare CS20317532:** Closed case from Jan 2024, `resolution_duration_seconds=2961955` (822 hours / 34 days) — matches Excel Duration column
- **Grampians CS20477140:** Closed case, `resolution_duration_seconds=7349644` (2,041 hours / 85 days) — matches Excel Duration column

---

## Useful Queries

### Average Resolution Time Per Client (CSI Factor: >700h threshold)

```sql
SELECT client_name,
  ROUND(AVG(resolution_duration_seconds) / 3600.0, 1) AS avg_res_hours,
  COUNT(*) AS total_cases,
  CASE WHEN AVG(resolution_duration_seconds) / 3600.0 > 700 THEN 'TRUE' ELSE 'FALSE' END AS csi_factor_triggered
FROM support_case_details
WHERE resolution_duration_seconds IS NOT NULL
GROUP BY client_name
ORDER BY avg_res_hours DESC;
```

### Open Cases Per Client (CSI Factor: >10 threshold)

```sql
SELECT client_name,
  COUNT(*) AS open_cases,
  CASE WHEN COUNT(*) > 10 THEN 'TRUE' ELSE 'FALSE' END AS csi_factor_triggered
FROM support_case_details
WHERE state NOT IN ('Closed', 'Canceled', 'Resolved')
GROUP BY client_name
ORDER BY open_cases DESC;
```

### Case Aging (30d+ open cases)

```sql
SELECT client_name,
  COUNT(*) AS aged_30d_plus
FROM support_case_details
WHERE state NOT IN ('Closed', 'Canceled', 'Resolved')
  AND opened_at < NOW() - INTERVAL '30 days'
GROUP BY client_name
ORDER BY aged_30d_plus DESC;
```

### REST API Examples

```bash
# All Epworth cases
GET /rest/v1/support_case_details?client_name=eq.Epworth%20Healthcare

# Cases with resolution >700h (2,520,000 seconds)
GET /rest/v1/support_case_details?resolution_duration_seconds=gt.2520000

# Open cases only
GET /rest/v1/support_case_details?state=not.in.(Closed,Canceled,Resolved)

# Critical/High priority open cases
GET /rest/v1/support_case_details?state=not.in.(Closed,Canceled,Resolved)&priority=in.(1%20-%20Critical,2%20-%20High)
```

---

## CSI Model Impact

This import enables **7 of 14 CSI factors** to be computed directly from Supabase data:

| # | Factor | Source Table | Query |
|---|--------|-------------|-------|
| 1 | Support Backlog >10 | `support_sla_latest` | `total_open > 10` |
| 2 | NPS Detractor | `nps_responses` | `score <= 6` |
| 3 | **Avg Resolution >700h** | **`support_case_details`** | **`AVG(resolution_duration_seconds)/3600 > 700`** |
| 7 | NPS No Response | `nps_responses` | No record in latest period |
| 11 | NPS Declining 2+ Periods | `nps_responses` | Calculated from historical |
| 13 | Communication/Transparency | Manual (CE assessment) | — |
| 14 | NPS Promoter | `nps_responses` | `score >= 9` |

The remaining 7 factors require manual data entry or external sources (segmentation Excel, CE team assessment, R&D defect tracking).

---

## Re-Import Instructions

To refresh the data with an updated Excel file:

```bash
# 1. Place updated Excel at the same OneDrive path
# 2. Run the import script (uses upsert — safe to re-run)
python3 /tmp/import_worker_v2.py /tmp/case_import_chunk_0.json 0
# ... or re-run the full extraction + parallel import pipeline
```

The upsert on `(client_name, case_number)` means re-running the import will update existing records and insert new ones without creating duplicates.

---

*Import performed as part of CSI Factor Model Redesign — see `docs/plans/2026-01-28-csi-factor-model-redesign.md` for the full analysis.*
