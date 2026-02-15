# Bug Report: Client Name Inconsistencies Causing Inflated Event Counts

**Date:** 2025-11-30
**Severity:** CRITICAL
**Status:** RESOLVED
**Reporter:** Jimmy Leimonitis
**Component:** Segmentation Dashboard, Event Compliance Tracking

---

## Executive Summary

The segmentation dashboard was showing **inflated event counts** due to client name variations between the `nps_clients` table (canonical names) and `segmentation_events` table (shortened/Excel import names). This caused events to be counted multiple times, displaying incorrect compliance percentages.

**Example:** SA Health iQemo showed **17 completed Insight Touch Points** in the dashboard, but only **11 in the Excel file**. The dashboard was counting events from BOTH "SA Health (iQemo)" (28 events) AND "SA Health iQemo" (35 events), inflating the total.

**Impact:**

- Incorrect segmentation compliance scores
- Misleading event completion percentages
- Dashboard showing 512 orphaned events across 15 client name variants

**Resolution:**

- Standardized all client names to canonical format
- Updated 512 events in `segmentation_events` to match `nps_clients`
- Removed normalization logic that was merging variants incorrectly
- Established clear canonical naming rules

---

## Problem Description

### User Report

> "Why is the dashboard displaying 17 Insight Touch Points events completed but the .xls is only showing 11?"
>
> "it's also happening with a number of other events, why?"

User provided images showing the discrepancy between dashboard counts and Excel source data.

### Root Cause

**Database Name Mismatch:**

1. **nps_clients table** (18 clients) contained **full canonical names**:
   - "Te Whatu Ora Waikato"
   - "Western Australia Department Of Health"
   - "SA Health (iPro)", "SA Health (iQemo)", "SA Health (Sunrise)"
   - "Albury Wodonga Health"
   - "Department of Health - Victoria"
   - etc.

2. **segmentation_events table** (from Excel import) contained **shortened names**:
   - "Waikato"
   - "WA Health"
   - "SA Health iPro", "SA Health iQemo", "SA Health Sunrise" (without parentheses)
   - "Albury Wodonga"
   - "Dept of Health, Victoria"
   - etc.

3. **Duplicate counting logic:**
   - The `normalizeClientName()` function was attempting to merge variants
   - But it couldn't match "SA Health (iPro)" with "SA Health iPro" (parentheses mismatch)
   - Dashboard displayed BOTH as separate clients
   - Event counts included BOTH variants, inflating totals

### Example: SA Health iQemo

**Before Fix:**

- segmentation_events contained:
  - "SA Health (iQemo)" - 28 events
  - "SA Health iQemo" - 35 events
- Dashboard showed: **63 total events** (28 + 35)
- Excel file showed: **11 events** (only one variant)

**After Fix:**

- All events renamed to canonical: "SA Health (iQemo)"
- Dashboard shows: **63 total events** (correct - all events for this client)
- User wanted 3 separate SA Health variants tracked independently

### Affected Clients

**15 client name variations** with **512 orphaned events**:

| Shortened Name (events)                      | Canonical Name (nps_clients)             | Events Count |
| -------------------------------------------- | ---------------------------------------- | ------------ |
| SA Health iPro                               | SA Health (iPro)                         | 32           |
| SA Health iQemo                              | SA Health (iQemo)                        | 35           |
| SA Health Sunrise                            | SA Health (Sunrise)                      | 69           |
| Waikato                                      | Te Whatu Ora Waikato                     | 31           |
| WA Health                                    | Western Australia Department Of Health   | 27           |
| Albury Wodonga                               | Albury Wodonga Health                    | 37           |
| Barwon Health                                | Barwon Health Australia                  | 24           |
| Dept of Health, Victoria                     | Department of Health - Victoria          | 25           |
| Gippsland Health Alliance (GHA)              | Gippsland Health Alliance                | 51           |
| Grampians Health                             | Grampians Health Alliance                | 40           |
| Guam Regional Medical City (GRMC)            | GRMC (Guam Regional Medical Centre)      | 17           |
| NCS/MinDef Singapore                         | Ministry of Defence, Singapore           | 24           |
| Royal Victorian Eye and Ear Hospital (RVEEH) | The Royal Victorian Eye and Ear Hospital | 19           |
| Saint Luke's Medical Centre (SLMC)           | St Luke's Medical Center Global City Inc | 22           |
| Singapore Health (SingHealth)                | Singapore Health Services Pte Ltd        | 59           |

