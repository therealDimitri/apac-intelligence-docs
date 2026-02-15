# Critical Data Issues Summary

**Date:** 2025-11-30
**Status:** Multiple data integrity issues discovered during UI overhaul

## ✅ Phase 1 Complete: Actions & Briefing Room UI Overhaul

### Successfully Delivered

**Actions & Tasks Page:**

- ✅ Multi-owner pills display (showing all owners as blue badges)
- ✅ Edit functionality with EditActionModal integration
- ✅ Database consolidation (165 → 52 actions, multi-owner support)
- ✅ Visual improvements (Users icon, "+X more" indicator)

**Briefing Room (Meetings) Page:**

- ✅ Edit functionality with EditMeetingModal integration
- ✅ Delete functionality with soft delete and confirmation
- ✅ Comprehensive form (Basic Info, Content, Resources sections)
- ✅ Auto-refetch after operations

**Files Modified:**

- `src/app/(dashboard)/actions/page.tsx` (~50 lines changed)
- `src/app/(dashboard)/meetings/page.tsx` (~40 lines changed)

---

## ⚠️ Critical Data Issues Discovered

While implementing the UI overhaul, discovered **4 critical data integrity issues** that prevent proper functionality:

### Issue #1: Giants Segment Clients Missing NPS Comments Data

**User Report:** "Giants still don't have NPS comments data, why?"

**Status:** Under investigation

**Symptoms:**

- Clients in Giant and Sleeping Giant segments don't show NPS feedback comments
- May be related to name mismatches or data import issues

**Investigation Created:**

- Script: `scripts/check-giants-nps-comments.mjs`
- Schema check: `scripts/check-nps-clients-schema.mjs`

**Next Steps:**

1. Complete investigation with schema check
2. Identify root cause (name mismatch vs missing data)
3. Fix data import or mapping logic
4. Verify all Giant segment clients have comments displayed

---

### Issue #2: Segmentation Events NOT Reconciling (CRITICAL)

**User Report:** "Client Segmentation events are STILL NOT RECONCILING. SAHealth is an example."

**Status:** **ROOT CAUSE IDENTIFIED**

**Critical Finding:**

- ✅ **The `expected_count` column DOES NOT EXIST in the `segmentation_events` table**
- ✅ **The `period` column DOES NOT EXIST in the `segmentation_events` table**

**Current Table Schema:**

```sql
segmentation_events columns:
- id
- client_name
- client_segmentation_id
- event_type_id
- event_date
- event_month
- event_year
- completed
- completed_date
- completed_by
- notes
- meeting_link
- created_at
- updated_at
- created_by

MISSING:
- expected_count (required for compliance calculation)
- period (required for quarterly/annual filtering)
```

**Impact:**

- UI cannot calculate compliance (completed/expected)
- Shows "4/0 completed" (4 events completed out of 0 expected)
- All expected counts default to 0 or undefined
- Reconciliation completely broken

**Root Cause Analysis:**

The UI is trying to get `expected_count` from `segmentation_events` table, but:

1. The column doesn't exist in the table
2. Expected count should come from `tier_event_requirements` table
3. Requires JOIN logic:
   - Get client segment from `nps_clients`
   - Get tier_id for that segment from `segmentation_tiers`
   - JOIN with `tier_event_requirements` to get `required_count` per event type
   - Compare actual event count vs `required_count`

**Example Data from Investigation:**

```
📊 SA Health (Sunrise):
   Segment: Giant
   ✅ 122 events in segmentation_events

   Event breakdown by type:
     - Strategic Ops Plan: 6/0 completed (should be 6/2)
     - Updating Client 360: 20/0 completed (should be 20/12)
     - CE On-Site Attendance: 20/0 completed (should be 20/12)
     - Whitespace Demos: 14/0 completed (should be 14/4)

   All showing /0 because expected_count column doesn't exist!
```

**Required Fixes:**

**Option A: Add Columns to segmentation_events (RECOMMENDED)**

```sql
ALTER TABLE segmentation_events
ADD COLUMN expected_count INTEGER,
ADD COLUMN period TEXT; -- e.g., 'Q1 2025', '2025', etc.
```

Then populate with:

```sql
UPDATE segmentation_events se
SET expected_count = (
  SELECT ter.required_count
  FROM nps_clients nc
  JOIN segmentation_tiers st ON nc.segment = st.tier_name
  JOIN tier_event_requirements ter ON st.id = ter.tier_id
  WHERE nc.client_name = se.client_name
    AND ter.event_type_id = se.event_type_id
)
```

**Option B: Fix UI to JOIN at Query Time**

- Modify hooks/queries to JOIN with tier_event_requirements
- Calculate expected_count dynamically
- More complex but avoids denormalization

**Recommendation:** Option A for performance and simplicity

