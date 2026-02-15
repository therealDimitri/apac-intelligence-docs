# Bug Report: Overdue Actions Not Surfaced on Dashboard

**Date**: 2026-01-23
**Status**: RESOLVED
**Severity**: High
**Component**: Executive Dashboard / RequiresAttentionPanel

---

## Issue Summary

The Executive Dashboard's "Requires Attention" panel did not display overdue actions, despite 29 actions having due dates in the past with statuses other than Completed/Cancelled.

## Root Cause

The `attentionItems` array in `BURCExecutiveDashboard.tsx` only aggregated:
- Overdue renewals
- Critical health clients
- No-contact clients (90+ days)
- Churn risk clients

It did not fetch or display overdue actions from the `actions` table.

## Solution

Added overdue actions fetching and display to the dashboard:

### 1. State Variable
```typescript
const [overdueActions, setOverdueActions] = useState<{
  id: number
  actionDescription: string
  client: string
  dueDate: string
  owner: string
  daysOverdue: number
}[]>([])
```

### 2. Fetch Logic in `fetchData()`
- Query actions with Status not in ('Completed', 'Cancelled') and is_internal = false
- Parse both ISO dates (2026-01-14) and DD/MM/YYYY dates (31/12/2025)
- Calculate days overdue and sort by most overdue first

### 3. Add to Attention Items
```typescript
overdueActions.slice(0, 5).forEach(action => {
  items.push({
    id: `overdue-action-${action.id}`,
    type: 'overdue',
    severity: action.daysOverdue > 30 ? 'critical' :
              action.daysOverdue > 14 ? 'high' : 'medium',
    clientName: action.client,
    message: `Action overdue by ${action.daysOverdue} days: ${action.actionDescription.slice(0, 50)}...`,
    daysOverdue: action.daysOverdue,
    actionLabel: action.owner,
  })
})
```

## Files Modified

- `src/components/burc/BURCExecutiveDashboard.tsx`

## Testing

1. Verified 29 overdue actions fetched from Supabase
2. Requires Attention panel now shows 26 total items (including up to 5 overdue actions)
3. Build passes with no TypeScript errors

## Related

- Part of data audit: `docs/audits/2026-01-23-data-audit-report.md`
- Closes audit item #4: "Surface overdue actions on dashboard (18 overdue)"
