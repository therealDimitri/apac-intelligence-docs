# Segmentation Events Dashboard Redesign

**Date:** 6 January 2026
**Status:** Design Recommendations
**Priority:** High
**Stakeholders:** CSE Team, Management, Product

---

## Executive Summary

This document outlines a comprehensive redesign of the Segmentation Events page to replace the current Excel-based compliance tracking workflow. The design leverages existing platform functionality (Briefing Room, Actions, Alerts) while introducing modern UI/UX patterns from industry leaders like Salesforce, HubSpot, Linear, and Notion.

---

## Current State Analysis

### What Exists (Fully Functional)

| Component | Status | Notes |
|-----------|--------|-------|
| `useEventCompliance.ts` | ✅ Complete | Full compliance calculations with segment-aware logic |
| `useCompliancePredictions.ts` | ✅ Complete | AI/ML predictions with confidence intervals |
| `compliance-meeting-sync.ts` | ✅ Complete | Briefing Room → Compliance auto-sync |
| `alert-system.ts` | ✅ Complete | Risk detection with 20+ alert types |
| `compliance-report-export.ts` | ✅ Complete | PDF generation (3 report types) |
| Materialized View | ✅ Complete | Performance optimised (50ms vs 1000ms) |

### Styling Issues (Current Page)

1. **Inconsistent with dashboard design language** - Grey backgrounds vs purple/gradient elsewhere
2. **Progress rings not matching brand colours** - Need Altera purple/emerald theme
3. **Card shadows and borders inconsistent** - Mix of styles
4. **Empty states too basic** - No engaging illustrations
5. **Filter bar styling outdated** - Doesn't match other pages

### Missing Features for Excel Replacement

1. **Bulk Event Import UI** - API exists, no frontend
2. **CSV Export for event lists** - Only PDF available
3. **Event scheduling optimisation** - AI suggests, no auto-schedule
4. **Calendar integration** - No Outlook/Teams blocking
5. **Audit trail UI** - Data stored, not displayed
6. **Custom compliance rules** - Hard-coded in database

---

## Recommended Design System

### Colour Palette (Matching Dashboard)

```css
/* Primary - Altera Purple */
--primary-50: #faf5ff;
--primary-500: #a855f7;
--primary-600: #9333ea;
--primary-700: #7e22ce;

/* Success - Emerald (Compliant) */
--success-500: #10b981;
--success-600: #059669;

/* Warning - Amber (At-Risk) */
--warning-500: #f59e0b;
--warning-600: #d97706;

/* Danger - Red (Critical) */
--danger-500: #ef4444;
--danger-600: #dc2626;

/* Neutral Backgrounds */
--bg-primary: #ffffff;
--bg-secondary: #f9fafb;
--bg-tertiary: #f3f4f6;
```

### Typography Hierarchy

| Level | Size | Weight | Use Case |
|-------|------|--------|----------|
| H1 | 24px | 700 | Page Title |
| H2 | 18px | 600 | Section Headers |
| H3 | 14px | 600 | Card Titles |
| Body | 14px | 400 | Content |
| Caption | 12px | 500 | Labels, Badges |
| Micro | 10px | 600 | Status Indicators |

---

## Proposed Layout Structure

### Page Header (Matches Dashboard)

```
┌─────────────────────────────────────────────────────────────────────┐
│ Segmentation Events                                                  │
│ Track and manage client engagement compliance                        │
│                                                                       │
│ [My Clients] [Team View]                     [↻ Refresh] [📥 Export] │
└─────────────────────────────────────────────────────────────────────┘
```

### Summary Cards Row (4 Cards, Gradient Headers)

```
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  📊 Total    │ │  ✅ Compliant │ │  ⚠️ At Risk  │ │  🚨 Critical │
│  Clients     │ │              │ │              │ │              │
│     42       │ │     28       │ │     10       │ │     4        │
│  +3 vs last  │ │  67%         │ │  24%         │ │  9%          │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
     Purple          Emerald          Amber            Red
```

