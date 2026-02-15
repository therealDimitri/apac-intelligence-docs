# Debt/Polish Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Complete 3 deferred P5 items — NPS DataTable migration, LayoutTokens.card adoption, component consolidation.

**Architecture:** Enhance the existing `DataTable` component with expandable row support, then rebuild the NPS client scores section as a DataTable. Sweep remaining ad-hoc card patterns to use `CardContainer`. Extract a shared `TrendBadge` and deduplicate local `StatusBadge` copies.

**Tech Stack:** React, TanStack Table, TanStack Virtual, Tailwind CSS, existing design tokens.

**Design doc:** `docs/plans/2026-02-15-debt-polish-design.md`

---

## Task 1: Extract TrendBadge as shared component

**Files:**
- Create: `src/components/ui/TrendBadge.tsx`
- Modify: `src/components/financial-analytics/LeadingIndicatorsPanel.tsx` (remove local TrendBadge, import shared)

**Step 1: Create TrendBadge component**

Create `src/components/ui/TrendBadge.tsx`:

```tsx
import { cn } from '@/lib/utils'
import { TrendingUp, TrendingDown, Minus } from 'lucide-react'

interface TrendBadgeProps {
  direction: 'up' | 'down' | 'flat'
  label?: string
  className?: string
}

export function TrendBadge({ direction, label, className }: TrendBadgeProps) {
  return (
    <div
      className={cn(
        'flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full',
        direction === 'up' && 'bg-green-100 text-green-700',
        direction === 'down' && 'bg-red-100 text-red-700',
        direction === 'flat' && 'bg-gray-100 text-gray-700',
        className
      )}
    >
      {direction === 'up' && <TrendingUp className="w-3 h-3" />}
      {direction === 'down' && <TrendingDown className="w-3 h-3" />}
      {direction === 'flat' && <Minus className="w-3 h-3" />}
      {label && <span>{label}</span>}
    </div>
  )
}
```

**Step 2: Replace local TrendBadge in LeadingIndicatorsPanel**

In `src/components/financial-analytics/LeadingIndicatorsPanel.tsx`:
- Delete the local `function TrendBadge(...)` definition (lines ~50-65)
- Add import: `import { TrendBadge } from '@/components/ui/TrendBadge'`
- All 3 existing `<TrendBadge ... />` usages (lines ~126, ~186, ~213) keep the same props — no changes needed

**Step 3: Verify build**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -30`
Expected: No errors related to TrendBadge

**Step 4: Commit**

```bash
git add src/components/ui/TrendBadge.tsx src/components/financial-analytics/LeadingIndicatorsPanel.tsx
git commit -m "refactor: extract TrendBadge as shared UI component"
```

---

## Task 2: Deduplicate local StatusBadge copies

**Files:**
- Modify: `src/components/goals/MeetingBriefPanel.tsx` (delete local StatusBadge at line 89, import shared)
- Modify: `src/components/team-performance/CSEPerformanceTable.tsx` (delete local StatusBadge at line 74, import shared)

**Step 1: Fix MeetingBriefPanel.tsx**

In `src/components/goals/MeetingBriefPanel.tsx`:
- Delete the local `function StatusBadge({ status }: { status: string | null })` (lines ~89-102) and its associated `STATUS_COLOURS` constant
- Add import: `import { StatusBadge } from '@/components/ui/StatusBadge'`
- Update call sites: the local version takes `{ status: string | null }` and renders the status label. The shared `StatusBadge` takes `{ status?: string; label?: string }`. Replace `<StatusBadge status={someStatus} />` — the shared version already handles status-to-label conversion and colour mapping. If `status` is null, wrap with a guard: `{status && <StatusBadge status={status} />}`

**Step 2: Fix CSEPerformanceTable.tsx**

In `src/components/team-performance/CSEPerformanceTable.tsx`:
- Delete the local `function StatusBadge({ status }: { status: PerformanceStatus })` (lines ~74-89) and its `getStatusColour`/`getStatusLabel` helpers
- The local version renders icons (CheckCircle2, AlertTriangle, AlertCircle) alongside text — the shared `StatusBadge` does NOT include icons. Two options:
  - **Option A (preferred):** Keep the shared `StatusBadge` for consistent look, accept no icon
  - **Option B:** Wrap shared `StatusBadge` with an icon inline at the call site
- Add import: `import { StatusBadge } from '@/components/ui/StatusBadge'`
- Map the performance status strings (`on-track`, `needs-attention`, `at-risk`) — the shared `StatusBadge` uses `getActionStatusColor()` which handles kebab-case statuses. Verify the colours match (green for on-track, yellow for needs-attention, red for at-risk). If not, use the `label` prop for display and `status` for colour.

**Step 3: Verify build**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -30`
Expected: No errors in modified files