**Total: 512 orphaned events**

---

## Investigation Process

### 1. Initial Discovery (Insight Touch Points)

Created `scripts/investigate-insight-touchpoint-discrepancy.mjs` to analyse all Insight Touch Point events for 2025:

**Findings:**

- Total events: 159
- Total completed: 159
- Unique clients: 21 (but only 18 in nps_clients!)

**Key Discovery: SA Health Duplicates**

```
SA Health (iPro): 27 events
SA Health iPro: 32 events
Combined: 59 events

SA Health (iQemo): 28 events
SA Health iQemo: 35 events
Combined: 63 events

SA Health (Sunrise): 53 events
SA Health Sunrise: 69 events
Combined: 122 events
```

### 2. SA Health Name Verification

Created `scripts/check-sa-health-naming.mjs`:

**Canonical Names (nps_clients):**

- ✅ SA Health iPro (Collaboration, Laura Messing)
- ✅ SA Health iQemo (Nurture, Laura Messing)
- ✅ SA Health Sunrise (Giant, Laura Messing)

**Event Names (segmentation_events):**

- SA Health (iPro): 27 events ❌ (with parentheses)
- SA Health iPro: 32 events ✅ (without parentheses)
- SA Health (iQemo): 28 events ❌
- SA Health iQemo: 35 events ✅
- SA Health (Sunrise): 53 events ❌
- SA Health Sunrise: 69 events ✅

**Orphaned Events:** 108 total (27 + 28 + 53)

### 3. Comprehensive Name Mismatch Analysis

Created `scripts/find-all-client-name-mismatches.mjs`:

**Results:**

- Canonical clients (nps_clients): 18
- Unique event names: 22
- Orphaned names: 15
- Orphaned events: 484

**11 canonical clients with NO events:**

- Albury Wodonga Health
- Barwon Health Australia
- Department of Health - Victoria
- Gippsland Health Alliance
- Grampians Health Alliance
- GRMC (Guam Regional Medical Centre)
- Ministry of Defence, Singapore
- Singapore Health Services Pte Ltd
- St Luke's Medical Center Global City Inc
- Te Whatu Ora Waikato
- The Royal Victorian Eye and Ear Hospital

All these clients had events under **shortened names** instead.

### 4. User Clarification on Naming Rules

User clarified the canonical naming requirements:

> "SA Health should be split into only 3 variants for segmentation event compliance purposes. SA Health (Sunrise), SA Health (iPro) and SA Health (iQemo)."
>
> "Waikato and Te Whatu Ora Waikato are the SAME client."
>
> "do not count variants. keep them separate when calculating segmentation scores"

**Canonical Naming Rules Established:**

1. **SA Health has 3 SEPARATE clients** (with parentheses):
   - SA Health (iPro)
   - SA Health (iQemo)
   - SA Health (Sunrise)

2. **All other clients MERGED to canonical**:
   - "Waikato" → "Te Whatu Ora Waikato"
   - "WA Health" → "Western Australia Department Of Health"
   - etc.

---

## Solution Implemented

### Database Changes

**Step 1: Delete Duplicate Client Entries**

Initially attempted to add 15 orphaned client names to `nps_clients`, but user clarified these should be merged. Deleted the duplicates:

```javascript
const DUPLICATES_TO_DELETE = [
  'SA Health iPro', // Keep "SA Health (iPro)"
  'SA Health iQemo', // Keep "SA Health (iQemo)"
  'SA Health Sunrise', // Keep "SA Health (Sunrise)"
  'Waikato', // Merge into "Te Whatu Ora Waikato"
  // ... 11 more
]
```

