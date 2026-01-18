# Bug Report: Laura Messing Plan Had Wrong Opportunities

**Date**: 17 January 2026
**Severity**: High
**Status**: Fixed (Data Corrected + Code Fix Applied)
**Affected Areas**: Strategic Plan - Opportunity Strategy Step

---

## Summary

Laura Messing's Account Plan 2026 was displaying WA Health and Western Health opportunities instead of her SA Health opportunities. These are John Salisbury's clients, not Laura's.

---

## Root Cause

The `opportunities_data` field in the `strategic_plans` table was saved with incorrect data. The plan (id: `654aab36-cdd6-4b10-b2b5-f2949f359dfc`) had:

**Before Fix:**
- 7 opportunities from WA Health, Western Health, Epworth, Barwon (John's clients)

**After Fix:**
- 19 opportunities from SA Health (Laura's correct client)

### How This Likely Happened
1. Plan was created while a different CSE was selected
2. Owner was changed after opportunities were loaded
3. The save operation persisted the stale opportunities data

---

## Solution

Directly updated the `opportunities_data` in the database using the correct opportunities from `sales_pipeline_opportunities` filtered by `cse_name = 'Laura Messing'`.

### Database Update
```sql
-- Fetched Laura's opportunities
SELECT * FROM sales_pipeline_opportunities
WHERE cse_name = 'Laura Messing'
AND in_or_out = 'In'
AND forecast_category != 'Omitted'

-- Updated the plan with correct data
UPDATE strategic_plans
SET opportunities_data = [... Laura's 19 SA Health opportunities ...]
WHERE id = '654aab36-cdd6-4b10-b2b5-f2949f359dfc'
```

---

## Verification

After fix:
- **Owner**: Laura Messing
- **Territory**: SA
- **Total Opportunities**: 19
- **Client**: Minister for Health aka South Australia Health (SA Health)
- **Sample Opportunities**:
  - SA Health - Renal
  - SA Health - Sunrise renewal + Wdx 2026
  - SA Health - WCHN Sunrise Surgery License

---

## Prevention - Code Fix Applied

The root cause was in the code logic that decided whether to preserve saved opportunities when loading a plan. The code only checked if opportunities existed, not whether they matched the current owner.

### Code Changes Made

**File**: `/src/app/(dashboard)/planning/strategic/new/page.tsx`

1. **Added `cse_name` to `PipelineOpportunity` interface** (line 302):
```typescript
interface PipelineOpportunity {
  // ... existing fields ...
  cse_name?: string // Owner CSE name - used to validate ownership on load
  // ...
}
```

2. **Include `cse_name` when transforming pipeline data** (line 1514):
```typescript
const pipeline: PipelineOpportunity[] = (pipelineData || []).map(row => ({
  // ... existing fields ...
  cse_name: row.cse_name || ownerName, // Track owner for validation on load
  // ...
}))
```

3. **Validate ownership before preserving opportunities** (lines 1964-1971):
```typescript
// Before (buggy):
const shouldKeepExistingOpportunities = prev.opportunities.length > 0

// After (fixed):
const hasExistingOpportunities = prev.opportunities.length > 0

// Validate ownership: check if the first saved opportunity's CSE matches current owner
// If cse_name is missing (legacy data) or doesn't match, refresh from pipeline
const savedCseName = prev.opportunities[0]?.cse_name
const opportunitiesMatchOwner = savedCseName?.toLowerCase() === ownerName.toLowerCase()

const shouldKeepExistingOpportunities = hasExistingOpportunities && opportunitiesMatchOwner
```

**File**: `/src/app/(dashboard)/planning/strategic/new/steps/types.ts`
- Also updated `PipelineOpportunity` interface to include `cse_name` for consistency

### How This Prevents Recurrence

- When a plan is loaded, the code now validates that saved opportunities belong to the current owner
- Legacy plans without `cse_name` will automatically refresh from the pipeline (correct behaviour)
- Future plans will save `cse_name` with each opportunity, enabling proper validation
- If the owner is changed, stale opportunities from the wrong CSE are automatically replaced

---

## Related Issues

- The `sales_pipeline_opportunities` table has correct CSE assignments
- The issue was isolated to this specific saved plan's data
- Legacy plans will auto-correct on next load (fresh pipeline data replaces stale data)

---

## Files Affected

1. `/src/app/(dashboard)/planning/strategic/new/page.tsx` - Ownership validation logic
2. `/src/app/(dashboard)/planning/strategic/new/steps/types.ts` - Interface update
