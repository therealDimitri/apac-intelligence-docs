# Bug Report: Support Health Export Failing

**Date:** 2026-01-24
**Severity:** High (Functionality Broken)
**Status:** Resolved

## Summary

The "Export to Excel" button on the Support Health page was failing with the error "Failed to export report. Please try again."

## Root Cause

The export API route (`/api/support-metrics/export/route.ts`) was attempting to query and order by a column `support_health_score` that does not exist in the `support_sla_metrics` database table.

The main support metrics API (`/api/support-metrics/route.ts`) calculates the `support_health_score` dynamically based on SLA data, but the export route was incorrectly assuming this column existed in the database.

### Database Error
```
code: '42703'
message: 'column support_sla_metrics.support_health_score does not exist'
```

## Resolution

Updated the export route to:

1. **Removed invalid ORDER BY** - Changed from ordering by non-existent `support_health_score` column to ordering by `client_name`

2. **Added dynamic health score calculation** - Implemented the same `calculateSupportHealthScore()` function used in the main API route

3. **Enriched metrics with calculated fields** - Added:
   - `canonical_name` from client aliases
   - `cse_name` and `cam_name` from client segmentation
   - `total_open` (sum of all priority levels)
   - `aging_30d_plus` (sum of aging buckets over 30 days)
   - `support_health_score` (calculated dynamically)

4. **In-memory sorting** - Sort enriched metrics by calculated health score after processing

## Files Modified

1. `src/app/api/support-metrics/export/route.ts`
   - Added `SupportMetricsDB` interface for raw database records
   - Updated `SupportMetrics` interface to extend database records with calculated fields
   - Added `calculateSupportHealthScore()` function
   - Updated GET handler to:
     - Fetch raw metrics without invalid ORDER BY
     - Fetch client aliases for canonical names
     - Fetch client segmentation for CSE/CAM assignments
     - Enrich metrics with calculated fields
     - Sort by calculated health score in memory

## Testing Performed

- [x] Database query executes without errors
- [x] Health scores calculated correctly (verified sample: Albury Wodonga Health = 88, Barwon Health = 92, Epworth Healthcare = 75)
- [x] Excel workbook generates successfully
- [x] Buffer creation succeeds (16,036 bytes)
- [x] Build passes without TypeScript errors

## Health Score Calculation Formula

The health score is calculated using weighted components:
- **SLA Compliance (40%)**: Based on resolution SLA percentage
- **Customer Satisfaction (30%)**: CSAT score converted from 1-5 scale to 0-100
- **Aging Health (20%)**: Penalty of 10 points per case over 30 days old
- **Critical Health (10%)**: Penalty of 25 points per critical case

## Related Files

- Main API Route: `src/app/api/support-metrics/route.ts`
- Export API Route: `src/app/api/support-metrics/export/route.ts`
- Support Page: `src/app/(dashboard)/support/page.tsx`
