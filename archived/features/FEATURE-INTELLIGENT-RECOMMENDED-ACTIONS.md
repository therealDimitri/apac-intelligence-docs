# Feature: Intelligent Recommended Actions System

**Date:** 2025-12-03
**Version:** 2.0
**Component:** Client Page → Overview Tab → Recommended Actions Card
**File:** `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx` (lines 371-655)

---

## Overview

The Recommended Actions card provides intelligent, prioritized, real-time action suggestions based on comprehensive analysis of all available client data. The system automatically evaluates 14 different metrics across multiple data sources and surfaces the top 5 most critical actions CSEs should take.

## Key Features

### 1. **Intelligent Prioritization**

- **3-Tier Severity System**: Critical (Red) → Warning (Yellow) → Info (Blue)
- **Automatic Sorting**: Actions are automatically ordered by severity
- **Top 5 Display**: Shows only the most important actions to avoid overwhelming users
- **Total Count**: Displays "X of Y" to show how many actions are hidden

### 2. **Real-Time Data Refresh**

- **Reactive Updates**: Automatically updates when any underlying data changes
- **Hook-Based**: Leverages React hooks for real-time data fetching
- **No Manual Refresh**: Data stays current without user intervention

### 3. **Comprehensive Data Sources**

Pulls from **9 different data sources**:

- Client health score & status
- NPS scores and sentiment analysis
- Meeting history and recency
- Action items and overdue tasks
- Event compliance (tier-based)
- Compliance risk predictions (ML-based)
- Portfolio initiative progress
- Aging accounts / Working Capital
- Upcoming event deadlines

---

## Action Types (14 Total)

### 🔴 CRITICAL PRIORITY (Red Background)

#### 1. Critical Health Score

**Trigger**: `client.health_score < 50`
**Message**: "Critical health score (X/100) - Escalate to management"
**Icon**: AlertTriangle
**Purpose**: Immediate escalation for clients at severe risk

**Example**:

- Health Score: 42/100
- Status: Critical
- Action: Escalate to management for intervention plan

#### 2. Very Low NPS (Detractor Territory)

**Trigger**: `client.nps_score < -50`
**Message**: "Critical NPS (X) - Schedule urgent feedback session"
**Icon**: AlertTriangle
**Purpose**: Address severe customer dissatisfaction

**Example**:

- NPS: -67
- Status: Severe detractor risk
- Action: Schedule urgent feedback session with stakeholders

#### 3. No Client Contact in 90+ Days

**Trigger**: `daysSinceLastMeeting >= 90`
**Message**: "No contact in X days - Schedule check-in immediately"
**Icon**: Clock
**Purpose**: Re-engage at-risk clients before relationship deteriorates further

**Example**:

- Last Meeting: 112 days ago
- Status: Relationship at risk
- Action: Schedule immediate check-in call

#### 4. Critical Event Compliance (<50%)

**Trigger**: Any event type with `compliance_percentage < 50`
**Message**: "X event type(s) at critical status (<50% compliance)"
**Icon**: Target
**Purpose**: Address severe compliance gaps that could impact segment tier

**Example**:

- QBRs: 33% compliance (1 of 3 delivered)
- Status: Critical non-compliance
- Action\*\*: Log missed QBRs immediately

#### 5. High Risk Compliance Prediction

**Trigger**: `prediction.predicted_status === 'at-risk' && risk_score > 0.7`
**Message**: "High risk of compliance miss (X%) - Review risk factors"
**Icon**: AlertTriangle
**Purpose**: Proactive intervention based on ML predictions

**Example**:

- Risk Score: 82%
- Predicted Status: At Risk
- Action: Review risk factors and create mitigation plan

---

### ⚠️ WARNING PRIORITY (Yellow Background)

#### 6. Working Capital Risk

**Trigger**: `!agingData.compliance.meetsGoals`
**Message**: "Working Capital at risk - Review aging receivables"
**Icon**: DollarSign
**Purpose**: Address accounts receivable aging issues

**Example**:

- Under 60 days: 78% (target: 90%)
- Under 90 days: 92% (target: 100%)
- Action: Review aging AR and collection strategy

#### 7. Low NPS Score

**Trigger**: `client.nps_score >= -50 && nps_score < 0`
**Message**: "Low NPS (X) - Address customer satisfaction"
**Icon**: TrendingDown
**Purpose**: Improve customer satisfaction before it becomes critical

