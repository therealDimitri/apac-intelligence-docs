# Support Dashboard UI/UX Research & Design Patterns

## Executive Summary

This document analyses UI/UX best practices from leading support platforms (Zendesk, Freshdesk, Intercom, ServiceNow, Jira Service Management) and provides specific design recommendations for a B2B enterprise healthcare support dashboard.

**Key Findings:**
- Executive dashboards require high-level KPIs with weekly/monthly refresh cycles
- Operational dashboards need real-time data with prominent SLA indicators
- Healthcare dashboards prioritise clean layouts, role-based access, and HIPAA compliance
- Mobile responsiveness requires 48×48px touch targets and thumb-friendly navigation
- Accessibility demands 4.5:1 contrast ratios and colour-blind safe palettes

---

## 1. Platform Analysis: SLA Compliance Visualisation

### Zendesk
**Key UI Patterns:**
- **SLA Badges with Colour Coding:** Visual indicators show time remaining before breach
  - Green: Comfortable time remaining
  - Yellow/Amber: Approaching breach (warning state)
  - Red: Breached (negative time value displayed, e.g., "-15m" or "4h")
- **Pause Icon:** Displays when SLA target is paused
- **Customisable Dashboards:** Managers can focus on specific data points (response times, satisfaction scores)
- **Interactive Breakdown:** Users can drill down by assignee, SLA policy, or channel

**Design Recommendations:**
- Use real-time SLA badges in ticket views and queue columns
- Display calendar time remaining (not just business hours) for transparency
- Group SLA dashboard by policy type (First Response, Resolution, etc.)

