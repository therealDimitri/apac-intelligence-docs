# Asana-Inspired Implementation Plan

**Created**: 2026-02-08
**Reference**: [asana-inspired-enhancements.md](asana-inspired-enhancements.md) (feature descriptions and rationale)

---

## Pre-Implementation: Infrastructure Audit

### What Exists
- **API routes**: 9 goal routes (CRUD, check-in, dependencies, hierarchy, audit, gantt, critical-path)
- **Components**: 16+ goal components (cards, strategy map, gantt, context menu, progress)
- **Hooks**: 6 goal hooks (strategy map, gantt data, check-in reminders, dependency notifications, approvals, automation rules)
- **DB tables**: `company_goals`, `team_goals`, `portfolio_initiatives`, `strategic_pillars`, `goal_templates`, `goal_dependencies`, `goal_approvals`, `goal_audit_log`
- **Types**: Full type system in `src/types/goals.ts` (GoalType, GoalStatus, ProgressMethod, CheckInStatus, etc.)
- **ChaSen tools**: 14 tools across portfolio/health/meetings/actions — **zero goal tools**

### What's Missing
- `goal_check_ins` DB table (type defined, table not created)
- `goal_status_updates` DB table (new)
- `goal_milestones` DB table (new)
- `goal_automation_rules` DB table (new)
- ChaSen tools for goals (none exist)
- Kanban/Table/Calendar view components
- Dashboard chart widgets

---

## Session 1: Smart Status + Check-In System

**Goal**: Give CSEs the ability to generate AI-powered status summaries and maintain a structured check-in history for every goal.

### Step 1.1: Create `goal_check_ins` Table

```sql
CREATE TABLE goal_check_ins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_type TEXT NOT NULL CHECK (goal_type IN ('pillar', 'company', 'team', 'initiative')),
  goal_id UUID NOT NULL,
  author_id TEXT,
  status TEXT CHECK (status IN ('on_track', 'at_risk', 'off_track')),
  progress_percentage NUMERIC(5,2),
  narrative TEXT,
  blockers TEXT,
  next_steps TEXT,
  check_in_date TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_check_ins_goal ON goal_check_ins(goal_type, goal_id);
CREATE INDEX idx_check_ins_date ON goal_check_ins(check_in_date DESC);

-- RLS: allow anon read/write (service key handles auth)
ALTER TABLE goal_check_ins ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for anon" ON goal_check_ins FOR ALL TO anon USING (true) WITH CHECK (true);
```

**Files**: Migration via Supabase MCP `apply_migration`

### Step 1.2: Create `goal_status_updates` Table

```sql
CREATE TABLE goal_status_updates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_type TEXT NOT NULL CHECK (goal_type IN ('pillar', 'company', 'team', 'initiative')),
  goal_id UUID NOT NULL,
  author_id TEXT,
  summary TEXT NOT NULL,
  ai_generated BOOLEAN DEFAULT false,
  child_snapshot JSONB,
  financial_snapshot JSONB,
  published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_status_updates_goal ON goal_status_updates(goal_type, goal_id);
CREATE INDEX idx_status_updates_date ON goal_status_updates(created_at DESC);

ALTER TABLE goal_status_updates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for anon" ON goal_status_updates FOR ALL TO anon USING (true) WITH CHECK (true);
```

### Step 1.3: Add Check-In Cadence to Goal Tables

```sql
ALTER TABLE company_goals ADD COLUMN check_in_cadence TEXT DEFAULT 'fortnightly'
  CHECK (check_in_cadence IN ('weekly', 'fortnightly', 'monthly'));
ALTER TABLE team_goals ADD COLUMN check_in_cadence TEXT DEFAULT 'fortnightly'
  CHECK (check_in_cadence IN ('weekly', 'fortnightly', 'monthly'));
ALTER TABLE portfolio_initiatives ADD COLUMN check_in_cadence TEXT DEFAULT 'fortnightly'
  CHECK (check_in_cadence IN ('weekly', 'fortnightly', 'monthly'));
ALTER TABLE strategic_pillars ADD COLUMN check_in_cadence TEXT DEFAULT 'monthly'
  CHECK (check_in_cadence IN ('weekly', 'fortnightly', 'monthly'));
```

