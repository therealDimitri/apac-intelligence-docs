# BUG REPORT: Client Segmentation Page - Missing Event Tracking & Compliance Monitoring System

**Date:** 2025-11-27
**Severity:** CRITICAL
**Category:** Missing Core Functionality
**Affects:** Client Segmentation Page (`/segmentation`)
**Status:** Identified - Implementation Required

---

## Executive Summary

The new Client Segmentation page (`src/app/(dashboard)/segmentation/page.tsx`) is missing the **entire event tracking and compliance monitoring system** that was the core value proposition of the old dashboard implementation.

**Current State:** Static visual grouping of clients by segment with basic NPS/Health Score averages
**Expected State:** Comprehensive Client Engagement Compliance Management System with event tracking, compliance scoring, and segment-specific requirement monitoring

**Impact:** CRITICAL - The dashboard cannot fulfill its primary purpose of tracking and ensuring compliance with segment-specific engagement requirements as defined in the official Altera APAC Client Segmentation Best Practice Guide (August 2024).

---

## User Discovery

**User Report:**

> [BUG] Review the client segmentation page in this dashboard and compare it to the old version in /Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Clients - Client Success/CS Connect Meetings/Sandbox/cs-connect-dashboard_sandbox Analyse the differences in functionality, data structure and analytics.

**User Expectation:** Feature parity with old dashboard's event tracking and compliance monitoring capabilities.

---

## Comparative Analysis

### Old Dashboard Implementation

**File:** `cs-connect-dashboard_sandbox/src/components/segmentation/client-segmentation-progress.js` (1101 lines)

**Core Features:**

1. ✅ Event tracking across 12 official Altera APAC event types
2. ✅ Event-level compliance scoring using formula: (compliant event types / total event types) × 100
3. ✅ Segment-specific requirement management (different event frequencies per segment)
4. ✅ Event calendar with schedule, complete, and link functionality
5. ✅ Historical segment tracking with effective_from/effective_to dates
6. ✅ CSE workload management and CSE-view toggle
7. ✅ Expandable client cards showing event-level breakdown
8. ✅ Per-event-type compliance status (critical/at-risk/compliant)
9. ✅ Integration with 7 database tables for comprehensive tracking
10. ✅ Real-time event completion tracking
11. ✅ Mock data fallback for graceful degradation

**Database Schema (5 tables):**

- `client_segmentation` - Client-tier assignments with historical tracking
- `segmentation_events` - Individual event records with completion status
- `segmentation_event_types` - 12 event type definitions
- `tier_event_requirements` - Required event counts per tier/segment
- `segmentation_compliance_scores` - Yearly compliance aggregates
- `segmentation_event_compliance` - Event-level compliance calculations
- `segmentation_tiers` - Tier/segment definitions

### New Dashboard Implementation

**File:** `src/app/(dashboard)/segmentation/page.tsx` (500+ lines)

**Current Features:**

1. ✅ Visual grouping of clients by 6 segments
2. ✅ Summary statistics (Total, Healthy, At-Risk, Critical counts)
3. ✅ Per-segment average NPS and Health Score
4. ✅ Search and filter functionality
5. ✅ Client cards with status badges
6. ✅ ClientLogoDisplay component integration

**Data Source:**

- Single `useClients()` hook fetching only from `nps_clients` table
- No event tracking tables
- No compliance scoring tables
- No segment requirement tables

**Missing Features:** ❌ ALL event tracking and compliance monitoring capabilities

---

## Missing Functionality - Detailed Analysis

### 1. ❌ Event Tracking System

**Old Dashboard Code:**

```javascript
// client-segmentation-progress.js:88-142
async loadEvents() {
  const { data, error } = await this.supabase
    .from('segmentation_events')
    .select('*, segmentation_event_types(*)')
    .eq('event_year', this.currentYear)
    .order('event_date');

  if (error) {
    console.error('Error loading events:', error);
    return;
  }

  this.data.events = data || [];
}

async loadEventCompliance() {
  const { data, error } = await this.supabase
    .from('segmentation_event_compliance')
    .select('*, segmentation_event_types(*)')
    .eq('year', this.currentYear);

  if (error) {
    console.error('Error loading event compliance:', error);
    return;
  }

  this.data.eventCompliance = data || [];
}
```

