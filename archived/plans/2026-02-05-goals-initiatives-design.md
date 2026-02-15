# Goals & Initiatives System - Complete Design Specification

**Date:** 2026-02-05
**Status:** Approved
**Target:** Enterprise-wide adoption with 50+ initiatives

## Executive Summary

This design introduces a comprehensive 3-tier goal hierarchy system (company_goals → team_goals → initiatives → actions) that transforms the existing Actions & Tasks system into a full-featured project management and strategic alignment platform. The design leverages existing database infrastructure (`actions.linked_initiative_id` already exists), integrates with MS Graph for automatic user/org synchronization, and incorporates ChaSen AI throughout for intelligent automation.

**Key Decision:** Full PM Tool (Option C) - supporting all user types (leadership, CSEs, cross-functional), solving all problems (visibility, goal alignment, PM tool replacement), and scaling to 50+ initiatives.

---

## 1. Database Schema

### New Tables

#### `company_goals`
```sql
CREATE TABLE company_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  owner_id UUID REFERENCES auth.users(id),
  progress_method TEXT CHECK (progress_method IN ('auto', 'manual', 'target_value', 'boolean')),
  progress_percentage NUMERIC(5,2),
  target_value NUMERIC,
  current_value NUMERIC,
  is_achieved BOOLEAN DEFAULT false,
  start_date DATE,
  target_date DATE,
  status TEXT CHECK (status IN ('on_track', 'at_risk', 'off_track', 'completed')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `team_goals`
```sql
CREATE TABLE team_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_goal_id UUID REFERENCES company_goals(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  owner_id UUID REFERENCES auth.users(id),
  team_id UUID, -- Maps to MS Graph groups
  progress_method TEXT CHECK (progress_method IN ('auto', 'manual', 'target_value', 'boolean')),
  progress_percentage NUMERIC(5,2),
  target_value NUMERIC,
  current_value NUMERIC,
  is_achieved BOOLEAN DEFAULT false,
  start_date DATE,
  target_date DATE,
  status TEXT CHECK (status IN ('on_track', 'at_risk', 'off_track', 'completed')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `initiatives` (Enhanced)
```sql
-- Enhance existing initiatives table
ALTER TABLE initiatives ADD COLUMN IF NOT EXISTS team_goal_id UUID REFERENCES team_goals(id) ON DELETE SET NULL;
ALTER TABLE initiatives ADD COLUMN IF NOT EXISTS progress_method TEXT CHECK (progress_method IN ('auto', 'manual', 'target_value', 'boolean'));
ALTER TABLE initiatives ADD COLUMN IF NOT EXISTS progress_percentage NUMERIC(5,2);
ALTER TABLE initiatives ADD COLUMN IF NOT EXISTS target_value NUMERIC;
ALTER TABLE initiatives ADD COLUMN IF NOT EXISTS current_value NUMERIC;
ALTER TABLE initiatives ADD COLUMN IF NOT EXISTS is_achieved BOOLEAN DEFAULT false;
ALTER TABLE initiatives ADD COLUMN IF NOT EXISTS status TEXT CHECK (status IN ('on_track', 'at_risk', 'off_track', 'completed'));
```

#### `goal_templates`
```sql
CREATE TABLE goal_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  tier TEXT CHECK (tier IN ('company', 'team', 'initiative')),
  title_template TEXT,
  description_template TEXT,
  suggested_metrics JSONB,
  industry TEXT,
  use_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `goal_check_ins`
```sql
CREATE TABLE goal_check_ins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_type TEXT CHECK (goal_type IN ('company', 'team', 'initiative')),
  goal_id UUID NOT NULL,
  author_id UUID REFERENCES auth.users(id),
  status TEXT CHECK (status IN ('on_track', 'at_risk', 'off_track')),
  progress_update TEXT,
  blockers TEXT,
  next_steps TEXT,
  check_in_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `goal_dependencies`
```sql
CREATE TABLE goal_dependencies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blocking_type TEXT CHECK (blocking_type IN ('company', 'team', 'initiative')),
  blocking_id UUID NOT NULL,
  blocked_type TEXT CHECK (blocked_type IN ('company', 'team', 'initiative')),
  blocked_id UUID NOT NULL,
  dependency_type TEXT CHECK (dependency_type IN ('blocks', 'related_to')),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(blocking_type, blocking_id, blocked_type, blocked_id)
);
```

#### `goal_approvals`
```sql
CREATE TABLE goal_approvals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_type TEXT CHECK (goal_type IN ('company', 'team', 'initiative')),
  goal_id UUID NOT NULL,
  change_type TEXT CHECK (change_type IN ('create', 'update_target', 'update_timeline', 'archive')),
  requested_by UUID REFERENCES auth.users(id),
  approved_by UUID REFERENCES auth.users(id),
  status TEXT CHECK (status IN ('pending', 'approved', 'rejected')),
  change_details JSONB,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);
```

#### `custom_roles`
```sql
CREATE TABLE custom_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  permissions JSONB NOT NULL, -- e.g., {"goals": {"create": true, "edit": "own", "delete": false}}
  is_system_role BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `user_role_assignments`
```sql
CREATE TABLE user_role_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role_id UUID REFERENCES custom_roles(id) ON DELETE CASCADE,
  scope TEXT, -- 'global', 'team:team_id', 'goal:goal_id'
  assigned_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, role_id, scope)
);
```

#### `ms_graph_sync_log`
```sql
CREATE TABLE ms_graph_sync_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sync_type TEXT CHECK (sync_type IN ('users', 'org_structure', 'role_mapping')),
  status TEXT CHECK (status IN ('success', 'partial', 'failed')),
  users_synced INTEGER,
  roles_assigned INTEGER,
  errors JSONB,
  sync_duration_ms INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Materialized Views

#### `goal_progress_rollup`
```sql
CREATE MATERIALIZED VIEW goal_progress_rollup AS
WITH team_progress AS (
  SELECT
    tg.company_goal_id,
    AVG(tg.progress_percentage) as avg_team_progress,
    COUNT(*) as team_count,
    COUNT(*) FILTER (WHERE tg.status = 'completed') as completed_count
  FROM team_goals tg
  GROUP BY tg.company_goal_id
),
initiative_progress AS (
  SELECT
    i.team_goal_id,
    AVG(i.progress_percentage) as avg_initiative_progress,
    COUNT(*) as initiative_count,
    COUNT(*) FILTER (WHERE i.status = 'completed') as completed_count
  FROM initiatives i
  WHERE i.team_goal_id IS NOT NULL
  GROUP BY i.team_goal_id
)
SELECT
  cg.id as company_goal_id,
  cg.title as company_goal_title,
  tp.avg_team_progress,
  tp.team_count,
  tp.completed_count as teams_completed,
  ip.avg_initiative_progress,
  ip.initiative_count,
  ip.completed_count as initiatives_completed
FROM company_goals cg
LEFT JOIN team_progress tp ON cg.id = tp.company_goal_id
LEFT JOIN team_goals tg ON cg.id = tg.company_goal_id
LEFT JOIN initiative_progress ip ON tg.id = ip.team_goal_id;

CREATE INDEX idx_goal_progress_company ON goal_progress_rollup(company_goal_id);
```

