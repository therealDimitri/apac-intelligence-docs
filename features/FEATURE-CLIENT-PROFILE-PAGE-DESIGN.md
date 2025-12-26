# Client Profile Page - Full Design & Implementation Guide

**Status**: Design Phase - Ready for Implementation
**Date**: December 1, 2025
**Objective**: Replace the Details button modal with a dedicated, modern full-page client profile view

---

## Executive Summary

Transform the inline modal (currently opened by "Details" button) into a **dedicated full-page client profile** that displays all client information in a modern, easy-to-scan layout. This page will replace the 6-tab modal with a single scrollable view, improving UX and providing a premium client detail experience.

**Key Improvements**:

- ✅ Full screen real estate utilization
- ✅ Better information hierarchy
- ✅ Reduced modal fatigue
- ✅ Easier navigation with breadcrumbs
- ✅ Better mobile responsiveness
- ✅ Premium, modern design aesthetic

---

## Navigation & Access

### Current Flow

```
Client Segmentation Page (/segmentation)
    ↓
[Details Button] → Modal (fixed overlay, requires close)
```

### Proposed New Flow

```
Client Segmentation Page (/segmentation)
    ↓
[Client Name/Row Click] → /clients/[clientId] (dedicated page)
    ↓
Full Client Profile Page (scrollable, back navigation)
```

### Route Structure

```
/clients/[clientId]
├── Parameters: clientId (from URL)
├── Breadcrumb: Segmentation > [Client Name]
└── Full Profile with all tabs
```

---

## Page Layout - Top to Bottom

### 1. HEADER & NAVIGATION (Fixed/Sticky)

**Height**: 120px (expandable on scroll)

**Components**:

```
[← Back Link] [Breadcrumb: Segmentation > Client Name]     [Share] [Export] [Menu]
[Logo] [Client Name - Display Name]                        [Status Badge] [Health Score]
```

**Design**:

- Gradient background: Purple (brand color)
- White text for contrast
- Sticky navigation on scroll
- Back arrow returns to segmentation page with client filter applied
- Client name uses display name mapping (e.g., "MinDef" for "Ministry of Defence")

---

### 2. CLIENT HEADER CARD (Hero Section)

**Height**: 320px

**Layout** (3-column grid):

**Left Column (40%)**:

```
┌─────────────────┐
│                 │
│   [Logo]        │ 120x120px with initials fallback
│                 │
└─────────────────┘
```

**Middle Column (40%)**:

```
Client Name
Display Name (if different)

[Status Badge: HEALTHY/AT-RISK/CRITICAL]
Health Score: XX/100 [||||||||░░]

Segment: [Segment Badge]
CSE Owner: [Name]
```

**Right Column (20%)**:

```
NPS Score: XX
└─ Last NPS: [date]

Last Meeting: [date]
└─ Days since: X

Open Actions: X
└─ Priority: [High/Med]
```

**Visual Style**:

- White card with subtle shadow
- Color-coded status indicator (left border)
- Icons next to metrics
- Clear typography hierarchy

**Responsive**:

- Tablets: Stack to 2 columns
- Mobile: Stack to 1 column (scrollable)

---

### 3. QUICK STATS ROW (4-Column Cards)

**Height**: 140px
**Cards**: Evenly distributed

**Card 1: Health Overview**

```
┌─────────────┐
│  HEALTH     │
│  SCORE      │
│   XX/100    │ [Large number]
│  [Status]   │
└─────────────┘
```

**Card 2: Engagement**

```
┌─────────────┐
│ ENGAGEMENT  │
│             │
│ ████░░ 67%  │ [Progress bar]
│ X meetings  │ [subtitle]
│ X responses │ [subtitle]
└─────────────┘
```

**Card 3: Compliance**

```
┌─────────────┐
│ COMPLIANCE  │
│             │
│ ████░░ XX%  │ [Progress bar]
│ X events    │ [subtitle]
│ Due: X days │ [subtitle]
└─────────────┘
```

**Card 4: Risk**

```
┌─────────────┐
│ RISK SCORE  │
│             │
│    LOW      │ [Status]
│ X factors   │ [subtitle]
│ ████░░ 25%  │ [Progress bar]
└─────────────┘
```

---

### 4. HEALTH SCORE BREAKDOWN SECTION

**Height**: 400px
**Title**: "Health Score Components"

**Visual**: 6 horizontal component bars

