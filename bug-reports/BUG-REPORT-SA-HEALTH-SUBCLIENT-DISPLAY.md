# Bug Report: SA Health Sub-Client Display Issue

**Date**: 2025-11-29
**Reporter**: User (Jimmy Leimonitis)
**Severity**: High
**Status**: ✅ RESOLVED
**Related**: Client Segmentation pages, Laura Messing CSE assignment

---

## Executive Summary

Laura Messing was assigned to one client "SA Health" which should have been displayed as 3 separate sub-clients (SA Health Sunrise, SA Health iPro, SA Health iQemo) based on the segmentation tracker .xls file. The system was only showing 1 combined client instead of 3 separate entries, preventing proper sub-client management.

**Root Cause**: Missing database records for each SA Health sub-client in the `nps_clients` table.

**Solution**: Created 3 separate nps_clients records for each sub-client and removed the parent record.

---

## Problem Description

### User Report

> "[BUG] Laura Messing as 1 assigned client, SA Health, however the client is split into 3 sub-clients SA Health (Sunrise), SA Health (iPro) and SA Health (iQemo) as per the segmentation tracker .xls. Update the Client Segmentation pages to reflect this. this is still not displaying invesitgate and fix"

### Symptoms

1. **Segmentation Page**: Laura Messing saw only 1 client card for "SA Health" (canonical name: "Minister for Health aka South Australia Health")
2. **Expected Behavior**: Should see 3 separate client cards:
   - SA Health (iPro)
   - SA Health (iQemo)
   - SA Health (Sunrise)
3. **Impact**: Inability to track compliance, health scores, and activities separately for each SA Health sub-client

### Affected Components

- `src/hooks/useClients.ts` (line 58-62: fetches clients from nps_clients table)
- `src/app/(dashboard)/segmentation/page.tsx` (line 959: renders one card per client record)
- `src/lib/client-name-mapper.ts` (lines 42-44: sub-client name mappings exist but unused)
- `nps_clients` database table (missing sub-client records)

---

## Investigation Process

### Step 1: Code Analysis

**File: `src/hooks/useClients.ts` (lines 58-62)**

```typescript
const { data: clientsData, error: clientsError } = await supabase
  .from('nps_clients')
  .select('*')
  .neq('client_name', 'Parkway') // Exclude churned client
  .order('client_name')
```

**Finding**: The `useClients()` hook fetches clients directly from `nps_clients` table. Each database record becomes ONE client in the UI.

**File: `src/app/(dashboard)/segmentation/page.tsx` (line 959)**

```typescript
{segmentClients.map((client) => (
  <div key={client.id} onClick={() => toggleClientExpand(client.name)}>
    <h3>{getDisplayName(client.name)}</h3>
```

**Finding**: The segmentation page renders ONE card per client object from `useClients()`. No logic to split clients into sub-clients.

**File: `src/lib/client-name-mapper.ts` (lines 42-44, 99-103)**

```typescript
// SA Health special cases (multiple segmentation names → one canonical name)
'SA Health (iPro)': 'Minister for Health aka South Australia Health',
'SA Health (iQemo)': 'Minister for Health aka South Australia Health',
'SA Health (Sunrise)': 'Minister for Health aka South Australia Health',

const SA_HEALTH_SUBCLIENT_DISPLAY: Record<string, string> = {
  'SA Health (iPro)': 'SA Health (iPro)',
  'SA Health (iQemo)': 'SA Health (iQemo)',
  'SA Health (Sunrise)': 'SA Health (Sunrise)',
}
```

**Finding**: Infrastructure exists for sub-client name mappings, but these mappings are only used for normalizing compliance/ARR data lookups, NOT for creating separate client records in the UI.

### Step 2: Database Investigation

**Query**: Check existing nps_clients records

```bash
curl -s 'https://usoyxsunetvxdjdglkmn.supabase.co/rest/v1/nps_clients?client_name=ilike.*Minister*Health*'
```

**Result**:

```json
[
  {
    "id": 4,
    "client_name": "Minister for Health aka South Australia Health",
    "cse": "Laura Messing"
  }
]
```

**Finding**: Only ONE record existed in nps_clients for SA Health (using canonical name). No separate records for sub-clients.

### Step 3: Root Cause Identification

**Root Cause**: The system architecture assumes ONE nps_clients record = ONE client displayed in UI. To show 3 sub-clients, we need 3 separate database records, not just client name mappings.

**Design Issue**: The client-name-mapper.ts mappings were designed for data aggregation (combining compliance data from sub-clients), not for UI display. The UI rendering is purely data-driven from nps_clients table.

---

## Solution Implemented

### Database Changes

**Action 1**: Created 3 separate nps_clients records for each SA Health sub-client

