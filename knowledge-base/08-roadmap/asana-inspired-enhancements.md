# Asana-Inspired Enhancements for APAC Intelligence

**Created**: 2026-02-08
**Status**: Planning
**Inspiration source**: [Asana Features](https://asana.com/features), [Asana Goals](https://asana.com/features/goals-reporting/goals), [Asana Portfolios](https://asana.com/features/goals-reporting/portfolios), [Asana Dashboards](https://asana.com/features/goals-reporting/reporting-dashboards), [Asana Workload](https://asana.com/features/resource-management/workload)

---

## Unique Advantages Over Asana

Before implementing Asana patterns, recognise what APAC Intelligence can do that Asana fundamentally cannot:

1. **Financial-goal alignment** — Tie BURC revenue data directly to goal progress ("This pillar's clients generated $2.1M vs $2.8M target")
2. **Client-centric context** — Goals are tied to specific clients with real NPS scores and revenue numbers
3. **AI with domain knowledge** — ChaSen knows clients, financials, and org structure. Asana's AI knows tasks and deadlines
4. **Single-pane-of-glass** — CSEs see goals, actions, meetings, client health, and financials in one app
5. **Auto-triggered from real data** — BURC sync can trigger goal status changes without manual intervention

**Strategy**: Adopt Asana's UX patterns (they've spent billions refining them) but fill them with unique APAC Intelligence data.

---

## Feature 1: Smart Status (AI-Generated Status Updates)

### What Asana Does
AI analyses project data (task completion rates, overdue items, blockers) and auto-generates a natural-language status summary. Users review, edit, and publish. Saves ~5 hours/week per portfolio manager.

### Our Implementation
**"Generate Status Update" button** on each goal detail page that:
- Pulls child goal progress, recent check-ins, overdue items, and blocking dependencies
- Cross-references BURC financials for revenue context (our differentiator)
- Generates a 2-3 sentence executive summary via ChaSen
- User edits before saving to a `goal_status_updates` table
- Shows a timeline of past status updates on the goal detail page

**Example output**: *"Growth pillar is 62% complete (6 of 9 company goals on track). Meditech ANZ expansion is at risk — 3 weeks overdue with no check-in since 15 Jan. Revenue contribution from Growth-aligned clients is $2.1M vs $2.8M target."*

### Dependencies
- New DB table: `goal_status_updates`
- New ChaSen tool: `generate_goal_status`
- New API route: `POST /api/goals/[id]/status-update`
- New component: `StatusUpdateTimeline`

### Impact: Very High | Complexity: Medium

---

## Feature 2: Structured Check-In System

### What Asana Does
Goals have periodic "status updates" — structured entries with status, progress, narrative, and blockers. Creates a timeline of updates.

### Our Implementation
**Structured check-in form** replacing ad-hoc progress updates:
- Fields: Status, progress %, what was accomplished, what's blocked, next steps
- Cadence setting per goal (weekly, fortnightly, monthly) — overdue check-in dots already exist
- Check-in history timeline on goal detail page
- **Roll-up check-ins**: When a team goal check-in is submitted, auto-draft a check-in for the parent company goal using ChaSen

### Current State
- `goal_check_ins` type is defined in `src/types/goals.ts` (GoalCheckIn interface: id, goal_type, goal_id, author_id, status, progress_update, blockers, next_steps, check_in_date)
- Check-in API route exists: `src/app/api/goals/[id]/check-in/route.ts`
- `useCheckInReminders` hook already tracks overdue status
- Missing: dedicated DB table, check-in form UI, cadence configuration, history timeline component

### Dependencies
- New DB table: `goal_check_ins` (matches existing type definition)
- New component: `CheckInForm`, `CheckInTimeline` (CheckInTimeline.tsx exists but may need updates)
- Add `check_in_cadence` column to goal tables
- Wire existing `useCheckInReminders` hook to real data

### Impact: High | Complexity: Medium

---

## Feature 3: Goals Dashboard Tab with Charts

### What Asana Does
Portfolios have a dashboard view with custom charts — status distribution (pie), progress over time (line), workload by assignee (bar). Users add/remove chart widgets.

### Our Implementation
New **"Dashboard"** tab on Goals & Initiatives page with chart widgets:

| Widget | Visualisation | Data Source |
|--------|--------------|-------------|
| Status distribution | Donut chart | All goals grouped by status |
| Progress over time | Line chart | `goal_audit_log` progress entries by week |
| Goals by owner | Horizontal bar chart | Goals grouped by `owner_id` |
| Overdue goals | Red-highlighted list | Goals past `target_date` |
| Check-in freshness | Heatmap | `last_check_in_date` recency |
| **Financial alignment** | Stacked bar | BURC revenue vs target by pillar |
| Completion rate | Metric card | % of goals completed vs total |
| Dependency health | Network mini-map | Count of blocked vs unblocked goals |