### Performance Indexes

```sql
-- Goal hierarchy queries
CREATE INDEX idx_team_goals_company ON team_goals(company_goal_id);
CREATE INDEX idx_initiatives_team_goal ON initiatives(team_goal_id);
CREATE INDEX idx_actions_initiative ON actions(linked_initiative_id);

-- Owner/assignee lookups
CREATE INDEX idx_company_goals_owner ON company_goals(owner_id);
CREATE INDEX idx_team_goals_owner ON team_goals(owner_id);
CREATE INDEX idx_team_goals_team ON team_goals(team_id);

-- Status filtering
CREATE INDEX idx_company_goals_status ON company_goals(status);
CREATE INDEX idx_team_goals_status ON team_goals(status);
CREATE INDEX idx_initiatives_status ON initiatives(status);

-- Date range queries
CREATE INDEX idx_company_goals_dates ON company_goals(start_date, target_date);
CREATE INDEX idx_team_goals_dates ON team_goals(start_date, target_date);

-- Check-ins timeline
CREATE INDEX idx_goal_check_ins_date ON goal_check_ins(check_in_date DESC);
CREATE INDEX idx_goal_check_ins_goal ON goal_check_ins(goal_type, goal_id);

-- Dependencies graph traversal
CREATE INDEX idx_goal_deps_blocking ON goal_dependencies(blocking_type, blocking_id);
CREATE INDEX idx_goal_deps_blocked ON goal_dependencies(blocked_type, blocked_id);

-- Role lookups
CREATE INDEX idx_user_roles_user ON user_role_assignments(user_id);
CREATE INDEX idx_user_roles_role ON user_role_assignments(role_id);
```

---

## 2. UI Structure

### Navigation Updates

**New Top-Level Items:**
- "Goals & Initiatives" (replaces/expands "Strategic Planning")
  - Strategy Map (visual hierarchy)
  - Company Goals
  - Team Goals
  - My Initiatives
  - All Initiatives

### Page Structure

#### `/goals-initiatives` (Strategy Map - Landing Page)
- Asana-style visual hierarchy showing company mission → goals → teams → initiatives
- Interactive nodes with click-to-drill-down
- Colour-coded status indicators (green/amber/red)
- Filters: Status, Owner, Team, Date Range
- "+ Create Goal" floating action button (role-gated)

#### `/goals-initiatives/company`
- List/Grid view of company goals
- Sortable columns: Title, Owner, Progress, Status, Target Date
- Expandable cards showing linked team goals
- Bulk actions: Export, Archive, Assign Owner
- "+ Create Company Goal" button

#### `/goals-initiatives/teams`
- Team-organized view (can filter by single team or view all)
- Each team card shows:
  - Team name (from MS Graph)
  - Team goals list
  - Progress rollup chart
  - Team members with avatars
- "+ Create Team Goal" button

#### `/goals-initiatives/initiatives` (Enhanced)
- Existing initiatives view enhanced with:
  - "Parent Goal" column showing team_goal linkage
  - Dependency indicators (🔗 icon with tooltip)
  - Check-in status badges
  - Strategy Map mini-preview showing position in hierarchy
- Filters: All, My Initiatives, Team, Goal, Status

#### `/goals-initiatives/[type]/[id]` (Detail Page)
- **Header Section:**
  - Breadcrumb: Strategy Map → Parent Goal → This Goal
  - Title (inline editable if permitted)
  - Owner avatar + name
  - Status dropdown
  - Progress visualization (auto-calculated or manual input based on method)
  - Dates: Start, Target, Actual Completion
  - Dependency graph widget

- **Tabs:**
  1. **Overview** - Description, metrics, key results
  2. **Child Items** - Linked goals/initiatives in hierarchy
  3. **Check-Ins** - Timeline of status updates
  4. **Actions** - Linked actions from actions table
  5. **Activity** - Collaboration feed (comments, approvals, updates)
  6. **Analytics** - Velocity chart, burn-up, AI insights

- **Right Sidebar:**
  - ChaSen AI Assistant (contextual suggestions)
  - Quick Actions panel
  - Related items (dependencies, related goals)
  - Approval status (if pending)

### Enhanced Actions Page Integration

**Existing `/actions` page gets new features:**
- "Initiative" filter dropdown (populated from initiatives table)
- Initiative column in table view
- Kanban swim lanes option: "Group by Initiative"
- Bulk action: "Link to Initiative" (opens initiative picker)
- Orphan actions indicator: Badge showing "X actions not linked to goals"

---

## 3. Migration Strategy

### Phase 1: Data Audit (Week 1)
1. Export all existing actions with `linked_initiative_id`
2. Identify initiatives with existing linked actions
3. Generate report: Coverage % by CSE, by client, by action type
4. Flag orphaned actions (no initiative link)

### Phase 2: Bulk Mapping Tool (Week 2)
AI-assisted bulk linking interface:
- Display orphaned actions grouped by: CSE, Client, Action Type
- ChaSen AI suggests initiative matches based on:
  - Action description semantic analysis
  - Client context
  - CSE ownership
  - Meeting notes topics
- Bulk select + confirm interface
- Manual override available
- Progress dashboard showing % completion

### Phase 3: Mandatory Linking (Week 3)
- **100% mapping requirement:** All actions must link to an initiative
- Actions creation form:
  - Initiative picker (required field)
  - "+ Create new initiative" quick-add option if none fit
- Validation rule: Block action save if no initiative selected
- Migration dashboard accessible to all CSEs showing their completion %

### Phase 4: Goal Hierarchy Setup (Week 4)
1. Leadership workshop to define company goals (5-10 goals)
2. Team leads create team goals linked to company goals
3. Existing initiatives mapped to team goals (AI-assisted suggestions)
4. Final review: Strategy Map validation session

### Rollback Plan
- All new tables use `ON DELETE SET NULL` for initiative/goal links
- Disabling feature: Set feature flag `goals_system_enabled = false`
- Actions table unchanged (no destructive migrations)
- Can operate in "initiatives only" mode without goals tier

---

## 4. Strategy Map & Visual Hierarchy

### Visualization Engine

**Technology Stack:**
- D3.js for graph rendering (force-directed or hierarchical layout)
- React Flow as alternative (drag-and-drop capable)
- SVG-based for crisp rendering at any zoom level