**Step 4: Commit**

```bash
git add src/components/goals/MeetingBriefPanel.tsx src/components/team-performance/CSEPerformanceTable.tsx
git commit -m "refactor: deduplicate local StatusBadge copies, use shared component"
```

---

## Task 3: Add expandable row support to DataTable

**Files:**
- Modify: `src/components/ui/enhanced/DataTable.tsx`

This is the prerequisite for NPS migration. The DataTable needs a `renderExpandedRow` prop.

**Step 1: Add expandable row types and prop**

In `DataTable.tsx`, add to `DataTableProps<T>`:

```tsx
renderExpandedRow?: (row: T) => React.ReactNode
```

**Step 2: Add expanded state tracking**

Inside the `DataTable` function body, add state:

```tsx
const [expandedKeys, setExpandedKeys] = React.useState<Set<string | number>>(new Set())

const toggleExpanded = React.useCallback((key: string | number) => {
  setExpandedKeys(prev => {
    const next = new Set(prev)
    if (next.has(key)) {
      next.delete(key)
    } else {
      next.add(key)
    }
    return next
  })
}, [])
```

**Step 3: Modify virtualizer to account for expanded rows**

Replace the fixed `estimateSize` with a dynamic one that doubles height for expanded rows:

```tsx
const virtualizer = useVirtualizer({
  count: data.length,
  getScrollElement: () => parentRef.current,
  estimateSize: React.useCallback(
    (index: number) => {
      if (!renderExpandedRow) return rowHeight
      const key = getRowKey(data[index])
      return expandedKeys.has(key) ? rowHeight + 200 : rowHeight
    },
    [expandedKeys, data, getRowKey, renderExpandedRow, rowHeight]
  ),
  overscan: 10,
})
```

Note: The expanded detail height of 200 is an estimate. For variable-height content, we could measure after render, but 200px is a reasonable default for the NPS insights panel.

**Step 4: Modify row rendering to include expanded detail**

In the virtual rows `map`, after the row `<div>`, conditionally render the expanded detail:

```tsx
{virtualItems.map(virtualItem => {
  const row = data[virtualItem.index]
  const rowKey = getRowKey(row)
  const isExpanded = renderExpandedRow && expandedKeys.has(rowKey)
  // ... existing row div ...

  return (
    <div
      key={rowKey}
      className="absolute left-0 top-0 w-full"
      style={{ transform: `translateY(${virtualItem.start}px)` }}
    >
      {/* Row cells */}
      <div
        className={cn(
          'flex w-full items-center border-b border-gray-100',
          striped && virtualItem.index % 2 === 1 && 'bg-gray-50/50',
          hoverable && 'hover:bg-purple-50/50',
          (onRowClick || renderExpandedRow) && 'cursor-pointer',
          customClassName
        )}
        style={{ height: rowHeight }}
        onClick={() => {
          if (renderExpandedRow) {
            toggleExpanded(rowKey)
          }
          onRowClick?.(row)
        }}
      >
        {/* ... existing cell rendering ... */}
      </div>

      {/* Expanded detail */}
      {isExpanded && (
        <div className="border-b border-gray-200 bg-gray-50/30 px-6 py-4">
          {renderExpandedRow(row)}
        </div>
      )}
    </div>
  )
})}
```

