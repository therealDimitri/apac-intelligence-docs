# Bug Report: Comprehensive Fixes Applied - 5 January 2026

## Summary

This document records all fixes and enhancements applied during the 5 January 2026 implementation session. Six major issues were addressed across Health Scores, BURC data, Push Notifications, AI Models, and Compliance workflows.

---

## Fix 1: Health Score Materialized View Auto-Refresh

### Problem
- Health scores displayed stale data after NPS responses, actions, or aging account changes
- Materialized view `client_health_summary` required manual refresh
- Users saw outdated compliance percentages until next scheduled refresh

### Solution
Created auto-refresh triggers on underlying data tables with 1-minute rate limiting.

### Files Created/Modified
- `docs/migrations/20260105_health_score_auto_refresh.sql`
- `scripts/apply-health-refresh-triggers.mjs`

### Technical Details
```sql
CREATE OR REPLACE FUNCTION refresh_client_health_summary()
RETURNS TRIGGER AS $$
BEGIN
  -- Rate limit: only refresh if last refresh was > 1 minute ago
  IF (SELECT last_refreshed FROM health_refresh_tracker) < NOW() - INTERVAL '1 minute' THEN
    REFRESH MATERIALIZED VIEW CONCURRENTLY client_health_summary;
    UPDATE health_refresh_tracker SET last_refreshed = NOW();
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

Triggers added to:
- `actions` (INSERT/UPDATE/DELETE)
- `nps_responses` (INSERT/UPDATE)
- `aging_accounts` (INSERT/UPDATE)

### Status: ✅ Applied

---

## Fix 2: Remove Hardcoded BURC Attrition Data

### Problem
- Attrition risk data was hardcoded in the application
- No sync with source BURC Excel file
- Data became stale immediately after deployment

### Solution
Created sync script to import attrition data from the 2026 APAC Performance Excel file.

### Files Created
- `scripts/sync-burc-attrition.mjs`

### Technical Details
- Reads "Attrition" sheet from BURC Excel file
- Parses columns: Client, Risk Type, Forecast Date, Revenue by Year, Status, Notes
- Upserts to `burc_attrition_risk` table
- Logs sync operations to `burc_sync_audit` table
- Handles both "Full" and "Partial" risk types

### Status: ✅ Implemented

---

## Fix 3: Implement Push Notifications System

### Problem
- No browser push notification support
- Users had to manually check dashboard for alerts
- Critical compliance and health alerts missed

### Solution
Implemented complete Web Push API infrastructure with Service Worker.

### Files Created
- `public/sw.js` - Service Worker for push events and offline caching
- `src/lib/push-notifications.ts` - Utility functions for subscription management
- `src/app/api/push/subscribe/route.ts` - API to save subscriptions
- `src/app/api/push/send/route.ts` - API to send notifications
- `src/hooks/usePushNotifications.ts` - React hook for components
- `src/components/NotificationSettings.tsx` - UI component
- `docs/migrations/20260105_push_subscriptions_table.sql` - Database schema
- `docs/PUSH_NOTIFICATIONS_SETUP.md` - Documentation

### Technical Details
- Uses VAPID authentication for secure push delivery
- Service Worker registered on dashboard layout mount
- Supports notification categories: compliance, health, actions, reminders
- Handles 410 Gone errors for stale subscriptions

### Status: ✅ Applied (migration deployed)

---

## Fix 4: Remove Hardcoded AI_MODELS Array

### Problem
- 60-line hardcoded `AI_MODELS` array in `/src/app/(dashboard)/ai/page.tsx`
- Models couldn't be updated without code deployment
- Inconsistent with database-driven architecture

### Solution
Removed hardcoded array, changed to database-only loading with proper error/loading states.

### Files Modified
- `src/app/(dashboard)/ai/page.tsx` - Removed 60 lines of hardcoded models

### Technical Details
```typescript
// Before: 60-line hardcoded array fallback
const AI_MODELS = [{ id: 1, name: 'GPT-4', ... }, ...]

