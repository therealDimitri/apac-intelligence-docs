# Bug Report: Compliance Event Percentages Not Reconciling

**Date:** 2025-12-03
**Severity:** High (Data Accuracy Issue)
**Status:** 🔍 Root Cause Identified, Fix In Progress
**Affected Components:** Event Compliance Summary, Materialized View, Segment Change Handling

---

## Problem Summary

Clients with segment changes in 2025 are showing incorrect compliance percentages (>100%) because the materialized view is using expected counts from only the latest segment period instead of taking the MAX across all segment periods for the year.

**Example: Epworth Healthcare**

- Segment change: Leverage (Jan-Aug) → Maintain (Sep-Dec)
- Strategic Ops Plan:
  - **Current display:** 4 completed / 1 expected = 400% ❌
  - **Should display:** 4 completed / 2 expected = 200% ✓
  - (Leverage tier requires 2, Maintain requires 1, MAX = 2)

**Visual Evidence:**
Screenshot shows Epworth with 63% overall compliance but multiple events showing 300-500% completion rates.

---

## Root Cause Analysis

### Issue 1: Column Name Mismatch

The materialized view SQL (line 65) references `ter.required_count`, but the actual `tier_event_requirements` table column is named `frequency`.

**Impact:** This causes the MAX aggregation logic to fail silently, returning NULL or incorrect values.

### Issue 2: Segment Change Aggregation Logic

The `combined_requirements` CTE is supposed to take the MAX of required counts across all segment periods, but due to the column name mismatch, it's only using the latest segment's requirements.

**Affected SQL (line 85):**

```sql
MAX(tr.required_count) as required_count  -- ❌ Column doesn't exist
```

**Should be:**

```sql
MAX(tr.frequency) as required_count  -- ✓ Correct column name
```

---

## Affected Clients

All clients with segment changes in 2025 show incorrect expected counts:

| Client             | Segment Change          | Example Over-Serviced Event        |
| ------------------ | ----------------------- | ---------------------------------- |
| Epworth Healthcare | Leverage → Maintain     | Strategic Ops: 4/1 (should be 4/2) |
| SA Health (iPro)   | Nurture → Collaboration | TBD                                |
| Grampians Health   | TBD                     | Multiple events                    |
| And others...      |                         |                                    |

**Total Impact:** 17 clients in 2025, subset have segment changes

---

## Investigation Timeline

1. **Initial Report:** User reported "Compliance events are not reconciling" with screenshot
2. **Client Identification:** Matched screenshot pattern to Epworth Healthcare (63% compliance)
3. **Data Verification:** Confirmed event counts are accurate in `segmentation_events` table
4. **Tier Analysis:** Discovered Epworth had 2 segment periods with different requirements:
   - Jan-Aug (Leverage): Strategic Ops requires **2**, Updating Client 360 requires **4**, Whitespace requires **2**
   - Sep-Dec (Maintain): Strategic Ops requires **1**, Updating Client 360 requires **2**, Whitespace requires **1**
5. **Expected Behavior:** View should use MAX (2, 4, 2) but is using Maintain values (1, 2, 1)
6. **Root Cause:** SQL column mismatch prevents MAX aggregation from working

---

## Attempted Solutions

### ✅ Solution Created (Not Yet Verified)

**File:** `docs/migrations/20251203_fix_materialized_view_column_name.sql`

**Changes:**

1. Line 65: Changed `ter.required_count` → `ter.frequency as required_count`
2. Line 71: Changed `WHERE ter.required_count > 0` → `WHERE ter.frequency > 0`
3. Added comprehensive documentation and verification queries

**Status:** Migration SQL created and executed, but verification shows data unchanged

---

## Next Steps (Recommended)

### Immediate Actions:

1. **Verify materialized view was actually refreshed:**

   ```sql
   SELECT last_updated FROM event_compliance_summary LIMIT 1;
   ```

   - If timestamp is old, view didn't refresh
   - Manual refresh: `REFRESH MATERIALIZED VIEW event_compliance_summary;`

2. **Check if migration actually applied:**

   ```sql
   SELECT pg_get_viewdef('event_compliance_summary');
   ```

   - Verify SQL uses `frequency` not `required_count`

