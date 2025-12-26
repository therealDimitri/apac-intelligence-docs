# Enhancement: Aged Accounts Alerts in Priority Matrix

**Date:** 21 December 2025
**Type:** Enhancement
**Status:** Completed

## Summary

Integrated aged accounts compliance alerts into the Priority Matrix dashboard. Users now see real-time alerts for accounts receivable issues directly in the "Do Now" quadrant, enabling proactive collection management.

## Changes Made

### 1. Updated Type Definitions

**Files Modified:**

- `src/components/priority-matrix/utils.ts`
- `src/components/ActionableIntelligenceDashboard.tsx`

Added `'aging'` type to the `CriticalAlert` interface:

```typescript
type: 'attrition' | 'compliance' | 'overdue' | 'risk' | 'aging'
```

Added `clients?: string[]` property for multi-client support in aging alerts.

### 2. Added Alert Type Label

Updated `getAlertTypeLabel()` function to display "Aged Accounts Alert" for aging type alerts.

### 3. Integrated useAgingAccounts Hook

Added the existing `useAgingAccounts` hook to fetch real-time aged receivables data from the Invoice Tracker integration.

### 4. Alert Generation Logic

Added logic to generate two types of **grouped** aging alerts (consolidated like compliance alerts):

#### a) Critical Aged Receivables (Grouped)

- Collects all clients with `critical` risk level and 90+ day overdue amounts
- Creates a **single grouped alert** showing all affected clients
- Displays total outstanding amount across all critical clients
- Shows multiple client logos when applicable
- Links to `/aging-accounts/compliance`

#### b) Under-60-Day Compliance Alert (Grouped)

- Triggers when compliance is below 90% target
- Groups remaining at-risk clients not already in the critical alert
- Severity: `critical` if gap > 15%, otherwise `high`
- Links to `/aging-accounts/compliance`

## Alert Display

Alerts appear in the "DO NOW" quadrant of the Priority Matrix with:

- Issue: Compliance percentage or outstanding amount
- Impact: Description of risk and required action
- Actions: Links to relevant aged accounts views

## Technical Details

### Dependencies

- Uses existing `useAgingAccounts` hook (`src/hooks/useAgingAccounts.ts`)
- Integrates with Invoice Tracker API for real-time data

### Urgency Scoring

- Critical portfolio alerts: urgencyScore = 5 (very high priority)
- High portfolio alerts: urgencyScore = 20
- Individual critical clients: urgencyScore = 3 (highest priority)

### Filtering

- Respects `isRelevantToUser()` filter for hyper-personalisation
- Only shows alerts for clients assigned to the current user (when "My Clients" filter is active)

## Testing

1. Build passes without TypeScript errors
2. Priority Matrix displays aging alerts when compliance is below target
3. Clicking alert actions navigates to correct aged accounts views

## Files Changed

| File                                                 | Change                                                 |
| ---------------------------------------------------- | ------------------------------------------------------ |
| `src/components/priority-matrix/utils.ts`            | Added `'aging'` type and label                         |
| `src/components/ActionableIntelligenceDashboard.tsx` | Added useAgingAccounts hook and alert generation logic |

## Related Documentation

- [Aged Accounts Compliance Feature](FEATURE-AGING-ACCOUNTS-COMPLIANCE.md)
- [Invoice Tracker Integration Guide](INVOICE-TRACKER-INTEGRATION-GUIDE.md)
