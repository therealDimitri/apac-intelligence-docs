# Bug Report: Ageing Accounts Table - TOTALS Row Alignment

**Date:** 2025-12-20
**Status:** Fixed
**Priority:** Low
**Category:** UI/Display Bug

---

## Summary

The TOTALS row in the Ageing Accounts Detailed View table was misaligned by one column, causing all monetary values to appear under the wrong column headers.

---

## Problem

### Observed Behaviour

| TOTALS (3 clients) |     | $140,263      | $0                | $16,573        | $0              | $126,279        | $283,115      |
| ------------------ | --- | ------------- | ----------------- | -------------- | --------------- | --------------- | ------------- |
| _(spans 2 cols)_   |     | _(under CSE)_ | _(under Current)_ | _(under 1-30)_ | _(under 31-60)_ | _(under 61-90)_ | _(under 90+)_ |

### Expected Behaviour

| TOTALS (3 clients) |     |     | $140,263          | $0             | $16,573         | $0              | $126,279      | $283,115        |
| ------------------ | --- | --- | ----------------- | -------------- | --------------- | --------------- | ------------- | --------------- |
| _(spans 3 cols)_   |     |     | _(under Current)_ | _(under 1-30)_ | _(under 31-60)_ | _(under 61-90)_ | _(under 90+)_ | _(under Total)_ |

---

## Root Cause

The footer row used `colSpan={2}` which only spanned the "Client Name" and "Status" columns. The table has 9 columns:

1. Client Name
2. Status
3. CSE
4. Current
5. 1-30 Days
6. 31-60 Days
7. 61-90 Days
8. 90+ Days
9. Total

The TOTALS label should span columns 1-3 (Client Name, Status, CSE) so that the monetary values start from column 4 (Current).

---

## Fix Applied

**File:** `src/app/(dashboard)/aging-accounts/page.tsx`

```diff
- <td colSpan={2} className="px-6 py-4 text-sm text-gray-900">
+ <td colSpan={3} className="px-6 py-4 text-sm text-gray-900">
    TOTALS ({filteredAndSortedClients.length} clients)
  </td>
```

---

## Commit

- `b4f9e48` - fix: align TOTALS row in Ageing Accounts table

---

## Testing

- [x] TOTALS row values align with column headers
- [x] Current column shows current balance total
- [x] 1-30 Days column shows 1-30 days total
- [x] 31-60 Days column shows 31-60 days total
- [x] 61-90 Days column shows 61-90 days total (yellow highlight)
- [x] 90+ Days column shows over 90 days total (red highlight)
- [x] Total column shows overall total (purple highlight)
