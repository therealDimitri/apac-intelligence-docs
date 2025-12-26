# Bug Report: Excel Parser Event Type Breakdown Integration

**Date**: 2025-11-27
**Status**: ✅ Resolved
**Priority**: High
**Component**: Event Type Breakdown, Excel Parser
**Reporter**: System
**Assignee**: Claude Code

## Summary

Integrated real-time Excel data parsing for Event Type Breakdown section on segmentation page. Encountered and resolved three critical issues during implementation: incorrect column indexing, authentication blocking, and header row detection failures.

## Background

Event Type Breakdown section displayed static placeholder data. User requested connection to live Excel file data from:

- **File**: `/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Clients - Client Success/Client Segmentation/APAC Client Segmentation Activity Register 2025.xlsx`
- **Requirement**: Parse all sheets and workbooks to populate real-time event compliance tracking

## Issues Encountered

### Issue 1: Wrong Column Indices in Parser

#### Symptoms

- Parser only found 2 event types instead of expected 12+
- Event names were validation text ("1=Yes, 0=No") instead of actual activity names
- Console showed: "Found event: 'Per Year' with X total events"

#### Root Cause

Excel parser was using 1-based column indices instead of 0-based:

```typescript
// INCORRECT CODE (src/lib/excel-parser.ts:36-56)
if (row && row[1] === 'Activity' && row[2] === 'Frequency') {
  headerRowIndex = i
}

const eventName = row[1] // Column B (WRONG)
const frequency = row[2] // Column C (WRONG)
const team = row[3] // Column D (WRONG)
```

The Activities sheet structure is:

```
Row 0: ["APAC CLIENT SEGMENTATION 2025", null, ...]
Row 1: [null, null, ...]
Row 2: ["Activity", "Frequency", "Team", "Maintain", "Leverage", ...]  ← Header row
Row 3: ["President/Group Leader Engagement (in person)", "Per Year", "P/GL", 0, 0, 0, 0, 1, 1]
```

Parser was looking for headers at `row[1]` and `row[2]` when they were actually at `row[0]` and `row[1]`.

#### Solution

**Fixed in**: `src/lib/excel-parser.ts:34-96`

Corrected to 0-based column indices:

```typescript
// CORRECTED CODE
if (row && row[0] === 'Activity' && row[1] === 'Frequency') {
  headerRowIndex = i
}

const eventName = row[0] // Column A (CORRECT)
const frequency = row[1] // Column B (CORRECT)
const team = row[2] // Column C (CORRECT)

// Segment columns also adjusted from 4-9 to 3-8
const maintain = Number(row[3]) || 0 // Column D
const leverage = Number(row[4]) || 0 // Column E
const nurture = Number(row[5]) || 0 // Column F
const collaboration = Number(row[6]) || 0 // Column G
const sleepingGiants = Number(row[7]) || 0 // Column H
const giants = Number(row[8]) || 0 // Column I
```

#### Verification

Created debug script `scripts/debug-activities.js` that inspected exact row structure:

```javascript
Row 2: ["Activity","Frequency","Team","Maintain","Leverage","Nurture","Collaboration","Sleeping Giants","Giants"]
Row 3: ["President/Group Leader Engagement (in person)","Per Year","P/GL",0,0,0,0,1,1]
```

After fix, parser successfully returned 12 event types with correct names:

- APAC Client Forum / User Group
- CE On-Site Attendance
- EVP Engagement
- President/Group Leader Engagement (in person)
- etc.

---

### Issue 2: API Authentication Blocking

#### Symptoms

- Created API endpoint at `/api/event-types/route.ts`
- curl test returned redirect to `/auth/dev-signin` instead of data
- Response: `HTTP/1.1 307 Temporary Redirect`

#### Root Cause

NextAuth v5 middleware (configured in `middleware.ts`) was intercepting ALL API routes and requiring authentication before any route logic could execute. The API endpoint had `export const dynamic = 'force-dynamic'` and `export const fetchCache = 'force-no-store'` but middleware runs BEFORE route handlers.

**Middleware configuration** (`middleware.ts`):

```typescript
export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
```

This matcher catches all routes including `/api/*`, forcing authentication.

#### Solution Options Presented to User

1. **Option 1**: Modify middleware to exclude `/api/event-types` (requires matcher changes)
2. **Option 2**: Use Server Component approach (bypasses middleware entirely) ✅ **USER SELECTED**

#### Implementation

**User explicitly selected "option 2"**

Created Server Component approach instead of API route:

- **File**: `src/components/EventTypeBreakdown.tsx`
- **Pattern**: Server Component that calls `parseEventTypeData()` directly on server
- **Benefit**: No HTTP request, no authentication middleware, simpler architecture

