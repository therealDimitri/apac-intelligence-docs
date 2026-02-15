# Invoice Tracker Integration Guide

**Last Updated:** 18 December 2025
**Version:** 1.0

---

## Overview

The Invoice Tracker integration provides live ageing receivables data from the external Invoice Tracker system (`invoice.alteraapacai.dev`) to the APAC Client Success Intelligence Dashboard. This enables real-time visibility into outstanding invoices, grouped by CSE assignments.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Invoice Tracker System                           │
│                   https://invoice.alteraapacai.dev                      │
│  ┌─────────────────┐    ┌─────────────────────────────────────────┐    │
│  │  Auth Service   │    │           Aging Report API              │    │
│  │ /api/auth/login │    │         /api/aging-report               │    │
│  └────────┬────────┘    └─────────────────┬───────────────────────┘    │
└───────────┼───────────────────────────────┼────────────────────────────┘
            │ JWT Token                     │ Aging Data (JSON)
            ▼                               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     Next.js API Routes (Backend)                        │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │              /api/invoice-tracker/aging-by-cse                     │ │
│  │  • Authenticates with Invoice Tracker                             │ │
│  │  • Fetches aging report                                           │ │
│  │  • Joins with CSE assignments from Supabase                       │ │
│  │  • Groups clients by CSE                                          │ │
│  │  • Calculates compliance metrics                                  │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │                /api/invoice-tracker/aging                          │ │
│  │  • Raw aging report (ungrouped)                                   │ │
│  │  • Client-level summaries                                         │ │
│  └───────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     React Frontend (Client)                             │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │                   useAgingAccounts Hook                            │ │
│  │  • Fetches data from API routes                                   │ │
│  │  • Caches responses (5 minute TTL)                                │ │
│  │  • Handles fallback to database if Invoice Tracker unavailable    │ │
│  │  • Transforms data to consistent format                           │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                              │                                          │
│         ┌────────────────────┼────────────────────┐                    │
│         ▼                    ▼                    ▼                    │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐              │
│  │   Ageing    │     │ Compliance  │     │  Command    │              │
│  │  Accounts   │     │  Dashboard  │     │   Centre    │              │
│  │    Page     │     │    Page     │     │   Widgets   │              │
│  └─────────────┘     └─────────────┘     └─────────────┘              │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Environment Configuration

### Required Environment Variables

```env
# Invoice Tracker API URL
INVOICE_TRACKER_URL=https://invoice.alteraapacai.dev

# Service account credentials for API authentication
INVOICE_TRACKER_EMAIL=your-service-account@company.com
INVOICE_TRACKER_PASSWORD=your-password
```

### Important Notes

- The Invoice Tracker does **not** require VPN access
- Credentials are for a service account, not individual user accounts
- The URL must include the protocol (`https://`)

---

## API Endpoints

### 1. Invoice Tracker Authentication

**External Endpoint:** `POST /api/auth/login`

**Request:**

```json
{
  "email": "service-account@company.com",
  "password": "password"
}
```

**Required Headers:**

```
Content-Type: application/json; charset=utf-8
```

