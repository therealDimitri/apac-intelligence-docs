# Enhancement Report: Strategic Planning UX Improvements

**Date:** 12 January 2026
**Status:** Resolved
**Type:** Bug Fixes & Enhancements
**Severity:** Medium

## Summary

Multiple UX improvements and bug fixes implemented for the Strategic Planning workflow, including ChaSen AI Coach redesign, pipeline opportunity management, and Planning Hub integration.

## Issues Addressed

### 1. ChaSen Generate Draft UI/UX Redesign
**Reported Behaviour:**
- Generated draft content was hard to read in the sidebar panel
- Small text with poor visual hierarchy
- No way to view full content comfortably

**Resolution:**
- Redesigned response panel with improved typography (prose-base with relaxed line height)
- Added scrollable container with max-height of 400px
- Added fullscreen/expanded view option with modal overlay
- Improved visual hierarchy with better headings and spacing
- Added header with copy and expand buttons
- Added scroll indicator for long content
- Fullscreen mode includes keyboard shortcut (Esc) to close

### 2. Add New Pipeline Opportunity Feature
**Reported Behaviour:**
- Users could only select from existing pipeline opportunities
- No way to add custom opportunities not in the system

**Resolution:**
- Added "Add New" button next to pipeline opportunities header
- Created inline form for new opportunity creation with fields:
  - Opportunity Name (required)
  - Client (dropdown from portfolio, required)
  - ACV (required)
  - Stage (auto-sets probability)
  - Probability (editable)
  - Expected Close Date
- Auto-selects new opportunity when added
- Calculates weighted ACV automatically
- Shows toast confirmation on success

### 3. Opportunities Card Text Cutoff
**Reported Behaviour:**
- Long opportunity names were cutting off without indication

**Resolution:**
- Added `truncate` class for proper text truncation
- Added `min-w-0` and `flex-1` for proper flex container sizing
- Added `title` attribute for hover tooltip showing full text

### 4. Submit for Review Button Not Working
**Reported Behaviour:**
- Button remained disabled even when form appeared complete
- Progress threshold too high at 80%
- Pre-selected opportunities not syncing to formData

**Resolution:**
- Lowered progress threshold from 80% to 60%
- Added sync of pre-selected opportunities (focus deals/BURC) to formData on portfolio load

### 5. Financial Decimal Places
**Reported Behaviour:**
- Financial values displayed with decimal places (e.g., $1,234,567.89)

**Resolution:**
- Added `Math.round()` to all financial displays in summary cards
- Values now display as whole numbers (e.g., $1,234,568)

### 6. ACV Target Label Rename
**Reported Behaviour:**
- Column labeled "ACV Target" was actually showing weighted values

**Resolution:**
- Renamed "ACV Target" to "Weighted ACV" in Portfolio Clients table
- Renamed "FY26 ACV Target" to "FY26 Weighted ACV Target" in summary card

### 7. Plans Not Showing in Planning Hub
**Reported Behaviour:**
- Newly created strategic plans were not appearing in Planning Hub
- Plans saved to `strategic_plans` table but Hub queried different tables

**Resolution:**
- Added query to `strategic_plans` table in Planning Hub
- Created `StrategicPlan` interface to match table schema
- Updated `allPlans` calculation to include strategic plans
- Updated delete handler to check all plan tables

## Files Modified

### AIInsightsPanel.tsx
- Added `useRef`, `useEffect`, `Maximize2`, `Minimize2` imports
- Added `isFullscreen` state and `contentRef`
- Added escape key handler for fullscreen
- Redesigned response display with:
  - Sticky header with gradient background
  - Scrollable content area with improved typography
  - Suggestions section with numbered items
  - Scroll indicator footer
  - Fullscreen modal with larger typography

### strategic/new/page.tsx
- Added `showNewOppForm` and `newOpp` state for new opportunity form
- Added "Add New" button to pipeline opportunities section
- Added inline form for creating new opportunities
- Added auto-probability setting based on stage
- Fixed text truncation with proper flex container classes
- Added sync of pre-selected opportunities to formData
- Lowered Submit for Review threshold to 60%
- Added `Math.round()` to financial displays
- Renamed ACV Target labels

### planning/page.tsx
- Added `StrategicPlan` interface
- Added `strategicPlans` state
- Added query to `strategic_plans` table
- Updated `allPlans` to include strategic plans with transformed format
- Updated delete handler for strategic plans

## Testing Performed

- [x] Build passes with zero TypeScript errors
- [x] ChaSen Generate Draft displays with improved readability
- [x] Fullscreen modal opens/closes correctly (button and Esc key)
- [x] Add New Opportunity form validates required fields
- [x] New opportunities added to list and auto-selected
- [x] Text truncation works with hover tooltip
- [x] Submit for Review enables at 60% progress
- [x] Financial values display without decimals
- [x] Strategic plans appear in Planning Hub
- [x] Plans can be deleted from Planning Hub

## Stage Probability Mapping

When adding new opportunities, the stage automatically sets probability:
- Discovery: 10%
- Qualification: 20%
- Proposal: 40%
- Negotiation: 60%
- Commit: 80%
- Closed Won: 100%

## Prevention

- UX improvements should be tested across different content lengths
- Form submissions should always sync all related state
- Database queries should be verified against actual table schemas
- Labels should accurately reflect the data being displayed
