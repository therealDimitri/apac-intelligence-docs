# Bug Report: EVP Email Data Quality Fixes

**Date**: 2026-01-26
**Severity**: High
**Status**: Fixed

## Issues Identified

User feedback identified multiple data quality issues in the EVP weekly email:

### 1. CSE Client Count Incorrect

**Problem**: Laura Messing showed 7 clients instead of 4 (SA Health parent + 3 children).

**Root Cause**: The `getTeamPerformanceData()` function in `data-aggregator.ts` was:
1. Fetching ALL rows from `client_segmentation` without filtering by `effective_to`
2. Not deduplicating by client name when counting per CSE
3. Including historical/inactive segmentation records

**Solution**: Added active-only filtering and deduplication:
```typescript
// Filter for active assignments only
const filterDate = new Date()
const activeSegmentation = (segmentationData || []).filter(s => {
  if (!s.effective_to) return true
  return new Date(s.effective_to) > filterDate
})

// Deduplicate by client_name + cse_name
const seenAssignments = new Set<string>()
const uniqueAssignments = activeSegmentation.filter(s => {
  const key = `${s.client_name}|${s.cse_name}`
  if (seenAssignments.has(key)) return false
  seenAssignments.add(key)
  return true
})
```

### 2. All Clients Showing as "Critical"

**Problem**: All 19 clients showed as "critical" with health scores of 25-32, when most should be "healthy".

**Root Cause (Multi-layered)**:

1. **Name Mismatch**: The `segmentation_event_compliance` table used different client names:
   - "Albury Wodonga" vs "Albury Wodonga Health"
   - "Barwon Health" vs "Barwon Health Australia"
   - "Royal Victorian Eye and Ear Hospital (RVEEH)" vs "The Royal Victorian Eye and Ear Hospital"
   - etc.

2. **Year Filter**: The `client_health_summary` materialized view filtered for `ec.year = EXTRACT(YEAR FROM CURRENT_DATE)` (2026), but all compliance data was for 2025.

3. **Result**: All compliance percentages showed as 0% → health scores ~30 → all critical

**Solution (Two-Part Fix)**:

**Part A - Fix Name Mismatches in Database**:
Updated `segmentation_event_compliance` table to use canonical names:
```sql
UPDATE segmentation_event_compliance SET client_name = 'Albury Wodonga Health' WHERE client_name = 'Albury Wodonga';
UPDATE segmentation_event_compliance SET client_name = 'Barwon Health Australia' WHERE client_name = 'Barwon Health';
-- etc.
```

**Part B - Bypass Broken View with Direct Calculation**:
Added direct compliance calculation in `data-aggregator.ts`:
```typescript
// Get compliance data directly (bypassing broken materialized view)
const complianceYear = new Date().getFullYear()
const { data: complianceData } = await supabase
  .from('segmentation_event_compliance')
  .select('client_name, year, expected_count, actual_count')
  .or(`year.eq.${complianceYear},year.eq.${complianceYear - 1}`)

// Calculate real health scores with compliance data
const calculateRealHealthScore = (clientName, npsScore, wcPercent) => {
  const compliance = complianceByClient[clientName.toLowerCase()]
  let compliancePercent = 0
  if (compliance && compliance.expected > 0) {
    compliancePercent = Math.min(100, (compliance.actual / compliance.expected) * 100)
  }
  const compliancePoints = Math.round((compliancePercent / 100) * 60)
  // ... calculate total
}
```

**Result**: Health scores now calculated correctly:
- Before: Albury Wodonga = 32 (critical)
- After: Albury Wodonga = 90 (healthy)

## Files Modified

- `/src/lib/emails/data-aggregator.ts`
  - Added `effective_to` filtering for active segmentation records
  - Added deduplication by client_name + cse_name
  - Added direct compliance data fetching (bypassing broken view)
  - Added `calculateRealHealthScore()` function for accurate health calculation

## Database Changes

- Updated `segmentation_event_compliance` table to fix client name mismatches (6 clients updated)
- Created migration file: `docs/migrations/20260126_fix_compliance_year_filter.sql` for future view fix

## Testing

- Verified Laura Messing now shows 4 clients (SA Health + 3 children)
- Verified health scores are calculated correctly:
  - Most clients: 70-90 (healthy)
  - SingHealth: 70 (healthy, 67% compliance)
  - Dept of Health Victoria: 30 (critical, 0% compliance - data issue)

## Materialized View Migration Applied

**Additional Issues Found During Migration**:

1. **Non-existent Table**: `segmentation_clients` table referenced in view doesn't exist
   - **Fix**: Removed the join, used `c.segment` from `nps_clients` directly

2. **Wrong Column Names in unified_meetings**:
   - View used `client` → Actual column is `client_name`
   - View used `date` → Actual column is `meeting_date`

3. **Wrong Column Names in aging_accounts**:
   - View used `ar_0_30` → Actual column is `days_1_to_30`
   - View used `ar_31_60` → Actual column is `days_31_to_60`
   - View used `ar_61_90` → Actual column is `days_61_to_90`
   - View used `total_ar` → Actual column is `total_outstanding`

4. **Wrong Column Names in nps_responses**:
   - View used `submitted_at` → Actual column is `created_at`

5. **Mixed Date Formats in actions.Due_Date**:
   - Some values in YYYY-MM-DD format (e.g., "2026-01-13")
   - Some values in DD/MM/YYYY format (e.g., "31/12/2025")
   - **Fix**: Added regex pattern matching to handle both formats

**Migration Results**:
```
Albury Wodonga Health: compliance=100%, health=82, status=healthy
Barwon Health Australia: compliance=100%, health=76, status=healthy
Mount Alvernia Hospital: compliance=100%, health=81, status=healthy
Department of Health - Victoria: compliance=100%, health=73, status=at-risk
SA Health: compliance=0%, health=47, status=critical
GRMC: compliance=60%, health=49, status=critical
```

## Known Remaining Issues

1. **SA Health Children**: SA Health (Sunrise), SA Health (iPro), SA Health (iQemo) have no compliance records - need to be added
2. **SA Health Parent**: Shows 0% compliance - compliance data may need to be linked

## Prevention

1. When adding new clients, ensure names match exactly across all tables
2. When querying segmentation data, always filter by active records
3. When year changes, ensure compliance queries include previous year data
4. Consider implementing a client name normalization layer
5. **New**: Standardise date formats in the actions table (currently mixed YYYY-MM-DD and DD/MM/YYYY)
6. **New**: Update database schema documentation when column names change