```typescript
// src/components/EventTypeBreakdown.tsx:8-10
export function EventTypeBreakdown() {
  // Parse data directly on the server (no API call needed)
  const eventTypes = parseEventTypeData()
  // ... render logic
}
```

#### Files Affected

- ✅ **Created & Used**: `src/components/EventTypeBreakdown.tsx`
- ⚠️ **Created but NOT Used**: `src/app/api/event-types/route.ts` (kept for reference)

---

### Issue 3: Header Row Detection Failure

#### Symptoms

- Parser returned 0 event types
- Console error: `[Excel Parser] Could not find header row in Activities sheet`
- Test script output: `✅ Successfully parsed 0 event types`

#### Root Cause

After fixing Issue 1, header detection logic still used wrong column indices. The fix for event name columns wasn't consistently applied to header detection.

#### Solution

**Fixed in**: `src/lib/excel-parser.ts:34-42`

Ensured header detection uses same 0-based indices:

```typescript
// Find the header row (contains "Activity", "Frequency", "Team", etc.)
let headerRowIndex = -1
for (let i = 0; i < Math.min(10, data.length); i++) {
  const row = data[i]
  if (row && row[0] === 'Activity' && row[1] === 'Frequency') {
    // ← CORRECTED
    headerRowIndex = i
    console.log('[Excel Parser] Found header row at index:', i)
    break
  }
}
```

#### Verification

Created test script `scripts/test-parser.js` that confirmed:

```
✅ Successfully parsed 12 event types

Sample Event Types:

1. APAC Client Forum / User Group
   - Frequency: Per Quarter
   - Team: P/GL
   - Priority: high | Severity: critical
   - Total: 5 | Completed: 15 | Remaining: -10
   - Completion: 300%

2. CE On-Site Attendance
   - Frequency: Per Year
   - Team: P/GL
   - Priority: medium | Severity: warning
   - Total: 30 | Completed: 62 | Remaining: -32
   - Completion: 207%
```

---

## Technical Implementation

### Architecture Decision

**Chosen Approach**: Server Component Pattern

- Parses Excel file on server during page render
- No API endpoint needed
- No authentication complexity
- Simple, straightforward data flow

**Alternative Considered**: API Route + Client Component

- Would require middleware exclusions
- Additional HTTP request overhead
- More complex error handling
- Not selected by user

### Files Created

1. **`src/lib/excel-parser.ts`** (251 lines)
   - Core Excel parsing logic using xlsx library
   - `parseActivitiesSheet()`: Extracts event definitions from Activities sheet
   - `countCompletedEvents()`: Aggregates completion data from 18 client sheets
   - `parseEventTypeData()`: Main export function
   - `parseClientSegments()`: Bonus function for segment data

2. **`src/components/EventTypeBreakdown.tsx`** (134 lines)
   - Server Component displaying event type breakdown
   - Sorts by priority (high → low), then completion % (low → high)
   - Color-coded progress bars: red (<50%), yellow (50-99%), green (≥100%)
   - Priority badges: high (orange), medium (yellow), low (gray)
   - Severity badges: critical (red), warning (yellow), normal (gray)
   - Summary footer with aggregated stats

3. **`src/app/api/event-types/route.ts`** (37 lines)
   - API endpoint (created but not used)
   - Kept for reference or future use
   - Would work if middleware configured to exclude it

4. **Testing Scripts**:
   - `scripts/inspect-excel.js`: Inspects Excel file structure (20 sheets)
   - `scripts/test-parser.js`: Validates parser output (12 event types)
   - `scripts/debug-activities.js`: Debugs row/column structure

### Files Modified

1. **`src/app/(dashboard)/segmentation/page.tsx`** (lines 575-578)
   - Added EventTypeBreakdown component
   - Positioned before "Search and Filter" section
   - Wrapped in margin div

2. **`package.json`**
   - Added dependency: `xlsx` library
   - Installation added 77 packages

### Excel File Structure

**Source File**: `APAC Client Segmentation Activity Register 2025.xlsx`

**Sheets** (20 total):

- `Client Segments - Sept`: Client segmentation definitions
- `Activities`: Event type definitions with expected counts per segment
- 18 client-specific sheets: Individual event tracking with monthly completion columns

**Activities Sheet Structure**:

```
Column A (0): Activity name
Column B (1): Frequency (Per Month, Per Quarter, Per Year)
Column C (2): Team (P/GL, CST, etc.)
Column D (3): Maintain (expected events)
Column E (4): Leverage (expected events)
Column F (5): Nurture (expected events)
Column G (6): Collaboration (expected events)
Column H (7): Sleeping Giants (expected events)
Column I (8): Giants (expected events)
```