**Financial alignment is the differentiator** — "This pillar's clients generated $X vs $Y target" directly on the dashboard.

### Dependencies
- Recharts already installed in project
- `goal_audit_log` table exists for historical data
- New aggregation API routes or expand existing endpoints
- New component: `GoalsDashboard` with widget grid

### Impact: High | Complexity: Medium-High

---

## Feature 4: Kanban Board View

### What Asana Does
Board view with columns representing statuses. Cards are draggable between columns to change status.

### Our Implementation
New **"Board"** view mode in Goals & Initiatives page:
- Columns: Not Started | On Track | At Risk | Off Track | Completed
- Goal cards draggable between columns (triggers status PATCH)
- Natural extension of the group-by-status feature already built
- Column headers show count and aggregate progress
- Swimlane option: group rows by owner or pillar

### Dependencies
- Package: `@dnd-kit/core` + `@dnd-kit/sortable`
- New component: `GoalKanbanBoard`
- Reuse existing `GoalCard` component
- Wire drag-end to existing `PATCH /api/goals/[id]` status update

### Impact: High | Complexity: Medium

---

## Feature 5: Automation Rules Engine

### What Asana Does
"When X happens, do Y" rules. Examples: task complete → notify manager. Due date passes → set to "at risk". All subtasks complete → mark parent complete.

### Our Implementation
Lightweight automations using existing Supabase infrastructure:

| Trigger | Action | Method |
|---------|--------|--------|
| Initiative marked complete | Update parent team goal progress | Supabase trigger function |
| Goal passes `target_date` | Auto-set status to "at risk" | Scheduled Edge Function (daily cron) |
| All child goals completed | Auto-set parent to "completed" | Supabase trigger on status update |
| No check-in for 14 days | Flag as "needs attention" + create reminder | Scheduled Edge Function |
| BURC sync detects revenue drop >10% | Flag related initiatives as "at risk" | Post-sync webhook |
| Goal status changed | Log to audit trail + send notification | Supabase trigger function |
| New dependency added on blocked goal | Notify goal owner | Supabase trigger function |

**BURC-triggered automations are uniquely ours** — Asana can't detect "client revenue dropped" and automatically flag the related initiative.

### Current State
- `useAutomationRules` hook exists (configuration layer)
- `goal_audit_log` table captures all changes
- No Supabase triggers or Edge Functions for goals yet

### Dependencies
- Supabase trigger functions (PL/pgSQL)
- Optional: Supabase Edge Function for scheduled tasks
- New DB table: `goal_automation_rules` (stores user-configured rules)
- Admin UI for rule configuration (lower priority)

### Impact: High | Complexity: Medium

---

## Feature 6: Smart Fields (AI-Suggested Metadata)

### What Asana Does
AI analyses task content and suggests values for custom fields — priority, effort, category. Reduces manual data entry.

### Our Implementation
**AI-assisted goal creation** — when creating a new initiative:
- ChaSen analyses title/description and suggests: **category**, **related client** (fuzzy match against `client_name_aliases`), **suggested CSE** (based on client ownership), **estimated effort**
- Pre-fill form fields with AI suggestions, user confirms/overrides
- **Post-BURC-sync suggestions**: AI scans for significant changes (new clients, revenue shifts, NPS drops) and auto-suggests new initiatives

**Example**: *"NPS for Meditech NZ dropped from +45 to +20. Suggest creating a 'Client Retention — Meditech NZ' initiative under the Customer Success team goal?"*

### Dependencies
- New ChaSen tool: `suggest_goal_metadata`
- New ChaSen tool: `suggest_initiatives_from_data`
- Update `GoalCreateModal` to call suggestion API
- Wire post-sync hook to trigger suggestions

### Impact: Medium | Complexity: Medium

---

## Feature 7: Additional View Modes

### What Asana Does
Same data, multiple views — List, Board, Calendar, Timeline, Dashboard. Users switch freely.

### Current State
Existing: Grid, Timeline (Gantt), Strategy Map, Overview. Just added: Group-by-status.

### Missing Views

**A. Table/List View** (spreadsheet-style):
- Sortable columns: Title, Status, Owner, Progress, Due Date, Last Check-in
- Compact, data-dense. Power users' favourite for scanning many goals
- Inline editing for status and progress fields
- Complexity: Low (TanStack Table patterns exist elsewhere in project)

**B. Calendar View** (by target date):
- Monthly calendar plotting goals by `target_date`
- Shows which goals are due when, clustered by date
- Click date to see all goals due that day
- Complexity: Medium