### Layout Algorithm

```
Company Mission (center, largest node)
  ↓
Company Goals (orbit 1, radius 200px)
  ↓
Team Goals (orbit 2, radius 350px)
  ↓
Initiatives (orbit 3, radius 500px)
  ↓
Actions (collapsed, shown on hover/click)
```

**Node Rendering:**
- Size based on importance/ARR impact
- Colour based on status:
  - Green: On Track (progress ≥ 90%)
  - Amber: At Risk (50-89%)
  - Red: Off Track (< 50%)
  - Grey: Not Started
  - Blue: Completed
- Border thickness indicates priority
- Pulse animation for "needs attention"

**Connections:**
- Hierarchy lines: Solid grey
- Dependency lines: Dashed blue (can be toggled off)
- Blocking relationships: Red dashed with arrow

### Interactivity

- **Click node:** Open detail flyout panel
- **Double-click node:** Navigate to detail page
- **Hover node:** Show progress tooltip + child count
- **Drag node:** Reposition in manual layout mode
- **Right-click node:** Context menu (Edit, Create Child, Delete, Dependencies)
- **Zoom:** Mouse wheel or pinch gesture
- **Pan:** Click-drag background
- **Search:** Highlight matching nodes, dim others
- **Filter:** Hide/show based on status, owner, team

### Flexible Creation & Editing

**Create Flow:**
1. Click "+ Create Goal" button (or right-click parent node → "Create Child")
2. Modal appears with:
   - **Tier auto-selected** based on context (or dropdown if ambiguous)
   - **Title** (required, ChaSen AI suggests based on parent/context)
   - **Description** (rich text editor, ChaSen AI drafts template)
   - **Owner** (user picker, defaults to current user)
   - **Parent Goal** (pre-selected if created from node, otherwise dropdown)
   - **Progress Method:**
     - Auto (from child items) - default
     - Manual (user enters %)
     - Target Value (numeric goal, e.g., "$2M ARR")
     - Boolean (achieved/not achieved)
   - **Dates:** Start, Target
   - **Template:** Dropdown to apply template (optional)
3. Click "Create" → Node appears in Strategy Map with animation

**Edit Flow:**
- Click node → Flyout panel → "Edit" button
- Inline editing for title (click to edit)
- "Edit Details" opens full modal (same fields as create)
- Progress method can be changed anytime
- Changing parent goal triggers approval workflow (if configured)

**Permissions Check:**
- System checks user's role permissions before showing create/edit options
- Greyed-out UI for read-only users
- Tooltip explains why action is disabled

---

## 5. Goal Creation & Editing

### Progress Calculation Methods

#### 1. Auto (Rollup from Children)
```typescript
function calculateAutoProgress(goal: Goal): number {
  const children = getChildGoals(goal.id)
  if (children.length === 0) return 0

  const totalProgress = children.reduce((sum, child) => sum + child.progress_percentage, 0)
  return Math.round(totalProgress / children.length)
}
```

#### 2. Manual Entry
- User inputs percentage directly via slider or text input
- Updated during check-ins
- No validation against child items (decoupled)

#### 3. Target Value
```typescript
interface TargetValueGoal {
  target_value: number
  current_value: number
  unit: string // e.g., "$", "clients", "%"
}

function calculateTargetProgress(goal: TargetValueGoal): number {
  return Math.min(100, (goal.current_value / goal.target_value) * 100)
}
```

#### 4. Boolean (Achieved/Not Achieved)
- Binary toggle
- Progress = 0% or 100%
- Used for milestone-type goals

### Goal Templates

**System Templates:**
1. **Revenue Growth**
   - Tier: Company
   - Title: "Achieve $X ARR in FY26"
   - Metrics: Starting ARR, Target ARR, Current ARR
   - Progress Method: Target Value

2. **Customer Success**
   - Tier: Team
   - Title: "Maintain 95% Gross Retention"
   - Metrics: Retention %, Churn $, Expansion $
   - Progress Method: Target Value

3. **Product Adoption**
   - Tier: Initiative
   - Title: "Drive [Product] adoption across [Segment]"
   - Metrics: Active users, Feature usage %, Training completion
   - Progress Method: Auto (from actions)

4. **Strategic Expansion**
   - Tier: Company/Team
   - Title: "Enter [New Market/Vertical]"
   - Metrics: Deals closed, Pipeline value, Market share
   - Progress Method: Manual

5. **Operational Excellence**
   - Tier: Team
   - Title: "Complete all Operating Rhythm events 100% on time"
   - Metrics: Completion %, Overdue events
   - Progress Method: Auto (from segmentation_events)

**Custom Templates:**
- Admins can create new templates via `/admin/goal-templates`
- Templates are shareable across teams
- Use count tracked for analytics

### ChaSen AI-Assisted Creation

**Natural Language Input:**
```typescript
// User types: "We need to grow ARR by 20% this year in healthcare"

// ChaSen AI suggests:
{
  tier: "company",
  title: "Grow Healthcare ARR by 20% in FY26",
  description: "Increase annual recurring revenue in the healthcare vertical from $X to $Y by June 30, 2026",
  progress_method: "target_value",
  target_value: calculated_target,
  current_value: current_arr,
  suggested_team_goals: [
    "Expand existing healthcare accounts",
    "Acquire 10 new healthcare clients",
    "Launch Healthcare-specific product features"
  ],
  suggested_initiatives: [
    "Healthcare vertical sales playbook",
    "Clinical workflow integration",
    "Regulatory compliance certification"
  ]
}
```

**AI Features During Creation:**
- Title refinement suggestions
- Description drafting based on context
- Metric recommendations based on goal type
- Parent goal suggestions (if tier allows)
- Similar goals detection (prevent duplicates)
- Dependency suggestions (based on historical patterns)

---

## 6. Flexible RBAC System

### Permission Model

**Granular Permissions (per entity type):**
- `create` - Can create new goals/initiatives
- `edit` - Can edit: `all`, `own`, `team`, `none`
- `delete` - Can delete: `all`, `own`, `none`
- `approve` - Can approve changes requiring approval
- `view_confidential` - Can view goals marked confidential
- `manage_roles` - Can assign roles to users
- `bulk_operations` - Can perform bulk actions

### System Roles (Pre-defined)

#### 1. Executive Leadership
```json
{
  "company_goals": { "create": true, "edit": "all", "delete": "all", "approve": true },
  "team_goals": { "create": true, "edit": "all", "delete": "all", "approve": true },
  "initiatives": { "create": true, "edit": "all", "delete": "all" },
  "actions": { "create": true, "edit": "all", "delete": "all" },
  "view_confidential": true,
  "manage_roles": true,
  "bulk_operations": true
}
```

