# Bug Report: Insights Tab Event Compliance List Truncated

**Date**: 2025-12-19
**Status**: RESOLVED
**Severity**: Medium
**Component**: Client Profile - Insights Tab - Event Compliance Section

---

## Issue Summary

The Insights tab in the client profile page was displaying only 5 event compliance items, while the full Compliance Details modal showed all 9 event types. This caused a data mismatch between the two views.

## Symptoms

- Insights tab showed only 5 events:
  - EVP Engagement (1 of 1)
  - Strategic Ops Plan (2 of 2)
  - CE On-Site Attendance (2 of 2)
  - Upcoming Release Planning (2 of 2)
  - Insight Touch Point (12 of 12)

- Compliance Details modal showed all 9 events including:
  - APAC Client Forum (1 of 1)
  - SLA/Service Review Meeting (5 of 4)
  - Updating Client 360 (11 of 8)
  - Whitespace Demos (3 of 2)

## Root Cause

The Event Compliance section in `RightColumn.tsx` was using `.slice(0, 5)` to limit the displayed events:

```typescript
// BEFORE: Line 1222
{compliance.event_compliance.slice(0, 5).map((ec, idx) => {
```

This was likely added to keep the sidebar compact, but it caused inconsistency with the modal which displayed all events.

## Solution

Removed the `.slice(0, 5)` limitation to display all event types:

```typescript
// AFTER: Line 1222
{compliance.event_compliance.map((ec, idx) => {
```

## File Modified

`src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`

## Impact

- Insights tab now shows all event compliance types (matching the modal)
- Users can see complete compliance picture without opening the modal
- Event completion counts now reconcile between views

## Verification

After fix, the Insights tab displays all 9 event types for Te Whatu Ora Waikato:

- EVP Engagement: 1 of 1 (100%)
- Strategic Ops Plan: 2 of 2 (100%)
- CE On-Site Attendance: 2 of 2 (100%)
- Upcoming Release Planning: 2 of 2 (100%)
- Insight Touch Point: 12 of 12 (100%)
- APAC Client Forum: 1 of 1 (100%)
- SLA/Service Review Meeting: 5 of 4 (125%)
- Updating Client 360: 11 of 8 (138%)
- Whitespace Demos: 3 of 2 (150%)

---

## Lessons Learned

1. **UI consistency** - Truncated lists should have clear "Show More" indicators
2. **Data reconciliation** - Summary views should match detailed views
3. **Code review** - Arbitrary limits like `.slice(0, 5)` should be documented with rationale
