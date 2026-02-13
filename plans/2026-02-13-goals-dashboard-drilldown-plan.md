# Goals Dashboard Drill-Down Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add slide-out drawer drill-downs to the Goals Dashboard so clicking any metric, chart segment, or list row opens a contextual detail panel with quick actions.

**Architecture:** A single `GoalDrillDownDrawer` component renders three modes (goal list, single goal, actions list) based on a `DrillContext` discriminated union. The drawer is portaled to `document.body` using framer-motion for animation, matching the existing `ActionSlideOutEdit` pattern. All data comes from existing API endpoints — no new routes needed.

**Tech Stack:** React, framer-motion, react-hotkeys-hook, recharts (click handlers on existing charts), Tailwind CSS, existing `/api/goals` and `/api/goals/[id]` endpoints.

**Design doc:** `docs/plans/2026-02-13-goals-dashboard-drilldown-design.md`

---

### Task 1: Create GoalDrillDownRow component

The compact goal card rendered inside the drawer's list mode.

**Files:**
- Create: `src/components/goals/GoalDrillDownRow.tsx`

**Step 1: Create the component file**

```tsx
'use client'

import React from 'react'
import { cn } from '@/lib/utils'
import { GOAL_TYPE_LABELS } from '@/lib/goals/labels'
import { ExternalLink } from 'lucide-react'
import type { GoalType, GoalStatus } from '@/types/goals'

const STATUS_COLOURS: Record<string, { dot: string; bar: string }> = {
  on_track: { dot: 'bg-green-500', bar: 'bg-green-500' },
  at_risk: { dot: 'bg-amber-500', bar: 'bg-amber-500' },
  off_track: { dot: 'bg-red-500', bar: 'bg-red-500' },
  completed: { dot: 'bg-blue-500', bar: 'bg-blue-500' },
  not_started: { dot: 'bg-gray-400', bar: 'bg-gray-400' },
}

const STATUS_OPTIONS: { value: GoalStatus; label: string }[] = [
  { value: 'not_started', label: 'Not Started' },
  { value: 'on_track', label: 'On Track' },
  { value: 'at_risk', label: 'At Risk' },
  { value: 'off_track', label: 'Off Track' },
  { value: 'completed', label: 'Completed' },
]

interface GoalDrillDownRowProps {
  id: string
  type: GoalType
  title: string
  status: GoalStatus | null
  owner: string | null
  targetDate: string | null
  progress: number
  daysOverdue?: number
  onStatusChange?: (goalId: string, goalType: GoalType, newStatus: GoalStatus) => void
  onNavigate: (goalType: GoalType, goalId: string) => void
}

export function GoalDrillDownRow({
  id,
  type,
  title,
  status,
  owner,
  targetDate,
  progress,
  daysOverdue,
  onStatusChange,
  onNavigate,
}: GoalDrillDownRowProps) {
  const colours = STATUS_COLOURS[status || 'not_started']
  const formattedDate = targetDate
    ? new Intl.DateTimeFormat('en-AU', { day: 'numeric', month: 'short', year: 'numeric' }).format(new Date(targetDate))
    : null

  return (
    <div className="group rounded-lg border border-gray-200 p-3 hover:border-purple-200 hover:shadow-sm transition-all">
      {/* Title row */}
      <div className="flex items-start gap-2">
        <div className={cn('w-2.5 h-2.5 rounded-full mt-1.5 shrink-0', colours.dot)} />
        <div className="flex-1 min-w-0">
          <p className="text-sm font-medium text-gray-900 line-clamp-2">{title}</p>
          <p className="text-xs text-gray-500 mt-0.5">
            {GOAL_TYPE_LABELS[type]}
            {owner ? ` · ${owner}` : ' · Unassigned'}
            {formattedDate && (
              <>
                {' · '}
                <span className={daysOverdue && daysOverdue > 0 ? 'text-red-600 font-medium' : ''}>
                  {daysOverdue && daysOverdue > 0 ? `${daysOverdue}d overdue` : formattedDate}
                </span>
              </>
            )}
          </p>
        </div>
      </div>

      {/* Progress bar */}
      <div className="flex items-center gap-2 mt-2">
        <div className="flex-1 h-1.5 bg-gray-100 rounded-full overflow-hidden">
          <div
            className={cn('h-full rounded-full transition-all', colours.bar)}
            style={{ width: `${Math.min(Math.max(progress, 0), 100)}%` }}
          />
        </div>
        <span className="text-[10px] text-gray-500 tabular-nums w-7 text-right">{progress}%</span>
      </div>

      {/* Actions row */}
      <div className="flex items-center justify-between mt-2">
        {onStatusChange ? (
          <select
            value={status || 'not_started'}
            onChange={e => {
              e.stopPropagation()
              onStatusChange(id, type, e.target.value as GoalStatus)
            }}
            onClick={e => e.stopPropagation()}
            className="text-xs border border-gray-200 rounded-md px-1.5 py-0.5 text-gray-600 bg-white hover:border-purple-300 focus:ring-1 focus:ring-purple-300 focus:border-purple-300 outline-none cursor-pointer"
          >
            {STATUS_OPTIONS.map(opt => (
              <option key={opt.value} value={opt.value}>{opt.label}</option>
            ))}
          </select>
        ) : (
          <div />
        )}
        <button
          onClick={() => onNavigate(type, id)}
          className="flex items-center gap-1 text-xs text-purple-600 hover:text-purple-800 font-medium transition-colors"
        >
          Open <ExternalLink className="h-3 w-3" />
        </button>
      </div>
    </div>
  )
}
```

