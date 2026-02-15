# Bug Report: Alert Centre Compliance Calculation Using Segment-Specific Requirements

**Date:** 2025-11-30
**Severity:** 🔴 **CRITICAL**
**Status:** ✅ **FIXED**
**Commit:** `4d17202`

---

## Summary

Alert Centre was treating ALL 12 event types as required for ALL clients regardless of segment, causing artificially low compliance percentages and triggering false compliance alerts.

**Example Issue:**

- SA Health Sunrise (Giant segment) showed compliance against 12 events
- But Giant segments do NOT require "Satisfaction Action Plan"
- Should only be measured against 11 events
- Result: Artificially low compliance percentage, incorrect "missing events" list

---

## Root Cause Analysis

### The Data Model

The Excel file "APAC Client Segmentation Activity Register 2025.xlsx" contains:

- Different client segments: Giant, Leverage, Maintain, Nurture, Collaborate, Sleeping Giant
- 12 event types per client
- **Grey cells** indicate events NOT applicable for that segment
- Example: Giants don't need Satisfaction Action Plans (greyed out in Excel)

### The Import Process

The import script (`scripts/import-all-clients-events-with-grey-filter.js`) correctly:

- Detects greyed-out cells using `isGreyedOut()` function
- **Excludes** greyed-out events from `segmentation_events` table
- Only inserts events that ARE required for that client's segment

### The Broken Logic

**Original Compliance Calculation in `/api/alerts/route.ts` (BEFORE FIX):**

```typescript
// Lines 95-96: Get ALL event types
const allEventTypes = (eventTypesResult.data || []).map((et: any) => et.id)

// Lines 99-105: Assign ALL event types to EVERY client ❌
for (const client of clientsResult.data || []) {
  complianceMap.set(client.client_name, {
    completed: new Set(),
    total: new Set(allEventTypes), // ❌ WRONG: All 12 events for everyone
    missing: [],
  })
}

// Lines 108-115: Track completed events
for (const event of eventsResult.data || []) {
  if (event.completed) {
    const clientCompliance = complianceMap.get(event.client_name)
    if (clientCompliance) {
      clientCompliance.completed.add(event.event_type_id)
    }
  }
}
```

**Why This Broke:**

- **Total** = All 12 event types (hardcoded for everyone)
- **Completed** = Events marked completed in `segmentation_events`
- But `segmentation_events` only contains events applicable to that segment (greyed-out events excluded)
- Result: **Compliance = completed / all_12_events** instead of **completed / applicable_events**

---

## Impact

### Before Fix

**SA Health Sunrise (Giant segment):**

