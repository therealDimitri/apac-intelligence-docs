# Bug Report: SA Health Not Showing in Client Gap Diagnosis

**Date**: 16 January 2026
**Status**: Fixed
**Severity**: Medium
**Component**: Strategic Planning Wizard - Discovery & Diagnosis Step

## Issue

SA Health was not appearing in the "Client Gap Diagnosis" section for Laura Messing's SA territory, despite having known health issues (health score = 44, NPS = -55).

## Root Cause

Two issues were identified:

### 1. Parent Client Missing CSE Assignment

The parent "SA Health" client in the `clients` table had `cse_name: null`, while the child clients (iPro, iQemo, Sunrise) had `cse_name: 'Laura Messing'`.

The portfolio loading query filters by:
```sql
WHERE cse_name = 'Laura Messing' AND parent_id IS NULL AND is_active = true
```

This returned no results because:
- Parent "SA Health" had no CSE assigned
- Children had CSE assigned but also had `parent_id` set

### 2. Missing Health Data for Parent

Health data existed for child variants (SA Health (iPro), etc.) but not for the parent "SA Health". The matching logic would eventually find children via partial matching, but the initial data load from `client_health_summary` (a materialised view) had no entry for the parent.

### 3. Overly Restrictive Filter Logic (Secondary Issue)

The gap analysis filter was:
```typescript
.filter(c => (c.healthScore ?? 100) < 80 || (c.nps ?? 10) < 7)
```

This defaulted to healthy values when data was missing, excluding clients that should be reviewed.

## Solution

### Database Fixes

1. **Updated parent SA Health's CSE assignment**:
```sql
UPDATE clients
SET cse_name = 'Laura Messing'
WHERE canonical_name = 'SA Health'
AND parent_id IS NULL;
```

2. **Added health history record for parent SA Health**:
```sql
INSERT INTO client_health_history (
  client_name, health_score, nps_score, status, snapshot_date
) VALUES (
  'SA Health', 44, -55, 'at-risk', '2026-01-16'
);
```

### Code Fixes

Updated filter logic in `DiscoveryDiagnosisStep.tsx` (lines 281-303) to include:
- Clients with healthScore < 80 (known unhealthy)
- Clients with NPS < 7 (detractors)
- Clients with null/undefined healthScore (needs review)
- Clients that already have gap diagnosis data entered

```typescript
const clientsForGapAnalysis = useMemo(() => {
  return portfolio
    .filter(c => {
      if (c.healthScore !== null && c.healthScore !== undefined && c.healthScore < 80) return true
      if (c.nps !== null && c.nps !== undefined && c.nps < 7) return true
      if (c.healthScore === null || c.healthScore === undefined) return true
      if (c.gapDiagnosis?.currentState || c.gapDiagnosis?.futureState || c.gapDiagnosis?.gapQuantified) return true
      return false
    })
    .sort((a, b) => {
      const aScore = a.healthScore ?? 999
      const bScore = b.healthScore ?? 999
      return aScore - bScore
    })
    .slice(0, 15)
}, [portfolio])
```

## Files Modified

- `src/app/(dashboard)/planning/strategic/new/steps/DiscoveryDiagnosisStep.tsx`
  - Updated gap analysis filter logic to include clients with missing health data
  - Increased limit from 10 to 15 clients
  - Updated empty state message

- Database changes (via Supabase):
  - `clients` table: Set `cse_name = 'Laura Messing'` for parent SA Health
  - `client_health_history` table: Added health record for parent SA Health

## Testing

- TypeScript compilation: Passed
- Build compilation: Passed
- Database verification: SA Health now has cse_name and health data

## Prevention

For future parent-child client relationships:
1. Ensure parent clients have CSE assignments that match their children
2. Add health records for parent clients (can be aggregated from children)
3. The updated filter logic now handles edge cases where health data is missing