### Dependencies
- Table: TanStack Table (already a project dependency pattern)
- Calendar: New calendar component or adapt existing date-picker patterns
- Share `normaliseGoal()` function across all views

### Impact: Table = Medium, Calendar = Low | Complexity: Table = Low, Calendar = Medium

---

## Feature 8: Breadcrumb Navigation & Roll-Up Cards

### What Asana Does
Nested portfolios with drill-down navigation. Progress rolls up automatically through the tree.

### Our Implementation
The 4-level hierarchy (Pillar → Company → Team → Initiative) already exists. Missing:

1. **Breadcrumb navigation**: When viewing a Company Goal, show clickable `Growth > Expand Meditech ANZ`
2. **Roll-up progress cards**: On each goal detail page, show mini summary of child goals with progress bars
3. **Expand/collapse in Strategy Map**: Click a node to expand/collapse children inline
4. **Aggregate status indicators**: Pillar shows "3 on track, 1 at risk, 2 not started" as a mini status bar

### Dependencies
- Breadcrumb: read parent chain from existing FK relationships
- Roll-up cards: new `ChildGoalSummary` component
- Strategy Map: modify React Flow node click behaviour
- API: expand `GET /api/goals/[id]/hierarchy` to include status counts

### Impact: Medium | Complexity: Low-Medium

---

## Feature 9: AI-Generated Meeting Briefs

### What Asana Does
AI generates meeting agendas from project status and task updates.

### Our Implementation
**Pre-meeting brief generator** — before a client meeting, ChaSen generates:
- Client's initiatives, recent check-ins, BURC financials, NPS trend, open actions
- 1-page summary combining all context
- Meeting agenda suggestions based on overdue actions, at-risk initiatives, upcoming milestones
- **Post-meeting action extraction**: Suggest actions based on meeting topics discussed

This is the intersection of `topics`, `actions`, `portfolio_initiatives`, and BURC data — something no generic project management tool can replicate.

### Dependencies
- New ChaSen tool: `generate_meeting_brief`
- New component: `MeetingBriefPanel` (sidebar on meeting detail page)
- Data already available across existing tables

### Impact: High | Complexity: Medium

---

## Feature 10: Milestone Markers

### What Asana Does
Diamond-shaped markers on timelines representing key dates/achievements rather than tasks with duration.

### Our Implementation
Add milestones to Gantt/Timeline view:
- Key dates: Quarter ends, BURC submission deadlines, client contract renewals
- Achievement markers: Goal hits 100% → diamond marker on timeline
- External events: Product launches, conference dates, regulatory deadlines
- Render as diamond shapes in `TimelineBar.tsx`

### Dependencies
- New DB table: `goal_milestones` (id, goal_type, goal_id, title, date, milestone_type, created_at)
- OR: add `is_milestone` boolean to existing goals for lightweight approach
- New component: `MilestoneMarker` for Gantt renderer

### Impact: Low | Complexity: Low

---

## Feature 11: CSE/CAM Workload View

### What Asana Does
Shows each team member's workload as horizontal capacity bars across a date range. Managers drag tasks between people to rebalance.

### Our Implementation
**Workload view** showing per-CSE capacity:
- Per-CSE row: active initiatives, open actions, upcoming meetings
- Capacity bar: green (manageable) → amber (heavy) → red (overloaded)
- Date range: weekly view with initiative deadlines and action due dates
- Click initiative to reassign CSE (updates `cse_name`)

Data sources already available:
- `portfolio_initiatives` → initiatives per CSE
- `actions` → open actions per owner
- `topics` → upcoming meetings per CSE
- `burc_annual_financials` → revenue responsibility per CSE

### Dependencies
- New page: `/workload` or new tab on Goals page
- New component: `WorkloadChart`
- Aggregation API across multiple tables
- Drag-and-drop reassignment

### Impact: High | Complexity: High

---

## Priority Matrix

| # | Feature | User Impact | Complexity | Session |
|---|---------|------------|------------|---------|
| 1 | Smart Status (AI summaries) | Very High | Medium | **1** |
| 2 | Check-in system | High | Medium | **1** |
| 3 | Goals Dashboard with charts | High | Medium-High | **2** |
| 4 | Kanban Board view | High | Medium | **2** |
| 5 | Automation rules | High | Medium | **3** |
| 6 | Smart Fields (AI pre-fill) | Medium | Medium | **3** |
| 7A | Table/List view | Medium | Low | **Quick win** |
| 7B | Calendar view | Low | Medium | **Backlog** |
| 8 | Breadcrumbs + roll-up cards | Medium | Low-Medium | **Quick win** |
| 9 | Meeting briefs | High | Medium | **4** |
| 10 | Milestones | Low | Low | **Backlog** |
| 11 | Workload view | High | High | **5** |