### Main Dashboard Grid (2x2 + Full Width)

```
┌────────────────────────────┬────────────────────────────┐
│                            │                            │
│  Overall Compliance        │  Compliance by Event Type  │
│  [Large Progress Ring]     │  [Mini Ring Grid]          │
│       78%                  │  QBR: 85%  HC: 72%        │
│     Compliant              │  ITP: 90%  SV: 65%        │
│                            │                            │
├────────────────────────────┼────────────────────────────┤
│                            │                            │
│  At-Risk Heat Map          │  Event Calendar            │
│  [CSE x Client Grid]       │  [Upcoming Events List]    │
│                            │                            │
│                            │                            │
└────────────────────────────┴────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  Compliance Trend                                        │
│  [Area Chart - 12 months]                               │
└─────────────────────────────────────────────────────────┘
```

---

## Component Specifications

### 1. Compliance Progress Ring (Redesigned)

**Current Issues:**
- Plain styling, no gradient
- Status text below ring, not inside

**New Design:**

```
        ╭─────────╮
       ╱           ╲
      │             │
      │    78%      │
      │  Compliant  │
      │             │
       ╲           ╱
        ╰─────────╯

   [███████████░░░]  Progress bar below
   28/36 event types met
```

**Implementation:**
- Gradient stroke matching status colour
- Animated on mount (0 → actual %)
- Percentage + status text INSIDE ring
- Subtle glow effect on hover
- Click to drill down

### 2. Event Type Summary Grid

**Pattern:** HubSpot-style mini cards with progress

```
┌─────────────────────────────────────────────────────────┐
│  Progress Towards Annual Targets                         │
├──────────────┬──────────────┬──────────────┬────────────┤
│   🔵 QBR     │   💚 Health  │   📊 Insight │   🏢 Site  │
│    85%       │    Check     │     Touch    │    Visit   │
│  ████████░░  │    72%       │     90%      │    65%     │
│  17/20       │  ██████░░░░  │  █████████░  │  █████░░░░ │
│              │  14/20       │  18/20       │  13/20     │
└──────────────┴──────────────┴──────────────┴────────────┘
```

### 3. Client Compliance Table (Redesigned)

**Pattern:** Linear/Notion-style data table with inline actions

**Features:**
- Sticky header with sort indicators
- Row hover with quick actions
- Bulk selection with bottom toolbar (Asana pattern)
- Inline status badges
- Progress bar in row

```
┌────────────────────────────────────────────────────────────────────┐
│ ☐  Client          Segment   CSE        Compliance    Status  ⋮   │
├────────────────────────────────────────────────────────────────────┤
│ ☐  Metro Health    Tier 1    Sarah J.   ████████░░    On Track ▾  │
│                                         85%                        │
│ ☐  Regional Care   Tier 2    John S.    ██████░░░░    At Risk  ▾  │
│                                         62%                        │
│ ☑  Coastal Med     Tier 1    Sarah J.   ████░░░░░░    Critical ▾  │
│                                         38%                        │
└────────────────────────────────────────────────────────────────────┘
                           ↓
┌────────────────────────────────────────────────────────────────────┐
│  1 selected            [Schedule Event] [Log Event] [View] [More] │
└────────────────────────────────────────────────────────────────────┘
```

### 4. Quick Event Capture (Mobile-First Bottom Sheet)

**Pattern:** Material Design 3 Bottom Sheet

**Desktop:** Modal centred
**Mobile:** Bottom sheet sliding up

