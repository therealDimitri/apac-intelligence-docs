# Feature: Alert-to-Action Automation System

**Date:** 2025-12-31
**Status:** Fully Implemented ✅

## Summary

Implemented a complete alert-to-action automation system with:
1. **Persisted alerts table** with status tracking (active, acknowledged, resolved, dismissed)
2. **Automatic action creation** for critical alerts
3. **`source_alert_id` linkage** in actions table for full traceability
4. **Deduplication logic** using MD5 fingerprinting to prevent duplicate alerts/actions
5. **Quick action context menus** for alert status management

## Components Created/Modified

### New Files

1. **`docs/migrations/20251231_alerts_table_and_action_linking.sql`**
   - Complete SQL migration for alerts table, fingerprints table
   - RLS policies for secure access
   - Indexes for performance
   - Helper functions for alert management

2. **`src/app/api/alerts/persisted/route.ts`**
   - GET: Fetch all persisted alerts with filters (status, severity, category, client)
   - POST: Create/upsert alert with deduplication via fingerprinting

3. **`src/app/api/alerts/persisted/[id]/route.ts`**
   - GET: Fetch single alert by ID
   - PATCH: Update alert status with timestamps
   - DELETE: Delete alert and fingerprint references

4. **`src/app/api/alerts/persisted/[id]/create-action/route.ts`**
   - POST: Creates an action from an existing alert
   - Auto-generates Action_ID, sets source_alert_id and source_alert_text_id
   - Marks alert as acknowledged and links action

5. **`src/hooks/usePersistedAlerts.ts`**
   - Hook for managing persisted alerts with full CRUD operations
   - Includes: `acknowledgeAlert`, `resolveAlert`, `dismissAlert`, `reactivateAlert`, `createActionFromAlert`
   - Batch operations: `acknowledgeMultiple`, `dismissMultiple`
   - Stats calculation for dashboard

6. **`src/components/alerts/AlertContextMenu.tsx`**
   - Portal-rendered context menu for alert quick actions
   - Dynamically builds menu items based on alert status
   - Includes dismiss reason input
   - Handles: acknowledge, resolve, dismiss, reactivate, create action, view client

### Modified Files

1. **`src/components/AlertCenter.tsx`**
   - Added persisted alerts integration with `showPersistedAlerts` prop
   - Added status filter dropdown
   - Added enhanced context menu for persisted alerts
   - Quick status action buttons (acknowledge, resolve, reactivate, create action)

2. **`src/lib/alert-system.ts`**
   - Added `persistAlert()` function to persist single alerts to database
   - Added `persistAlerts()` function to persist multiple alerts with progress tracking
   - Added `detectAndPersistAlerts()` convenience function combining detection and persistence
   - Automatic action creation for critical alerts when persisting

3. **`src/components/CreateActionModal.tsx`**
   - Added `sourceAlertId` and `sourceAlertTextId` props for linking actions to source alerts
   - Added `InitialActionData.sourceAlertId` and `InitialActionData.sourceAlertTextId` fields
   - Automatically updates source alert when action is created (marks as acknowledged, links action ID)

## Database Schema

### alerts table
```sql
CREATE TABLE alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  alert_id TEXT UNIQUE NOT NULL,
  category TEXT NOT NULL,
  severity TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  recommendation TEXT,
  client_name TEXT NOT NULL,
  client_id INTEGER REFERENCES clients(id),
  client_uuid UUID,
  cse_name TEXT,
  cse_email TEXT,
  current_value TEXT,
  previous_value TEXT,
  threshold_value TEXT,
  metadata JSONB DEFAULT '{}',
  auto_action_created BOOLEAN DEFAULT FALSE,
  linked_action_id TEXT,
  detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  acknowledged_at TIMESTAMPTZ,
  acknowledged_by TEXT,
  resolved_at TIMESTAMPTZ,
  resolved_by TEXT,
  dismissed_at TIMESTAMPTZ,
  dismissed_by TEXT,
  dismiss_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### alert_fingerprints table (for deduplication)
```sql
CREATE TABLE alert_fingerprints (
  fingerprint TEXT PRIMARY KEY,
  alert_id UUID REFERENCES alerts(id) ON DELETE CASCADE,
  first_detected_at TIMESTAMPTZ DEFAULT NOW(),
  last_detected_at TIMESTAMPTZ DEFAULT NOW(),
  occurrence_count INTEGER DEFAULT 1
);
```

### actions table additions
```sql
ALTER TABLE actions ADD COLUMN IF NOT EXISTS source_alert_id UUID;
ALTER TABLE actions ADD COLUMN IF NOT EXISTS source_alert_text_id TEXT;
```

## Alert Status Workflow

```
[New Alert] → active → acknowledged → resolved
                  ↓         ↓
               dismissed ← ─┘
                  ↓
            (can reactivate)
