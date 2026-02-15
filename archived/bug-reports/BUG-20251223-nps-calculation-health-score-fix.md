# Bug Report: NPS Calculation Causing Incorrect Health Scores

**Date:** 2025-12-23
**Severity:** High
**Status:** Resolved
**Component:** Database / Materialized Views / client_health_summary

## Summary

Client health scores dropped significantly after the `client_health_summary` view was recreated. The root cause was that NPS scores were being calculated incorrectly - using the average of raw 0-10 individual response scores instead of the proper NPS formula.

## Problem

The health score calculation was using `AVG(score)` from `nps_responses`, which returns values in the 0-10 range. However, NPS (Net Promoter Score) should be calculated as:

```
NPS = %Promoters(scores 9-10) - %Detractors(scores 0-6)
```

This yields a value between -100 and +100, not 0-10.

### Impact

- Health scores were significantly lower than expected
- NPS contribution to health score was underweighted
- Clients with good NPS data appeared to have poor health scores

## Root Cause

The `client_health_summary` view was using:

```sql
LEFT JOIN LATERAL (
  SELECT
    AVG(score)::INTEGER as current_score,  -- WRONG: This gives 0-10
    ...
  FROM nps_responses nr
  WHERE nr.client_name = c.client_name
) nps ON true
```

The health score formula then applied a 0.4 weight:

```sql
COALESCE(nps.current_score, 0) * 0.4  -- With AVG of 0-10, max contribution is only 4 points
```

When NPS is correctly calculated (-100 to +100), it needs to be normalised before applying the weight:

```sql
((COALESCE(nps.calculated_nps, 0) + 100) / 2.0) * 0.4  -- Normalised 0-100, then weighted
```

## Resolution

Updated the `client_health_summary` materialized view with proper NPS calculation:

```sql
LEFT JOIN LATERAL (
  SELECT
    -- Proper NPS calculation: %Promoters - %Detractors
    ROUND(
      (COUNT(*) FILTER (WHERE score >= 9)::DECIMAL / NULLIF(COUNT(*), 0) * 100) -
      (COUNT(*) FILTER (WHERE score <= 6)::DECIMAL / NULLIF(COUNT(*), 0) * 100)
    )::INTEGER as calculated_nps,
    0 as trend,
    COUNT(*) as response_count
  FROM nps_responses nr
  WHERE nr.client_name = c.client_name
    OR nr.client_name IN (
      SELECT display_name
      FROM client_name_aliases
      WHERE canonical_name = c.client_name
        AND is_active = true
    )
) nps ON true
```

And updated the health score calculation:

```sql
(
  -- NPS normalised from -100 to +100 → 0 to 100, then apply 0.4 weight
  ((COALESCE(nps.calculated_nps, 0) + 100) / 2.0) * 0.4 +
  COALESCE(compliance_metrics.compliance_percentage, 0) * 0.4 +
  LEAST(COALESCE(engagement.meeting_count, 0) * 5, 20) +
  GREATEST(20 - COALESCE(engagement.open_action_count, 0) * 2, 0)
)::INTEGER as health_score
```

## Verification Results

After the fix:

| Client                          | Health Score | NPS Score | Compliance | Notes                            |
| ------------------------------- | ------------ | --------- | ---------- | -------------------------------- |
| Te Whatu Ora Waikato            | 96           | 78        | 100%       | ✅ High NPS, full compliance     |
| Albury Wodonga Health           | 89           | 20        | 100%       | ✅ Moderate NPS, full compliance |
| Gippsland Health Alliance (GHA) | 87           | 33        | 100%       | ✅                               |
| SA Health (Sunrise)             | 76           | 0         | 91%        | ✅ No NPS responses              |
| Grampians Health                | 67           | -67       | 100%       | ✅ Negative NPS now reflected    |
| Department of Health - Victoria | 65           | -55       | 90%        | ✅ Proper exclusion applied      |

## NPS Calculation Reference

### Individual Response Scores (0-10)

- **Promoters:** 9-10
- **Passives:** 7-8
- **Detractors:** 0-6

### NPS Formula

```
NPS = (Number of Promoters / Total Responses × 100) - (Number of Detractors / Total Responses × 100)
```

### NPS Range

- Minimum: -100 (all detractors)
- Maximum: +100 (all promoters)

### Health Score Normalisation

To use NPS in the health score formula (which expects 0-100 inputs):

```
Normalised NPS = (NPS + 100) / 2
```

- NPS of -100 → 0
- NPS of 0 → 50
- NPS of +100 → 100

## Related Bug Reports

- `BUG-20251223-proper-exclusion-filter-implementation.md` - Event exclusion fix
- `BUG-20251223-cascade-drop-client-health-summary.md` - CASCADE drop issue

## Files Modified

- `client_health_summary` materialized view (via Supabase Dashboard SQL Editor)

## Additional Fix: Table Name Correction

During implementation, also corrected the table reference:

- **Wrong:** `client_aliases` (doesn't exist)
- **Correct:** `client_name_aliases`

And column name:

- **Wrong:** `alias`
- **Correct:** `display_name`

## Prevention

1. **Document NPS scale** - Clearly document that NPS is -100 to +100, not 0-10
2. **Test with edge cases** - Include clients with negative NPS in test scenarios
3. **Validate health score ranges** - Ensure health scores fall within expected 0-100 range
