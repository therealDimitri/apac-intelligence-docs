# Bug Report: Segmentation Compliance Data Fixes

**Date:** 2026-01-27
**Type:** Bug Fix / Data Alignment
**Status:** Completed & Deployed
**Author:** Claude Opus 4.5

---

## Overview

Fixed multiple issues in the segmentation compliance system that caused incorrect compliance calculations, missing 2026 data, and inconsistent year handling between UI views.

## Background

User reported that the segmentation logic on the Segmentation Events page was incorrect. The 2026 segmentation records should use a combination of the 2026 Segmentation Excel file and direct segmentation event inputs via the dashboard.

Investigation revealed:
- **Source:** APAC Client Segmentation Activity Register 2026.xlsx (OneDrive)
- **Database tier requirements:** Already matched the Excel (no update needed)
- **Multiple other issues:** Client name mismatches, year handling inconsistency, missing 2026 records, stale materialised view

## Issues Found & Fixed

### Issue 1: Client Name Mismatches in Exclusions Table

**Problem:** The `client_event_exclusions` table used different client name spellings than `client_segmentation` and `nps_clients`. This meant exclusions silently failed to apply, creating false non-compliance for affected clients.

**Mismatches Fixed:**

| Old (Exclusions) | Corrected To (Canonical) |
|---|---|
| `Grampians Health Alliance` | `Grampians Health` |
| `Ministry of Defence, Singapore` | `NCS/MinDef Singapore` |
| `Gippsland Health Alliance` | `Gippsland Health Alliance (GHA)` |
| `Department of Health, Victoria` | `Department of Health - Victoria` |

**Rows affected:** 25 exclusion records updated.

### Issue 2: Year Handling Inconsistency Between Compliance Hooks

**Problem:** Two hooks calculated compliance using different year semantics:
- `useEventCompliance(client, 2026)` internally offset to `year - 1 = 2025` ("reporting year" semantic)
- `useAllClientsCompliance(2026)` queried for year 2026 directly ("assessment year" semantic)

This meant the segmentation page list view and the client detail panel showed different data for the same year.

**Fix:** Removed the `year - 1` offset from `useEventCompliance`. Both hooks now use the year parameter as the assessment year (the year of events). When a user views "2025 compliance", they see 2025 events. When they view "2026 compliance", they see 2026 events.

**Segment change deadline logic updated:**
- Before: `detectSegmentChange(clientName, year - 1)` → deadline June 30 of `year`
- After: `detectSegmentChange(clientName, year)` → deadline June 30 of `year + 1`

**File changed:** `src/hooks/useEventCompliance.ts`

### Issue 3: Missing 2026 Client Segmentation Records

**Problem:** The `client_segmentation` table only had records with 2025 effective dates (effective_from = 2025-09-01, effective_to = null). The materialised view `event_compliance_summary` derives its year from these dates, so it had no 2026 rows for most clients.

**Fix:**
1. Closed all open-ended 2025 records by setting `effective_to = 2025-12-31`
2. Inserted 18 new records with `effective_from = 2026-01-01` matching the 2026 Excel

**Clients added (18):**
All clients from the 2026 Excel register with their correct segments:
- **Maintain (6):** Barwon Health, RVEEH, Western Health, SLMC, GRMC, Epworth
- **Leverage (5):** Albury Wodonga, Grampians, GHA, Mount Alvernia, NCS/MinDef
- **Nurture (2):** Dept of Health Victoria, SA Health (iQemo)
- **Collaboration (2):** SA Health (iPro), Te Whatu Ora Waikato
- **Sleeping Giant (2):** SingHealth, WA Health
- **Giant (1):** SA Health (Sunrise)

### Issue 4: Stale Materialised View

**Problem:** The `event_compliance_summary` materialised view had not been refreshed after the data changes. It showed 20 rows (19 for 2025, 1 for 2026).

**Fix:** Refreshed the view via direct PostgreSQL connection. Now shows 38 rows (19 for 2025, 19 for 2026).

## Verification

### After Refresh - 2026 View Data

| Client | Segment | Score | Status | Event Types |
|---|---|---|---|---|
| SA Health (Sunrise) | Giant | 18% | critical | 11 |
| All others | Various | 0% | critical | 1-12 |

This is expected - it's January 2026 and very few events have been logged yet.

### After Refresh - 2025 View Data (unchanged)

| Client | Score | Status |
|---|---|---|
| Albury Wodonga Health | 100% | compliant |
| GHA | 100% | compliant |
| Grampians Health | 100% | compliant |
| Mount Alvernia Hospital | 100% | compliant |
| NCS/MinDef Singapore | 100% | compliant |
| SA Health (iPro) | 100% | compliant |
| SA Health (Sunrise) | 100% | compliant |
| Te Whatu Ora Waikato | 100% | compliant |
| Western Health | 100% | compliant |
| Barwon Health | 88% | at-risk |
| SingHealth | 83% | at-risk |
| SA Health (iQemo) | 82% | at-risk |
| Epworth Healthcare | 80% | at-risk |
| Dept of Health Victoria | 75% | at-risk |
| SLMC | 60% | at-risk |
| WA Health | 50% | at-risk |
| GRMC | 40% | critical |
| RVEEH | 0% | critical |
| SA Health | 0% | critical |