**Step 2: Commit**

```bash
git add src/components/goals/GoalDrillDownRow.tsx
git commit -m "feat(goals): add GoalDrillDownRow component for dashboard drill-down"
```

---

### Task 2: Create GoalDrillDownDrawer component

The drawer shell with list, single, and actions modes.

**Files:**
- Create: `src/components/goals/GoalDrillDownDrawer.tsx`

**Step 1: Create the drawer component**

```tsx
'use client'

import React, { useEffect, useState, useCallback, useRef } from 'react'
import { createPortal } from 'react-dom'
import { motion, AnimatePresence, useReducedMotion } from 'framer-motion'
import { useHotkeys } from 'react-hotkeys-hook'
import {
  X,
  CheckCircle2,
  ExternalLink,
  AlertTriangle,
  Clock,
  Loader2,
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { GOAL_TYPE_LABELS } from '@/lib/goals/labels'
import { GoalDrillDownRow } from './GoalDrillDownRow'
import type { GoalType, GoalStatus } from '@/types/goals'

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type DrillContext =
  | {
      mode: 'list'
      title: string
      filter: { status?: GoalStatus; type?: GoalType; owner?: string; overdue?: boolean }
    }
  | { mode: 'single'; goalId: string; goalType: GoalType; title?: string }
  | { mode: 'actions'; title: string; filter: { actionStatus: string } }

interface GoalListItem {
  id: string
  type: GoalType
  title: string
  status: GoalStatus | null
  owner: string | null
  targetDate: string | null
  progress: number
  daysOverdue?: number
}

interface SingleGoalDetail {
  id: string
  type: GoalType
  title: string
  description: string | null
  status: GoalStatus | null
  owner: string | null
  progress: number
  targetDate: string | null
  startDate: string | null
  lastCheckIn: string | null
  childCount: number
}

interface ActionItem {
  id: string
  title: string
  status: string
  owner: string | null
  dueDate: string | null
  goalName: string | null
}

interface GoalDrillDownDrawerProps {
  context: DrillContext | null
  onClose: () => void
  onStatusChange: (goalId: string, goalType: GoalType, newStatus: GoalStatus) => void
  onNavigate: (goalType: GoalType, goalId: string) => void
  /** Pre-loaded actions from useActions() — avoids refetch */
  actions?: Array<{
    id: number
    Action_Title: string
    Status: string
    Owner: string | null
    Due_Date: string | null
    linked_initiative_id: string | null
    initiative_name?: string | null
  }>
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const GOAL_TYPES: GoalType[] = ['pillar', 'company', 'team', 'initiative']

function getGoalTitle(goal: Record<string, unknown>, goalType: GoalType): string {
  return (goalType === 'initiative' ? goal.name : goal.title) as string || 'Untitled'
}

function getGoalStatus(goal: Record<string, unknown>, goalType: GoalType): GoalStatus | null {
  return (goalType === 'initiative' ? goal.goal_status : goal.status) as GoalStatus | null
}

function getGoalOwner(goal: Record<string, unknown>, goalType: GoalType): string | null {
  return (goalType === 'initiative' ? goal.owner_department : goal.owner_id) as string | null
}

function getGoalDate(goal: Record<string, unknown>, goalType: GoalType): string | null {
  return (goalType === 'initiative' ? goal.completion_date : goal.target_date) as string | null
}

function daysOverdue(targetDate: string | null): number {
  if (!targetDate) return 0
  const diff = Math.floor((Date.now() - new Date(targetDate).getTime()) / 86400000)
  return Math.max(diff, 0)
}

const formatDate = (d: string | null) =>
  d ? new Intl.DateTimeFormat('en-AU', { day: 'numeric', month: 'short', year: 'numeric' }).format(new Date(d)) : null

// ---------------------------------------------------------------------------
// Component
// ---------------------------------------------------------------------------

export function GoalDrillDownDrawer({
  context,
  onClose,
  onStatusChange,
  onNavigate,
  actions,
}: GoalDrillDownDrawerProps) {
  const prefersReducedMotion = useReducedMotion()
  const triggerRef = useRef<Element | null>(null)
  const [goals, setGoals] = useState<GoalListItem[]>([])
  const [singleGoal, setSingleGoal] = useState<SingleGoalDetail | null>(null)
  const [loading, setLoading] = useState(false)

  // Capture the active element as trigger for focus return
  useEffect(() => {
    if (context) {
      triggerRef.current = document.activeElement
    }
  }, [context])

  // Focus return on close
  const handleClose = useCallback(() => {
    onClose()
    requestAnimationFrame(() => {
      if (triggerRef.current instanceof HTMLElement) {
        triggerRef.current.focus()
      }
    })
  }, [onClose])

  // Escape to close
  useHotkeys('escape', handleClose, { enabled: !!context, enableOnFormTags: true })

  // Fetch data when context changes
  useEffect(() => {
    if (!context) {
      setGoals([])
      setSingleGoal(null)
      return
    }

    if (context.mode === 'actions') return // uses pre-loaded data

    const controller = new AbortController()

    if (context.mode === 'list') {
      setLoading(true)
      const { filter } = context
      const typesToFetch = filter.type ? [filter.type] : GOAL_TYPES

      Promise.all(
        typesToFetch.map(async gt => {
          const params = new URLSearchParams({ goal_type: gt, limit: '50' })
          if (filter.status) params.set('status', filter.status)
          if (filter.owner) params.set('owner_id', filter.owner)
          const res = await fetch(`/api/goals?${params}`, { signal: controller.signal })
          const json = await res.json()
          if (!json.success) return []
          const items = json.data?.data || json.data || []
          return items.map((g: Record<string, unknown>) => ({
            id: g.id as string,
            type: gt,
            title: getGoalTitle(g, gt),
            status: getGoalStatus(g, gt),
            owner: getGoalOwner(g, gt),
            targetDate: getGoalDate(g, gt),
            progress: (g.progress_percentage as number) ?? 0,
            daysOverdue: daysOverdue(getGoalDate(g, gt)),
          }))
        })
      )
        .then(results => {
          let merged = results.flat()
          // Filter overdue client-side if needed
          if (filter.overdue) {
            const now = Date.now()
            merged = merged.filter(
              g => g.targetDate && new Date(g.targetDate).getTime() < now && g.status !== 'completed'
            )
          }
          // Sort: overdue → days desc, status → progress asc, default → alpha
          if (filter.overdue) {
            merged.sort((a, b) => (b.daysOverdue ?? 0) - (a.daysOverdue ?? 0))
          } else if (filter.status) {
            merged.sort((a, b) => a.progress - b.progress)
          } else if (filter.owner) {
            merged.sort((a, b) => a.title.localeCompare(b.title))
          }
          setGoals(merged)
        })
        .catch(err => {
          if (err.name !== 'AbortError') console.error('[DrillDownDrawer] fetch failed:', err)
        })
        .finally(() => setLoading(false))
    }

    if (context.mode === 'single') {
      setLoading(true)
      fetch(`/api/goals/${context.goalId}?goal_type=${context.goalType}`, {
        signal: controller.signal,
      })
        .then(res => res.json())
        .then(json => {
          if (!json.success) return
          const g = json.data?.data || json.data
          if (!g) return
          const gt = context.goalType
          setSingleGoal({
            id: g.id,
            type: gt,
            title: getGoalTitle(g, gt),
            description: (g.description as string) || null,
            status: getGoalStatus(g, gt),
            owner: getGoalOwner(g, gt),
            progress: (g.progress_percentage as number) ?? 0,
            targetDate: getGoalDate(g, gt),
            startDate: (g.start_date as string) || null,
            lastCheckIn: (g.last_check_in_date as string) || null,
            childCount: 0,
          })
        })
        .catch(err => {
          if (err.name !== 'AbortError') console.error('[DrillDownDrawer] fetch failed:', err)
        })
        .finally(() => setLoading(false))
    }

    return () => controller.abort()
  }, [context])

  // Actions mode — filter pre-loaded data
  const filteredActions: ActionItem[] =
    context?.mode === 'actions' && actions
      ? actions
          .filter(a => {
            const status = context.filter.actionStatus
            if (status === 'overdue') {
              return a.Due_Date && new Date(a.Due_Date) < new Date() && a.Status !== 'Completed'
            }
            return a.Status?.toLowerCase().replace(/\s+/g, '_') === status
          })
          .map(a => ({
            id: a.id,
            title: a.Action_Title || 'Untitled',
            status: a.Status || 'Not Started',
            owner: a.Owner,
            dueDate: a.Due_Date,
            goalName: a.initiative_name || null,
          }))
      : []

  // Quick stats for list mode
  const overdueCount = goals.filter(g => (g.daysOverdue ?? 0) > 0).length
  const unassignedCount = goals.filter(g => !g.owner).length

  if (!context) return null

  return createPortal(
    <AnimatePresence>
      {context && (
        <>
          {/* Scrim */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: prefersReducedMotion ? 0 : 0.2 }}
            onClick={handleClose}
            className="fixed inset-0 bg-black/20 z-[90]"
            aria-hidden="true"
          />

          {/* Drawer panel */}
          <motion.div
            role="dialog"
            aria-label={context.mode === 'single' ? (singleGoal?.title || 'Goal Detail') : (context as { title?: string }).title || 'Goals'}
            aria-modal="true"
            initial={{ x: '100%' }}
            animate={{ x: 0 }}
            exit={{ x: '100%' }}
            transition={{
              type: 'spring',
              damping: 30,
              stiffness: 300,
              duration: prefersReducedMotion ? 0 : undefined,
            }}
            className="fixed right-0 top-0 bottom-0 w-full max-w-[480px] bg-white shadow-2xl z-[100] flex flex-col"
          >
            {/* Header */}
            <div className="flex items-center justify-between px-5 py-4 border-b border-gray-200">
              <div className="min-w-0">
                <h2 className="text-base font-semibold text-gray-900 truncate">
                  {context.mode === 'single'
                    ? (singleGoal?.title || context.title || 'Loading...')
                    : context.title}
                </h2>
                {context.mode === 'list' && !loading && (
                  <p className="text-xs text-gray-500 mt-0.5">
                    {goals.length} {goals.length === 1 ? 'goal' : 'goals'}
                  </p>
                )}
                {context.mode === 'actions' && (
                  <p className="text-xs text-gray-500 mt-0.5">
                    {filteredActions.length} {filteredActions.length === 1 ? 'action' : 'actions'}
                  </p>
                )}
              </div>
              <button
                onClick={handleClose}
                className="p-1.5 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-colors"
                aria-label="Close drawer"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            {/* Quick stats bar (list mode only) */}
            {context.mode === 'list' && !loading && goals.length > 0 && (overdueCount > 0 || unassignedCount > 0) && (
              <div className="flex items-center gap-3 px-5 py-2 bg-gray-50 border-b border-gray-100 text-xs text-gray-600">
                {overdueCount > 0 && (
                  <span className="flex items-center gap-1">
                    <Clock className="h-3 w-3 text-red-500" />
                    {overdueCount} overdue
                  </span>
                )}
                {unassignedCount > 0 && (
                  <span className="flex items-center gap-1">
                    <AlertTriangle className="h-3 w-3 text-amber-500" />
                    {unassignedCount} unassigned
                  </span>
                )}
              </div>
            )}

            {/* Body — scrollable */}
            <div className="flex-1 overflow-y-auto px-5 py-4">
              {loading ? (
                <div className="flex items-center justify-center py-12">
                  <Loader2 className="h-6 w-6 text-purple-500 animate-spin" />
                </div>
              ) : context.mode === 'list' ? (
                goals.length === 0 ? (
                  <div className="flex flex-col items-center justify-center py-12 text-gray-400">
                    <CheckCircle2 className="h-10 w-10 mb-2" />
                    <p className="text-sm">No goals match this filter</p>
                  </div>
                ) : (
                  <div className="space-y-2">
                    {goals.map(g => (
                      <GoalDrillDownRow
                        key={`${g.type}-${g.id}`}
                        id={g.id}
                        type={g.type}
                        title={g.title}
                        status={g.status}
                        owner={g.owner}
                        targetDate={g.targetDate}
                        progress={g.progress}
                        daysOverdue={g.daysOverdue}
                        onStatusChange={onStatusChange}
                        onNavigate={(gt, gid) => {
                          handleClose()
                          onNavigate(gt, gid)
                        }}
                      />
                    ))}
                  </div>
                )
              ) : context.mode === 'single' && singleGoal ? (
                <div className="space-y-4">
                  {/* Status & type */}
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-purple-100 text-purple-700">
                      {GOAL_TYPE_LABELS[singleGoal.type]}
                    </span>
                    <span className={cn(
                      'inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium',
                      singleGoal.status === 'on_track' && 'bg-green-100 text-green-700',
                      singleGoal.status === 'at_risk' && 'bg-amber-100 text-amber-700',
                      singleGoal.status === 'off_track' && 'bg-red-100 text-red-700',
                      singleGoal.status === 'completed' && 'bg-blue-100 text-blue-700',
                      (!singleGoal.status || singleGoal.status === 'not_started') && 'bg-gray-100 text-gray-700',
                    )}>
                      {singleGoal.status?.replace(/_/g, ' ') || 'not started'}
                    </span>
                  </div>

                  {/* Description */}
                  {singleGoal.description && (
                    <p className="text-sm text-gray-600">{singleGoal.description}</p>
                  )}

                  {/* Metadata grid */}
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <p className="text-[10px] text-gray-500 uppercase tracking-wide">Owner</p>
                      <p className="text-sm text-gray-900 mt-0.5">{singleGoal.owner || 'Unassigned'}</p>
                    </div>
                    <div>
                      <p className="text-[10px] text-gray-500 uppercase tracking-wide">Progress</p>
                      <p className="text-sm text-gray-900 mt-0.5">{singleGoal.progress}%</p>
                    </div>
                    <div>
                      <p className="text-[10px] text-gray-500 uppercase tracking-wide">Target Date</p>
                      <p className="text-sm text-gray-900 mt-0.5">{formatDate(singleGoal.targetDate) || '--'}</p>
                    </div>
                    <div>
                      <p className="text-[10px] text-gray-500 uppercase tracking-wide">Last Check-In</p>
                      <p className="text-sm text-gray-900 mt-0.5">{formatDate(singleGoal.lastCheckIn) || 'Never'}</p>
                    </div>
                  </div>

                  {/* Progress bar */}
                  <div>
                    <div className="flex items-center justify-between text-xs text-gray-500 mb-1">
                      <span>Progress</span>
                      <span>{singleGoal.progress}%</span>
                    </div>
                    <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                      <div
                        className={cn(
                          'h-full rounded-full transition-all',
                          singleGoal.status === 'on_track' && 'bg-green-500',
                          singleGoal.status === 'at_risk' && 'bg-amber-500',
                          singleGoal.status === 'off_track' && 'bg-red-500',
                          singleGoal.status === 'completed' && 'bg-blue-500',
                          (!singleGoal.status || singleGoal.status === 'not_started') && 'bg-gray-400',
                        )}
                        style={{ width: `${singleGoal.progress}%` }}
                      />
                    </div>
                  </div>

                  {/* Open full detail */}
                  <button
                    onClick={() => {
                      handleClose()
                      onNavigate(singleGoal.type, singleGoal.id)
                    }}
                    className="w-full flex items-center justify-center gap-2 px-4 py-2.5 rounded-lg bg-purple-600 text-white text-sm font-medium hover:bg-purple-700 transition-colors"
                  >
                    Open Full Detail <ExternalLink className="h-4 w-4" />
                  </button>
                </div>
              ) : context.mode === 'actions' ? (
                filteredActions.length === 0 ? (
                  <div className="flex flex-col items-center justify-center py-12 text-gray-400">
                    <CheckCircle2 className="h-10 w-10 mb-2" />
                    <p className="text-sm">No actions match this filter</p>
                  </div>
                ) : (
                  <div className="space-y-2">
                    {filteredActions.map(a => (
                      <div
                        key={a.id}
                        className="rounded-lg border border-gray-200 p-3 hover:border-purple-200 hover:shadow-sm transition-all"
                      >
                        <p className="text-sm font-medium text-gray-900 line-clamp-2">{a.title}</p>
                        <p className="text-xs text-gray-500 mt-0.5">
                          {a.status}
                          {a.owner ? ` · ${a.owner}` : ''}
                          {a.dueDate ? ` · ${formatDate(a.dueDate)}` : ''}
                        </p>
                        {a.goalName && (
                          <p className="text-[10px] text-purple-600 mt-1">Linked: {a.goalName}</p>
                        )}
                      </div>
                    ))}
                  </div>
                )
              ) : null}
            </div>

            {/* Footer */}
            {context.mode === 'list' && goals.length > 0 && (
              <div className="px-5 py-3 border-t border-gray-200">
                <button
                  onClick={() => {
                    handleClose()
                    const filter = context.filter
                    const params = new URLSearchParams()
                    if (filter.status) params.set('status', filter.status)
                    window.location.href = `/goals-initiatives${params.toString() ? `?${params}` : ''}`
                  }}
                  className="w-full text-center text-sm text-purple-600 hover:text-purple-800 font-medium transition-colors"
                >
                  View all in Goals & Projects →
                </button>
              </div>
            )}
          </motion.div>
        </>
      )}
    </AnimatePresence>,
    document.body
  )
}
```

