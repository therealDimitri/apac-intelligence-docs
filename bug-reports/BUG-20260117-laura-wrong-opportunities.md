# Bug Report: Laura Messing Plan Had Wrong Opportunities

**Date**: 17 January 2026
**Severity**: High
**Status**: Fixed (Data Corrected)
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

## Prevention

To prevent similar issues:

1. **Reload opportunities when owner changes**: When a plan's owner is changed, automatically refresh the opportunities data from the database
2. **Validate owner-opportunity match on save**: Before saving, verify that the opportunities belong to the selected owner
3. **Add ownership audit trail**: Log when plan ownership changes and flag if opportunities mismatch
4. **UI warning**: Show a warning if loaded opportunities don't match the selected CSE

### Suggested Code Change
In `strategic/new/page.tsx`, when owner changes, force reload of opportunities:

```typescript
// When owner changes, always reload fresh opportunities
// Don't preserve stale opportunities from a different owner
const shouldKeepExistingOpportunities = false // Always refresh on owner change
```

---

## Related Issues

- The `sales_pipeline_opportunities` table has correct CSE assignments
- The issue was isolated to this specific saved plan's data

---

## Files Affected

No code changes required - this was a data fix only.