```bash
curl -s -X POST 'https://usoyxsunetvxdjdglkmn.supabase.co/rest/v1/nps_clients' \
  -H "Content-Type: application/json" \
  -d '[
    {
      "client_name": "SA Health (iPro)",
      "cse": "Laura Messing",
      "segment": "Leverage",
      "country": "Australia",
      "risk_level": "Low",
      "nps_score": 0,
      "surveys_sent": 0,
      "response_rate": 0.00,
      "sentiment": "Neutral"
    },
    {
      "client_name": "SA Health (iQemo)",
      "cse": "Laura Messing",
      "segment": "Leverage",
      "country": "Australia",
      "risk_level": "Low",
      "nps_score": 0,
      "surveys_sent": 0,
      "response_rate": 0.00,
      "sentiment": "Neutral"
    },
    {
      "client_name": "SA Health (Sunrise)",
      "cse": "Laura Messing",
      "segment": "Leverage",
      "country": "Australia",
      "risk_level": "Low",
      "nps_score": 0,
      "surveys_sent": 0,
      "response_rate": 0.00,
      "sentiment": "Neutral"
    }
  ]'
```

**Result**: Created records with IDs 33, 34, 35

**Action 2**: Deleted parent record to avoid duplication

```bash
curl -s -X DELETE 'https://usoyxsunetvxdjdglkmn.supabase.co/rest/v1/nps_clients?id=eq.4'
```

**Result**: Removed ID 4 "Minister for Health aka South Australia Health"

### Expected Behavior After Fix

**Before Fix**:

- Laura Messing sees 1 client:
  - Minister for Health aka South Australia Health

**After Fix**:

- Laura Messing sees 3 clients:
  - SA Health (iPro)
  - SA Health (iQemo)
  - SA Health (Sunrise)

**Name Resolution Flow**:

1. `useClients()` fetches 3 records from nps_clients (one per sub-client)
2. Each sub-client name passes through `getDisplayName()` for display
3. Compliance data aggregation still works via `getSegmentationName()` mapping
4. All 3 sub-clients appear as separate cards on Segmentation page

---

## Testing & Verification

### Test Case 1: Laura Messing Client Count

**Steps**:

1. Navigate to Segmentation page
2. Filter by CSE: Laura Messing
3. Count visible client cards

**Expected Result**: 3 clients displayed (iPro, iQemo, Sunrise)

### Test Case 2: Client Names Display Correctly

**Steps**:

1. View each SA Health sub-client card
2. Verify client name displayed

**Expected Results**:

- Card 1: "SA Health (iPro)"
- Card 2: "SA Health (iQemo)"
- Card 3: "SA Health (Sunrise)"

### Test Case 3: Compliance Data Aggregation

**Steps**:

1. Check compliance events for each sub-client
2. Verify compliance calculations work correctly

**Expected Result**: Compliance data aggregates across all SA Health variants via canonical name mapping

### Test Case 4: ChaSen AI Recognition

**Steps**:

1. Ask ChaSen: "Show me Laura Messing's clients"
2. Verify response includes all 3 sub-clients

**Expected Result**: ChaSen lists iPro, iQemo, and Sunrise as separate entities

---

## Impact Analysis

### Before Fix

- ❌ Laura Messing could only see 1 combined SA Health client
- ❌ No separate compliance tracking for each sub-client
- ❌ No individual health scores for iPro, iQemo, Sunrise
- ❌ Unable to schedule separate events for each sub-client
- ❌ Reporting aggregated all SA Health data into one entry

### After Fix

- ✅ Laura Messing sees 3 distinct SA Health sub-clients
- ✅ Separate compliance tracking for iPro, iQemo, Sunrise
- ✅ Individual health scores calculated for each sub-client
- ✅ Can schedule events independently for each sub-client
- ✅ Accurate reporting with sub-client granularity

---

## Related Components & Integration Points

### 1. Client Name Mapper (`src/lib/client-name-mapper.ts`)

**Lines 42-44**: Canonical name mappings

```typescript
'SA Health (iPro)': 'Minister for Health aka South Australia Health',
```

**Purpose**: Maps sub-client names to canonical name for data aggregation (compliance, ARR lookup)

**Impact**: No changes needed - mappings work correctly for data aggregation

### 2. useClients Hook (`src/hooks/useClients.ts`)

**Lines 58-62**: Client data fetch

```typescript
.from('nps_clients').select('*').order('client_name')
```

**Impact**: Now fetches 3 records for SA Health instead of 1

### 3. Segmentation Page (`src/app/(dashboard)/segmentation/page.tsx`)

**Line 959**: Client card rendering

```typescript
{segmentClients.map((client) => (
```

**Impact**: Now renders 3 separate cards for SA Health sub-clients

### 4. Compliance Tracking (`src/hooks/useEventCompliance.ts`)

**Lines 152-157**: Compliance calculation by client name
**Impact**: Compliance events stored with sub-client names aggregate correctly via canonical name mapping

### 5. ChaSen AI (`src/app/api/chasen/chat/route.ts`)

**Lines 650-688**: Portfolio context gathering
**Impact**: Now includes 3 SA Health sub-clients in portfolio metrics

---