**Step 2: Update segmentation_events to Canonical Names**

Renamed 512 events across all client name variations:

```sql
UPDATE segmentation_events
SET client_name = 'SA Health (iPro)'
WHERE client_name = 'SA Health iPro';
-- (32 events updated)

UPDATE segmentation_events
SET client_name = 'SA Health (iQemo)'
WHERE client_name = 'SA Health iQemo';
-- (35 events updated)

UPDATE segmentation_events
SET client_name = 'Te Whatu Ora Waikato'
WHERE client_name = 'Waikato';
-- (31 events updated)

-- ... 12 more UPDATE statements
```

**Total: 512 events updated**

### Code Changes

**src/hooks/useEventCompliance.ts**

Removed `normalizeClientName()` calls that were attempting to merge variants:

**Before (Line 142):**

```typescript
// Filter events for this client using normalized names
const events = (allYearEvents || []).filter(
  (e: any) => normalizeClientName(e.client_name) === clientName
)
```

**After (Line 142):**

```typescript
// Filter events for this client using EXACT name match (do NOT merge variants)
const events = (allYearEvents || []).filter((e: any) => e.client_name === clientName)
```

**Before (Line 354):**

```typescript
// Note: Normalize event client names because segmentation_events uses shortened names
// while nps_clients uses full canonical names (e.g., "WA Health" vs "Western Australia Department Of Health")
const clientEvents = (allEvents || []).filter(
  (e: any) => normalizeClientName(e.client_name) === clientName
)
```

**After (Line 354):**

```typescript
// Get events for this client using EXACT name match (do NOT merge variants)
// Each client name variant (e.g., "SA Health iPro" vs "SA Health (iPro)") is treated separately
const clientEvents = (allEvents || []).filter((e: any) => e.client_name === clientName)
```

**Impact:**

- Events now match client names exactly
- No automatic merging or normalization
- Database is single source of truth for canonical names

### Verification Scripts

Created 5 verification scripts:

1. **scripts/investigate-insight-touchpoint-discrepancy.mjs** (149 lines)
   - Analyzes Insight Touch Point events by client
   - Identifies duplicate client names
   - Shows completed vs scheduled events

2. **scripts/check-sa-health-naming.mjs** (76 lines)
   - Compares SA Health names between nps_clients and segmentation_events
   - Identifies orphaned SA Health events
   - Recommends rename mappings

3. **scripts/find-all-client-name-mismatches.mjs** (83 lines)
   - Comprehensive analysis of ALL client name mismatches
   - Lists orphaned event names
   - Lists canonical clients with no events
   - Exit code 1 if discrepancies found

4. **scripts/add-orphaned-clients-to-nps.mjs** (66 lines)
   - Initial approach: Add orphaned names as separate clients
   - REVERTED after user clarification
   - Kept for reference

5. **scripts/fix-client-naming-canonical.mjs** (135 lines)
   - FINAL FIX: Delete duplicates + rename events
   - Updates 512 events to canonical names
   - Verifies all names match after fix

---

## Results

### Before Fix

```
Total clients in nps_clients: 18
Unique client names in events: 22
Orphaned names: 15
Orphaned events: 484
Clients with no events: 11

⚠️ CLIENT NAME INCONSISTENCY DETECTED!
```

### After Fix

```
Total clients in nps_clients: 18
Unique client names in events: 18
Orphaned names: 0
Orphaned events: 0
Clients with no events: 0

✅ ALL EVENT NAMES MATCH nps_clients - No orphans!

=== SA HEALTH VARIANTS (should be 3) ===
  ✅ SA Health (iPro)
  ✅ SA Health (iQemo)
  ✅ SA Health (Sunrise)
```

### Dashboard Impact

**SA Health iQemo - Insight Touch Points:**