3. **Debug combined_requirements CTE:**
   - Run CTE queries individually to identify where aggregation fails
   - Check if `MAX(tr.frequency)` is actually being calculated

4. **Consider alternative fix:**
   - If MAX aggregation still doesn't work, might need to restructure CTE logic
   - Possible workaround: Use window functions or different JOIN approach

### Long-Term Actions:

1. **Schema Consistency:**
   - Rename `frequency` column to `required_count` in `tier_event_requirements` table
   - Or update all documentation to use `frequency` terminology
   - Prevents future confusion

2. **Add Data Validation:**
   - Create tests that verify compliance percentages for clients with known segment changes
   - Alert if any client shows >200% on any event type (likely indicates aggregation bug)

3. **Documentation:**
   - Document expected behavior for segment changes in tier requirements
   - Add examples showing correct vs incorrect calculations

---

## Verification Queries

### Check Epworth's Expected Counts

```sql
SELECT
  client_name,
  jsonb_pretty(event_compliance::jsonb) as events
FROM event_compliance_summary
WHERE client_name = 'Epworth Healthcare'
  AND year = 2025;
```

**Expected Results After Fix:**

```json
{
  "event_type_name": "Strategic Ops Plan (Partnership) Meeting",
  "expected_count": 2, // Currently shows 1
  "actual_count": 4,
  "compliance_percentage": 200 // Currently shows 400
}
```

### Verify MAX Aggregation Logic

```sql
-- Get all tier requirements for Epworth's 2 segment periods
SELECT
  t.tier_name,
  et.event_name,
  ter.frequency as required_count
FROM client_segmentation cs
JOIN tier_event_requirements ter ON ter.tier_id = cs.tier_id
JOIN segmentation_event_types et ON et.id = ter.event_type_id
JOIN segmentation_tiers t ON t.id = cs.tier_id
WHERE cs.client_name = 'Epworth Healthcare'
  AND EXTRACT(YEAR FROM cs.effective_from) = 2025
ORDER BY et.event_name, t.tier_name;
```

**Expected Output:**

- Strategic Ops Plan: Leverage (2), Maintain (1) → MAX should be 2
- Updating Client 360: Leverage (4), Maintain (2) → MAX should be 4

---

## Files Modified/Created

1. **Created:** `docs/migrations/20251203_fix_materialized_view_column_name.sql`
2. **Created:** `scripts/apply-materialized-view-column-fix.mjs`
3. **Created:** `scripts/find-epworth-compliance.mjs`
4. **Created:** `scripts/check-epworth-tier-history.mjs`
5. **Created:** `scripts/debug-combined-requirements.mjs`
6. **Created:** `scripts/verify-tier-requirements-schema.mjs`
7. **Created:** `scripts/debug-compliance-reconciliation.mjs`

---

## Lessons Learned

1. **Schema Documentation:** Column names must match between documentation and actual schema
2. **Migration Testing:** Always verify materialized view refresh after structural changes
3. **Data Validation:** Compliance percentages >200% should trigger alerts (likely indicates bug)
4. **Segment Changes:** Complex business logic (segment tier changes) requires careful aggregation handling

---

## Impact

- **Data Accuracy:** Compliance percentages are misleading for ~50% of clients (those with segment changes)
- **Business Decisions:** CSEs may make incorrect assumptions about client engagement levels
- **User Trust:** Seeing 400-500% completion rates erodes confidence in the system
- **Urgency:** High - affects active client management decisions

---

## Recommendations

**Short-term:**

- Manually verify the materialized view refresh actually happened
- Run verification queries to confirm expected counts match tier requirements
- If fix didn't work, investigate why MAX aggregation is failing

**Medium-term:**

- Add automated tests for segment change scenarios
- Create data validation rules that flag impossible percentages
- Document all segment change edge cases

**Long-term:**

- Consider redesigning tier requirements to be time-period aware
- Evaluate if materializing at client-year level is best approach
- Add comprehensive logging to track when/why view refreshes occur

---

## Status Updates

- **2025-12-03 Initial Investigation:** Root cause identified, migration created
- **2025-12-03 Migration Applied:** SQL executed but verification shows no data change
- **Next:** Debug why materialized view refresh didn't update expected counts