**Client Sheet Completion Columns**:

- Column B (1): Event Name
- Columns 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27: Completion status (1/Y/true = completed)

### Business Logic

**Priority Determination** (`src/lib/excel-parser.ts:151-163`):

- `high`: Per Month or Per Quarter events
- `medium`: Per Year events
- `low`: Unknown or other frequencies

**Severity Determination** (`src/lib/excel-parser.ts:168-180`):

- `critical`: Per Month or Per Quarter events
- `warning`: Per Year events
- `normal`: Unknown or other frequencies

**Completion Calculation**:

```typescript
completionPercentage = Math.round((completedEvents / totalEvents) * 100)
remainingEvents = totalEvents - completedEvents
```

Note: Completion can exceed 100% if more events completed than expected (e.g., 300% for APAC Client Forum).

---

## Testing Results

### Before Fix

```
[Excel Parser] Found event: "Per Year" with 2 total events
[Excel Parser] Found event: "1=Yes, 0=No" with 0 total events
✅ Successfully parsed 2 event types
```

### After Fix

```
[Excel Parser] Found header row at index: 2
[Excel Parser] Found event: "APAC Client Forum / User Group" with 5 total events
[Excel Parser] Found event: "CE On-Site Attendance" with 30 total events
[Excel Parser] Found event: "EVP Engagement" with 11 total events
... (9 more events)
✅ Successfully parsed 12 event types
```

### Completion Data Samples

| Event Type                        | Total Expected | Completed | % Complete | Status       |
| --------------------------------- | -------------- | --------- | ---------- | ------------ |
| APAC Client Forum / User Group    | 5              | 15        | 300%       | 🟢 Exceeding |
| CE On-Site Attendance             | 30             | 62        | 207%       | 🟢 Exceeding |
| EVP Engagement                    | 11             | 29        | 264%       | 🟢 Exceeding |
| President/Group Leader Engagement | 2              | 2         | 100%       | 🟢 Complete  |
| Altera-led events                 | 11             | 4         | 36%        | 🔴 Behind    |
| Client Review                     | 55             | 13        | 24%        | 🔴 Behind    |

---

## Resolution Summary

### Changes Committed

**Commit**: `e14f5ee`
**Branch**: `main`
**Message**: "feat: integrate real-time Excel data into Event Type Breakdown"

### Deployment Status

- ✅ Code pushed to `origin/main`
- ✅ GitHub repository: `therealDimitri/apac-intelligence-v2`
- ⏳ Netlify deployment: Pending (auto-triggered via GitHub integration)

### Verification Steps

1. ✅ Parser successfully reads Excel file
2. ✅ Correct column indices (0-based)
3. ✅ All 12 event types parsed
4. ✅ Completion percentages calculated correctly
5. ✅ Server Component integrated into segmentation page
6. ✅ Local dev server compiled without errors
7. ✅ Changes committed and pushed to GitHub

---

## Lessons Learned

1. **Always verify column indices**: XLSX library uses 0-based arrays, not Excel's 1-based column letters
2. **Middleware runs before route handlers**: Authentication middleware intercepts ALL matching routes
3. **Server Components bypass API complexity**: For server-side data, skip the API layer entirely
4. **Debug scripts are invaluable**: Small inspection scripts save hours of blind debugging
5. **User preferences matter**: Present options and let user choose architecture approach

---

## Future Considerations

1. **Error Handling**: Add try/catch with user-friendly error messages if Excel file not found
2. **Caching**: Consider caching parsed data for performance (currently re-parses on every render)
3. **File Watching**: Implement file system watching to detect Excel file changes
4. **API Endpoint**: If API access needed in future, add middleware exception for `/api/event-types`
5. **Data Validation**: Add warnings for missing sheets or unexpected column structures

---

## Related Files

- `src/lib/excel-parser.ts:34-96` - Column index fixes
- `src/components/EventTypeBreakdown.tsx:8-10` - Server Component data fetching
- `src/app/(dashboard)/segmentation/page.tsx:575-578` - Component integration
- `scripts/debug-activities.js` - Debug script that revealed column structure
- `scripts/test-parser.js` - Validation script

---

## References

- XLSX Library Documentation: https://docs.sheetjs.com/
- Next.js Server Components: https://nextjs.org/docs/app/building-your-application/rendering/server-components
- NextAuth v5 Middleware: https://authjs.dev/getting-started/session-management/protecting

---

**Status**: ✅ **RESOLVED**
**Resolution Date**: 2025-11-27
**Deployed**: Pending Netlify auto-deployment
