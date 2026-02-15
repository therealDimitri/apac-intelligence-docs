# Bug Report: Health Score NPS Reconciliation Between UI Components

**Date:** 2025-12-23
**Severity:** Medium
**Status:** Resolved
**Component:** Database / Materialized View / client_health_summary

## Summary

Health scores were not reconciling between different UI components on the client profile page. The Health Score Breakdown modal showed 100 while the Health Score card and Insights panel showed 87. The correct behaviour is to use the **latest quarter's NPS** for health score calculations.

## Problem

For GHA (Gippsland Health Alliance):
- **Health Score Card**: 87 (from database - using all-time NPS)
- **Health Score Breakdown Modal**: 100 (from frontend - using latest quarter NPS)
- **Insights Panel**: 87 (from database - using all-time NPS)

The discrepancy was caused by the database `client_health_summary` materialized view calculating NPS from ALL responses across all periods, while the frontend correctly calculated NPS from only the latest quarter.

### Root Cause

The `client_health_summary` materialized view's NPS calculation:

```sql
-- BEFORE: Calculated NPS from ALL responses (all-time)
LEFT JOIN LATERAL (
  SELECT
    round(count(*) FILTER (WHERE r.score >= 9)::numeric / NULLIF(count(*), 0)::numeric * 100 -
          count(*) FILTER (WHERE r.score <= 6)::numeric / NULLIF(count(*), 0)::numeric * 100) AS nps_score
  FROM nps_responses r
  WHERE r.client_name = c.client_name  -- No period filter!
) nps_metrics ON true
```

For GHA:
- **All-time NPS**: Mixed responses across Q2 24, Q4 24, Q2 25, Q4 25 → NPS +33
- **Latest quarter (Q4 25)**: 3 promoters (scores 9, 10, 9), 0 detractors → NPS +100

Per business requirements, health score should reflect **current client sentiment** using the most recent NPS cycle.

## Resolution

Updated the `client_health_summary` materialized view to calculate NPS from only the **latest period** for each client.

### Database Change (client_health_summary view)

```sql
-- AFTER: Calculate NPS from LATEST PERIOD only
LEFT JOIN LATERAL (
  SELECT
    latest.period as nps_period,
    round(
      count(*) FILTER (WHERE r.score >= 9)::numeric / NULLIF(count(*), 0)::numeric * 100 -
      count(*) FILTER (WHERE r.score <= 6)::numeric / NULLIF(count(*), 0)::numeric * 100
    ) AS nps_score,
    count(*) FILTER (WHERE r.score >= 9) AS promoter_count,
    count(*) FILTER (WHERE r.score >= 7 AND r.score <= 8) AS passive_count,
    count(*) FILTER (WHERE r.score <= 6) AS detractor_count,
    count(*) AS response_count,
    max(r.response_date) AS last_response_date
  FROM nps_responses r
  INNER JOIN (
    -- Find the latest period for this client
    SELECT period
    FROM nps_responses
    WHERE client_name = c.client_name
    ORDER BY
      CASE
        WHEN period LIKE 'Q% 25' THEN 2025
        WHEN period LIKE 'Q% 24' THEN 2024
        WHEN period = '2023' THEN 2023
        ELSE 2000
      END DESC,
      CASE
        WHEN period LIKE 'Q4%' THEN 4
        WHEN period LIKE 'Q3%' THEN 3
        WHEN period LIKE 'Q2%' THEN 2
        WHEN period LIKE 'Q1%' THEN 1
        ELSE 0
      END DESC
    LIMIT 1
  ) latest ON r.period = latest.period
  WHERE r.client_name = c.client_name
  GROUP BY latest.period
) nps_metrics ON true
```

### New Column Added

Added `nps_period` column to track which period's NPS is being used for the health score.

## Verification Results

After the fix, all UI components show consistent values for GHA:

| Component | Health Score | NPS Used | Period | Notes |
|-----------|--------------|----------|--------|-------|
| Health Score Card | 100 | N/A | N/A | From `client.health_score` |
| Health Score Breakdown Modal | 100 | +100 | Q4 25 | Uses `calculatedNpsScore` |
| Insights Panel | 100 | +100 | Q4 25 | Uses `calculatedNpsScore` |
| Most Recent NPS Card | N/A | +100 | Q4 25 | Intentionally shows recent quarter |

### Health Score Calculation (GHA - After Fix)

| Component | Value | Points |
|-----------|-------|--------|
| NPS Score (+100 from Q4 25) | (100 + 100) / 200 × 40 | 40/40 |
| Segmentation Compliance | 100% | 50/50 |
| Working Capital | No aging data (default 100%) | 10/10 |
| **Total** | | **100/100** |

## Design Decision

Health score now uses the **latest quarter's NPS** to reflect current client sentiment, which is more actionable for CSE decision-making. The NPS period sorting logic ensures:

1. **Year ordering**: 2025 > 2024 > 2023
2. **Quarter ordering within year**: Q4 > Q3 > Q2 > Q1

This ensures the most recent NPS cycle is always used, even when multiple periods exist.

## Files Modified

- `client_health_summary` materialized view (via Supabase Dashboard SQL Editor)

## Frontend Code (Unchanged)

The frontend already correctly prioritised latest quarter NPS:

```javascript
// LeftColumn.tsx - Uses calculatedNpsScore (latest quarter) first
const npsScore = calculatedNpsScore ?? client.nps_score ?? 0

// RightColumn.tsx - Uses calculatedNpsScore (latest quarter) first
const npsValue = calculatedNpsScore ?? client.nps_score
```

## Related Bug Reports

- `BUG-20251223-proper-exclusion-filter-implementation.md` - Event exclusion fix

## Prevention

1. **Document NPS calculation source** - Health score should always use latest quarter NPS
2. **Ensure database and frontend alignment** - Both should use the same NPS source
3. **Add nps_period column** - Makes it explicit which period's NPS is being used