**New Dashboard:** No equivalent functionality - no database tables, no queries, no UI

**Impact:** Cannot track individual engagement events (meetings, reviews, on-site visits, etc.) per client.

---

### 2. ❌ 12 Official Altera APAC Event Types

**Old Dashboard Data:**
From `segmentation_event_types.json`:

| Event Type                                    | Code         | Frequency   | Responsible Team  |
| --------------------------------------------- | ------------ | ----------- | ----------------- |
| President/Group Leader Engagement (in person) | PGL_ENGAGE   | Per Year    | P/GL              |
| EVP Engagement                                | EVP_ENGAGE   | Per Year    | EVP               |
| Strategic Ops Plan (Partnership) Meeting      | STRAT_OPS    | Per Year    | CE/VP/AVP +/- EVP |
| Satisfaction Action Plan                      | SAT_PLAN     | Per Year    | CE                |
| SLA/Service Review Meeting                    | SLA_REVIEW   | Per Year    | Support           |
| CE On-Site Attendance                         | CE_ONSITE    | Per Year    | CE                |
| Insight Touch Point                           | INSIGHT_TP   | Per Year    | CE                |
| Health Check (Opal)                           | HEALTH_CHECK | Per Year    | PS/R&D            |
| Upcoming Release Planning                     | RELEASE_PLAN | Per Year    | Solutions/PS/R&D  |
| Whitespace Demos (Sunrise)                    | WHITESPACE   | Per Year    | Solutions/PS      |
| APAC Client Forum / User Group                | CLIENT_FORUM | 1=Yes, 0=No | CE                |
| Updating Client 360                           | UPDATE_360   | Per Year    | CE                |

**New Dashboard:** No event types defined - not implemented

**Impact:** Cannot categorise or track specific types of client engagements defined in Altera APAC Best Practice Guide.

---

### 3. ❌ Compliance Scoring Algorithm

**Old Dashboard Code:**

```javascript
// client-segmentation-progress.js:840-875
calculateEventLevelCompliance(client) {
  // NEW FORMULA: compliance rate = (count of event types with ≥100% compliance) / (total event types expected)
  // This measures how many event type requirements are being met, not total event count

  const clientEventCompliance = this.data.eventCompliance.filter(
    ec => ec.client_name === client.client_name
  );

  // Count total event types (excluding those with 0 expected)
  const totalEventTypes = clientEventCompliance.filter(ec => ec.expected_count > 0).length;

  if (totalEventTypes === 0) return 0;

  // Count event types that are at 100% or above compliance
  const compliantEventTypes = clientEventCompliance.filter(
    ec => ec.expected_count > 0 && ec.compliance_percentage >= 100
  ).length;

  // Calculate percentage
  return (compliantEventTypes / totalEventTypes) * 100;
}
```

**Formula:** `(Event Types with ≥100% Compliance / Total Event Types) × 100`

**Example:**

- Client: Sleeping Giant segment
- Required event types: 6 (EVP Engagement, SLA Review, CE On-Site, etc.)
- Compliant event types: 4 (have met or exceeded expected count)
- Compliance Score: (4/6) × 100 = 67%

**New Dashboard:** No compliance calculation - not implemented

**Impact:** Cannot measure or report on client engagement compliance levels.

---

### 4. ❌ Segment-Specific Event Requirements

**Old Dashboard Code:**
From `client360-segment-system.js:218-299`:

```javascript
const apacActivities = {
  Maintain: [
    {
      action: 'Strategic Ops Plan (Partnership) Meeting',
      frequency: '1/year',
      owner: 'CE/VP/AVP +/- EVP',
      priority: 'HIGH',
    },
    { action: 'Satisfaction Action Plan', frequency: '1/year', owner: 'CE', priority: 'CRITICAL' },
    {
      action: 'SLA/Service Review Meeting',
      frequency: '2/year',
      owner: 'Support',
      priority: 'MEDIUM',
    },
    { action: 'CE On-Site Attendance', frequency: '1/year', owner: 'CE', priority: 'MEDIUM' },
    { action: 'Insight Touch Point', frequency: '12/year', owner: 'CE', priority: 'MEDIUM' },
    { action: 'Updating Client 360', frequency: '2/year', owner: 'CE', priority: 'MEDIUM' },
  ],

  'Sleeping Giant': [
    {
      action: 'President/Group Leader Engagement (in person)',
      frequency: '1/year',
      owner: 'P/GL',
      priority: 'CRITICAL',
    },
    { action: 'EVP Engagement', frequency: '4/year', owner: 'EVP', priority: 'CRITICAL' },
    {
      action: 'SLA/Service Review Meeting',
      frequency: '12/year',
      owner: 'Support',
      priority: 'HIGH',
    },
    { action: 'CE On-Site Attendance', frequency: '12/year', owner: 'CE', priority: 'HIGH' },
    {
      action: 'Whitespace Demos (Sunrise)',
      frequency: '4/year',
      owner: 'Solutions/PS',
      priority: 'HIGH',
    },
    { action: 'Updating Client 360', frequency: '12/year', owner: 'CE', priority: 'HIGH' },
  ],
  // ... other segments with different frequencies
}
```

**Key Insight:** Different segments have DIFFERENT event frequency requirements:

- **Maintain:** 6 event types, mostly 1-2/year (low touch)
- **Sleeping Giant:** 6 event types, mostly 4-12/year (high touch due to critical risk)

**New Dashboard:** No segment-specific requirements - all segments treated identically

**Impact:** Cannot differentiate engagement strategies based on segment classification as defined in Altera APAC Best Practice Guide (August 2024).

---

### 5. ❌ Expandable Event Detail Panels

**Old Dashboard Code:**

```javascript
// client-segmentation-progress.js:433-522
renderEventDetailsModern(client) {
  const clientEventCompliance = this.data.eventCompliance.filter(
    ec => ec.client_name === client.client_name
  );

  const sortedCompliance = clientEventCompliance
    .filter(ec => ec.expected_count > 0)
    .sort((a, b) => {
      const statusOrder = { 'critical': 0, 'at_risk': 1, 'compliant': 2 };
      return statusOrder[a.status] - statusOrder[b.status];
    });

  return `
    <table class="event-table">
      <thead>
        <tr>
          <th>Event Type</th>
          <th>Expected</th>
          <th>Actual</th>
          <th>Compliance</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>
        ${sortedCompliance.map(ec => this.renderEventRowModern(ec)).join('')}
      </tbody>
    </table>
  `;
}

renderEventRowModern(ec) {
  const statusClass = {
    'critical': 'status-critical',
    'at_risk': 'status-warning',
    'compliant': 'status-success'
  }[ec.status];

  return `
    <tr class="${statusClass}">
      <td>${ec.segmentation_event_types.event_name}</td>
      <td class="text-centre">${ec.expected_count}</td>
      <td class="text-centre">${ec.actual_count}</td>
      <td class="text-centre">${Math.round(ec.compliance_percentage)}%</td>
      <td class="text-centre">
        <span class="status-badge ${statusClass}">
          ${ec.status.toUpperCase()}
        </span>
      </td>
    </tr>
  `;
}
```

**UI Features:**

- Click client card to expand → Shows event breakdown table
- Sorts by status (critical first, then at-risk, then compliant)
- Displays: Event Type, Expected Count, Actual Count, Compliance %, Status Badge
- Color-coded status indicators

**New Dashboard:** No expandable panels - client cards are static

**Impact:** Cannot drill down into per-client event-level details to identify specific compliance gaps.

---

### 6. ❌ Event Calendar and Scheduling

**Old Dashboard Code:**