#### 2. Team Lead
```json
{
  "company_goals": { "create": false, "edit": "none", "delete": "none" },
  "team_goals": { "create": true, "edit": "team", "delete": "own" },
  "initiatives": { "create": true, "edit": "team", "delete": "own" },
  "actions": { "create": true, "edit": "team", "delete": "team" },
  "view_confidential": false,
  "manage_roles": false,
  "bulk_operations": true
}
```

#### 3. CSE (Customer Success Engineer)
```json
{
  "company_goals": { "create": false, "edit": "none", "delete": "none" },
  "team_goals": { "create": false, "edit": "none", "delete": "none" },
  "initiatives": { "create": true, "edit": "own", "delete": "own" },
  "actions": { "create": true, "edit": "own", "delete": "own" },
  "view_confidential": false,
  "manage_roles": false,
  "bulk_operations": false
}
```

#### 4. Cross-Functional Contributor
```json
{
  "company_goals": { "create": false, "edit": "none", "delete": "none" },
  "team_goals": { "create": false, "edit": "none", "delete": "none" },
  "initiatives": { "create": false, "edit": "assigned", "delete": "none" },
  "actions": { "create": true, "edit": "own", "delete": "own" },
  "view_confidential": false,
  "manage_roles": false,
  "bulk_operations": false
}
```

#### 5. View-Only (Stakeholder)
```json
{
  "company_goals": { "create": false, "edit": "none", "delete": "none" },
  "team_goals": { "create": false, "edit": "none", "delete": "none" },
  "initiatives": { "create": false, "edit": "none", "delete": "none" },
  "actions": { "create": false, "edit": "none", "delete": "none" },
  "view_confidential": false,
  "manage_roles": false,
  "bulk_operations": false
}
```

### Custom Role Creation

**UI: `/admin/roles`**

Features:
- Role name + description
- Visual permissions matrix (checkboxes for each entity/action combo)
- Test mode: Preview what a user with this role would see
- Clone existing role to modify
- Audit log of role changes

**Permissions Matrix UI:**
```
                    Create    Edit        Delete    Approve
Company Goals       [ ]       [All|Team|Own|None]  [ ]      [ ]
Team Goals          [x]       [All|Team|Own|None]  [x]      [ ]
Initiatives         [x]       [All|Team|Own|None]  [x]      [ ]
Actions             [x]       [All|Team|Own|None]  [x]      [ ]

Special Permissions:
[x] View Confidential Goals
[ ] Manage User Roles
[x] Bulk Operations
```

### Role Assignment

**Manual Assignment:**
- Admin navigates to `/admin/users/[userId]/roles`
- Select role from dropdown
- Choose scope:
  - Global (all goals/teams)
  - Team-specific (only goals/initiatives in Team X)
  - Goal-specific (only children of Goal Y)
- Assign button → Creates `user_role_assignments` record

**Automatic Assignment (MS Graph):**
- See MS Graph Integration section below

---

## 7. MS Graph Integration

### Auto-Sync Architecture

**Sync Schedule:**
- Full sync: Daily at 2 AM UTC
- Delta sync: Every 4 hours (only changed users)
- On-demand sync: Admin can trigger manually

**Sync Process:**
```typescript
async function syncMSGraph() {
  // 1. Fetch users from Azure AD
  const graphUsers = await fetchGraphUsers()

  // 2. Upsert users table
  for (const user of graphUsers) {
    await upsertUser({
      id: user.id,
      email: user.mail,
      display_name: user.displayName,
      job_title: user.jobTitle,
      department: user.department,
      manager_id: user.manager?.id,
      office_location: user.officeLocation
    })
  }

  // 3. Fetch org structure (groups/teams)
  const graphGroups = await fetchGraphGroups()

  for (const group of graphGroups) {
    await upsertTeam({
      id: group.id,
      name: group.displayName,
      description: group.description,
      members: group.members.map(m => m.id)
    })
  }

  // 4. Map roles based on job title/department
  await assignRolesFromMapping(graphUsers)

  // 5. Log sync results
  await logSyncResults(results)
}
```

### Role Mapping Configuration

**UI: `/admin/ms-graph-role-mapping`**

Mapping rules stored in `role_mapping_rules` table:
```sql
CREATE TABLE role_mapping_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_type TEXT CHECK (source_type IN ('job_title', 'department', 'security_group')),
  source_value TEXT, -- e.g., "VP Customer Success", "Engineering", "Goal_Approvers"
  target_role_id UUID REFERENCES custom_roles(id),
  priority INTEGER, -- Higher priority rules apply first
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Example Mappings:**
| Source Type       | Source Value                | Target Role           | Priority |
|-------------------|-----------------------------|----------------------|----------|
| job_title         | VP Customer Success         | Executive Leadership | 100      |
| job_title         | Customer Success Manager    | Team Lead            | 90       |
| job_title         | Customer Success Engineer   | CSE                  | 80       |
| department        | Sales                       | Cross-Functional     | 50       |
| security_group    | Goal_Approvers              | (adds approve perm)  | 110      |

**Mapping Logic:**
1. Sort rules by priority (descending)
2. For each user:
   - Match job_title rules
   - Match department rules
   - Match security_group memberships
   - Apply highest priority matching rule
   - If multiple rules match, combine permissions (union)
3. Create/update `user_role_assignments` records

### Org Structure Sync

**Team Creation:**
- MS Graph groups → `team_goals.team_id` mapping
- Group display name → Team name
- Group members → Auto-populate team goal ownership suggestions

**Hierarchy Detection:**
- Manager relationship → Suggest reporting structure for approvals
- Department nesting → Suggest team goal hierarchy

### Flexibility & Scalability

**Override Capability:**
- Manual role assignments take precedence over auto-mapped roles
- `user_role_assignments.source` field tracks: `manual` vs `ms_graph`
- Admins can lock manual assignments to prevent sync overwrite

**New Departments/Titles:**
- Unmapped users get "View-Only" role by default
- Daily report sent to admins: "X unmapped users detected"
- One-click "Create mapping rule" from report

**Audit Trail:**
- `ms_graph_sync_log` table records every sync
- User detail page shows role assignment history
- Admins can view: "Role assigned by MS Graph sync on [date]"

---

## 8. Scalability & Flexibility

### Database Partitioning

**Table Partitioning Strategy (for 50+ initiatives scaling to 500+):**

```sql
-- Partition by fiscal year for time-series data
CREATE TABLE goal_check_ins_partitioned (
  LIKE goal_check_ins INCLUDING ALL
) PARTITION BY RANGE (check_in_date);

CREATE TABLE goal_check_ins_fy25 PARTITION OF goal_check_ins_partitioned
  FOR VALUES FROM ('2024-07-01') TO ('2025-07-01');

CREATE TABLE goal_check_ins_fy26 PARTITION OF goal_check_ins_partitioned
  FOR VALUES FROM ('2025-07-01') TO ('2026-07-01');

