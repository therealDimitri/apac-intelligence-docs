# Bug Report: Missing Subsidiary Information and Origination Sources

**Date:** 2025-12-31
**Severity:** Low (UX Enhancement)
**Status:** Fixed

## Issue Description

Two related UX issues were identified:

1. **Missing Subsidiary Information**: The SingHealth attrition alert description didn't reflect that KKH and other hospitals are SingHealth subsidiaries. Users expected to see which subsidiaries would be affected by the SingHealth contract expiration.

2. **Missing Origination Sources**: Actions and alerts didn't display their origination source (e.g., Meeting, AI/ML, BURC, NPS, Segmentation), making it difficult for users to understand where each item originated from.

## Root Cause

1. The `CONFIRMED_ATTRITION` array only had basic client information without subsidiary details.
2. Alert creation didn't populate the `category` field with source information for display.

## Solution

### 1. Added Subsidiary Information

Updated `CONFIRMED_ATTRITION` to include subsidiary arrays:

```typescript
const CONFIRMED_ATTRITION = [
  {
    client: 'SingHealth',
    year: 2029,
    reason: 'Contract expiration',
    subsidiaries: ['KKH', 'SGH', 'CGH', 'NHCS', 'SKH', 'NCCS', 'SNEC'],
    source: 'BURC',
  },
  // ...
]
```

The impact message now includes: "Affects 7 subsidiaries: KKH, SGH, CGH, NHCS, SKH, NCCS, SNEC."

### 2. Added Origination Sources

All alerts now include a `category` field showing their source:

| Alert Type | Source Category |
|------------|-----------------|
| Attrition | BURC |
| NPS Risk | NPS |
| Compliance Events | Segmentation |
| Overdue Actions | Meeting/Internal/[Category] |
| Aged Receivables | Ageing |

## Files Modified

- `src/components/ActionableIntelligenceDashboard.tsx`

## Testing

1. View the Priority Matrix or Actionable Intelligence Dashboard
2. Locate the SingHealth attrition alert
3. Verify the impact message includes "Affects 7 subsidiaries: KKH, SGH, CGH..."
4. Verify all alerts display their origination source category

## Additional Notes

- KKH (KK Women's and Children's Hospital) is correctly associated with SingHealth, not NCS/MinDef
- Other SingHealth subsidiaries include: SGH (Singapore General Hospital), CGH (Changi General Hospital), NHCS (National Heart Centre Singapore), SKH (Sengkang General Hospital), NCCS (National Cancer Centre Singapore), SNEC (Singapore National Eye Centre)