**Example**:

- NPS: -18
- Status: Detractor territory
- Action: Conduct satisfaction survey and address concerns

#### 8. No Meeting in 30-89 Days

**Trigger**: `daysSinceLastMeeting >= 30 && daysSinceLastMeeting < 90`
**Message**: "No meeting in X days - Schedule client check-in"
**Icon**: Calendar
**Purpose**: Maintain regular engagement cadence

**Example**:

- Last Meeting: 47 days ago
- Expected Cadence: 30 days (based on segment)
- Action: Schedule next check-in within 2 weeks

#### 9. Overdue Actions

**Trigger**: `overdueActions.length > 0`
**Message**: "Complete X overdue action(s)"
**Icon**: CheckCircle2
**Purpose**: Close action items to demonstrate follow-through

**Example**:

- Overdue Actions: 3
- Oldest: 23 days overdue
- Action: Complete overdue commitments ASAP

#### 10. At-Risk Event Types (50-79% Compliance)

**Trigger**: Event types with `compliance_percentage >= 50 && < 80`
**Message**: "X event type(s) at risk (50-79% compliance)"
**Icon**: Target
**Purpose**: Address moderate compliance gaps before they become critical

**Example**:

- RoadMap Reviews: 67% compliance (2 of 3 delivered)
- Status: At risk
- Action: Schedule remaining roadmap review

---

### 💡 INFORMATIONAL ACTIONS (Blue Background)

#### 11. Log Remaining Events

**Trigger**: `compliance.overall_compliance_score < 100`
**Message**: "Log X remaining event(s) to achieve 100% compliance"
**Icon**: Lightbulb
**Purpose**: Complete segmentation requirements

**Example**:

- Compliant Event Types: 7 of 9
- Remaining: 2 event types
- Action: Log 2 remaining events (e.g., Account Planning, Executive Briefing)

#### 12. Moderate Compliance Risk

**Trigger**: `prediction.predicted_status === 'at-risk' && risk_score <= 0.7`
**Message**: "Moderate compliance risk (X%) - Monitor progress"
**Icon**: Activity
**Purpose**: Stay aware of potential compliance issues

**Example**:

- Risk Score: 58%
- Predicted Status: At Risk
- Action: Monitor progress and plan to mitigate risk factors

#### 13. Portfolio Initiatives Need Attention

**Trigger**: `completionRate < 50 && portfolioStats.inProgress > 0`
**Message**: "X active initiative(s) - Accelerate delivery"
**Icon**: Briefcase
**Purpose**: Drive portfolio initiative completion

**Example**:

- Total Initiatives: 12
- Completed: 4 (33%)
- In Progress: 6
- Action: Accelerate delivery of active initiatives

#### 14. Upcoming Events (Next 2 Weeks)

**Trigger**: Events with `event_date` within 14 days
**Message**: "X event(s) due in next 2 weeks - Prepare"
**Icon**: Calendar
**Purpose**: Proactive event preparation

**Example**:

- Upcoming Events: 2
  - QBR: Due in 8 days
  - Executive Briefing: Due in 13 days
- Action: Prepare agendas and materials

---

## Technical Architecture

### Data Flow

```
React Component (RightColumn)
    ↓
Multiple Hooks (Real-time data fetching)
    ├─ useActions() → Client actions, overdue tracking
    ├─ useMeetings() → Meeting history, recency
    ├─ useEventCompliance() → Event compliance by type
    ├─ useCompliancePredictions() → ML risk predictions
    ├─ useAgingAccounts() → Working capital metrics
    ├─ usePortfolioInitiatives() → Initiative progress
    ├─ useSegmentationEvents() → Upcoming events
    └─ client prop → Health score, NPS, status
    ↓
ActionItem[] Array (14 possible actions)
    ↓
Priority Sorting (critical → warning → info)
    ↓
Slice to Top 5
    ↓
Render with color-coded badges
```

### Type System

```typescript
type ActionItem = {
  icon: any // Lucide icon component
  text: string // Action description
  severity: 'critical' | 'warning' | 'info' // Priority level
  color: string // Text color class
  bgColor: string // Background color class
  borderColor: string // Border color class
  onClick: () => void // Click handler
}

const actionItems: ActionItem[] = []

const severityOrder: Record<ActionItem['severity'], number> = {
  critical: 0,
  warning: 1,
  info: 2,
}
```