-- Auto-create future partitions via cron job
```

**Horizontal Scaling:**
- Read replicas for reporting queries
- Write queries to primary DB
- Materialized views refresh on replicas

### Caching Strategy

**Redis Cache Layers:**
1. **Goal Hierarchy Cache** (TTL: 5 minutes)
   - Key: `goal:hierarchy:${companyGoalId}`
   - Value: Full tree JSON (company → teams → initiatives → actions)
   - Invalidate on: Any goal/initiative update

2. **User Permissions Cache** (TTL: 15 minutes)
   - Key: `user:permissions:${userId}`
   - Value: Resolved permissions object
   - Invalidate on: Role assignment change, role definition change

3. **Progress Rollup Cache** (TTL: 10 minutes)
   - Key: `goal:progress:${goalId}`
   - Value: Calculated progress metrics
   - Invalidate on: Child item progress update

**Real-Time Invalidation:**
```typescript
// After goal update
await redis.del(`goal:hierarchy:${goal.company_goal_id}`)
await redis.del(`goal:progress:${goal.id}`)
await publishToWebSocket({ type: 'goal_updated', goalId: goal.id })
```

### Plugin System for Custom Progress Calculators

**Architecture:**
```typescript
interface ProgressCalculatorPlugin {
  id: string
  name: string
  description: string
  calculate(goal: Goal, children: Goal[]): number
  validate(goal: Goal): ValidationResult
}

class PluginRegistry {
  private plugins: Map<string, ProgressCalculatorPlugin> = new Map()

  register(plugin: ProgressCalculatorPlugin) {
    this.plugins.set(plugin.id, plugin)
  }

  calculate(goal: Goal, pluginId: string): number {
    const plugin = this.plugins.get(pluginId)
    return plugin.calculate(goal, goal.children)
  }
}
```

**Example Plugin: Weighted Progress**
```typescript
const weightedProgressPlugin: ProgressCalculatorPlugin = {
  id: 'weighted_progress',
  name: 'Weighted Progress',
  description: 'Calculate progress based on child item weights',

  calculate(goal, children) {
    const totalWeight = children.reduce((sum, c) => sum + c.weight, 0)
    const weightedProgress = children.reduce((sum, c) =>
      sum + (c.progress_percentage * c.weight), 0)

    return Math.round(weightedProgress / totalWeight)
  },

  validate(goal) {
    const totalWeight = goal.children.reduce((sum, c) => sum + c.weight, 0)
    return totalWeight === 100
      ? { valid: true }
      : { valid: false, error: 'Child weights must sum to 100' }
  }
}
```

### API Architecture

**RESTful Endpoints:**
```
GET    /api/goals                    - List goals (with filters)
POST   /api/goals                    - Create goal
GET    /api/goals/:id                - Get goal detail
PATCH  /api/goals/:id                - Update goal
DELETE /api/goals/:id                - Archive goal
GET    /api/goals/:id/hierarchy      - Get full hierarchy tree
GET    /api/goals/:id/progress       - Get progress calculation
POST   /api/goals/:id/check-in       - Create check-in
GET    /api/goals/:id/dependencies   - Get dependency graph
POST   /api/goals/:id/approve        - Approve pending change

GET    /api/initiatives              - List initiatives
POST   /api/initiatives              - Create initiative
GET    /api/initiatives/:id          - Get detail
PATCH  /api/initiatives/:id          - Update
DELETE /api/initiatives/:id          - Archive

POST   /api/ms-graph/sync            - Trigger manual sync
GET    /api/ms-graph/sync-status     - Get last sync results
```

**GraphQL Alternative (for complex queries):**
```graphql
query GetStrategyMap {
  companyGoals {
    id
    title
    progress
    teamGoals {
      id
      title
      progress
      initiatives {
        id
        title
        progress
        actions {
          id
          description
          status
        }
      }
    }
  }
}
```

### Webhook System for External Integrations

**Use Cases:**
- Slack notifications on goal status changes
- Update external PM tools (Jira, Monday.com)
- Trigger automation workflows (Zapier, Make)
- Sync to data warehouses

**Implementation:**
```sql
CREATE TABLE webhooks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  url TEXT NOT NULL,
  events TEXT[] NOT NULL, -- ['goal.created', 'goal.updated', 'goal.completed']
  secret TEXT, -- For signature verification
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE webhook_deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  webhook_id UUID REFERENCES webhooks(id),
  event_type TEXT,
  payload JSONB,
  response_status INTEGER,
  response_body TEXT,
  delivered_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Delivery:**
```typescript
async function deliverWebhook(event: GoalEvent) {
  const webhooks = await getActiveWebhooks(event.type)

  for (const webhook of webhooks) {
    const payload = {
      event: event.type,
      data: event.goal,
      timestamp: new Date().toISOString()
    }

    const signature = generateSignature(payload, webhook.secret)

    try {
      const response = await fetch(webhook.url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Webhook-Signature': signature
        },
        body: JSON.stringify(payload)
      })

      await logDelivery(webhook.id, response.status, await response.text())
    } catch (error) {
      await logDelivery(webhook.id, 0, error.message)
    }
  }
}
```

### Audit Trail

**Comprehensive Activity Log:**
```sql
CREATE TABLE goal_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_type TEXT CHECK (goal_type IN ('company', 'team', 'initiative')),
  goal_id UUID NOT NULL,
  action TEXT CHECK (action IN ('created', 'updated', 'deleted', 'status_changed', 'progress_updated', 'owner_changed')),
  actor_id UUID REFERENCES auth.users(id),
  old_values JSONB,
  new_values JSONB,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_goal ON goal_audit_log(goal_type, goal_id);
CREATE INDEX idx_audit_actor ON goal_audit_log(actor_id);
CREATE INDEX idx_audit_created ON goal_audit_log(created_at DESC);
```

**Retention Policy:**
- Keep 2 years of audit logs in primary DB
- Archive older logs to cold storage (S3)
- Compliance export feature for audits

---

## 9. Additional Asana Features

### 9.1 Dependencies & Blocking Relationships

**UI Indicators:**
- 🔗 icon on goal cards showing dependency count
- Red 🚫 icon if blocked by incomplete dependencies
- Timeline view shows dependency lines (critical path highlighted)

**Dependency Management Modal:**
- "Add Dependency" button on goal detail page
- Search/select goal to link
- Relationship type: "Blocks" or "Related To"
- Auto-validation: Prevent circular dependencies

**Critical Path Calculation:**
```typescript
function calculateCriticalPath(goal: Goal): Goal[] {
  const blocking = getBlockingGoals(goal)
  if (blocking.length === 0) return [goal]

  const longestPath = blocking.reduce((longest, blocker) => {
    const path = calculateCriticalPath(blocker)
    return path.length > longest.length ? path : longest
  }, [])

  return [...longestPath, goal]
}
```

