# Feature: Invoice Tracker Integration (Aged Receivables)

**Date:** 2025-12-18
**Status:** Complete
**Category:** Integration / Working Capital

---

## Overview

Integration with the Invoice Tracker application to provide real-time aged receivables data and working capital insights by client. This enables CSMs to view outstanding invoices, aging buckets, and risk assessments directly within the APAC Intelligence Hub.

## Components Created

### 1. API Proxy Route

**File:** `src/app/api/invoice-tracker/aging/route.ts`

Proxies requests to the Invoice Tracker API with:

- JWT authentication with automatic token caching (23-hour TTL)
- Transform aging report into client-centric summaries
- Risk level calculation (critical/high/medium/low)
- Currency conversion to USD
- Client filtering support

**Endpoints:**

- `GET /api/invoice-tracker/aging` - Returns portfolio and client aging data
- `GET /api/invoice-tracker/aging?client=SingHealth` - Filter by client name
- `GET /api/invoice-tracker/aging?format=raw` - Returns raw Invoice Tracker data

### 2. React Hook

**File:** `src/hooks/useAgedReceivables.ts`

Custom hook providing:

- `data` - Full aging data response
- `loading` - Loading state
- `error` - Error message if any
- `refresh()` - Manual refresh function
- `getClientAging(clientName)` - Get specific client's aging
- `getAtRiskClients()` - Get clients with critical/high risk
- `portfolioTotals` - Portfolio-level totals
- `clients` - Array of client summaries

**Options:**

```typescript
useAgedReceivables({
  clientFilter?: string,    // Filter by client name
  autoRefresh?: boolean,    // Enable auto-refresh (default: false)
  refreshInterval?: number  // Refresh interval in ms (default: 300000)
})
```

### 3. UI Component

**File:** `src/components/AgedReceivablesCard.tsx`

React component with:

- Portfolio summary view (4 metric cards)
- Client list with expandable aging breakdown
- Risk level badges with colour coding
- Refresh button
- Link to Invoice Tracker application

**Usage:**

```tsx
import AgedReceivablesCard from '@/components/AgedReceivablesCard'

// Portfolio view (all clients)
<AgedReceivablesCard />

// Single client view
<AgedReceivablesCard clientName="SingHealth" />

// Compact view (no client list)
<AgedReceivablesCard compact />
```

### 4. ChaSen Knowledge Entries

Four knowledge entries added to `chasen_knowledge` table:

| Category       | Key                   | Title                             |
| -------------- | --------------------- | --------------------------------- |
| data_sources   | aged_receivables      | Aged Receivables Data Source      |
| formulas       | overdue_ratio         | Overdue Ratio Calculation         |
| business_rules | ar_risk_thresholds    | AR Risk Thresholds and Escalation |
| definitions    | working_capital_terms | Working Capital Terminology       |

ChaSen can now answer questions about:

- How aging buckets work
- Risk level classifications
- Overdue ratio calculations
- Recommended actions by risk level

## Data Model

### Aging Buckets

- **Current** - Not yet due
- **31-60 days** - 1-2 months overdue
- **61-90 days** - 2-3 months overdue
- **91-120 days** - 3-4 months overdue
- **121-180 days** - 4-6 months overdue
- **181-270 days** - 6-9 months overdue
- **271-365 days** - 9-12 months overdue
- **>365 days** - Over 1 year overdue

### Risk Level Calculation

| Risk Level   | Criteria                                               |
| ------------ | ------------------------------------------------------ |
| **Critical** | Any invoice >271 days overdue OR >50% overdue ratio    |
| **High**     | Any invoice 121-270 days overdue OR >30% overdue ratio |
| **Medium**   | Any invoice 61-120 days overdue OR >15% overdue ratio  |
| **Low**      | All invoices <61 days AND <15% overdue ratio           |

### Response Types

```typescript
interface ClientAgingSummary {
  client: string
  totalUSD: number
  current: number
  days31to60: number
  days61to90: number
  days91to120: number
  days121to180: number
  days181to270: number
  days271to365: number
  over365: number
  invoiceCount: number
  oldestOverdueDays: number
  riskLevel: 'low' | 'medium' | 'high' | 'critical'
}

interface PortfolioTotals {
  totalUSD: number
  current: number
  overdue: number
  days31to60: number
  days61to90: number
  days91to120: number
  days121to180: number
  days181to270: number
  days271to365: number
  over365: number
  clientCount: number
  criticalClients: number
  highRiskClients: number
}
```

## Environment Variables

Add to `.env.local` (local) and Netlify (production):

```bash
INVOICE_TRACKER_URL=https://invoice-tracker.altera-apac.com
INVOICE_TRACKER_EMAIL=<service_account_email>
INVOICE_TRACKER_PASSWORD=<service_account_password>
```

## Integration Points

### Dashboard

Add to main dashboard for portfolio-wide view:

```tsx
<AgedReceivablesCard showRefresh />
```

### Client Profile

Add to client detail pages:

```tsx
<AgedReceivablesCard clientName={client.name} />
```

### ChaSen AI

ChaSen automatically has access to knowledge about aged receivables and can answer questions like:

- "What are the risk levels for aged receivables?"
- "How is overdue ratio calculated?"
- "What actions should I take for critical risk clients?"

## External Dependencies

- **Invoice Tracker API** - `https://invoice-tracker.altera-apac.com`
  - Authentication: JWT token via `/api/auth/login`
  - Aging Report: `/api/aging-report`

## Testing

### Local Testing

The Invoice Tracker API (`invoice-tracker.altera-apac.com`) may not be accessible from external networks. Testing should be done:

1. On corporate network, or
2. In production environment

### Verification Script

```bash
node scripts/add-ar-knowledge.mjs
```

## Files Changed

| File                                         | Action                      |
| -------------------------------------------- | --------------------------- |
| `src/app/api/invoice-tracker/aging/route.ts` | Created                     |
| `src/hooks/useAgedReceivables.ts`            | Created                     |
| `src/components/AgedReceivablesCard.tsx`     | Created                     |
| `scripts/add-ar-knowledge.mjs`               | Created                     |
| `.env.local`                                 | Modified (added 3 env vars) |
| `chasen_knowledge` table                     | Modified (added 4 entries)  |

## Related Documentation

- [Invoice Tracker Repository](https://github.com/dwilsoning/invoice-tracker)
- ChaSen Knowledge Admin: `/settings/knowledge`

---

**Author:** Claude Code
**Commits:** `0da8b2f`, `33f22c5`
