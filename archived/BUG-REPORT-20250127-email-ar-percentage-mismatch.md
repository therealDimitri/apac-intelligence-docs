# Bug Report: Email AR Percentage Calculation Mismatch

**Date:** 2025-01-27
**Severity:** Medium
**Status:** Fixed

## Problem Description

The Working Capital percentages displayed in email reports did not match the dashboard values. The email was using TOTAL outstanding amounts (including current/not-yet-due invoices) as the denominator, while the dashboard correctly uses OVERDUE amounts only (excluding current).

### Symptoms
- Email reports showed different AR aging percentages compared to the dashboard
- "Under 60 Days" and "Under 90 Days" percentages were consistently different between email and dashboard

## Root Cause

In `/src/lib/emails/data-aggregator.ts`, the AR aging percentage calculations were:

1. Including "current" (not-yet-due) invoices in the numerator for "Under 60 Days"
2. Using `totalOutstanding` (which includes current) as the denominator

This differed from the dashboard logic which:
1. Excludes "current" invoices entirely (they're not overdue)
2. Uses `totalOverdue` as the denominator

## Files Affected

- `/src/lib/emails/data-aggregator.ts` - Two calculation blocks fixed:
  - Lines ~1136-1160 (first AR aging calculation in manager email aggregation)
  - Lines ~2372-2394 (second AR aging calculation in buildARAgingForClients function)

## Fix Applied

### Before (Incorrect):
```typescript
// Under 60 days = current + 1-30 + 31-60
const under60 = arAging.current + arAging.days1to30 + arAging.days31to60
arAging.percentUnder60Days = Math.round((under60 / arAging.totalOutstanding) * 100)
```

### After (Correct):
```typescript
// Total overdue (excludes current - only late invoices)
const totalOverdue = arAging.days1to30 + arAging.days31to60 + arAging.days61to90 + arAging.days91Plus

// Under 60 days = 1-30 + 31-60 (excludes current)
const under60 = arAging.days1to30 + arAging.days31to60
arAging.percentUnder60Days = totalOverdue > 0 ? Math.round((under60 / totalOverdue) * 100) : 100

// Under 90 days = 1-30 + 31-60 + 61-90 (excludes current)
const under90 = under60 + arAging.days61to90
arAging.percentUnder90Days = totalOverdue > 0 ? Math.round((under90 / totalOverdue) * 100) : 100

// Over 90 days
arAging.percentOver90Days = totalOverdue > 0 ? Math.round((arAging.days91Plus / totalOverdue) * 100) : 0
```

## Testing

- Build compilation verified with `npm run build` - no TypeScript errors
- Changes applied to both calculation locations for consistency

## Impact

- Email reports will now show AR aging percentages that match the dashboard
- Better alignment between different views of the same data
- More accurate Working Capital metrics in email communications

## Lessons Learned

When displaying the same metric across different interfaces (dashboard, email, API), ensure the calculation methodology is consistent. Document the formula being used so discrepancies can be identified and resolved.
