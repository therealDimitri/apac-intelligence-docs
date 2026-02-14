# UX Coherence 10/10 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Raise UX coherence from 8.5/10 to 10/10 by building 3 shared components and sweeping the codebase to eliminate hardcoded styling patterns.

**Architecture:** Build StatusBadge, EmptyState, and CardContainer components using existing design tokens, then mechanically replace inline patterns across ~130 file locations. No new tokens, no backend changes, no behaviour changes — pure visual consistency.

**Tech Stack:** React, TypeScript, Tailwind CSS, existing design-tokens.ts

---

### Task 1: Create StatusBadge Component

**Files:**
- Create: `src/components/ui/StatusBadge.tsx`

**Step 1: Create StatusBadge component**

```tsx
import { cn } from '@/lib/utils'
import {
  BadgeStyles,
  getActionStatusColor,
  getPriorityColor,
  getHealthColor,
  getHealthStatus,
  getNPSColor,
  type Priority,
  type ActionStatus,
  type NPSSentiment,
} from '@/lib/design-tokens'

type BadgeShape = 'pill' | 'rect' | 'tag' | 'pillLarge'

interface StatusBadgeProps {
  /** Action/goal status: "In Progress", "Completed", "Blocked", etc. */
  status?: string
  /** Priority level: "critical", "high", "medium", "low" */
  priority?: string
  /** Health score (0-100) — auto-derives label */
  health?: number
  /** NPS sentiment: "promoter", "passive", "detractor" */
  sentiment?: NPSSentiment
  /** Custom label override (otherwise auto-derived from status/priority/health) */
  label?: string
  /** Badge shape */
  variant?: BadgeShape
  /** Additional classes */
  className?: string
}

export function StatusBadge({
  status,
  priority,
  health,
  sentiment,
  label,
  variant = 'pill',
  className,
}: StatusBadgeProps) {
  const shapeClass = BadgeStyles[variant]

  // Determine colours and label from props (priority order: health > priority > sentiment > status)
  let colorClass = 'bg-gray-100 text-gray-700'
  let derivedLabel = label || ''

  if (health !== undefined) {
    const healthStatus = getHealthStatus(health)
    const colors = getHealthColor(health)
    colorClass = colors.badge
    if (!label) {
      derivedLabel = healthStatus === 'healthy' ? 'Healthy' : healthStatus === 'atRisk' ? 'At Risk' : 'Critical'
    }
  } else if (priority) {
    const colors = getPriorityColor(priority)
    colorClass = colors.badge
    if (!label) {
      const normalised = priority.toLowerCase()
      derivedLabel = normalised.charAt(0).toUpperCase() + normalised.slice(1)
    }
  } else if (sentiment) {
    const colors = getNPSColor(sentiment)
    colorClass = colors.badge
    if (!label) {
      derivedLabel = sentiment.charAt(0).toUpperCase() + sentiment.slice(1)
    }
  } else if (status) {
    const colors = getActionStatusColor(status)
    colorClass = colors.badge
    if (!label) {
      derivedLabel = status.replace(/[-_]/g, ' ').replace(/\b\w/g, c => c.toUpperCase())
    }
  }

  return (
    <span className={cn(shapeClass, colorClass, className)}>
      {derivedLabel}
    </span>
  )
}
```

**Step 2: Verify it compiles**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -20`
Expected: No errors related to StatusBadge

**Step 3: Commit**

```bash
git add src/components/ui/StatusBadge.tsx
git commit -m "feat(ui): add StatusBadge component wrapping design tokens"
```

---

### Task 2: Create EmptyState Component

**Files:**
- Create: `src/components/ui/EmptyState.tsx`

**Step 1: Create EmptyState component**

```tsx
import { type LucideIcon } from 'lucide-react'
import { cn } from '@/lib/utils'

interface EmptyStateAction {
  label: string
  onClick: () => void
}

interface EmptyStateProps {
  icon: LucideIcon
  title: string
  description?: string
  action?: EmptyStateAction
  /** Compact variant for sidebar panels and card bodies */
  compact?: boolean
  className?: string
}

export function EmptyState({
  icon: Icon,
  title,
  description,
  action,
  compact = false,
  className,
}: EmptyStateProps) {
  if (compact) {
    return (
      <div className={cn('text-center py-6', className)}>
        <Icon className="h-5 w-5 text-gray-400 mx-auto mb-2" />
        <p className="text-sm font-medium text-gray-500">{title}</p>
        {description && (
          <p className="text-xs text-gray-400 mt-1">{description}</p>
        )}
      </div>
    )
  }

  return (
    <div className={cn('text-center py-12', className)}>
      <div className="inline-flex items-center justify-center w-12 h-12 bg-purple-100 rounded-full mb-4">
        <Icon className="h-6 w-6 text-purple-600" />
      </div>
      <h3 className="text-sm font-semibold text-gray-900 mb-1">{title}</h3>
      {description && (
        <p className="text-sm text-gray-500 max-w-sm mx-auto">{description}</p>
      )}
      {action && (
        <button
          onClick={action.onClick}
          className="mt-4 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors text-sm font-medium"
        >
          {action.label}
        </button>
      )}
    </div>
  )
}
```

**Step 2: Verify it compiles**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -20`
Expected: No errors related to EmptyState

