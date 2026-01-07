# Feature: Support SLA Metrics Integration

**Date:** 8 January 2026
**Status:** Implemented
**Components:** Database, API, UI, Alerts, Health Score, Churn Prediction

---

## Overview

Integrated Support SLA metrics from Excel reports into the dashboard, providing:
- Real-time support health visibility per client
- Integration with health scoring system
- Churn prediction enhancement
- Automated alerting for support issues

---

## Files Created/Modified

### New Files

| File | Purpose |
|------|---------|
| `docs/migrations/20260108_support_sla_metrics.sql` | Database schema for SLA metrics |
| `scripts/sync-sla-reports.mjs` | Excel parser and Supabase sync script |
| `scripts/apply-sla-metrics-migration.mjs` | Migration runner |
| `src/app/api/support-metrics/route.ts` | GET all clients' support metrics |
| `src/app/api/clients/[clientId]/support-metrics/route.ts` | Client-specific support metrics |
| `src/components/support/SupportHealthCard.tsx` | Client profile support widget |
| `src/components/support/SupportOverviewTable.tsx` | Executive dashboard table |
| `src/components/support/index.ts` | Component exports |

### Modified Files

| File | Changes |
|------|---------|
| `src/lib/churn-prediction.ts` | Added SupportMetricsData interface, enhanced support risk calculation |
| `src/lib/health-score-config.ts` | Extended SupportHealthData, enhanced calculateSupportHealthScore() |
| `src/lib/alert-system.ts` | Added 5 new support alert categories, detectSupportAlerts() function |

---

## Database Schema

### Table: `support_sla_metrics`

```sql
CREATE TABLE support_sla_metrics (
  id UUID PRIMARY KEY,
  client_name TEXT NOT NULL,
  client_uuid UUID,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  period_type TEXT DEFAULT 'monthly',

  -- Case Volume
  total_incoming INTEGER DEFAULT 0,
  total_closed INTEGER DEFAULT 0,
  backlog INTEGER DEFAULT 0,

  -- Priority Breakdown
  critical_open INTEGER DEFAULT 0,
  high_open INTEGER DEFAULT 0,
  moderate_open INTEGER DEFAULT 0,
  low_open INTEGER DEFAULT 0,

  -- Aging Distribution
  aging_0_7d INTEGER DEFAULT 0,
  aging_8_30d INTEGER DEFAULT 0,
  aging_31_60d INTEGER DEFAULT 0,
  aging_61_90d INTEGER DEFAULT 0,
  aging_90d_plus INTEGER DEFAULT 0,

  -- SLA Compliance
  response_sla_percent DECIMAL(5,2),
  resolution_sla_percent DECIMAL(5,2),
  breach_count INTEGER DEFAULT 0,

  -- Satisfaction
  satisfaction_score DECIMAL(3,2),

  -- Metadata
  source_file TEXT,
  imported_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_name, period_start, period_end)
);
```

### Table: `support_case_details`

Individual case records linked to metrics periods for drill-down.

---

## API Endpoints

### GET /api/support-metrics

Returns all clients' latest support metrics with summary.

**Response:**
```json
{
  "success": true,
  "metrics": [
    {
      "id": "uuid",
      "client_name": "SA Health",
      "total_open": 15,
      "critical_open": 2,
      "resolution_sla_percent": 94.5,
      "satisfaction_score": 4.2,
      "support_health_score": 78
    }
  ],
  "summary": {
    "totalClients": 6,
    "totalOpenCases": 45,
    "totalCritical": 5,
    "avgSLACompliance": 91.2,
    "clientsAtRisk": 2
  }
}
```

### GET /api/clients/[clientId]/support-metrics

Returns detailed support metrics for a specific client with history, trends, and sparklines.

---

## Support Health Score Calculation

**Formula (0-100 scale):**
```
SLA Score (40%): Max 100, from resolution_sla_percent
Satisfaction Score (30%): (satisfaction_score / 5) * 100
Aging Score (20%): 100 - (aging_30d_plus * 10)
Critical Score (10%): 100 - (critical_open * 25)

Total = (SLA × 0.4) + (Sat × 0.3) + (Aging × 0.2) + (Critical × 0.1)
```

