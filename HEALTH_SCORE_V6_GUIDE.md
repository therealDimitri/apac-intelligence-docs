# Enhanced Health Score System v6.0

**Date**: 2026-01-05
**Version**: 6.0
**Status**: Active

## Overview

The Enhanced Health Score System v6.0 introduces a comprehensive 6-component model that provides deeper insights into client health across four strategic categories. This system maintains backward compatibility with v4.0 while offering a more nuanced view of client relationships.

## System Architecture

### Component Breakdown

```
Total: 100 points across 6 components in 4 categories

ENGAGEMENT (30 points)
├── NPS Score (15 points) - Customer satisfaction
└── Compliance Rate (15 points) - Meeting engagement requirements

FINANCIAL HEALTH (40 points)
├── AR Aging (10 points) - Receivables under 60/90 days
├── Revenue Trend (15 points) - YoY growth
└── Contract Status (15 points) - Renewal risk and ARR stability

OPERATIONAL (20 points)
├── Actions Completion (10 points) - Task completion rate
└── Support Health (10 points) - Response times and ticket volume

STRATEGIC (10 points)
└── Expansion Potential (10 points) - Upsell/cross-sell opportunities
```

## Scoring Logic

### 1. NPS Score (15 points)

**Formula**: `((nps_score + 100) / 200) * 15`

- Converts NPS range (-100 to +100) to 0-15 points
- Example: NPS of +50 = 11.25 points (rounded to 11)
- No data default: 0 (neutral NPS)

### 2. Compliance Rate (15 points)

**Formula**: `(compliance_percentage / 100) * 15`

- Direct conversion of compliance percentage
- Capped at 100%
- Example: 80% compliance = 12 points
- No data default: 50% (7.5 points)

### 3. AR Aging (10 points)

**Dual-Goal System**:
- Goal 1: ≥90% of AR under 60 days (worth 5 points)
- Goal 2: 100% of AR under 90 days (worth 5 points)

**Scoring**:
- Both goals met: 10 points (full score)
- One goal met: 5-7 points (proportional)
- Neither goal met: 0-5 points (proportional to progress)
- No data: 10 points (assumes healthy)

### 4. Revenue Trend (15 points)

**Scoring Tiers**:
- YoY growth > 10%: **15 points** (strong growth)
- YoY growth 0-10%: **10 points** (modest growth/flat)
- YoY growth < 0%: **5 points** (declining)
- No data: **10 points** (neutral)

**Data Source**: `client_revenue_data` table

### 5. Contract Status (15 points)

**Risk-Based Scoring Matrix**:

| Renewal Risk | ARR Stability | Points |
|--------------|---------------|--------|
| Low          | Stable        | 15     |
| Low          | At-risk       | 12     |
| Low          | Declining     | 13     |
| Medium       | Stable        | 10     |
| Medium       | At-risk       | 7      |
| Medium       | Declining     | 8      |
| High         | Any           | 5      |
| No data      | -             | 10     |

**Data Source**: `client_contract_status` table

### 6. Actions Completion (10 points)

**Formula**: `(completion_percentage / 100) * 10`

- Direct conversion of completion rate
- Example: 75% completion = 7.5 points (rounded to 8)
- No actions: 10 points (nothing outstanding)

### 7. Support Health (10 points)

**Multi-Factor Scoring**:

Starting score: 10 points

**Response Time Penalties**:
- > 48 hours: cap at 3 points
- 24-48 hours: cap at 7 points
- < 24 hours: no penalty

**Volume Penalties**:
- > 10 open tickets: cap at 3 points
- 5-10 open tickets: cap at 7 points
- < 5 open tickets: no penalty

**Escalation Penalty**:
- -1 point per escalated ticket (minimum 3 points)

**No tickets**: 10 points (healthy)

**Data Source**: `client_support_tickets` table

### 8. Expansion Potential (10 points)

**Potential-Based Scoring**:
- High potential: **10 points**
- Medium potential: **7 points**
- Low potential: **3 points**
- No data: **5 points** (neutral)

**Data Source**: `client_expansion_opportunities` table

## Implementation Guide

### 1. Database Migration

Run the migration to create supporting tables:

```bash
# Apply the migration
psql $DATABASE_URL -f docs/migrations/20260105_enhanced_health_score.sql
```

This creates:
- `client_revenue_data` - Revenue tracking for trend analysis
- `client_contract_status` - Contract and renewal risk data
- `client_support_tickets` - Support ticket metrics
- `client_expansion_opportunities` - Expansion tracking
- Helper functions for score calculation
- New columns in `client_health_history` for v6.0 tracking

### 2. Using v6.0 in Code

```typescript
import {
  calculateHealthScoreV6,
  HEALTH_SCORE_CONFIG_V6,
  RevenueTrendData,
  ContractStatusData,
  SupportHealthData,
  ExpansionData,
} from '@/lib/health-score-config'

// Prepare data
const revenueTrend: RevenueTrendData = {
  currentRevenue: 500000,
  previousRevenue: 450000,
  yoyGrowthPercentage: 11.1, // Calculated: ((500k - 450k) / 450k) * 100
}

const contractStatus: ContractStatusData = {
  renewalRisk: 'low',
  arrStability: 'stable',
  contractEndDate: '2027-06-30',
  daysUntilRenewal: 542,
}

const supportHealth: SupportHealthData = {
  openTicketCount: 3,
  averageResponseTimeHours: 18.5,
  escalatedTicketCount: 0,
}

const expansion: ExpansionData = {
  potential: 'high',
  identifiedOpportunities: ['Module X', 'Service Y'],
  estimatedValue: 150000,
}

// Calculate score
const result = calculateHealthScoreV6(
  npsScore,
  compliancePercentage,
  workingCapitalData,
  revenueTrend,
  contractStatus,
  actionsData,
  supportHealth,
  expansion
)

console.log(result.total) // Total score (0-100)
console.log(result.breakdown) // Component-level scores
console.log(result.category) // Primary concern area
```