**Step 2: Commit**

```bash
git add src/components/goals/GoalDrillDownDrawer.tsx
git commit -m "feat(goals): add GoalDrillDownDrawer component with list/single/actions modes"
```

---

### Task 3: Wire drill-down triggers into GoalsDashboard

Add `drillContext` state, click handlers on all 6 interactive widgets, and render the drawer.

**Files:**
- Modify: `src/components/goals/GoalsDashboard.tsx`

**Step 1: Add imports at top of file (after existing imports)**

Add these imports after the existing import block (around line 36):

```tsx
import { useRouter } from 'next/navigation'
import { GoalDrillDownDrawer, type DrillContext } from './GoalDrillDownDrawer'
```

**Step 2: Add state and router inside the component**

Inside `GoalsDashboard` function, after the existing `useState` declarations (around line 910), add:

```tsx
const router = useRouter()
const [drillContext, setDrillContext] = useState<DrillContext | null>(null)
```

**Step 3: Add status change handler**

After the drill state, add a handler for inline status changes from the drawer:

```tsx
const handleDrillStatusChange = useCallback(
  async (goalId: string, goalType: GoalType, newStatus: GoalStatus) => {
    try {
      const statusCol = goalType === 'initiative' ? 'goal_status' : 'status'
      const res = await fetch(`/api/goals/${goalId}?goal_type=${goalType}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ [statusCol]: newStatus }),
      })
      const json = await res.json()
      if (json.success) {
        // Refresh dashboard data
        fetchData()
      }
    } catch (err) {
      console.error('[GoalsDashboard] status change failed:', err)
    }
  },
  []
)
```

Note: `fetchData` is the existing function that fetches dashboard data — find its name in the component (may be called via a `useEffect` with a dependency, or an explicit function). Reference it in the callback.

**Step 4: Make MetricCard clickable**

Update the `MetricCard` component to accept an `onClick` prop. Add to the interface:

```tsx
onClick?: () => void
```

Add to the component's outer `<div>`:

```tsx
onClick={onClick}
className={cn(
  'rounded-xl border border-gray-200 p-4',
  bgClass || 'bg-white',
  onClick && 'cursor-pointer hover:ring-2 hover:ring-purple-200 active:scale-[0.98] transition-all'
)}
```

**Step 5: Wire MetricCard onClick handlers**

Where the 4 MetricCards are rendered (around line 1094), add `onClick`:

```tsx
<MetricCard
  label="Total Goals"
  value={data.totals.total}
  icon={Target}
  sparkline={progressSparkline.length >= 3 ? progressSparkline : undefined}
  onClick={() => setDrillContext({ mode: 'list', title: `All Goals (${data.totals.total})`, filter: {} })}