### Step 1.4: Update Check-In API Route

**File**: `src/app/api/goals/[id]/check-in/route.ts`

Update POST handler to:
1. Insert into `goal_check_ins` table
2. Update `last_check_in_date` on the parent goal table
3. If progress changed, update `progress_percentage` on parent goal
4. Log to `goal_audit_log` with action `'check_in'`
5. Return the created check-in

Update GET handler to:
1. Query `goal_check_ins` filtered by goal_type + goal_id
2. Order by `check_in_date DESC`
3. Support pagination

### Step 1.5: Create Status Update API Route

**File**: `src/app/api/goals/[id]/status-update/route.ts` (NEW)

- **GET**: List status updates for a goal (paginated, newest first)
- **POST**: Create a status update (manual or AI-generated)
  - If `ai_generated: true`, call ChaSen to generate summary
  - Save `child_snapshot` (current child goal statuses) and `financial_snapshot` (BURC data)

### Step 1.6: Add ChaSen Goal Tools

**File**: `src/lib/chasen-tools.ts` — add 2 new tools:

**Tool: `generate_goal_status`**
- Input: `goal_type`, `goal_id`
- Process:
  1. Fetch goal + all child goals with status/progress
  2. Fetch recent check-ins (last 30 days)
  3. Fetch blocking dependencies
  4. If initiative/company goal: cross-reference BURC financials for related clients
  5. Generate 2-3 sentence executive summary
- Output: `{ summary, child_snapshot, financial_snapshot }`

**Tool: `search_goals`**
- Input: `query` (natural language), optional `goal_type`, `status`, `owner`
- Process: Search goals by title/description with filters
- Output: Matching goals with progress and status

### Step 1.7: Build Check-In Form Component

**File**: `src/components/goals/CheckInForm.tsx` (NEW)

- Form fields: Status (radio), Progress % (slider), Narrative (textarea), Blockers (textarea), Next Steps (textarea)
- Slide-out panel (reuse pattern from action creation)
- On submit: POST to `/api/goals/[id]/check-in`
- Auto-refresh check-in timeline after submit

### Step 1.8: Build Status Update Timeline Component

**File**: `src/components/goals/StatusUpdateTimeline.tsx` (NEW)

- Vertical timeline showing all status updates for a goal
- Each entry: date, author, summary text, AI badge if generated
- Expand to show child_snapshot and financial_snapshot
- "Generate Status Update" button at top (calls ChaSen tool)

### Step 1.9: Wire Into Goal Detail Page

**File**: `src/app/(dashboard)/goals-initiatives/[type]/[id]/page.tsx`

- Add tabs or sections: "Check-Ins" and "Status Updates"
- Check-Ins tab: CheckInForm + CheckInTimeline
- Status Updates tab: StatusUpdateTimeline with "Generate" button
- Show check-in cadence setting (editable dropdown)

### Step 1.10: Regenerate DB Types

```bash
npm run db:refresh
```

### Verification
- Create a check-in via the form → appears in timeline
- Generate AI status update → summary includes child goal progress + financial context
- Check-in updates `last_check_in_date` on parent goal
- Overdue check-in dot reflects real cadence setting

---

## Session 2: Goals Dashboard + Kanban Board

**Goal**: Add data visualisation and drag-and-drop status management.

### Step 2.1: Build Dashboard Tab

**File**: `src/components/goals/GoalsDashboard.tsx` (NEW)

Widget grid layout (responsive: 1 col mobile, 2 col tablet, 3 col desktop):

**Widget A: Status Distribution** (Recharts PieChart)
- Data: Count of goals per status across all types
- Donut with centre label showing total count
- Click segment to filter goal list

**Widget B: Progress Over Time** (Recharts LineChart)
- Data: Average progress % from `goal_audit_log` entries, grouped by week
- Lines per goal type (pillar, company, team, initiative)
- Last 12 weeks

