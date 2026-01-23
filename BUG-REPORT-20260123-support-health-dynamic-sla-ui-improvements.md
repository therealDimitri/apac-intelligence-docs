# Bug Report: Support Health Dynamic SLA and UI Improvements

**Date:** 2026-01-23
**Severity:** Medium (Feature Enhancement + UX Improvements)
**Status:** Resolved

## Summary

Comprehensive improvements to the Support Health dashboard addressing:
1. Static SLA weights replaced with dynamic per-client configuration
2. Confusing UI labels and metrics renamed for clarity
3. Missing visual indicators (tier badges, colour-coded tickets)
4. Limited table interactions (no bulk operations, unclear actions)
5. Excel import capability for SLA reports

## Issue 1: Static SLA Weights

### Problem
All clients used the same static health score weights (40% SLA, 30% CSAT, 20% Aging, 10% Critical) regardless of their service tier or contractual agreements.

### Root Cause
No database table existed to store per-client SLA targets and weights.

### Resolution
Created `client_sla_targets` database table with tier-based default configurations:

```sql
CREATE TABLE IF NOT EXISTS client_sla_targets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  tier TEXT DEFAULT 'Standard' CHECK (tier IN ('Platinum', 'Gold', 'Silver', 'Bronze', 'Standard')),
  response_sla_target NUMERIC(5,2) DEFAULT 95.00,
  resolution_sla_target NUMERIC(5,2) DEFAULT 90.00,
  csat_target NUMERIC(3,2) DEFAULT 4.00,
  weight_sla INTEGER DEFAULT 40,
  weight_csat INTEGER DEFAULT 30,
  weight_aging INTEGER DEFAULT 20,
  weight_critical INTEGER DEFAULT 10,
  CONSTRAINT weights_sum_to_100 CHECK (weight_sla + weight_csat + weight_aging + weight_critical = 100)
);
```

Updated API route to fetch client-specific weights and apply them to health score calculations.

## Issue 2: Confusing "Aging Penalty" Label

### Problem
The "Aging Penalty" metric showed 0/100 = good (no aging cases), which confused users who expected higher numbers to indicate better performance.

### Root Cause
Inverted scoring logic with unintuitive naming convention.

### Resolution
- Renamed "Aging Penalty" to "Aging Health"
- Updated tooltip to explain: "Cases under 30 days old as a percentage. 100% = no aged cases."
- Renamed "Critical Cases" to "Critical Health" with similar clarity

## Issue 3: Missing Client Tier Indicators

### Problem
Client tier information (Platinum, Gold, Silver, Bronze, Standard) was not visible in the table or expanded details, making it difficult to identify high-priority clients.

### Root Cause
Tier data existed in `client_segmentation` but was not displayed in the UI.

### Resolution
Added tier badges throughout the interface:
- Next to client names in the main table
- In expanded row details header
- Colour-coded by tier:
  - Platinum: Slate/grey
  - Gold: Amber
  - Silver: Blue-grey
  - Bronze: Orange-brown
  - Standard: Light grey

## Issue 4: Open Tickets Lacked Visual Priority

### Problem
Open ticket counts were displayed as plain numbers without visual indication of severity.

### Root Cause
No conditional styling applied to ticket count badges.

### Resolution
Added colour-coded badges for open ticket counts:
- Green (≤3 tickets): Healthy
- Amber (4-10 tickets): Needs attention
- Red (>10 tickets): Critical backlog

## Issue 5: Unclear N/A Values

### Problem
Metrics showing "N/A%" were confusing - users couldn't distinguish between missing data and zero values.

### Root Cause
Generic N/A display without context.

### Resolution
- Changed display from "N/A%" to "--"
- Added tooltips explaining: "No data available for this metric"
- Consistent across all SLA and CSAT metrics

## Issue 6: Limited Table Actions

### Problem
- External link icon purpose was unclear
- No bulk operations available
- No quick access to common actions

### Root Cause
Minimal action UI with single icon button.

### Resolution
1. Replaced external link icon with dropdown action menu containing:
   - View Client Profile
   - View Support Cases
   - Export Client Report
   - Configure SLA Targets

2. Added checkbox selection column for bulk operations:
   - Select individual rows
   - Select all visible rows
   - Bulk export selected clients

3. Added floating bulk action bar when rows are selected

## Issue 7: No Excel Import Capability

### Problem
No automated way to import SLA reports from client Excel files.

### Root Cause
Missing import script.

### Resolution
Created `scripts/sync-sla-reports.mjs` that:
- Parses client SLA Excel reports
- Extracts data from multiple sheet types (SLA Compliance, Case Volume, Aging, CSAT, Availability)
- Extracts client name and period from filename
- Supports dry-run mode for testing
- Upserts to `support_sla_metrics` table

Usage:
```bash
node scripts/sync-sla-reports.mjs data/sla-reports/Client_Nov2025.xlsx --dry-run
node scripts/sync-sla-reports.mjs data/sla-reports/*.xlsx
```

## Files Created

1. `supabase/migrations/20260123_client_sla_targets.sql`
   - New table for per-client SLA configuration
   - PostgreSQL function for fetching targets with fallback
   - Default tier configurations

2. `scripts/sync-sla-reports.mjs`
   - Excel import script for SLA reports
   - Multi-sheet parsing capability

## Files Modified

1. `src/app/api/support-metrics/route.ts`
   - Added `SLATargets` interface
   - Added `DEFAULT_TARGETS` lookup by tier
   - Updated `calculateSupportHealthScore()` for dynamic weights
   - Added tier lookup from segmentation

2. `src/components/support/ExpandableRowContent.tsx`
   - Added tier badge display
   - Renamed "Aging Penalty" to "Aging Health"
   - Renamed "Critical Cases" to "Critical Health"
   - Updated tooltips with clearer explanations
   - Added `SLATargets` interface

3. `src/components/support/SupportOverviewTable.tsx`
   - Added checkbox selection column
   - Added tier badges next to client names
   - Added colour-coded open tickets badges
   - Changed N/A display to "--" with tooltips
   - Added action dropdown menu
   - Added bulk actions bar
   - Changed "Period" header to "Last Updated"
   - Updated colspan for new checkbox column

## Testing Performed

- [x] Build passes without TypeScript errors
- [x] Tier badges display correctly
- [x] Open ticket colour coding works
- [x] Action dropdown menu functional
- [x] Checkbox selection and bulk export work
- [x] N/A values show "--" with tooltips
- [x] Excel import script parses test data correctly

## Database Migration Note

The migration file `20260123_client_sla_targets.sql` needs to be applied via Supabase Dashboard SQL Editor as the automated migration failed due to connection issues.

## Future Considerations

1. Add SLA target configuration UI in client profile
2. Add historical trend comparison for individual clients
3. Add automated Excel import scheduling via cron
4. Add SLA breach alerts and notifications

## Related Files

- Migration: `supabase/migrations/20260123_client_sla_targets.sql`
- Import Script: `scripts/sync-sla-reports.mjs`
- API Route: `src/app/api/support-metrics/route.ts`
- Table Component: `src/components/support/SupportOverviewTable.tsx`
- Row Content: `src/components/support/ExpandableRowContent.tsx`