**Notifications:**
- "Goal X is blocked by Y" alert on detail page
- Email notification when blocking goal completes: "You can now start Goal Z"

### 9.2 Status Check-Ins

**Weekly Check-In Workflow:**
1. Every Monday, goal owners receive notification: "Weekly check-in due for Goal X"
2. Click notification → Opens check-in modal:
   - Status dropdown: On Track / At Risk / Off Track
   - Progress update (text field, 280 char limit)
   - Blockers (optional text field)
   - Next steps (bullet list)
3. Submit → Creates `goal_check_ins` record
4. Check-in appears in Activity feed + visible to stakeholders

**UI Components:**
- Check-ins timeline on goal detail page (vertical timeline)
- Latest check-in badge on goal cards
- Overdue check-in indicator (red dot) if > 7 days since last update

**Automated Reminders:**
```typescript
// Cron job: Every Monday 9 AM
async function sendCheckInReminders() {
  const goals = await getActiveGoalsRequiringCheckIn()

  for (const goal of goals) {
    await sendEmail({
      to: goal.owner_email,
      subject: `Weekly check-in: ${goal.title}`,
      body: renderCheckInTemplate(goal)
    })
  }
}
```

### 9.3 Forms for Goal Creation

**Structured Input Forms:**
- Template-based forms (select template → form pre-fills)
- Dynamic fields based on goal tier
- Conditional fields (e.g., "If progress method = target_value, show target field")

**Form Builder (Admin):**
- Drag-drop field designer
- Field types: Text, Number, Date, Dropdown, Multi-select, Rich Text
- Validation rules per field
- Save as template for reuse

**Use Cases:**
- Quarterly goal submission form (leadership fills for company goals)
- Initiative request form (CSEs submit for approval)
- Goal approval form (approvers fill rejection reason)

### 9.4 Activity Feed & Collaboration

**Activity Types:**
- Goal created/updated/completed
- Check-in submitted
- Comment added
- Approval requested/granted/denied
- Owner changed
- Dependency added
- Status changed

**Feed UI:**
- Vertical timeline on goal detail page
- Filter by: Activity Type, User, Date Range
- Subscribe to goal → Get notifications on all activity

**Comments:**
- Rich text comments on any goal
- @mention users (triggers notification)
- Attach files (stored in Supabase Storage)
- React with emoji (👍 ❤️ 🎉)

**Real-Time Updates:**
- WebSocket connection for live activity feed
- Toast notification when other users edit same goal

### 9.5 Approval Workflows

**Approval Triggers:**
- Company goal creation (requires VP approval)
- Goal target date extension (requires manager approval)
- Goal deletion (requires creator + manager approval)
- Budget-impacting goals (requires finance approval)

**Workflow Configuration:**
```sql
CREATE TABLE approval_workflows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  trigger_condition JSONB, -- e.g., {"goal_type": "company", "action": "create"}
  approver_role_id UUID REFERENCES custom_roles(id),
  approver_user_ids UUID[], -- Optional: Specific users
  require_all BOOLEAN DEFAULT false, -- All approvers must approve vs. any one
  timeout_hours INTEGER, -- Auto-reject after X hours
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Approval UI:**
- Pending approvals badge in nav bar
- Approvals inbox at `/goals-initiatives/approvals`
- Each item shows: Goal title, Requested by, Change details, Approve/Reject buttons
- Rejection requires comment (mandatory field)

**Email Notifications:**
- Requester: "Your goal creation request is pending approval"
- Approver: "You have a pending approval: Goal X"
- Requester: "Your goal was approved/rejected"

---

## 10. ChaSen AI Integration

### 10.1 Natural Language Goal Creation

**User Input:**
```
"Create a goal to increase ARR by 15% in healthcare this year"
```

**ChaSen Processing:**
```typescript
async function parseGoalIntent(input: string): Promise<GoalDraft> {
  const response = await chasen.analyze({
    prompt: `Extract goal details from: "${input}"`,
    context: {
      current_arr: await getCurrentARR('healthcare'),
      fiscal_year: getCurrentFiscalYear(),
      existing_goals: await getActiveGoals({ vertical: 'healthcare' })
    }
  })

  return {
    tier: 'company',
    title: 'Increase Healthcare ARR by 15% in FY26',
    description: response.description,
    progress_method: 'target_value',
    target_value: response.calculated_target,
    current_value: response.current_value,
    unit: '$',
    start_date: response.fiscal_year_start,
    target_date: response.fiscal_year_end,
    suggested_team_goals: response.breakdown,
    confidence_score: response.confidence
  }
}
```

**UI Flow:**
1. User clicks "+ Create Goal" → Modal opens
2. "Describe your goal" text area appears
3. User types natural language description
4. ChaSen badge pulses → "Analyzing..."
5. Form fields auto-populate with parsed values
6. User reviews/edits → Submits

**Edge Cases:**
- Ambiguous input → ChaSen asks clarifying question
- Duplicate goal detected → Shows warning + link to existing goal
- Unrealistic target → ChaSen suggests adjusted target with reasoning

### 10.2 Smart Goal Linking

**Auto-Linking Actions to Initiatives:**
```typescript
async function suggestInitiativeLink(action: Action): Promise<Initiative[]> {
  const matches = await chasen.findSimilar({
    type: 'initiative',
    query: action.description,
    context: {
      client_id: action.client_id,
      cse_name: action.cse_name,
      meeting_topics: action.related_meeting_topics
    },
    limit: 5
  })

  return matches.map(m => ({
    initiative: m.item,
    confidence: m.score,
    reason: m.explanation
  }))
}
```

**UI:**
- When creating action without initiative link, sidebar shows:
  - "Suggested Initiatives" panel
  - Top 3 matches with confidence badges (High/Medium/Low)
  - One-click "Link to this" button
  - Tooltip explaining why suggested

**Auto-Link Mode:**
- Background job runs nightly on orphaned actions
- High-confidence matches (>85%) auto-link
- Medium-confidence (60-85%) added to review queue
- Low-confidence (<60%) flagged for manual review

### 10.3 Weekly Executive Digest

**Content Generation:**
```typescript
async function generateWeeklyDigest(userId: string): Promise<Digest> {
  const user = await getUser(userId)
  const goals = await getUserGoals(userId) // Owned or watching

  const digest = await chasen.summarize({
    goals: goals.map(g => ({
      title: g.title,
      progress_delta: g.progress_this_week - g.progress_last_week,
      status: g.status,
      recent_check_ins: g.check_ins_this_week
    })),
    tone: 'executive', // Concise, action-oriented
    format: 'email'
  })

  return {
    subject: `Goals Digest: Week of ${getWeekStart()}`,
    summary: digest.summary, // 2-3 sentences
    highlights: digest.highlights, // Bullet list
    action_required: digest.action_items,
    at_risk_goals: digest.risks
  }
}
```

**Digest Sections:**
1. **Executive Summary** (2-3 sentences)
   - Overall portfolio health
   - Week-over-week progress trend

2. **Goals at Risk** (if any)
   - List of goals with status = "off_track" or "at_risk"
   - ChaSen-generated explanation of why at risk
   - Suggested interventions

3. **Key Milestones Achieved**
   - Goals/initiatives marked complete this week
   - Impact statement (e.g., "unlocks 3 dependent initiatives")

4. **Upcoming Deadlines** (next 14 days)
   - Goals with target dates approaching
   - Check-ins due

5. **Recommended Actions**
   - ChaSen-suggested next steps
   - E.g., "Schedule check-in with Sarah on Initiative X"

**Delivery:**
- Email sent every Monday 8 AM (user timezone)
- Also available in-app at `/goals-initiatives/digest`
- Slack integration optional (post to #goals channel)

### 10.4 Risk Prediction & Early Warnings

**Risk Scoring Model:**
```typescript
interface RiskFactors {
  progress_velocity: number // % change per week
  check_in_frequency: number // Days since last check-in
  dependency_blocks: number // Count of blocking dependencies
  owner_workload: number // Count of active goals owned
  historical_delay_rate: number // % of past goals delivered late
}