/>
<MetricCard
  label="Completed"
  value={data.totals.completed}
  subtitle={`${completedPct}% of total`}
  icon={CheckCircle2}
  onClick={() => setDrillContext({ mode: 'list', title: `Completed Goals (${data.totals.completed})`, filter: { status: 'completed' } })}
/>
<MetricCard
  label="At Risk"
  value={data.totals.at_risk}
  icon={AlertTriangle}
  bgClass="bg-amber-50"
  textClass="text-amber-700"
  onClick={() => setDrillContext({ mode: 'list', title: `At Risk Goals (${data.totals.at_risk})`, filter: { status: 'at_risk' } })}
/>
<MetricCard
  label="Overdue"
  value={data.totals.overdue}
  icon={Clock}
  bgClass="bg-red-50"
  textClass="text-red-700"
  onClick={() => setDrillContext({ mode: 'list', title: `Overdue Goals (${data.totals.overdue})`, filter: { overdue: true } })}
/>
```

**Step 6: Wire Status Distribution pie click**

In `StatusDistributionWidget`, the pie chart `<Cell>` elements or legend buttons already have click handlers that set `statusFilter`. Add an additional handler that opens the drawer. Find where the pie `onClick` is defined and ADD (not replace) a drill context setter:

```tsx
// In the pie chart Cell onClick or legend button onClick:
onClick={() => {
  // Keep existing filter behaviour
  setStatusFilter(prev => (prev === status ? null : status))
  // Also open drill-down drawer
  const count = entry.count
  setDrillContext({
    mode: 'list',
    title: `${STATUS_LABELS[status]} Goals (${count})`,
    filter: { status: status as GoalStatus },
  })
}}
```

**Step 7: Wire Goals by Owner bar click**

In `GoalsByOwnerWidget`, add click handler to the `<Bar>` elements. Recharts `<Bar>` accepts an `onClick` prop:

```tsx
<Bar
  dataKey="on_track"
  fill="#22c55e"
  onClick={(barData: Record<string, unknown>) => {
    setDrillContext({
      mode: 'list',
      title: `Goals: ${barData.owner as string}`,
      filter: { owner: barData.owner as string },
    })
  }}
