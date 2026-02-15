# Bug Report: Priority Matrix Assignments Not Syncing Across Devices/Browsers

**Date:** 2025-12-30
**Severity:** Medium
**Status:** Resolved

## Summary

Priority Matrix owner assignments, quadrant positions, and per-client assignments were stored in browser `localStorage`, causing them to not sync across different browsers or devices. Users would assign owners on one machine, but see default data on another.

## Symptoms

- Owner assignments made on dev machine showed correct CSE names with profile photos
- Same page on production (different browser/device) showed truncated names like "client_succ..." and "S sales"
- Quadrant positions (e.g., moving items between "Do Now" and "Plan") did not persist across browsers
- Per-client owner assignments for multi-client items were lost when switching devices

## Root Cause

The `MatrixContext.tsx` stored all persistence data in browser `localStorage`:
- `priority-matrix-item-positions` - Which quadrant each item belongs to
- `priority-matrix-item-owners` - Assigned CSE for each item
- `priority-matrix-client-assignments` - Per-client owners for multi-client items

Since `localStorage` is browser-specific, this data never synced to the database and was invisible to other browsers/devices.

## Resolution

Implemented database persistence with localStorage as a fast cache layer:

### 1. Created Database Table

```sql
CREATE TABLE public.priority_matrix_assignments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id TEXT NOT NULL UNIQUE,
    owner TEXT,
    quadrant TEXT,
    client_assignments JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 2. Created API Endpoint

`/api/priority-matrix` with methods:
- **GET** - Fetch all assignments
- **POST** - Upsert an assignment (create or update)
- **DELETE** - Remove an assignment
- **PATCH** - Bulk update multiple assignments

### 3. Updated MatrixContext

- Loads assignments from database on component mount
- Saves to localStorage immediately for fast UI updates
- Saves to database asynchronously (non-blocking)
- Prefers database data, falls back to localStorage

## Files Modified

| File | Changes |
|------|---------|
| `src/components/priority-matrix/MatrixContext.tsx` | Added database sync functions, updated save/load logic |
| `src/app/api/priority-matrix/route.ts` | New API endpoint for CRUD operations |
| `docs/migrations/20251230_priority_matrix_assignments.sql` | Database migration |
| `scripts/apply-priority-matrix-assignments-migration.mjs` | Migration script |

## Technical Implementation

### Data Flow

```
User Action (assign owner)
    ↓
localStorage (immediate, for fast UI)
    ↓
Database API (async, for persistence)
    ↓
Database (source of truth)
```

### Load Sequence

```
1. Component mounts
2. Load from localStorage (fast, for immediate display)
3. Fetch from database (async)
4. Merge database data into state (database takes priority)
5. Future saves go to both localStorage and database
```

### Key Functions

- `fetchDatabaseAssignments()` - Loads all assignments from API
- `saveToDatabase()` - Upserts assignment via API (async)
- `deleteFromDatabase()` - Removes assignment via API (async)
- `applyPersistedData()` - Merges database/localStorage data into items

## Testing Verification

1. Open Priority Matrix on Browser A
2. Assign an owner to an item
3. Open Priority Matrix on Browser B (or incognito)
4. Verify the owner assignment appears correctly
5. Verify profile photos display for assigned owners

## Database Verification

```sql
-- Check assignments in database
SELECT item_id, owner, quadrant, client_assignments
FROM priority_matrix_assignments
ORDER BY updated_at DESC
LIMIT 10;
```

## API Verification

```bash
# Fetch all assignments
curl https://apac-cs-dashboards.com/api/priority-matrix

# Create/update an assignment
curl -X POST https://apac-cs-dashboards.com/api/priority-matrix \
  -H "Content-Type: application/json" \
  -d '{"item_id": "test-item", "owner": "John Smith"}'
```

## Related Files

- `src/hooks/useCSEProfiles.ts` - Hook for CSE profile photos
- `src/components/priority-matrix/types.ts` - MatrixItem type definition
- `src/components/priority-matrix/PriorityMatrix.tsx` - Main component

## Notes

- localStorage is retained as a cache layer for fast initial renders
- Database is the source of truth for cross-device sync
- RLS policies allow anonymous access (consistent with other tables)
- Migration includes `updated_at` trigger for automatic timestamp updates