**Widget C: Goals by Owner** (Recharts BarChart)
- Data: Goal count per `owner_id`, grouped by status
- Horizontal stacked bars
- Click bar to filter to that owner

**Widget D: Overdue Goals** (list)
- Goals past `target_date` with status != completed
- Sorted by days overdue (most overdue first)
- Red styling with days-overdue count

**Widget E: Check-In Freshness** (heatmap grid)
- Grid of goal cards coloured by `last_check_in_date` recency
- Green (< 7 days), Amber (7-14 days), Red (> 14 days), Grey (never)
- Click to navigate to goal

**Widget F: Financial Alignment** (Recharts BarChart)
- Data: BURC revenue vs target grouped by strategic pillar
- Stacked bars showing actual vs gap-to-target
- Requires cross-referencing `burc_annual_financials` with `strategic_pillars`

### Step 2.2: Dashboard Aggregation API

**File**: `src/app/api/goals/dashboard/route.ts` (NEW)

Single endpoint returning all dashboard data in one call:
```typescript
GET /api/goals/dashboard
Response: {
  statusDistribution: { status: GoalStatus, count: number }[],
  progressTimeline: { week: string, pillar: number, company: number, team: number, initiative: number }[],
  goalsByOwner: { owner: string, on_track: number, at_risk: number, ... }[],
  overdueGoals: { id, type, title, target_date, days_overdue }[],
  checkInFreshness: { id, type, title, last_check_in_date, days_since }[],
  financialAlignment: { pillar: string, actual_revenue: number, target_revenue: number }[],
  totals: { total: number, completed: number, at_risk: number, overdue: number }
}
```

### Step 2.3: Wire Dashboard Tab

**File**: `src/app/(dashboard)/goals-initiatives/page.tsx`

- Add "Dashboard" to tab list (after Overview, before individual type tabs)
- Render `<GoalsDashboard />` when Dashboard tab is active
- Loading skeleton matching widget grid layout

### Step 2.4: Install DnD Kit

```bash
npm install @dnd-kit/core @dnd-kit/sortable @dnd-kit/utilities
```

### Step 2.5: Build Kanban Board Component

**File**: `src/components/goals/GoalKanbanBoard.tsx` (NEW)

- 5 columns: Not Started | On Track | At Risk | Off Track | Completed
- Column headers: status label + count + aggregate progress bar
- Cards: reuse `GoalCard` component (compact variant)
- Drag between columns → PATCH `/api/goals/[id]` with new status
- Column scroll for many cards
- Optional swimlane grouping by owner (toggle)

### Step 2.6: Wire Board View

**File**: `src/app/(dashboard)/goals-initiatives/page.tsx`

- Add "Board" to viewMode options (alongside Grid and existing views)
- Render `<GoalKanbanBoard />` when Board view selected
- Pass same goals data + status change handler

### Verification
- Dashboard loads with all 6 widgets populated
- Chart interactions (click to filter) work
- Drag a goal card from "On Track" to "At Risk" → status updates in DB
- Board view shows correct card counts per column
- Financial alignment chart shows real BURC data

---

## Session 3: Automation Rules + Smart Fields

**Goal**: Reduce manual status management and streamline goal creation.

### Step 3.1: Create Automation Rules Table

```sql
CREATE TABLE goal_automation_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  trigger_type TEXT NOT NULL CHECK (trigger_type IN (
    'status_changed', 'progress_updated', 'target_date_passed',
    'check_in_overdue', 'all_children_complete', 'burc_revenue_drop',
    'dependency_resolved'
  )),
  trigger_config JSONB DEFAULT '{}',
  action_type TEXT NOT NULL CHECK (action_type IN (
    'set_status', 'create_notification', 'update_progress',
    'create_check_in_reminder', 'flag_attention'
  )),
  action_config JSONB DEFAULT '{}',
  scope_goal_type TEXT,
  scope_goal_id UUID,
  enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE goal_automation_rules ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for anon" ON goal_automation_rules FOR ALL TO anon USING (true) WITH CHECK (true);
```

### Step 3.2: Create Supabase Trigger Functions

**Migration: `create_goal_automation_triggers`**

