# Bug Report: Analytics Top Clients Display Issues

**Date:** 2025-12-27
**Status:** Fixed
**Severity:** Medium
**Component:** Briefing Room Analytics - Top Clients

---

## Problem Description

The "Top Clients" chart in the Briefing Room Analytics tab had two issues:

1. **Internal meetings not showing department names**: Internal meetings were displayed as just "Internal" instead of "Internal - [Department Name]"

2. **Meeting subjects shown as client names**: The `client_name` field in `unified_meetings` sometimes contained meeting subjects (e.g., "5 in 25 process and Client Success, Internal") instead of actual client names

---

## Root Cause

The `calculateTopClients()` function in `/api/analytics/meetings` was directly using the `client_name` field without:

1. Checking the `is_internal` flag or `department_code` for internal meetings
2. Parsing comma-separated client names (multiple clients per meeting)
3. Filtering out meeting subject patterns (text ending with ", Internal")

---

## Data Quality Issues Identified

From database investigation:

```
client_name values observed:
- "Internal Meeting" (should show department)
- "5 in 25 process and Client Success, Internal" (meeting subject, not client)
- "SA Health (iPro), SA Health (iQemo), SA Health (Sunrise)" (multiple clients)
- "SingHealth" (correct)
```

---

## Solution

Modified `src/app/api/analytics/meetings/route.ts`:

### 1. Updated MeetingRecord interface
```typescript
interface MeetingRecord {
  // ... existing fields
  is_internal: boolean | null
  department_code: string | null
}
```

### 2. Added department name mapping
```typescript
const DEPARTMENT_NAMES: Record<string, string> = {
  CLIENT_SUCCESS: 'Client Success',
  CLIENT_SUPPORT: 'Client Support',
  PROFESSIONAL_SERVICES: 'Professional Services',
  RD: 'R&D',
  PROGRAM_DELIVERY: 'Program Delivery',
  TECHNICAL_SERVICES: 'Technical Services',
  MARKETING: 'Marketing',
  SALES_SOLUTIONS: 'Sales & Solutions',
  BUSINESS_OPS: 'Business Ops',
  COMMERCIAL_OPS: 'Commercial Ops',
}
```

### 3. Created extractClients() helper function

This function handles:
- Internal meetings → "Internal - [Department Name]"
- Meeting subjects ending with ", Internal" → "Internal - [Department Name]"
- Multiple comma-separated clients → Split and count each separately
- Filter out generic "Internal" labels

### 4. Updated calculateTopClients()

Now uses `extractClients()` to properly parse client names and distribute meeting counts across multiple clients when applicable.

---

## Files Changed

| File | Change |
|------|--------|
| `src/app/api/analytics/meetings/route.ts` | Added `is_internal` and `department_code` to query; added `DEPARTMENT_NAMES` mapping; added `extractClients()` helper; updated `calculateTopClients()` |

---

## Testing

Verified in browser that Analytics tab now shows:
- "Internal - Client Support" instead of just "Internal"
- Proper client names like "SingHealth" and "Mount Alvernia Hospital"
- Multiple clients from same meeting counted separately

---

## Lessons Learned

1. The `client_name` field in `unified_meetings` can contain:
   - Actual client names
   - Multiple comma-separated clients
   - Meeting subjects (when meetings were imported from Outlook)
   - "Internal" or "Internal Meeting" without department context

2. Always check `is_internal` and `department_code` fields for internal meeting classification

3. Data quality issues in legacy data require defensive parsing logic
