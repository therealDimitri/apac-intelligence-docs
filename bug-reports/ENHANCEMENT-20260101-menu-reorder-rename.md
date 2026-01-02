# Enhancement: Menu Reorder and BURC Rename

**Date:** 1 January 2026
**Status:** Completed
**Type:** UI/UX Enhancement
**Component:** Sidebar Navigation, BURC Performance Page

## Summary

Renamed "BURC Financials" to "BURC Performance" and reorganised the sidebar navigation to follow a more logical workflow.

## Changes Made

### 1. Sidebar Navigation Reorder

**Previous Order:**
1. Command Centre
2. BURC Financials
3. Client Profiles
4. NPS Analytics
5. Working Capital
6. Briefing Room
7. Actions & Tasks
8. ChaSen AI
9. Guides & Resources

**New Order:**
1. Command Centre (Dashboard home)
2. Client Profiles (Core client data)
3. Briefing Room (Meetings)
4. Actions & Tasks (Follow-up items)
5. NPS Analytics (Client feedback)
6. BURC Performance (Financial tracking)
7. Working Capital (Aging accounts)
8. ChaSen AI (AI assistant)
9. Guides & Resources (Documentation)

**Rationale:**
- Workflow-based ordering: View clients → Attend meetings → Track actions → Review feedback
- Core daily activities (Clients, Meetings, Actions) are now more prominent
- Financial modules (BURC, Working Capital) grouped together
- Support functions (AI, Guides) at the bottom

### 2. BURC Rename

| Location | Before | After |
|----------|--------|-------|
| Sidebar menu | BURC Financials | BURC Performance |
| Page title | BURC Financials | BURC Performance |
| Page subtitle | BURC-aligned revenue intelligence and action tracking | Revenue intelligence, CSI ratios, and financial tracking |
| PDF export title | BURC Financial Report | BURC Performance Report |
| PDF footer | BURC Financial Report | BURC Performance Report |

## Files Modified

### `src/components/layout/sidebar.tsx`
- Reordered navigation array
- Renamed menu item from "BURC Financials" to "BURC Performance"
- Moved hidden/commented items to end of array for cleaner code

### `src/app/(dashboard)/financials/page.tsx`
- Updated page title to "BURC Performance"
- Updated page subtitle
- Updated PDF export title and footer text

## Testing

1. Navigate to any page and verify sidebar menu order
2. Click "BURC Performance" and verify:
   - Page title shows "BURC Performance"
   - Subtitle shows updated text
3. Click "Export Report" and verify:
   - PDF title is "BURC Performance Report"
   - Footer includes "BURC Performance Report"

## Related Documentation

- Bug report for PDF export: `BUG-REPORT-20260101-burc-export-pdf.md`