**Trigger A: Auto-complete parent when all children complete**
```sql
CREATE OR REPLACE FUNCTION check_parent_completion()
RETURNS TRIGGER AS $$
BEGIN
  -- For team_goals: check if all siblings under same company_goal are complete
  IF TG_TABLE_NAME = 'team_goals' AND NEW.status = 'completed' THEN
    PERFORM 1 FROM team_goals
    WHERE company_goal_id = NEW.company_goal_id
    AND status != 'completed'
    AND id != NEW.id;
    IF NOT FOUND THEN
      UPDATE company_goals SET status = 'completed', is_achieved = true,
        progress_percentage = 100, updated_at = now()
      WHERE id = NEW.company_goal_id;
    END IF;
  END IF;

  -- For portfolio_initiatives: check if all siblings under same team_goal are complete
  IF TG_TABLE_NAME = 'portfolio_initiatives' AND NEW.goal_status = 'completed' THEN
    PERFORM 1 FROM portfolio_initiatives
    WHERE team_goal_id = NEW.team_goal_id
    AND goal_status != 'completed'
    AND id != NEW.id;
    IF NOT FOUND THEN
      UPDATE team_goals SET status = 'completed', is_achieved = true,
        progress_percentage = 100, updated_at = now()
      WHERE id = NEW.team_goal_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_team_goal_completion
  AFTER UPDATE OF status ON team_goals
  FOR EACH ROW
  WHEN (NEW.status = 'completed' AND OLD.status != 'completed')
  EXECUTE FUNCTION check_parent_completion();

CREATE TRIGGER trg_initiative_completion
  AFTER UPDATE OF goal_status ON portfolio_initiatives
  FOR EACH ROW
  WHEN (NEW.goal_status = 'completed' AND OLD.goal_status != 'completed')
  EXECUTE FUNCTION check_parent_completion();
```

**Trigger B: Auto-update progress on child changes**
```sql
CREATE OR REPLACE FUNCTION recalculate_parent_progress()
RETURNS TRIGGER AS $$
DECLARE
  parent_type TEXT;
  parent_id UUID;
  avg_progress NUMERIC;
BEGIN
  -- Determine parent
  IF TG_TABLE_NAME = 'team_goals' THEN
    parent_id := COALESCE(NEW.company_goal_id, OLD.company_goal_id);
    SELECT AVG(progress_percentage) INTO avg_progress
    FROM team_goals WHERE company_goal_id = parent_id;
    UPDATE company_goals SET progress_percentage = COALESCE(avg_progress, 0),
      updated_at = now()
    WHERE id = parent_id AND progress_method = 'auto';
  ELSIF TG_TABLE_NAME = 'portfolio_initiatives' THEN
    parent_id := COALESCE(NEW.team_goal_id, OLD.team_goal_id);
    SELECT AVG(progress_percentage) INTO avg_progress
    FROM portfolio_initiatives WHERE team_goal_id = parent_id;
    UPDATE team_goals SET progress_percentage = COALESCE(avg_progress, 0),
      updated_at = now()
    WHERE id = parent_id AND progress_method = 'auto';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_team_goal_progress
  AFTER UPDATE OF progress_percentage ON team_goals
  FOR EACH ROW EXECUTE FUNCTION recalculate_parent_progress();

CREATE TRIGGER trg_initiative_progress
  AFTER UPDATE OF progress_percentage ON portfolio_initiatives
  FOR EACH ROW EXECUTE FUNCTION recalculate_parent_progress();
```

### Step 3.3: Create Scheduled Staleness Check

**File**: Supabase Edge Function `check-goal-staleness` (NEW)

Daily cron (or called from existing scheduled sync):
1. Find goals past `target_date` with status NOT in ('completed', 'off_track') → set to 'at_risk'
2. Find goals with `last_check_in_date` older than their `check_in_cadence` → flag in audit log
3. Return summary of actions taken

### Step 3.4: Add ChaSen Smart Fields Tool

**File**: `src/lib/chasen-tools.ts` — add tool:

**Tool: `suggest_goal_metadata`**
- Input: `title`, `description`, `goal_type`
- Process:
  1. Analyse title/description for client names (fuzzy match against `client_name_aliases`)
  2. If client found: look up CSE assignment, recent NPS, revenue
  3. Suggest: category, related client, suggested CSE/owner, priority
  4. If similar goals exist, surface them (avoid duplicates)
- Output: `{ category, client_name, suggested_owner, priority, similar_goals[] }`

### Step 3.5: Wire Smart Fields into Goal Create Modal

**File**: `src/components/goals/GoalCreateModal.tsx`

- After user types title (debounced 500ms), call `suggest_goal_metadata`
- Show suggestions as pre-filled form fields with "AI suggested" badge
- User can accept or override each suggestion
- Show "Similar goals" warning if duplicates detected

### Step 3.6: Automation Rules API

**File**: `src/app/api/goals/automations/route.ts` (NEW)

- **GET**: List all automation rules (with enabled filter)
- **POST**: Create a new automation rule
- **PATCH**: Enable/disable a rule
- **DELETE**: Remove a rule

### Verification
- Complete all child team goals → parent company goal auto-completes
- Update child progress → parent progress recalculates (when method = 'auto')
- Goal past target date → status auto-changes to "at risk" (after daily check)
- Creating initiative with client name in title → AI suggests correct CSE and category
- Similar goal warning appears when creating a duplicate title

---

## Session 4: Meeting Briefs + Table View

**Goal**: Help CSEs prepare for meetings and provide a power-user data view.

### Step 4.1: Add ChaSen Meeting Brief Tool

**File**: `src/lib/chasen-tools.ts` — add tool:

**Tool: `generate_meeting_brief`**
- Input: `client_name`, optional `meeting_date`
- Process:
  1. Fetch client's initiatives from `portfolio_initiatives`
  2. Fetch recent check-ins for those initiatives
  3. Fetch BURC financials (revenue, target, NPS)
  4. Fetch open actions for this client
  5. Fetch upcoming meeting topics
  6. Generate structured brief: key metrics, initiative status, risks, suggested agenda
- Output: `{ brief_markdown, key_metrics, risks[], suggested_agenda[] }`

### Step 4.2: Build Meeting Brief Component

**File**: `src/components/goals/MeetingBriefPanel.tsx` (NEW)

- Side panel or expandable section on meeting detail page
- Sections: Key Metrics, Initiative Status, Risks & Blockers, Suggested Agenda
- "Generate Brief" button calls ChaSen tool
- Copy-to-clipboard for sharing in email/Teams
- Print-friendly styling

### Step 4.3: Wire Brief into Topics/Meetings Page

**File**: `src/app/(dashboard)/topics/[id]/page.tsx` (or wherever meeting detail lives)

- Add "Meeting Brief" panel/button
- Auto-detect client from meeting topic metadata
- Pre-generate brief when user navigates to meeting detail (optional, behind toggle)

### Step 4.4: Build Table View Component

**File**: `src/components/goals/GoalTableView.tsx` (NEW)

- TanStack Table with columns: Title, Type, Status, Owner, Progress %, Due Date, Last Check-In, Child Count
- Sortable column headers (click to sort)
- Inline status editing (click status cell → dropdown)
- Row click → navigate to goal detail
- Column visibility toggle (hide/show columns)
- Export to CSV button

### Step 4.5: Wire Table View

**File**: `src/app/(dashboard)/goals-initiatives/page.tsx`

- Add "Table" to viewMode options
- Render `<GoalTableView />` when Table view selected
- Pass normalised goals data

### Verification
- Generate meeting brief for a client → brief includes BURC data, initiative status, actions
- Brief is copyable and readable
- Table view is sortable by all columns
- Inline status editing works in table view
- Column toggle hides/shows columns correctly

---

## Session 5: Breadcrumbs + Roll-Up Cards + Milestones

**Goal**: Improve navigation and hierarchy awareness across the goal system.

### Step 5.1: Build Breadcrumb Component

**File**: `src/components/goals/GoalBreadcrumb.tsx` (NEW)

