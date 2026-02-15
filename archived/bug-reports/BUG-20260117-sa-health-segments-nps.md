# Bug Report: SA Health Clients - Wrong Segments and Inconsistent NPS

**Date:** 17 January 2026
**Status:** Fixed
**Severity:** Medium
**Component:** Strategic Planning > Client Gap Diagnosis

---

## Problem Description

Laura Messing's Account Plan 2026 displayed incorrect data for SA Health clients:

1. **Segments**: All 4 SA Health clients showed "Maintain" instead of their correct segments
2. **NPS**: Inconsistent NPS values - some showed -46, others showed null

### Affected Clients

| Client | Wrong Segment | Correct Segment | Wrong NPS | Correct NPS |
|--------|---------------|-----------------|-----------|-------------|
| SA Health | Maintain | Giant | -46 | 6 |
| SA Health (iPro) | Maintain | Collaboration | -46 | 6 |
| SA Health (iQemo) | Maintain | Nurture | null | 6 |
| SA Health (Sunrise) | Maintain | Giant | null | 6 |

---

## Root Cause Analysis

### Issue 1: Segments

Two data sources had conflicting segment values:

- **`client_health_summary`** (correct): Giant, Collaboration, Nurture, Giant
- **`clients` table** (outdated): Maintain for all

The code at `/src/app/(dashboard)/planning/strategic/new/page.tsx:1494` has fallback logic:

```typescript
segment: health?.segment || c.segment || c.tier || 'Unknown'
```

When health lookup failed (due to name matching issues), it fell back to `c.segment` from the `clients` table which had outdated "Maintain" values.

### Issue 2: NPS

The saved `portfolio_data` in `strategic_plans` table had stale NPS values. SA Health clients should share the same NPS (6) since they're part of the same organisation, but only SA Health (iPro) had actual NPS response data.

---

## Solution Implemented

### Data Fixes

1. **Updated `clients` table** - Set correct segments for SA Health clients:
   ```sql
   UPDATE clients SET segment = 'Giant' WHERE display_name = 'SA Health';
   UPDATE clients SET segment = 'Collaboration' WHERE display_name = 'SA Health (iPro)';
   UPDATE clients SET segment = 'Nurture' WHERE display_name = 'SA Health (iQemo)';
   UPDATE clients SET segment = 'Giant' WHERE display_name = 'SA Health (Sunrise)';
   ```

2. **Updated `strategic_plans.portfolio_data`** - Corrected Laura's plan with:
   - Correct segments from `client_health_summary`
   - Unified NPS value (6) for all SA Health clients

### Why This Fix Works

- The `clients` table now matches `client_health_summary` segments
- Future plans will load correct segments regardless of which source is used
- Existing plan data was corrected to reflect accurate values

---

## Prevention

### Recommendations

1. **Single Source of Truth**: Segments should only be maintained in `client_health_summary` (derived from segmentation rules)

2. **Remove `segment` from `clients` table**: Or keep it synchronized via a trigger

3. **Parent-level NPS**: Consider propagating NPS from parent organisations to sub-clients when they share the same customer relationship

---

## Files Affected

| Resource | Changes |
|----------|---------|
| `clients` table | Updated segments for 4 SA Health records |
| `strategic_plans` table | Updated `portfolio_data` for Laura's plan (ID: dd31dd96-234a-487f-8718-d6f726e9e5f3) |

---

## Testing Steps

1. Navigate to Planning Hub → Laura Messing's Account Plan
2. Go to Step 2 (Discovery & Diagnosis)
3. Verify Client Gap Diagnosis shows:
   - SA Health: Giant segment
   - SA Health (iPro): Collaboration segment
   - SA Health (iQemo): Nurture segment
   - SA Health (Sunrise): Giant segment
   - All clients show NPS = 6

---

## Related Issues

- BUG-20260117: Laura Messing Plan Had Wrong Opportunities (similar root cause - stale saved data)
