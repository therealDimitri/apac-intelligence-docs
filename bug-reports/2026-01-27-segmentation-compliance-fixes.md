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

## Issue 8: RVEEH Showing 0% Compliance Despite 33 Completed Events

**Symptom:** Royal Victorian Eye and Ear Hospital (RVEEH) displayed 0% compliance on the 2025 compliance page, despite having 33 completed segmentation events in the database.

**Root Cause:** The `client_name_aliases` table had a mismatched canonical name. The canonical name was set to `"The Royal Victorian Eye and Ear Hospital"` (with "The" prefix), but `client_segmentation` uses `"Royal Victorian Eye and Ear Hospital"` (without "The").

The materialised view's `event_counts` CTE resolves event client names to canonical names via aliases, then JOINs to `combined_requirements` (which uses `client_segmentation` names). Because the canonical name didn't match the segmentation name, the JOIN produced zero matches — making all RVEEH events invisible to compliance calculations.

**Investigation Steps:**
1. Confirmed 33 completed events exist in `segmentation_events` for RVEEH (created 2026-01-10)
2. Confirmed materialised view was refreshed after events were created (2026-01-27)
3. Confirmed event type IDs match: 7 of 8 Maintain tier requirements have events
4. Queried `client_name_aliases` — found canonical = `"The Royal Victorian Eye and Ear Hospital"`
5. Queried `client_segmentation` — found name = `"Royal Victorian Eye and Ear Hospital"`
6. Traced the JOIN logic in `supabase/migrations/20260111_fix_compliance_view_client_aliases.sql`:
   - `event_counts` CTE maps events → canonical via `COALESCE(cnm.canonical_name, se.client_name)`
   - `event_type_compliance` CTE JOINs `combined_requirements cr` with `event_counts ec` ON `ec.client_name = cr.client_name`
   - This JOIN fails when canonical ≠ segmentation name

**Fix Applied:**
1. Updated `client_name_aliases` canonical name from `"The Royal Victorian Eye and Ear Hospital"` to `"Royal Victorian Eye and Ear Hospital"` (5 rows updated)
2. Removed explicit self-mapping row (`display="Royal Victorian Eye and Ear Hospital"` → `canonical="Royal Victorian Eye and Ear Hospital"`) since the CTE's `UNION ALL` already handles self-mappings — keeping it would cause duplicate JOIN rows
3. Refreshed materialised view via `scripts/refresh-compliance-view.mjs`

**Result:** RVEEH now shows **75% compliance** (6/8 event types compliant, 33 of 21 events completed) — up from 0%.

**Lesson:** Canonical names in `client_name_aliases` must always match the names used in `client_segmentation`. Any mismatch silently breaks the materialised view JOIN, causing events to be invisible.

---

## Issue 9: Event Double-Counting Across All Clients Due to Self-Mapping Alias Rows

**Symptom:** Event counts in the materialised view were exactly double the actual database counts for most clients. For example, Albury Wodonga showed 24 Insight Touch Points in the view but only 12 existed in the database. This inflated compliance scores — clients appeared more compliant than they actually were.

**Root Cause:** The `client_name_aliases` table contained 15 explicit self-mapping rows where `display_name = canonical_name` (case-insensitive). The materialised view's `client_name_mapping` CTE already adds `canonical_name → canonical_name` self-mappings via its `UNION ALL` clause. Having both the explicit row and the CTE-generated row caused the `LEFT JOIN` to match twice per event, doubling the `COUNT(*)` for every event.

Additionally, 2 duplicate alias entries were found (SingHealth, WA Health).

**Affected Clients:** All 17 clients with alias entries (every client except RVEEH, which was already fixed in Issue 8).

**Fix Applied:**
1. Removed 15 explicit self-mapping rows from `client_name_aliases` where `LOWER(display_name) = LOWER(canonical_name)`
2. Removed 2 duplicate alias entries
3. Refreshed materialised view

**Compliance Score Changes (before → after, 2025):**

| Client | Before (doubled) | After (correct) | Change |
|--------|-----------------|-----------------|--------|
| Barwon Health Australia | 88% | 75% | -13% |
| Epworth Healthcare | 80% | 70% | -10% |
| GRMC | 40% | 20% | -20% |
| NCS/MinDef Singapore | 100% | 89% | -11% |
| SA Health (iPro) | 100% | 88% | -12% |
| SA Health (iQemo) | 82% | 73% | -9% |
| SA Health (Sunrise) | 100% | 92% | -8% |
| SLMC | 60% | 30% | -30% |
| SingHealth | 83% | 33% | -50% |
| WA Health | 50% | 25% | -25% |
| Western Health | 100% | 88% | -12% |