```
NPS Score (25 pts)
████████████░░░░░░ 12/25 pts
└─ Promoters: X% | Detractors: X% | Neutral: X%

Engagement (25 pts)
██████░░░░░░░░░░░░ 15/25 pts
└─ Meetings: X | Responses: X

Segmentation Compliance (15 pts)
██████░░░░░░░ 10/15 pts
└─ Average event compliance: XX%

Aging Accounts (15 pts)
████████░░░░░░░░░░ 9/15 pts
└─ <90 days: X% | <60 days: X%

Actions Risk (10 pts)
██████░░░░░░░░░░░░ 6/10 pts
└─ Open actions: X | Overdue: X

Recency (10 pts)
██████████░░░░░░░░ 10/10 pts
└─ Last interaction: X days ago
```

**Interactive**:

- Hover over bar shows tooltip with explanation
- Click on component expands details below
- Color coding: Green (>75%), Yellow (50-75%), Red (<50%)

---

### 5. SEGMENT & POSITIONING

**Height**: 180px
**Title**: "Positioning & Strategy"

**3-Column Layout**:

**Column 1: Segment Info**

```
Current Segment: [Segment Name]
└─ [Icon] [Description]
└─ Target: [Objective]

Spend Level: [$$$$ | $$$ | $$ | $]
NPS Level: [High | Medium | Low]
```

**Column 2: Positioning Matrix**

```
[Visual 2x2 matrix]
- Y-axis: Spend (Low ↔ High)
- X-axis: NPS/Satisfaction (Low ↔ High)
- Red dot: Current position
- Green diamond: Target position
- Arrows show movement
```

**Column 3: Recommendations**

```
Primary Objective:
└─ [Increase Spend / Increase Satisfaction]

Key Focus Areas:
• [Action 1]
• [Action 2]
• [Action 3]

Success Metrics:
• Target NPS: XX
• Target Spend: $XXX
• Timeline: X months
```

---

### 6. OPEN ACTIONS SECTION

**Height**: Variable (min 250px)
**Title**: "Action Items & Tasks"

**Tabs/Filters**:

- [ All (X) ] [ Open (X) ] [ Overdue (X) ] [ Completed (X) ]

**Table View**:

```
┌─────────────────────────────────────────────────────────┐
│ Action                  │ Owner  │ Due      │ Status     │
├─────────────────────────────────────────────────────────┤
│ [Action 1]              │ [Name] │ [date]   │ [Status]   │
│ [Action 2] (OVERDUE)    │ [Name] │ [date]   │ [Red]      │
│ [Action 3]              │ [Name] │ [date]   │ [Status]   │
└─────────────────────────────────────────────────────────┘
```

**Features**:

- Sortable columns
- Color-coded status (Red=Overdue, Yellow=Due Soon, Green=On Track)
- Quick action buttons: Edit, Complete, Delete
- "+ New Action" button at bottom
- Expandable rows show full action details

---

### 7. EVENT COMPLIANCE SECTION

**Height**: 500px
**Title**: "Event Compliance & Scheduling"

**Tabs**:

- [ Overview ] [ Schedule ] [ History ]

**Overview Tab** (default):

```
Overall Compliance: XX%
├─ Status: [Compliant/At-Risk/Critical]
└─ Trend: ↑ +5% from last month

Event Type Breakdown (6+ cards):
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ Event Type 1     │  │ Event Type 2     │  │ Event Type 3     │
│ Priority: High   │  │ Priority: High   │  │ Priority: Medium │
│ Status: [badge]  │  │ Status: [badge]  │  │ Status: [badge]  │
│ XX/XX events     │  │ XX/XX events     │  │ XX/XX events     │
│ XX% compliance   │  │ XX% compliance   │  │ XX% compliance   │
│ Due: XX days     │  │ Due: XX days     │  │ Due: XX days     │
└──────────────────┘  └──────────────────┘  └──────────────────┘

Next Scheduled Events (collapsed list):
□ Event A - Due: [date] - Status: Scheduled
□ Event B - Due: [date] - Status: Pending
□ Event C - Due: [date] - Status: Not Scheduled
```

**Schedule Tab**:

```
Calendar View for next 90 days
├─ [Calendar visualization]
├─ Scheduled events marked
├─ Compliance deadlines highlighted
└─ [+ Schedule Event] button
```

**History Tab**:

```
Past Events (last 12 months):
┌─────────────────────────────────────────────────┐
│ Date      │ Event Type │ Duration │ Notes       │
├─────────────────────────────────────────────────┤
│ [date]    │ [type]     │ [dur]    │ [notes]     │
│ [date]    │ [type]     │ [dur]    │ [notes]     │
└─────────────────────────────────────────────────┘
```

---

### 8. NPS DATA & TRENDS

