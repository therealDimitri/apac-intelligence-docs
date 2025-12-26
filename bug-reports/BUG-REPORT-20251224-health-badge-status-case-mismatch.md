# Bug Report: Health Badge Status Case Mismatch

**Date:** 24 December 2025
**Status:** Fixed
**Severity:** Medium
**Affected Feature:** Client Profile page - Health status badge colours and icons

---

## Summary

The health status badge on the individual client profile page (LeftColumn.tsx) was not displaying the correct colours and icons. "Healthy" clients were not showing green badges with the CheckCircle2 icon.

---

## Root Cause

**Case mismatch between database values and UI comparisons.**

The `client_health_summary` materialized view in the database returns status values with:

- `"Healthy"` (capital H)
- `"At Risk"` (capital letters, space between words)
- `"Critical"` (capital C)

But the UI code was comparing against:

- `'healthy'` (lowercase)
- `'at-risk'` (lowercase, hyphen instead of space)
- `'critical'` (implicitly via else clause)

**Example from database:**

```
- Epworth Healthcare: status="Critical" (health_score: 45)
- Te Whatu Ora Waikato: status="Healthy" (health_score: 100)
- Mount Alvernia Hospital: status="At Risk" (health_score: 61)
```

---

## Symptoms

1. All clients showed the "Critical" (red) badge colour regardless of actual status
2. All clients showed the AlertTriangle icon instead of CheckCircle2 for healthy clients
3. The badge text displayed correctly (since it used `client.status` directly)

---

## Fix Applied

**File:** `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`

Added a `normalizedStatus` variable that converts the database status to a consistent format:

```typescript
// Normalize status from database (handles "Healthy", "At Risk", "Critical" from DB)
// Converts to lowercase and replaces space with hyphen for consistent comparison
const normalizedStatus = (client.status || '').toLowerCase().replace(/\s+/g, '-') as
  | 'healthy'
  | 'at-risk'
  | 'critical'
```

Then updated all status comparisons to use `normalizedStatus`:

```typescript
// Before
client.status === 'healthy'

// After
normalizedStatus === 'healthy'
```

---

## Verification

After the fix:

- Healthy clients (score >= 70): Green badge with CheckCircle2 icon
- At Risk clients (score 50-69): Yellow badge with AlertTriangle icon
- Critical clients (score < 50): Red badge with AlertTriangle icon

---

## Prevention

1. **Consistent Status Values:** Database migrations should use consistent casing (`'healthy'`, `'at-risk'`, `'critical'`)
2. **Type Safety:** TypeScript interfaces should enforce lowercase hyphenated status values
3. **Normalisation:** When reading from database, always normalize status values to expected format

---

## Related Files

- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` - Fixed
- `src/app/(dashboard)/client-profiles/page.tsx` - Uses healthScore thresholds directly (no fix needed)
- `docs/migrations/20251223_cap_working_capital_in_health_score.sql` - Returns `'Healthy'` (capitalised)