**Step 3: Commit**

```bash
git add src/components/ui/EmptyState.tsx
git commit -m "feat(ui): add shared EmptyState component"
```

---

### Task 3: Create CardContainer Component

**Files:**
- Create: `src/components/ui/CardContainer.tsx`

**Step 1: Create CardContainer component**

```tsx
import { cn } from '@/lib/utils'
import { LayoutTokens } from '@/lib/design-tokens'

interface CardContainerProps {
  children: React.ReactNode
  /** Padding preset */
  padding?: 'standard' | 'compact' | 'none'
  /** Elevated shadow for featured cards */
  elevated?: boolean
  /** Additional classes */
  className?: string
}

export function CardContainer({
  children,
  padding = 'standard',
  elevated = false,
  className,
}: CardContainerProps) {
  const paddingClass = {
    standard: LayoutTokens.cardPadding,
    compact: 'p-3',
    none: '',
  }[padding]

  return (
    <div
      className={cn(
        LayoutTokens.card,
        paddingClass,
        elevated && 'shadow-md',
        className
      )}
    >
      {children}
    </div>
  )
}
```

**Step 2: Verify it compiles**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -20`
Expected: No errors

**Step 3: Commit**

```bash
git add src/components/ui/CardContainer.tsx
git commit -m "feat(ui): add CardContainer component using LayoutTokens"
```

---

### Task 4: Sidebar Colour Token Migration

Replace hardcoded STATUS_COLORS / PRIORITY_COLORS maps in 3 sidebar components with design token imports. These maps duplicate the exact same colour logic already in design-tokens.ts.

**Files:**
- Modify: `src/components/sidebar/ActionSidebarContent.tsx:83-95`
- Modify: `src/components/sidebar/GoalSidebarContent.tsx:136-143`
- Modify: `src/components/sidebar/MeetingSidebarContent.tsx:92-107`

**Step 1: ActionSidebarContent — replace PRIORITY_COLORS and STATUS_COLORS**

Remove `PRIORITY_COLORS` (lines 83-88) and `STATUS_COLORS` (lines 90-95). Add import of `getPriorityColor` and `getActionStatusColor` from `@/lib/design-tokens`. At each usage site, replace `PRIORITY_COLORS[value] || 'bg-gray-100 text-gray-700'` with `getPriorityColor(value).badge` and `STATUS_COLORS[value] || 'bg-gray-100 text-gray-700'` with `getActionStatusColor(value).badge`.

**Step 2: GoalSidebarContent — replace STATUS_COLORS**

Remove `STATUS_COLORS` (lines 136-143). Import `getActionStatusColor` from `@/lib/design-tokens`. Replace each `STATUS_COLORS[status]` with `getActionStatusColor(status).badge`. Note: `not_started` maps to `notStarted`, `on_track` to `completed` (green), `at_risk` to `blocked` (amber), `behind` to `overdue` (red). If the existing status values don't map cleanly, use `StatusBadge` with a `status` prop instead.

**Step 3: MeetingSidebarContent — replace STATUS_COLORS and EVENT_TYPE_COLORS**

Remove `STATUS_COLORS` (lines 92-97) and `EVENT_TYPE_COLORS` (lines 99-107). Import `getActionStatusColor` from `@/lib/design-tokens`. For meeting status colours, use `getActionStatusColor(status).badge`. For event type colours, these are domain-specific (not status-based) — keep as a local map but import the values from the design system or use `StatusBadge` with `label` + `className`.

**Step 4: Verify and commit**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -20`
Expected: No errors

```bash
git add src/components/sidebar/ActionSidebarContent.tsx src/components/sidebar/GoalSidebarContent.tsx src/components/sidebar/MeetingSidebarContent.tsx
git commit -m "refactor(sidebar): replace hardcoded colour maps with design token imports"
```

---

### Task 5: Duplicate Colour Function Removal

Delete local `getStatusColor()` / `getPriorityColor()` functions in 12 files. Replace with imports from `@/lib/design-tokens`.