```javascript
// client-segmentation-progress.js:523-604
renderScheduleEventButton(client) {
  return `
    <button
      class="btn-primary btn-sm"
      onclick="scheduleEvent('${client.client_name}')"
    >
      <i class="fas fa-calendar-plus"></i>
      Schedule Event
    </button>
  `;
}

async scheduleEvent(clientName, eventTypeId, eventDate) {
  const { data, error } = await this.supabase
    .from('segmentation_events')
    .insert([{
      client_name: clientName,
      event_type_id: eventTypeId,
      event_date: eventDate,
      event_month: new Date(eventDate).getMonth() + 1,
      event_year: new Date(eventDate).getFullYear(),
      completed: false,
      created_at: new Date().toISOString()
    }]);

  if (error) {
    console.error('Error scheduling event:', error);
    return;
  }

  this.loadData(); // Refresh data
}
```

**Features:**

- Schedule future events
- Track completion status
- Link events to meetings
- Filter by year, month, event type

**New Dashboard:** No event scheduling functionality

**Impact:** Cannot plan or track future client engagement events.

---

### 7. ❌ CSE Workload Management

**Old Dashboard Code:**

```javascript
// client-segmentation-progress.js:605-650
calculateCSEWorkload() {
  const cseWorkload = {};

  this.data.clients.forEach(client => {
    const cseName = client.cse_name || 'Unassigned';

    if (!cseWorkload[cseName]) {
      cseWorkload[cseName] = {
        clientCount: 0,
        totalEvents: 0,
        completedEvents: 0,
        complianceScore: 0
      };
    }

    cseWorkload[cseName].clientCount++;
    cseWorkload[cseName].totalEvents += this.calculateExpectedEvents(client);
    cseWorkload[cseName].completedEvents += this.calculateCompletedEvents(client);
  });

  // Calculate average compliance per CSE
  Object.keys(cseWorkload).forEach(cseName => {
    const clients = this.data.clients.filter(c => c.cse_name === cseName);
    const totalCompliance = clients.reduce((sum, c) =>
      sum + this.calculateEventLevelCompliance(c), 0
    );
    cseWorkload[cseName].complianceScore = Math.round(
      totalCompliance / clients.length
    );
  });

  return cseWorkload;
}

renderCSEView() {
  const workload = this.calculateCSEWorkload();

  return Object.entries(workload).map(([cseName, data]) => `
    <div class="cse-card">
      <h3>${cseName}</h3>
      <div class="cse-stats">
        <div class="stat">${data.clientCount} clients</div>
        <div class="stat">${data.totalEvents} events planned</div>
        <div class="stat">${data.completedEvents} completed</div>
        <div class="stat">${data.complianceScore}% avg compliance</div>
      </div>
    </div>
  `).join('');
}
```

**Features:**

- CSE-level aggregation of workload
- Total clients per CSE
- Total events planned per CSE
- Average compliance score per CSE
- Toggle between Client-View and CSE-View

**New Dashboard:** No CSE workload tracking

**Impact:** Cannot assess CSE performance or workload distribution across team.

---

### 8. ❌ Historical Segment Tracking

**Old Dashboard Database:**
From `client_segmentation.json`:

```json
{
  "id": "09c57a0f-0b93-434c-9348-7d588e58cc68",
  "client_name": "Barwon Health",
  "tier_id": "5dcead33-cda2-4551-980a-ea8c50369eef",
  "cse_name": "Jonathan Salisbury",
  "effective_from": "2025-01-01",
  "effective_to": null,
  "notes": null,
  "created_at": "2025-11-13T15:53:24.702014+00:00",
  "updated_at": "2025-11-13T15:53:24.702014+00:00"
}
```

**Key Fields:**

- `effective_from`: When client entered this segment
- `effective_to`: When client exited this segment (null = current)
- `tier_id`: Foreign key to segment definition

**Use Case:** Track when clients move between segments (e.g., Leverage → Giant after revenue increase)

**New Dashboard:** No historical tracking - only current segment stored in `nps_clients.segment` column