Overall portfolio: 50% → 42% (327/521 events, previously showed 563/521)

**Lesson:** The `client_name_mapping` CTE's `UNION ALL` already handles self-mappings. Never add explicit `display_name = canonical_name` rows to `client_name_aliases` — they will cause double-counting in any LEFT JOIN that uses the mapping.

---

## Issue 10: Extended Window Recalculation Discarding Pre-Change Events

**Symptom:** Six re-segmented clients (SA Health (Sunrise), WA Health, SingHealth, GHA, Grampians Health, NCS/MinDef Singapore) showed 0% compliance on the segmentation page's 2025 view, despite having significant event data in the database and correct scores in the materialised view.

**Root Cause:** The `useAllClientsCompliance` hook's extended window recalculation filtered current-year events to only those from the segment change month (September) onwards. For clients that changed segment in September 2025, this discarded all events from January–August 2025 — typically 60–89% of their completed events.

For example:
- SA Health (Sunrise): 74 total events → 22 kept (52 discarded, 70% lost)
- SingHealth: 44 total events → 5 kept (39 discarded, 89% lost)
- GHA: 27 total events → 9 kept (18 discarded, 67% lost)

The filtering code used `eventDate.getMonth() + 1 >= changeMonth` which only kept events from September onwards, throwing away all pre-change events that had already been counted by the materialised view.

