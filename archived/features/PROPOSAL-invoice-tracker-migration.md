# Proposal: Replace Excel Aging Accounts with Invoice Tracker Integration

**Date:** 2025-12-18
**Status:** Draft Proposal
**Author:** Claude Code

---

## Executive Summary

Replace the manual Excel-based aging accounts import workflow with real-time Invoice Tracker API integration. This eliminates manual data entry, provides fresher data, and reduces operational overhead while preserving all existing compliance calculations and CSE attribution.

---

## Current State Analysis

### Excel-Based Workflow

```
Manual Excel Update → GitHub Actions → Parser → Database → API → UI
     (Weekly)           (Monday 9am)
```

**Pain Points:**

- Data is up to 7 days stale
- Manual file preparation required
- Risk of human error in Excel updates
- No real-time visibility into AR changes
- Duplicate effort (data exists in Invoice Tracker already)

### Current Data Sources

| Source          | Data                              | Update Frequency |
| --------------- | --------------------------------- | ---------------- |
| Excel File      | CSE + Client + Aging Buckets      | Weekly (manual)  |
| Invoice Tracker | Client + Aging Buckets + Invoices | Real-time        |

### Key Gap

**Invoice Tracker lacks CSE assignment.** The Excel file contains CSE-to-client mappings that don't exist in Invoice Tracker.

---

## Recommended Solution

### Architecture: Hybrid Approach

```
Invoice Tracker API ──┬──► Aging Data (real-time)
                      │
Client-CSE Mapping ───┴──► Combined Data ──► API ──► UI
(from clients table)
```

### Strategy: Use `clients` Table for CSE Assignment

The existing `clients` table already contains CSE assignments:

```sql
-- clients table has:
-- - client_name (normalised)
-- - assigned_cse (CSE name)
-- - segment, tier, etc.
```

**Solution:** Join Invoice Tracker data with `clients` table to get CSE assignments.

---

## Implementation Options

### Option A: Full Replacement (Recommended)

Replace Excel import entirely with Invoice Tracker API.

**Pros:**

- Real-time data
- No manual intervention
- Single source of truth
- Eliminates Excel maintenance

**Cons:**

- Requires CSE mapping in `clients` table to be complete
- Historical compliance data needs migration strategy

**Effort:** Medium (2-3 days)

---

### Option B: Hybrid with Fallback

Use Invoice Tracker as primary, Excel as fallback for unmapped clients.

**Pros:**

- Gradual migration
- Handles edge cases
- Lower risk

**Cons:**

- Maintains two systems temporarily
- More complex logic

**Effort:** Medium-High (3-4 days)

---

### Option C: Invoice Tracker with CSE Override Table

Create a dedicated `cse_client_assignments` table for CSE mappings.

**Pros:**

- Decoupled from `clients` table
- Easy to maintain
- Supports historical assignments

**Cons:**

- New table to maintain
- Data duplication

**Effort:** Medium (2-3 days)

---

## Recommended Implementation (Option A)

### Phase 1: Data Mapping Verification

**Task:** Ensure all Invoice Tracker clients have CSE assignments in `clients` table.

```sql
-- Find clients in Invoice Tracker without CSE assignment
SELECT DISTINCT it.client_name
FROM invoice_tracker_data it
LEFT JOIN clients c ON LOWER(it.client_name) = LOWER(c.client_name)
WHERE c.assigned_cse IS NULL;
```

**Deliverable:** Report of unmapped clients + manual CSE assignments.

---

### Phase 2: API Route Modification

**File:** `src/app/api/aging-accounts/route.ts`

**Change:** Replace database query with Invoice Tracker API call + CSE join.

```typescript
// Current: Query aging_accounts table
const { data } = await supabase.from('aging_accounts').select('*')

// New: Fetch from Invoice Tracker + join with clients for CSE
const invoiceData = await fetch('/api/invoice-tracker/aging')
const { data: clients } = await supabase.from('clients').select('client_name, assigned_cse')

// Merge CSE assignments
const enrichedData = invoiceData.clients.map(client => ({
  ...client,
  cseName: findCSE(clients, client.client),
}))
```

**New Response Structure:**

```typescript
{
  success: true,
  data: [{
    cseName: string,
    clients: [{
      clientName: string,
      buckets: AgingBuckets,
      totalOutstanding: number,
      riskLevel: 'low' | 'medium' | 'high' | 'critical'
    }],
    compliance: {
      totalOutstanding: number,
      percentUnder60Days: number,
      percentUnder90Days: number,
      meetsGoals: boolean
    }
  }],
  source: 'invoice-tracker',
  timestamp: string
}
```

---

### Phase 3: Compliance Calculation Update

**File:** `src/app/api/aging-accounts/compliance/route.ts`

**Preserve existing compliance logic:**

