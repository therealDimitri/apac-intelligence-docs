# Bug Report: Compliance Percentage Mismatch Between Health Score and Segmentation Card

**Date:** 2025-12-19
**Status:** Fixed
**Severity:** High
**Affected Clients:** All clients (especially Saint Luke's Medical Centre)

## Problem Description

The compliance percentage shown in the Health Score modal did not match the compliance percentage shown in the Segmentation Actions card.

### Example: Saint Luke's Medical Centre (SLMC)
- **Health Score Modal:** Showed 100% compliance → 50/50 points
- **Segmentation Actions Card:** Showed 50% compliance
- **Insights Tab:** Showed "At Risk" with 47% risk score

## Root Cause Analysis

### Issue 1: Different Data Sources

Two different tables were being used for compliance calculation:

| Component | Data Source | Formula | Result |
|-----------|-------------|---------|--------|
| Health Score (`client_health_summary`) | `segmentation_event_compliance` | AVG of compliance_percentage | **100%** |
| Segmentation Card (`event_compliance_summary`) | `segmentation_events` | COUNT(compliant) / COUNT(total) | **50%** |

### Issue 2: Stale Data in segmentation_event_compliance

The `segmentation_event_compliance` table contained pre-calculated compliance percentages that were:
1. **Calculated differently** - used `(actual/expected)*100` for each row
2. **Not filtering** event types with `expected_count = 0`
3. **Using AVG** of these percentages, which included values >100% (400%, 600%)

For SLMC:
- Raw values: 0, 0, 0, 0, 0, 400, 600, 50, 100, 200, 150, 0
- AVG = 125% → capped at 100%

### Issue 3: Different Client Names Between Tables

The `segmentation_event_compliance` table used different client names than `nps_clients`:
- "Albury Wodonga" vs "Albury Wodonga Health"
- "Waikato" vs "Te Whatu Ora Waikato"
- "Singapore Health (SingHealth)" vs "SingHealth"

## Fix Applied

Updated `client_health_summary` materialized view to use `event_compliance_summary` as the single source of truth for compliance data.

### Before (Incorrect)
```sql
-- client_health_summary queried segmentation_event_compliance directly
LEFT JOIN LATERAL (
  SELECT
    AVG(compliance_percentage) as compliance_percentage
  FROM segmentation_event_compliance ec
  WHERE ec.client_name = c.client_name ...
) compliance_metrics ON true
```

### After (Fixed)
```sql
-- client_health_summary now uses event_compliance_summary
LEFT JOIN LATERAL (
  SELECT
    COALESCE(ecs.overall_compliance_score, 0) as compliance_percentage,
    COALESCE(ecs.overall_status, 'critical') as compliance_status
  FROM event_compliance_summary ecs
  WHERE ecs.client_name = c.client_name
    AND ecs.year = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
) compliance_metrics ON true
```

### Why This Works

The `event_compliance_summary` view:
1. Calculates compliance from `segmentation_events` (actual event data)
2. Uses the formula: `(compliant_event_types / total_event_types) * 100`
3. Uses `nps_clients` names (via segment tier joins)
4. Is already used by the Segmentation Actions card

Now both the Health Score modal and Segmentation Actions card use the same data source.

## Results After Fix

All 18 clients now have matching compliance percentages:

| Client | Before | After | Match |
|--------|--------|-------|-------|
| Albury Wodonga Health | 78% | 100% | ✓ |
| Barwon Health Australia | 63% | 75% | ✓ |
| Department of Health - Victoria | 45% | 82% | ✓ |
| Epworth Healthcare | 63% | 70% | ✓ |
| Gippsland Health Alliance (GHA) | 89% | 100% | ✓ |
| Grampians Health | 89% | 100% | ✓ |
| Guam Regional Medical City (GRMC) | 38% | 38% | ✓ |
| Mount Alvernia Hospital | 67% | 78% | ✓ |
| NCS/MinDef Singapore | 56% | 56% | ✓ |
| Royal Victorian Eye and Ear Hospital | 63% | 75% | ✓ |
| SA Health (iPro) | 0% | 64% | ✓ |
| SA Health (iQemo) | 0% | 73% | ✓ |
| SA Health (Sunrise) | 0% | 91% | ✓ |
| Saint Luke's Medical Centre (SLMC) | 100% | 50% | ✓ |
| SingHealth | 42% | 33% | ✓ |
| Te Whatu Ora Waikato | 78% | 100% | ✓ |
| WA Health | 17% | 25% | ✓ |
| Western Health | 50% | 88% | ✓ |

## Files Modified

- `docs/migrations/20251219_fix_health_score_with_aliases.sql` - Updated compliance calculation

## Technical Details

### Health Score Formula v3.2 (with Unified Compliance)

```
Health Score = NPS (40 pts) + Compliance (50 pts) + Working Capital (10 pts)

NPS Component:      ((nps_score + 100) / 200) * 40
                    NPS calculated from MOST RECENT QUARTER only

Compliance:         (compliance_% / 100) * 50
                    Uses event_compliance_summary.overall_compliance_score
                    Formula: (compliant_event_types / total_event_types) * 100

Working Capital:    (min(100, wc_%) / 100) * 10
                    Aggregates multi-entity clients

Defaults:
- NPS: 0 (neutral) when no recent quarter data
- Compliance: 0% when no data in event_compliance_summary
- Working Capital: 100% (no aging data = no problem)
```

## Testing Checklist

- [x] All 18 clients have matching compliance between views
- [x] SLMC shows 50% in both Health Score modal and Segmentation card
- [x] SA Health variants now show correct compliance (previously 0%)
- [x] Health scores recalculated with correct compliance values

## Prevention

1. Always use `event_compliance_summary` as the single source of truth for compliance
2. The `segmentation_event_compliance` table should be deprecated or kept in sync
3. When adding new compliance features, verify they use `event_compliance_summary`

## Related Issues

- Previous fix: `20251219_health_score_mismatch_fix.md` - Fixed NPS calculation period mismatch
- Previous fix: `20251219_working_capital_aggregation_fix.md` - Fixed Working Capital for multi-entity clients