**Impact:** Cannot track segment progression over time or audit segment changes.

---

### 9. ❌ Real-Time Event Completion Tracking

**Old Dashboard Code:**

```javascript
// client-segmentation-progress.js:651-695
async markEventComplete(eventId, completedBy) {
  const { data, error } = await this.supabase
    .from('segmentation_events')
    .update({
      completed: true,
      completed_date: new Date().toISOString(),
      completed_by: completedBy
    })
    .eq('id', eventId);

  if (error) {
    console.error('Error marking event complete:', error);
    return;
  }

  // Recalculate compliance
  await this.recalculateCompliance(eventId);

  // Refresh data
  this.loadData();
}

async recalculateCompliance(eventId) {
  // Fetch event details
  const { data: event } = await this.supabase
    .from('segmentation_events')
    .select('*, segmentation_event_types(*)')
    .eq('id', eventId)
    .single();

  // Update compliance calculation in segmentation_event_compliance table
  // ... compliance calculation logic
}
```

**Features:**

- Mark events as complete with timestamp
- Track who completed the event
- Auto-recalculate compliance scores
- Real-time UI updates

**New Dashboard:** No event completion tracking

**Impact:** Cannot track event execution in real-time.

---

### 10. ❌ Segment Strategy Documentation

**Old Dashboard Code:**
From `client360-segment-system.js:16-163`:

```javascript
segments: {
  'Leverage': {
    colour: '#667eea',
    description: 'Low spend / High satisfaction - high potential growth accounts',
    criteria: 'CSI: High | Spend: Low',
    strategy: 'Leverage Relationships to Increase Revenue',
    goals: {
      revenue: 'Increase revenue by 15%',
      retention: 'Maintain satisfaction',
      reference: 'Position as reference clients'
    },
    focusAreas: [
      'Increase new name sales within account',
      'Deploy additional services and products',
      'Expand relationship with non-buying departments',
      'Identify upsell and cross-sell opportunities'
    ],
    cadence: 'Bi-weekly relationship building'
  },

  'Sleeping Giant': {
    colour: '#ff9800',
    description: 'Very high spend / Low satisfaction - critical at-risk accounts',
    criteria: 'CSI: Low | Spend: Very High',
    strategy: 'Reactivate & Restore Strategic Partnership',
    goals: {
      revenue: 'Restore revenue',
      retention: 'Prevent account loss - critical risk',
      reference: 'Prevent negative reference'
    },
    focusAreas: [
      'Engagement audit - understand dormancy',
      'Executive reactivation engagement',
      'Value realization demonstration',
      'Strategic partnership restoration'
    ],
    cadence: 'Urgent reactivation program'
  }
  // ... other segments
}
```

**Features:**

- Official Altera APAC segment definitions
- Strategic goals per segment
- Focus areas and tactics
- Engagement cadence recommendations
- Color-coded visual system

**New Dashboard:** Minimal segment descriptions in `SEGMENT_CONFIG` (lines 24-67 of segmentation/page.tsx)

**Impact:** Missing official Altera APAC Best Practice Guide strategic context and actionable guidance.

---

### 11. ❌ Database Table Architecture

**Old Dashboard Tables (7 tables):**

1. **`client_segmentation`**
   - Purpose: Client-tier assignments with historical tracking
   - Key fields: client_name, tier_id, cse_name, effective_from, effective_to
   - Status: ❌ Does not exist in new dashboard

2. **`segmentation_events`**
   - Purpose: Individual event records with completion tracking
   - Key fields: client_name, event_type_id, event_date, completed, completed_date
   - Status: ❌ Does not exist in new dashboard

3. **`segmentation_event_types`**
   - Purpose: 12 official Altera APAC event type definitions
   - Key fields: event_name, event_code, frequency_type, responsible_team
   - Status: ❌ Does not exist in new dashboard

4. **`tier_event_requirements`**
   - Purpose: Expected event counts per tier/segment
   - Key fields: tier_id, event_type_id, expected_count_per_year
   - Status: ❌ Does not exist in new dashboard

