# Bug Report: Churn Prediction Feature Wiring Complete

**Date:** 2026-01-08
**Status:** Resolved
**Priority:** Medium
**Component:** Churn Prediction Engine

---

## Issue Summary

The churn prediction system had three TODO items for feature extraction that were using placeholder values (0 or undefined), limiting the accuracy of churn predictions:
- Support ticket count: Always 0
- Revenue history: Empty array
- Days until renewal: Always undefined

---

## Root Cause

The `extractFeaturesForClient()` function in `src/lib/churn-prediction.ts` had placeholder values because the data sources had not been identified or wired.

```typescript
// Before: Placeholder values
const ticketCount = 0; // TODO: Integrate support ticket data
const revenueHistory: number[] = []; // TODO: Integrate revenue data
const daysUntilRenewal = undefined; // TODO: Integrate contract renewal data
```

---

## Solution Implemented

### 1. Support Tickets → Actions Table Proxy

Since there is no dedicated support tickets table, the `actions` table is used as a proxy. Actions with:
- Category containing "Support" or "Escalation"
- Priority of "Critical" or "High"
- Status NOT "Completed" or "Done"

Are counted as active support items, which correlates with client health concerns.

```typescript
const { data: supportActions } = await supabase
  .from('actions')
  .select('id, Category, Priority, Status')
  .eq('client', clientName)
  .or('Category.ilike.%support%,Category.ilike.%escalation%,Priority.eq.Critical,Priority.eq.High');

const openSupportActions = supportActions?.filter(a =>
  a.Status !== 'Completed' && a.Status !== 'Done'
) || [];
const ticketCount = openSupportActions.length;
```

### 2. Contract Renewal → burc_contracts Table

Contract renewal dates are sourced from `burc_contracts` with active status:

```typescript
const { data: contractData } = await supabase
  .from('burc_contracts')
  .select('renewal_date, contract_status')
  .ilike('client_name', `%${clientName.split(' ')[0]}%`)
  .eq('contract_status', 'active')
  .limit(1)
  .single();

let daysUntilRenewal: number | undefined;
if (contractData?.renewal_date) {
  const renewalDate = new Date(contractData.renewal_date);
  const today = new Date();
  daysUntilRenewal = Math.ceil((renewalDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
}
```

### 3. Revenue History → burc_historical_revenue_detail Table

Client revenue trends are extracted from `burc_historical_revenue_detail`:

```typescript
const { data: revenueData } = await supabase
  .from('burc_historical_revenue_detail')
  .select('fiscal_year, amount_usd')
  .ilike('client_name', `%${clientName.split(' ')[0]}%`)
  .gte('fiscal_year', 2022)
  .order('fiscal_year', { ascending: true });

// Aggregate by year
const revenueByYear = new Map<number, number>();
revenueData?.forEach(r => {
  const current = revenueByYear.get(r.fiscal_year) || 0;
  revenueByYear.set(r.fiscal_year, current + (r.amount_usd || 0));
});
const revenueHistory = Array.from(revenueByYear.values());
```

---

## Data Architecture

```
┌─────────────────────────────┐
│        Feature              │  Data Source
├─────────────────────────────┤
│ Support Tickets (proxy)     │ → actions (Category, Priority)
│ Contract Renewal            │ → burc_contracts (renewal_date)
│ Revenue History             │ → burc_historical_revenue_detail
│ NPS Scores                  │ → nps_responses (existing)
│ Compliance Rate             │ → event_compliance_by_client (existing)
│ Meeting Count               │ → unified_meetings (existing)
│ AR Aging                    │ → aging_accounts (existing)
└─────────────────────────────┘
```

---

## Test Results

Verified feature extraction for sample clients:

| Client | Open Support Actions | Contract Renewal | Revenue Data |
|--------|---------------------|------------------|--------------|
| Epworth Healthcare | 1 | Not found | FY22-26 ✓ |
| SingHealth | 3 | Not found | FY22-25 ✓ |
| WA Health | 1 | 574 days | FY22-26 ✓ |

---

## Files Modified

| File | Change |
|------|--------|
| `src/lib/churn-prediction.ts` | Wired 3 new data sources to `extractFeaturesForClient()` |

---

## Risk Score Calculations

The existing risk calculation functions remain unchanged:

- **Support Tickets Risk**: 0 (none), 20 (1-2), 50 (3-5), 70 (6-10), 90 (10+)
- **Renewal Proximity Risk**: Increases as renewal approaches, especially if other issues exist
- **Revenue Trend Risk**: Detects declining revenue patterns across years

---

## Limitations & Future Improvements

1. **Client Name Matching**: Uses partial matching on first word of client name, which may miss some matches
2. **Support Tickets**: No dedicated support ticket system; actions table is a proxy
3. **Contract Coverage**: Only 8 contracts in `burc_contracts`, so many clients have no renewal data

**Recommended Future Work:**
- Add client_uuid matching for more reliable joins
- Integrate external support ticket system (Zendesk, Freshdesk, Jira) if available
- Expand contract data coverage

---

## Verification

After deployment, the churn prediction API (`/api/analytics/churn-prediction`) will return more accurate predictions with real data for:
- `supportTickets` risk score
- `revenueTrend` risk score
- `renewalProximity` risk score