```
┌─────────────────────────────────────┐
│  ═══════════  (drag handle)         │
│                                      │
│  📝 Log Compliance Event             │
│                                      │
│  Event Type                          │
│  [QBR] [Health Check] [ITP] [Other] │
│                                      │
│  Client                              │
│  [🔍 Search or select client...]    │
│                                      │
│  Date                                │
│  [📅 Today]  [Yesterday]  [Custom]  │
│                                      │
│  Notes (optional)                    │
│  [                                ] │
│                                      │
│  [Link to Meeting]                   │
│                                      │
│  ┌──────────────────────────────┐   │
│  │     Save Event               │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

### 5. Salesforce-Style Activity Timeline

**For Client Detail View:**

```
┌─────────────────────────────────────────────────────────┐
│  Activity Timeline                           [Expand All] │
├─────────────────────────────────────────────────────────┤
│  UPCOMING & OVERDUE                                      │
│  ┌────────────────────────────────────────────────────┐ │
│  │ ⚠️ OVERDUE  QBR - Q4 Review                        │ │
│  │    Due: 15 Dec 2025 (22 days ago)                  │ │
│  │    [Schedule Now] [Mark Complete]                  │ │
│  └────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────┐ │
│  │ 📅 UPCOMING  Health Check                          │ │
│  │    Scheduled: 20 Jan 2026 (14 days)                │ │
│  │    [View Meeting] [Reschedule]                     │ │
│  └────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────┤
│  JANUARY 2026                                    [−]    │
│  ○ 03 Jan - Site Visit - ✅ Completed                   │
├─────────────────────────────────────────────────────────┤
│  DECEMBER 2025                                   [+]    │
│  (3 events)                                             │
└─────────────────────────────────────────────────────────┘
```

---

## Alert System Enhancements

### New Alert Types for Compliance

| Alert Type | Trigger | Severity | Action |
|------------|---------|----------|--------|
| `compliance_critical` | < 30% compliance | Critical | Immediate escalation |
| `compliance_at_risk` | 30-50% compliance | High | Schedule events |
| `compliance_trending_down` | 10%+ decline in 30 days | High | Review required |
| `compliance_deadline_approaching` | 30 days to deadline, < 75% | High | Schedule remaining |
| `compliance_perfect` | 100% compliance achieved | Info | Praise notification |
| `compliance_exceeded` | > 100% compliance | Info | Recognition |
| `event_overdue` | Scheduled date passed | High | Reschedule |
| `segment_change_deadline` | Extended deadline approaching | Medium | Review requirements |

### Alert Display Patterns

**Inline Banner (Top of Page):**
```
┌─────────────────────────────────────────────────────────────────┐
│ ⚠️ 4 clients require immediate attention    [View All] [Dismiss] │
└─────────────────────────────────────────────────────────────────┘
```

**Toast Notifications (Carbon Design Pattern):**
- Top-right positioning
- Auto-dismiss after 5 seconds (unless critical)
- No interactive elements (WCAG compliance)

**Praise Notifications (Gamification):**
```
┌─────────────────────────────────────┐
│  🎉 Perfect Score!                  │
│  Metro Health achieved 100%         │
│  compliance this quarter            │
│                                      │
│  [Share] [View Details]             │
└─────────────────────────────────────┘
```

---

## Integration Workflows

### 1. Briefing Room → Compliance (Existing, Enhance)

**Current:** Meeting completion auto-creates compliance event
**Enhancement:** Visual feedback showing sync status

```
Meeting Created → Compliance Event Created → Toast: "Event tracked for compliance"
Meeting Completed → Event Marked Complete → Badge: "Compliance Updated"
```

### 2. Compliance → Actions (New Integration)

**Workflow:**
1. Compliance alert generated (< 50%)
2. Auto-create Action item for CSE
3. Priority based on severity
4. Link action to client profile

**Implementation:**
```typescript
// In alert-system.ts
async function createActionFromAlert(alert: Alert) {
  if (alert.type.startsWith('compliance_')) {
    await createAction({
      title: `Address compliance: ${alert.client_name}`,
      description: alert.message,
      priority: mapSeverityToPriority(alert.severity),
      assigned_to: alert.assigned_to,
      due_date: calculateDueDate(alert.severity),
      linked_client: alert.client_name,
      source: 'compliance_alert'
    })
  }
}
```

### 3. Manager Escalation Flow

```
Critical Compliance (< 30%)
    ↓
