# Feature: Data Quality Monitoring Dashboard

**Date**: 2026-01-24
**Type**: New Feature
**Status**: Implemented

## Summary

Created a new Data Quality Monitoring Dashboard that provides visibility into data integrity issues across the system.

## Files Created

1. **API Endpoint**: `/src/app/api/admin/data-quality/route.ts`
   - Fetches orphaned record counts from unified_meetings, actions, and nps_responses tables
   - Calculates stale data warnings based on last update timestamps
   - Identifies name mismatches by comparing client names against the clients table and client_name_aliases
   - Computes data completeness metrics (percentage of records with valid client_uuid)

2. **Component**: `/src/components/admin/DataQualityDashboard.tsx`
   - Card-based layout with severity indicators
   - Summary cards showing overall status, orphaned records, stale sources, and name mismatches
   - Detailed breakdown of orphaned records by table
   - Data completeness progress bars
   - Data freshness status with colour-coded severity (critical/warning/ok)
   - Name mismatch table showing unmatched client names

3. **Page Route**: `/src/app/(dashboard)/admin/data-quality/page.tsx`
   - Admin page at `/admin/data-quality`
   - Includes metadata for title and description
   - Suspense boundary with loading state

## Features

### Orphaned Record Detection
- Counts records in unified_meetings, actions, and nps_responses that have null or empty client_uuid
- Displays counts per table with visual indicators

### Stale Data Warnings
- Monitors last update timestamps for key data sources:
  - Health Snapshots (client_health_history)
  - Actions
  - Meetings (unified_meetings)
  - Aged Accounts (aging_accounts)
  - NPS Responses
- Severity levels:
  - **OK**: Updated within 24 hours
  - **Warning**: Updated 24-168 hours ago (1-7 days)
  - **Critical**: Updated more than 168 hours ago (7+ days) or never

### Name Mismatch Detection
- Compares client_name values in aging_accounts and unified_meetings against:
  - Known client names from the clients table
  - Active aliases from client_name_aliases table
- Reports unmatched names with record counts

### Data Completeness Metrics
- Calculates percentage of records with valid client_uuid for each table
- Visual progress bars with colour coding:
  - Green: 95%+ completeness
  - Amber: 80-94% completeness
  - Red: Below 80% completeness

## Technical Notes

- Uses British/Australian English spelling as per project guidelines
- Follows existing codebase patterns for API routes and components
- Uses shadcn/ui components (Card, Badge, Table, Progress, Alert)
- Lucide React icons for visual consistency
- date-fns for timestamp formatting

## Testing

- TypeScript compilation: Passed
- ESLint: Passed
- Manual verification: Pending deployment

## Related Database Tables Referenced

From `docs/database-schema.md`:
- `unified_meetings` - client_uuid, client_name, updated_at columns
- `actions` - client_uuid, client, updated_at columns
- `nps_responses` - client_uuid, client_name, created_at columns
- `aging_accounts` - client_uuid, client_name, updated_at columns
- `client_health_history` - snapshot_date column
- `clients` - canonical_name column
- `client_name_aliases` - display_name, canonical_name, is_active columns
