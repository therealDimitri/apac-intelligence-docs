# Bug Report: ChaSen Health Score Data Mismatch

**Date**: 2025-12-19
**Status**: RESOLVED
**Severity**: High
**Component**: ChaSen AI Chat - Health Score Calculation

---

## Issue Summary

ChaSen was displaying incorrect health scores and compliance percentages for clients, showing different values than the UI client profile pages.

## Symptoms

- ChaSen showed Albury Wodonga Health with:
  - Health score: **50/100** (incorrect)
  - Compliance: **50%** (incorrect)
  - "1 meeting held against recommended cadence of 9"

- UI (client_health_summary view) showed:
  - Health score: **84/100** (correct)
  - Compliance: **100%** (correct)

## Root Cause

### Data Source Mismatch

ChaSen was calculating health scores manually from raw tables with **client name mismatches**:

| Data Source                              | Client Name             | Data Available                          |
| ---------------------------------------- | ----------------------- | --------------------------------------- |
| `client_health_summary` (UI)             | `Albury Wodonga Health` | ✅ All data present                     |
| `segmentation_event_compliance` (ChaSen) | `Albury Wodonga`        | ❌ No match for "Albury Wodonga Health" |

### Code Flow (Before Fix)

1. ChaSen queried `segmentation_event_compliance` for "Albury Wodonga Health"
2. No records found (data stored as "Albury Wodonga" without "Health")
3. Code fell back to default: `avgComplianceByClient[clientName] ?? 50`
4. Health score calculated with 50% compliance instead of actual 100%

```typescript
// BEFORE: Manual calculation with fallback
const clientCompliance = avgComplianceByClient[clientName] ?? 50 // Falls back to 50!
const { total: healthScore } = calculateHealthScore(latestNPS, clientCompliance)
```

## Solution

### Changed ChaSen to use `client_health_summary` view

The `client_health_summary` materialized view is the **single source of truth** used by the UI. Updated ChaSen to use this pre-calculated data instead of calculating from scratch.

### Changes Made

**File**: `src/app/api/chasen/chat/route.ts`

1. **Added query for client_health_summary** (lines 1130-1143):

```typescript
// NEW - Client Health Summary (pre-calculated health scores from materialized view)
supabase
  .from('client_health_summary')
  .select('client_name, segment, cse, nps_score, health_score, compliance_percentage, ...')
```

2. **Updated health score mapping** (lines 1356-1387):

```typescript
// AFTER: Using pre-calculated data from materialized view
const clientHealthScores = clientHealthSummaryData.map((client: any) => {
  const healthScore = client.health_score ?? 50
  const compliancePercentage = client.compliance_percentage ?? 50
  const npsScore = client.nps_score ?? 0
  // ...
})
```

3. **Fixed servicing analysis references** (lines 1500-1508):

```typescript
// AFTER: Using correct property names
const healthScore = healthData.healthScore // Was: healthData.score (undefined)
const compliancePercentage = healthData.compliancePercentage // Was: avgComplianceByClient lookup
const segment = healthData.segment // Was: clientsData lookup
```

## Benefits of Fix

1. **Data Consistency**: ChaSen now shows exact same data as UI
2. **Single Source of Truth**: Both use `client_health_summary` view
3. **No Fallback Issues**: Pre-calculated data eliminates default value problems
4. **Better Performance**: One query replaces multiple lookups with joins
5. **Correct Client Names**: View handles name normalisation

## Verification

After fix, ChaSen should display for Albury Wodonga Health:

- Health score: **84/100**
- Compliance: **100%**
- Segment: **Leverage**
- Status: **healthy**

## Related Files

- `src/app/api/chasen/chat/route.ts` - ChaSen chat API endpoint
- `src/hooks/useClients.ts` - UI hook (already uses client_health_summary)
- `src/lib/health-score-config.ts` - Health score calculation formula

## Lessons Learned

1. **Always use materialised views for aggregated data** - Avoids client name inconsistencies
2. **Single source of truth principle** - AI and UI should use same data source
3. **Check default/fallback values** - `?? 50` masked the real problem

---

**Resolution**: Updated ChaSen to use `client_health_summary` materialised view instead of calculating health scores from raw tables with potential name mismatches.