```

## Deduplication Logic

Alerts are deduplicated using an MD5 fingerprint of:
- `category`
- `client_name` (normalised to lowercase)
- `current_value` (optional)

When a duplicate is detected:
1. The occurrence count is incremented
2. The `last_detected_at` timestamp is updated
3. The existing alert is returned instead of creating a new one

## Usage

### Enable Persisted Alerts in AlertCenter
```tsx
<AlertCenter
  cseName="John Smith"
  showPersistedAlerts={true}
/>
```

### Create a Persisted Alert
```typescript
const response = await fetch('/api/alerts/persisted', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    alert_id: 'ALERT-001',
    category: 'health_decline',
    severity: 'critical',
    title: 'Health Score Dropped',
    description: 'Client health score dropped by 15 points',
    client_name: 'Acme Corp',
    auto_create_action: true, // Auto-create action for critical alerts
  }),
})
```

### Use the Hook
```typescript
const {
  alerts,
  loading,
  acknowledgeAlert,
  resolveAlert,
  dismissAlert,
  createActionFromAlert,
} = usePersistedAlerts({ status: 'active' })
```

### Persist Alerts from alert-system.ts
```typescript
import { detectAndPersistAlerts, persistAlert, persistAlerts } from '@/lib/alert-system'

// Option 1: Detect and persist in one operation
const { alerts, persistResults } = await detectAndPersistAlerts({
  clients: healthData,
  npsData: npsResponses,
}, {
  autoCreateActionForCritical: true,
  onProgress: (current, total) => console.log(`${current}/${total}`)
})

// Option 2: Persist a single alert
const result = await persistAlert(myAlert, { autoCreateAction: true })

// Option 3: Persist multiple alerts
const results = await persistAlerts(alertsArray, {
  autoCreateActionForCritical: true,
})
```

### Create Action from Alert with Linking
```tsx
<CreateActionModal
  isOpen={showModal}
  onClose={() => setShowModal(false)}
  onSuccess={handleSuccess}
  sourceAlertId="uuid-of-source-alert"
  sourceAlertTextId="health-critical-ClientName-123"
  initialData={{
    title: 'Follow up on health decline',
    client: 'Client Name',
    priority: 'high',
  }}
/>
```

## Completed Items ✅

1. ✅ **Database Migration Applied**: Tables created in Supabase
   - `alerts` table with status tracking
   - `alert_fingerprints` table for deduplication
   - `actions.source_alert_id` and `actions.source_alert_text_id` columns

2. ✅ **alert-system.ts Updated**: Added persistence functions
   - `persistAlert()` - persist single alert
   - `persistAlerts()` - persist multiple with progress
   - `detectAndPersistAlerts()` - detect + persist in one call

3. ✅ **CreateActionModal Updated**: Source alert linking
   - `sourceAlertId` prop for UUID linking
   - `sourceAlertTextId` prop for text ID linking
   - Auto-updates source alert on action creation

## Testing

1. Run TypeScript check: `npx tsc --noEmit` - Passes with no errors
2. Verify API routes work correctly after database migration
3. Test context menu functionality in the AlertCenter

## Related Files

- `src/lib/alert-system.ts` - Alert generation logic
- `src/app/(dashboard)/alerts/page.tsx` - Alerts dashboard page