async function calculateRiskScore(goal: Goal): Promise<number> {
  const factors = await collectRiskFactors(goal)

  const score = await chasen.predict({
    model: 'goal_risk_classifier',
    features: factors
  })

  return score // 0-100, higher = more risk
}
```

**Warning Thresholds:**
- Risk Score 70-85: Yellow flag (at_risk status)
- Risk Score 85+: Red flag (off_track status)
- Auto-email owner + manager when flag triggered

**ChaSen Insights:**
```typescript
async function generateRiskInsight(goal: Goal, riskScore: number): Promise<string> {
  return await chasen.explain({
    goal: goal,
    risk_score: riskScore,
    prompt: 'Explain why this goal is at risk and suggest mitigation'
  })
}

// Example output:
// "Initiative X is at risk (score: 82) because:
//  1. Progress velocity has slowed from 12%/week to 3%/week
//  2. No check-in submitted in 14 days
//  3. Blocked by 2 incomplete dependencies
//
//  Recommended actions:
//  - Schedule urgent check-in with owner
//  - Escalate blocking dependencies to leadership
//  - Consider deadline extension or scope reduction"
```

**Proactive Alerts:**
- Notification 3 days before goal transitions to "at risk"
- Email to stakeholders when risk score increases >20 points
- Weekly risk dashboard for leadership (all at-risk goals)

### 10.5 Meeting Notes → Goals Extraction

**Auto-Extract from Unified Meetings:**
```typescript
async function extractGoalsFromMeeting(meetingId: string): Promise<GoalSuggestion[]> {
  const meeting = await getMeeting(meetingId)

  const extracted = await chasen.extract({
    text: meeting.meeting_notes,
    extract_types: ['goals', 'initiatives', 'action_items'],
    context: {
      attendees: meeting.attendees,
      client_id: meeting.client_id,
      meeting_type: meeting.meeting_type
    }
  })

  return extracted.map(item => ({
    type: item.type, // 'company_goal', 'team_goal', 'initiative'
    title: item.title,
    description: item.description,
    confidence: item.confidence,
    source_quote: item.quote_from_notes,
    suggested_owner: item.suggested_owner,
    suggested_parent: item.suggested_parent_goal
  }))
}
```

**UI Integration:**
1. After meeting is saved, ChaSen analyzes notes
2. If goals/initiatives detected, badge appears on meeting card
3. Click badge → Modal shows extracted items
4. User reviews each item:
   - Accept → Creates goal/initiative
   - Edit → Modify fields before creating
   - Reject → Dismiss
5. Accepted items auto-link to meeting (audit trail)

**Meeting Types Optimized For:**
- Strategic planning sessions (company/team goals)
- QBRs (initiative commitments)
- 1:1s with leadership (action items → initiatives)

### 10.6 Next Best Actions Recommendation

**Context-Aware Suggestions:**
```typescript
async function suggestNextActions(userId: string): Promise<ActionSuggestion[]> {
  const context = await gatherUserContext(userId)

  const suggestions = await chasen.recommend({
    user: context.user,
    owned_goals: context.owned_goals,
    at_risk_goals: context.at_risk_goals,
    overdue_check_ins: context.overdue_check_ins,
    upcoming_deadlines: context.upcoming_deadlines,
    recent_activity: context.recent_activity,
    historical_patterns: context.historical_patterns
  })

  return suggestions.map(s => ({
    action: s.action,
    reason: s.reason,
    priority: s.priority, // 'urgent', 'high', 'medium', 'low'
    time_estimate: s.estimated_minutes,
    impact: s.expected_impact
  }))
}
```

**Example Suggestions:**
- "Submit overdue check-in for Initiative X (due 3 days ago)"
- "Review and approve 2 pending goal requests"
- "Schedule 1:1 with Sarah - her goals are 40% behind schedule"
- "Update progress on Goal Y - target date is in 5 days"
- "Link 12 orphaned actions to initiatives"

**UI Placement:**
- Dashboard widget: "Recommended Actions" card (top 3)
- Full list at `/goals-initiatives/recommendations`
- Browser notification for urgent items
- Morning digest email (if enabled)

**Learning from Feedback:**
- User can mark suggestion as "helpful" or "not helpful"
- Dismissing suggestion teaches ChaSen to deprioritize similar
- Completing suggested action increases weight for similar patterns

### 10.7 Goal Health Scoring & Predictive Insights

**Comprehensive Health Score:**
```typescript
interface HealthScore {
  overall: number // 0-100
  components: {
    progress_health: number // On track for target date?
    engagement_health: number // Check-ins, comments, activity
    dependency_health: number // Blocked or blocking?
    team_health: number // Owner workload, team capacity
    confidence_health: number // Historical delivery rate
  }
  trend: 'improving' | 'stable' | 'declining'
  forecast: {
    predicted_completion_date: Date
    completion_probability: number // % chance of on-time delivery
  }
}