**Investigation Scripts Created:**

- `scripts/investigate-sahealth-reconciliation.mjs`
- `scripts/check-tier-requirements-schema.mjs`
- `scripts/check-segmentation-events-expected-count.mjs`

---

### Issue #3: SA Health Sub-Clients Not Displaying Parent NPS Scores

**User Report:** "SA Health sub-clients are still not displaying NPS scores. For this view, they must display the parent SAHealth scores"

**Status:** Not yet investigated

**Description:**

- SA Health has 3 sub-clients: iPro, iQemo, Sunrise
- Each sub-client should display the parent "SA Health" NPS score
- Currently showing null/0 or individual scores instead of parent

**Likely Causes:**

1. UI not mapping sub-clients to parent client for NPS lookup
2. NPS responses stored under parent name but UI filtering by sub-client name
3. Missing parent-child relationship in database

**Required Investigation:**

1. Check if NPS responses exist for parent "SA Health"
2. Check if sub-clients have their own separate NPS responses
3. Determine expected behavior: parent score OR aggregated score OR individual scores
4. Fix mapping logic in UI or database

---

### Issue #4: CSE Profile Photos Broken

**User Report:** Screenshot showing broken image icons for CSE profiles

**Status:** Dev server restarted, not yet investigated

**Symptoms:**

- CSE profile photos showing as broken image placeholders
- Affects: BoonTeck Lim, Gilbert So, Jonathan Salisbury, Nikki Wei, etc.

**Likely Causes:**

1. Photo URL construction incorrect in `useCSEProfiles` hook
2. Supabase storage bucket permissions issue (not public)
3. Photo paths in database incorrect (missing `/photos/` prefix)
4. File extensions mismatch (.jpeg vs .jpg)

**Hook Location:**

- `src/hooks/useCSEProfiles.ts` (lines 67-78)
- Constructs URL: `${SUPABASE_URL}/storage/v1/object/public/cse-photos/${photoPath}`

**Investigation Needed:**

1. Check actual photo URLs in browser console (404 errors?)
2. Verify bucket `cse-photos` is public
3. Check photo_url values in `cse_profiles` table
4. Test with known CSE to see actual vs expected URL

---

## 📋 Recommended Action Plan

### Immediate Priority (Week 1)

1. **Fix Segmentation Events Reconciliation** (CRITICAL)
   - Add `expected_count` and `period` columns to `segmentation_events`
   - Populate expected_count from tier_event_requirements
   - Update UI to display correct compliance percentages
   - Test with SA Health (Sunrise) as example

2. **Fix SA Health Sub-Client NPS Score Display**
   - Investigate parent-child relationship logic
   - Implement parent score mapping for sub-clients
   - Test with all 3 SA Health variants

3. **Fix CSE Profile Photos**
   - Debug photo URL construction
   - Verify storage bucket permissions
   - Test photo loading for all CSEs

### Medium Priority (Week 2)

4. **Investigate Giants NPS Comments**
   - Complete schema analysis
   - Fix data import or mapping
   - Verify all Giant segment clients show comments

---

## 🛠 Technical Debt Created

**Database Schema Issues:**

- Missing columns in `segmentation_events` table
- Denormalization needed or complex JOIN queries required
- Parent-child client relationships not properly modeled

**UI/Hook Issues:**

- `useEventCompliance` hook assumes `expected_count` exists
- Photo URL construction not tested in production
- NPS data mapping doesn't handle sub-clients

**Data Quality Issues:**

- Possible name mismatches between tables
- Inconsistent client naming (SA Health vs SA Health (iPro))
- Event counts not matching tier requirements

---

## 📊 Impact Assessment

**User Impact:**

- ❌ Segmentation compliance metrics completely broken
- ❌ SA Health sub-clients missing critical NPS data
- ❌ CSE profiles look unprofessional with broken images
- ❌ Giants segment missing NPS feedback insights

**Dashboard Reliability:**

- High Priority Fixes: 2 (Segmentation reconciliation, SA Health NPS)
- Medium Priority Fixes: 2 (CSE photos, Giants comments)

**Estimated Fix Time:**

- Segmentation reconciliation: 4-6 hours (migration + UI updates)
- SA Health NPS scores: 2-3 hours (parent mapping logic)
- CSE profile photos: 1-2 hours (URL debugging)
- Giants NPS comments: 2-3 hours (data investigation)

**Total Estimated:** 9-14 hours of development work

---

## ✅ Next Steps

1. Review this summary
2. Prioritize which issues to fix first
3. Run diagnostic scripts to complete investigations
4. Implement fixes starting with segmentation reconciliation
5. Test thoroughly with SA Health example
6. Deploy and verify all data displays correctly

**Current Status:** UI overhaul complete ✅, Data fixes pending ⏳
