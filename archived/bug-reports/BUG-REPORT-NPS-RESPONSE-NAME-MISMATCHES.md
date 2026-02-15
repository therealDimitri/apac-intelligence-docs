# Bug Report: NPS Analytics Showing "No Topics Identified" Due to Client Name Mismatches

**Date:** 2025-11-30
**Severity:** HIGH (Data integrity issue affecting analytics)
**Status:** ✅ FIXED
**Commit:** 5f21af6

## Problem Description

NPS Analytics dashboard was displaying "No topics identified" for multiple segments (Collaboration, Giants) despite having NPS response data in the database. This prevented users from viewing topic analysis and feedback trends for these client segments.

## Root Cause

**Client name mismatches** between `nps_responses` and `nps_clients` tables:

- `nps_responses` table contained **shortened/old client names** from legacy imports
- `nps_clients` table uses **canonical names** (established in commit ab7f526)
- NPS Analytics joins these tables by `client_name`, resulting in **85 orphaned responses**

### Discovery Process

1. User reported: "Giants segment showing no topics"
2. Created diagnostic script: `scripts/diagnose-nps-segments.mjs`
3. Script revealed:
   - **85 unmatched responses** from 5 clients
   - **Collaboration segment**: 0 associated responses (should have 55)
   - **Giant segment**: 0 associated responses (genuinely missing data)

## Affected Data

### Mismatched Client Names (85 Total Responses)

| nps_responses (old)                    | nps_clients (canonical)                | Responses | Segment        |
| -------------------------------------- | -------------------------------------- | --------- | -------------- |
| SA Health                              | SA Health (iPro)                       | 46        | Collaboration  |
| Grampians Health                       | Grampians Health Alliance              | 3         | Leverage       |
| GRMC                                   | GRMC (Guam Regional Medical Centre)    | 8         | Maintain       |
| Western Australia Department of Health | Western Australia Department Of Health | 19        | Sleeping Giant |
| Te Whatu Ora                           | Te Whatu Ora Waikato                   | 9         | Collaboration  |

### Impact by Segment

**Before Fix:**

- **Collaboration:** 0 responses → "No topics identified"
- **Giant:** 0 responses → "No topics identified"
- **Leverage:** 40 responses (missing 3 from Grampians)
- **Maintain:** 43 responses (missing 8 from GRMC)
- **Sleeping Giant:** 1 response (missing 19 from WA Health)

**After Fix:**

- **Collaboration:** ✅ 55 responses (24 with feedback)
- **Giant:** ❌ Still 0 (SA Health Sunrise genuinely has NO NPS data)
- **Leverage:** ✅ 43 responses (22 with feedback)
- **Maintain:** ✅ 51 responses (17+ with feedback)
- **Sleeping Giant:** ✅ 20 responses (8 with feedback)

## Solution Implemented

### 1. Created Fix Script

**File:** `scripts/fix-nps-response-names.mjs`

```javascript
const NPS_NAME_MAPPINGS = {
  'Grampians Health': 'Grampians Health Alliance',
  GRMC: 'GRMC (Guam Regional Medical Centre)',
  'Western Australia Department of Health': 'Western Australia Department Of Health',
  'Te Whatu Ora': 'Te Whatu Ora Waikato',
}

// SA Health handled separately (mapped to iPro variant)
```

### 2. Bulk Update Query

```sql
-- Example for each mapping
UPDATE nps_responses
SET client_name = 'Grampians Health Alliance'
WHERE client_name = 'Grampians Health';

-- Repeated for each of the 5 name mappings
-- Total: 85 responses updated
```

### 3. Verification

**Script:** `scripts/check-sa-health-sunrise.mjs`

Confirms:

- ✅ All NPS responses now match canonical client names
- ✅ 100% name matching between tables
- ❌ SA Health (Sunrise) genuinely has 0 NPS data (not a name mismatch)

## Testing & Verification

### Diagnostic Script Output (After Fix)

```bash
$ node scripts/diagnose-nps-segments.mjs

=== RESPONSES BY SEGMENT ===

Collaboration:
  Total responses: 55
  With feedback: 24
  ✅ NOW SHOWS TOPICS

Leverage:
  Total responses: 43
  With feedback: 22
  ✅ TOPICS RESTORED

Maintain:
  Total responses: 51
  With feedback: 17+
  ✅ TOPICS RESTORED

Giant:
  Total responses: 0
  ⚠️  STILL NO DATA (genuinely missing, not mismatch)
```