### 3. Using HealthBreakdownV6 Component

```tsx
import HealthBreakdownV6 from '@/app/(dashboard)/clients/[clientId]/components/HealthBreakdownV6'

<HealthBreakdownV6
  client={client}
  isExpanded={true}
  onToggle={() => setExpanded(!expanded)}
  revenueTrend={revenueTrend}
  contractStatus={contractStatus}
  supportHealth={supportHealth}
  expansion={expansion}
/>
```

## Data Population

### Revenue Data

```sql
INSERT INTO client_revenue_data (client_name, fiscal_year, fiscal_quarter, revenue_amount)
VALUES
  ('Client A', 2025, 'Q1', 125000),
  ('Client A', 2025, 'Q2', 130000),
  ('Client A', 2024, 'Q1', 110000),
  ('Client A', 2024, 'Q2', 115000);
```

### Contract Status

```sql
INSERT INTO client_contract_status (
  client_name,
  contract_end_date,
  renewal_risk,
  arr_stability,
  contract_value
)
VALUES (
  'Client A',
  '2027-06-30',
  'low',
  'stable',
  500000
);
```

### Support Tickets

```sql
INSERT INTO client_support_tickets (
  client_name,
  ticket_number,
  status,
  priority,
  created_date,
  first_response_date,
  response_time_hours
)
VALUES (
  'Client A',
  'TICKET-001',
  'open',
  'medium',
  '2026-01-01 10:00:00',
  '2026-01-01 15:30:00',
  5.5
);
```

### Expansion Opportunities

```sql
INSERT INTO client_expansion_opportunities (
  client_name,
  opportunity_type,
  potential_level,
  estimated_value,
  status,
  description
)
VALUES (
  'Client A',
  'upsell',
  'high',
  150000,
  'qualified',
  'Interested in additional modules for regional sites'
);
```

## Backward Compatibility

### v4.0 Support

The system maintains full backward compatibility with v4.0:

1. **Existing Data**: All existing health history data continues to work
2. **Default Calculation**: The standard `calculateHealthScore()` function still uses v4.0
3. **Migration Path**: Organizations can gradually adopt v6.0 as data becomes available
4. **Opt-in**: v6.0 must be explicitly requested via `calculateHealthScoreV6()`

### Data Availability Handling

When v6.0 data is not available, the system gracefully defaults:

- **Revenue Trend**: No data → 10 points (neutral)
- **Contract Status**: No data → 10 points (neutral)
- **Support Health**: No tickets → 10 points (healthy)
- **Expansion**: No data → 5 points (neutral)

This ensures clients without full v6.0 data still receive fair scoring.

## Thresholds (Unchanged)

Health status thresholds remain consistent with v4.0:

- **Healthy**: ≥ 70 points
- **At-Risk**: 60-69 points
- **Critical**: < 60 points

## Testing

### Unit Tests

```bash
npm run test -- health-score-config
```

### Validation Query

```sql
-- Test all v6.0 functions for a client
SELECT
  client_name,
  calculate_revenue_trend_score(client_name) as revenue_score,
  calculate_contract_status_score(client_name) as contract_score,
  calculate_support_health_score(client_name) as support_score,
  calculate_expansion_score(client_name) as expansion_score
FROM nps_clients
LIMIT 10;
```

## Benefits of v6.0

1. **Holistic View**: Captures financial, operational, and strategic dimensions
2. **Proactive Insights**: Revenue trends and contract risk enable early intervention
3. **Operational Excellence**: Support metrics drive service quality
4. **Growth Focus**: Expansion tracking aligns health with revenue opportunities
5. **Balanced Scoring**: 40% financial weighting reflects business priorities

## Migration Timeline

1. **Phase 1** (Week 1): Deploy code with v6.0 support
2. **Phase 2** (Week 2): Begin populating revenue and contract data
3. **Phase 3** (Week 3): Add support ticket integration
4. **Phase 4** (Week 4): Implement expansion opportunity tracking
5. **Phase 5** (Week 5): Full v6.0 rollout with dashboard updates

## API Endpoints

### Get v6.0 Health Score

```typescript
GET /api/clients/[clientId]/health-v6

Response:
{
  "version": "6.0",
  "total": 78,
  "status": "healthy",
  "breakdown": {
    "nps": 12,
    "compliance": 13,
    "arAging": 10,
    "revenueTrend": 15,
    "contractStatus": 12,
    "actions": 8,
    "supportHealth": 7,
    "expansion": 10
  },
  "category": "operational",
  "insights": {
    "primaryConcern": "Actions completion rate needs improvement",
    "strengths": ["Strong revenue growth", "Low renewal risk"],
    "opportunities": ["High expansion potential identified"]
  }
}
```

## Reporting

v6.0 scores will be available in:

- Client Profile Health Breakdown
- Health History Charts (trend analysis)
- ChaSen AI Context
- Executive Dashboards
- CSE Performance Reports

## Support

For questions or issues with v6.0 implementation:

1. Check this guide first
2. Review `/docs/migrations/20260105_enhanced_health_score.sql`
3. Consult `/src/lib/health-score-config.ts`
4. Contact: Platform Team

## Changelog

- **2026-01-05**: v6.0 released with 6-component model
- **2026-01-02**: v4.0 added Actions component
- **2025-12-28**: v3.0 added Working Capital dual-goals
- **2025-12-03**: v2.0 adjusted weights (NPS 40%, Compliance 50%)
- **2025-12-02**: v1.0 initial 2-component system