/>
```

Apply the same `onClick` to each `<Bar>` (on_track, at_risk, off_track, not_started, completed). All navigate with the same owner filter — the drawer will show all goals for that owner.

**Step 8: Wire Overdue Goals row click**

In `OverdueGoalsWidget`, each overdue goal row is currently a `<div>`. Add:

```tsx
onClick={() => setDrillContext({
  mode: 'single',
  goalId: goal.id,
  goalType: goal.type as GoalType,
  title: goal.title,
})}
className="... cursor-pointer hover:bg-gray-50"
```

**Step 9: Wire Check-In Freshness card click**

In `CheckInFreshnessWidget`, each card is a `<div>`. Add:

```tsx
onClick={() => setDrillContext({
  mode: 'single',
  goalId: item.id,
  goalType: item.type as GoalType,
  title: item.title,
})}
className="... cursor-pointer"
```

**Step 10: Wire Recent Activity entry click**

In `RecentActivityWidget`, each activity row is a `<div>`. Add:

```tsx
onClick={() => setDrillContext({
  mode: 'single',
  goalId: activity.goal_id,
  goalType: activity.goal_type as GoalType,
  title: activity.goal_title,
})}
className="... cursor-pointer hover:bg-gray-50"
```

**Step 11: Wire Linked Actions click**

In `LinkedActionsWidget`, each stat row (Open, In Progress, Completed, Overdue) is rendered. Add click handlers:

```tsx
onClick={() => setDrillContext({
  mode: 'actions',
  title: `${label} Actions (${count})`,
  filter: { actionStatus: statusKey },
})}
className="... cursor-pointer hover:bg-gray-50"
```

Where `statusKey` maps to: `'not_started'`, `'in_progress'`, `'completed'`, `'overdue'`.

**Step 12: Render the drawer**

At the end of the GoalsDashboard return (before the closing `</div>`), add:

```tsx
<GoalDrillDownDrawer
  context={drillContext}
  onClose={() => setDrillContext(null)}
  onStatusChange={handleDrillStatusChange}
  onNavigate={(type, id) => {
    setDrillContext(null)
    router.push(`/goals-initiatives/${type}/${id}`)
  }}
  actions={allActions}