5. **`segmentation_compliance_scores`**
   - Purpose: Yearly compliance score aggregates per client
   - Key fields: client_name, year, overall_compliance_score
   - Status: ❌ Does not exist in new dashboard

6. **`segmentation_event_compliance`**
   - Purpose: Event-level compliance calculations
   - Key fields: client_name, event_type_id, expected_count, actual_count, compliance_percentage, status
   - Status: ❌ Does not exist in new dashboard

7. **`segmentation_tiers`**
   - Purpose: Tier/segment definitions with criteria
   - Key fields: tier_name, tier_description, csi_threshold, spend_threshold
   - Status: ❌ Does not exist in new dashboard

**New Dashboard Data Source:**

- Single table: `nps_clients` with `segment` column (string)
- No relational structure
- No historical tracking
- No event or compliance data

**Impact:** Cannot implement event tracking or compliance monitoring without database schema migration.

---

## Root Cause Analysis

### Why the Gap Exists

1. **Different Implementation Priorities:**
   - Old dashboard: Built as Client Engagement Compliance Management System
   - New dashboard: Built as modern Client Health Monitoring System
   - Event tracking was not included in initial Next.js migration scope

2. **Database Schema Not Migrated:**
   - Old dashboard used 7 specialized tables
   - New dashboard only uses `nps_clients` table
   - Event tracking tables were not created in Supabase

3. **Different Technology Stacks:**
   - Old dashboard: Class-based JavaScript with direct DOM manipulation
   - New dashboard: React with TypeScript and modern component patterns
   - Code was rewritten from scratch, not ported

4. **Scope Creep Prevention:**
   - New dashboard focused on core health metrics first
   - Event tracking planned as future enhancement
   - Feature parity not established as requirement

---

## Impact Assessment

### Business Impact: CRITICAL

**Without Event Tracking and Compliance Monitoring:**

1. **Cannot Enforce Altera APAC Best Practice Guide**
   - No way to ensure segment-specific engagement requirements are met
   - Example: Sleeping Giant clients require 12 CE On-Site visits/year - no way to track

2. **No CSE Accountability**
   - Cannot measure if CSEs are meeting engagement commitments
   - No workload visibility for resource allocation

3. **No Compliance Reporting**
   - Cannot report to leadership on engagement compliance levels
   - No early warning system for at-risk client relationships

4. **No Event Planning Capability**
   - Cannot schedule required future engagements
   - No calendar integration for strategic planning

5. **No Historical Analysis**
   - Cannot track segment progression over time
   - Cannot analyse what engagement strategies lead to segment improvements

### Technical Impact: HIGH

**Development Effort Required:**

1. **Database Migration:**
   - Create 6 new Supabase tables
   - Define foreign key relationships
   - Migrate historical data (if available)
   - Estimated effort: 2-3 days

2. **API Development:**
   - Create hooks for event tracking (useEvents, useEventTypes, etc.)
   - Implement compliance calculation logic
   - Add real-time subscriptions
   - Estimated effort: 3-4 days

3. **UI Development:**
   - Build expandable client detail panels
   - Create event scheduling modal
   - Implement CSE view toggle
   - Add compliance progress indicators
   - Estimated effort: 4-5 days

4. **Testing:**
   - Unit tests for compliance calculations
   - Integration tests for event tracking
   - E2E tests for full workflow
   - Estimated effort: 2-3 days

**Total Estimated Effort:** 11-15 days (2-3 weeks)

---

## Recommended Solution

### Phased Implementation Plan

#### Phase 1: Database Foundation (2-3 days)

**Tasks:**

1. Create Supabase migration script for 6 new tables
2. Define table schemas with proper relationships
3. Seed `segmentation_event_types` with 12 official event types
4. Create initial `tier_event_requirements` based on Altera APAC Best Practice Guide

**Deliverables:**

