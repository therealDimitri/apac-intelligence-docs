# Bug Report: Compliance Data Out of Sync - Albury Wodonga Insight Touch Point

**Date:** 15 December 2025
**Status:** Fixed (with Auto-Sync Implemented)
**Severity:** Medium
**Related Report:** BUG-REPORT-20251215-priority-matrix-comprehensive-review.md

## Problem Summary

Albury Wodonga Health was incorrectly displayed as having incomplete Insight Touch Points (11/12) in the Priority Matrix, when they had actually completed all 12 events. This was caused by the `segmentation_event_compliance` table being out of sync with the actual `segmentation_events` table.

## Root Cause Analysis

### Two-Table Architecture

The compliance system uses two tables:

1. **`segmentation_events`** - Individual event records with `completed` flag (source of truth)
2. **`segmentation_event_compliance`** - Aggregated `expected_count` and `actual_count` per client/event type

### The Sync Problem

The `segmentation_event_compliance` table stores pre-calculated counts but can become stale when:

- Events are marked as completed after the compliance record was created
- New events are added to `segmentation_events`
- Events are deleted or modified

### Evidence Found

| Table                           | Albury Wodonga Insight Touch Points |
| ------------------------------- | ----------------------------------- |
| `segmentation_events`           | 12 completed events ✅              |
| `segmentation_event_compliance` | 11/12 (stale) ❌                    |

### Client Name Mismatch

Additional complexity: Client names differ between tables:

- `segmentation_events`: "Albury Wodonga Health"
- `segmentation_event_compliance`: "Albury Wodonga"

## Solution Implemented

### Part 1: Manual Refresh Script (Initial Fix)

**File:** `scripts/refresh-compliance-from-events.mjs`

The script:

1. Queries all event types from `segmentation_event_types`
2. For each event type, counts completed events per client from `segmentation_events`
3. Compares with existing counts in `segmentation_event_compliance`
4. Updates any mismatched records
5. Handles client name variations using partial matching

### Part 2: Automatic Sync (Permanent Solution)

**File:** `src/lib/compliance-sync.ts`

Created a compliance sync utility that automatically updates `segmentation_event_compliance` whenever events are modified.

**File:** `src/hooks/useEvents.ts`

Integrated the sync into all event modification functions:

| Function              | Trigger Condition                    |
| --------------------- | ------------------------------------ |
| `markEventComplete()` | Always syncs after marking complete  |
| `updateEvent()`       | Syncs when `completed` field changes |
| `deleteEvent()`       | Syncs if deleted event was completed |

### Key Logic

```typescript
// src/lib/compliance-sync.ts

// Sync compliance after event changes
export async function syncComplianceForEvent(
  supabase: AnySupabaseClient,
  options: { clientName: string; eventTypeId: string; year?: number }
): Promise<SyncResult>

// Maps client name variations
const CLIENT_NAME_MAPPING: Record<string, string> = {
  'Albury Wodonga Health': 'Albury Wodonga',
  'Department of Health - Victoria': 'Dept of Health, Victoria',
  SingHealth: 'Singapore Health (SingHealth)',
  // ... more mappings
}
```

```typescript
// src/hooks/useEvents.ts

const markEventComplete = async (eventId, completedBy) => {
  // Get event details
  const { data: eventData } = await supabase
    .from('segmentation_events')
    .select('client_name, event_type_id, event_year')
    .eq('id', eventId)
    .single()

  // Update event
  await supabase.from('segmentation_events').update(...)

  // Auto-sync compliance
  if (eventData) {
    await syncComplianceForEvent(supabase, {
      clientName: eventData.client_name,
      eventTypeId: eventData.event_type_id,
      year: eventData.event_year,
    })
  }
}
```

### Database Trigger (Applied ✅)

A database trigger was also created and applied via Supabase Dashboard:

**File:** `docs/migrations/20251215_auto_sync_compliance_trigger.sql`

The trigger `sync_compliance_on_event_change` fires automatically on:

- INSERT into `segmentation_events`
- UPDATE of `completed` column
- DELETE from `segmentation_events`

This provides a second layer of sync that works even for direct database modifications outside the application.

## Files Created/Modified

| File                                                        | Purpose                                           |
| ----------------------------------------------------------- | ------------------------------------------------- |
| `scripts/refresh-compliance-from-events.mjs`                | Manual sync script for one-off refreshes          |
| `scripts/debug-insight-touchpoint.mjs`                      | Debug script to investigate compliance data       |
| `src/lib/compliance-sync.ts`                                | **NEW** - Compliance sync utility                 |
| `src/hooks/useEvents.ts`                                    | **MODIFIED** - Added auto-sync to event mutations |
| `docs/migrations/20251215_auto_sync_compliance_trigger.sql` | Database trigger (optional)                       |

## Testing Performed

1. Ran debug script to identify the initial discrepancy
2. Ran manual refresh script to sync data
3. Verified TypeScript compilation (0 errors)
4. Verified build succeeds
5. Confirmed Albury Wodonga no longer in incomplete clients list
6. Priority Matrix now shows correct client logos for incomplete events

## How Auto-Sync Works

```
User marks event complete
        │
        ▼
useEvents.markEventComplete()
        │
        ├── 1. Fetch event details (client_name, event_type_id, year)
        │
        ├── 2. Update segmentation_events.completed = true
        │
        └── 3. syncComplianceForEvent()
                │
                ├── Count all completed events for this client/event type/year
                │
                ├── Find matching compliance record (with name normalisation)
                │
                └── Update segmentation_event_compliance.actual_count
```

## Impact

- **Data Accuracy:** Compliance percentages now automatically match actual completed events
- **User Trust:** Priority Matrix no longer shows false positives for incomplete events
- **Client Relations:** Correct recognition for clients who have completed their requirements
- **Maintenance Free:** No need to manually run sync scripts - data stays in sync automatically

## Related Documentation

- `docs/database-schema.md` - Table definitions
- The `segmentation_events` table is the source of truth for individual event completion
- The `segmentation_event_compliance` table is a denormalised cache that is now auto-synced
