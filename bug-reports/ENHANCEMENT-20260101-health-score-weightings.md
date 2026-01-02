# Enhancement: Health Score Weighting Update

**Date:** 1 January 2026
**Status:** Completed
**Type:** Business Logic Enhancement
**Component:** Health Score Calculation System

## Summary

Updated the health score calculation formula from a 3-component system to a 4-component system with new weightings.

## Previous Formula (v3.0)

| Component | Weight | Description |
|-----------|--------|-------------|
| NPS Score | 40 pts | Client satisfaction |
| Segmentation Compliance | 50 pts | Event completion rate |
| Working Capital | 10 pts | Receivables aging |
| **Total** | **100 pts** | |

## New Formula (v4.0)

| Component | Weight | Description |
|-----------|--------|-------------|
| NPS Score | 20 pts | Client satisfaction (-100 to +100 scaled to 0-20) |
| Segmentation Compliance | 60 pts | Event completion rate (now highest weight) |
| Working Capital | 10 pts | Receivables aging (unchanged) |
| Actions Completion | 10 pts | Client action completion rate |
| **Total** | **100 pts** | |

## Rationale

1. **Increased Compliance Weight (50→60)**: Reflects the importance of consistent client engagement
2. **Reduced NPS Weight (40→20)**: NPS is still valuable but less volatile than engagement metrics
3. **Added Actions Component (new, 10pts)**: Tracks follow-through on client commitments
4. **Working Capital Unchanged (10)**: Already appropriately weighted

## Files Modified

### `src/lib/health-score-config.ts`

1. Updated version to 4.0
2. Changed NPS weight: 40 → 20
3. Changed Compliance weight: 50 → 60
4. Added new "actions" component with weight 10
5. Updated `calculateHealthScore` function:
   - Added `actionsData` parameter
   - Updated NPS calculation: `((nps + 100) / 200) * 20`
   - Updated Compliance calculation: `(compliance / 100) * 60`
   - Added Actions calculation: `(completionPercentage / 100) * 10`
6. Updated return type to include `actions` in breakdown
7. Updated `formulaSummary` and `chasenDescription`
8. Added `ActionsData` interface

### `src/app/(dashboard)/clients/[clientId]/components/HealthBreakdown.tsx`

1. Added `useActions` hook import
2. Added `actionsData` calculation based on client's actions
3. Added actions component to health breakdown display
4. Updated `calculateHealthScore` call with 4th parameter

## Calculation Details

### NPS Component (20 pts)
```typescript
npsPoints = Math.round(((nps + 100) / 200) * 20)
// NPS -100 → 0 pts
// NPS 0 → 10 pts
// NPS +100 → 20 pts
```

### Compliance Component (60 pts)
```typescript
compliancePoints = Math.round((compliance / 100) * 60)
// 0% compliance → 0 pts
// 50% compliance → 30 pts
// 100% compliance → 60 pts
```

### Working Capital Component (10 pts)
Unchanged - dual-goal system:
- Goal 1: ≥90% AR under 60 days
- Goal 2: 100% AR under 90 days
- Both goals met → 10 pts, otherwise proportional

### Actions Component (10 pts)
```typescript
actionsPoints = Math.round((completionPercentage / 100) * 10)
// 0% completed → 0 pts
// 50% completed → 5 pts
// 100% completed → 10 pts
// No actions → 10 pts (full score)
```

## Testing

1. Navigate to any client profile page
2. Expand "Health Score Breakdown" section
3. Verify 4 components are now displayed:
   - NPS Score (out of 20)
   - Segmentation Compliance (out of 60)
   - Working Capital (out of 10)
   - Actions Completion (out of 10)
4. Verify total still sums to 100

## Impact on Existing Scores

With the new weighting:
- Clients with high compliance will see improved scores
- Clients relying on high NPS alone may see reduced scores
- Clients with good action follow-through will benefit

## ChaSen AI Integration

The `chasenDescription` in the config is automatically used by ChaSen AI when explaining health scores, so AI responses will reflect the new formula.