- Migration SQL file: `supabase/migrations/add_event_tracking_schema.sql`
- Seed data: `supabase/seed/event_types.sql`

**Example Schema:**

```sql
-- segmentation_event_types table
CREATE TABLE segmentation_event_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_name TEXT NOT NULL,
  event_code TEXT NOT NULL UNIQUE,
  frequency_type TEXT NOT NULL,
  responsible_team TEXT,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- segmentation_events table
CREATE TABLE segmentation_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_name TEXT NOT NULL,
  event_type_id UUID REFERENCES segmentation_event_types(id),
  event_date DATE NOT NULL,
  event_month INTEGER NOT NULL,
  event_year INTEGER NOT NULL,
  completed BOOLEAN DEFAULT false,
  completed_date TIMESTAMP WITH TIME ZONE,
  completed_by TEXT,
  notes TEXT,
  meeting_link TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_events_client ON segmentation_events(client_name);
CREATE INDEX idx_events_type ON segmentation_events(event_type_id);
CREATE INDEX idx_events_year ON segmentation_events(event_year);
```

#### Phase 2: API Layer (3-4 days)

**Tasks:**

1. Create `useEvents` hook for event CRUD operations
2. Create `useEventTypes` hook for event type definitions
3. Create `useEventCompliance` hook for compliance calculations
4. Implement compliance scoring algorithm (port from old dashboard)

**Deliverables:**

- `src/hooks/useEvents.ts`
- `src/hooks/useEventTypes.ts`
- `src/hooks/useEventCompliance.ts`
- `src/lib/compliance-calculator.ts`

**Example Hook:**

```typescript
// src/hooks/useEvents.ts
export function useEvents(clientName?: string, year?: number) {
  const [events, setEvents] = useState<Event[]>([])
  const [loading, setLoading] = useState(true)

  const fetchEvents = useCallback(async () => {
    let query = supabase
      .from('segmentation_events')
      .select('*, segmentation_event_types(*)')
      .order('event_date', { ascending: false })

    if (clientName) query = query.eq('client_name', clientName)
    if (year) query = query.eq('event_year', year)

    const { data, error } = await query

    if (error) throw error
    setEvents(data || [])
  }, [clientName, year])

  useEffect(() => {
    fetchEvents()
  }, [fetchEvents])

  const createEvent = async (event: NewEvent) => {
    const { data, error } = await supabase.from('segmentation_events').insert([event])

    if (error) throw error
    fetchEvents()
  }

  return { events, loading, createEvent, refetch: fetchEvents }
}
```

#### Phase 3: UI Components (4-5 days)

**Tasks:**

1. Update segmentation page with expandable client cards
2. Create `EventDetailsPanel` component
3. Create `ScheduleEventModal` component
4. Create `ComplianceProgressBar` component
5. Add CSE view toggle

**Deliverables:**

- Updated `src/app/(dashboard)/segmentation/page.tsx`
- `src/components/segmentation/EventDetailsPanel.tsx`
- `src/components/segmentation/ScheduleEventModal.tsx`
- `src/components/segmentation/ComplianceProgressBar.tsx`

**Example Component:**

```typescript
// src/components/segmentation/EventDetailsPanel.tsx
export function EventDetailsPanel({ client }: { client: Client }) {
  const { eventCompliance, loading } = useEventCompliance(client.name)

  if (loading) return <div>Loading event details...</div>

  // Sort by status (critical first, then at-risk, then compliant)
  const sorted = eventCompliance
    .filter(ec => ec.expected_count > 0)
    .sort((a, b) => {
      const order = { critical: 0, at_risk: 1, compliant: 2 }
      return order[a.status] - order[b.status]
    })

  return (
    <div className="event-details-panel">
      <table className="w-full">
        <thead>
          <tr>
            <th>Event Type</th>
            <th>Expected</th>
            <th>Actual</th>
            <th>Compliance</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          {sorted.map(ec => (
            <tr key={ec.id} className={getStatusClass(ec.status)}>
              <td>{ec.event_type.event_name}</td>
              <td className="text-centre">{ec.expected_count}</td>
              <td className="text-centre">{ec.actual_count}</td>
              <td className="text-centre">{Math.round(ec.compliance_percentage)}%</td>
              <td className="text-centre">
                <span className={`badge ${getStatusClass(ec.status)}`}>
                  {ec.status.toUpperCase()}
                </span>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
```