```typescript
function calculateCompliance(clients: ClientAgingSummary[]): CSECompliance {
  const totalOverdue = clients.reduce((sum, c) =>
    sum + c.totalUSD - c.current, 0)

  const under60 = clients.reduce((sum, c) =>
    sum + c.days31to60, 0)  // Note: 1-30 is not in Invoice Tracker buckets

  const under90 = under60 + clients.reduce((sum, c) =>
    sum + c.days61to90, 0)

  return {
    totalOutstanding: clients.reduce((sum, c) => sum + c.totalUSD, 0),
    totalOverdue,
    amountUnder60Days: under60,
    amountUnder90Days: under90,
    percentUnder60Days: totalOverdue > 0 ? (under60 / totalOverdue) * 100 : 100,
    percentUnder90Days: totalOverdue > 0 ? (under90 / totalOverdue) * 100 : 100,
    meetsGoals: /* existing logic */
  }
}
```

**Important Bucket Mapping:**

| Excel Column | Invoice Tracker Field                  |
| ------------ | -------------------------------------- |
| Current      | `current`                              |
| 1-30 Days    | ❌ Not available (combined with 31-60) |
| 31-60 Days   | `days31to60`                           |
| 61-90 Days   | `days61to90`                           |
| 91-120 Days  | `days91to120`                          |
| 121-180 Days | `days121to180`                         |
| 181-270 Days | `days181to270`                         |
| 271-365 Days | `days271to365`                         |
| >365 Days    | `over365`                              |

**Gap:** Invoice Tracker doesn't have 1-30 days bucket. Options:

1. Treat 31-60 as "under 60" (slight compliance calculation change)
2. Request Invoice Tracker API enhancement
3. Accept the data model difference

---

### Phase 4: Historical Data Strategy

**Options:**

**A. Keep Historical in Database (Recommended)**

- Retain `aging_accounts` table for historical queries
- New data from Invoice Tracker, historical from database
- Compliance trend charts use both sources

**B. Snapshot Invoice Tracker Weekly**

- Create scheduled job to snapshot Invoice Tracker data
- Store in `aging_accounts_history` table
- Full history going forward

**C. Drop Historical**

- Start fresh with Invoice Tracker
- Lose historical compliance trends
- Not recommended

---

### Phase 5: UI Component Updates

#### Update `useAgingAccounts` Hook

```typescript
// src/hooks/useAgingAccounts.ts

export function useAgingAccounts(options: Options = {}) {
  const { cseName, useInvoiceTracker = true } = options

  const fetchData = useCallback(async () => {
    if (useInvoiceTracker) {
      // New: Fetch from Invoice Tracker API
      const response = await fetch('/api/aging-accounts?source=invoice-tracker')
      return response.json()
    } else {
      // Legacy: Fetch from database (for historical)
      const response = await fetch('/api/aging-accounts?source=database')
      return response.json()
    }
  }, [cseName, useInvoiceTracker])

  // ... rest of hook
}
```

#### Update Pages

**`/aging-accounts/page.tsx`:**

- Add "Last Updated" timestamp from Invoice Tracker
- Remove "Week Ending" filter (real-time data)
- Add "Refresh" button for manual refresh

**`/aging-accounts/compliance/page.tsx`:**

- Historical chart: Use database for past weeks
- Current compliance: Use Invoice Tracker
- Add data source indicator

---

### Phase 6: Deprecate Excel Workflow

1. **Disable GitHub Actions workflow** (`.github/workflows/import-aging-accounts.yml`)
2. **Archive Excel parser** (`src/lib/aging-accounts-parser.ts`)
3. **Keep database table** for historical data
4. **Update documentation**

---

## Data Model Comparison

### Current (Excel-Based)

```typescript
interface AgingAccountsRow {
  cse_name: string // From Excel column A
  client_name: string // From Excel column B
  current_amount: number // Column D
  days_1_to_30: number // Column E
  days_31_to_60: number // Column F
  days_61_to_90: number // Column G
  days_91_to_120: number // Column H
  days_121_to_180: number // Column I
  days_181_to_270: number // Column J
  days_271_to_365: number // Column K
  days_over_365: number // Column L
  total_outstanding: number // Column M
  most_recent_comment: string // Column C
  is_inactive: boolean // Derived
}
```

### New (Invoice Tracker-Based)

```typescript
interface InvoiceTrackerAging {
  client: string // From Invoice Tracker
  cseName: string // From clients table join
  current: number // Bucket: Current
  days31to60: number // Bucket: 31-60
  days61to90: number // Bucket: 61-90
  days91to120: number // Bucket: 91-120
  days121to180: number // Bucket: 121-180
  days181to270: number // Bucket: 181-270
  days271to365: number // Bucket: 271-365
  over365: number // Bucket: >365
  totalUSD: number // Grand total
  invoiceCount: number // Number of invoices
  oldestOverdueDays: number // Days since oldest overdue
  riskLevel: RiskLevel // Calculated risk
}
```

### Key Differences

| Aspect           | Excel  | Invoice Tracker          |
| ---------------- | ------ | ------------------------ |
| 1-30 days bucket | ✅ Yes | ❌ No                    |
| Invoice count    | ❌ No  | ✅ Yes                   |
| Risk level       | ❌ No  | ✅ Yes                   |
| Comments         | ✅ Yes | ❌ No                    |
| Inactive flag    | ✅ Yes | ❌ No                    |
| Currency         | Single | Multi (converted to USD) |
| Update frequency | Weekly | Real-time                |

