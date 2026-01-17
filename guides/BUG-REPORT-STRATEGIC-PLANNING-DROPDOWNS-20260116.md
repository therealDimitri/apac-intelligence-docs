# Bug Report: Strategic Planning Wizard - Client Dropdowns & Related Issues

**Date**: 16 January 2026
**Status**: Partially Resolved
**Severity**: High
**Reporter**: User
**Investigator**: Claude

---

## Executive Summary

Multiple bugs were reported in the Strategic Planning wizard relating to empty dropdowns and missing functionality. Root cause analysis revealed these issues stem from two distinct causes:

1. **Data Configuration**: Client-to-CSE assignments in the database
2. **Code Regression**: MS Graph owner search was missing from Actions step

---

## Bugs Reported

| # | Bug Description | Root Cause | Status |
|---|-----------------|------------|--------|
| 1 | Client dropdown not displaying in Stakeholder Intelligence | Data - No clients assigned to selected CSE | Explained |
| 2 | Client Gap Diagnosis not showing clients | Data - No clients assigned to selected CSE | Explained |
| 3 | Risks client dropdown not using display names | Not a bug - display_name is used correctly | Verified |
| 4 | Pipeline Opportunity dropdown empty | Data - No pipeline for selected CSE | Explained |
| 5 | Risk Overview summary not at top | Not a bug - already at top in code | Verified |
| 6 | Add Your First Risk button not working | Works, but client dropdown is empty | Explained |
| 7 | Actions owner MS Graph search missing | Code regression | **FIXED** |
| 8 | Actions client dropdown broken | Data - Empty portfolio | Explained |

---

## Root Cause Analysis

### Issue 1: Empty Client Dropdowns (Bugs 1, 2, 4, 6, 8)

**Root Cause**: The Strategic Planning wizard loads clients based on the selected CSE owner. Only CSEs with `cse_name` assignments in the `clients` table will have portfolio data.

**Current CSE Assignments** (as of 16 Jan 2026):

| CSE Name | Clients Assigned | Pipeline Opportunities |
|----------|------------------|----------------------|
| John Salisbury | 5 | 11 |
| Laura Messing | 4 | 19 |
| Open Role | 13 | 21 |
| Tracey Bland | 5 | 36 |
| **All other profiles** | **0** | **0** |

**Impact**: When users select an owner who has no clients assigned (e.g., Kenny Gan, Dimitri Leimonitis), all client-related dropdowns will be empty.

**Data Flow**:
```
1. User selects CSE owner in Setup step
2. loadPortfolioForOwner(ownerName) queries:
   - clients table WHERE cse_name = ownerName
   - sales_pipeline_opportunities WHERE cse_name = ownerName
3. If no matches, formData.portfolio = []
4. All step components receive empty portfolio prop
5. All client dropdowns render with no options
```

**Code Location**: `src/app/(dashboard)/planning/strategic/new/page.tsx:1321-1700`

### Issue 2: MS Graph Owner Search Missing (Bug 7)

**Root Cause**: The Actions step (`ActionNarrativeStep.tsx`) was using a plain text input for the owner field instead of the `PeopleSearchInput` component.

**Before (broken)**:
```tsx
<input
  type="text"
  placeholder="Owner (required)"
  value={newAction.owner || ownerName || ''}
  onChange={e => setNewAction(prev => ({ ...prev, owner: e.target.value }))}
/>
```

**After (fixed)**:
```tsx
<PeopleSearchInput
  value={newAction.owner ? newAction.owner.split('; ').filter(Boolean) : ownerName ? [ownerName] : []}
  onChange={owners => setNewAction(prev => ({ ...prev, owner: owners.join('; ') }))}
  placeholder="Search for people in your organisation..."
  hideHelpText
/>
```

**File**: `src/app/(dashboard)/planning/strategic/new/steps/ActionNarrativeStep.tsx:410-426`

### Issue 3: Display Names (Bug 3)

**Not a Bug**: The code correctly uses `display_name` from the clients table.

**Evidence**:
```javascript
// In loadClients() - line 1173
client_name: client.display_name || client.canonical_name

// Sample data from database:
Canonical: "Barwon Health Australia" → Display: "Barwon Health"
Canonical: "Gippsland Health Alliance (GHA)" → Display: "GHA"
Canonical: "KK Women's and Children's Hospital" → Display: "KK Women's Hospital"
```

### Issue 4: Risk Overview Position (Bug 5)

**Not a Bug**: The Risk Overview section is already positioned at the top of the card.

**Code Location**: `src/app/(dashboard)/planning/strategic/new/steps/RiskRecoveryStep.tsx:317-369`

