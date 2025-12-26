# Bug Report: Database Column Mismatches and RLS Issues

**Date**: 2025-12-01
**Severity**: Critical
**Status**: ✅ Resolved
**Reporter**: Automated (Claude Code)

---

## Summary

Multiple database schema mismatches and missing RLS policies caused complete application failure across NPS Analytics, Briefing Room, and Actions & Tasks pages after Phase 2 materialized view deployment.

---

## Impact

### **Affected Features**
- ❌ NPS Analytics - "Failed to load NPS data"
- ❌ Briefing Room - "Failed to load meetings data"
- ❌ Actions & Tasks - "Failed to load actions data"
- ❌ Production Build - TypeScript compilation failure

### **User Impact**
- **100% of core features broken** - Complete application failure
- **All data pages inaccessible** - Critical business functionality lost
- **Deployment blocked** - Production builds failing

---

## Root Causes

### **1. Column Name Mismatches (3 tables)**

Application code referenced columns that didn't exist in the actual database schema:

| Table | Code Expected | Database Has | Location |
|-------|--------------|--------------|----------|
| `nps_responses` | `client_id` | ❌ None | `useNPSData.ts:72` |
| `unified_meetings` | `notes` | ❌ None | `useMeetings.ts:142` |
| `actions` | `Client`, `Owner` | `client`, `Owners` | `useActions.ts:78,139` |

### **2. Missing RLS Policy**

The `unified_meetings` table had RLS enabled but no SELECT policy for anon/authenticated users, causing 0 results despite 64 meetings existing in the database.

---

## Timeline

### **Initial Discovery** (2025-12-01 07:35 UTC)
- User reported: "Failed to load actions data" + screenshot showing column error
- Investigation revealed column `actions.Owner does not exist`

### **Cascade Failure Discovery** (2025-12-01 07:37 UTC)
- Found 3 additional column mismatches across all major data hooks
- Identified pattern: Code expected columns that never existed

### **Fix Implementation** (2025-12-01 07:38-07:42 UTC)
- Fixed `useNPSData.ts` - Removed `client_id`
- Fixed `useMeetings.ts` - Removed `notes`
- Fixed `useActions.ts` - Changed `Client`→`client`, removed `Owner`
- Fixed `EditActionModal.tsx` - Changed `Client`→`client`
- Fixed `CreateActionModal.tsx` - Changed `Client`→`client`

### **Build Failure Discovery** (2025-12-01 07:43 UTC)
- Production build failed: TypeScript error on `action.Owner` reference
- Fixed: Removed `action.Owner` fallback at line 139

### **RLS Issue Discovery** (2025-12-01 07:45 UTC)
- Briefing Room still showing "No meetings found"
- Investigation: ANON key returns 0 rows, SERVICE key returns 64 rows
- Root cause: Missing SELECT policy on `unified_meetings`

### **Final Resolution** (2025-12-01 07:47 UTC)
- Added RLS policy: `"Allow all users to view meetings"`
- ✅ All features restored

---

## Fixes Applied

### **Fix 1: useNPSData.ts Column References**
**File**: `src/hooks/useNPSData.ts`
**Commit**: `cb3fd27`

**Changes**:
```typescript
// BEFORE (INCORRECT)
export interface NPSResponse {
  id: string
  client_name: string
  client_id: string  // ❌ Column doesn't exist
  // ...
}

.select('id, client_name, client_id, score, ...')

// AFTER (CORRECT)
export interface NPSResponse {
  id: string
  client_name: string  // ✅ client_id removed
  // ...
}

.select('id, client_name, score, ...')
```

---

### **Fix 2: useMeetings.ts Column References**
**File**: `src/hooks/useMeetings.ts`
**Commit**: `cb3fd27`

**Changes**:
```typescript
// BEFORE (INCORRECT)
.select(`
  meeting_id,
  id,
  meeting_notes,
  notes,  // ❌ Column doesn't exist
  ...
`)

// AFTER (CORRECT)
.select(`
  meeting_id,
  id,
  meeting_notes,  // ✅ notes removed
  ...
`)
```

---

### **Fix 3: useActions.ts Column References**
**File**: `src/hooks/useActions.ts`
**Commits**: `cb3fd27`, `541cac3`, `c5f0cff`

**Changes**:
```typescript
// BEFORE (INCORRECT)
.select(`
  Action_ID,
  client,      // ❌ Wrong case (should be lowercase)
  Owner,       // ❌ Column doesn't exist
  Owners,
  ...
`)

const ownersString = action.Owners || action.Owner || 'Unassigned'
//                                      ^^^^^^^^^^^^^ TypeScript error

// AFTER (CORRECT)
.select(`
  Action_ID,
  client,      // ✅ Correct lowercase
  Owners,      // ✅ Owner removed
  ...
`)

const ownersString = action.Owners || 'Unassigned'
//                                    ✅ TypeScript passes
```

---

### **Fix 4: EditActionModal.tsx API Call**
**File**: `src/components/EditActionModal.tsx`
**Commit**: `cb3fd27`

