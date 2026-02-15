# Planning Hub Compliance API Routes

**Date**: 2026-01-09
**Feature**: Planning Hub Compliance and Segmentation API Routes
**Status**: Implemented

## Overview

This document covers the implementation of three new API routes for the Planning Hub to support compliance tracking and engagement timeline features.

## API Routes Created

### 1. Account-Level Compliance API

**Endpoint**: `GET /api/planning/compliance/account`

**File**: `/src/app/api/planning/compliance/account/route.ts`

**Purpose**: Fetches account-level compliance requirements and status for a specific client.

**Query Parameters**:
- `clientName` (required): The client name to fetch compliance for
- `year` (optional): The calendar year (defaults to current year)
- `includeHistory` (optional): Include historical compliance data (defaults to false)

**Data Sources**:
- `client_segmentation` - Client tier and CSE assignments
- `event_compliance_summary` - Materialised view for compliance metrics
- `segmentation_event_compliance` - Raw compliance records per event type
- `segmentation_events` - Completed and upcoming events
- `segmentation_event_types` - Event type definitions
- `client_health_history` - Historical health data (if includeHistory=true)

**Response Structure**:
```typescript
{
  success: boolean
  clientName: string
  canonicalName: string
  year: number
  segmentation: {
    tierId: string | null
    tierName: string | null
    cseName: string | null
    effectiveFrom: string | null
    effectiveTo: string | null
  }
  requirements: EventRequirement[]
  summary: {
    totalEventTypes: number
    compliantEventTypes: number
    overallCompliancePercentage: number
    overallStatus: 'critical' | 'at-risk' | 'compliant'
  }
  deadline: {
    date: string
    isExtended: boolean
    reason: string | null
    monthsRemaining: number
  }
  lastUpdated: string
}
```

### 2. Territory-Level Compliance Summary API

**Endpoint**: `GET /api/planning/compliance/territory`

**File**: `/src/app/api/planning/compliance/territory/route.ts`

**Purpose**: Fetches territory-level compliance summary aggregating data across all clients assigned to a CSE or CAM.

**Query Parameters**:
- `cseName` (optional): Filter by CSE name
- `camName` (optional): Filter by CAM name
- `year` (optional): The calendar year (defaults to current year)
- `segment` (optional): Filter by client segment/tier
- `status` (optional): Filter by compliance status (critical, at-risk, compliant)

**Data Sources**:
- `event_compliance_summary` - Materialised view for compliance metrics
- `nps_clients` - CAM assignments
- `client_segmentation` - Segment change detection
- `segmentation_event_compliance` - Per-event-type compliance details
- `segmentation_event_types` - Event type definitions

**Response Structure**:
```typescript
{
  success: boolean
  territory: {
    cseName: string | null
    camName: string | null
    totalClients: number
    year: number
  }
  summary: {
    overallCompliancePercentage: number
    overallStatus: 'critical' | 'at-risk' | 'compliant'
    clientsCompliant: number
    clientsAtRisk: number
    clientsCritical: number
    totalEventTypesTracked: number
    averageComplianceBySegment: Record<string, number>
  }
  clients: ClientComplianceSummary[]
  eventTypeAggregates: EventTypeAggregate[]
  recommendations: Array<{
    type: 'urgent' | 'warning' | 'info'
    message: string
    clientsAffected: string[]
  }>
  lastUpdated: string
}
```

### 3. Engagement Timeline API (Enhanced)

**Endpoint**: `GET /api/planning/timeline`

**File**: `/src/app/api/planning/timeline/route.ts`

**Purpose**: Fetches comprehensive engagement timeline for a client, combining data from multiple sources.

**Query Parameters**:
- `clientId` (optional): Client UUID for lookup
- `clientName` (optional): Client name (at least one required)
- `months` (optional): Number of months of history (default: 12)
- `types` (optional): Comma-separated list of event types (meeting, nps, action, health, event)
- `startDate` (optional): Start of date range (ISO format)
- `endDate` (optional): End of date range (ISO format)

**Data Sources**:
- `unified_meetings` - Meeting records
- `nps_responses` - NPS survey responses
- `actions` - Action items
- `client_health_history` - Health score changes
- `segmentation_events` - Compliance events (NEW)
- `segmentation_event_types` - Event type definitions (NEW)

**Response Structure**:
```typescript
{
  success: boolean
  data: {
    events: TimelineEvent[]
    eventsByMonth: Record<string, TimelineEvent[]>
    summary: {
      totalMeetings: number
      totalNPSResponses: number
      totalActions: number
      totalHealthChanges: number
      totalComplianceEvents: number  // NEW
      completedActions: number
      overdueActions: number
      completedComplianceEvents: number  // NEW
      pendingComplianceEvents: number  // NEW
    }
    velocity: {
      meetingsPerMonth: Array<{ month: string; count: number }>
      averageMeetingsPerMonth: number
      trend: number
      trendDirection: 'increasing' | 'decreasing' | 'stable'
    }
    dateRange: {
      start: string
      end: string
    }
  }
}
```

## Key Features

### Compliance Calculation Logic

1. **Per-event-type compliance**: `(actual_count / expected_count) x 100`
2. **Overall compliance score**: `(Event Types with >= 100% / Total Event Types) x 100`

### Status Thresholds

- **Critical**: < 50% compliance
- **At-Risk**: 50-79% compliance
- **Compliant**: >= 80% compliance
- **Exceeded**: > 100% (for individual event types only)

### Deadline Extension Logic

When a client's segment changes during a calendar year:
- Standard deadline: 31 December of the compliance year
- Extended deadline: 30 June of the following year
- This allows 12+ months for newly segmented clients to meet requirements

### Client Name Mapping

The routes include comprehensive client name mapping to handle inconsistencies between tables:
- `Albury Wodonga Health` <-> `Albury Wodonga`
- `SingHealth` <-> `Singapore Health (SingHealth)`
- `Department of Health - Victoria` <-> `Dept of Health, Victoria`
- etc.

## Usage Examples

### Account Compliance
```bash
# Get compliance for a specific client
GET /api/planning/compliance/account?clientName=SA%20Health&year=2025

# Include historical data
GET /api/planning/compliance/account?clientName=SA%20Health&includeHistory=true
```

### Territory Compliance
```bash
# Get all clients for a CSE
GET /api/planning/compliance/territory?cseName=John%20Smith

# Filter by segment
GET /api/planning/compliance/territory?cseName=John%20Smith&segment=Strategic

# Filter by status
GET /api/planning/compliance/territory?status=critical
```

### Timeline
```bash
# Get full timeline
GET /api/planning/timeline?clientName=SA%20Health

# Filter by event types
GET /api/planning/timeline?clientName=SA%20Health&types=meeting,event

# Custom date range
GET /api/planning/timeline?clientName=SA%20Health&startDate=2025-01-01&endDate=2025-06-30
```

## Related Files

- `/src/hooks/useEventCompliance.ts` - Client-side compliance hook
- `/src/lib/compliance-sync.ts` - Compliance sync utilities
- `/src/lib/segment-deadline-utils.ts` - Deadline calculation utilities
- `/src/app/api/event-types/route.ts` - Event types API
- `/src/app/api/segmentation-events/route.ts` - Segmentation events API

## Future Enhancements

1. Add support for new tables when created:
   - `account_plan_event_requirements`
   - `territory_compliance_summary`
   - `engagement_timeline`

2. Consider caching layer for frequently accessed compliance data

3. Add WebSocket support for real-time compliance updates