async function calculateHealthScore(goal: Goal): Promise<HealthScore> {
  const components = {
    progress_health: calculateProgressHealth(goal),
    engagement_health: calculateEngagementHealth(goal),
    dependency_health: calculateDependencyHealth(goal),
    team_health: await calculateTeamHealth(goal),
    confidence_health: await calculateConfidenceHealth(goal)
  }

  const overall = Object.values(components).reduce((sum, v) => sum + v, 0) / 5

  const forecast = await chasen.forecast({
    goal: goal,
    historical_velocity: goal.progress_history,
    current_health: overall
  })

  return {
    overall: Math.round(overall),
    components,
    trend: calculateTrend(goal.health_history),
    forecast
  }
}
```

**UI Visualization:**
- Health score badge on goal cards (0-100 with colour gradient)
- Detail page shows radar chart of 5 health components
- Trend sparkline (last 30 days of health scores)
- Forecast timeline: "Predicted completion: [date] (probability: 78%)"

**Alerts:**
- Health score drops >15 points in 7 days → Notification
- Forecast shows <50% on-time probability → Escalation email
- Quarterly health report for leadership (all goals scored)

**ChaSen Insights Panel:**
```
Health Score: 68/100 (Declining)

Components:
✅ Progress Health: 85 (On track)
⚠️  Engagement Health: 60 (Low check-in frequency)
❌ Dependency Health: 45 (2 blockers incomplete)
✅ Team Health: 75 (Capacity available)
⚠️  Confidence Health: 55 (Owner has 40% late delivery rate)

Forecast:
📅 Predicted Completion: August 15, 2026 (3 weeks late)
📊 On-Time Probability: 34%

Recommendations:
1. Schedule urgent check-in to unblock dependencies
2. Reassign blocking Initiative X to faster-moving team
3. Consider deadline extension to September 1 (87% probability)
```

---

## 11. Implementation Timeline

### Phase 1: Foundation (Weeks 1-2)
- [ ] Database schema creation (all tables + indexes)
- [ ] Materialized views for progress rollup
- [ ] Basic CRUD API routes for goals/initiatives
- [ ] Migration strategy tooling (audit + bulk mapper)

### Phase 2: Core UI (Weeks 3-4)
- [ ] Strategy Map visualization (D3.js/React Flow)
- [ ] Goal/Initiative detail pages
- [ ] Create/Edit forms with progress methods
- [ ] Enhanced Actions page integration
- [ ] Navigation updates

### Phase 3: RBAC & MS Graph (Weeks 5-6)
- [ ] Custom roles UI + permissions matrix
- [ ] MS Graph sync scheduler
- [ ] Role mapping configuration UI
- [ ] User role assignment interface
- [ ] Permission checking middleware

### Phase 4: Advanced Features (Weeks 7-8)
- [ ] Dependencies & blocking UI
- [ ] Check-in workflow + timeline
- [ ] Activity feed + comments
- [ ] Approval workflows + inbox
- [ ] Forms builder

### Phase 5: ChaSen AI Integration (Weeks 9-10)
- [ ] NL goal creation parser
- [ ] Smart linking engine
- [ ] Weekly digest generator
- [ ] Risk prediction model
- [ ] Meeting extraction
- [ ] Next best actions recommender
- [ ] Health scoring system

### Phase 6: Performance & Polish (Weeks 11-12)
- [ ] Redis caching layer
- [ ] Database partitioning
- [ ] Webhook system
- [ ] Audit trail UI
- [ ] Plugin system for custom calculators
- [ ] Load testing + optimization

### Phase 7: Launch Prep (Week 13)
- [ ] Admin training sessions
- [ ] User documentation
- [ ] Video tutorials
- [ ] Pilot with 5 CSEs
- [ ] Feedback iteration
- [ ] Full rollout to all users

---

## 12. Success Metrics

### Adoption Metrics
- % of actions linked to initiatives (target: 100% by Week 3)
- % of users creating check-ins weekly (target: 80%)
- % of goals with complete hierarchy (target: 95%)
- Daily active users on Strategy Map (target: 60% of team)

### Effectiveness Metrics
- Average time to link action to initiative (target: <30 seconds)
- Goal completion rate (target: >85% on-time)
- Risk prediction accuracy (target: >75% precision)
- User satisfaction score (target: 8/10)

### Business Impact
- Reduction in orphaned actions (target: 0%)
- Increase in strategic alignment visibility (measured via surveys)
- Time saved on manual reporting (target: 5 hours/week per leader)
- Reduction in missed deadlines (target: 50% reduction vs. baseline)

---

## 13. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Users resist mandatory action linking | High | Provide AI-assisted bulk mapper, make process <30s |
| MS Graph sync failures cause data drift | Medium | Daily reconciliation reports, manual override UI |
| Strategy Map performance degrades with scale | Medium | Virtualization, lazy loading, client-side caching |
| ChaSen AI suggestions are inaccurate | Medium | Confidence thresholds, user feedback loop, gradual rollout |
| Custom roles create permission confusion | Low | Role preview mode, audit trail, default safe permissions |
| Approval workflows cause bottlenecks | Medium | Timeout auto-escalation, delegate approver feature |

---

## 14. Appendix

### A. Database ER Diagram
```
company_goals (1) --→ (*) team_goals (1) --→ (*) initiatives (1) --→ (*) actions
      ↓                      ↓                      ↓
  goal_templates      goal_check_ins      action_relations
      ↓                      ↓
custom_roles          goal_dependencies
      ↓
user_role_assignments
```

### B. Example User Journey: CSE Creating Initiative

1. CSE logs in → Dashboard shows "12 orphaned actions" badge
2. Clicks badge → Opens bulk linking tool
3. ChaSen AI suggests initiative for each action (confidence scores shown)
4. CSE reviews suggestions, accepts 10, manually links 2
5. Clicks "Create new initiative" for last action
6. Modal opens with:
   - Title pre-filled by ChaSen from action description
   - Parent goal dropdown (suggests team goal based on client/CSE)
   - Progress method defaults to "Auto"
7. CSE reviews, clicks "Create"
8. New initiative appears in Strategy Map
9. Action auto-links to new initiative
10. Badge updates: "0 orphaned actions" ✅

### C. Glossary

- **Company Goal**: Top-tier strategic objective owned by leadership
- **Team Goal**: Mid-tier objective owned by team leads, linked to company goal
- **Initiative**: Bottom-tier project/workstream linked to team goal
- **Action**: Granular task linked to initiative (existing actions table)
- **Progress Method**: Algorithm for calculating goal completion (auto/manual/target/boolean)
- **Check-In**: Weekly status update on goal progress
- **Dependency**: Relationship where Goal A blocks Goal B
- **Approval Workflow**: Required sign-off before goal change takes effect
- **MS Graph**: Microsoft Graph API for Azure AD user/org sync
- **ChaSen AI**: Internal AI assistant for recommendations and automation
- **Strategy Map**: Visual hierarchy showing all goals and their relationships
- **Health Score**: Predictive metric (0-100) indicating goal delivery likelihood

---

**End of Design Document**

*This design has been validated incrementally with all stakeholders and is approved for implementation.*