/>
```

Where `allActions` is the actions data from `useActions()` — check the existing variable name used in the component.

**Step 13: Add GoalType import if not already present**

Ensure `GoalType` and `GoalStatus` are imported from `@/types/goals`.

**Step 14: Commit**

```bash
git add src/components/goals/GoalsDashboard.tsx
git commit -m "feat(goals): wire drill-down triggers across all dashboard widgets"
```

---

### Task 4: Test in browser

**Step 1: Navigate to Goals Dashboard tab**

Open `http://localhost:3001/goals-initiatives`, click the "Dashboard" tab.

**Step 2: Test KPI card drill-down**

Click the "At Risk" KPI card. Verify:
- Drawer slides in from the right
- Title shows "At Risk Goals (N)"
- Lists only at-risk goals
- Status dropdown works (change a status, verify it updates)
- "Open →" navigates to goal detail page
- Escape closes the drawer
- "View all in Goals & Projects →" navigates to filtered list

**Step 3: Test pie chart drill-down**

Click a wedge on the Status Distribution donut chart. Verify drawer opens with filtered goals.

**Step 4: Test overdue row drill-down**

Click an item in the Overdue Goals widget. Verify single goal mode shows description, metadata grid, and "Open Full Detail" button.

**Step 5: Test owner bar drill-down**

Click a bar in the Goals by Owner chart. Verify drawer shows all goals for that owner.

**Step 6: Test accessibility**

- Tab through the drawer to verify focus trap
- Press Escape to close
- Verify focus returns to the element you clicked

**Step 7: Commit final state**

```bash
git add -A
git commit -m "feat(goals): dashboard drill-down drawer - complete implementation"
```