### Calculation Logic

#### Example: Days Since Last Meeting

```typescript
const clientMeetings = meetings.filter(
  m => m.client.toLowerCase() === client.name.toLowerCase()
)

const lastMeeting = clientMeetings.length > 0
  ? clientMeetings.sort((a, b) =>
      new Date(b.date).getTime() - new Date(a.date).getTime()
    )[0]
  : null

const daysSinceLastMeeting = lastMeeting
  ? Math.floor((new Date().getTime() - new Date(lastMeeting.date).getTime()) / (1000 * 60 * 60 * 24))
  : null

// Then check thresholds:
if (daysSinceLastMeeting >= 90) → Critical
if (daysSinceLastMeeting >= 30 && < 90) → Warning
```

#### Example: Event Compliance Tiers

```typescript
const criticalEvents = compliance.event_compliance.filter(ec => ec.compliance_percentage < 50) // → Critical: < 50%

const atRiskEvents = compliance.event_compliance.filter(
  ec => ec.compliance_percentage >= 50 && ec.compliance_percentage < 80
) // → Warning: 50-79%

// Info: Remaining events to log
const remainingCount = compliance.total_event_types_count - compliance.compliant_event_types_count
```

---

## UI/UX Design

### Card Layout

```
┌────────────────────────────────────────────┐
│  ✨ Recommended Actions        (3 of 8)   │
│  Prioritized by severity & impact          │
├────────────────────────────────────────────┤
│                                            │
│  🔴 Critical health score (42/100) -       │
│      Escalate to management                │
│                                            │
│  🔴 No contact in 112 days - Schedule      │
│      check-in immediately                  │
│                                            │
│  ⚠️ Working Capital at risk - Review       │
│      aging receivables                     │
│                                            │
│  ⚠️ Complete 3 overdue actions             │
│                                            │
│  💡 Log 2 remaining events to achieve      │
│      100% compliance                       │
│                                            │
└────────────────────────────────────────────┘
```

### Color Coding

- **Red (`bg-red-50`, `border-red-200`, `text-red-700`)**: Critical actions requiring immediate attention
- **Yellow (`bg-yellow-50`, `border-yellow-200`, `text-yellow-700`)**: Warnings that should be addressed soon
- **Blue (`bg-blue-50`, `border-blue-200`, `text-blue-700`)**: Informational actions to improve performance

### Icons

All icons from `lucide-react`:

- AlertTriangle: Health & risk alerts
- Clock: Meeting recency
- Target: Compliance issues
- DollarSign: Financial metrics
- TrendingDown: NPS/satisfaction
- Calendar: Meeting scheduling
- CheckCircle2: Action completion
- Lightbulb: Informational tips
- Activity: Risk monitoring
- Briefcase: Portfolio initiatives

---

## Business Logic

### Priority Calculation

1. **Evaluate all 14 action types** across all data sources
2. **Filter triggered actions** (only add if condition is met)
3. **Sort by severity** using `severityOrder` mapping
4. **Limit to top 5** to avoid overwhelming users
5. **Display count** showing total vs. shown (e.g., "3 of 8")

### Real-Time Updates

The card re-renders whenever any hook data changes:

- **Actions created/completed** → Recalculate overdue count
- **New meetings logged** → Update meeting recency
- **Events logged** → Recalculate compliance scores
- **Health score changes** → Update critical alerts
- **NPS responses** → Update satisfaction alerts

**No manual refresh required** - all data is reactive via React hooks.

---

## Example Scenarios

### Scenario 1: Critical Client Situation

**Client State**:

- Health Score: 38/100
- NPS: -72
- Last Meeting: 127 days ago
- Overdue Actions: 5
- Event Compliance: 42%

**Recommended Actions Displayed** (Top 5):

1. 🔴 Critical health score (38/100) - Escalate to management
2. 🔴 Critical NPS (-72) - Schedule urgent feedback session
3. 🔴 No contact in 127 days - Schedule check-in immediately
4. 🔴 1 event type at critical status (<50% compliance)
5. ⚠️ Complete 5 overdue actions

**Hidden Actions** (3): 6. ⚠️ Working Capital at risk 7. ⚠️ Low NPS (-72) - Address customer satisfaction 8. 💡 Log 6 remaining events

**Total**: Showing 5 of 8 actions

---

### Scenario 2: Healthy Client with Minor Issues