**Response:**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { ... }
}
```

**Token Caching:**

- Tokens are cached in memory for 23 hours
- Auto-refresh occurs 5 minutes before expiry
- No database storage required

### 2. Invoice Tracker Aging Report

**External Endpoint:** `GET /api/aging-report`

**Required Headers:**

```
Authorization: Bearer {token}
Content-Type: application/json
```

**Response Structure:**

```json
{
  "generatedAt": "2025-12-18T12:00:00Z",
  "currency": "USD",
  "grandTotal": 3202240,
  "buckets": {
    "Current": {
      "totalUSD": 2466889,
      "clients": {
        "Client Name": {
          "totalUSD": 838120,
          "invoiceCount": 33,
          "invoices": [
            {
              "invoiceNumber": "INV-001",
              "invoiceDate": "2025-11-01",
              "dueDate": "2025-12-01",
              "amountDue": 50000,
              "currency": "AUD",
              "amountUSD": 32500,
              "daysOverdue": 0
            }
          ]
        }
      }
    },
    "31-60": { ... },
    "61-90": { ... },
    "91-120": { ... },
    "121-180": { ... },
    "181-270": { ... },
    "271-365": { ... },
    ">365": { ... }
  },
  "exchangeRates": {
    "AUD": 0.65,
    "SGD": 0.74,
    "PHP": 0.018
  }
}
```

### 3. Internal API: Aging by CSE

**Endpoint:** `GET /api/invoice-tracker/aging-by-cse`

**Query Parameters:**

- `cse` (optional): Filter by CSE name

**Response:**

```json
{
  "success": true,
  "source": "invoice-tracker",
  "generatedAt": "2025-12-18T12:00:00Z",
  "portfolioTotals": {
    "totalUSD": 3202240,
    "current": 2466889,
    "overdue": 735351,
    "invoiceCount": 70,
    "cseCount": 5,
    "clientCount": 11,
    "atRiskClients": 6
  },
  "byCSE": [
    {
      "cseName": "Tracey Bland",
      "clients": [
        {
          "client": "Department of Health - Victoria",
          "totalUSD": 1027060,
          "current": 838120,
          "days31to60": 188940,
          "days61to90": 0,
          "days91to120": 0,
          "days121to180": 0,
          "days181to270": 0,
          "days271to365": 0,
          "over365": 0,
          "invoiceCount": 33,
          "oldestOverdueDays": 45,
          "riskLevel": "low"
        }
      ],
      "totals": {
        "totalUSD": 1102549,
        "current": 913609,
        "overdue": 188940,
        "invoiceCount": 35
      },
      "compliance": {
        "totalOutstanding": 1102549,
        "totalOverdue": 188940,
        "amountUnder60Days": 188940,
        "amountUnder90Days": 188940,
        "percentUnder60Days": 100,
        "percentUnder90Days": 100,
        "meetsGoals": true,
        "healthScore": 100
      }
    }
  ],
  "unmatchedClients": ["IQHT", "Philips Electronics Australia"],
  "exchangeRates": { ... }
}
```

### 4. Internal API: Raw Aging

**Endpoint:** `GET /api/invoice-tracker/aging`

**Query Parameters:**

- `client` (optional): Filter by client name
- `format` (optional): `summary` (default) or `raw`

---

## Data Flow

### Aging Buckets

| Bucket  | Days Overdue | Dashboard Column      |
| ------- | ------------ | --------------------- |
| Current | 0-30 days    | Current               |
| 31-60   | 31-60 days   | 31-60 Days            |
| 61-90   | 61-90 days   | 61-90 Days            |
| 91-120  | 91-120 days  | 90+ Days (aggregated) |
| 121-180 | 121-180 days | 90+ Days (aggregated) |
| 181-270 | 181-270 days | 90+ Days (aggregated) |
| 271-365 | 271-365 days | 90+ Days (aggregated) |
| >365    | Over 1 year  | 90+ Days (aggregated) |

### Risk Level Calculation

```typescript
if (client.over365 > 0 || client.days271to365 > 0 || overdueRatio > 0.5) {
  riskLevel = 'critical'
} else if (client.days181to270 > 0 || client.days121to180 > 0 || overdueRatio > 0.3) {
  riskLevel = 'high'
} else if (client.days91to120 > 0 || client.days61to90 > 0 || overdueRatio > 0.15) {
  riskLevel = 'medium'
} else {
  riskLevel = 'low'
}
```

### Compliance Goals

- **Goal 1:** 90% of overdue receivables under 60 days
- **Goal 2:** 100% of overdue receivables under 90 days
- **Health Score:** 0-100 based on gap from goals

```typescript
const meetsGoals = percentUnder60Days >= 90 && percentUnder90Days >= 100