**Sources:**
- [Zendesk SLA Policies](https://support.zendesk.com/hc/en-us/articles/5604663490458-Using-SLA-policies)
- [Tracking Zendesk SLA Metrics | Geckoboard](https://www.geckoboard.com/blog/track-zendesk-service-level-agreement-sla-metrics/)
- [Zendesk Dashboard Examples | Geckoboard](https://www.geckoboard.com/dashboard-examples/support/zendesk-dashboard/)

---

### Freshdesk
**Key UI Patterns:**
- **Team Dashboards:** Group-specific performance monitoring with live widgets
- **Ticket Lifecycle Report:** Analyses time spent at each stage without manual time entries
- **Custom Metrics:** Users can define aged ticket lists with time thresholds
- **Widget Library:** Scorecards and bar charts for live workload monitoring
- **Graph Formats:** Charts, graphs, tables, or text representations

**Design Recommendations:**
- Create customisable aging buckets (0-24h, 1-3d, 4-7d, 7d+)
- Use bar charts for ticket volume comparisons across categories
- Implement live widgets that pull data from ticket views
- Apply 90-day default filters for performance reports

**Sources:**
- [Freshdesk Analytics Introduction](https://support.freshdesk.com/support/solutions/articles/239757-introduction-to-analytics)
- [Team Dashboards Setup | Freshdesk](https://support.freshdesk.com/support/solutions/articles/234371-team-dashboards-setup-and-functionality)
- [Freshdesk Dashboards | Geckoboard](https://www.geckoboard.com/product/data-sources/freshdesk/)

---

### Intercom
**Key UI Patterns:**
- **CSAT Score Over Time:** Line graph tracking satisfaction trends across teammates and AI agents
- **Overview Report:** Unified view of human + automated support with side-by-side performance
- **Conversation Ratings Chart:** Filter by negative CSAT to prioritise problem areas
- **CX Score:** AI-generated alternative that addresses survey bias
- **Remarks Breakdown:** Visual charts for Amazing/Great/OK/Bad/Terrible ratings

**Design Recommendations:**
- Display CSAT as both a percentage (e.g., 95%) and emoji-based ratings
- Compare teammate vs. AI performance in a unified dashboard
- Track CSAT response rates to ensure survey timing is optimal
- Use drill-down capabilities to view individual conversation remarks

**Sources:**
- [Intercom CSAT Reporting](https://www.intercom.com/help/en/articles/10244420-customer-satisfaction-csat-reporting)
- [Holistic Overview Report | Intercom](https://www.intercom.com/help/en/articles/3008200-holistic-overview-report)
- [Intercom CX Score](https://www.intercom.com/help/en/articles/10495092-understand-customer-experience-at-scale-with-the-cx-score)

---

### ServiceNow
**Key UI Patterns:**
- **Role-Specific Dashboards:** CEO Dashboard (three-pane real-time view), CISO Dashboard (security operations heatmap)
- **Heatmaps:** Highlight risks by impact and likelihood
- **Dashboard Tabs:** Organise multiple views without cluttering the screen
- **Grid-Based Layout:** Flexible widget arrangement for visual appeal
- **Conditional Formatting:** Draw attention to key rows requiring action

**Design Recommendations:**
- Create Executive vs. Operational dashboard variants
- Use heatmaps for ticket priority distribution (Critical/High/Medium/Low)
- Standardise colours, fonts, and layouts across dashboards
- Implement dashboard tabs for different time periods or service categories
- Start with ServiceNow templates for ITSM best practices

**Sources:**
- [ServiceNow Dashboards Guide | Perspectium](https://www.perspectium.com/blog/servicenow-dashboards/)
- [10 Essential Tips for ServiceNow Dashboards](https://www.esolutionsone.com/10-tips-for-creating-better-servicenow-dashboards-for-your-users)
- [ServiceNow KPI Dashboard Guide](https://www.perspectium.com/blog/servicenow-kpi-dashbaord/)

---

### Jira Service Management
**Key UI Patterns:**
- **SLA Timer Display:** Shows time left on the clock; turns yellow then red when breached
- **Hover Tooltips:** Display data towards SLA goal when hovering over SLA items
- **Queue Customisation:** Sort by remaining time to resolution; pressing issues listed first
- **Cross-Project Monitoring:** Third-party tools allow SLA monitoring across multiple projects
- **Daily Filters:** Automatically display all issues that breached SLA in last 24 hours

**Design Recommendations:**
- Use timer-based SLA display with colour progression (green → yellow → red)
- Sort queues by remaining time by default
- Implement tooltip overlays for additional SLA context
- Create daily breach reports with automated notifications
- Customise queue columns to show Priority, Status, Assignee, SLA status

**Sources:**
- [Jira SLA Best Practices | Deviniti](https://deviniti.com/blog/enterprise-software/jira-service-management-sla/)
- [Jira Queue Management Guide | Deviniti](https://deviniti.com/blog/customer-it-service/jira-queue-management/)
- [SLA Display Formats | Jira](https://confluence.atlassian.com/servicedeskserver/how-teams-see-slas-946617611.html)

---

## 2. Visualisation Techniques by Metric Type

### SLA Compliance Percentage

**Best Visualisation: Gauge Chart (Radial Meter)**
- **Design Pattern:** Circular gauge with colour-coded zones (red/yellow/green)
- **Threshold Recommendations:**
  - Red: 0-89% (Critical - Under Target)
  - Yellow: 90-94% (Warning - At Risk)
  - Green: 95-100% (Healthy - Meeting Target)
- **Formula:** `(Tickets Resolved Within SLA ÷ Total Tickets) × 100`
- **Layout:** Place multiple gauges side-by-side for comparative KPIs (First Response SLA, Resolution SLA, Overall Compliance)

**Alternative Visualisation: Progress Bar with Percentage**
- More space-efficient for mobile views
- Can stack multiple SLA types vertically

**Sources:**
- [Gauge Chart for KPIs | Chart Engine](https://chartengine.io/gauge-chart/)
- [SLA Compliance Measurement | Freshworks](https://www.freshworks.com/itsm/sla/metrics/)
- [SLA Compliance Formula | KPI Depot](https://kpidepot.com/kpi/service-level-agreement-sla-compliance-rate)

---

### Ticket Volume Trends Over Time

**Best Visualisation: Line Chart with Dual Axis**
- **Primary Axis:** Total ticket volume (created vs. resolved)
- **Secondary Axis:** Backlog trend (cumulative)
- **Time Ranges:** Last 7 days, 30 days, 90 days, 12 months
- **Design Elements:**
  - Use sparklines for quick trend indicators in summary cards
  - Highlight latest data point with accent colour or dot
  - Show mini-history (scrollable recent changes) to provide context

**Alternative Visualisation: Stacked Area Chart**
- Shows ticket composition by priority (P1/P2/P3/P4) over time
- Useful for understanding changing ticket mix

**Sources:**
- [Real-Time Dashboard UX Strategies | Smashing Magazine](https://www.smashingmagazine.com/2025/09/ux-strategies-real-time-dashboards/)
- [Dashboard Design Principles | UXPin](https://www.uxpin.com/studio/blog/dashboard-design-principles/)

---

### Aging Tickets (Backlog Buckets)

**Best Visualisation: Horizontal Stacked Bar Chart**
- **Bucket Structure:**
  - 0-24 hours (Green - Fresh)
  - 1-3 days (Yellow - Aging)
  - 4-7 days (Orange - Old)
  - 7+ days (Red - Critical Backlog)
- **Design Pattern:** Each bar represents a priority level (P1/P2/P3/P4)
- **Interactivity:** Click to drill down into specific bucket for ticket list

**Alternative Visualisation: Heat Map Matrix**
- Rows: Priority levels (P1-P4)
- Columns: Age buckets (0-24h, 1-3d, 4-7d, 7d+)
- Colour intensity: Ticket count (darker = more tickets)

**ITIL Priority Time Frames:**
- P1 (Critical): Target resolution within 1-2 hours
- P2 (High): Target resolution within 4-8 hours
- P3 (Medium): Target resolution within 24-48 hours
- P4 (Low): Target resolution within 3-5 days

**Sources:**
- [Ticket Backlog Analysis | Jnana Analytics](https://www.jnanaanalytics.com/blogs/ticket-backlogs)
- [Reduce Support Ticket Backlog | Swifteq](https://swifteq.com/post/reduce-support-tickets)
- [Zendesk Backlog Evolution](https://support.zendesk.com/hc/en-us/articles/4409155859610-Understanding-backlog-evolution)

---

### Customer Satisfaction (CSAT) Score

**Best Visualisation: Large Number with Trend Indicator**
- **Format:** `92%` with small up/down arrow and +/- change
- **Supporting Chart:** Line graph showing CSAT over time (last 30/90 days)
- **Breakdown:** Emoji-based ratings distribution (😀 Great, 😐 Okay, 😞 Poor)
- **Comparative View:** CSAT by team, agent, or ticket type

**Alternative Visualisation: Donut Chart**
- Shows percentage breakdown of positive/neutral/negative ratings
- Centre displays overall CSAT percentage

**Best Practices:**
- Track CSAT response rate separately (low response = biased data)
- Filter by date range, channel, teammate, or team
- Display remarks/comments for negative CSAT ratings

**Sources:**
- [Intercom CSAT Reporting](https://www.intercom.com/help/en/articles/10244420-customer-satisfaction-csat-reporting)
- [Intercom CX Score](https://www.intercom.com/help/en/articles/10495092-understand-customer-experience-at-scale-with-the-cx-score)

---

### System Availability/Uptime

**Best Visualisation: Uptime Percentage with Status Bar**
- **Format:** `99.8% uptime` (last 30 days)
- **Status Bar:** Visual timeline showing uptime (green) vs. downtime (red) events
- **Supporting Metrics:**
  - Mean Time To Resolution (MTTR) for incidents
  - Number of incidents by severity
  - Planned vs. unplanned downtime

**Alternative Visualisation: Calendar Heat Map**
- Each day is a cell coloured by uptime percentage
- Quickly identify patterns (e.g., issues on Mondays, after deployments)

**Sources:**
- [ServiceNow Dashboard Examples](https://www.suretysystems.com/insights/servicenow-dashboards-surety-systems/)

---

### Service Credit/Debit Tracking

**Best Visualisation: Financial Ledger Table with Balance Summary**
- **Summary Cards:** Total Credits, Total Debits, Net Balance (prominently displayed)
- **Transaction Table:** Date, Type (Credit/Debit), Amount, Reason, Running Balance
- **Trend Chart:** Line graph showing credit balance over time
- **Filters:** By date range, client, service type

**Design Recommendations:**
- Use green for credits, red for debits
- Display currency or custom credit units
- Include auditable ledger with all balance changes
- Show expirations and credit purchases
- Implement real-time balance tracking

**Healthcare SaaS Context:**
- Integrate with revenue cycle management (RCM) platforms
- Track SLA breach penalties as debits
- Display credits earned for exceeding SLAs
- Show impact on contract terms/pricing

**Sources:**
- [SaaS Billing with Credits | Orb](https://www.withorb.com/blog/saas-billing-service)
- [Healthcare Financial Software | Jorie AI](https://www.jorie.ai/post/7-best-healthcare-financial-software-for-hospitals-clinics)
- [Healthcare Payment Solutions | Phreesia](https://www.phreesia.com/healthcare-payment-solutions/)

---

### First Response Time (FRT) Metrics

**Best Visualisation: KPI Card with Histogram**
- **Primary Metric:** Average FRT (e.g., 2h 15m)
- **Target Comparison:** "Target: 4h" with progress bar
- **Distribution Histogram:** Shows frequency of response times (bucket by hour ranges)

**Supporting Metrics:**
- FRT by priority level (P1 should be fastest)
- FRT by team or agent (identify training opportunities)
- Percentage meeting FRT SLA

**Sources:**
- [SLA Metrics for IT Service Delivery | ManageEngine](https://www.manageengine.com/products/service-desk/itsm/sla-metrics.html)

---

### Resolution Time Metrics

**Best Visualisation: Box Plot or Violin Plot**
- Shows median, quartiles, and outliers for resolution times
- Useful for identifying tickets taking unusually long

**Alternative Visualisation: KPI Card with Breakdown**
- **Primary Metric:** Average Resolution Time (e.g., 18h)
- **Breakdown Table:** By priority (P1: 2h, P2: 8h, P3: 24h, P4: 5d)
- **Trend Line:** Weekly average resolution time

**Sources:**
- [SLA Metrics | Freshworks](https://www.freshworks.com/itsm/sla/metrics/)

---

## 3. Healthcare IT Support Dashboard Best Practices

### Design Principles

#### 1. Know Your Audience (Role-Based Design)
- **Executives:** High-level KPIs, strategic trends, compliance metrics
- **Support Managers:** Team performance, SLA adherence, backlog management
- **Support Agents:** Individual ticket queues, SLA timers, knowledge base access
- **Healthcare Administrators:** System availability, patient impact, security incidents

**Design Recommendation:**
- Create separate dashboard views for each role
- Use role-based access control (RBAC) for data sensitivity
- Allow users to toggle between "My Performance" and "Team Performance"

#### 2. Clean, Uncluttered Layout
- **One-Screen Approach:** Fit all critical information on a single screen (no scrolling)
- **Visual Hierarchy:** Most important metrics at top, supporting data in middle, detailed breakdowns at bottom
- **White Space:** Use padding and margins generously to avoid overwhelm
- **Progressive Disclosure:** Start with overview; allow drill-down for details

**Grid Layout Recommendation:**
- Use 12-column grid for desktop
- 4-column grid for tablet
- 2-column grid for mobile
- 8px spacing increments for consistent scaling

#### 3. Real-Time Updates for Critical Metrics
- **Operational Dashboards:** Real-time or near-real-time data refresh (30s-1m intervals)
- **Executive Dashboards:** Daily or weekly refresh sufficient for strategic trends
- **Visual Indicators:** Show "Last Updated" timestamp prominently
- **Auto-Refresh:** Configurable auto-refresh with pause/resume controls

**Implementation:**
- Use WebSocket connections for live ticket updates
- Implement optimistic UI updates for user actions
- Show loading skeletons during data fetches

#### 4. Interactive Elements
- **Filters:** Date range, priority, team, ticket type, client
- **Drill-Down:** Click on chart segments to view underlying data
- **Sorting:** Allow users to sort tables by any column
- **Hover States:** Display tooltips with additional context

#### 5. Security & Compliance (HIPAA)
- **Data Anonymisation:** De-identify patient information in support metrics
- **Access Controls:** Row-level security based on user role
- **Audit Logs:** Track who accessed what data and when
- **Encryption:** Ensure data in transit and at rest is encrypted

**Sources:**
- [Healthcare Dashboard Best Practices | Thinkitive](https://www.thinkitive.com/blog/best-practices-in-healthcare-dashboard-design/)
- [Healthcare Dashboard Design | Fuselab Creative](https://fuselabcreative.com/healthcare-dashboard-design-best-practices/)
- [Healthcare UI Design 2025 | Eleken](https://www.eleken.co/blog-posts/user-interface-design-for-healthcare-applications)
- [Healthcare Dashboard Examples | Upsolve AI](https://upsolve.ai/blog/healthcare-dashboard-examples)

---

## 4. Executive vs. Operational Dashboard Design

### Executive/Strategic Dashboards

**Purpose:** Monitor long-term performance against enterprise-wide goals

**Key Characteristics:**
- **Audience:** C-suite executives, senior management (1-2 primary users)
- **Update Frequency:** Weekly or monthly
- **Data Granularity:** High-level summaries and trends
- **Time Horizon:** Quarters, years (long-term strategy)
- **Metrics Focus:**
  - Overall SLA compliance %
  - Customer satisfaction trends
  - Support cost per ticket
  - Ticket volume trends (monthly/quarterly)
  - Revenue impact of support (upsell opportunities, churn prevention)

**Design Patterns:**
- **Layout:** Compact, simple visualisations for at-a-glance understanding
- **Charts:** Line charts for trends, gauge charts for KPI achievement
- **Colours:** Minimal colour palette; use sparingly for emphasis
- **Narrative:** Include context and insights, not just raw numbers

**Example Layout:**
```
┌─────────────────────────────────────────────────────┐
│ Executive Support Dashboard - Q1 2026              │
├─────────────────────────────────────────────────────┤
│ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐        │
│ │ SLA    │ │ CSAT   │ │ Backlog│ │ Cost/  │        │
│ │ 96%    │ │ 94%    │ │ -12%   │ │ Ticket │        │
│ │ ↑ 2%   │ │ ↑ 3%   │ │        │ │ $24.50 │        │
│ └────────┘ └────────┘ └────────┘ └────────┘        │
│                                                     │
│ ┌─────────────────────────────────────────────┐    │
│ │ Ticket Volume Trend (Last 12 Months)        │    │
│ │ [Line chart: Created vs. Resolved]          │    │
│ └─────────────────────────────────────────────┘    │
│                                                     │
│ ┌─────────────────────────────────────────────┐    │
│ │ CSAT by Service Category (Quarterly)        │    │
│ │ [Horizontal bar chart]                      │    │
│ └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

---

### Operational Dashboards

**Purpose:** Provide real-time snapshot of day-to-day performance

**Key Characteristics:**
- **Audience:** Support managers, team leads, front-line agents
- **Update Frequency:** Real-time or near-real-time (30s-5m intervals)
- **Data Granularity:** Detailed, actionable metrics
- **Time Horizon:** Today, this week (immediate focus)
- **Metrics Focus:**
  - Open tickets by priority
  - SLA timers (approaching breach)
  - Tickets assigned to me/my team
  - First response time (today)
  - Aging ticket distribution

**Design Patterns:**
- **Layout:** Information-dense; multiple widgets
- **Charts:** Real-time counters, status indicators, colour-coded alerts
- **Colours:** Traffic light system (red/yellow/green) for urgency
- **Interactivity:** Click to view ticket details, claim unassigned tickets

**Example Layout:**
```
┌─────────────────────────────────────────────────────┐
│ Support Operations Dashboard - Live                │
├─────────────────────────────────────────────────────┤
│ ┌──────────┐ ┌──────────┐ ┌──────────┐            │
│ │ Open P1  │ │ SLA At   │ │ Unassgnd │            │
│ │ 3 🔴     │ │ Risk: 12 │ │ 8        │            │
│ └──────────┘ └──────────┘ └──────────┘            │
│                                                     │
│ ┌─────────────────────────────────────────────┐    │
│ │ Tickets Approaching SLA Breach              │    │
│ │ [Table: ID, Client, Priority, Time Left]    │    │
│ │ #1234 | Mercy Hosp | P2 | 🟡 45m remaining  │    │
│ │ #1235 | St John's  | P1 | 🔴 -5m (BREACHED)│    │
│ └─────────────────────────────────────────────┘    │
│                                                     │
│ ┌─────────────────────────────────────────────┐    │
│ │ Aging Tickets by Priority                   │    │
│ │ [Stacked bar: 0-24h|1-3d|4-7d|7d+]         │    │
│ └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

---

### Design Comparison Table

| Aspect | Executive Dashboard | Operational Dashboard |
|--------|-------------------|---------------------|
| **Primary User** | Executives, senior leaders | Managers, agents, team leads |
| **Update Frequency** | Weekly/Monthly | Real-time (30s-5m) |
| **Time Horizon** | Quarters, years | Today, this week |
| **Data Granularity** | Summarised, aggregated | Detailed, granular |
| **Interactivity** | Low (static reports) | High (click to act) |
| **Visual Density** | Sparse, clean | Dense, information-rich |
| **Colour Use** | Minimal, subtle | Bold, attention-grabbing |
| **Metrics Count** | 4-8 key KPIs | 12-20 operational metrics |
| **Navigation** | Single screen preferred | Tabs, filters, drill-downs |

**Sources:**
- [Operational vs. Executive Dashboards | Domo](https://www.domo.com/learn/article/operational-vs-executive-dashboards)
- [Types of Dashboards | Yellowfin BI](https://www.yellowfinbi.com/blog/operational-strategic-or-analytical-dashboard-which-type-best-for-bi)
- [4 Types of Dashboards | Klipfolio](https://www.klipfolio.com/blog/starter-guide-to-dashboards)
- [Executive Dashboard Design | MarkerHire](https://marketerhire.com/blog/executive-dashboard)

---

## 5. Colour Schemes & Accessibility

### Colour Palette Recommendations

#### Status/Alert Colours (Traffic Light System)
- **Critical/Error:** `#DC2626` (Red 600) - SLA breached, system down, P1 tickets
- **Warning/Caution:** `#F59E0B` (Amber 500) - Approaching SLA breach, P2 tickets
- **Success/Healthy:** `#10B981` (Green 500) - SLA met, system operational, resolved
- **Info/Neutral:** `#3B82F6` (Blue 500) - FYI notifications, general info
- **Muted/Low Priority:** `#6B7280` (Grey 500) - P4 tickets, archived items

#### Primary Brand Colours (Healthcare-Appropriate)
- **Primary Blue:** `#2563EB` (Blue 600) - Professional, trustworthy, calming
- **Secondary Teal:** `#14B8A6` (Teal 500) - Healthcare-associated, fresh
- **Accent Purple:** `#7C3AED` (Violet 600) - Modern, innovative

#### Background & Text
- **Background (Light Mode):** `#FFFFFF` (Pure white) or `#F9FAFB` (Grey 50)
- **Background (Dark Mode):** `#111827` (Grey 900) or `#1F2937` (Grey 800)
- **Primary Text (Light):** `#111827` (Grey 900) - 12.63:1 contrast on white
- **Secondary Text (Light):** `#6B7280` (Grey 500) - 4.61:1 contrast on white
- **Primary Text (Dark):** `#F9FAFB` (Grey 50) - High contrast on dark backgrounds

### Accessibility Standards (WCAG 2.1 Level AA)

#### Contrast Requirements
- **Normal Text:** Minimum 4.5:1 contrast ratio
- **Large Text (18pt+ or 14pt bold+):** Minimum 3:1 contrast ratio
- **Graphics and UI Components:** Minimum 3:1 contrast ratio
- **Target:** Aim for 7:1 (Level AAA) for critical data

#### Colour-Blind Safe Design
- **Do Not Rely on Colour Alone:** Use icons, patterns, labels in addition to colour
- **Red-Green Alternative:** Use red/blue or red/purple combinations instead
- **Orange Border + Red Background:** For alerts that red-green colour-blind users can distinguish
- **Patterns for Charts:** Use hatching, dots, stripes in addition to colour fills

**Recommended Tools:**
- **Colour Safe** (colorsafe.co) - Build WCAG-compliant palettes
- **Tanaguru Contrast Finder** - Find accessible colour alternatives
- **Adobe Colour** - Test for colour blindness (protanopia, deuteranopia, tritanopia)

#### Healthcare-Specific Considerations
- **Blue-to-Green Gradients:** Calming, professional, colour-blind safe
- **Avoid Pure Black/White:** Use `#111827` instead of `#000000`, `#F9FAFB` instead of `#FFFFFF`
- **Consistent Icons:** Use universally recognised symbols (✓ checkmark, ✗ cross, ⚠ warning triangle)

### Dark Mode Support
- Provide toggle between light and dark themes
- Maintain same contrast ratios in both modes
- Reduce eye strain for agents working long shifts
- Preserve colour meaning across themes (red = critical in both)

**Sources:**
- [Colour Palettes for Data Visualisation | Carbon Design](https://medium.com/carbondesign/color-palettes-and-accessibility-features-for-data-visualization-7869f4874fca)
- [Designing Colour-Blind Accessible Dashboards | Medium](https://medium.com/@courtneyjordan/designing-color-blind-accessible-dashboards-ba3e0084be82)
- [Accessible Colour Scheme Design | Envoy Design](https://medium.com/envoy-design/how-to-design-an-accessible-color-scheme-4a13ca12c92b)
- [Inclusive Website Colour Palettes | BrowserStack](https://www.browserstack.com/guide/color-palette-accessibility)
- [Tableau Dashboard Accessibility](https://help.tableau.com/current/pro/desktop/en-us/accessibility_dashboards.htm)

---

## 6. Mobile-Responsive Design Patterns

### Touch Target Requirements

#### Minimum Sizes (2025 Standards)
- **Touch Targets:** 48×48 pixels minimum (preferred: 56×56px)
- **Spacing Between Targets:** 8-16px to prevent accidental taps
- **Text Size:** Minimum 16px for body text, 14px for labels
- **Icon Size:** 24×24px minimum for interactive icons

#### Thumb-Friendly Navigation
- **Bottom Navigation Bar:** Ideal for 3-5 primary sections
- **Thumb Zone Design:** Place critical actions within natural thumb arc (lower two-thirds of screen)
- **Gesture Support:** Swipe to refresh, pull to load more, pinch to zoom charts
- **Floating Action Button (FAB):** For primary action (e.g., "Create Ticket")

### Layout Patterns

#### Responsive Grid Breakpoints
```
Desktop:  1280px+ (12-column grid)
Tablet:   768-1279px (8-column grid)
Mobile:   320-767px (4-column grid)
```

#### Mobile Dashboard Layout
```
┌─────────────────────────┐
│ ☰  Dashboard      🔔 (3)│  ← Header (sticky)
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │ SLA Compliance: 96% │ │  ← Key metric card
│ │ [Gauge chart]       │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │
│ │ Open Tickets: 23    │ │  ← Key metric card
│ │ P1: 2 🔴  P2: 8 🟡  │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │
│ │ My Tickets (5)      │ │  ← Scrollable list
│ │ #1234 | Mercy Hosp  │ │
│ │ P2 | 45m left 🟡   │ │
│ │ ─────────────────── │ │
│ │ #1235 | St John's   │ │
│ │ P1 | BREACHED 🔴   │ │
│ └─────────────────────┘ │
│                         │
├─────────────────────────┤
│ 📊 💬 👤 ⚙️             │  ← Bottom nav (44px tall)
└─────────────────────────┘
```

### Progressive Disclosure
- **Summary View:** Show only critical metrics on mobile
- **Expandable Sections:** Use accordions or cards that expand on tap
- **Dedicated Pages:** Move detailed charts to separate views
- **Filters Panel:** Slide-in drawer for filtering options

### Performance Optimisation
- **Skeleton Screens:** Show content placeholders during loading
- **Lazy Loading:** Load charts only when scrolled into view
- **Image Compression:** Use WebP format, 85% quality
- **Reduced Data:** Fetch smaller datasets for mobile (e.g., last 7 days vs. 90 days)

### Accessibility on Mobile
- **Larger Tap Targets:** 56×56px for critical actions
- **Voice Control Support:** Ensure all actions work with iOS/Android voice commands
- **Screen Reader Labels:** ARIA labels for all interactive elements
- **Haptic Feedback:** Provide tactile confirmation for button presses

**Sources:**
- [10 Tips for Mobile-Friendly Dashboards | Lightning Ventures](https://www.lightningventures.com.au/blogs/10-tips-for-mobile-friendly-dashboards)
- [Intuitive Mobile Dashboard UI | Toptal](https://www.toptal.com/designers/dashboard-design/mobile-dashboard-ui)
- [Mobile App Design Best Practices 2025 | Nerdify](https://getnerdify.com/blog/mobile-app-design-best-practices/)
- [Dashboard Design Trends 2025 | Fuselab Creative](https://fuselabcreative.com/top-dashboard-design-trends-2025/)

---

## 7. Real-Time vs. Historical Data Presentation

### Real-Time Dashboard Design

**Use Cases:**
- Operational support dashboards for agents and managers
- System monitoring (uptime, performance)
- Live SLA breach alerts
- Current queue status

**Design Patterns:**

#### 1. Blending Live + Historical Context
- Show current value prominently (large number)
- Include mini-history sparkline beneath (last 24 hours)
- Display percentage change vs. yesterday/last week
- Prevents knee-jerk reactions to normal fluctuations

**Example:**
```
Open Tickets: 47
[Sparkline showing last 24h: ▁▂▃▄▅▆▇█]
↑ 12% vs. yesterday
```

#### 2. Animated Charts for Real-Time Feeds
- Use smooth transitions when data updates
- Highlight latest data point with accent colour or pulsing dot
- Show "Live" indicator badge
- Include "Last Updated: 30s ago" timestamp

#### 3. Colour-Coded Status Indicators
- **Green Pulse:** System healthy, all SLAs met
- **Yellow Flash:** Warnings, approaching thresholds
- **Red Blink:** Critical alerts, SLA breaches
- **Grey Solid:** Paused or inactive

#### 4. Auto-Refresh Controls
- Configurable refresh intervals (15s, 30s, 1m, 5m)
- Pause/Resume button for users reviewing data
- Visual countdown timer showing next refresh

**Technical Considerations:**
- **WebSocket Connections:** For push-based updates (preferred)
- **Polling Intervals:** 30s-5m for REST API polling
- **Optimistic Updates:** Show user actions immediately, reconcile later
- **Rate Limiting:** Prevent server overload with too-frequent refreshes

---

### Historical Dashboard Design

**Use Cases:**
- Executive strategic dashboards
- Trend analysis and forecasting
- Performance reports (weekly, monthly, quarterly)
- Compliance audits

**Design Patterns:**

#### 1. Time Range Selectors
- **Presets:** Today, Yesterday, Last 7 days, Last 30 days, Last Quarter, Last Year
- **Custom Range:** Date picker for specific periods
- **Comparison Mode:** Compare current period to previous period (e.g., this month vs. last month)

**Example:**
```
┌────────────────────────────────────┐
│ Date Range: Last 30 Days ▼         │
│ ○ Today  ○ 7d  ● 30d  ○ 90d  ○ 1y │
└────────────────────────────────────┘
```

#### 2. Trend Visualisations
- **Line Charts:** Best for continuous time series data
- **Area Charts:** Show cumulative values or stacked categories
- **Bar Charts:** Compare discrete time periods (monthly totals)
- **Heat Maps:** Identify patterns by day-of-week or hour-of-day

#### 3. Data Granularity Controls
- **Zoom In:** Hourly → Daily → Weekly → Monthly → Quarterly
- **Drill-Down:** Click on data point to see underlying details
- **Brush Selection:** Drag to select time range for closer examination

#### 4. Annotations and Context
- Mark significant events (deployments, incidents, holidays)
- Show target/goal lines for KPIs
- Display moving averages to smooth out noise

---

### Hybrid Approach: Live + Historical

**Best for:** Dashboards serving both operational and strategic needs

**Design Pattern:**
```
┌─────────────────────────────────────────────────────┐
│ Current Status (Live)                   Last 30 Days│
├─────────────────────────────────────────────────────┤
│ ┌──────────┐                                        │
│ │ Open: 47 │  ← Live counter                        │
│ │ ↑ 12%    │  ← vs. average                         │
│ └──────────┘                                        │
│                                                     │
│ ┌─────────────────────────────────────────────┐    │
│ │ Ticket Volume Trend                         │    │
│ │ [Line chart: Last 30 days with "Now" marker]│    │
│ │                                 ●          │    │
│ │                                ╱           │    │
│ │                               ╱            │    │
│ │ ─────────────────────────────              │    │
│ │ Jan 1         Jan 15         Feb 1 (Now)   │    │
│ └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

**Key Principles:**
- **Visual Hierarchy:** Live data at top (larger), historical below (context)
- **Consistent Time Axis:** Use same time scale across related charts
- **Data Freshness Indicators:** Show when data was last updated
- **Materialized Views:** Pre-compute aggregations for fast historical queries

**Sources:**
- [UX Strategies for Real-Time Dashboards | Smashing Magazine](https://www.smashingmagazine.com/2025/09/ux-strategies-real-time-dashboards/)
- [Real-Time Data Visualisation | Tinybird](https://www.tinybird.co/blog/real-time-data-visualization)
- [Real-Time Dashboards: Are They Worth It? | Tinybird](https://www.tinybird.co/blog/real-time-dashboards-are-they-worth-it)
- [Dashboard Design UX Patterns | Pencil & Paper](https://www.pencilandpaper.io/articles/ux-pattern-analysis-data-dashboards)

---

## 8. Recommended Component Library & Design System

### Design System Choices for Healthcare B2B

#### Option 1: Tailwind UI + Headless UI (Recommended)
**Pros:**
- Highly customisable without fighting framework defaults
- Excellent accessibility out-of-the-box
- Responsive by default
- Large community, extensive documentation
- Professional, modern aesthetic

**Cons:**
- Requires building some components from scratch
- Learning curve for utility-first CSS

**Best For:** Custom healthcare dashboard with specific branding needs

---

#### Option 2: Shadcn/ui (Built on Radix UI + Tailwind)
**Pros:**
- Copy-paste components (no npm bloat)
- Built with accessibility in mind (Radix UI primitives)
- Modern, clean design
- Highly customisable
- Excellent TypeScript support

**Cons:**
- Relatively new (less battle-tested)
- Smaller ecosystem than Material UI

**Best For:** Rapid prototyping with modern stack (React + TypeScript)

---

#### Option 3: Material UI (MUI)
**Pros:**
- Comprehensive component library
- Excellent documentation
- Widely used in enterprise applications
- Built-in theming system
- Strong community support

**Cons:**
- Can look "generic" without customisation
- Larger bundle size
- Opinionated design (harder to deviate from Material Design)

**Best For:** Teams familiar with Material Design, rapid development

---

#### Option 4: Ant Design
**Pros:**
- Enterprise-focused components (complex tables, forms)
- Excellent data visualisation components
- Professional aesthetic
- Strong i18n support

**Cons:**
- Chinese-origin design language (may need customisation for Western markets)
- Larger bundle size
- Less flexible theming

**Best For:** Enterprise dashboards with complex data tables

---

### Chart Library Recommendations

#### Recharts (Recommended for React)
- Composable, declarative API
- Built on D3.js
- Responsive by default
- Good accessibility support

#### Apache ECharts
- Extremely powerful, feature-rich
- Excellent performance with large datasets
- Beautiful default themes
- Steeper learning curve

#### Chart.js
- Lightweight, simple API
- Good for basic charts
- Limited interactivity

---

## 9. Specific UI Patterns for Healthcare Support

### 1. Patient Impact Indicator
**Problem:** Support tickets affect real patients receiving care
**Solution:** Display "Patient Impact" badge on tickets

**Design:**
```
┌──────────────────────────────────────┐
│ Ticket #1234 | P1 | 🔴 BREACHED     │
│ ⚕️ High Patient Impact               │
│ 15 clinicians unable to access EHR   │
└──────────────────────────────────────┘
```

**Colour Coding:**
- 🔴 High Impact (patients affected, care disrupted)
- 🟡 Medium Impact (workflow disruption, no care impact)
- 🟢 Low Impact (cosmetic, training, enhancement requests)

---

### 2. Compliance Dashboard
**Problem:** Healthcare organisations must track regulatory compliance
**Solution:** Dedicated compliance metrics section

**Metrics:**
- **HIPAA Incident Response Time:** Target <1 hour
- **Security Patch Application:** Target <7 days
- **Audit Log Completeness:** Target 100%
- **Access Review Cadence:** Quarterly

**Visualisation:** Checklist with green checkmarks or red warning icons

---

### 3. On-Call Escalation Widget
**Problem:** Critical issues need immediate escalation paths
**Solution:** Prominent "Escalate" button with on-call rotation display

**Design:**
```
┌──────────────────────────────────────┐
│ On-Call Engineer: Sarah Chen         │
│ Mobile: *** *** **89 (Click to call) │
│ [Escalate to On-Call] button         │
└──────────────────────────────────────┘
```

---

### 4. Knowledge Base Integration
**Problem:** Agents need quick access to solutions
**Solution:** Contextual KB article suggestions based on ticket content

**Design:** Sidebar panel showing "Suggested Articles" with confidence scores

---

### 5. Multi-Tenant Client Selector
**Problem:** Support team manages multiple healthcare clients
**Solution:** Global client filter dropdown with quick-switch

**Design:**
```
┌────────────────────────────────────┐
│ Client: All Clients ▼              │
│ ☑ Mercy Hospital (23 open)         │
│ ☑ St John's Clinic (8 open)        │
│ ☑ City Health Network (15 open)    │
└────────────────────────────────────┘
```

---

## 10. Implementation Checklist

### Phase 1: Foundation (Week 1-2)
- [ ] Define user roles (Executive, Manager, Agent, Admin)
- [ ] Choose design system (Tailwind UI recommended)
- [ ] Set up colour palette (with dark mode support)
- [ ] Create responsive grid system (12/8/4 columns)
- [ ] Implement authentication and RBAC

### Phase 2: Core Metrics (Week 3-4)
- [ ] SLA compliance gauge charts
- [ ] Ticket volume line charts
- [ ] Aging ticket stacked bars
- [ ] CSAT score display
- [ ] Real-time open ticket counter

### Phase 3: Dashboard Views (Week 5-6)
- [ ] Executive dashboard (static, weekly refresh)
- [ ] Operational dashboard (real-time, 30s refresh)
- [ ] Agent personal dashboard (my tickets, my SLAs)
- [ ] Client-specific dashboard (multi-tenant filter)

### Phase 4: Interactivity (Week 7-8)
- [ ] Drill-down from charts to ticket lists
- [ ] Date range filters (presets + custom)
- [ ] Export to PDF/CSV functionality
- [ ] Dashboard customisation (drag-and-drop widgets)

### Phase 5: Mobile Optimisation (Week 9-10)
- [ ] Responsive layouts for tablet (768px+)
- [ ] Responsive layouts for mobile (320px+)
- [ ] Touch-friendly navigation (bottom bar)
- [ ] Progressive disclosure for detailed data

### Phase 6: Accessibility & Polish (Week 11-12)
- [ ] WCAG 2.1 Level AA contrast compliance
- [ ] Keyboard navigation support
- [ ] Screen reader testing (JAWS, NVDA, VoiceOver)
- [ ] Colour-blind testing (protanopia, deuteranopia)
- [ ] Loading states, empty states, error states
- [ ] Performance optimisation (< 3s initial load)

---

## 11. Key Takeaways

### Critical Success Factors
1. **Role-Based Design:** Different users need different views (exec vs. agent)
2. **Real-Time Where It Matters:** Operational dashboards need live data; executive dashboards do not
3. **Accessibility First:** 4.5:1 contrast, 48px touch targets, screen reader support
4. **Progressive Disclosure:** Start simple, allow drill-down for details
5. **Healthcare Context:** Patient impact, compliance tracking, on-call escalation

### Design Principles Priority
1. **Clarity** > Aesthetics (users must understand data instantly)
2. **Performance** > Features (fast dashboard beats feature-rich slow dashboard)
3. **Accessibility** > Novelty (WCAG compliance is non-negotiable)
4. **Mobile-Friendly** > Desktop-Only (60%+ access on mobile/tablet)
5. **Actionable** > Informational (every metric should drive a decision)

### Quick Reference: Metric → Visualisation Mapping

| Metric | Best Visualisation | Alternative |
|--------|-------------------|-------------|
| SLA Compliance % | Gauge Chart | Progress Bar |
| Ticket Volume Trend | Line Chart | Area Chart |
| Aging Tickets | Stacked Bar | Heat Map |
| CSAT Score | Large Number + Trend | Donut Chart |
| System Uptime | Status Bar + % | Calendar Heat Map |
| Service Credits | Ledger Table + Balance | Line Chart |
| First Response Time | KPI Card + Histogram | Box Plot |
| Resolution Time | KPI Card + Breakdown | Violin Plot |

---

## 12. Resources & Further Reading

### Design Systems
- [Tailwind UI](https://tailwindui.com/) - Premium component library
- [Shadcn/ui](https://ui.shadcn.com/) - Copy-paste accessible components
- [Material UI](https://mui.com/) - React component library
- [Radix UI](https://www.radix-ui.com/) - Unstyled, accessible primitives

### Chart Libraries
- [Recharts](https://recharts.org/) - Composable React charts
- [Apache ECharts](https://echarts.apache.org/) - Powerful visualisation library
- [Chart.js](https://www.chartjs.org/) - Simple JavaScript charts

### Accessibility Tools
- [Colour Safe](http://colorsafe.co/) - WCAG-compliant colour palettes
- [Adobe Colour](https://color.adobe.com/) - Colour blindness simulator
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/) - WCAG contrast checker
- [axe DevTools](https://www.deque.com/axe/devtools/) - Browser extension for accessibility testing

### Dashboard Examples & Inspiration
- [Geckoboard Dashboard Gallery](https://www.geckoboard.com/dashboard-examples/)
- [Dribbble: Dashboard Design](https://dribbble.com/tags/dashboard)
- [Mobbin: Dashboard UI Patterns](https://mobbin.com/)

---

## Appendix: Complete Source Bibliography

### Platform-Specific Research
- [Zendesk SLA Policies](https://support.zendesk.com/hc/en-us/articles/5604663490458-Using-SLA-policies)
- [Complete Guide to Zendesk SLAs | Swifteq](https://swifteq.com/post/zendesk-sla)
- [Tracking Zendesk SLA Metrics | Geckoboard](https://www.geckoboard.com/blog/track-zendesk-service-level-agreement-sla-metrics/)
- [Zendesk Dashboard Examples | Geckoboard](https://www.geckoboard.com/dashboard-examples/support/zendesk-dashboard/)
- [Freshdesk Analytics Introduction](https://support.freshdesk.com/support/solutions/articles/239757-introduction-to-analytics)
- [Freshdesk Dashboards | Geckoboard](https://www.geckoboard.com/product/data-sources/freshdesk/)
- [Better Analytics with Freshdesk](https://www.freshworks.com/freshdesk/reporting-analytics/)
- [Intercom CSAT Reporting](https://www.intercom.com/help/en/articles/10244420-customer-satisfaction-csat-reporting)
- [Intercom Holistic Overview Report](https://www.intercom.com/help/en/articles/3008200-holistic-overview-report)
- [Intercom CX Score](https://www.intercom.com/help/en/articles/10495092-understand-customer-experience-at-scale-with-the-cx-score)
- [ServiceNow Dashboards Guide | Perspectium](https://www.perspectium.com/blog/servicenow-dashboards/)
- [10 Essential Tips for ServiceNow Dashboards](https://www.esolutionsone.com/10-tips-for-creating-better-servicenow-dashboards-for-your-users)
- [Jira SLA Best Practices | Deviniti](https://deviniti.com/blog/enterprise-software/jira-service-management-sla/)
- [Jira Queue Management Guide | Deviniti](https://deviniti.com/blog/customer-it-service/jira-queue-management/)

### Healthcare-Specific
- [Healthcare Dashboard Best Practices | Thinkitive](https://www.thinkitive.com/blog/best-practices-in-healthcare-dashboard-design/)
- [Healthcare Dashboard Design | Fuselab Creative](https://fuselabcreative.com/healthcare-dashboard-design-best-practices/)
- [Healthcare UI Design 2025 | Eleken](https://www.eleken.co/blog-posts/user-interface-design-for-healthcare-applications)
- [Healthcare Dashboard Examples | Upsolve AI](https://upsolve.ai/blog/healthcare-dashboard-examples)
- [Healthcare Financial Software | Jorie AI](https://www.jorie.ai/post/7-best-healthcare-financial-software-for-hospitals-clinics)
- [Healthcare Payment Solutions | Phreesia](https://www.phreesia.com/healthcare-payment-solutions/)

### Executive vs. Operational Dashboards
- [Operational vs. Executive Dashboards | Domo](https://www.domo.com/learn/article/operational-vs-executive-dashboards)
- [Types of Dashboards | Yellowfin BI](https://www.yellowfinbi.com/blog/operational-strategic-or-analytical-dashboard-which-type-best-for-bi)
- [4 Types of Dashboards | Klipfolio](https://www.klipfolio.com/blog/starter-guide-to-dashboards)
- [Executive Dashboard Design | MarkerHire](https://marketerhire.com/blog/executive-dashboard)

### Accessibility & Colour
- [Colour Palettes for Data Visualisation | Carbon Design](https://medium.com/carbondesign/color-palettes-and-accessibility-features-for-data-visualization-7869f4874fca)
- [Designing Colour-Blind Accessible Dashboards | Medium](https://medium.com/@courtneyjordan/designing-color-blind-accessible-dashboards-ba3e0084be82)
- [Accessible Colour Scheme Design | Envoy Design](https://medium.com/envoy-design/how-to-design-an-accessible-color-scheme-4a13ca12c92b)
- [Inclusive Website Colour Palettes | BrowserStack](https://www.browserstack.com/guide/color-palette-accessibility)
- [Tableau Dashboard Accessibility](https://help.tableau.com/current/pro/desktop/en-us/accessibility_dashboards.htm)

### Mobile & Responsive Design
- [10 Tips for Mobile-Friendly Dashboards | Lightning Ventures](https://www.lightningventures.com.au/blogs/10-tips-for-mobile-friendly-dashboards)
- [Intuitive Mobile Dashboard UI | Toptal](https://www.toptal.com/designers/dashboard-design/mobile-dashboard-ui)
- [Mobile App Design Best Practices 2025 | Nerdify](https://getnerdify.com/blog/mobile-app-design-best-practices/)
- [Dashboard Design Trends 2025 | Fuselab Creative](https://fuselabcreative.com/top-dashboard-design-trends-2025/)

### Real-Time vs. Historical Data
- [UX Strategies for Real-Time Dashboards | Smashing Magazine](https://www.smashingmagazine.com/2025/09/ux-strategies-real-time-dashboards/)
- [Real-Time Data Visualisation | Tinybird](https://www.tinybird.co/blog/real-time-data-visualization)
- [Real-Time Dashboards: Are They Worth It? | Tinybird](https://www.tinybird.co/blog/real-time-dashboards-are-they-worth-it)
- [Dashboard Design UX Patterns | Pencil & Paper](https://www.pencilandpaper.io/articles/ux-pattern-analysis-data-dashboards)

### Visualisation Techniques
- [Gauge Chart for KPIs | Chart Engine](https://chartengine.io/gauge-chart/)
- [SLA Compliance Measurement | Freshworks](https://www.freshworks.com/itsm/sla/metrics/)
- [SLA Metrics for IT Service Delivery | ManageEngine](https://www.manageengine.com/products/service-desk/itsm/sla-metrics.html)
- [Ticket Backlog Analysis | Jnana Analytics](https://www.jnanaanalytics.com/blogs/ticket-backlogs)
- [Reduce Support Ticket Backlog | Swifteq](https://swifteq.com/post/reduce-support-tickets)

### Financial Tracking
- [SaaS Billing with Credits | Orb](https://www.withorb.com/blog/saas-billing-service)
- [SaaS Company Dashboard | Geckoboard](https://www.geckoboard.com/dashboard-examples/finance/saas-company-dashboard/)

---

**Document Version:** 1.0
**Last Updated:** 2026-01-08
**Author:** UI/UX Design Analysis
**Next Review:** 2026-04-08
