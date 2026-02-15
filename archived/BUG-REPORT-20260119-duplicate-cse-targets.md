# Bug Report: Duplicate CSE Targets Causing Inflated Totals

**Status:** Fixed

## Date
2026-01-19

## Summary
The `cse_cam_targets` table contained duplicate entries for FY2026 CSE targets, causing the total Weighted ACV and Total ACV to be significantly higher than the APAC 2026 Sales Budget.

## Root Cause
The migration file `20260119_update_cse_targets_fy2026.sql` inserted duplicate entries for CSEs with name variations:

| Duplicate Pair | Weighted ACV Impact | Total ACV Impact |
|----------------|---------------------|------------------|
| `John Salisbury` + `Johnathan Salisbury` | +$1,269,625 | +$928,123 |
| `New Asia CSE` + `Open Role` | +$2,485,028 | +$7,919,399 |

## Impact

| Metric | Before Fix | After Fix | Budget Target |
|--------|------------|-----------|---------------|
| Weighted ACV | $12,113,202 | $8,358,549 | $8,358,549 ✓ |
| Total ACV | $26,757,093 | $17,909,571 | $17,909,571 ✓ |

The inflated totals were **45% higher** for Weighted ACV and **49% higher** for Total ACV.

## Dashboard Impact
The Executive Dashboard "Total Pipeline" card was showing incorrect values due to these inflated targets affecting coverage calculations.

## Fix Applied
Created migration `20260119_fix_duplicate_cse_targets.sql` to remove the duplicate entries:

```sql
-- Remove duplicates, keeping the names that match other data sources
DELETE FROM cse_cam_targets
WHERE fiscal_year = 2026
  AND role_type = 'CSE'
  AND cse_cam_name IN ('Johnathan Salisbury', 'New Asia CSE');
```

## Final CSE Targets (FY2026)

| CSE Name | Weighted ACV | Total ACV |
|----------|--------------|-----------|
| John Salisbury | $1,269,625 | $928,123 |
| Laura Messing | $2,675,260 | $5,726,997 |
| Open Role | $2,485,028 | $7,919,399 |
| Tracey Bland | $1,928,636 | $3,335,052 |
| **TOTAL** | **$8,358,549** | **$17,909,571** |

## Files Modified
- `/supabase/migrations/20260119_fix_duplicate_cse_targets.sql` - Migration to remove duplicates

## Recommendations

### Short-term
1. ✅ Remove duplicate entries (DONE)
2. Update the original migration to prevent duplicates in future deployments

### Long-term
1. Add unique constraint on `(cse_cam_name, role_type, fiscal_year)` to prevent duplicates
2. Use CSE IDs instead of names for referential integrity
3. Create a CSE master table with approved names and aliases

## Verification Query

```sql
SELECT
  role_type,
  COUNT(*) as entry_count,
  SUM(weighted_acv_target) as total_weighted_acv,
  SUM(total_acv_target) as total_acv
FROM cse_cam_targets
WHERE fiscal_year = 2026
GROUP BY role_type;

-- Expected:
-- CSE | 4 | 8358549 | 17909571
-- CAM | 2 | 7150064 | 16575506
```

## Reference
- Source document: APAC 2026 Sales Budget 14Jan2026 v0.1
- Expected Weighted ACV: $8,358,549
- Expected Total ACV: $17,909,571