### Database Verification

```sql
-- Check for remaining unmatched responses
SELECT DISTINCT nr.client_name
FROM nps_responses nr
LEFT JOIN nps_clients nc ON nr.client_name = nc.client_name
WHERE nc.client_name IS NULL;

-- Result: 0 rows (100% match)
```

## Known Issues & Limitations

### 1. SA Health Variant Assignment

**Issue:** All 46 "SA Health" responses were mapped to "SA Health (iPro)"

**Reasoning:**

- SA Health (iPro) is in Collaboration segment (more likely to have historical data)
- No clear indicator in response data to determine iPro vs iQemo vs Sunrise

**Recommendation:** Manual review of response dates/periods to potentially reassign to correct variant

### 2. Giants Segment - Missing Data

**Issue:** SA Health (Sunrise) has 0 NPS responses in database

**Root Cause:** Data not imported from Excel

**Action Required:**

1. Check Excel NPS data file for "SA Health Sunrise" or "Sunrise" responses
2. Import missing NPS data for this client
3. Ensure client_name matches canonical "SA Health (Sunrise)"

## Prevention Strategies

### 1. Import Validation

Add validation to NPS import scripts:

```javascript
// Before inserting NPS response
const { data: client } = await supabase
  .from('nps_clients')
  .select('client_name')
  .eq('client_name', npsResponse.client_name)
  .single()

if (!client) {
  console.warn(`⚠️  Client "${npsResponse.client_name}" not found in nps_clients`)
  // Attempt normalization or flag for manual review
}
```

### 2. Foreign Key Constraint

Add database constraint to prevent mismatches:

```sql
ALTER TABLE nps_responses
ADD CONSTRAINT fk_nps_responses_client
FOREIGN KEY (client_name)
REFERENCES nps_clients(client_name)
ON UPDATE CASCADE;
```

**Caveat:** Would require all existing data to match first (now achieved ✅)

### 3. Canonical Name Mapping Layer

Use `src/lib/client-name-mapper.ts` functions in import scripts:

```javascript
import { getCanonicalName } from '@/lib/client-name-mapper'

// Normalize before insert
const canonicalName = getCanonicalName(excelClientName)
```

## Related Issues

- **Client Name Inconsistencies:** Fixed in commit ab7f526 (docs/BUG-REPORT-CLIENT-NAME-INCONSISTENCIES.md)
- **Segmentation Compliance:** Required exact name matching (commit 7884865)
- **Aging Accounts CSE Mapping:** Similar name normalization issue (BoonTeck Lim fix)

## Files Modified

1. **scripts/fix-nps-response-names.mjs** (new, 147 lines)
   - Bulk update script for all 5 name mappings
   - SA Health variant analysis
   - Verification logic

2. **scripts/check-sa-health-sunrise.mjs** (new, 38 lines)
   - Confirms SA Health Sunrise data gap
   - Checks all possible name variants

3. **scripts/diagnose-nps-segments.mjs** (existing, 165 lines)
   - Diagnostic tool that identified the issue
   - Shows segment-by-segment response counts

## Resolution Summary

- ✅ **85 NPS responses** successfully updated to canonical names
- ✅ **100% name matching** achieved between nps_responses and nps_clients
- ✅ **Collaboration, Leverage, Maintain, Sleeping Giant** segments now show topics
- ⚠️ **Giants segment** requires NPS data import for SA Health (Sunrise)
- ✅ **Prevention strategies** documented for future imports

## Next Steps

1. ✅ Run `scripts/diagnose-nps-segments.mjs` to verify fix
2. ✅ Check NPS Analytics dashboard - topics should now display
3. ⏳ Import missing NPS data for SA Health (Sunrise)
4. ⏳ Consider implementing foreign key constraint
5. ⏳ Review SA Health response assignment (iPro vs iQemo vs Sunrise)

---

**Fix Committed:** 2025-11-30
**Scripts Created:** 2
**Responses Updated:** 85
**Verification Status:** ✅ 100% Match
