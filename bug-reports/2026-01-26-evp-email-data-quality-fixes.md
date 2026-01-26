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

## Known Remaining Issues

1. **SA Health Children**: SA Health (Sunrise), SA Health (iPro), SA Health (iQemo) have no compliance records - need to be added
2. **Department of Health - Victoria**: Shows 0/35 actual events - may be a data entry issue
3. **Materialized View**: The `client_health_summary` view still needs the SQL fix applied directly to Supabase

## Prevention

1. When adding new clients, ensure names match exactly across all tables
2. When querying segmentation data, always filter by active records
3. When year changes, ensure compliance queries include previous year data
4. Consider implementing a client name normalization layer
