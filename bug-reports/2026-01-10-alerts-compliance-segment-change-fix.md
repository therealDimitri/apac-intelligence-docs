# Bug Fix: Alerts API Compliance Data Not Segment-Change Aware

**Date**: 2026-01-10
**Type**: Bug Fix
**Status**: RESOLVED
**Commit**: 96cf651e

---

## Issue

**Problem**: The Alerts API (`/api/alerts`) was calculating compliance data directly from the `segmentation_events` table without accounting for segment changes. This meant that compliance gap alerts could show incorrect data for clients who changed segments mid-year.

**Impact**:
- Clients who changed segments (e.g., from Silver to Gold) during the assessment year were being evaluated against the wrong requirements
- Compliance alerts may have been incorrectly flagged as "critical" when the client actually had extended deadlines
- Missing events alerts included events from before the segment change, which should not count against the client

**Root Cause**: The alerts API manually built compliance data by iterating over `segmentation_events` and counting completed vs total events. This raw calculation doesn't account for:
1. Extended compliance deadlines (June 30 following year) for segment-changed clients
2. The need to only count events from the segment change month onwards

---

## Fix Applied

Integrated the server-side portfolio context (`getAllClientsComplianceServer`) into the Alerts API. This function:
1. Detects if a client's segment changed during the assessment year
2. Recalculates compliance from the change month onwards (not full year)
3. Uses extended deadlines for segment-changed clients

### Changes Made

**File**: `src/app/api/alerts/route.ts`

1. **Added import**:
```typescript
import { getAllClientsComplianceServer } from '@/lib/server-portfolio-context'
```

2. **Removed direct database queries**:
- Removed `segmentation_events` query
- Removed `segmentation_event_types` query (used for event names)

3. **Added corrected compliance fetch**:
```typescript
// Fetch corrected compliance data (segment-change aware)
getAllClientsComplianceServer(priorYear),
```

4. **Replaced manual compliance calculation** with server-side portfolio data:
```typescript
const complianceData = (clientsResult.data || []).map(
  (clientData: { client_name: string; cse?: string }) => {
    const correctedCompliance = correctedComplianceMap.get(clientData.client_name)

    // Get missing events (not compliant or exceeded)
    const missingEvents = correctedCompliance
      ? correctedCompliance.event_compliance
          .filter(e => e.status !== 'compliant' && e.status !== 'exceeded')
          .map(e => e.event_type_name)
      : []

    return {
      client: clientData.client_name,
      compliancePercentage: correctedCompliance?.overall_compliance_score ?? 0,
      cse: clientData.cse || 'Unknown',
      missingEvents,
      // Include segment change info for enhanced alerts
      hasSegmentChanged: correctedCompliance?.has_segment_changed ?? false,
      monthsToDeadline: correctedCompliance?.months_to_deadline ?? 0,
    }
  }
)
```

---

## Technical Details

### Before (Incorrect)
- Queried `segmentation_events` directly for current year events
- Counted all events regardless of segment change timing
- Used raw compliance percentage: `(completed / total) * 100`
- Missing events included all incomplete events from the year

### After (Correct)
- Uses `getAllClientsComplianceServer()` which:
  - Detects segment changes via `client_segmentation` history
  - Filters events to only those after segment change month
  - Calculates compliance using recalculated event counts
  - Returns extended deadline dates for segment-changed clients
- Provides `hasSegmentChanged` and `monthsToDeadline` for enhanced alerting
- Missing events list only includes events relevant to current segment requirements

---

## Verification

1. Build passes without TypeScript errors
2. Pre-commit hooks pass (ESLint, Prettier, type check)
3. Alerts now reflect the same compliance data shown in:
   - Client Profiles page
   - Client Detail page
   - Command Centre dashboard
   - ChaSen AI responses

---

## Related Files

- `src/lib/server-portfolio-context.ts` - Server-side compliance calculations
- `src/contexts/ClientPortfolioContext.tsx` - Client-side equivalent
- `src/hooks/useEventCompliance.ts` - Original compliance hook with segment change logic

---

## Related Commits

- `ff375524` - ChaSen server-side portfolio context
- `99be43e2` - ClientPortfolioContext for list pages
- `d55ccaff` - Health score fix for segment-changed clients (original fix)
