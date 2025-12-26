# Open Tasks & TODOs

**Last Updated**: 2025-12-17

This document tracks all open tasks, pending features, and documented TODOs found in the codebase.

---

## 🔴 High Priority

_No high priority tasks at this time._

---

## 🟡 Medium Priority

### 2. ChaSen AI Testing & Training

**Tasks**:

- Test ChaSen queries with real user scenarios
- Train CS team on new query capabilities
- Create ChaSen query cheat sheet for team
- Test compliance queries after cache expiry
- Verify Segmentation page compliance scores

**Context**: New ChaSen AI features need validation and user training
**Status**: Pending user testing

### 3. Client Name Variations Testing

**Description**: Test ChaSen with all client name variations in production
**Context**: Ensure AI can handle different ways users refer to clients
**Examples**: "Hunter New England" vs "HNE" vs "Hunter"
**Status**: Pending production testing

### ~~4. Session Management Improvements~~ ✅

**Tasks**:

- ~~Add session expiration detection in frontend~~ ✅
- ~~Improve error messages to differentiate auth vs API vs code errors~~ ✅

**Context**: Better user experience when sessions expire or errors occur
**Status**: Completed (2025-12-17)

---

## 🟢 Low Priority / Future Enhancements

### 5. QuickActionsFooter Implementations

**Location**: Various client detail page components
**Features to Implement**:

- ~~Schedule meeting integration~~ ✅ Completed
- Email client integration
- Create action/task from page
- ~~Export client data~~ ✅ Completed (CSV export in Priority Matrix)

**Status**: Partially complete

### 6. Various UI/UX Improvements

- Enhanced loading states
- Better mobile responsiveness
- Accessibility improvements
- Dark mode support (Settings page placeholder)

**Status**: Backlog

---

## ✅ Recently Completed

### Toast Notification System

**Date**: 2025-12-17
**Location**: `src/components/ui/toast-provider.tsx`, `src/lib/toast.ts`
**Implementation**: Added sonner toast library with:

- ToastProvider component in root layout
- Toast utility with success, error, warning, info methods
- Helper functions: `showClipboardToast`, `showApiResultToast`, `showConfirmationToast`
- Replaced all `alert()` calls with toast notifications across:
  - Meetings page (delete, bulk actions)
  - Actions page (status updates)
  - AI page (export, clipboard)
  - NPS page (export)
  - Client detail pages (share, export)

### CenterColumn Dropdown Menu

**Date**: 2025-12-17
**Location**: `src/app/(dashboard)/clients/[clientId]/components/v2/CenterColumn.tsx`
**Implementation**: Added dropdown menu for timeline items with:

- Edit action/meeting
- Copy details to clipboard
- Open in Outlook Calendar (for meetings)
- Mark as complete
- Delete item
- Click-outside to close behaviour

### QuickActionsFooter Improvements

**Date**: 2025-12-17
**Location**: `src/app/(dashboard)/clients/[clientId]/components/QuickActionsFooter.tsx`
**Implementation**: Replaced placeholder alerts with functional actions:

- Call: Opens Teams call with CSE email
- Message: Opens Teams chat
- Schedule: Opens Outlook Calendar
- Create Action: Navigates to actions page with client pre-selected
- Add Note: Shows "coming soon" toast (TODO for future)

### Session Management Improvements

**Date**: 2025-12-17
**Location**: `src/lib/session-manager.ts`, `src/hooks/useApiError.ts`
**Implementation**: Created client-side session management utilities:

- Error type differentiation (auth, api, network, validation, unknown)
- Automatic session expiration detection with sign-out redirect
- `fetchWithSession` wrapper for API calls with session handling
- `useApiError` hook for React components
- User-friendly error messages per error type
- `ApiError` class for structured error handling

### Client Stakeholders Integration

**Date**: 2025-12-17 (previously completed)
**Location**: `src/hooks/useClientContacts.ts`, `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`
**Implementation**: Stakeholders are pulled from `nps_responses` table via `useClientContacts` hook. Displays contact name, role, email, and last contact date in the Team tab. Includes Add Contact modal for adding new stakeholders.

### Topic Extraction Background Classification

