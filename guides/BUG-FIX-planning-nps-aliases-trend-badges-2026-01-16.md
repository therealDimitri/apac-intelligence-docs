# Bug Fix: NPS Client Alias Matching & Trend Badges

**Date:** 2026-01-16
**Severity:** Medium (Data Display)
**Status:** ✅ Fixed

## Problem Description

### Issue 1: Missing NPS Scores
Several clients in the Planning Wizard were showing "-" for NPS scores despite having NPS response data in the database:
- GRMC showed "-" (NPS data existed as "Guam Regional Medical Centre")
- MinDef showed "-" (NPS data existed as "Ministry of Defence, Singapore")

### Issue 2: Missing Trend Indicators
The Client Gap Diagnosis table showed Health, NPS, and Support scores but lacked trend indicators to show whether scores were improving or declining.

## Root Cause

### NPS Alias Issue
The `clientAliases` mapping in `page.tsx` didn't include variations for Singapore/Guam clients:
- "Guam Regional Medical City (GRMC)" ≠ "Guam Regional Medical Centre" (database)
- "NCS/MinDef Singapore" ≠ "Ministry of Defence, Singapore" (database)

### Trend Badges Issue
The `PortfolioClient` type lacked trend fields, and no trend calculation logic existed. The `client_health_history` table contained historical snapshots but they weren't being used for trend analysis.

## Solution

### 1. Added Client Aliases

```typescript
const clientAliases: Record<string, string[]> = {
  // ... existing aliases ...
  'SA Health': ['SA Health', 'South Australia Health', 'SA Health (iPro)'],
  'Guam Regional Medical City (GRMC)': [
    'Guam Regional Medical City (GRMC)',
    'Guam Regional Medical Centre',
    'GRMC',
  ],
  GRMC: ['Guam Regional Medical City (GRMC)', 'Guam Regional Medical Centre', 'GRMC'],
  'NCS/MinDef Singapore': [
    'NCS/MinDef Singapore',
    'Ministry of Defence, Singapore',
    'MinDef',
    'NCS',
  ],
  MinDef: ['NCS/MinDef Singapore', 'Ministry of Defence, Singapore', 'MinDef', 'NCS'],
  // ... more aliases ...
}
```

### 2. Added Trend Fields to PortfolioClient

```typescript
interface PortfolioClient {
  // ... existing fields ...
  healthTrend?: 'up' | 'stable' | 'down'
  healthTrendValue?: number
  npsTrend?: 'up' | 'stable' | 'down'
  npsTrendValue?: number
  supportTrend?: 'up' | 'stable' | 'down'
  supportTrendValue?: number
}
```

### 3. Trend Calculation Logic

Query `client_health_history` for historical snapshots and compare current vs 30-day-old values:

```typescript
// Calculate trends from historical snapshots
const thirtyDaysAgo = new Date()
thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)

// Health trend: > +5 = up, < -5 = down, else stable
// NPS trend: > +10 = up, < -10 = down, else stable
// Support trend: > +5 = up, < -5 = down, else stable
```

### 4. Trend Badge UI

Added trend arrows next to each score in the Client Gap Diagnosis table:

```tsx
{client.healthTrend && (
  <span className={client.healthTrend === 'up' ? 'text-emerald-500' : 'text-red-500'}>
    {client.healthTrend === 'up' ? (
      <TrendingUp className="h-3 w-3" />
    ) : client.healthTrend === 'down' ? (
      <TrendingUp className="h-3 w-3 rotate-180" />
    ) : null}
  </span>
)}
```

## Files Modified

1. **`src/app/(dashboard)/planning/strategic/new/page.tsx`**
   - Added client aliases for Singapore/Guam clients
   - Added trend calculation from `client_health_history`
   - Mapped trend data to portfolio clients

2. **`src/app/(dashboard)/planning/strategic/new/steps/types.ts`**
   - Added `npsTrend`, `npsTrendValue`, `supportTrend`, `supportTrendValue` fields

3. **`src/app/(dashboard)/planning/strategic/new/steps/DiscoveryDiagnosisStep.tsx`**
   - Added trend badge display next to Health, NPS, Support scores

## Database Notes

- NPS aggregate is calculated from `nps_responses` table using standard formula:
  - Promoters (score >= 9), Detractors (score <= 6)
  - NPS = ((promoters - detractors) / total) * 100

- Trends are calculated from `client_health_history` table:
  - Uses `health_score`, `nps_score`, `support_health_points` columns
  - Compares latest snapshot vs snapshot from 30+ days ago

## Verification

```bash
# Build passes
npm run build

# Manual test
1. Navigate to /planning/strategic/new
2. Select "Open Role" from CSE dropdown
3. Go to Step 2 (Discovery)
4. Verify NPS scores show for GRMC (-25) and MinDef (0)
5. Verify trend arrows appear next to scores where historical data exists
```

## Results

| Client | Before | After |
|--------|--------|-------|
| GRMC | NPS: - | NPS: -25 |
| MinDef | NPS: - | NPS: 0 |
| Mount Alvernia | NPS: -60 | NPS: -60 |
| SingHealth | NPS: -25 | NPS: -25 |
| SLMC | NPS: - | NPS: - (no data in database) |

## Related

- `nps_responses` table - Source of NPS survey data
- `client_health_history` table - Historical health snapshots for trends
- `/client-profiles` - Reference implementation for client data display