**Files to modify (in order):**
1. `src/app/(dashboard)/clients/[clientId]/components/ClientHeader.tsx:22` — local `getStatusColor()`
2. `src/app/(dashboard)/clients/[clientId]/components/OpenActionsSection.tsx:26,39` — local `getPriorityColor()` + `getStatusColor()`
3. `src/app/(dashboard)/clients/[clientId]/components/ComplianceSection.tsx:56` — local `getStatusColor()`
4. `src/app/(dashboard)/clients/[clientId]/components/v2/CenterColumn.tsx:420,435` — local `getStatusColor()` + `getPriorityColor()`
5. `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx:2059` — local `getStatusColor()`
6. `src/app/(dashboard)/aging-accounts/compliance/components/PolicyComplianceIndicators.tsx:221` — local `getStatusColor()`
7. `src/components/InsightsSidebar.tsx:127` — local `getPriorityColor()`
8. `src/components/EventTypeBreakdown.tsx:44` — local `getStatusColor()`
9. `src/components/benchmarking/RegionalRankingCards.tsx:34` — local `getStatusColor()`
10. `src/components/EventTypeVisualization.tsx:149` — local `getStatusColor()`
11. `src/components/autopilot/TouchpointSuggestionCard.tsx:92` — local `getPriorityColor()`
12. `src/components/priority-matrix/detail/DetailOverview.tsx:221` — local `getPriorityColor()`

**For each file:**
1. Delete the local function definition
2. Add import: `import { getActionStatusColor, getPriorityColor } from '@/lib/design-tokens'`
3. At each call site, check if the return type is compatible:
   - Local functions typically return a string like `'bg-red-100 text-red-700'`
   - Design token functions return an object with `.badge`, `.bg`, `.text`, `.border` etc.
   - Replace `getStatusColor(val)` with `getActionStatusColor(val).badge` (or `.bg` / `.text` depending on usage)
   - Replace `getPriorityColor(val)` with `getPriorityColor(val).badge`

**Step: Verify and commit**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -20`
Expected: No errors

```bash
git add -A
git commit -m "refactor: replace 12 local colour functions with design token imports"
```

---

### Task 6: Badge Migration Sweep

Replace 15+ inline badge/pill patterns with `StatusBadge` component where the badge represents a status, priority, or sentiment. Skip non-status decorative badges (e.g. file type indicators).

**Files to migrate (representative set — search for remaining):**
1. `src/components/AlertCenter.tsx:516-525` — 3 severity badges
2. `src/components/CreateActionModal.tsx:555` — status badge
3. `src/components/EventDetailModal.tsx:485,492` — type badges
4. `src/components/DocumentUpload.tsx:307,314` — status badges
5. `src/components/RecurringMeetingPatterns.tsx:108` — count badge
6. `src/components/csi/ScenarioPlanning.tsx:251` — status badge
7. `src/components/priority-matrix/detail/DetailHeader.tsx:108` — type badge

**Pattern to replace:**
```tsx
// Before:
<span className="px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-700">
  Critical
</span>

// After:
<StatusBadge priority="critical" />
```

**For badges that don't map to status/priority/sentiment** (like event types or file types), use `StatusBadge` with explicit `label` + `className`:
```tsx
<StatusBadge label="Executive Briefing" className="bg-purple-100 text-purple-700" />
```

**Step: Verify and commit**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -20`

```bash
git add -A
git commit -m "refactor: migrate inline badge patterns to StatusBadge component"
```

---

### Task 7: Empty State Migration

Replace 10+ ad-hoc empty states with the shared `EmptyState` component.

**Files to migrate:**
1. `src/components/pipeline/PipelineSection.tsx:205` — "No deals in this section"
2. `src/components/pipeline/AssignOwnerModal.tsx:206` — empty search results
3. `src/components/csi/GoalProgressTracker.tsx:222` — "No goals to track"
4. `src/components/forms/FormBuilder.tsx:613` — "No fields to preview"
5. `src/components/planning/DraggableList.tsx:86` — empty list
6. `src/components/charts/DataPointAnnotations.tsx:514` — no annotations
7. `src/components/ClientNPSTrendsModal.tsx:947` — "No comment themes"
8. `src/components/support/KnownProblemsPanel.tsx:164` — no known problems

**Pattern to replace:**
```tsx
// Before:
<div className="text-center py-8 text-gray-500">
  No goals to track
</div>

// After:
import { EmptyState } from '@/components/ui/EmptyState'
import { Target } from 'lucide-react'

<EmptyState
  icon={Target}
  title="No goals to track"
  compact
/>
```

Use `compact` for inline/sidebar contexts. Use standard for full-page contexts.

Choose appropriate Lucide icons:
- Pipeline: `BarChart3`
- Goals: `Target`
- Forms: `FileText`
- Lists: `List`
- Charts: `LineChart`
- Support: `LifeBuoy`
- Search: `Search`