let healthScore = 100
if (!meetsGoals) {
  const gap90 = Math.max(0, 100 - percentUnder90Days)
  const gap60 = Math.max(0, 90 - percentUnder60Days)
  healthScore = Math.max(0, 100 - (gap90 * 0.6 + gap60 * 0.4))
}
```

---

## CSE Client Assignments

### Database Table: `cse_client_assignments`

| Column                 | Type      | Description                      |
| ---------------------- | --------- | -------------------------------- |
| id                     | uuid      | Primary key                      |
| cse_name               | text      | CSE full name                    |
| client_name            | text      | Display name of client           |
| client_name_normalized | text      | Matching key for Invoice Tracker |
| is_active              | boolean   | Whether assignment is active     |
| created_at             | timestamp | Creation timestamp               |
| updated_at             | timestamp | Last update timestamp            |

### Client Name Matching

The system uses fuzzy matching to link Invoice Tracker clients to CSE assignments:

1. **Exact match** on `client_name_normalized`
2. **Normalised match** (lowercase, remove suffixes like Pte, Ltd, Health, etc.)
3. **Partial match** (substring containment)
4. **Default:** "Unassigned" if no match found

```typescript
function normaliseClientName(name: string): string {
  return name
    .toLowerCase()
    .replace(/\s+(pte|pty|ltd|inc|corp|limited|hospital|health|medical|centre|center)\.?/gi, '')
    .replace(/[^a-z0-9]/g, '')
    .trim()
}
```

### Current Assignments (as of Dec 2025)

| CSE                | Clients                                                                         |
| ------------------ | ------------------------------------------------------------------------------- |
| BoonTeck Lim       | Singapore Health Services, National Cancer Centre, Sengkang General Hospital    |
| Gilbert So         | Strategic Asia Pacific Partners, St Luke's Medical Center                       |
| Jonathan Salisbury | Western Health, Barwon Health Australia                                         |
| Laura Messing      | South Australia Health                                                          |
| Tracey Bland       | Department of Health Victoria, Albury Wodonga Health, Gippsland Health Alliance |

---

## Frontend Components

### useAgingAccounts Hook

**Location:** `src/hooks/useAgingAccounts.ts`

**Usage:**

```typescript
const {
  agingData, // CSEAgingData[] - grouped by CSE
  currentCSEData, // Current CSE's data (if filtered)
  loading, // boolean
  error, // Error | null
  refetch, // () => Promise<void>
  getComplianceScore, // (compliance) => number
  dataSource, // 'invoice-tracker' | 'database'
  generatedAt, // ISO timestamp string
  unmatchedClients, // string[] - clients without CSE assignment
} = useAgingAccounts({ cseName: 'optional-filter', source: 'invoice-tracker' })
```

**Features:**

- 5-minute client-side cache
- Automatic fallback to database if Invoice Tracker unavailable
- Background refresh after cache hit

### Ageing Accounts Page

**Location:** `src/app/(dashboard)/aging-accounts/page.tsx`

**Features:**

- Client-level breakdown table
- Search by client or CSE name
- Filter by CSE dropdown
- Sort by client name, CSE, total, or 90+ days
- Summary cards with bucket totals
- Data source indicator (Live vs Cached)
- Refresh button

**Excluded from Display:**

- Clients assigned to "Unassigned" CSE group
- Totals recalculated without unassigned clients

### Compliance Dashboard

**Location:** `src/app/(dashboard)/aging-accounts/compliance/page.tsx`

**Features:**

- CSE-level compliance view
- Health score visualisation
- Goal achievement indicators
- Portfolio-wide metrics

---

## Troubleshooting

### Common Issues

| Issue                         | Cause                           | Solution                                           |
| ----------------------------- | ------------------------------- | -------------------------------------------------- |
| "Unauthorized" error          | Invalid or expired token        | Check credentials in .env.local                    |
| "Bad Request" on auth         | Missing charset in Content-Type | Ensure header is `application/json; charset=utf-8` |
| DNS resolution failure        | Wrong URL                       | Verify INVOICE_TRACKER_URL is correct              |
| Clients showing as Unassigned | Missing CSE assignment          | Add mapping to cse_client_assignments table        |
| Stale data                    | Cache not refreshed             | Click refresh button or wait 5 minutes             |

### Verification Steps

1. **Test API Connection:**

```bash
curl -X POST "https://invoice.alteraapacai.dev/api/auth/login" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{"email":"your-email","password":"your-password"}'
```

2. **Check Environment Variables:**

```bash
grep INVOICE_TRACKER .env.local
```

3. **Verify CSE Assignments:**

```sql
SELECT * FROM cse_client_assignments WHERE is_active = true ORDER BY cse_name;
```

---

## Security Considerations

- Service account credentials stored in environment variables only
- JWT tokens cached in memory (not persisted)
- API routes protected by Next.js middleware
- No client-side exposure of credentials
- All API calls use HTTPS

---

## Future Enhancements

- [ ] Webhook integration for real-time invoice updates
- [ ] Historical trend tracking
- [ ] Automated CSE assignment suggestions
- [ ] Email alerts for aging threshold breaches
- [ ] Invoice-level drill-down in dashboard