**Step 5: Verify build**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -30`
Expected: No errors. Existing DataTable consumers unaffected (new prop is optional).

**Step 6: Commit**

```bash
git add src/components/ui/enhanced/DataTable.tsx
git commit -m "feat: add expandable row support to DataTable"
```

---

## Task 4: Build NPS DataTable column definitions

**Files:**
- Create: `src/components/nps/NPSClientDataTable.tsx`

This is a new component that wraps DataTable with NPS-specific column definitions, row actions, and expanded row rendering. Creating it as a separate component keeps the NPS page clean and makes it testable.

**Step 1: Create NPSClientDataTable component**

Create `src/components/nps/NPSClientDataTable.tsx`:

```tsx
'use client'

import { useMemo, useCallback } from 'react'
import { Eye, User, ClipboardList, Calendar, Download } from 'lucide-react'
import { DataTable, type DataTableColumn, type RowAction } from '@/components/ui/enhanced/DataTable'
import { TrendBadge } from '@/components/ui/TrendBadge'
import ClientLogoDisplay from '@/components/ClientLogoDisplay'
import SparklineChart from '@/components/SparklineChart'
import type { ClientNPSScore } from '@/hooks/useNPSData'
import type { TrendInsight } from '@/lib/chasen-nps-insights'

interface NPSClientDataTableProps {
  clients: ClientNPSScore[]
  clientInsights: Map<string, TrendInsight>
  getDisplayName: (name: string) => string
  isMyClient: (name: string) => boolean
  getClientSegment: (name: string) => string | null
  getSegmentColor: (segment: string) => string
  segmentConfig: Record<string, { icon: React.ComponentType<{ className?: string }> }>
  onViewFeedback: (clientName: string) => void
  onExportReport: () => void
  isLoading?: boolean
}