## Technical Details

### Tier Event Requirements vs Excel

Investigation confirmed the database `tier_event_requirements` table already matches the 2026 Excel:

| Segment | Total Events/Year |
|---|---|
| Sleeping Giant | 66 |
| Giant | 65 |
| Nurture | 36 |
| Collaboration | 34 |
| Leverage | 26 |
| Maintain | 21 |

The original seed SQL file (`20251127_seed_tier_requirements.sql`) was stale (based on August 2024 guide) but the live database had already been updated.

### Issue 5: RVEEH Name Duplication Across Tables

**Problem:** `nps_clients` used "The Royal Victorian Eye and Ear Hospital" while `client_segmentation` and `segmentation_events` used "Royal Victorian Eye and Ear Hospital" (without "The"). This caused a ghost duplicate entry in the `event_compliance_summary` materialised view (3 rows instead of 2).

**Fix:** Updated all tables to the canonical name "Royal Victorian Eye and Ear Hospital":
- `nps_clients`: 1 row updated
- `nps_responses`: 2 rows updated
- `actions`: 1 row updated
- Refreshed `event_compliance_summary` materialised view (now 37 rows, down from 38)

### Issue 6: SA Health Bare Name Duplicate in Segmentation

**Problem:** A bare "SA Health" entry existed alongside the three legitimate product-based entities (SA Health (Sunrise), SA Health (iQemo), SA Health (iPro)). The bare entry was a legacy Giant-segment record for 2025 only, duplicating SA Health (Sunrise) which is also Giant. It showed as 0% critical in the compliance view.

**Fix:**
- Deleted bare "SA Health" from `client_segmentation` (1 closed 2025 record)
- Reassigned 1 segmentation event from "SA Health" to "SA Health (Sunrise)"
- Deleted bare "SA Health" from `nps_clients` (ghost placeholder with null score/ARR/CDH)
- Refreshed `event_compliance_summary` materialised view (now 36 rows, down from 37)

**Note:** `nps_responses` (46 rows) and `unified_meetings` (20+ rows) still use bare "SA Health" as an umbrella name across all products. These are legitimate references to SA Health as a whole and were not changed.

### Issue 7: List View Missing Cross-Year Events for Re-Segmented Clients

**Problem:** The `useAllClientsCompliance` hook (used by the compliance list view) only queried the current year's data from `event_compliance_summary`. For re-segmented clients whose assessment window extends into the following year (e.g. Sep 2025 → Jun 30 2026), events logged in the next year's portion (Jan-Jun 2026) were not included in the compliance calculation.

The single-client hook `useEventCompliance` correctly fetched both years' data, so the detail view showed accurate scores. This created an inconsistency where the list view would show lower scores than the detail view for re-segmented clients as events accumulated in the extended window.

**11 affected clients** (all re-segmented in September 2025):
- Department of Health - Victoria (Collaboration → Nurture)
- Epworth Healthcare (Leverage → Maintain)
- GHA (Collaboration → Leverage)
- Grampians Health (Collaboration → Leverage)
- GRMC (Leverage → Maintain)
- NCS/MinDef Singapore (Maintain → Leverage)
- SA Health (iPro) (Nurture → Collaboration)
- SA Health (Sunrise) (Sleeping Giant → Giant)
- SingHealth (Nurture → Sleeping Giant)
- SLMC (Leverage → Maintain)
- WA Health (Nurture → Sleeping Giant)

**Fix:** Updated `useAllClientsCompliance` to:
1. Identify re-segmented clients after batch deadline detection
2. Fetch next year's data from `event_compliance_summary` for those clients (1 additional query)
3. Combine events from both years: current year from change month onwards + next year Jan-Jun
4. Recalculate compliance using the combined event set (matching `useEventCompliance` logic)

Cache version bumped from `v8_list_segment_recalc` to `v9_list_cross_year_window`.

**File changed:** `src/hooks/useEventCompliance.ts`

### Known Remaining Issues

None.

---

## Related Files

- `src/hooks/useEventCompliance.ts` - Year handling fix, cross-year window fix for list view
- `src/lib/segment-deadline-utils.ts` - Segment change detection and deadline calculation
- `supabase/migrations/20251127_seed_tier_requirements.sql` - Original seed (stale, not modified)
- `supabase/migrations/20251223000000_update_compliance_view_with_exclusions.sql` - Materialised view definition

## Source Documents

- APAC Client Segmentation Activity Register 2026.xlsx (OneDrive)
- Altera APAC Client Segmentation Best Practice Guide (August 2024) - original seed source