**Height**: 350px
**Title**: "NPS Trends & Sentiment"

**3-Column Layout**:

**Column 1: NPS Summary**

```
Current NPS: XX
└─ Change: ±XX from last period

NPS Breakdown:
Promoters (9-10): XX%
Passives (7-8): XX%
Detractors (0-6): XX%

[Donut chart visualization]
```

**Column 2: NPS Timeline (Sparkline)**

```
Last 12 Months:
[Line chart: NPS trend over time]

Responses:
├─ Total: XXX
├─ Rate: XX% (vs expected)
└─ Trend: ↑ or ↓
```

**Column 3: Recent Feedback**

```
Latest Responses (last 5):
• Promoter (XXX): "Quote..."
• Detractor (XX): "Quote..."
• Passive (XX): "Quote..."
• [See All Responses] button
```

---

### 9. MEETING HISTORY

**Height**: 300px
**Title**: "Meeting Activity"

**Summary Stats** (3-card row):

```
Total Meetings: XX    Last Meeting: [date]    Frequency: Every X days
```

**Meeting Log** (collapsible list):

```
[Date] - [Meeting Type] - Duration: Xm - CSE: [Name]
└─ Notes: [Summary]
└─ Attendees: [X people]
└─ Outcomes: [X actions]

[Date] - [Meeting Type] - Duration: Xm - CSE: [Name]
[Date] - [Meeting Type] - Duration: Xm - CSE: [Name]
```

**Features**:

- Click to expand meeting details
- "+ Schedule Meeting" button
- Calendar view option

---

### 10. AI INSIGHTS & RECOMMENDATIONS

**Height**: 450px
**Title**: "AI-Generated Insights & Recommendations"

**Tabs**:

- [ Issues (X) ] [ Opportunities (X) ] [ Risks (X) ] [ Actions (X) ]

**Issues Tab** (default):

```
[HIGH SEVERITY - Red Card]
├─ Title: "Declining NPS Trend"
├─ Impact: High
├─ Description: NPS dropped 8 points in last quarter
├─ Root Causes:
│  • Lower engagement (fewer meetings)
│  • Compliance issues with Event Type X
│  • Aging accounts reaching deadline
├─ Recommended Action: Schedule health check meeting
└─ [View Details] button

[MEDIUM SEVERITY - Yellow Card]
├─ Title: "X Overdue Actions"
├─ Impact: Medium
├─ Description: X actions overdue by average X days
├─ Recommended Action: Prioritize completion
└─ [View Details] button

[LOW SEVERITY - Blue Card]
├─ Title: "Opportunity: Upsell Potential"
├─ Impact: Medium (Positive)
├─ Description: Strong engagement suggests readiness for expansion
├─ Recommended Action: Contact CSE to discuss expansion
└─ [View Details] button
```

**Opportunities Tab**:

```
[GREEN Card]
├─ Title: "High Engagement - Growth Ready"
├─ Details: Client showing strong engagement metrics
├─ Recommendation: Consider expansion discussion
└─ [Schedule Meeting] button

[GREEN Card]
├─ Title: "Compliance Trend Improving"
├─ Details: Compliance up 12% month-over-month
├─ Recommendation: Reinforce current practices
└─ [Details] button
```

**Risks Tab**:

```
Risk Assessment: MEDIUM (45/100)
Risk Factors:
• Declining NPS: -8 points
• Aging accounts approaching limits
• X events not scheduled
• Meeting frequency dropping

Churn Risk: LOW (15%)
└─ Historical data: Similar clients have X% churn rate

Financial Risk: MEDIUM (55%)
└─ Compliance issues could impact renewal
```

**Actions Tab**:

```
AI-Recommended Actions (Priority Order):

1️⃣ [URGENT] Schedule Health Check Meeting
   └─ Estimated time: 30 mins
   └─ Expected impact: Understanding NPS decline
   └─ [Schedule] button

2️⃣ [HIGH] Address Aging Accounts Issues
   └─ Details: X accounts exceeding 90-day limit
   └─ Due: X days
   └─ [View Accounts] button

3️⃣ [HIGH] Complete Pending Events
   └─ Overdue: X events
   └─ Impact: Compliance improvement 15%
   └─ [View Events] button

4️⃣ [MEDIUM] Increase Meeting Frequency
   └─ Current: Every X days
   └─ Target: Every X days
   └─ [Schedule Series] button
```

---

### 11. PREDICTED OUTCOMES (AI Forecasting)

**Height**: 250px
**Title**: "12-Month Forecast & Predictions"

**3-Column Cards**:

**Card 1: Compliance Forecast**

