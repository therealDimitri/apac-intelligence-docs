# Bug Fix Report: UI Improvements - Notifications, Swimlane Sizing, and Label Formatting

**Date:** 5 January 2026
**Status:** Fixed
**Type:** UI/UX Improvements

## Issues Reported

### Issue 1: Browser Notification Pop-ups
**Report:** Review all notifications across the dashboard and convert browser notification pop-ups to in-app versions.

**Finding:** Upon investigation, the application already uses in-app notifications properly:
- `NotificationModal` - styled toast notification positioned at bottom-right with auto-dismiss
- `toast` from Sonner library - inline toast notifications with rich colours
- `NotificationBell` - persistent notification dropdown in the header
- Push notifications use Service Workers correctly (in `sw.js`)

**Result:** No browser `Notification()` API calls found in user-facing code. The notification system is already correctly implemented as in-app notifications. **No changes required.**

---

### Issue 2: Swimlane View Card Sizes
**Report:** Swimlane view cards not utilising enough display space.

**Root Cause:** StatusColumn components had constrained width limits (`min-w-[180px] max-w-[280px]`) and minimal padding.

**Files Modified:**
- `src/components/priority-matrix/views/SwimlaneKanban.tsx`

**Changes Applied:**

| Component | Before | After |
|-----------|--------|-------|
| StatusColumn width | `min-w-[180px] max-w-[280px]` | `min-w-[240px] max-w-[400px]` |
| Column content padding | `space-y-2 min-h-[100px] p-2` | `space-y-2.5 min-h-[120px] p-3` |
| KanbanCard padding (compact) | `p-2` | `p-2.5` |
| KanbanCard padding (comfortable) | `p-3` | `p-4` |
| Card content left padding (compact) | `pl-4` | `pl-5` |
| Card content left padding (comfortable) | `pl-5` | `pl-6` |

---

### Issue 3: Underscore-Separated Category Labels
**Report:** Some actions display `client_retention` and `client_success` with underscores instead of readable format.

**Root Cause:** Multiple components used `replace('_', ' ')` which only replaces the **first** underscore, not all occurrences.

**Files Modified (10 files):**

| File | Line | Original | Fixed |
|------|------|----------|-------|
| `src/components/FinancialActionsWidget.tsx` | 309 | `team.replace('_', ' ')` | `team.replace(/_/g, ' ')` |
| `src/app/(dashboard)/aging-accounts/compliance/components/WriteOffAnalysis.tsx` | 427 | `record.category.replace('_', ' ')` | `record.category.replace(/_/g, ' ')` |
| `src/app/(dashboard)/actions/inbox/page.tsx` | 57 | `status.replace('_', ' ')` | `status.replace(/_/g, ' ')` |
| `src/components/insights/InsightCard.tsx` | 371 | `insight.category.replace('_', ' ')` | `insight.category.replace(/_/g, ' ')` |
| `src/components/insights/InsightContextMenu.tsx` | 178 | `insight.category.replace('_', ' ')` | `insight.category.replace(/_/g, ' ')` |
| `src/components/insights/EmptyState.tsx` | 119 | `activeCategory.replace('_', ' ')` | `activeCategory.replace(/_/g, ' ')` |
| `src/components/financial-analytics/CostAnalysisPanel.tsx` | 331 | `service.replace('_', ' ')` | `service.replace(/_/g, ' ')` |
| `src/components/unified-actions/ActionProvider.tsx` | 460 | `status.replace('_', ' ')` | `status.replace(/_/g, ' ')` |
| `src/components/dashboard/DataInsightsWidgets.tsx` | 178 | `initiative.status.replace('_', ' ')` | `initiative.status.replace(/_/g, ' ')` |
| `src/components/burc/BURCDrillDown.tsx` | 161 | `item.status.replace('_', ' ')` | `item.status.replace(/_/g, ' ')` |

**Technical Note:** The fix changes from `String.replace()` with a string argument (replaces first match only) to `String.replace()` with a regex using the global flag `/g` (replaces all matches).

**Example:**
- Before: `"client_success_initiative".replace('_', ' ')` → `"client success_initiative"`
- After: `"client_success_initiative".replace(/_/g, ' ')` → `"client success initiative"`

---

## Verification

- TypeScript compilation: **Passes with no errors**
- All changes preserve existing functionality
- Labels now display in readable format with proper word spacing

## Categories Affected

The following underscore-separated values are now properly formatted when displayed:

**Team Labels:**
- `client_success` → "Client Success"
- `internal_ops` → "Internal Ops"

**Status Labels:**
- `in_progress` → "In Progress"
- `on_hold` → "On Hold"
- `at_risk` → "At Risk"

**Category Labels:**
- `declining_metric` → "Declining Metric"
- `data_quality` → "Data Quality"
- `bad_debt` → "Bad Debt"

---

## Summary

| Issue | Status | Action Taken |
|-------|--------|--------------|
| Browser notifications | Already in-app | No changes required |
| Swimlane card sizing | Fixed | Increased column widths and card padding |
| Underscore labels | Fixed | Updated 10 files to use global regex replace |