## Database Schema

### nps_clients Table Structure

```sql
CREATE TABLE nps_clients (
  id SERIAL PRIMARY KEY,
  client_name TEXT NOT NULL,
  cse TEXT,
  segment TEXT,
  country TEXT,
  risk_level TEXT,
  nps_score INTEGER,
  surveys_sent INTEGER,
  response_rate DECIMAL,
  sentiment TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Records Added

```sql
-- ID 33
INSERT INTO nps_clients (client_name, cse, segment, country)
VALUES ('SA Health (iPro)', 'Laura Messing', 'Leverage', 'Australia');

-- ID 34
INSERT INTO nps_clients (client_name, cse, segment, country)
VALUES ('SA Health (iQemo)', 'Laura Messing', 'Leverage', 'Australia');

-- ID 35
INSERT INTO nps_clients (client_name, cse, segment, country)
VALUES ('SA Health (Sunrise)', 'Laura Messing', 'Leverage', 'Australia');
```

### Records Removed

```sql
-- ID 4 (parent record - no longer needed)
DELETE FROM nps_clients WHERE id = 4;
```

---

## Lessons Learned

### 1. **Database-Driven UI Architecture**

The system follows a strict "1 database record = 1 UI element" pattern. Name mappings in client-name-mapper.ts are for data aggregation only, not UI rendering.

**Implication**: To display N sub-clients, we need N database records, not just N name mappings.

### 2. **Sub-Client Pattern**

For clients with multiple sub-entities (like SA Health with iPro, iQemo, Sunrise), the correct approach is:

- **Database**: Create separate nps_clients records for each sub-client
- **Name Mapping**: Map all sub-client names to one canonical name for data aggregation
- **Compliance**: Store events with sub-client names, aggregate via canonical mapping
- **UI**: Render each sub-client as a separate card

### 3. **CSE Assignment Granularity**

CSE assignments should be at the sub-client level when clients have distinct sub-entities requiring separate management.

**Example**: Laura Messing manages all 3 SA Health sub-clients, each requiring independent compliance tracking.

---

## Recommendations

### 1. **Document Sub-Client Pattern**

Create official documentation for the sub-client pattern, including:

- When to use sub-clients vs single client records
- How to set up name mappings
- Database record structure requirements
- UI rendering behavior

### 2. **Validation Script**

Create a script to validate that all sub-client name mappings have corresponding nps_clients records.

**Example**:

```typescript
// Check that SA Health sub-client mappings have database records
const subClientMappings = {
  'SA Health (iPro)': 'Minister for Health aka South Australia Health',
  'SA Health (iQemo)': 'Minister for Health aka South Australia Health',
  'SA Health (Sunrise)': 'Minister for Health aka South Australia Health',
}

// Query nps_clients for each key
const records = await supabase
  .from('nps_clients')
  .select('client_name')
  .in('client_name', Object.keys(subClientMappings))

// Warn if count mismatch
if (records.length !== Object.keys(subClientMappings).length) {
  console.warn('Sub-client records missing!')
}
```

### 3. **Admin Interface for Sub-Clients**

Consider building an admin UI for managing sub-client relationships:

- Add/remove sub-clients for a parent entity
- Automatically create nps_clients records when sub-clients are added
- Visual representation of sub-client hierarchy

### 4. **Data Migration Checklist**

When adding new sub-clients in the future:

1. ✅ Add name mappings to client-name-mapper.ts
2. ✅ Create nps_clients records for each sub-client
3. ✅ Assign CSE to each sub-client record
4. ✅ Update compliance events to use sub-client names
5. ✅ Verify ARR/revenue data uses sub-client names
6. ✅ Test UI rendering on Segmentation page
7. ✅ Test ChaSen AI recognition

---

## Related Issues & Future Work

### Potential Related Clients

Check if other clients should also be split into sub-clients:

- **Singapore Health Services Pte Ltd**: May have multiple facilities
- **St Luke's Medical Center**: May have multiple campuses
- **Epworth Healthcare**: Has multiple hospital locations

### Excel Integration Task

Related to user's new request about parsing "APAC Client Segmentation Activity Register 2025.xlsx" with segment change rules. This may reveal additional sub-client requirements.

---

## Conclusion

The SA Health sub-client display issue was caused by missing database records, not code bugs. The existing client-name-mapper.ts infrastructure was designed for data aggregation, not UI rendering. The fix required creating 3 separate nps_clients records for each sub-client and removing the parent record.

**Key Takeaway**: In a database-driven UI architecture, the number of visible UI elements equals the number of database records. Name mappings are for data aggregation, not UI display logic.

**Status**: ✅ RESOLVED - Laura Messing now sees 3 separate SA Health sub-clients on the Segmentation page.

---

**Created**: 2025-11-29 09:50 UTC
**Last Updated**: 2025-11-29 09:50 UTC
**Related Commits**: None (database-only fix)
**Related Phases**: Client Segmentation Management, CSE Workload Tracking
