# Bug Report: View Event Details Navigation Fix

**Date:** 15 December 2025
**Status:** Fixed
**Severity:** Medium
**Commits:** f8902ef, 64a7e00, 9dd4936, 1291b5a

## Problem Summary

The "View Event Details" link in the Priority Matrix critical alerts was navigating to a defunct Client Segmentation page instead of showing the specific clients that need the event completed.

## Symptoms

1. User clicks "View Event Details" on a compliance alert (e.g., "Health Check (Opal) severely behind schedule")
2. Page navigates to `/segmentation` which shows all clients in a generic segmentation view
3. No filtering by event type - user cannot see which clients actually need that specific event

## Root Cause Analysis

The `ActionableIntelligenceDashboard.tsx` component had a hardcoded link to `/segmentation` for compliance alerts:

```typescript
// Before (line 336):
{ label: 'View Event Details', action: 'view', href: '/segmentation' }
```

This destination page:

- Was a generic segmentation view showing all clients
- Had no capability to filter by event type
- Did not highlight which clients were non-compliant for specific events

## Solution Implemented

### 1. Updated Navigation Link

Changed the href to include the event type as a URL parameter:

```typescript
// After:
{ label: 'View Event Details', action: 'view', href: `/client-profiles?eventType=${encodeURIComponent(event.name)}` }
```

### 2. Created New API Endpoint

**File:** `src/app/api/event-compliance/route.ts`

Created a new API endpoint to fetch compliance data for a specific event type:

- Queries `segmentation_event_types` to find the event type ID
- Queries `segmentation_event_compliance` table (the canonical source used by Priority Matrix)
- Returns clients with `expected_count > 0` and their compliance status
- Sorts by compliance percentage (lowest first, most critical)

**Follow-up Fix (64a7e00):** Initial implementation queried `segmentation_events` table instead of `segmentation_event_compliance`. This caused a data mismatch where the API returned "All clients have completed this event" while the Priority Matrix showed the event as severely behind schedule. The tables serve different purposes:

- `segmentation_events`: Individual event records with `completed` boolean
- `segmentation_event_compliance`: Aggregated compliance data with `expected_count` and `actual_count` per client per event type (used by Priority Matrix RPC functions)

**Follow-up Fix (9dd4936):** Client names in `segmentation_event_compliance` don't match canonical names in `nps_clients`. Added mapping to normalize names:

| Compliance Table                | nps_clients (canonical)           |
| ------------------------------- | --------------------------------- |
| "Dept of Health, Victoria"      | "Department of Health - Victoria" |
| "Singapore Health (SingHealth)" | "SingHealth"                      |
| "Albury Wodonga"                | "Albury Wodonga Health"           |
| "Barwon Health"                 | "Barwon Health Australia"         |
| "Waikato"                       | "Te Whatu Ora Waikato"            |

**Follow-up Fix (1291b5a):** The Priority Matrix was showing wrong client logos on compliance alerts. The `extractClientsFromEventData` function extracts clients from `monthlyData.clientBreakdown` which shows clients who **completed** events. For "behind schedule" alerts, this showed SA Health's logo (who completed the event) instead of the clients who **haven't** completed (Vic Health, SingHealth, WA Health). Fixed by skipping client extraction for compliance-type alerts.

### 3. Updated Client Profiles Page

**File:** `src/app/(dashboard)/client-profiles/page.tsx`

Enhanced the page to support event type filtering:

- Added `useSearchParams` hook to read URL parameters
- Added state for event compliance data
- Added `useEffect` to fetch compliance data when `eventType` filter is present
- Added filter banner showing the active event type filter with clear option
- Filters displayed clients to only those needing the event
- Sorts clients by compliance percentage (lowest first, showing most critical)
- Added Suspense boundary for SSR compatibility

## Files Changed

| File                                                 | Changes                                                               |
| ---------------------------------------------------- | --------------------------------------------------------------------- |
| `src/components/ActionableIntelligenceDashboard.tsx` | Updated href from `/segmentation` to `/client-profiles?eventType=...` |
| `src/app/(dashboard)/client-profiles/page.tsx`       | Added event type filter support, compliance fetching, filter banner   |
| `src/app/api/event-compliance/route.ts`              | New API endpoint for fetching client compliance data by event type    |

## Testing Performed

1. Verified "View Event Details" now navigates to `/client-profiles?eventType=...`
2. Confirmed only clients needing that event type are displayed
3. Verified filter banner appears with event type name
4. Confirmed "Clear Filter" button removes the filter
5. TypeScript compilation successful
6. ESLint checks passed

## Impact

- **User Experience:** Users can now directly see which clients need attention for specific compliance events
- **Efficiency:** Eliminates manual searching through all clients to find non-compliant ones
- **Actionability:** Compliance alerts now lead to actionable views with relevant clients only

## Related Documentation

- Alert Centre was removed as alerts are now in Priority Matrix (same session)
- Traditional View button removed (same session)
- "Actionable Intelligence Command Centre" banner removed (same session)
