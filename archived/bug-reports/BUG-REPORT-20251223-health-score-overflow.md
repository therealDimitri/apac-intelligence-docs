# Bug Report: Health Score Overflow Due to Uncapped Working Capital

**Date**: 23 December 2025
**Type**: Bug Fix
**Priority**: P1 (Critical)
**Status**: Resolved

---

## Summary

GHA (Gippsland Health Alliance) was showing a health score of **580** instead of the expected **100**. The root cause was an uncapped `working_capital_percentage` value that exceeded 100% due to negative receivables data.

---

## Problem Description

### Symptoms

- GHA health score displayed as 580 on the client profile page
- Health score should be capped at 0-100
- Other clients may have been affected if they had similar data anomalies

### Root Cause Analysis

1. **Underlying Data Issue**: The `aging_accounts` table contained negative values for `amount_over_90_days` (-23106.36) with a small `total_outstanding` (480.95)

2. **Formula Calculation**:

   ```
   working_capital_percentage = (1.0 - (amount_over_90_days / total_outstanding)) * 100
   working_capital_percentage = (1.0 - (-23106.36 / 480.95)) * 100
   working_capital_percentage = (1.0 - (-48.04)) * 100
   working_capital_percentage = 49.04 * 100
   working_capital_percentage = 4904%
   ```

3. **Health Score Formula (Pre-Fix)**:

   ```sql
   -- Health Score v3.0: NPS (40pts) + Compliance (50pts) + Working Capital (10pts)
   (
     ((COALESCE(nps.calculated_nps, 0) + 100) / 2.0) * 0.4 +
     COALESCE(compliance_metrics.compliance_percentage, 50) * 0.5 +
     COALESCE(working_capital.working_capital_percentage, 100) * 0.1  -- NOT CAPPED!
   )::INTEGER as health_score
   ```

4. **Resulting Calculation**:
   - NPS contribution: (100 + 100) / 2 × 0.4 = **40 points**
   - Compliance contribution: 100 × 0.5 = **50 points**
   - Working Capital contribution: 4904 × 0.1 = **490.4 points** (should be max 10)
   - **Total: 580 points** (should be max 100)

---

## Solution Implemented

### Fix Applied

Added `LEAST(100, GREATEST(0, ...))` capping to all percentage-based inputs in the health score formula:

```sql
-- Health score with CAPPED percentages
(
  -- NPS: capped at 0-100 before applying weight
  LEAST(100, GREATEST(0, ((COALESCE(nps.calculated_nps, 0) + 100) / 2.0))) * 0.4 +

  -- Compliance: capped at 0-100 before applying weight
  LEAST(100, GREATEST(0, COALESCE(compliance_metrics.compliance_percentage, 50))) * 0.5 +

  -- Working Capital: CAPPED at 0-100 before applying weight (THE KEY FIX)
  LEAST(100, GREATEST(0, COALESCE(working_capital.working_capital_percentage, 100))) * 0.1
)::INTEGER as health_score
```

### Additional Change

The `working_capital_percentage` column in the view is also now capped for display:

```sql
LEAST(100, GREATEST(0, working_capital.working_capital_percentage)) as working_capital_percentage
```

---

## Files Modified

| File                                                               | Changes                                             |
| ------------------------------------------------------------------ | --------------------------------------------------- |
| `docs/migrations/20251223_cap_working_capital_in_health_score.sql` | New migration file with capped health score formula |
| `scripts/fix-working-capital-cap.mjs`                              | Script to apply the fix via Supabase REST API       |

---

## Verification

### Before Fix

```json
{
  "client_name": "Gippsland Health Alliance (GHA)",
  "nps_score": 100,
  "compliance_percentage": 100,
  "working_capital_percentage": 4904,
  "health_score": 580,
  "status": "Healthy"
}
```

### After Fix

```json
{
  "client_name": "Gippsland Health Alliance (GHA)",
  "nps_score": 100,
  "compliance_percentage": 100,
  "working_capital_percentage": 100,
  "health_score": 100,
  "status": "Healthy"
}
```

### Health Score Breakdown (After Fix)

| Component       | Value                   | Weight | Points  |
| --------------- | ----------------------- | ------ | ------- |
| NPS             | 100 → normalised to 100 | 40%    | 40      |
| Compliance      | 100%                    | 50%    | 50      |
| Working Capital | 4904% → capped to 100%  | 10%    | 10      |
| **Total**       |                         |        | **100** |

---

## Lessons Learned

1. **Always cap percentage values**: Any percentage used in calculations should be bounded (0-100) to prevent overflow
2. **Defensive programming**: Input validation should happen at the formula level, not just at the data level
3. **Edge case testing**: Test with extreme values including negative numbers in financial data

---

## Recommended Follow-up

1. **Data Quality Check**: Investigate why `aging_accounts` has negative values for receivables
2. **Monitoring**: Add alerts for health scores outside 0-100 range
3. **All Clients Check**: Verify no other clients have similar data anomalies

---

**Fixed By**: Claude Code Assistant
**Migration Applied**: 2025-12-23 via `exec_sql` RPC