**Step: Verify and commit**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -20`

```bash
git add -A
git commit -m "refactor: migrate ad-hoc empty states to shared EmptyState component"
```

---

### Task 8: Typography Token Sweep

Replace hardcoded heading/body text classes with `TypographyClasses` imports in 10+ files.

**Mapping:**
- `text-2xl font-bold text-gray-900` → `TypographyClasses.pageTitle`
- `text-lg font-semibold text-gray-900` → `TypographyClasses.sectionTitle`
- `text-base font-semibold text-gray-900` → `TypographyClasses.cardTitle`
- `text-sm text-gray-600` → `TypographyClasses.body`
- `text-xs text-gray-500` → `TypographyClasses.caption`
- `text-sm font-medium text-gray-700` → `TypographyClasses.label`

**Files to sweep:**
1. `src/components/AgingAccountsCard.tsx:85,106,128,149` — metric headings (SKIP — these are coloured metrics, not standard headings)
2. `src/components/AgedReceivablesCard.tsx:145,154,165,174,245` — metric headings + section title
3. `src/components/analytics/CompetitorInsights.tsx:254` — heading

**Important:** Only replace headings/body text that match the token purpose exactly. Do NOT replace metric displays (coloured numbers like `text-2xl font-bold text-green-600`) — these are intentionally colour-coded. Only replace neutral gray headings and body text.

**Pattern:**
```tsx
// Before:
<h2 className="text-lg font-semibold text-gray-900">Section Title</h2>

// After:
import { TypographyClasses } from '@/lib/design-tokens'
<h2 className={TypographyClasses.sectionTitle}>Section Title</h2>
```

**Step: Verify and commit**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -20`

```bash
git add -A
git commit -m "refactor: replace hardcoded typography with TypographyClasses tokens"
```

---

### Task 9: Form Input Standardisation

Unify input element styling: `rounded-lg` border radius, `InteractiveTokens.focusRingVisible` focus state.

**Files to modify:**
1. `src/components/ui/enhanced/FilterPopover.tsx:159,183` — search inputs
2. `src/components/comments/EditorToolbar.tsx:171` — link input
3. `src/components/ui/Select.tsx:21,75` — select element

**Pattern:**
```tsx
// Before:
<input className="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:ring-2 focus:ring-purple-500 focus:border-purple-500" />

// After:
import { InteractiveTokens } from '@/lib/design-tokens'
<input className={cn('rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm', InteractiveTokens.focusRingVisible)} />
```

For `EditorToolbar.tsx` which uses `focus:border-blue-500` — change to purple for brand consistency:
```tsx
// Before:
focus:outline-none focus:border-blue-500
// After:
InteractiveTokens.focusRingVisible
```

**Step: Verify and commit**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -20`

```bash
git add -A
git commit -m "refactor: standardise form input focus rings with InteractiveTokens"
```

---

### Task 10: Final Verification

**Step 1: TypeScript check**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty`
Expected: Zero errors

**Step 2: Lint check**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx next lint`
Expected: Zero errors

**Step 3: Build check**

Run: `cd ~/GitHub/apac-intelligence-v2 && npm run build`
Expected: Successful build

**Step 4: Run existing tests**

Run: `cd ~/GitHub/apac-intelligence-v2 && npm test -- --passWithNoTests`
Expected: All 471 tests pass (no behavioural changes made)

**Step 5: Visual spot-check top 5 pages**

Open in browser: `/`, `/clients`, `/actions`, `/goals-initiatives`, `/digest`
Verify: Cards render correctly, badges show proper colours, empty states display properly

---

### Task 11: Update Knowledge Base

**Files:**
- Modify: `docs/knowledge-base/04-user-experience/design-system.md`
- Modify: `docs/knowledge-base/08-roadmap/priorities.md`

**Step 1: Add component documentation to design-system.md**

Add a section documenting StatusBadge, EmptyState, and CardContainer usage patterns.

**Step 2: Add P13 entry to priorities.md**

```markdown
## Priority 13: UX Coherence 10/10 — COMPLETE

Built 3 shared components (StatusBadge, EmptyState, CardContainer) and swept ~130 file locations to eliminate hardcoded styling patterns. Replaced 12 duplicate colour functions, migrated 15+ inline badges, unified 10+ empty states, and standardised form inputs.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| StatusBadge component (wraps BadgeStyles + colour tokens) | High | Low | Done |
| EmptyState component (standard + compact variants) | Medium | Low | Done |
| CardContainer component (wraps LayoutTokens.card) | Medium | Low | Done |
| Sidebar colour token migration (3 files) | Low | Low | Done |
| Duplicate colour function removal (12 files) | Medium | Low | Done |
| Badge migration sweep (15+ files) | Medium | Medium | Done |
| Empty state migration (10+ files) | Medium | Low | Done |
| Typography token sweep | Low | Low | Done |
| Form input standardisation | Low | Low | Done |
```

**Step 3: Commit docs**

```bash
cd docs && git add -A && git commit -m "docs: P13 UX coherence 10/10 complete"
cd .. && git add docs && git commit -m "chore: update docs submodule ref"
```
