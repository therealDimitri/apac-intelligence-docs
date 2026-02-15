# Unified Actions System Design

**Version:** 1.0
**Date:** 30 December 2025
**Author:** Architecture Team
**Status:** Proposal

---

## Executive Summary

This document proposes a unified actions system that consolidates four currently disparate action management workflows into a single, cohesive experience. The goal is to eliminate inconsistencies, reduce user confusion, and create a modern, intuitive interface inspired by best practices from [Linear](https://linear.app/), [Asana](https://asana.com/templates/eisenhower-matrix), [ClickUp](https://clickup.com/blog/task-management-software/), and [Notion](https://www.simple.ink/blog/notion-2025-what-to-expect-exploring-new-features-and-strategic-directions).

---

## Table of Contents

1. [Current State Analysis](#current-state-analysis)
2. [Problem Statement](#problem-statement)
3. [Design Principles](#design-principles)
4. [Proposed Architecture](#proposed-architecture)
5. [Unified Data Model](#unified-data-model)
6. [UI/UX Specifications](#uiux-specifications)
7. [Component Library](#component-library)
8. [Implementation Roadmap](#implementation-roadmap)
9. [Sources & References](#sources--references)

---

## Current State Analysis

### Existing Action Sources

| Source | Component | Conversion Method | Storage | Display |
|--------|-----------|-------------------|---------|---------|
| **BURC/CSI Insights** | `ActionRecommendationsPanel` | Manual via context menu | Creates new DB record | Card with context menu |
| **Briefing Room** | Extract Actions API | AI extraction via Claude | Direct DB insert | Meeting detail modal |
| **Actions Page** | `KanbanBoard` | Direct creation/edit | DB read/write | Kanban columns |
| **Priority Matrix** | `PriorityMatrix` | Maps from actions table | Read-only view | 4-quadrant matrix |

### Identified Inconsistencies

1. **Column Name Mismatches**
   - DB: `Action_Description`, Code: `title`
   - DB: `Owners` (capital), Code: `owner` (lowercase)
   - DB: `client` (lowercase), Code mixed usage

2. **Status Value Inconsistencies**
   - DB: `'To Do'`, `'In Progress'`, `'Completed'`, `'Cancelled'`
   - Code: `'open'`, `'in-progress'`, `'completed'`, `'cancelled'`

3. **Date Format Inconsistencies**
   - DB: `DD/MM/YYYY` (Australian)
   - API input: `YYYY-MM-DD` (ISO)
   - Display: Various formats

4. **Priority Value Inconsistencies**
   - DB: Capitalised (`'High'`, `'Medium'`)
   - Code: Lowercase (`'high'`, `'medium'`)

5. **Context Menu Differences**
   - BURC: "Create Action Item", "Assign to Team"
   - Kanban: "View Details", "Edit", Status/Priority submenus
   - Matrix: Inline panel actions

---

## Problem Statement

Users experience cognitive friction when:
1. Creating actions from different sources (BURC insights vs meeting transcripts)
2. Managing actions across different views (Kanban vs Matrix)
3. Understanding what actions they can take (inconsistent context menus)
4. Tracking action provenance (where did this action come from?)

**Goal:** Create a unified "Action" concept that behaves consistently regardless of origin or viewing context.

---

## Design Principles

Based on research from [NN/G contextual menus guidelines](https://www.nngroup.com/articles/contextual-menus-guidelines/), [Linear's design system](https://linear.app/now/how-we-redesigned-the-linear-ui), and [enterprise UX patterns](https://uitop.design/blog/design/enterprise-ux-design/):

### 1. Progressive Disclosure
Reveal complexity in layers. Show essential information first, details on demand.

### 2. Contextual Intelligence
Adapt UI based on action source, user role, and current task context.

### 3. Consistency Over Customisation
Same action = same behaviour, regardless of where it appears.

### 4. Clear Provenance
Always show where an action came from (AI insight, meeting, manual, ChaSen).

### 5. Immediate Feedback
Every action provides instant visual confirmation with undo capability.

---

## Proposed Architecture

### Unified Action Type

```typescript
/**
 * Unified Action Interface
 * Single source of truth for all action types
 */
export interface UnifiedAction {
  // Core identifiers
  id: string                    // UUID for API calls
  actionId: string              // Human-readable ID (ACT-2025-001)

  // Content
  title: string                 // Action description (max 200 chars)
  notes: string | null          // Extended details/context

  // Ownership
  client: string                // Client name
  clientId: number | null       // FK to clients table
  owners: string[]              // Array of owner names
  assignedBy: string | null     // Who created/assigned this

  // Timing
  dueDate: Date                 // Always stored as Date object
  createdAt: Date
  updatedAt: Date
  completedAt: Date | null

  // Classification
  status: ActionStatus          // Enum: 'not_started' | 'in_progress' | 'completed' | 'cancelled'
  priority: ActionPriority      // Enum: 'critical' | 'high' | 'medium' | 'low'
  category: string              // User-defined category

  // Provenance (NEW - tracks origin)
  source: ActionSource
  sourceMetadata: ActionSourceMetadata

  // AI Context (from ChaSen)
  aiContext?: AIActionContext

  // Internal Operations
  internal?: InternalOpsMetadata

  // Relationships
  meetingId?: string            // Source meeting (if from transcript)
  parentActionId?: string       // For sub-actions
  linkedInitiativeId?: number   // Portfolio initiative
}

// Enums for type safety
export enum ActionStatus {
  NOT_STARTED = 'not_started',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled'
}

export enum ActionPriority {
  CRITICAL = 'critical',
  HIGH = 'high',
  MEDIUM = 'medium',
  LOW = 'low'
}

export enum ActionSource {
  MANUAL = 'manual',           // Created via Actions page
  MEETING = 'meeting',         // Extracted from meeting transcript
  INSIGHT_AI = 'insight_ai',   // From AI insights (CSI)
  INSIGHT_ML = 'insight_ml',   // From ML recommendations
  CHASEN = 'chasen',           // ChaSen AI recommendation
  OUTLOOK = 'outlook',         // Synced from Outlook
  IMPORT = 'import'            // Bulk imported
}

export interface ActionSourceMetadata {
  source: ActionSource
  createdAt: Date

  // Source-specific metadata
  insightId?: string           // If from insight
  meetingId?: string           // If from meeting
  meetingTitle?: string
  extractionConfidence?: number // AI extraction confidence (0-100)
  originalRecommendation?: string // Original insight text
  ratioContext?: string        // BURC ratio (PS, SALES, etc.)
}

export interface AIActionContext {
  summary: string              // 3-4 sentence context
  keyPoints: string[]
  urgencyIndicators: string[]
  relatedTopics: string[]
  confidence: number           // 0-100
  generatedAt: Date
  model: string                // Which AI model generated
}
```

### Unified Action Service

```typescript
/**
 * Central service for all action operations
 * Handles conversion, validation, and persistence
 */
export class UnifiedActionService {

  // Create from any source
  async createFromInsight(insight: MLInsight): Promise<UnifiedAction>
  async createFromMeeting(meetingId: string, extractedAction: ExtractedAction): Promise<UnifiedAction>
  async createFromChaSen(recommendation: ChaSenRecommendation): Promise<UnifiedAction>
  async createManual(data: CreateActionDTO): Promise<UnifiedAction>

  // CRUD operations
  async update(id: string, updates: Partial<UnifiedAction>): Promise<UnifiedAction>
  async delete(id: string): Promise<void>
  async bulkUpdate(ids: string[], updates: Partial<UnifiedAction>): Promise<UnifiedAction[]>

  // Query operations
  async getById(id: string): Promise<UnifiedAction>
  async getByClient(clientName: string): Promise<UnifiedAction[]>
  async getByOwner(ownerName: string): Promise<UnifiedAction[]>
  async getOverdue(): Promise<UnifiedAction[]>

  // Conversion utilities
  toKanbanItem(action: UnifiedAction): KanbanItem
  toMatrixItem(action: UnifiedAction): MatrixItem
  toDatabaseRecord(action: UnifiedAction): DatabaseActionRecord
  fromDatabaseRecord(record: DatabaseActionRecord): UnifiedAction
}
```

---

## UI/UX Specifications

### Unified Context Menu

Based on [Microsoft's Split Context Menu](https://www.windowslatest.com/2025/11/06/microsoft-admits-windows-11s-right-click-menu-is-cluttered-confirms-fix-with-a-new-ui-feature/) and [NN/G guidelines](https://www.nngroup.com/articles/contextual-menus/):

```
┌─────────────────────────────────────┐
│ ⚡ Quick Actions                     │
│ ┌─────────┬─────────┬─────────────┐ │
│ │ ▶ Start │ ✓ Done  │ 📋 Duplicate│ │
│ └─────────┴─────────┴─────────────┘ │
├─────────────────────────────────────┤
│ 👁 View Details            ⌘D      │
│ ✏️ Edit                    ⌘E      │
├─────────────────────────────────────┤
│ Status                         ▶   │
│   ├ ○ Not Started                  │
│   ├ ◐ In Progress                  │
│   ├ ✓ Completed                    │
│   └ ✕ Cancelled                    │
│ Priority                       ▶   │
│   ├ 🔴 Critical                    │
│   ├ 🟠 High                        │
│   ├ 🔵 Medium                      │
│   └ ⚪ Low                         │
│ Assign to...                   ▶   │
├─────────────────────────────────────┤
│ 🔔 Set Reminder                    │
│ 📎 Link to Meeting                 │
│ 📊 Add to Initiative               │
├─────────────────────────────────────┤
│ 🗑 Delete                   ⌘⌫     │
└─────────────────────────────────────┘
```

**Key Design Decisions:**
1. **Quick Actions Bar** - Top row with 3 most common actions (inspired by Linear)
2. **Keyboard Shortcuts** - Visible for power users
3. **Grouped Sections** - Logical groupings with dividers
4. **Submenus** - For Status and Priority to reduce clutter
5. **Consistent Icons** - Same icons across all views

### Action Card Component

A single, reusable component for all views:

```
┌──────────────────────────────────────────────────────┐
│ ┌────┐ ┌──────┐ ┌────┐                    ┌───────┐ │
│ │HIGH│ │ ML   │ │ 📅 │ Review Q3 pipeline │ ⋮     │ │
│ └────┘ └──────┘ └────┘                    └───────┘ │
│                                                      │
│ Acme Corp • Jimmy L. • Due: 15 Jan 2026             │
│                                                      │
│ ┌─────────────────────────────────────────────────┐ │
│ │ 📊 From: SALES Ratio insight • 85% confidence  │ │
│ └─────────────────────────────────────────────────┘ │
│                                                      │
│ ┌─────────┐ ┌─────────────┐ ┌─────────────────────┐ │
│ │ ▶ Start │ │ ✓ Complete  │ │ More Info ▼        │ │
│ └─────────┘ └─────────────┘ └─────────────────────┘ │
└──────────────────────────────────────────────────────┘

Legend:
- Priority badge (coloured: red/orange/blue/grey)
- Source badge (AI/ML/Meeting/Manual)
- Calendar icon with due date indicator (red if overdue)
- Kebab menu (⋮) for context menu
- Provenance bar showing origin
- Action buttons with clear labels
```

### Toast Notification System

Consistent feedback across all action operations:

```typescript
// Success patterns
toast.success('Action Created', {
  description: '"Review Q3 pipeline" added to your task list',
  action: { label: 'View', onClick: () => navigateToAction(id) }
})

toast.success('Status Updated', {
  description: 'Marked as "In Progress"',
  action: { label: 'Undo', onClick: () => revertStatus(id, previousStatus) }
})

// Warning patterns
toast.warning('Overdue Action', {
  description: '"Review Q3 pipeline" was due 3 days ago',
  action: { label: 'Update Due Date', onClick: () => openDatePicker(id) }
})

// Error patterns
toast.error('Failed to Update', {
  description: 'Could not save changes. Please try again.',
  action: { label: 'Retry', onClick: () => retryUpdate(id, updates) }
})
```

### View Modes

#### 1. Kanban Board (Default for Actions Page)

```
┌─────────────────────────────────────────────────────────────────────┐
│ Actions & Tasks                         [Kanban] [List] [Calendar] │
├────────────────┬────────────────┬────────────────┬─────────────────┤
│  NOT STARTED   │  IN PROGRESS   │   COMPLETED    │   CANCELLED     │
│  (12)          │  (5)           │   (28)         │   (3)           │
├────────────────┼────────────────┼────────────────┼─────────────────┤
│ ┌────────────┐ │ ┌────────────┐ │ ┌────────────┐ │ ┌─────────────┐ │
│ │ Action 1   │ │ │ Action 4   │ │ │ Action 7   │ │ │ Action 10   │ │
│ └────────────┘ │ └────────────┘ │ └────────────┘ │ └─────────────┘ │
│ ┌────────────┐ │ ┌────────────┐ │                │                 │
│ │ Action 2   │ │ │ Action 5   │ │                │                 │
│ └────────────┘ │ └────────────┘ │                │                 │
│        ⋮       │        ⋮       │                │                 │
│ [+ Add Action] │                │                │                 │
└────────────────┴────────────────┴────────────────┴─────────────────┘
```

#### 2. Priority Matrix (Eisenhower)

Inspired by [UXPin Priority Matrix patterns](https://www.uxpin.com/studio/blog/priority-matrix-the-value-of-a-unique-ux/):

```
┌─────────────────────────────────────────────────────────────────────┐
│ Priority Matrix                              [•] Drag central dot   │
├────────────────────────────────┬────────────────────────────────────┤
│     🔥 DO NOW (Urgent+Imp)     │      📅 PLAN (Important)          │
│                                │                                    │
│  ┌────┐ ┌────┐ ┌────┐         │  ┌────┐ ┌────┐                     │
│  │ A1 │ │ A2 │ │ A3 │         │  │ A4 │ │ A5 │                     │
│  └────┘ └────┘ └────┘         │  └────┘ └────┘                     │
│                                │                                    │
├────────────────────────────────┼────────────────────────────────────┤
│     👥 DELEGATE (Urgent)       │      👁 MONITOR (Neither)          │
│                                │                                    │
│  ┌────┐                       │  ┌────┐ ┌────┐                     │
│  │ A6 │                       │  │ A7 │ │ A8 │                     │
│  └────┘                       │  └────┘ └────┘                     │
│                                │                                    │
└────────────────────────────────┴────────────────────────────────────┘

Quadrant behaviour:
- Drag items between quadrants to re-prioritise
- Double-click to open detail panel
- Right-click for context menu
- Quadrants auto-resize based on content (Linear-style)
```

#### 3. Unified Inbox (NEW - Inspired by Notion Mail)

A new view that shows ALL actionable items from all sources:

```
┌─────────────────────────────────────────────────────────────────────┐
│ 📥 Action Inbox                    [All] [AI] [Meetings] [Manual]  │
├─────────────────────────────────────────────────────────────────────┤
│ TODAY (3)                                                           │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ 🔴 HIGH │ ML │ Review SALES ratio decline                        │ │
│ │ Acme Corp • From: CSI Analysis • 2 hours ago                    │ │
│ └─────────────────────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ 🟠 MED  │ 📹 │ Follow up on training request                     │ │
│ │ Health NSW • From: Meeting with John • 4 hours ago              │ │
│ └─────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│ THIS WEEK (8)                                                       │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ 🔵 LOW  │ AI │ Schedule quarterly review                         │ │
│ │ Metro Health • From: ChaSen • Yesterday                         │ │
│ └─────────────────────────────────────────────────────────────────┘ │
│        ⋮                                                            │
└─────────────────────────────────────────────────────────────────────┘
```

### Insight-to-Action Conversion Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    INSIGHT CARD (BURC/CSI)                          │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ 🔴 CRITICAL │ ML │ SALES Ratio Below Target                     │ │
│ │                                                                  │ │
│ │ Sales ratio at 0.85 vs target 1.00 requires immediate review.  │ │
│ │                                                                  │ │
│ │ Analysis:                                                        │ │
│ │ 1. Q3 pipeline conversion dropped 15%                           │ │
│ │ 2. Two major deals slipped to Q4                                │ │
│ │ 3. New competitor pricing pressure identified                   │ │
│ │                                                                  │ │
│ │ ┌─────────────┐ ┌─────────────────┐ ┌─────────────────────────┐ │ │
│ │ │ ▶ Review    │ │ + Create Task   │ │ More Info ▼            │ │ │
│ │ │   Pipeline  │ │                 │ │                         │ │ │
│ │ └─────────────┘ └─────────────────┘ └─────────────────────────┘ │ │
│ └─────────────────────────────────────────────────────────────────┘ │
│                              │                                      │
│                              ▼ Click "Create Task"                  │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │                    QUICK CREATE MODAL                           │ │
│ │                                                                  │ │
│ │ Title: [Review SALES ratio decline               ] (pre-filled) │ │
│ │                                                                  │ │
│ │ ┌─────────────────────────────────────────────────────────────┐ │ │
│ │ │ 📊 Insight Context (auto-populated)                         │ │ │
│ │ │ • Source: CSI Analysis - ML Recommendation                  │ │ │
│ │ │ • Ratio: SALES (0.85 vs 1.00 target)                        │ │ │
│ │ │ • Confidence: 88%                                           │ │ │
│ │ └─────────────────────────────────────────────────────────────┘ │ │
│ │                                                                  │ │
│ │ Assign to: [Jimmy L.        ▼]  Due: [7 Jan 2026    📅]        │ │
│ │ Priority:  [High            ▼]  Client: [Acme Corp  ▼]         │ │
│ │                                                                  │ │
│ │         [Cancel]                    [Create Task]               │ │
│ └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Component Library

### New Unified Components

| Component | Purpose | Replaces |
|-----------|---------|----------|
| `<UnifiedActionCard />` | Single action display | `ActionCard`, `MatrixItem`, `RecommendationCard` |
| `<UnifiedContextMenu />` | Right-click menu | `ActionContextMenu`, `InsightContextMenu`, `RecommendationContextMenu` |
| `<ActionQuickCreate />` | Fast action creation | Multiple modals |
| `<ActionDetailPanel />` | Slide-out details | `ActionDetailModal` |
| `<ActionSourceBadge />` | Shows origin | Multiple badge implementations |
| `<ActionStatusPill />` | Status indicator | Various status displays |
| `<ActionPriorityBadge />` | Priority indicator | Various priority displays |
| `<UnifiedToast />` | Action feedback | Multiple toast patterns |

### Component Hierarchy

```
<ActionProvider>                    // Global state management
  ├── <ActionInbox />               // Unified inbox view
  ├── <KanbanBoard />               // Kanban view (uses UnifiedActionCard)
  ├── <PriorityMatrix />            // Matrix view (uses UnifiedActionCard)
  ├── <ActionQuickCreate />         // Creation modal
  ├── <ActionDetailPanel />         // Detail slide-out
  └── <UnifiedContextMenu />        // Global context menu
</ActionProvider>
```

---

## Implementation Roadmap

### Phase 1: Foundation (2 weeks)

1. **Create Unified Type Definitions**
   - Define `UnifiedAction` interface
   - Create enums for status, priority, source
   - Add migration helpers for existing data

2. **Build UnifiedActionService**
   - Central CRUD operations
   - Conversion methods for all sources
   - Database abstraction layer

3. **Standardise Database Schema**
   - Add `source` and `source_metadata` columns
   - Create migration for column name standardisation
   - Add indexes for common queries

### Phase 2: UI Components (2 weeks)

4. **Create Unified Components**
   - `UnifiedActionCard` with all display modes
   - `UnifiedContextMenu` with consistent options
   - `ActionSourceBadge` and `ActionStatusPill`
   - `UnifiedToast` notification system

5. **Update Existing Views**
   - Refactor Kanban to use new components
   - Refactor Priority Matrix to use new components
   - Update insight cards to use new action creation flow

### Phase 3: New Features (1 week)

6. **Action Inbox View**
   - New unified inbox page
   - Source filtering
   - Smart grouping (Today, This Week, Overdue)

7. **Enhanced Provenance Tracking**
   - Visual provenance indicators
   - Drill-down to source (meeting, insight, etc.)
   - Audit trail display

### Phase 4: Polish (1 week)

8. **Keyboard Shortcuts**
   - Global shortcuts for common actions
   - Command palette integration
   - Accessibility improvements

9. **Performance Optimisation**
   - Virtualised lists for large action counts
   - Optimistic updates
   - Background sync

---

## Sources & References

### Design Research
- [Linear Design Trend - LogRocket](https://blog.logrocket.com/ux-design/linear-design/)
- [Linear UI Redesign](https://linear.app/now/how-we-redesigned-the-linear-ui)
- [Enterprise UX Design Patterns - Uitop](https://uitop.design/blog/design/enterprise-ux-design/)
- [Top 7 Enterprise UX Patterns - Onething Design](https://www.onething.design/post/top-7-enterprise-ux-design-patterns)

### Context Menu Best Practices
- [NN/G Contextual Menus Guidelines](https://www.nngroup.com/articles/contextual-menus-guidelines/)
- [Microsoft Split Context Menu](https://www.windowslatest.com/2025/11/06/microsoft-admits-windows-11s-right-click-menu-is-cluttered-confirms-fix-with-a-new-ui-feature/)
- [Height - Guide to Context Menus](https://height.app/blog/guide-to-build-context-menus)
- [Mobbin - Context Menu UI Design](https://mobbin.com/glossary/context-menu)

### Task Management UX
- [Notion 2025 Features](https://www.simple.ink/blog/notion-2025-what-to-expect-exploring-new-features-and-strategic-directions)
- [ClickUp Task Management Guide](https://clickup.com/blog/task-management-software/)
- [Asana Eisenhower Matrix Template](https://asana.com/templates/eisenhower-matrix)
- [UXPin Priority Matrix UX](https://www.uxpin.com/studio/blog/priority-matrix-the-value-of-a-unique-ux/)

### Enterprise Software Trends
- [10 UX/UI Best Practices for 2025 - devPulse](https://devpulse.com/insights/ux-ui-design-best-practices-2025-enterprise-applications/)
- [Asana vs Monday vs ClickUp Comparison](https://www.makeitfuture.com/blog/project-management-tools-faceoff)

---

## Appendix A: Migration Strategy

### Database Column Mapping

| Current Column | New Column | Type | Notes |
|---------------|------------|------|-------|
| `Action_ID` | `action_id` | text | Keep for backwards compatibility |
| `Action_Description` | `title` | text | Rename with alias |
| `Notes` | `notes` | text | No change |
| `client` | `client_name` | text | Standardise |
| `Owners` | `owners` | text[] | Convert to array |
| `Due_Date` | `due_date` | timestamp | Convert from DD/MM/YYYY |
| `Status` | `status` | enum | Lowercase values |
| `Priority` | `priority` | enum | Lowercase values |
| NEW | `source` | enum | Add column |
| NEW | `source_metadata` | jsonb | Add column |

### Backwards Compatibility

All API endpoints will continue to accept legacy formats during transition:
- Status values: Both `'In Progress'` and `'in_progress'`
- Date formats: Both `DD/MM/YYYY` and `YYYY-MM-DD`
- Owner formats: Both semicolon-separated string and array

---

## Appendix B: Keyboard Shortcuts

| Shortcut | Action | Context |
|----------|--------|---------|
| `⌘ K` | Open command palette | Global |
| `⌘ N` | Create new action | Actions page |
| `⌘ D` | View details | Action selected |
| `⌘ E` | Edit action | Action selected |
| `⌘ ⌫` | Delete action | Action selected (with confirmation) |
| `1-4` | Set priority (Critical-Low) | Action selected |
| `S` | Toggle status menu | Action selected |
| `A` | Assign to... | Action selected |
| `↑ ↓` | Navigate actions | List/Kanban view |
| `← →` | Move between columns | Kanban view |
| `Space` | Toggle selection | Multi-select mode |
| `Esc` | Close modal/panel | Any modal open |

---

## Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Product Owner | | | |
| Tech Lead | | | |
| UX Designer | | | |
