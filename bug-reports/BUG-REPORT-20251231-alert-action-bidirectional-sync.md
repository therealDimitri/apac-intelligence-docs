# Bug Report: Alert-Action Bidirectional Sync

**Date:** 31 December 2025
**Status:** ✅ RESOLVED
**Severity:** Medium
**Component:** Priority Matrix, Actions API

## Problem Summary

Alerts and actions were linked but not fully synchronised. When an action's status or priority changed, the linked alert was not updated. This caused inconsistencies between the Priority Matrix (showing alerts) and the Actions page (showing actions).

### Symptoms

1. Priority Matrix showed different priority than Actions page for the same item
2. Completing an action did not resolve the linked alert
3. Cancelling an action did not dismiss the linked alert
4. Priority changes were not reflected bidirectionally

### Example

S13 action showed as:
- **Priority Matrix:** HIGH severity (from alert)
- **Actions page:** Medium priority (from action)

## Root Cause

The system had:
- ✅ Alert → Action sync (in `/api/alerts/persisted/[id]/route.ts`)
- ❌ Action → Alert sync (missing from `/api/actions/[id]/route.ts`)

When actions were updated through the Actions API, no callback existed to update the linked alert.

## Solution Applied

### 1. Added Action → Alert Sync in `/api/actions/[id]/route.ts`

**PATCH handler now:**
- Checks if action has `source_alert_id`
- When status changes to Complete/Completed → resolves linked alert
- When status changes to Cancelled → dismisses linked alert
- When priority changes → updates alert severity

**DELETE handler now:**
- Checks for linked alert before deletion
- Dismisses the linked alert with reason "Linked action was deleted"

### 2. Priority Mapping

```typescript
const priorityToSeverity: Record<string, string> = {
  Critical: 'critical',
  High: 'high',
  Medium: 'medium',
  Low: 'low',
}
```

### 3. Files Modified

- `src/app/api/actions/[id]/route.ts` - Added bidirectional sync logic
- `src/components/ActionableIntelligenceDashboard.tsx` - Added owner/department to CriticalAlert
- `src/components/priority-matrix/types.ts` - Added owners and actionId to MatrixItem metadata
- `src/components/priority-matrix/utils.ts` - Pass action metadata through to matrix items

## Verification

After fix:
```
=== SUMMARY ===
Total linked alerts: 10
Total linked actions: 10
All priorities in sync: YES
```

All 10 linked alert-action pairs now have:
- Matching priorities (alert severity = action priority)
- Bidirectional IDs (`linked_action_id` ↔ `source_alert_id`)
- Owner/department data passed through to Priority Matrix

## Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     ALERT GENERATED                          │
│              (from health decline, overdue, etc.)           │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                 USER CREATES ACTION                          │
│    POST /api/alerts/persisted/[id]/create-action            │
│    - Creates action with source_alert_id                     │
│    - Updates alert with linked_action_id                     │
└─────────────────────┬───────────────────────────────────────┘
                      │
          ┌───────────┴───────────┐
          ▼                       ▼
┌─────────────────────┐  ┌─────────────────────┐
│   ALERT UPDATED     │  │   ACTION UPDATED    │
│   PATCH /alerts/    │  │   PATCH /actions/   │
│   [id]              │  │   [id]              │
│                     │  │                     │
│   → Syncs to action │  │   → Syncs to alert  │
│     status/priority │  │     status/severity │
└─────────────────────┘  └─────────────────────┘
```

## Related Scripts

- `scripts/backfill-alerts.mjs` - Creates alerts from existing overdue actions
- `scripts/sync-alert-priorities.mjs` - Recalculates alert severity and syncs priorities

## Testing Checklist

- [x] Type check passes (`npx tsc --noEmit`)
- [x] All 10 linked pairs verified in sync
- [x] Priority mapping correct (Critical↔critical, High↔high, etc.)
- [x] Both PATCH and DELETE handlers updated