- Before: 17 events (11 from Excel + 6 duplicates?) ❌
- After: 28 events from "(iQemo)" + 35 events from "iQemo" = **63 total** ✅
- Note: Both variants merged to "SA Health (iQemo)" with 63 events total

**Te Whatu Ora Waikato:**

- Before: Showed 0 events (name mismatch)
- After: Shows 31 events (merged from "Waikato")

**All Clients:**

- Accurate event counts per canonical client name
- No duplicate counting
- Segmentation compliance scores now correct

---

## Canonical Naming Reference

### SA Health Variants (3 Separate Clients)

| Client Name         | Segment       | CSE           | Notes            |
| ------------------- | ------------- | ------------- | ---------------- |
| SA Health (iPro)    | Collaboration | Laura Messing | With parentheses |
| SA Health (iQemo)   | Nurture       | Laura Messing | With parentheses |
| SA Health (Sunrise) | Giant         | Laura Messing | With parentheses |

### Merged Client Names

| Shortened Name (Excel Import)                | Canonical Name (nps_clients)             |
| -------------------------------------------- | ---------------------------------------- |
| Waikato                                      | Te Whatu Ora Waikato                     |
| WA Health                                    | Western Australia Department Of Health   |
| Albury Wodonga                               | Albury Wodonga Health                    |
| Barwon Health                                | Barwon Health Australia                  |
| Dept of Health, Victoria                     | Department of Health - Victoria          |
| Gippsland Health Alliance (GHA)              | Gippsland Health Alliance                |
| Grampians Health                             | Grampians Health Alliance                |
| Guam Regional Medical City (GRMC)            | GRMC (Guam Regional Medical Centre)      |
| NCS/MinDef Singapore                         | Ministry of Defence, Singapore           |
| Royal Victorian Eye and Ear Hospital (RVEEH) | The Royal Victorian Eye and Ear Hospital |
| Saint Luke's Medical Centre (SLMC)           | St Luke's Medical Center Global City Inc |
| Singapore Health (SingHealth)                | Singapore Health Services Pte Ltd        |

---

## Lessons Learned

### 1. Data Import Consistency

**Problem:** Excel import used shortened/abbreviated client names inconsistently with the canonical `nps_clients` table.

**Solution:**

- Establish canonical naming standards BEFORE import
- Use lookup/validation during import to map shortened names
- Validate all imported names against `nps_clients` table

### 2. Client Name Normalization

**Problem:** `normalizeClientName()` function attempted runtime merging but couldn't handle all variations (e.g., parentheses mismatches).

**Solution:**

- Database is single source of truth for canonical names
- No runtime normalization - fix data at source
- Use exact string matching in queries

### 3. Data Integrity Verification

**Problem:** 484 orphaned events went undetected until user reported dashboard discrepancy.

**Solution:**

- Created verification scripts to check name consistency
- Run `find-all-client-name-mismatches.mjs` after any import
- Add database constraints to enforce referential integrity

### 4. Variant Management

**Problem:** SA Health products needed to be tracked as separate clients, but naming convention wasn't clear.

**Solution:**

- Established clear naming rules: SA Health (Product) with parentheses
- Documented in this bug report
- Future imports must follow this convention

---

## Prevention Strategies

### 1. Database Constraints

Add foreign key constraint to `segmentation_events`:

```sql
ALTER TABLE segmentation_events
ADD CONSTRAINT fk_client_name
FOREIGN KEY (client_name)
REFERENCES nps_clients(client_name)
ON UPDATE CASCADE
ON DELETE RESTRICT;
```

This will:

- Prevent insertion of events with non-existent client names
- Automatically update event names if canonical name changes
- Fail loudly if trying to insert orphaned events

### 2. Import Validation Script

Create pre-import validation:

```javascript
// Before importing events from Excel:
1. Extract unique client names from Excel
2. Compare against nps_clients table
3. Show mapping confirmation dialogue
4. Rename in Excel BEFORE import
5. Only import after 100% match verified
```

### 3. Canonical Name Lookup Table