```
Predicted Year-End Compliance: XX%
├─ Current: XX%
├─ Trend: [Arrow up/down]
├─ Probability: XX% confidence
└─ [View Factors] button
```

**Card 2: NPS Forecast**

```
Predicted Year-End NPS: XX
├─ Current: XX
├─ Trend: [Arrow up/down]
├─ Probability: XX% confidence
└─ [View Factors] button
```

**Card 3: Churn Risk**

```
Renewal Probability: XX%
├─ Risk Factors: X identified
├─ Trend: [Arrow up/down]
├─ Last Updated: [date]
└─ [Mitigation Plan] button
```

---

### 12. CSE & TEAM INFORMATION

**Height**: 200px
**Title**: "Account Team"

**Primary CSE Card**:

```
┌────────────────────┐
│ [Photo]            │
│ CSE Name           │
│ Email: [email]     │
│ Phone: [phone]     │
│ [Message] [Call]   │
└────────────────────┘
```

**Secondary Team Members** (if applicable):

```
Co-CSE: [Name] - [Title]
Manager: [Name] - [Title]
Support: [Name] - [Title]
```

---

### 13. QUICK ACTIONS FOOTER (Sticky/Fixed)

**Height**: 80px
**Position**: Bottom of page

**Button Grid**:

```
[Schedule Meeting] [Send Message] [Create Action] [Export Report] [Share Profile] [More Options...]
```

**Features**:

- Sticky footer visible while scrolling
- Quick access to common actions
- "More Options" dropdown menu with:
  - Edit client details
  - View contract
  - View financials
  - View communication history
  - Generate report
  - Archive client
  - Merge duplicate

---

## Design System & Visual Hierarchy

### Color Scheme

```
Primary: Purple (#8B5CF6) - Brand color, headers
Success: Green (#10B981) - Healthy, compliant
Warning: Yellow (#F59E0B) - At-risk, attention needed
Danger: Red (#EF4444) - Critical, urgent
Info: Blue (#3B82F6) - Information, secondary

Status Colors:
├─ Healthy: Green gradient
├─ At-Risk: Yellow/Orange gradient
└─ Critical: Red gradient
```

### Typography

```
Page Title: 36px, Bold, Purple
Section Headers: 24px, Bold, Dark Gray
Card Titles: 16px, Semi-bold, Dark Gray
Body Text: 14px, Regular, Medium Gray
Stats Numbers: 28px, Bold, Purple
Supporting Text: 12px, Regular, Light Gray
```

### Spacing & Sizing

```
Page Padding: 32px (top/bottom), 24px (left/right)
Section Spacing: 32px between sections
Card Padding: 24px
Component Gaps: 16px
Component Padding: 12px
```

### Cards & Surfaces

```
White cards with subtle box-shadow
Border-radius: 12px for primary cards, 8px for secondary
Hover states: Lift effect (+4px shadow)
Dividers: Light gray (#E5E7EB)
```

---

## Interactive Elements & Behavior

### Expandable Sections

- Click section header to expand/collapse
- Smooth animation (300ms)
- Chevron icon indicates state
- Save state in local storage (remember user preference)

### Hover States

- Buttons: Slightly darker background
- Cards: Lift effect + increased shadow
- Rows: Light gray background
- Links: Underline + color change

### Responsive Behavior

**Desktop (1440px+)**:

- 3-column layouts
- Full header always visible
- Side navigation possible

**Tablet (768px - 1439px)**:

- 2-column layouts, some cards stack
- Header collapses on scroll
- Hamburger menu for actions

**Mobile (< 768px)**:

- Single column everything
- Full-screen sections
- Bottom sticky action bar
- Minimized header

---

## Performance Optimizations

1. **Data Fetching**
   - Fetch only visible sections initially
   - Lazy load AI insights
   - Cache client data (5-min validity)

2. **Rendering**
   - Use React.memo for card components
   - Virtualize long lists (action items, meeting history)
   - Progressive image loading for logos

3. **Interactions**
   - Debounce search filters
   - Cancel previous requests on new fetch
   - Prefetch related data on mount

---

## Implementation Roadmap

### Phase 1: Core Page Structure (Week 1)

- [ ] Create `/clients/[clientId]` route
- [ ] Build header component
- [ ] Build health overview card
- [ ] Build quick stats row
- [ ] Navigation & breadcrumb

### Phase 2: Data Sections (Week 2)

- [ ] Health score breakdown
- [ ] Segment & positioning
- [ ] Open actions section
- [ ] Event compliance section

### Phase 3: Insights & Interactions (Week 3)