---

## CSE Assignment Strategy

### Current CSE Mappings (from clients table)

```sql
SELECT DISTINCT assigned_cse, COUNT(*) as client_count
FROM clients
WHERE assigned_cse IS NOT NULL
GROUP BY assigned_cse;
```

### Required Actions

1. **Audit `clients` table** for complete CSE assignments
2. **Create CSE mapping view** for easy joining:

```sql
CREATE VIEW v_client_cse_mapping AS
SELECT
  client_name,
  LOWER(client_name) as client_name_normalized,
  assigned_cse as cse_name,
  segment,
  tier
FROM clients
WHERE assigned_cse IS NOT NULL;
```

3. **Handle unmapped clients:**
   - Option A: Assign to "Unassigned" CSE bucket
   - Option B: Exclude from compliance calculations
   - Option C: Flag for manual review

---

## Migration Checklist

### Pre-Migration

- [ ] Audit `clients` table for CSE assignments
- [ ] Identify unmapped Invoice Tracker clients
- [ ] Assign CSEs to unmapped clients
- [ ] Document current compliance baselines
- [ ] Backup `aging_accounts` table

### Migration

- [ ] Create new API route version (`/api/aging-accounts/v2`)
- [ ] Update compliance calculation for new buckets
- [ ] Add Invoice Tracker data source to hooks
- [ ] Update UI components for real-time data
- [ ] Test compliance calculations match

### Post-Migration

- [ ] Disable Excel import workflow
- [ ] Archive Excel parser code
- [ ] Update user documentation
- [ ] Monitor for data discrepancies
- [ ] Gather user feedback

---

## Risk Assessment

| Risk                         | Likelihood | Impact | Mitigation                |
| ---------------------------- | ---------- | ------ | ------------------------- |
| Missing CSE assignments      | Medium     | High   | Pre-audit clients table   |
| Compliance calculation drift | Low        | Medium | Side-by-side comparison   |
| Invoice Tracker API downtime | Low        | Medium | Cache last known data     |
| Missing 1-30 days bucket     | High       | Low    | Adjust compliance formula |
| Historical data loss         | Low        | High   | Keep database table       |

---

## Timeline Estimate

| Phase                        | Duration     | Dependencies            |
| ---------------------------- | ------------ | ----------------------- |
| 1. Data Mapping Verification | 1 day        | Access to clients table |
| 2. API Route Modification    | 1 day        | Phase 1 complete        |
| 3. Compliance Calculation    | 0.5 day      | Phase 2 complete        |
| 4. Historical Data Strategy  | 0.5 day      | Phase 2 complete        |
| 5. UI Component Updates      | 1 day        | Phases 2-4 complete     |
| 6. Testing & Validation      | 1 day        | Phase 5 complete        |
| 7. Deprecate Excel Workflow  | 0.5 day      | Phase 6 complete        |
| **Total**                    | **5-6 days** |                         |

---

## Recommendation

**Proceed with Option A (Full Replacement)** with the following conditions:

1. **Complete CSE audit first** - Ensure all Invoice Tracker clients have CSE assignments
2. **Accept 1-30 days gap** - Adjust compliance formula to use 31-60 as first overdue bucket
3. **Retain historical data** - Keep `aging_accounts` table for trend analysis
4. **Implement gradually** - Use feature flag to switch between sources

### Immediate Next Steps

1. Run CSE mapping audit query
2. Identify and assign unmapped clients
3. Create `/api/aging-accounts/v2` route with Invoice Tracker integration
4. Side-by-side comparison of compliance calculations

---

## Appendix: API Endpoint Design

### New Unified Aging Endpoint

```
GET /api/aging-accounts/v2
```

**Query Parameters:**

- `cse` - Filter by CSE name
- `client` - Filter by client name
- `source` - `invoice-tracker` (default) or `database` (historical)
- `includeHistory` - Include historical compliance data

**Response:**

```json
{
  "success": true,
  "source": "invoice-tracker",
  "generatedAt": "2025-12-18T10:30:00Z",
  "portfolioSummary": {
    "totalOutstanding": 1500000,
    "totalOverdue": 450000,
    "overduePercent": 30,
    "clientCount": 25,
    "cseCount": 5,
    "atRiskClients": 3
  },
  "byCSE": [
    {
      "cseName": "John Smith",
      "clients": [...],
      "compliance": {
        "totalOutstanding": 300000,
        "percentUnder60Days": 85,
        "percentUnder90Days": 95,
        "meetsGoals": false,
        "healthScore": 78
      }
    }
  ],
  "alerts": [
    {
      "type": "critical_aging",
      "client": "ClientX",
      "message": "3 invoices over 365 days ($45,000)"
    }
  ]
}
```

---

**Document Version:** 1.0
**Last Updated:** 2025-12-18
