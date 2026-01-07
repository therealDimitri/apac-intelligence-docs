# SLA Report Integration Analysis & Recommendations

**Date:** 2026-01-08
**Status:** Analysis Complete
**Priority:** High
**Impact:** Client Health Scoring, Churn Prediction, Executive Dashboards

---

## 1. Data Source Analysis

### Available SLA Reports

| Client | File | Period | File Size |
|--------|------|--------|-----------|
| WA Health | WAH Support Dashboard_Nov 2025.xlsx | Monthly | 240KB |
| SA Health | SAH Support Dashboard - Oct 2025.xlsx | Monthly | 824KB |
| Grampians | Grampians Heath Support Dashboard - Q4-2025.xlsx | Quarterly | 143KB |
| RVEEH | RVEEH Support Dashboard - Q4-2025.xlsx | Quarterly | 128KB |
| Barwon Health | Barwon Support Dashboard -Q4 2025.xlsx | Quarterly | 204KB |
| Albury Wodonga | Albury wodonga Heath Support Dashboard - Q4-2025.xlsx | Quarterly | 116KB |

---

## 2. Key Data Points Identified

### 2.1 Support Case Metrics (High Value)

**Sheet: Resolution Details**
```
CaseNumber | Opened | Resolved | Initial Priority | Current Priority | Short description | Has Breached?
```

**Value for Dashboard:**
- Open case count by priority
- Average resolution time
- SLA breach rate
- Case aging distribution

### 2.2 Case Volume Trends (High Value)

**Sheet: Case Volume**
```
Month | Total Incoming | Total Closed | Backlog
```

**Value for Dashboard:**
- Monthly ticket trend (up/down)
- Backlog trajectory
- Capacity planning insights

### 2.3 Open Aging Cases (High Value)

**Sheet: Open Aging Cases / Open Aging Rough**
```
Number | Month/Year | Opened | Priority | Short description | State | Assigned to
```

**Value for Dashboard:**
- Cases > 30 days old
- Cases > 90 days old
- Stale case alerts

### 2.4 System Availability (Medium Value)

**Sheet: Availability**
```
Month | % Availability | Outage Duration | Service Deduction
```

**Value for Dashboard:**
- Monthly uptime percentage
- Outage frequency/duration
- SLA deduction tracking

### 2.5 Customer Satisfaction (High Value)

**Sheet: Case Survey**
```
Month | Surveys Sent | Surveys Completed | Average Score | % Complete
```

**Value for Dashboard:**
- Support satisfaction score (like NPS)
- Response rate
- Score trends

### 2.6 SLA Compliance (High Value)

**Sheet: SLA Compliance / Response and Comm Compliance**
```
Monthly Response Time Compliance | First Response | Resolution within SLA
```

**Value for Dashboard:**
- SLA achievement percentage
- Trend over time
- Red/amber/green health indicator

---

## 3. Recommended Dashboard Integration

### 3.1 Client Profile Page Enhancement

Add a **Support Health** section to the client profile showing:

```
┌─────────────────────────────────────────────────────────────┐
│  SUPPORT HEALTH                                    [Oct '25] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  🎫 Open Cases: 12          📊 Case Volume Trend: ↑15%      │
│  ⚠️  Critical: 2            📈 Resolution Rate: 94%        │
│  🕐 Aging >30d: 3           ✅ SLA Compliance: 98%         │
│                                                             │
│  ────────────────────────────────────────────────────────── │
│                                                             │
│  📊 Monthly Case Volume           📉 SLA Compliance Trend   │
│  [Sparkline chart]                [Sparkline chart]         │
│                                                             │
│  Customer Satisfaction: 4.5/5.0 ⭐                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Churn Prediction Enhancement

Wire support metrics into `calculateSupportTicketRisk()`:

```typescript
// Current: ticketCount = 0 (placeholder)
// Enhanced:
const supportRiskFactors = {
  openCriticalCases: 2,      // 2 critical cases open
  agingCases30d: 3,          // 3 cases older than 30 days
  slaBreachRate: 0.05,       // 5% SLA breach rate
  satisfactionScore: 4.5,    // Survey average
};

