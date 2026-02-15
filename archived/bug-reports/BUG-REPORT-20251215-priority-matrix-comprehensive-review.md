# Bug Report: Priority Matrix Comprehensive Review & Fixes

**Date:** 15 December 2025
**Status:** Fixed
**Severity:** Medium
**Related Report:** BUG-REPORT-20251215-view-event-details-navigation.md

## Problem Summary

Following the initial View Event Details navigation fix, a comprehensive review of the Priority Matrix revealed additional issues:

1. **Multiple `/segmentation` links still present** - 5 additional links pointed to the defunct segmentation page
2. **Wrong client logos on compliance alerts** - Showing clients who completed events instead of clients who need to complete them
3. **Client name mismatches** - Names in `segmentation_event_compliance` table don't match canonical names in `nps_clients`

## Issues Found & Fixed

### Issue 1: Remaining `/segmentation` Links

**Location:** `src/components/ActionableIntelligenceDashboard.tsx`

| Line | Original Link                                          | Fixed Link                       |
| ---- | ------------------------------------------------------ | -------------------------------- |
| 233  | `/segmentation` (Attrition "View Segmentation Events") | `/client-profiles?search=...`    |
| 479  | `/segmentation` (Priority action for events)           | `/client-profiles?eventType=...` |
| 710  | `/segmentation` ("View All Clients")                   | `/client-profiles`               |
| 711  | `/segmentation` ("Filter by Segment")                  | `/client-profiles`               |
| 750  | `/segmentation` ("View Breakdown")                     | `/client-profiles`               |

### Issue 2: Wrong Client Logos on Multi-Client Alerts

**Root Cause:** The `extractClientsFromEventData` function in `utils.ts` extracted clients from `monthlyData.clientBreakdown`, which shows clients who **completed** events. For compliance alerts (events "behind schedule"), this displayed the wrong clients.

**Example:** For "Health Check (Opal) severely behind schedule":

- **Before:** Showed SA Health's logo (who completed the event)
- **After:** Shows Vic Health, SingHealth, WA Health logos (who need to complete it)

**Solution:** Enhanced the `/api/event-types` endpoint to return `incompleteClients` for each event type by querying `segmentation_event_compliance` table. Updated `criticalAlertsToMatrixItems` and `priorityActionsToMatrixItems` functions to use this data.

### Issue 3: Client Name Normalisation

**Problem:** The `segmentation_event_compliance` table uses variant client names that don't match `nps_clients` canonical names, causing logo lookups to fail.

**Solution:** Added comprehensive client name mapping:

```typescript
const COMPLIANCE_TO_CANONICAL: Record<string, string> = {
  'Dept of Health, Victoria': 'Department of Health - Victoria',
  'Singapore Health (SingHealth)': 'SingHealth',
  'Albury Wodonga': 'Albury Wodonga Health',
  'Barwon Health': 'Barwon Health Australia',
  'Royal Victorian Eye and Ear Hospital (RVEEH)': 'The Royal Victorian Eye and Ear Hospital',
  'Royal Victorian Eye and Ear Hospital': 'The Royal Victorian Eye and Ear Hospital',
  "Saint Luke's Medical Centre (SLMC)": "St Luke's Medical Centre",
  'NCS/MinDef Singapore': 'Ministry of Defence, Singapore',
  Waikato: 'Te Whatu Ora Waikato',
}
```

## Files Changed

| File                                                 | Changes                                                                                                                                 |
| ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `src/components/ActionableIntelligenceDashboard.tsx` | Fixed 5 `/segmentation` links to point to `/client-profiles`                                                                            |
| `src/app/api/event-types/route.ts`                   | Added `incompleteClients` field to response, added client name mapping                                                                  |
| `src/app/api/event-compliance/route.ts`              | Updated client name mapping to match                                                                                                    |
| `src/components/priority-matrix/utils.ts`            | Updated `EventTypeData` interface, modified `criticalAlertsToMatrixItems` and `priorityActionsToMatrixItems` to use `incompleteClients` |

## Technical Details

### Data Flow (Fixed)

```
segmentation_event_compliance table
        │
        ▼
/api/event-types (adds incompleteClients per event)
        │
        ▼
ActionableIntelligenceDashboard (passes eventData to alerts)
        │
        ▼
utils.ts (uses incompleteClients for compliance/event alerts)
        │
        ▼
PriorityMatrix (displays correct client logos)
```

### Key Logic Changes

**Before (utils.ts):**

```typescript
// Always extracted from monthlyData (shows COMPLETED clients)
const clients = extractClientsFromEventData(alert.eventData)
```

**After (utils.ts):**

```typescript
// For compliance alerts: use incompleteClients (shows INCOMPLETE clients)
// For other alerts: extract from monthlyData
if (isComplianceAlert && alert.eventData?.incompleteClients?.length) {
  clients = alert.eventData.incompleteClients
} else if (!isComplianceAlert && alert.eventData) {
  clients = extractClientsFromEventData(alert.eventData)
}
```

## Testing Performed

1. TypeScript compilation verified
2. Build succeeded
3. Verified Priority Matrix shows correct client logos:
   - "Health Check (Opal) severely behind schedule" now shows Vic Health, SingHealth, WA Health (incomplete)
   - Not SA Health (who completed the event)
4. Verified all "View Event Details" links navigate to `/client-profiles?eventType=...`
5. Verified client filter banners appear correctly on Client Profiles page
6. Console logs confirm `incompleteClients` data is being used

## Impact

- **Correct Information:** Users now see which clients actually need attention, not which clients completed events
- **Actionable Navigation:** All "View Details" links lead to filtered, relevant client views
- **Logo Accuracy:** Multi-client alerts display logos for the correct clients
- **Data Consistency:** Client names are normalised between database tables and UI

## Related Documentation

- BUG-REPORT-20251215-view-event-details-navigation.md (initial fix)
- The `segmentation_event_compliance` table is the canonical source for compliance data
- The `monthlyData.clientBreakdown` shows completed events, not required events
