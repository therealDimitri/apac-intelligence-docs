# Data Quality

## Quality Layers

### Layer 1: Pre-Sync Validation
- **Script**: `scripts/burc-validate-sync.mjs`
- **When**: Optional (`--validate` flag before major syncs)
- **Coverage**: BURC data only
- **Checks**: Revenue bounds, spike detection, headcount anomalies, fiscal year range

### Layer 2: API-Level Monitoring
- **Route**: `GET /api/admin/data-quality/`
- **Coverage**: All major tables
- **Checks**: Orphaned records, stale data, name mismatches, completeness metrics, anomaly detection

### Layer 3: Data Reconciliation
- **Route**: `POST /api/admin/data-quality/reconciliation`
- **Scripts**: `reconcile-financials.mjs`, `reconcile-burc-source.mjs`, `detailed-reconcile.mjs`
- **Coverage**: BURC finances

## Staleness Thresholds

| Source | Warning | Critical |
|--------|---------|----------|
| `client_health_history` | 48h | 7 days |
| `actions` | 14 days | 30 days |
| `unified_meetings` | 2 days | 7 days |
| `aging_accounts` | 2 days | 7 days |
| `nps_responses` | 90 days | 180 days |
| `burc_annual_financials` | 7 days | 30 days |

## Client Name Resolution

The #1 data quality challenge. Client names vary across sources:
- "Albury Wodonga Health" vs "Albury Wodonga" vs "Albury-Wodonga (AWH)"
- "GHA" vs "Gippsland Health Alliance (GHA)"

### Resolution Mechanisms

1. **`resolve_client_name()` RPC** — Fuzzy matching with confidence scoring
   - 1.0 = exact match
   - 0.9 = contains match
   - 0.8 = reverse contains
   - 0.4+ = similarity match

2. **`client_name_aliases` table** — Display name to canonical name mappings (116+ entries)

3. **`client_canonical_lookup` view** — Materialised view for fast lookups

4. **`scan_client_name_mismatches()` RPC** — Detect unresolved names across tables

### Data Quality Warnings
- `client_name_aliases` can contain garbage from meeting imports (prefixes: "CONFIRMED,", "Re,", "PLACEHOLDER,")
- Legitimate commas exist: "Dept of Health, Victoria", "Ministry of Defence, Singapore"
- Client UUID migration is **incomplete** — some APIs still query by name, others by UUID

## Known Issues

| Issue | Severity | Status |
|-------|----------|--------|
| Client name normalization fragmented across 5+ scripts | High | Partially addressed by `client_name_aliases` |
| Client UUID migration incomplete | High | Some APIs migrated, others still use name matching |
| Excel cell references unvalidated | High | Sheet restructure causes silent failures |
| Activity name typos unmapped | Medium | Silently skipped, no audit trail |
| ARR data from wrong table | Fixed | Now uses `client_arr` table |
| `actions` table capitalized columns | Medium | `Status`, `Due_Date` not lowercase |
| Support health metric wrong table | Medium | Must use `support_sla_latest` VIEW, not `support_cases` |

## Source of Truth References

| Data | Authoritative Source | Sync Frequency |
|------|---------------------|----------------|
| FY2026 Revenue (Gross) | 2026 APAC Performance.xlsx cell U36 | Hourly |
| FY2026 ARR by Client | `client_arr` table | Hourly |
| Segmentation Compliance | `segmentation_event_compliance` + `segmentation_events` | Manual |
| CSI Metrics | BURC Maint sheet ratios | Hourly |
| Support SLA | `support_sla_latest` VIEW | Real-time |
| NPS Score | `nps_responses` table | Quarterly |
| Client Names | `client_name_aliases` (canonical: `clients` table) | Manual |

## Recommended Improvements

### High Priority
1. Validate Excel cell references exist before sync
2. Centralise all client name mappings in `client_name_aliases`
3. Complete client UUID migration across all API routes
4. Document all Excel cell references in a mapping spreadsheet

### Medium Priority — All Complete
5. ~~Hash-based duplicate detection for activity events~~ ✅ DONE — see [Dedup Architecture](#segmentation-event-dedup-architecture) below
6. ~~Comprehensive sync logging with INSERT/UPDATE/SKIP decisions~~ ✅ DONE (sync-logger helper, 34/34 crons adopted)
7. ~~Alerting on data staleness (Slack/Teams notifications)~~ ✅ DONE (staleness-check cron + Teams webhooks)
8. ~~Automated compliance reconciliation via daily cron~~ ✅ DONE (/api/cron/compliance-reconciliation)

## CSI Ratio Data Quality — Outlier Clamping & Adjustment Detection

The CSI ratios API (`/api/analytics/burc/csi-ratios/route.ts`) applies two data quality safeguards before returning historical data:

### Ratio Clamping

Raw ratios are clamped to meaningful business ranges to prevent chart distortion:

| Ratio | Floor | Ceiling | Typical Range |
|-------|-------|---------|---------------|
| PS | 0 | 6 | 0.5–3 |
| Sales | 0 | 4 | 0–2 |
| Maintenance | 0 | 15 | 4–10 |
| R&D | 0 | 3 | 0.2–1 |
| G&A | 0% | 40% | 10–25% |

Applied via `clampRatios()` — `Math.min(upper, Math.max(0, value))`.

### Accounting Adjustment Detection

Months with negative revenue or opex are flagged as `isAdjustment: true`. Detection criteria (`detectAdjustment()`):

- Negative total revenue (`total_nr < 0`)
- Negative component revenue exceeding $50K (`ps_nr < -50000` or `maintenance_nr < -50000`)
- Negative opex (`sm_opex < 0` or `ga_opex < 0`)

**Known adjustment months** (as of Feb 2026):
- **Jan 2024**: Negative SM & GA opex → PS=12.33 spike
- **Jan 2025**: Negative total revenue → PS=-4.89, Maint=-0.65
- **Aug 2025**: Negative SM opex

The chart component (`CSITimelineChart.tsx`) renders adjustment months as **gaps** (null values with `connectNulls={false}`) and shows "Accounting adjustment — excluded" in tooltips.

## Segmentation Event Dedup Architecture

Duplicates in `segmentation_events` are prevented at **three layers**:

### DB Layer (authoritative)
- **UNIQUE constraint**: `(client_name, event_type_id, event_date)` — prevents identical events regardless of insertion path
- **`content_hash` column**: MD5 of `client_name:event_type_id:event_date:source` — used for fast sync cache lookups
- **`compute_content_hash()` trigger**: Auto-computes hash on INSERT/UPDATE of key columns
- **`source` CHECK constraint**: Must be one of `dashboard`, `excel`, `bulk_import`, `briefing_room`, `api`

### RPC Layer
- **`upsert_segmentation_event()`**: Uses `INSERT ... ON CONFLICT (client_name, event_type_id, event_date) DO UPDATE` — atomic, no race conditions
- **Source priority**: Dashboard source is preserved when Excel tries to overwrite

### API Route Layer
- **Dashboard POST** (`/api/segmentation-events`): Returns `409 Conflict` on duplicate with user-friendly message
- **Bulk import** (`/api/compliance/events/bulk`): Uses `.upsert({ ignoreDuplicates: true })` — silently skips, reports `duplicatesSkipped` count
- **Briefing room sync** (`/api/compliance/events/sync`): Catches `23505`, links meeting to existing event instead of failing
- **Excel sync** (`scripts/sync-excel-activities.mjs`): Pre-checks via `content_hash` cache + calls RPC