**Fix:** Changed the recalculation to keep ALL current-year events from the materialised view (which already evaluates against the correct tier's requirements) and only ADD next-year Jan–Jun events on top. The materialised view's `combined_requirements` CTE already uses each client's latest segment, so pre-change events are correctly assessed against the new tier.

**Before (broken):**
```typescript
// Current year: events from change month onwards (DISCARDS Jan-Aug)
const filteredEvents = (ec.events || []).filter((e) => {
  const eventDate = new Date(e.event_date)
  return eventDate.getMonth() + 1 >= changeMonth
})
```

**After (fixed):**
```typescript
// Keep ALL current year events from materialised view (already correct)
// Only ADD next year Jan-Jun events on top
for (const ec of eventCompliance) {
  currentCounts[ec.event_type_id] = {
    expected: ec.expected_count,
    actual: ec.actual_count,  // Use view's count, not filtered
    events: ec.events || []
  }
}
```

**Compliance Score Changes (2025, segmentation page):**

| Client | Before Fix | After Fix |
|--------|-----------|-----------|
| SA Health (Sunrise) | 0% | 100% |
| GHA | 0% | 100% |
| Grampians Health | 0% | 100% |
| NCS/MinDef Singapore | 0% | 89% |
| WA Health | 0% | 25% |
| SingHealth | 0% | 33% |

Cache version bumped from `v9_list_cross_year_window` to `v10_list_keep_all_year_events`.

**File changed:** `src/hooks/useEventCompliance.ts`

**Lesson:** When the materialised view already evaluates events against the correct (latest) tier requirements, client-side recalculation should not discard events — it should only add cross-year events on top. The view is the source of truth for current-year compliance.

---

## Issue 11: Health Score Discrepancy Between Portfolio Card and Client Profile (FOUC)

**Symptom:** Portfolio Health cards showed correct health scores (e.g. 91 for Mount Alvernia Hospital) but the client profile detail page showed a different, lower score (31 for Mount Alvernia). The detail page would briefly flash the correct score before settling on the wrong value (FOUC — Flash of Unstyled Content).

**Root Cause — Two Bugs:**

1. **Year mismatch between contexts:**
   - `ClientPortfolioContext` (card view) used `useAllClientsCompliance(priorYear)` → 2025 compliance
   - `ClientMetricsContext` (detail view) used `useEventCompliance(clientName, currentYear)` → 2026 compliance
   - `page.tsx` (v2 route) also used `useEventCompliance(client, currentYear)` → 2026 compliance
   - In January 2026, current year compliance is ~0% for all clients since events haven't been logged yet
   - Compliance is weighted at 60% of the health score, so 0% vs 100% = 60-point swing (explaining 91 → 31)

2. **Stale `useMemo` in LeftColumn:**
   - Health score `useMemo` at line 510-603 of `LeftColumn.tsx` used `eventCompliance?.overall_compliance_score`
   - But dependency array was only `[client]`, missing `eventCompliance`
   - When compliance data loaded asynchronously, the memo never recalculated — causing FOUC

**Fix Applied:**

1. Changed `ClientMetricsContext.tsx` to use `priorYear` instead of `currentYear` for compliance:
   ```typescript
   const priorYear = currentYear - 1
   useEventCompliance(clientName, priorYear)
   ```

2. Changed `page.tsx` (v2) to use `priorYear` for both compliance and predictions:
   ```typescript
   const priorYear = currentYear - 1
   useEventCompliance(client?.name || '', priorYear)
   useCompliancePredictions(client?.name || '', priorYear)
   ```

3. Added `eventCompliance` to LeftColumn useMemo dependency array:
   ```typescript
   }, [client, eventCompliance])
   ```

**Files changed:**
- `src/contexts/ClientMetricsContext.tsx`
- `src/app/(dashboard)/clients/[clientId]/v2/page.tsx`
- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`

**Result:** Mount Alvernia now shows 91 in both the Portfolio Health card and the client profile detail page. No FOUC observed.

**Lesson:** When multiple contexts calculate health scores independently, they must use the same compliance year parameter. The `useMemo` dependency array must include ALL reactive values referenced inside the memo — missing an async data source causes stale renders.

---

### Issue 12: SLMC Health Score Discrepancy — Single-Client Hook Discarded Pre-Change Events

**Symptom:** Saint Luke's Medical Centre (SLMC) showed health score 37 on the Portfolio Health card but 25 on the client profile page. The card showed "Seg% 100%" but the profile's Segmentation Actions card showed 10% compliance.

**Root Cause:** The two compliance hooks handled re-segmented clients with contradictory logic:

- **`useAllClientsCompliance` (batch, card view)** — Lines 622-625: Kept ALL current-year events and added next-year Jan-Jun events on top. Comment explicitly stated: "We do NOT discard pre-change events — they still count toward the current year's compliance." Result: 3/10 event types met target = 30%.

- **`useEventCompliance` (single-client, profile view)** — Lines 322-329: Filtered events to only include those from the change month onwards. For SLMC (changed Sep 2025), this discarded Jan-Aug events, leaving only Sep-Dec events. Result: 1/10 event types met target = 10%.

**Score calculation trace:**
- Card (37): NPS(null→0)=10 + Compliance(30%)=18 + WC(0/0)=0 + Actions(11/12)=9 = 37
- Profile (25): NPS(null→0)=10 + Compliance(10%)=6 + WC(0/0)=0 + Actions(11/12)=9 = 25

**Note:** The card's "Seg% 100%" display is a separate issue — it reads `client.compliance_percentage` from the materialised view (which measures action item completion: 11/12 ≈ 100%), not the event type compliance used by the health score formula.

**Fix:** Updated `useEventCompliance` segment-change path to match the batch hook's approach — keep ALL current-year events (using `ec.actual_count` directly from the materialised view) and ADD next-year Jan-Jun events on top:

```typescript
// BEFORE (discarded pre-change events):
const filteredEvents = (ec.events || []).filter((e) => {
  return eventDate.getMonth() + 1 >= changeMonth
})

// AFTER (keeps ALL current-year events):
combinedEvents[ec.event_type_id] = {
  expected: ec.expected_count,
  actual: ec.actual_count,
  events: ec.events || [],
}
```

**Files changed:**
- `src/hooks/useEventCompliance.ts`

**Result:** SLMC now shows 37 in both the Portfolio Health card and the client profile detail page. Compliance displays as 30% in both views.

**Lesson:** When two hooks implement the same business logic for different contexts (batch vs single-client), any divergence in event filtering creates silent score discrepancies. The batch hook had the correct rationale: pre-change events were legitimately performed and should count toward compliance regardless of when the segment changed.

---

## Related Files

- `src/hooks/useEventCompliance.ts` - Year handling fix, cross-year window fix for list view
- `src/contexts/ClientMetricsContext.tsx` - Year mismatch fix (Issue 11)
- `src/app/(dashboard)/clients/[clientId]/v2/page.tsx` - Year mismatch fix (Issue 11)
- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` - Stale useMemo fix (Issue 11)
- `src/lib/segment-deadline-utils.ts` - Segment change detection and deadline calculation
- `supabase/migrations/20251127_seed_tier_requirements.sql` - Original seed (stale, not modified)
- `supabase/migrations/20251223000000_update_compliance_view_with_exclusions.sql` - Materialised view definition

## Source Documents

- APAC Client Segmentation Activity Register 2026.xlsx (OneDrive)
- Altera APAC Client Segmentation Best Practice Guide (August 2024) - original seed source
