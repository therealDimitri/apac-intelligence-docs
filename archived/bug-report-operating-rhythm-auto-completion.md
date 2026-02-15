# Bug Report: Operating Rhythm Auto-Completing Activities Based on Dates

**Date:** 2026-02-02
**Status:** Fixed
**Severity:** High
**Component:** Operating Rhythm / AnnualOrbitView

## Issue Description

The Operating Rhythm page was auto-completing client activities based on dates instead of actual completion status from the Segmentation Progress page. Activities appeared as "completed" even when they hadn't been logged via the dashboard.

## Root Cause

The `AnnualOrbitView` component had fallback logic that generated mock completion data when the `activityCompletions` prop was not passed. Since the page never passed this prop, the component always used mock data that auto-completed activities based on whether the current date had passed each activity's scheduled date.

## Solution Implemented

### 1. Created `useOperatingRhythmData` Hook
- Transforms real compliance data from `segmentation_events` table
- Uses `useAllClientsCompliance(year)` to fetch actual completions
- Maps database records to `ActivityCompletion` format for the orbit view

### 2. Added Excel Sync System
Created a complete Excel sync pipeline to capture completions from both sources:

- **`activity-register-parser.ts`**: Parses the APAC Client Segmentation Activity Register Excel file
- **`activity-sync-service.ts`**: Syncs parsed activities to database with deduplication
- **`upsert_segmentation_event` RPC**: Database function for insert/update with source priority
- **`/api/cron/excel-sync` endpoint**: API route for scheduled syncing

### 3. Deduplication Logic
- Unique key: `client_name` + `event_type_id` + `DATE(event_date)`
- Dashboard source has priority over Excel source when merging
- Prevents duplicate records when same activity logged in both places

## Files Changed

- `src/hooks/useOperatingRhythmData.ts` (new)
- `src/app/(dashboard)/operating-rhythm/page.tsx` (modified)
- `src/lib/excel-sync/activity-register-parser.ts` (new)
- `src/lib/excel-sync/activity-sync-service.ts` (new)
- `src/lib/excel-sync/index.ts` (new)
- `src/app/api/cron/excel-sync/route.ts` (new)
- `supabase/migrations/20260202_upsert_segmentation_event.sql` (new)

## Testing

1. Build passes with zero TypeScript errors
2. Netlify deployment successful
3. Operating Rhythm now shows only actual completed activities
4. Dashboard "Log Event" completions properly reflected
5. Excel sync ready for scheduled execution

## Prevention

- Removed mock data fallback from AnnualOrbitView
- Activity completions now always come from database
- Single source of truth via `segmentation_events` table with source tracking