export function NPSClientDataTable({
  clients,
  clientInsights,
  getDisplayName,
  isMyClient,
  getClientSegment,
  getSegmentColor,
  segmentConfig,
  onViewFeedback,
  onExportReport,
  isLoading,
}: NPSClientDataTableProps) {
  const columns = useMemo<DataTableColumn<ClientNPSScore>[]>(
    () => [
      {
        key: 'name',
        header: 'Client',
        width: 200,
        flex: 1,
        minWidth: 180,
        cell: (row) => {
          const segment = getClientSegment(row.name)
          const SegmentIcon = segment ? segmentConfig[segment]?.icon : null
          return (
            <div className="flex items-center gap-2 min-w-0">
              <ClientLogoDisplay clientName={row.name} size="sm" />
              <div className="min-w-0 flex-1">
                <div className="flex items-center gap-1.5">
                  <span className="text-sm font-medium text-gray-900 truncate">
                    {getDisplayName(row.name)}
                  </span>
                  {isMyClient(row.name) && (
                    <span className="px-1.5 py-0.5 rounded-full text-[10px] font-semibold bg-indigo-100 text-indigo-700 border border-indigo-200 flex-shrink-0">
                      Mine
                    </span>
                  )}
                </div>
                {segment && SegmentIcon && (
                  <span className={`text-[10px] font-medium flex items-center gap-0.5 ${getSegmentColor(segment)}`}>
                    <SegmentIcon className="h-2.5 w-2.5" />
                    {segment}
                  </span>
                )}
              </div>
            </div>
          )
        },
      },
      {
        key: 'score',
        header: 'NPS',
        width: 100,
        sortable: true,
        align: 'center',
        cell: (row) => (
          <div className="flex items-center gap-1.5 justify-center">
            <span
              className={`text-base font-bold ${
                row.score >= 70
                  ? 'text-green-600'
                  : row.score >= 0
                    ? 'text-yellow-600'
                    : 'text-red-600'
              }`}
            >
              {row.score >= 0 ? '+' : ''}{row.score}
            </span>
            <TrendBadge direction={row.trend} className="px-1 py-0" />
          </div>
        ),
      },
      {
        key: 'trend',
        header: 'Trend',
        width: 140,
        cell: (row) =>
          row.trendData ? (
            <SparklineChart
              data={row.trendData}
              colour={
                row.score >= 70 ? '#10b981' : row.score >= 0 ? '#f59e0b' : '#ef4444'
              }
              height={32}
            />
          ) : (
            <span className="text-xs text-gray-400">No data</span>
          ),
      },
      {
        key: 'responses',
        header: 'Responses',
        width: 90,
        sortable: true,
        align: 'center',
        cell: (row) => (
          <span className="text-sm text-gray-600">{row.responses}</span>
        ),
      },
      {
        key: 'riskLevel',
        header: 'Risk',
        width: 110,
        sortable: true,
        align: 'center',
        cell: (row) => {
          const insight = clientInsights.get(row.name)
          if (!insight) return <span className="text-xs text-gray-400">-</span>
          const riskColors: Record<string, string> = {
            critical: 'bg-red-100 text-red-700',
            high: 'bg-purple-100 text-purple-700',
            medium: 'bg-yellow-100 text-yellow-700',
            low: 'bg-green-100 text-green-700',
          }
          return (
            <span className={`text-xs font-medium px-2 py-0.5 rounded-full ${riskColors[insight.riskLevel] || 'bg-gray-100 text-gray-600'}`}>
              {insight.riskLevel.charAt(0).toUpperCase() + insight.riskLevel.slice(1)}
            </span>
          )
        },
      },
    ],
    [clientInsights, getDisplayName, isMyClient, getClientSegment, getSegmentColor, segmentConfig]
  )

  const rowActions = useMemo<RowAction<ClientNPSScore>[]>(
    () => [
      {
        label: 'View NPS Feedback',
        icon: <Eye className="h-4 w-4" />,
        onClick: (row) => onViewFeedback(row.name),
      },
      {
        label: 'View Client Profile',
        icon: <User className="h-4 w-4" />,
        onClick: (row) => {
          window.location.href = `/client-profiles?search=${encodeURIComponent(row.name)}`
        },
      },
      {
        label: 'Create Action',
        icon: <ClipboardList className="h-4 w-4" />,
        onClick: (row) => {
          window.location.href = `/actions?client=${encodeURIComponent(row.name)}`
        },
      },
      {
        label: 'View Meetings',
        icon: <Calendar className="h-4 w-4" />,
        onClick: (row) => {
          window.location.href = `/meetings?client=${encodeURIComponent(row.name)}`
        },
      },
      {
        label: 'Export Report',
        icon: <Download className="h-4 w-4" />,
        onClick: () => onExportReport(),
      },
    ],
    [onViewFeedback, onExportReport]
  )

  const renderExpandedRow = useCallback(
    (row: ClientNPSScore) => {
      const insight = clientInsights.get(row.name)
      if (!insight) {
        return (
          <div className="text-xs text-gray-500 py-2">
            No AI insights available for {getDisplayName(row.name)}
          </div>
        )
      }

      return (
        <div className="max-w-2xl">
          <div className="flex items-center justify-between mb-2">
            <span
              className={`text-xs font-semibold px-2 py-0.5 rounded-full ${
                insight.riskLevel === 'critical'
                  ? 'bg-red-100 text-red-700'
                  : insight.riskLevel === 'high'
                    ? 'bg-purple-100 text-purple-700'
                    : insight.riskLevel === 'medium'
                      ? 'bg-yellow-100 text-yellow-700'
                      : 'bg-green-100 text-green-700'
              }`}
            >
              {insight.riskLevel.toUpperCase()} RISK
            </span>
            <span
              className={`text-xs px-2 py-0.5 rounded-full ${
                insight.confidence === 'high'
                  ? 'bg-green-100 text-green-700'
                  : insight.confidence === 'medium'
                    ? 'bg-amber-100 text-amber-700'
                    : 'bg-gray-100 text-gray-600'
              }`}
            >
              {insight.confidence} confidence
            </span>
          </div>
          <p className="text-xs text-gray-700 mb-2">{insight.summary}</p>
          {insight.keyFactors.length > 0 && (
            <div className="mb-2">
              <p className="text-sm font-bold text-gray-900 mb-1">Key Factors:</p>
              <ul className="text-xs text-gray-600 space-y-0.5">
                {insight.keyFactors.slice(0, 3).map((factor: string, idx: number) => (
                  <li key={idx} className="flex items-start">
                    <span className="text-gray-400 mr-1">&bull;</span>
                    <span>{factor}</span>
                  </li>
                ))}
              </ul>
            </div>
          )}
          <div className="pt-2">
            <p className="text-sm font-bold text-gray-900 mb-2">Recommended Actions:</p>
            <div className="flex flex-wrap gap-2">
              {insight.recommendation
                .split('\n')
                .filter((line: string) => line.trim())
                .map((action: string, idx: number) => (
                  <span
                    key={idx}
                    className="px-3 py-1.5 bg-purple-50 text-purple-700 border border-purple-200 rounded-full text-xs font-medium"
                  >
                    {action.trim()}
                  </span>
                ))}
            </div>
          </div>
        </div>
      )
    },
    [clientInsights, getDisplayName]
  )

  return (
    <DataTable
      data={clients}
      columns={columns}
      height={560}
      rowHeight={64}
      getRowKey={(row) => row.name}
      rowActions={rowActions}
      renderExpandedRow={renderExpandedRow}
      isLoading={isLoading}
      emptyMessage="No NPS data available"
      striped
      hoverable
    />
  )
}
```

**Step 2: Verify build**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -30`
Expected: No errors (depends on Task 3 being done first for `renderExpandedRow` prop)