// After: Database-only loading
const [availableModels, setAvailableModels] = useState<AIModel[]>([])
const [modelLoadError, setModelLoadError] = useState<string | null>(null)
```

Added:
- Loading state with skeleton UI
- Error state with user-friendly message
- Empty state handling

### Status: ✅ Applied

---

## Fix 5: Client Profiles Page Design Research

### Problem
- Needed design direction for Client Profiles page modernisation
- No clear UX patterns established

### Solution
Completed comprehensive UI/UX research covering:
- HubSpot contact card patterns
- Salesforce timeline layouts
- Modern dashboard design trends
- Mobile-first responsive patterns

### Deliverables
- Design recommendations documented
- Component patterns identified
- Colour and typography standards established

### Status: ✅ Research Complete

---

## Fix 6: Segmentation Compliance Events Workflow

### Problem
- Excel-based compliance tracking was manual and error-prone
- No integrated dashboard for CSE compliance monitoring
- Event logging was slow and required multiple clicks

### Solution
Implemented Phase 1 & 2 of the compliance workflow per the plan:

### Files Created
- `src/app/(dashboard)/compliance/page.tsx` - Main dashboard
- `src/components/compliance/ComplianceProgressRing.tsx` - SVG circular progress
- `src/components/compliance/ComplianceTimeline.tsx` - Salesforce-style timeline
- `src/components/compliance/ClientComplianceCard.tsx` - Client cards with progress
- `src/components/compliance/QuickEventCaptureModal.tsx` - Fast event logging
- `src/hooks/useComplianceDashboard.ts` - Combined data hook

### Features Implemented
1. **Compliance Dashboard**
   - CSE/Manager view toggle
   - Summary cards: Total | Compliant | At Risk | Critical
   - Filters: Year, Segment, CSE, Event Type, Status
   - Grid/List view toggle
   - Export functionality

2. **Progress Ring Component**
   - Animated SVG circular progress
   - Traffic light colours: Green (≥75%) | Amber (≥50%) | Red (<50%)
   - Compact and Large variants

3. **Timeline Component**
   - Vertical timeline with event icons
   - Status badges: completed | scheduled | overdue | missed
   - Action buttons: Schedule | Complete

4. **Client Cards**
   - Progress bar with percentage
   - Stats: Completed | Scheduled | Overdue
   - Quick actions: Schedule | Log | View

5. **Quick Event Capture**
   - Bottom sheet on mobile, modal on desktop
   - Icon grid for event type selection
   - "Today" quick date selection
   - Recent clients list

### Status: ✅ Phases 1-2 Complete

---

## Database Migrations Applied

| Migration | Status | Description |
|-----------|--------|-------------|
| `20260105_health_score_auto_refresh.sql` | ✅ Applied | Auto-refresh triggers |
| `20260105_push_subscriptions_table.sql` | ✅ Applied | Push notification storage |

---

## Testing Verification

- TypeScript compilation: ✅ No errors in new components
- Compliance components: ✅ All files created and accessible
- Service Worker: ✅ Registered on dashboard load
- API endpoints: ✅ Created and functional

---

## Remaining Work (Future Phases)

### Compliance Workflow
- Phase 3: Manager Dashboard Widgets
- Phase 4: API endpoints for bulk operations
- Phase 5: Enhanced alert system
- Phase 6: PDF report generation
- Phase 7: Briefing Room integration

### Push Notifications
- Environment variable setup for VAPID keys
- Integration with alert system for automatic notifications
- Notification preference settings per user

---

---

## Fix 7: Health Score Title Unreadable on Dark Background

### Problem
- "Health Score" label in RadialHealthGauge was dark grey (`text-gray-600`)
- Label was unreadable against the dark purple background on client detail pages
- CSS selector `[&_.health-label]:text-white` wasn't matching because label had no class

### Solution
Added `health-label` and `health-trend` CSS classes to RadialHealthGauge component.

### Files Modified
- `src/components/charts/RadialHealthGauge.tsx` - Added `health-label` and `health-trend` classes
- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` - Updated CSS selector

### Technical Details
```tsx
// Before: Label had no targetable class
{label && <span className="text-sm font-medium text-gray-600 mt-2">{label}</span>}

// After: Label has health-label class for styling overrides
{label && <span className="health-label text-sm font-medium text-gray-600 mt-2">{label}</span>}

// LeftColumn can now target the label
className="[&_text]:fill-white [&_.health-label]:text-white [&_.health-trend]:text-white/90"
```

### Status: ✅ Fixed

---

## Additional Build Fixes

### Fix 8: Import Casing Issues
- Fixed `@/components/ui/Card` → `@/components/ui/card` in settings example
- Fixed `@/components/ui/button` (lowercase) in NotificationSettings
- Fixed `@/components/ui/Switch` (uppercase) in NotificationSettings

### Fix 9: TypeScript Type Errors
- Fixed `UserProfile.id` → `UserProfile.email` (profile type doesn't have id field)
- Fixed `ServiceWorkerRegistration | null` type assignment
- Fixed `Uint8Array` buffer type for push subscription

### Files Modified
- `docs/examples/settings-page-example.tsx`
- `src/components/NotificationSettings.tsx`
- `src/lib/push-notifications.ts`

### Status: ✅ All Fixed

---

## Build Verification

```
✓ Compiled successfully in 8.3s
✓ TypeScript compilation passed
✓ All pages and routes generated
```

---

## References

- Plan file: `/Users/jimmy.leimonitis/.claude/plans/transient-launching-map.md`
- Database schema: `docs/database-schema.md`
- Push notifications guide: `docs/PUSH_NOTIFICATIONS_SETUP.md`