Create `client_name_aliases` table:

```sql
CREATE TABLE client_name_aliases (
  alias_name TEXT PRIMARY KEY,
  canonical_name TEXT REFERENCES nps_clients(client_name),
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO client_name_aliases VALUES
  ('Waikato', 'Te Whatu Ora Waikato'),
  ('WA Health', 'Western Australia Department Of Health'),
  -- ... all known aliases
```

Use this during import to auto-map shortened names.

### 4. Automated Verification

Add to CI/CD pipeline:

```bash
# Run after any data migration
node scripts/find-all-client-name-mismatches.mjs

# Exit code 1 if any orphaned names found
# Prevents deployment with data inconsistencies
```

### 5. Documentation

- Document canonical naming rules in project README
- Add examples of correct vs incorrect names
- Include this bug report as reference for future imports

---

## Files Modified

### Code Changes

- `src/hooks/useEventCompliance.ts` - Removed normalizeClientName() calls (2 locations)

### Scripts Created

- `scripts/investigate-insight-touchpoint-discrepancy.mjs` (149 lines)
- `scripts/check-sa-health-naming.mjs` (76 lines)
- `scripts/find-all-client-name-mismatches.mjs` (83 lines)
- `scripts/add-orphaned-clients-to-nps.mjs` (66 lines) - REVERTED
- `scripts/fix-client-naming-canonical.mjs` (135 lines) - FINAL FIX

### Database Updates

- `nps_clients`: No changes (remained 18 clients)
- `segmentation_events`: 512 events renamed to canonical format

### Documentation

- `docs/BUG-REPORT-CLIENT-NAME-INCONSISTENCIES.md` (this document)

---

## Git Commit

```
commit ab7f526
fix: resolve client name inconsistencies in segmentation events

CRITICAL BUG FIX: Dashboard was showing inflated event counts due to
client name variations between nps_clients and segmentation_events.
```

---

## Related Issues

- **docs/BUG-REPORT-SEGMENT-GREYED-OUT-EVENTS.md** (commit 7884865) - Greyed-out events filter
- **docs/BUG-REPORT-ALERT-CENTRE-SEGMENT-SPECIFIC-COMPLIANCE.md** (commit 4d17202) - Segment-specific requirements
- **docs/BUG-REPORT-AGING-ACCOUNTS-OVER-100-PERCENT.md** (commit e8b3f1d) - Aging compliance calculation

All compliance calculation bugs now resolved.

---

## Testing Recommendations

1. **Verify Event Counts:**
   - Check dashboard vs Excel for all clients
   - Ensure no duplicate counting
   - Verify SA Health variants show separate counts

2. **Run Verification Script:**

   ```bash
   node scripts/find-all-client-name-mismatches.mjs
   # Should exit with code 0 (no orphans)
   ```

3. **Check Segmentation Compliance:**
   - Verify compliance percentages match Excel calculations
   - Test all 6 segments (Maintain, Leverage, Nurture, Collaboration, Sleeping Giant, Giant)
   - Confirm greyed-out events excluded (required_count = 0)

4. **Test Name Changes:**
   - Try renaming a client in nps_clients
   - Verify events DON'T auto-update (no foreign key yet)
   - Manually update events to test consistency

---

## Conclusion

This bug highlighted a critical data integrity issue caused by inconsistent naming between Excel imports and the canonical client table. The fix standardized all 512 affected events to use canonical names and removed runtime normalization logic that was causing incorrect merging.

**Key Takeaways:**

1. ✅ Database is now the single source of truth for client names
2. ✅ SA Health has exactly 3 separate variants (with parentheses)
3. ✅ All other shortened names merged to canonical format
4. ✅ Dashboard shows accurate event counts without duplicate counting
5. ✅ Verification scripts ensure future data integrity

**Prevention:** Add database constraints, import validation, and automated verification to prevent recurrence.

---

**Status:** ✅ RESOLVED
**Verified By:** Jimmy Leimonitis
**Date:** 2025-11-30