- Input: current goal's type and parent chain
- Renders: `Strategic Pillars > Growth > Expand ANZ Market > [Current Goal]`
- Each segment is clickable (navigates to that goal's detail page)
- Responsive: truncates middle segments on mobile

### Step 5.2: Fetch Parent Chain

**File**: `src/app/api/goals/[id]/route.ts` — enhance GET response

Add `parent_chain` to response:
- For initiative: fetch team_goal → company_goal → pillar
- For team goal: fetch company_goal → pillar
- For company goal: fetch pillar
- Return as array: `[{ type, id, title }, ...]`

### Step 5.3: Build Roll-Up Cards Component

**File**: `src/components/goals/ChildGoalSummary.tsx` (NEW)

- Shows on goal detail page: grid of mini cards for child goals
- Each card: title, status badge, progress bar (compact)
- Aggregate header: "3 of 5 on track (60%)"
- Click card → navigate to child goal detail

### Step 5.4: Wire Into Goal Detail Page

**File**: `src/app/(dashboard)/goals-initiatives/[type]/[id]/page.tsx`

- Add `GoalBreadcrumb` above title
- Add `ChildGoalSummary` section below description
- Only show ChildGoalSummary for pillar/company/team goals (not initiatives)

### Step 5.5: Create Milestones Table

```sql
CREATE TABLE goal_milestones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_type TEXT CHECK (goal_type IN ('pillar', 'company', 'team', 'initiative')),
  goal_id UUID,
  title TEXT NOT NULL,
  milestone_date DATE NOT NULL,
  milestone_type TEXT DEFAULT 'custom' CHECK (milestone_type IN (
    'custom', 'quarter_end', 'contract_renewal', 'product_launch', 'burc_deadline', 'achievement'
  )),
  description TEXT,
  completed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_milestones_date ON goal_milestones(milestone_date);
CREATE INDEX idx_milestones_goal ON goal_milestones(goal_type, goal_id);

ALTER TABLE goal_milestones ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for anon" ON goal_milestones FOR ALL TO anon USING (true) WITH CHECK (true);
```

### Step 5.6: Add Milestone Markers to Timeline

**File**: `src/components/goals/gantt/TimelineBar.tsx`

- Add diamond-shaped markers for milestones at their date position
- Different colours by `milestone_type`
- Hover tooltip shows milestone title and date
- Click navigates to related goal

### Step 5.7: Milestone API

**File**: `src/app/api/goals/milestones/route.ts` (NEW)

- **GET**: List milestones (filter by date range, goal, type)
- **POST**: Create milestone
- **PATCH**: Update milestone (mark complete)
- **DELETE**: Remove milestone

### Verification
- Breadcrumb shows full parent chain on goal detail page
- Click breadcrumb segment → navigates to parent goal
- Child summary shows correct count and aggregate progress
- Milestones appear as diamonds on Gantt timeline
- Milestone hover shows title and date

---

## Session 6: Workload View

**Goal**: Give leadership visibility into CSE/CAM capacity and enable workload rebalancing.

### Step 6.1: Workload Aggregation API

**File**: `src/app/api/goals/workload/route.ts` (NEW)

```typescript
GET /api/goals/workload?period=4w
Response: {
  cses: [{
    name: string,
    active_initiatives: number,
    open_actions: number,
    upcoming_meetings: number,
    revenue_responsibility: number,
    capacity_score: number, // 0-100 (computed)
    initiatives: [{ id, name, status, target_date }],
    weekly_breakdown: [{ week: string, initiative_count, action_count, meeting_count }]
  }]
}
```

Aggregation across:
- `portfolio_initiatives` → count by `cse_name`
- `actions` → count open actions by owner (match to CSE)
- `topics` → upcoming meetings by attendee
- `burc_annual_financials` → revenue by CSE territory

### Step 6.2: Build Workload Chart Component

**File**: `src/components/goals/WorkloadView.tsx` (NEW)

- Per-CSE horizontal rows with capacity bars
- Capacity bar: green (0-60%), amber (60-80%), red (80-100%)
- Expandable row: shows breakdown (initiatives, actions, meetings)
- Date range selector: 2w / 4w / 8w / 12w
- Click initiative → reassign CSE (dropdown + PATCH API)

### Step 6.3: Wire Workload View

**File**: `src/app/(dashboard)/goals-initiatives/page.tsx`

- Add "Workload" tab (alongside Dashboard, Overview, etc.)
- Or: create dedicated `/workload` page if scope warrants it
- Render `<WorkloadView />` with data from workload API

### Verification
- Workload view shows all CSEs with capacity bars
- Capacity score correctly reflects initiative + action + meeting load
- Expanding a CSE row shows their initiatives and actions
- Reassigning an initiative updates `cse_name` in DB
- Date range filter adjusts the weekly breakdown

---

## Quick Wins (Any Session)

These can be slotted into any session when time permits:

### QW1: Breadcrumb Navigation (partial — Step 5.1-5.2 above)
If Session 5 hasn't happened yet, add basic breadcrumb with parent title only (single API call to fetch parent).

### QW2: Table View (partial — Step 4.4-4.5 above)
Minimal table: sortable columns, no inline editing. Can be done in ~1 hour.

### QW3: Aggregate Status Indicators on Strategy Map
**File**: `src/components/goals/strategy-map/GoalNodeBase.tsx`
Add mini status bar to node: "3 on track, 1 at risk" shown as coloured dots below title.

### QW4: Copy Goal Link
**File**: `src/components/goals/GoalContextMenu.tsx`
Add "Copy Link" action that copies `/goals-initiatives/{type}/{id}` to clipboard with toast.

---

## Database Migration Summary

| Session | Table | Type |
|---------|-------|------|
| 1 | `goal_check_ins` | New table |
| 1 | `goal_status_updates` | New table |
| 1 | `check_in_cadence` column | Alter 4 tables |
| 3 | `goal_automation_rules` | New table |
| 3 | Trigger functions (completion, progress) | PL/pgSQL |
| 5 | `goal_milestones` | New table |

Total: 4 new tables, 4 column additions, 4 trigger functions

---

## New File Summary

| Session | File | Type |
|---------|------|------|
| 1 | `src/components/goals/CheckInForm.tsx` | Component |
| 1 | `src/components/goals/StatusUpdateTimeline.tsx` | Component |
| 1 | `src/app/api/goals/[id]/status-update/route.ts` | API route |
| 2 | `src/components/goals/GoalsDashboard.tsx` | Component |
| 2 | `src/components/goals/GoalKanbanBoard.tsx` | Component |
| 2 | `src/app/api/goals/dashboard/route.ts` | API route |
| 3 | `src/app/api/goals/automations/route.ts` | API route |
| 4 | `src/components/goals/MeetingBriefPanel.tsx` | Component |
| 4 | `src/components/goals/GoalTableView.tsx` | Component |
| 5 | `src/components/goals/GoalBreadcrumb.tsx` | Component |
| 5 | `src/components/goals/ChildGoalSummary.tsx` | Component |
| 5 | `src/app/api/goals/milestones/route.ts` | API route |
| 6 | `src/components/goals/WorkloadView.tsx` | Component |
| 6 | `src/app/api/goals/workload/route.ts` | API route |

Total: 10 new components, 5 new API routes

---

## ChaSen Tool Additions

| Session | Tool Name | Purpose |
|---------|-----------|---------|
| 1 | `generate_goal_status` | AI status summary with financial context |
| 1 | `search_goals` | Natural language goal search |
| 3 | `suggest_goal_metadata` | AI-suggested fields for goal creation |
| 4 | `generate_meeting_brief` | Pre-meeting brief with client context |

Total: 4 new ChaSen tools

---

## Package Dependencies

| Session | Package | Purpose |
|---------|---------|---------|
| 2 | `@dnd-kit/core` | Drag-and-drop for Kanban board |
| 2 | `@dnd-kit/sortable` | Sortable containers for Kanban |
| 2 | `@dnd-kit/utilities` | DnD helper utilities |

All other features use existing dependencies (Recharts, TanStack Table patterns, React Flow).