**Thresholds:**
- >= 80: Healthy (green)
- 60-79: At Risk (amber)
- < 60: Critical (red)

---

## Alert Categories

| Category | Severity | Trigger |
|----------|----------|---------|
| `support_health_decline` | Critical/High | Health score < 60/75 |
| `support_critical_case` | Critical | Any critical cases open |
| `support_sla_breach` | Critical/High | SLA < 80%/90% |
| `support_satisfaction_low` | Critical/High | CSAT < 3.0/3.5 |
| `support_aging_cases` | High/Medium | Aging 30d+ >= 10/5 |

---

## Churn Prediction Integration

The churn prediction now uses enhanced support metrics when available:

1. **SupportMetricsData** interface added to feature extraction
2. **calculateSupportTicketRisk()** uses:
   - Pre-calculated supportHealthScore if available
   - Otherwise calculates from individual metrics
   - Falls back to simple ticket count if no SLA data

3. **Risk Factors** include detailed support issues:
   - Critical case count
   - SLA compliance percentage
   - Aging case count
   - Satisfaction score

4. **Recommended Actions** for support issues:
   - Escalate to support leadership
   - Review open cases with client
   - Schedule support review meeting

---

## Health Score v6.0 Integration

The enhanced health score system (v6.0) includes support health as a component:

**Operational Category (20 points):**
- Actions Completion: 10 points
- **Support Health: 10 points** (new)

**Support Health Scoring (10 points max):**
- Uses pre-calculated supportHealthScore scaled to 0-10
- OR calculates from SLA, satisfaction, critical, aging metrics
- Falls back to basic ticket volume if no SLA data

---

## Excel Parser

The `sync-sla-reports.mjs` script parses:

1. **Resolution Details** sheet: Case priorities, aging distribution
2. **Case Volume** sheet: Incoming, closed, backlog
3. **SLA Compliance** sheet: Response/resolution percentages
4. **Case Survey** sheet: Satisfaction scores

**Usage:**
```bash
node scripts/sync-sla-reports.mjs
```

**Environment:**
- `NEXT_PUBLIC_SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SLA_REPORTS_PATH` (optional, defaults to OneDrive path)

---

## UI Components

### SupportHealthCard

Client profile widget showing:
- Support health score with traffic light colour
- Open cases with critical count
- SLA compliance percentage
- Customer satisfaction rating
- Period label
- Trend indicators (up/down/stable)

**Props:**
```typescript
interface SupportHealthCardProps {
  clientId: string
  clientName?: string
  compact?: boolean  // Compact mode for smaller spaces
}
```

### SupportOverviewTable

Executive dashboard table showing:
- All clients sorted by health score (lowest first)
- Sortable columns
- "At-risk only" filter
- Summary row with totals
- Links to client detail pages

---

## Usage Example

### Add to Client Profile

```tsx
import { SupportHealthCard } from '@/components/support'

<SupportHealthCard
  clientId={client.id}
  clientName={client.name}
/>
```

### Add to Executive Dashboard

```tsx
import { SupportOverviewTable } from '@/components/support'

<SupportOverviewTable />
```

### Detect Support Alerts

```typescript
import { detectAllAlerts } from '@/lib/alert-system'

const alerts = detectAllAlerts({
  supportData: [
    {
      client: 'SA Health',
      cse: 'John Smith',
      supportHealthScore: 55,
      resolutionSlaPercent: 78,
      criticalOpen: 3,
      aging30dPlus: 12,
    }
  ]
})
```

---

## Next Steps

1. **Apply database migration** using Supabase SQL Editor or migration script
2. **Run initial sync** with `node scripts/sync-sla-reports.mjs`
3. **Add SupportHealthCard** to client profile pages
4. **Add SupportOverviewTable** to executive dashboard
5. **Configure alert thresholds** as needed in DEFAULT_ALERT_CONFIG

---

## Testing

Verify the implementation:
1. Check API: `GET /api/support-metrics`
2. Check client API: `GET /api/clients/SA%20Health/support-metrics`
3. View component in browser
4. Test alert detection with sample data