**Changes**:
```typescript
// BEFORE (INCORRECT)
body: JSON.stringify({
  Client: formData.client,  // ❌ Wrong case
  ...
})

// AFTER (CORRECT)
body: JSON.stringify({
  client: formData.client,  // ✅ Correct lowercase
  ...
})
```

---

### **Fix 5: CreateActionModal.tsx Database Insert**
**File**: `src/components/CreateActionModal.tsx`
**Commit**: `cb3fd27`

**Changes**:
```typescript
// BEFORE (INCORRECT)
.insert({
  Client: formData.client,  // ❌ Wrong case
  ...
})

// AFTER (CORRECT)
.insert({
  client: formData.client,  // ✅ Correct lowercase
  ...
})
```

---

### **Fix 6: RLS Policy for unified_meetings**
**Method**: Direct Supabase service role execution
**Date**: 2025-12-01 07:47 UTC

**SQL**:
```sql
-- Drop any restrictive policies
DROP POLICY IF EXISTS "Allow all users to view meetings" ON unified_meetings;

-- Create permissive SELECT policy
CREATE POLICY "Allow all users to view meetings"
  ON unified_meetings
  FOR SELECT
  TO anon, authenticated
  USING (true);
```

**Verification**:
```javascript
// BEFORE: ANON key query
Total count: 0  // ❌ RLS blocking access

// AFTER: ANON key query
Total count: 64  // ✅ All meetings accessible
```

---

## Git Commits

1. **`cb3fd27`** - "fix: Correct database column references to match actual schema"
   - Fixed `useNPSData.ts`, `useMeetings.ts`, `useActions.ts` column mismatches
   - Fixed `EditActionModal.tsx`, `CreateActionModal.tsx` API calls

2. **`541cac3`** - "fix: Remove non-existent Owner column from actions query"
   - Removed `Owner` column from SELECT statement in `useActions.ts`

3. **`c5f0cff`** - "fix: Remove Owner fallback to fix TypeScript build error"
   - Removed `action.Owner` fallback to fix production build

---

## Testing & Verification

### **Development Server**
```bash
✓ npm run dev
✓ All pages loading (/, /nps, /actions, /meetings)
✓ No "column does not exist" errors in console
```

### **Production Build**
```bash
✓ npm run build
✓ TypeScript compilation successful
✓ All routes compiled without errors
```

### **Database Queries**
```javascript
// NPS Data
✓ ANON key: Returns all responses
✓ No client_id errors

// Meetings Data
✓ ANON key: Returns 64 meetings
✓ RLS policy allowing access

// Actions Data
✓ ANON key: Returns all actions
✓ client/Owners columns working correctly
```

---

## Prevention Measures

### **Immediate Actions**
1. ✅ **Schema Validation Script** - Created `check-schema.js` to verify columns before deployment
2. ✅ **Automated Migration Runner** - Created `scripts/run-migration.mjs` for service role deployments
3. ✅ **RLS Policy Review** - Documented all tables requiring SELECT policies

### **Process Improvements**
1. **Always verify schema before code changes** - Use service role to check actual columns
2. **Test with ANON key during development** - Catch RLS issues before production
3. **Production build before commit** - Run `npm run build` to catch TypeScript errors
4. **Use service worker for ALL database operations** - Per user directive, never manual SQL

### **Code Review Checklist**
- [ ] Column names match database schema exactly (case-sensitive)
- [ ] TypeScript types reflect actual database columns
- [ ] RLS policies exist for all new tables
- [ ] Production build succeeds (`npm run build`)
- [ ] Queries tested with ANON key (not just service role)

---

## Lessons Learned

### **What Went Wrong**
1. **No schema validation** - Code referenced non-existent columns
2. **Case sensitivity ignored** - `Client` vs `client` not caught during development
3. **RLS policies missing** - Assumed RLS was configured but never verified
4. **Dev mode masked issues** - Dev server didn't catch TypeScript errors

### **What Went Right**
1. **Service worker automation** - Fixed RLS issues instantly without manual work
2. **Systematic debugging** - Checked actual schema vs code expectations
3. **Comprehensive fixes** - Fixed all instances across 5 files in one session

---

## Related Issues

- Phase 2 materialized views deployment (successful)
- RLS security fixes deployment (caused initial column mismatch discovery)

---

## Files Modified

```
src/hooks/useNPSData.ts          (1 interface, 1 query)
src/hooks/useMeetings.ts         (1 query)
src/hooks/useActions.ts          (1 query, 1 mapping, 1 fallback)
src/components/EditActionModal.tsx   (1 API call)
src/components/CreateActionModal.tsx (1 database insert)
```

---

## Database Changes

```sql
-- RLS Policy Added
unified_meetings: "Allow all users to view meetings" (SELECT for anon, authenticated)
```

---

## Monitoring

**Post-Deployment Checks**:
- ✅ NPS Analytics page loads
- ✅ Briefing Room shows all 64 meetings
- ✅ Actions & Tasks page shows all actions
- ✅ Production build succeeds
- ✅ No console errors related to columns

---

**Status**: ✅ **All Issues Resolved**

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