- Total events counted: 12 (including Satisfaction Action Plan)
- Actual events in database: 11 (Satisfaction Action Plan shouldn't be there)
- Compliance calculated against wrong total
- Alert Centre showed incorrect "missing events"

**All Clients:**

- Artificially low compliance percentages
- False compliance alerts triggered
- Incorrect "missing events" listed (events not applicable to segment)
- Business decisions made on incorrect metrics

### After Fix

**SA Health Sunrise (Giant segment):**

- Total events counted: 11 (correct - no Satisfaction Action Plan)
- Actual events in database: 11 (after removing incorrect event)
- Compliance correctly calculated
- Alert Centre shows accurate data

**All Clients:**

- Segment-specific compliance percentages
- Accurate compliance alerts
- Correct "missing events" lists
- Reliable business metrics

---

## Solution Implemented

### Code Changes

**Updated Logic in `src/app/api/alerts/route.ts` (Lines 92-118):**

```typescript
// Calculate compliance data from events
// IMPORTANT: Only events in segmentation_events are required for that client
// (Greyed-out events in Excel are excluded during import)
const complianceMap = new Map<
  string,
  { completed: Set<string>; total: Set<string>; missing: string[] }
>()

// Initialize compliance tracking for each client (empty - will populate from actual events)
for (const client of clientsResult.data || []) {
  complianceMap.set(client.client_name, {
    completed: new Set(),
    total: new Set(), // ✅ Start empty - will add based on segmentation_events
    missing: [],
  })
}

// Build compliance from segmentation_events (segment-specific requirements)
for (const event of eventsResult.data || []) {
  const clientCompliance = complianceMap.get(event.client_name)
  if (clientCompliance) {
    // Add this event type to client's required events
    clientCompliance.total.add(event.event_type_id)

    // If completed, also add to completed set
    if (event.completed) {
      clientCompliance.completed.add(event.event_type_id)
    }
  }
}
```

**Key Change:**

- `total` now starts EMPTY and gets populated from `segmentation_events`
- Only events that exist in the database for that client are counted as required
- Greyed-out events (not in database) are not counted

### Database Fix

Discovered and fixed data integrity issue:

- SA Health Sunrise (Giant) had 1 incorrect "Satisfaction Action Plan" event in database
- This event should have been greyed out in Excel and excluded during import
- Deleted using `scripts/fix-giant-sat-action-plan.mjs`

**Before:**

```
SA Health Sunrise: 68 total events (12 event types including Satisfaction Action Plan)
```

**After:**

```
SA Health Sunrise: 67 total events (11 event types, no Satisfaction Action Plan)
```

---

## Technical Explanation

### Segment-Specific Requirements

Each segment has different event requirements:

| Segment        | Example Client     | Typical Events Required                 |
| -------------- | ------------------ | --------------------------------------- |
| Giant          | SA Health Sunrise  | 11 events (no Satisfaction Action Plan) |
| Leverage       | Barwon Health      | 10-11 events                            |
| Maintain       | Epworth Healthcare | 8-9 events                              |
| Nurture        | Mount Alvernia     | 10-11 events                            |
| Collaborate    | SingHealth         | 11-12 events                            |
| Sleeping Giant | GRMC               | 11-12 events                            |

**Greyed-Out Events** (examples):

- Giant: Satisfaction Action Plan (not required)
- Maintain: EVP Engagement (not required)
- Leverage: Various events depending on client

### Compliance Calculation

**BEFORE (Incorrect):**

```
Total Required = 12 (all event types)
Completed = Count of completed events in database
Compliance % = (Completed / 12) × 100
```

**AFTER (Correct):**

```
Total Required = Unique event_type_ids in segmentation_events for that client
Completed = Count of completed events in database
Compliance % = (Completed / Total Required) × 100
```

---

## Verification

### Test Script

Created `scripts/test-compliance-fix.mjs` to verify the fix:

```bash
node scripts/test-compliance-fix.mjs
```

**Output:**

```
=== SA Health Sunrise ===
Segment: Giant

Total events in segmentation_events: 67

Compliance Calculation:
  Required events: 11
  Completed events: 11
  Compliance: 100.0%

=== REQUIRED EVENTS (in database) ===
  ✅ President/Group Leader Engagement (in person)
  ✅ EVP Engagement
  ✅ Strategic Ops Plan (Partnership) Meeting
  ✅ SLA/Service Review Meeting
  ✅ CE On-Site Attendance
  ✅ Insight Touch Point
  ✅ Health Check (Opal)
  ✅ Upcoming Release Planning
  ✅ Whitespace Demos (Sunrise)
  ✅ APAC Client Forum / User Group
  ✅ Updating Client 360

=== USER'S BUG REPORT CHECK ===
Satisfaction Action Plan required for Giant? ✅ NO (CORRECT)

✅ FIX VERIFIED: Compliance calculation no longer counts Satisfaction Action Plan for Giants
```

### Additional Verification Scripts

1. **scripts/check-segments.mjs** - Lists all segments and event types in database
2. **scripts/check-sat-action-plan.mjs** - Checks Giant clients for incorrect events
3. **scripts/fix-giant-sat-action-plan.mjs** - Deletes incorrect events (used for fix)
4. **scripts/check-tier-requirements.mjs** - Checks for tier_event_requirements table

---

## Files Modified

1. **src/app/api/alerts/route.ts**
   - Lines 92-118: Fixed compliance calculation logic
   - Changed from assigning all events to all clients → building from segmentation_events
   - Added comments explaining segment-specific logic
   - Lines changed: ~35 lines

2. **scripts/test-compliance-fix.mjs** (NEW - 84 lines)
   - Verification script for SA Health Sunrise
   - Shows before/after compliance calculation
   - Confirms Satisfaction Action Plan exclusion

3. **scripts/check-segments.mjs** (NEW - 47 lines)
   - Lists all distinct segments in database
   - Lists all event types
   - Useful for understanding data structure

4. **scripts/check-sat-action-plan.mjs** (NEW - 46 lines)
   - Checks which Giant clients have Satisfaction Action Plan events
   - Identifies data integrity issues

5. **scripts/fix-giant-sat-action-plan.mjs** (NEW - 61 lines)
   - Deletes incorrect Satisfaction Action Plan events for Giant clients
   - Used to fix SA Health Sunrise data

6. **scripts/check-tier-requirements.mjs** (NEW - 34 lines)
   - Checks if tier_event_requirements table exists
   - Future enhancement: use this table for segment mapping

---

## Lessons Learned

### Data Integrity

1. **Import process must match calculation logic**
   - Excel greyed-out cells → excluded from import
   - Compliance calculation must use what's in database, not hardcoded list

2. **Segment-specific requirements are critical**
   - Different segments have different event requirements
   - Cannot treat all clients the same way

3. **Verify data after import**
   - SA Health Sunrise had incorrect event in database
   - Should have been caught during import validation

### Testing Implications

1. **Test with real data** - Synthetic test data might not include segment variations
2. **Verify against business rules** - Check that Giant segments don't have excluded events
3. **Create verification scripts** for data integrity checks
4. **Validate import results** before using data for calculations

---

## Related Issues

- None (first occurrence of this specific bug)
- Related to broader segmentation compliance system
- Potential future enhancement: Use `tier_event_requirements` table for mapping

---

## Prevention

To prevent similar issues:

1. **Add data validation** after import:

   ```javascript
   // Verify no Giant clients have Satisfaction Action Plan events
   const giantClients = await supabase.from('nps_clients').select('*').eq('segment', 'Giant')
   const satActionPlanEvents = await supabase
     .from('segmentation_events')
     .select('*')
     .in(
       'client_name',
       giantClients.map(c => c.client_name)
     )
     .eq('event_type_id', SAT_ACTION_PLAN_ID)

   if (satActionPlanEvents.length > 0) {
     throw new Error('Data integrity violation: Giant clients have Satisfaction Action Plan events')
   }
   ```

2. **Add unit tests** for compliance calculation:

   ```javascript
   test('Giant segment should not count Satisfaction Action Plan', () => {
     const events = [
       /* events for Giant client */
     ]
     const compliance = calculateCompliance(events)
     expect(compliance.total).not.toContain(SAT_ACTION_PLAN_ID)
   })
   ```

3. **Document segment requirements** in code comments or database
4. **Create dashboard** showing compliance by segment with expected ranges

---

## Future Enhancements

### Use tier_event_requirements Table

The database schema includes a `tier_event_requirements` table (see `supabase/migrations/20251127_migrate_tier_requirements_schema.sql`) that maps:

- Segment → Event Type → Required Count Per Year

**Future improvement:**

1. Populate this table from Excel import
2. Use it in compliance calculation instead of segmentation_events
3. Provides clear source of truth for segment requirements

**Benefits:**

- Single source of truth for requirements
- Easier to update requirements without re-importing Excel
- Can show "expected vs actual" in dashboards
- Supports validation during import

---

## Deployment Notes

- ✅ Code committed: `4d17202`
- ✅ Database fix applied: 1 event deleted from SA Health Sunrise
- ✅ Verification scripts created and tested
- ✅ Build successful
- ✅ No breaking changes
- ✅ Backward compatible (no API changes)

**Deployment Impact:** Low risk - Fixes incorrect data display

---

## User Feedback

User reported with Excel images:

> "the calculations for segment events are incorrect. For example, SA Health Sunrise is a Giant segments do NOT have a requirement for a Satisfaction Action Plan. However you have calculated/parsed incorrectly with 2 events. Fix logic and calculations for all clients."

**Resolution:**

- ✅ Fixed calculation logic to use segment-specific requirements
- ✅ Deleted incorrect Satisfaction Action Plan event
- ✅ Verified SA Health Sunrise now shows 11 required events (correct)
- ✅ All clients now calculated with segment-specific requirements

---

## Additional Resources

- Excel File: `APAC Client Segmentation Activity Register 2025.xlsx`
- Import Script: `scripts/import-all-clients-events-with-grey-filter.js`
- Database Migration: `supabase/migrations/20251127_migrate_tier_requirements_schema.sql`
- Seed Data: `supabase/migrations/20251127_seed_tier_requirements.sql`
- Alert System: `src/lib/alert-system.ts`

---

**Report Created By:** Claude Code
**Reviewed By:** Jimmy Leimonitis
**Date Fixed:** 2025-11-30