#### Phase 4: Testing & Refinement (2-3 days)

**Tasks:**

1. Write unit tests for compliance calculations
2. Write integration tests for event CRUD operations
3. Manual testing of full workflow
4. Performance optimisation
5. Documentation updates

**Deliverables:**

- Test files in `__tests__/segmentation/`
- Updated documentation in `docs/`
- Performance benchmarks

---

## Testing Verification

**Once Implemented, User Should Verify:**

1. **Database Schema:**
   - [ ] All 6 tables exist in Supabase
   - [ ] Foreign key relationships defined
   - [ ] 12 event types seeded correctly
   - [ ] Segment requirements seeded for all 6 segments

2. **Event Tracking:**
   - [ ] Can schedule new events from UI
   - [ ] Events appear in client detail panels
   - [ ] Can mark events as complete
   - [ ] Completion updates compliance scores

3. **Compliance Scoring:**
   - [ ] Overall compliance % displays per client
   - [ ] Event-level compliance shows expected vs actual
   - [ ] Status indicators (critical/at-risk/compliant) colour-coded
   - [ ] Formula matches: (compliant event types / total event types) × 100

4. **Segment Requirements:**
   - [ ] Different segments show different event type requirements
   - [ ] Sleeping Giant shows 12/year for high-touch events
   - [ ] Maintain shows 1-2/year for most events
   - [ ] All 12 event types visible in detail panels

5. **CSE Workload:**
   - [ ] CSE view shows aggregated workload per CSE
   - [ ] Total events planned per CSE displayed
   - [ ] Average compliance score per CSE calculated
   - [ ] Can toggle between Client-View and CSE-View

6. **Historical Tracking:**
   - [ ] Segment changes tracked with effective_from/effective_to dates
   - [ ] Can view segment progression over time
   - [ ] Historical compliance scores retained

---

## Lessons Learned

### What Went Wrong

1. **Incomplete Requirements Gathering:**
   - Event tracking system not identified as core requirement during Next.js migration
   - Old dashboard analysis not thorough enough before starting new implementation

2. **No Feature Parity Checklist:**
   - Should have created comprehensive feature comparison before building
   - Missing features discovered only after deployment

3. **Database Schema Planning:**
   - Should have analysed old dashboard database schema before designing new one
   - Only migrated `nps_clients` table without understanding full relational model

### Prevention Strategy

**Short-term:**

- ✅ Create this bug report documenting all missing features
- ✅ Prioritize Phase 1 (Database Foundation) as next sprint
- ✅ Get user approval on phased implementation plan

**Medium-term:**

- Create feature parity checklist for all future migrations
- Establish "old dashboard" as source of truth for requirements
- Require database schema analysis before starting UI work

**Long-term:**

- Document all Altera APAC Best Practice Guide requirements in Confluence
- Create automated tests comparing old vs new feature sets
- Establish rollback plan if critical features missing after migration

---

## Related Documentation

- **Altera APAC Client Segmentation Best Practice Guide (August 2024)** - Defines official segment strategies and event requirements
- **Old Dashboard Source:** `/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Clients - Client Success/CS Connect Meetings/Sandbox/cs-connect-dashboard_sandbox`
- **Database Backup:** `/cs-connect-dashboard_sandbox/database/backups/backup-2025-11-19T05-56-49/`

---

## Status

**Current State:** Missing functionality identified and documented
**Next Action:** User approval of phased implementation plan
**Estimated Timeline:** 2-3 weeks for full implementation
**Priority:** CRITICAL - Core business functionality missing

---

**Report Generated:** 2025-11-27
**Generated By:** Claude Code
**Reviewed By:** [Pending User Review]