**Step 3: Commit**

```bash
git add src/components/nps/NPSClientDataTable.tsx
git commit -m "feat: add NPSClientDataTable component with columns, actions, expandable rows"
```

---

## Task 5: Integrate NPSClientDataTable into NPS page

**Files:**
- Modify: `src/app/(dashboard)/nps/page.tsx`

This is the biggest change — replacing ~240 lines of card rendering + ~70 lines of context menu with the new DataTable component.

**Step 1: Add import**

Add to imports in `nps/page.tsx`:

```tsx
import { NPSClientDataTable } from '@/components/nps/NPSClientDataTable'
```

**Step 2: Extract getSegmentColor helper**

The NPS page has a `getSegmentColor` function. It stays in the page (used by segment filter buttons too). No change needed, just note it's already available.

**Step 3: Replace Client Scores card section**

Replace the entire "Client Scores with Sparklines" `<div>` block (lines ~1157-1398) with:

```tsx
<div className="bg-white rounded-lg shadow">
  <div className="px-6 py-4 border-b border-gray-200">
    <div className="flex items-start justify-between gap-4">
      <div className="flex-1 min-h-[52px]">
        <h2 className="text-xl font-bold text-gray-900">Client Scores & Trends</h2>
        <p className="text-sm text-gray-600 mt-1">AI-powered insights by ChaSen</p>
      </div>
      <div className="flex flex-col items-end gap-1 flex-shrink-0">
        <button
          onClick={() => generateInsights(true)}
          disabled={insightsLoading}
          className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-purple-700 bg-purple-50 border border-purple-200 rounded-lg hover:bg-purple-100 transition-colors disabled:opacity-50 disabled:cursor-not-allowed whitespace-nowrap"
          title="Regenerate AI insights with latest data"
        >
          <RefreshCw className={`h-4 w-4 ${insightsLoading ? 'animate-spin' : ''}`} />
          {insightsLoading ? 'Refreshing...' : 'Refresh Insights'}
        </button>
        {lastInsightsRefresh && (
          <p className="text-xs text-gray-400 flex items-center gap-1">
            <Clock className="h-3 w-3" />
            {lastInsightsRefresh.toLocaleDateString('en-AU', { day: 'numeric', month: 'short' })}{' '}
            {lastInsightsRefresh.toLocaleTimeString('en-AU', { hour: '2-digit', minute: '2-digit' })}
          </p>
        )}
      </div>
    </div>

    {/* Active Filter Banner (preserved) */}
    {(filterType || clientsParam) && (
      /* ... existing filter banner JSX unchanged ... */
    )}
  </div>

  <div className="p-4">
    <NPSClientDataTable
      clients={filteredClientScores}
      clientInsights={clientInsights}
      getDisplayName={getDisplayName}
      isMyClient={isMyClient}
      getClientSegment={getClientSegment}
      getSegmentColor={getSegmentColor}
      segmentConfig={SEGMENT_CONFIG}
      onViewFeedback={openFeedbackModal}
      onExportReport={handleExportReport}
      isLoading={insightsLoading}
    />
  </div>
</div>
```