// Risk calculation
const ticketRisk = calculateSupportRisk(supportRiskFactors);
```

**Risk Score Mapping:**
| Factor | Low Risk | Medium Risk | High Risk |
|--------|----------|-------------|-----------|
| Open Critical | 0 | 1-2 | 3+ |
| Aging Cases | 0-2 | 3-5 | 6+ |
| SLA Breach % | <5% | 5-15% | >15% |
| Satisfaction | >4.5 | 3.5-4.5 | <3.5 |

### 3.3 Executive Dashboard Widget

Add a **Support Overview** widget showing all clients:

```
┌──────────────────────────────────────────────────────────────┐
│  SUPPORT OVERVIEW                                 [Q4 2025]  │
├──────────────────────────────────────────────────────────────┤
│  Client           │ Open │ Aging │ SLA % │ Satisfaction     │
│  ─────────────────│──────│───────│───────│──────────────────│
│  🔴 SA Health     │  42  │   8   │  91%  │ ⭐ 3.8           │
│  🟡 WA Health     │  28  │   3   │  98%  │ ⭐ 4.5           │
│  🟢 Grampians     │  12  │   1   │  99%  │ ⭐ 4.8           │
│  🟢 RVEEH         │   8  │   0   │ 100%  │ ⭐ 4.7           │
│  🟢 Barwon        │  15  │   2   │  97%  │ ⭐ 4.4           │
│  🟢 Albury        │   6  │   0   │ 100%  │ ⭐ 4.9           │
└──────────────────────────────────────────────────────────────┘
```

---

## 4. Technical Implementation Plan

### Phase 1: Database Schema (Week 1)

Create `support_sla_metrics` table:

```sql
CREATE TABLE support_sla_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  client_id UUID REFERENCES client_segmentation(client_uuid),
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  period_type TEXT DEFAULT 'monthly', -- 'monthly' or 'quarterly'

  -- Case Volume
  total_incoming INTEGER DEFAULT 0,
  total_closed INTEGER DEFAULT 0,
  backlog INTEGER DEFAULT 0,

  -- Priority Breakdown
  critical_open INTEGER DEFAULT 0,
  high_open INTEGER DEFAULT 0,
  moderate_open INTEGER DEFAULT 0,
  low_open INTEGER DEFAULT 0,

  -- Aging
  aging_30d INTEGER DEFAULT 0,
  aging_60d INTEGER DEFAULT 0,
  aging_90d INTEGER DEFAULT 0,
  aging_90d_plus INTEGER DEFAULT 0,

  -- SLA Compliance
  response_sla_percent DECIMAL(5,2),
  resolution_sla_percent DECIMAL(5,2),
  breach_count INTEGER DEFAULT 0,

  -- Availability
  availability_percent DECIMAL(5,2),
  outage_minutes INTEGER DEFAULT 0,

  -- Satisfaction
  surveys_sent INTEGER DEFAULT 0,
  surveys_completed INTEGER DEFAULT 0,
  satisfaction_score DECIMAL(3,2),

  -- Metadata
  source_file TEXT,
  imported_at TIMESTAMPTZ DEFAULT NOW(),
  imported_by TEXT,

  UNIQUE(client_name, period_start, period_end)
);
```

### Phase 2: File Watcher & Parser (Week 2)

Create `scripts/sync-sla-reports.mjs`:

```typescript
// Watch SLA report directories for new files
// Parse Excel files using xlsx
// Upsert to support_sla_metrics table
// Trigger health score recalculation
```

### Phase 3: API Endpoints (Week 2)

```
GET /api/clients/[clientId]/support-metrics
  → Returns latest SLA metrics for client

GET /api/analytics/support-overview
  → Returns summary for all clients (executive view)

POST /api/admin/import-sla-report
  → Manual upload/import of SLA report
```

### Phase 4: UI Components (Week 3)

1. `SupportHealthCard.tsx` - Client profile widget
2. `SupportOverviewTable.tsx` - Executive dashboard widget
3. `SLATrendChart.tsx` - Historical trend visualisation

### Phase 5: Churn Prediction Integration (Week 3)

Update `extractFeaturesForClient()` to query `support_sla_metrics` instead of the current actions-based proxy.

---

## 5. Data Sync Strategy

### Option A: Manual Upload (MVP)
- Admin uploads SLA reports via UI
- Parser extracts and stores metrics
- **Pros:** Simple, controlled
- **Cons:** Manual effort, potential delays

### Option B: File Watcher (Recommended)
- Watch OneDrive sync folders for new files
- Auto-parse on file change
- **Pros:** Automated, near real-time
- **Cons:** Requires file system access

### Option C: API Integration (Future)
- Direct ServiceNow/Jira API integration
- **Pros:** Real-time, no file dependency
- **Cons:** Requires API access, authentication

**Recommendation:** Start with Option A (manual upload) for MVP, implement Option B for automation.

---

## 6. Health Score Integration

Update the health score formula to include support metrics:

```
Current Formula:
Health Score = NPS (25%) + Compliance (30%) + Engagement (25%) + Financial (20%)

Proposed Formula:
Health Score = NPS (20%) + Compliance (25%) + Engagement (20%) + Financial (15%) + Support (20%)

Support Component:
- SLA Compliance (40% of Support)
- Case Aging Health (30% of Support)
- Satisfaction Score (30% of Support)
```

---

## 7. Alert Integration

New alert types for support metrics:

| Alert | Trigger | Severity |
|-------|---------|----------|
| `support_sla_declining` | SLA drops >5% from prior period | high |
| `support_critical_open` | >3 critical cases open | critical |
| `support_aging_backlog` | >5 cases aging >90 days | high |
| `support_satisfaction_drop` | Score drops <4.0 | high |
| `support_volume_spike` | Incoming +50% MoM | medium |

---

## 8. Priority & Effort Estimate

| Phase | Effort | Priority | Dependency |
|-------|--------|----------|------------|
| DB Schema | 2 hours | P1 | None |
| Parser/Sync | 4 hours | P1 | Schema |
| API Endpoints | 3 hours | P1 | Schema |
| Client UI Widget | 3 hours | P2 | APIs |
| Executive Widget | 2 hours | P2 | APIs |
| Churn Integration | 2 hours | P2 | Schema |
| Health Score Update | 1 hour | P3 | APIs |
| Alerts | 2 hours | P3 | APIs |

**Total Estimated Effort:** ~19 hours (~2.5 days)

---

## 9. Next Steps

1. **Approve approach** - Review with stakeholders
2. **Create migration** - `20260108_support_sla_metrics.sql`
3. **Build parser** - `scripts/sync-sla-reports.mjs`
4. **Test with one client** - WA Health (smallest file)
5. **Roll out to all clients** - Import remaining SLA reports
6. **Add to client profiles** - SupportHealthCard component
7. **Wire to churn prediction** - Replace actions proxy