**Client State**:

- Health Score: 82/100
- NPS: 45
- Last Meeting: 18 days ago
- Overdue Actions: 0
- Event Compliance: 89%

**Recommended Actions Displayed** (Top 2):

1. 💡 Log 1 remaining event to achieve 100% compliance
2. 💡 3 events due in next 2 weeks - Prepare

**Total**: Showing 2 of 2 actions

---

### Scenario 3: At-Risk Client Trending Positive

**Client State**:

- Health Score: 67/100
- NPS: -8
- Last Meeting: 34 days ago
- Overdue Actions: 1
- Event Compliance: 78%
- Risk Prediction: 45% (Moderate)

**Recommended Actions Displayed** (Top 5):

1. ⚠️ No meeting in 34 days - Schedule client check-in
2. ⚠️ Complete 1 overdue action
3. ⚠️ 2 event types at risk (50-79% compliance)
4. 💡 Moderate compliance risk (45%) - Monitor progress
5. 💡 Log 2 remaining events to achieve 100% compliance

**Total**: Showing 5 of 5 actions

---

## Future Enhancements

### Phase 1: Action Handlers (Next Sprint)

- **Clickable Actions**: Implement `onClick` handlers
- **Deep Links**: Navigate to relevant pages/sections
- **Quick Actions**: Inline buttons (e.g., "Schedule Meeting", "Log Event")

### Phase 2: Customization

- **User Preferences**: Allow CSEs to customize priority thresholds
- **Dismissed Actions**: "Snooze" or "Dismiss" specific actions
- **Notification Settings**: Email/Slack alerts for critical actions

### Phase 3: Advanced Intelligence

- **Trend Analysis**: Show action trends over time
- **Impact Scoring**: Calculate business impact of each action
- **Success Tracking**: Measure outcomes when actions are completed
- **ML Recommendations**: Use AI to suggest optimal action timing

### Phase 4: Team-Wide View

- **Manager Dashboard**: Aggregate actions across all CSEs' clients
- **Benchmarking**: Compare action frequency across teams
- **Workload Balancing**: Identify CSEs with too many critical actions

---

## Monitoring & Metrics

### Success Criteria

**Goal**: Help CSEs take the right actions at the right time to improve client outcomes

**Metrics to Track**:

1. **Action Completion Rate**: % of displayed actions that get resolved
2. **Time to Action**: Days from action appearing to being addressed
3. **Client Health Improvement**: Change in health score after action taken
4. **Compliance Improvement**: Change in compliance score after action taken
5. **NPS Recovery**: Change in NPS after satisfaction actions

### A/B Testing Opportunities

- **Action Limit**: Test 5 vs. 7 vs. 10 displayed actions
- **Severity Thresholds**: Adjust when actions trigger (e.g., NPS < -30 vs. < -50)
- **Messaging**: Test different action text variations
- **Visual Design**: Test icon choices, color schemes

---

## Technical Notes

### Performance Considerations

- **Hook Efficiency**: All data hooks use React Query with caching
- **Memoization**: Consider `useMemo` for expensive calculations if needed
- **Render Optimization**: Re-renders only when data actually changes
- **Lazy Loading**: Card only calculates when Overview tab is active

### Error Handling

- **Graceful Degradation**: If a data source fails, only that action is skipped
- **Null Safety**: All data checks use optional chaining (`?.`)
- **Empty State**: Card hides entirely if no actions (clean UI)

### Type Safety

- **ActionItem Interface**: Strongly typed severity levels
- **Record Type**: Type-safe severity order mapping
- **Type Inference**: Full TypeScript support for all calculations

---

## Related Documentation

- [Event Compliance Feature](./FEATURE-EVENT-COMPLIANCE.md)
- [Working Capital / Aging AR](./FEATURE-AGING-ACCOUNTS-COMPLIANCE.md)
- [Compliance Predictions](./FEATURE-COMPLIANCE-PREDICTIONS.md)
- [Client Health Score](./FEATURE-CLIENT-HEALTH-SCORE.md)
- [NPS Analysis](./FEATURE-NPS-ANALYSIS.md)

---

**Version History**:

- **v1.0** (2024-11-15): Initial implementation with 4 actions
- **v2.0** (2025-12-03): Enhanced with 14 intelligent actions, priority sorting, real-time data

**Maintained By**: Claude Code
**Last Updated**: 2025-12-03