- [ ] NPS data & trends
- [ ] AI insights section
- [ ] Meeting history
- [ ] Forecast cards

### Phase 4: Polish & Integration (Week 4)

- [ ] Responsive design refinement
- [ ] Performance optimization
- [ ] Testing & bug fixes
- [ ] Integration with segmentation page
- [ ] Remove "Details" button, add client row click

---

## Migration Strategy

### Step 1: Build New Page

- Develop new `/clients/[clientId]` page alongside existing modal

### Step 2: Soft Launch

- Make client names/rows on segmentation page clickable
- Still show "Details" button temporarily
- Allow users to choose between modal and full page

### Step 3: Full Migration

- Set click-on-row to open full page
- Keep "Details" button but point to new page
- Deprecate modal interface

### Step 4: Cleanup

- Remove old modal component
- Archive modal code
- Document in changelog

---

## Success Metrics

1. **User Engagement**
   - Avg time on profile page: > 2 mins
   - Bounce rate: < 20%
   - Return visits: > 60% of users

2. **Feature Usage**
   - Actions created from page: > 30%
   - Meetings scheduled from page: > 25%
   - Export/Share clicks: > 15%

3. **Performance**
   - Page load time: < 2 seconds
   - Scroll FPS: > 55 fps
   - Mobile accessibility score: > 90

---

## File Structure (Proposed)

```
src/
├── app/
│   └── (dashboard)/
│       └── clients/
│           └── [clientId]/
│               ├── page.tsx                    (Main profile page)
│               ├── layout.tsx                  (Page layout)
│               └── components/
│                   ├── ClientHeader.tsx
│                   ├── HealthOverview.tsx
│                   ├── QuickStatsRow.tsx
│                   ├── HealthBreakdown.tsx
│                   ├── SegmentSection.tsx
│                   ├── OpenActionsSection.tsx
│                   ├── ComplianceSection.tsx
│                   ├── NPSTrendsSection.tsx
│                   ├── MeetingHistorySection.tsx
│                   ├── AIInsightsSection.tsx
│                   ├── ForecastSection.tsx
│                   ├── CSEInfoSection.tsx
│                   └── QuickActionsFooter.tsx
├── components/
│   ├── ClientProfileCard.tsx
│   ├── HealthScoreBar.tsx
│   ├── SegmentBadge.tsx
│   └── [reusable components]
└── hooks/
    ├── useClientProfile.ts                     (New hook - aggregate all data)
    └── [existing hooks]
```

---

## Accessibility Considerations

1. **Keyboard Navigation**
   - All interactive elements keyboard-accessible
   - Logical tab order
   - Skip-to-main link

2. **Screen Readers**
   - Semantic HTML structure
   - ARIA labels for complex components
   - Status announcements for dynamic updates

3. **Visual Accessibility**
   - Color not only indicator (icons + text)
   - Sufficient contrast ratios
   - Resizable text support

---

## Security & Permissions

- Verify user has access to view client
- Check CSE/role-based permissions
- Log profile page access
- Mask sensitive data if needed (contracts, financial)

---

## Future Enhancements (Phase 2+)

1. **Activity Timeline** - Combined view of all client interactions
2. **Document Library** - Contracts, communications, reports
3. **Financial Dashboard** - Revenue, ARR, churn risk, renewal dates
4. **Comparison Tool** - Compare client against peer group
5. **Customizable Widgets** - Let users rearrange sections
6. **Export to PDF** - Generate professional client report
7. **Team Collaboration** - Comments, notes, assignments within profile
8. **Real-time Updates** - WebSocket for live data updates

---

**End of Design Document**

---

## Implementation Notes for Developer

### Key Integration Points

1. **Replace "Details" Button**
   - In `/src/app/(dashboard)/segmentation/page.tsx`
   - Change button click handler from modal to navigation
   - `router.push(`/clients/${client.id}`)`

2. **Reuse Existing Components**
   - Most components already exist
   - Import from existing locations
   - Combine into new page layout

3. **Data Fetching**
   - Create new `useClientProfile` hook
   - Combine existing data hooks
   - Parallelize requests for performance

4. **Styling**
   - Use existing Tailwind config
   - Follow project's design system
   - Reference `/segmentation` page for consistency

### Estimated Development Time

- Setup & Routing: 4 hours
- Components: 16 hours
- Styling & Responsive: 12 hours
- Data Integration: 8 hours
- Testing: 8 hours
- **Total**: ~48 hours (1-2 weeks for single developer)

---

**Design created**: December 1, 2025
**Ready for**: Development & Implementation