**Date**: 2025-12-17
**Location**: `src/lib/topic-extraction.ts`, `src/app/api/topics/classify-background/route.ts`
**Implementation**: Created background API endpoint that triggers topic classification for uncached NPS responses. Now returns cached results immediately while queuing missing classifications.

### NPS Period Configuration Database Table

**Date**: 2025-12-17
**Location**: `docs/migrations/20251217_create_nps_period_config_table.sql`
**Implementation**: Created `nps_period_config` table to store survey periods (2023, Q2 24, Q4 24, Q2 25, Q4 25) with metadata including surveys_sent counts, date ranges, and fiscal year info. Replaces hardcoded period definitions.

### Portfolio Initiatives Database Table

**Date**: 2025-12-17
**Location**: `docs/migrations/20251216_create_portfolio_initiatives_table.sql`
**Implementation**: Created `portfolio_initiatives` table to track client initiatives with status, category, dates, and descriptions. Connected via `usePortfolioInitiatives` hook.

### Meeting File Upload to Supabase Storage

**Date**: 2025-12-17
**Location**: `src/app/api/meetings/upload-file/route.ts`, `src/components/EditMeetingModal.tsx`
**Implementation**: Created file upload API for meeting transcripts and recordings. Uploads to Supabase Storage buckets with signed URLs. Supports TXT/PDF/DOCX for transcripts, MP4/MOV/AVI/WebM for recordings.

### Priority Matrix CSV Export

**Date**: 2025-12-17
**Location**: `src/components/priority-matrix/PriorityMatrix.tsx`
**Implementation**: Enhanced `handleExport` function with proper CSV escaping, BOM for Excel UTF-8 compatibility, and additional columns (Tags, Impact, Confidence).

### Smart Meeting Recommendations Modal

**Date**: 2025-12-17
**Location**: `src/components/MeetingRecommendations.tsx`
**Implementation**: Connected "Schedule Meeting" buttons to `QuickScheduleMeetingModal` with pre-filled client name, meeting type mapping (Check-in→health_check_opal, QBR→qbr, Escalation→escalation, Planning→strategic_ops_plan_review), and priority.

### Client Detail Page Navigation

**Date**: 2025-12-17
**Location**: `src/app/(dashboard)/clients/page.tsx`
**Implementation**: Added navigation from client list to `/clients/{id}/v2`. Client names are now clickable, and "View Full Profile" button in modal navigates to detail page.

### CSE Job Title Sync Feature (Removed)

**Date**: 2025-12-02
**Decision**: Removed feature entirely due to Azure AD permission limitations
**Reason**: Required `User.Read.All` delegated permission which won't be granted
**Solution**: Use Supabase `cse_profiles` table as source of truth for job titles

### Email Address Corrections

**Date**: 2025-12-02
**Fixed**:

- Dominic Wilson-Ing: `dominic.wilsoning@` → `dominic.wilson-ing@alterahealth.com`
- Jonathan Salisbury: `jonathan.salisbury@` → `john.salisbury@alterahealth.com`

### Microsoft Graph User Lookup Improvements

**Date**: 2025-12-02
**Enhancement**: Implemented dual-strategy user lookup
**Results**: Reduced user lookup failures from 15 to 1
**Method**: Try direct `/users/{email}` first, fallback to `/me/people`

---

## 📊 Priority Summary

- **High Priority**: 0 tasks
- **Medium Priority**: 2 task groups (testing/training)
- **Low Priority**: 2 feature areas
- **Total Open**: 4 items
- **Recently Completed**: 12 items (2025-12-17)

---

## 🔍 Search Tips

To find TODOs in codebase:

```bash
# Search for TODO comments
grep -r "TODO" --include="*.ts" --include="*.tsx" src/

# Search for FIXME comments
grep -r "FIXME" --include="*.ts" --include="*.tsx" src/

# Search for task checklists in docs
grep -r "- \[ \]" docs/
```

---

## 📝 Notes

- All high-priority items are code TODOs found in active source files
- Medium-priority items are primarily testing/validation tasks
- Low-priority items are future enhancements without blocking impact
- The CSE profiles table in Supabase is the authoritative source for CS team job titles
- Settings page is currently a placeholder ("Coming Soon")