**Step 4: Delete context menu**

Remove the entire context menu block (lines ~1476-1548):
- The `contextMenu` state declaration (`useState`)
- The `handleContextMenu` function
- The `closeContextMenu` function
- The `onContextMenu` handler (removed with the card layout)
- The context menu JSX at the bottom of the component
- The `useEffect` for click-outside closing of context menu

**Step 5: Clean up unused imports**

Remove imports no longer needed after the card→table migration:
- Remove `ClipboardList`, `User`, `Download` from lucide imports (moved to NPSClientDataTable)
- Keep `Eye` if still used by `openFeedbackModal` reference elsewhere — check first

**Step 6: Verify build**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -30`
Expected: No errors

**Step 7: Visual test**

Run: `cd ~/GitHub/apac-intelligence-v2 && npm run dev`
Open: `http://localhost:3001/nps`
Verify:
- DataTable renders with client rows
- Sparklines visible in Trend column
- Click row → AI insights expand below
- Row action menu → all 5 actions work
- Segment filter buttons still filter the table
- Search still works
- Summary cards at top unchanged
- Topics section unchanged

**Step 8: Commit**

```bash
git add src/app/(dashboard)/nps/page.tsx
git commit -m "feat: migrate NPS client scores from card layout to DataTable"
```

---

## Task 6: CardContainer adoption — Skeleton components

**Files:**
- Modify: `src/components/ui/skeletons/index.tsx`

**Step 1: Add import**

Add to imports:

```tsx
import { CardContainer } from '@/components/ui/CardContainer'
```

**Step 2: Replace ad-hoc card wrappers**

Find all instances of `<div className="bg-white rounded-lg border border-gray-200 p-4">` (and `p-3` variants) and replace with `<CardContainer padding="compact">` or `<CardContainer>` depending on padding.

The 8 instances from the grep (lines 39, 157, 172, 228, 319, 392, 421, 478):

- Line 39 (`p-4`): `<CardContainer>` (standard = p-5, close enough — or use `padding="compact"` for p-3)
- Line 157 (`p-3`): `<CardContainer padding="compact">`
- Line 172 (`p-4`): `<CardContainer>`
- Line 228 (no padding, has hover): `<CardContainer padding="none" className="hover:border-gray-300">`
- Line 319 (`p-4`): `<CardContainer>`
- Line 392 (`p-3`): `<CardContainer padding="compact">`
- Line 421 (overflow-hidden): `<CardContainer padding="none" className="overflow-hidden">`
- Line 478 (`p-4 flex items-center gap-3`): `<CardContainer className="flex items-center gap-3">`

Note: `CardContainer` includes `shadow-sm` via `LayoutTokens.card` while skeletons used plain `border` without shadow. This is acceptable — the skeleton matches the real component styling more closely.

**Step 3: Verify build**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -30`
Expected: No errors

**Step 4: Commit**

```bash
git add src/components/ui/skeletons/index.tsx
git commit -m "refactor: adopt CardContainer in skeleton components"
```

---

## Task 7: CardContainer adoption — NPS summary cards

**Files:**
- Modify: `src/app/(dashboard)/nps/page.tsx`

**Step 1: Add CardContainer import**

If not already imported, add:

```tsx
import { CardContainer } from '@/components/ui/CardContainer'
```

**Step 2: Replace NPS summary card wrappers**

Replace the 4 ad-hoc card wrappers in the NPS page:

1. **Line 923** `<div className="bg-white rounded-lg shadow p-6">` → `<CardContainer elevated>`
2. **Line 1097** `<div className="bg-white rounded-lg shadow p-6 grid grid-cols-2 gap-5 content-center">` → `<CardContainer elevated className="grid grid-cols-2 gap-5 content-center">`
3. **Line 1157** (Client Scores section wrapper) `<div className="bg-white rounded-lg shadow">` → `<CardContainer padding="none" elevated>`
4. **Line 1401** (Topics section wrapper) `<div className="bg-white rounded-lg shadow">` → `<CardContainer padding="none" elevated>`

Note: Using `elevated` adds `shadow-md` which is close to the existing `shadow`. The `LayoutTokens.card` base includes `shadow-sm`.

**Step 3: Verify build and visual**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -30`
Expected: No errors. Visually verify NPS page cards look correct.