Alert Generated
    ↓
CSE Notified (Toast + Bell)
    ↓
72 hours no action?
    ↓
Manager Notified
    ↓
Dashboard highlights in "Team View"
```

---

## PDF Report Templates

### 1. CSE Monthly Report

**Sections:**
- Header: CSE name, period, generated date
- Summary metrics: Clients managed, avg compliance, rank
- Client breakdown table
- Trend chart (sparkline)
- Recommendations

### 2. Team Summary Report (for Management)

**Sections:**
- Executive summary
- Team leaderboard
- Risk heatmap (CSE vs Client)
- Portfolio compliance trend
- Critical clients requiring attention
- Forecast to year-end

### 3. Client Detail Report

**Sections:**
- Client header with segment tier
- Compliance status (ring chart)
- Event timeline (completed + scheduled)
- Year-over-year comparison
- AI predictions and recommendations

---

## Implementation Phases

### Phase 1: Styling Alignment (1 sprint)
- [ ] Update colour palette to match dashboard
- [ ] Redesign progress rings with gradients
- [ ] Consistent card shadows and borders
- [ ] Better empty states with illustrations
- [ ] Update filter bar styling

### Phase 2: Enhanced Data Table (1 sprint)
- [ ] Add bulk selection with bottom toolbar
- [ ] Inline status badges with hover actions
- [ ] Row-level progress bars
- [ ] Sticky header with sort
- [ ] CSV export button

### Phase 3: Quick Event Capture (1 sprint)
- [ ] Mobile-first bottom sheet modal
- [ ] Event type icon grid
- [ ] Recent clients quick select
- [ ] Meeting link integration
- [ ] Success animations

### Phase 4: Timeline View (1 sprint)
- [ ] Salesforce-style activity timeline
- [ ] Collapsible month sections
- [ ] Inline action buttons
- [ ] Overdue highlighting
- [ ] View all/expand all

### Phase 5: Alert Enhancements (1 sprint)
- [ ] New compliance alert types
- [ ] Inline banner component
- [ ] Praise/recognition notifications
- [ ] Actions integration
- [ ] Escalation workflow

### Phase 6: Manager Dashboard (1 sprint)
- [ ] CSE leaderboard with photos
- [ ] Heat map visualisation
- [ ] Team metrics cards
- [ ] PDF report generation
- [ ] Export to presentation

---

## Success Metrics

| Metric | Current | Target |
|--------|---------|--------|
| Time to log event | ~60 seconds | < 10 seconds |
| Excel usage | Daily | Eliminated |
| Compliance visibility | Manual lookup | Real-time |
| Manager report time | 2+ hours | < 5 minutes |
| Alert response time | Days | < 24 hours |
| Mobile event logging | 0% | > 50% |

---

## Technical Considerations

### Performance
- Continue using materialized view for dashboard queries
- Lazy load timeline events (paginate by month)
- Cache AI predictions for 1 hour
- Optimistic UI updates for event logging

### Accessibility
- WCAG 2.1 AA compliance
- No interactive elements in toasts
- Keyboard navigation for table
- Screen reader announcements for status changes

### Mobile Responsiveness
- Bottom sheet for modals
- Collapsed sidebar on mobile
- Touch-friendly action buttons
- Swipe gestures for table rows

---

## References

- [Linear Dashboard Best Practices](https://linear.app/now/dashboards-best-practices)
- [Salesforce Activity Timeline](https://help.salesforce.com/s/articleView?id=sales.activity_timeline_parent.htm)
- [Material Design 3 Bottom Sheets](https://m3.material.io/components/bottom-sheets/overview)
- [Carbon Design System Notifications](https://carbondesignsystem.com/patterns/notification-pattern/)
- [HubSpot Dashboard Capabilities](https://www.hubspot.com/products/reporting-dashboards)

---

*Generated: 6 January 2026*
