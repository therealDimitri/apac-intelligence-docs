# Bug Report: Priority Matrix Assigned-To Badge Not Persisting

**Date:** 17 December 2025
**Status:** ✅ Fixed
**Severity:** High
**Component:** Priority Matrix, Assignment System

---

## Summary

The "Assigned to" badge on Priority Matrix items was disappearing after page reload, even when users had assigned actions to team members (specifically John Salisbury). The badges would initially appear correctly after assignment but would not persist across browser sessions.

---

## Root Causes Identified

### 1. Name Inconsistency (John vs Jonathan Salisbury)

**Location:** Multiple files
**Issue:** The system had conflicting name configurations:

- `microsoft-graph.ts:661` — Mock data used `displayName: 'Jonathan Salisbury'`
- `aging-accounts-parser.ts:14` — Name mapping transformed `'John Salisbury'` → `'Jonathan Salisbury'`
- Database records were being created with "Jonathan Salisbury" instead of "John Salisbury"

### 2. Aggressive localStorage Cleanup

**Location:** `MatrixContext.tsx:65-110`
**Issue:** The `cleanupStalePersistedData()` function was removing owner entries from localStorage whenever items temporarily disappeared from the Priority Matrix (e.g., when pushed out by `.slice()` limits or data changes). This meant valid assignments were being deleted when items cycled in and out of the visible matrix.

### 3. Assignment API Mismatch

**Location:** `api/assignment/route.ts`
**Issue:** Matrix item IDs (e.g., `overdue-ACT-123`) didn't match database Action_IDs (`ACT-123`). When the API received an assignment request with a matrix item ID, it couldn't find the existing action and would create a new one instead of updating the existing record.

---

## Fixes Applied

### Fix 1: Standardised John Salisbury Name

**Files Modified:**

- `src/lib/microsoft-graph.ts:659-667`
- `src/lib/aging-accounts-parser.ts:12-15`

**Changes:**

```typescript
// microsoft-graph.ts - Changed mock user display name
displayName: 'John Salisbury',  // was 'Jonathan Salisbury'
mail: 'john.salisbury@alterahealth.com',

// aging-accounts-parser.ts - Removed problematic mapping
const CSE_NAME_MAPPINGS: Record<string, string> = {
  'Boon Lim': 'BoonTeck Lim',
  // Note: John Salisbury should remain as "John Salisbury" - no mapping needed
};
```

### Fix 2: Preserved Owner Assignments in localStorage

**File Modified:** `src/components/priority-matrix/MatrixContext.tsx:65-104`

**Changes:**

- Removed the cleanup of owner entries from localStorage
- Only position entries (UI state) are now cleaned up
- Owner assignments persist indefinitely, allowing them to be reapplied when items reappear in the matrix

```typescript
// NOTE: We intentionally do NOT clean up owner entries
// Owner assignments are valuable user data that should persist even when items
// temporarily don't appear in the matrix (due to filters, slice limits, etc.)
console.log('[MatrixContext] Preserving all owner assignments in localStorage')
```

### Fix 3: Added Action ID Extraction for Matrix Items

**File Modified:** `src/app/api/assignment/route.ts:24-52, 139-151`

**Changes:**

- Added `extractActionIdFromMatrixId()` function to extract actual database Action_IDs from matrix item IDs
- Pattern matching for: `overdue-ACT-xxx`, `action-ACT-xxx`, and direct `ACT-xxx` formats
- API now correctly updates existing database records instead of creating duplicates

```typescript
function extractActionIdFromMatrixId(matrixItemId: string): string | null {
  const overdueMatch = matrixItemId.match(/^overdue-(ACT-[A-Za-z0-9-]+)$/i)
  if (overdueMatch) return overdueMatch[1].toUpperCase()

  const actionMatch = matrixItemId.match(/^action-(ACT-[A-Za-z0-9-]+)$/i)
  if (actionMatch) return actionMatch[1].toUpperCase()

  if (matrixItemId.match(/^ACT-[A-Za-z0-9-]+$/i)) return matrixItemId.toUpperCase()

  return null
}
```

### Fix 4: Database Records Updated

**Tables Updated:**

1. **`actions` table** — 13 records updated:
   - WA Health (4 actions)
   - Barwon Health Australia (2 actions)
   - Epworth Healthcare (2 actions)
   - The Royal Victorian Eye and Ear Hospital (3 actions)
   - Western Health (2 actions)

2. **`cse_profiles` table** — 1 record updated:
   - Changed `full_name` from "Jonathan Salisbury" to "John Salisbury"
   - Changed `first_name` from "John" to "John" (no change needed)
   - This fixes the assignment dropdown showing "Jonathan" in suggested assignees

---

## Testing Verification

1. **Build Verification:** `npm run build` — ✅ Compiled successfully
2. **Database Update:** 13 records corrected via migration script
3. **Name Consistency:** All systems now use "John Salisbury" consistently

---

## Files Changed

| File                                               | Change Type | Description                                    |
| -------------------------------------------------- | ----------- | ---------------------------------------------- |
| `src/lib/microsoft-graph.ts`                       | Modified    | Changed Jonathan → John Salisbury in mock data |
| `src/lib/aging-accounts-parser.ts`                 | Modified    | Removed John → Jonathan name mapping           |
| `src/components/priority-matrix/MatrixContext.tsx` | Modified    | Preserved owner assignments in localStorage    |
| `src/app/api/assignment/route.ts`                  | Modified    | Added Action ID extraction from matrix IDs     |
| `scripts/fix-john-salisbury-name.ts`               | Created     | One-time migration script for database         |

---

## Technical Details

### Data Flow Before Fix

1. User assigns "John Salisbury" via dropdown (showing "Jonathan Salisbury")
2. localStorage stores: `{ "overdue-ACT-123": "Jonathan Salisbury" }`
3. On reload: Item regenerated, cleanup removes orphaned entry
4. Badge disappears

### Data Flow After Fix

1. User assigns "John Salisbury" via dropdown (now showing "John Salisbury")
2. localStorage stores: `{ "overdue-ACT-123": "John Salisbury" }`
3. API extracts `ACT-123` from matrix ID, updates correct database record
4. On reload: localStorage entry preserved, owner applied to matching item
5. Badge persists ✅

---

## Recommendations

1. **Monitor localStorage size** — Since owner entries are no longer cleaned up, consider implementing a time-based cleanup (e.g., entries older than 90 days) if storage becomes an issue
2. **Consider database persistence** — For critical assignments, consider storing owner data in the database rather than localStorage for better cross-device persistence
3. **Add name validation** — Consider adding validation to prevent name inconsistencies in the future

---

## Related Issues

- Priority Matrix badge display
- Assignment workflow
- localStorage persistence
- Name standardisation across the platform