---

## Fixes Applied

### 1. MS Graph Owner Search in Actions

**File**: `src/app/(dashboard)/planning/strategic/new/steps/ActionNarrativeStep.tsx`

**Changes**:
- Added import for `PeopleSearchInput` component
- Replaced plain text input with `PeopleSearchInput`
- Uses semicolon delimiter for multiple owners (compatible with Azure AD "Last, First" format)

**Commit**: (pending)

---

## Recommended Actions

### For Data Issues

The empty dropdown issues are not code bugs but data configuration requirements. To ensure a CSE can use the Strategic Planning wizard:

1. **Assign clients to CSE in database**:
   ```sql
   UPDATE clients
   SET cse_name = 'CSE Full Name'
   WHERE canonical_name IN ('Client 1', 'Client 2', ...);
   ```

2. **Verify pipeline assignments**:
   ```sql
   SELECT cse_name, COUNT(*) as opp_count
   FROM sales_pipeline_opportunities
   WHERE in_or_out = 'In'
   GROUP BY cse_name;
   ```

### For Future Prevention

1. **Add empty state messaging**: When portfolio is empty, show a helpful message instead of just empty dropdowns
2. **Allow manual client entry**: Consider allowing users to type client names if portfolio is empty
3. **Validate CSE assignments**: Add an admin tool to review and manage CSE-to-client assignments

---

## Files Investigated

| File | Purpose |
|------|---------|
| `src/app/(dashboard)/planning/strategic/new/page.tsx` | Main wizard page, portfolio loading |
| `src/app/(dashboard)/planning/strategic/new/steps/StakeholderIntelligenceStep.tsx` | Stakeholder step with client dropdown |
| `src/app/(dashboard)/planning/strategic/new/steps/DiscoveryDiagnosisStep.tsx` | Client Gap Diagnosis |
| `src/app/(dashboard)/planning/strategic/new/steps/RiskRecoveryStep.tsx` | Risks with client/opportunity dropdowns |
| `src/app/(dashboard)/planning/strategic/new/steps/ActionNarrativeStep.tsx` | Actions with owner field |
| `src/components/PeopleSearchInput.tsx` | MS Graph people search component |

---

## Why Issues Keep Reappearing

The user expressed frustration that issues keep reappearing. Analysis reveals:

1. **Data vs Code confusion**: Most "bugs" are actually data configuration issues that appear as broken UI
2. **CSE assignment gaps**: The database has incomplete CSE assignments for many profiles
3. **No validation feedback**: The UI doesn't clearly indicate when data is missing vs when there's a bug

**Recommendation**: Add explicit "No clients found for this owner" messaging with a link to request client assignments.

---

---

## Submit for Review Workflow Documentation

### Overview

When a user clicks "Submit for Review", the plan transitions from `draft` to `in_review` status.

### Workflow Steps

```
1. User completes plan (minimum 50% completion required)
2. User clicks "Submit for Review" button
3. Plan status changes: draft → in_review
4. System comment is added to plan
5. User is redirected to /planning page
6. Reviewer can approve or reject the plan
```

### Status Transitions

| From Status | Action | To Status |
|-------------|--------|-----------|
| draft | Submit | in_review |
| in_review | Approve | approved |
| in_review | Reject | draft (with rejection reason) |

### Who Reviews Plans?

Currently, there is **no automatic reviewer assignment**. The workflow supports:
- Any user with access can view plans with `in_review` status
- The `/planning` page shows plans awaiting review
- The Approve API (`POST /api/planning/strategic/[id]/approve`) requires:
  - `approved_by`: Name of the approver
  - `action`: Either `'approve'` or `'reject'`
  - `rejection_reason`: Required if rejecting

### Notifications

**Current State**: No automatic notifications are sent when a plan is submitted or approved.

**Recommended Enhancement**: Add email notifications to:
- Notify manager/director when plan is submitted
- Notify plan owner when plan is approved/rejected

### API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/planning/strategic/[id]/submit` | POST | Submit plan for review |
| `/api/planning/strategic/[id]/approve` | POST | Approve or reject plan |

### Activity Logging

All actions are logged in:
1. `strategic_plans.activity_log` JSON field
2. `plan_activity_log` table (if exists)
3. `plan_comments` table (as system comments)

---

## Related Documentation

- [MS Graph Owner Integration](./BUG-REPORT-20251230-owners-ms-graph-integration.md)
- [Client Dropdown Actions](../features/FEATURE-CLIENT-DROPDOWN-ACTIONS.md)
- [Semicolon Delimiter Fix](./BUG-FIX-action-owner-comma-parsing.md)