**Step 4: Commit**

```bash
git add src/app/(dashboard)/nps/page.tsx
git commit -m "refactor: adopt CardContainer in NPS summary cards"
```

---

## Task 8: CardContainer adoption — WidgetContainer and EmployeeSearch

**Files:**
- Modify: `src/components/dashboard/WidgetContainer.tsx` (line 125)
- Modify: `src/components/ui/employee-search.tsx` (line 186)

**Step 1: WidgetContainer dropdown**

In `src/components/dashboard/WidgetContainer.tsx`:
- Add import: `import { CardContainer } from '@/components/ui/CardContainer'`
- Replace line 125: `<div className="absolute right-0 top-full mt-1 w-40 bg-white rounded-lg shadow-lg border border-gray-200 py-1 z-20">`
- With: `<CardContainer padding="none" elevated className="absolute right-0 top-full mt-1 w-40 py-1 z-20">`

**Step 2: EmployeeSearch dropdown**

In `src/components/ui/employee-search.tsx`:
- Add import: `import { CardContainer } from '@/components/ui/CardContainer'`
- Replace line 186: `<div className="absolute z-50 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-60 overflow-y-auto">`
- With: `<CardContainer padding="none" elevated className="absolute z-50 w-full mt-1 max-h-60 overflow-y-auto">`

**Step 3: Verify build**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -30`
Expected: No errors

**Step 4: Commit**

```bash
git add src/components/dashboard/WidgetContainer.tsx src/components/ui/employee-search.tsx
git commit -m "refactor: adopt CardContainer in WidgetContainer and EmployeeSearch dropdowns"
```

---

## Task 9: Update roadmap and docs

**Files:**
- Modify: `docs/knowledge-base/08-roadmap/quick-wins.md` (mark NPS DataTable as done)
- Modify: `docs/knowledge-base/08-roadmap/priorities.md` (mark P5 deferred items as done)

**Step 1: Update quick-wins.md**

Find the line `**NPS table to DataTable — DEFERRED**` and replace with:
`**NPS table to DataTable — DONE** (2026-02-15): Client scores migrated to DataTable with expandable AI insights, row actions, sparkline columns`

**Step 2: Update priorities.md**

Find the P5 section and update the deferred items:
- `LayoutTokens.card adoption` → mark as DONE
- `Component consolidation` → mark as DONE

**Step 3: Commit docs submodule**

```bash
cd ~/GitHub/apac-intelligence-v2/docs
git add knowledge-base/08-roadmap/quick-wins.md knowledge-base/08-roadmap/priorities.md
git commit -m "docs: mark P5 deferred items and NPS DataTable as done"
cd ~/GitHub/apac-intelligence-v2
git add docs
git commit -m "docs: update submodule ref — P5 deferred items complete"
```

---

## Summary

| Task | Description | ~Lines Changed |
|------|-------------|---------------|
| 1 | Extract TrendBadge | +30, -15 |
| 2 | Deduplicate StatusBadge | +2 imports, -40 local defs |
| 3 | DataTable expandable rows | +50 |
| 4 | NPSClientDataTable component | +200 (new file) |
| 5 | NPS page migration | -310 (card+context menu), +30 (DataTable usage) |
| 6 | Skeleton CardContainer | ~16 replacements |
| 7 | NPS summary CardContainer | 4 replacements |
| 8 | Widget/Search CardContainer | 2 replacements |
| 9 | Docs update | ~10 lines |
