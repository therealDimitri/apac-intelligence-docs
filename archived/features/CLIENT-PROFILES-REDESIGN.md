# Client Profiles Page - Modern UI/UX Redesign

**Version:** 2.0
**Date:** 2026-01-05
**Status:** Implementation Ready

---

## Executive Summary

This document outlines a comprehensive redesign of the Client Profiles page, transforming it from a basic card grid into a cutting-edge, feature-rich customer success interface inspired by industry leaders like Salesforce, HubSpot, Gainsight, Linear, Stripe, and Notion.

### Goals
1. **Improve data density** whilst maintaining clarity
2. **Enhance filtering & search** with advanced capabilities
3. **Enable multiple view modes** for different use cases
4. **Increase interactivity** with inline editing and quick actions
5. **Improve accessibility** and mobile responsiveness
6. **Add advanced features** like bulk actions, command palette, and health trends

---

## Current State Analysis

### Existing Implementation

**File:** `/src/app/(dashboard)/client-profiles/page.tsx`

**Current Features:**
- ✅ Card-based grid layout (1-4 columns responsive)
- ✅ Search by client name or CSE
- ✅ Segment filtering (Giant, Collaboration, Leverage, etc.)
- ✅ Health score visualisation with circular progress
- ✅ Health sparkline (30-day trend)
- ✅ Context menu with quick actions
- ✅ Event type filtering from URL params
- ✅ Client logo display
- ✅ CSE photo integration
- ✅ Real-time data refresh indicator

**Current Data Displayed:**
- Client name and logo
- CSE name and photo
- Health score (calculated)
- Health status badge (Healthy/At-risk/Critical)
- Health sparkline (30-day trend)
- Segment badge
- Event compliance data (when filtered)

**Pain Points:**
1. **Limited view options** - Only card grid available
2. **No inline editing** - Must navigate to client detail page
3. **No bulk actions** - Can't act on multiple clients
4. **Limited sorting** - Only health score or compliance
5. **No saved filters** - Must reapply filters each visit
6. **No keyboard shortcuts** - Mouse-dependent navigation
7. **Limited data visibility** - Can't see NPS, compliance %, or actions at a glance
8. **No comparison mode** - Can't compare clients side-by-side

---

## Industry Research Summary

### Salesforce Lightning Design System 2 (2025)

**Key Patterns:**
- **Modular architecture** with reusable components
- **Styling hooks** (CSS custom properties) for theming
- **Agentic design** - AI-forward interfaces with primitives
- **Consistent visual hierarchy** across all views
- **Flexible layout system** that adapts to user needs

**Sources:**
- [Lightning Design System 2](https://www.lightningdesignsystem.com/)
- [What is SLDS 2?](https://www.salesforce.com/blog/what-is-slds-2/)

### HubSpot Company Records (2025)

**Key Patterns:**
- **UI Extensions with React** for custom cards
- **Multi-step flows** for complex processes
- **Bidirectional property refreshes** - real-time updates
- **Table design patterns** - sortable, filterable data
- **CRM data components** - consistent data display
- **Figma design kit** for visual consistency
- **Refreshed visual theme** with improved contrast
- **Simplified design components** for AI-era workflows

**Sources:**
- [Spring Spotlight 2025: UI Extensions](https://developers.hubspot.com/blog/app-cards-updates-spring-spotlight-2025)
- [Rethinking HubSpot's Record Design](https://product.hubspot.com/blog/rethinking-hubspots-record-design-with-usability-in-mind)
- [HubSpot UI Extensions Examples](https://github.com/HubSpot/ui-extensions-examples/tree/main/design-patterns)

### Gainsight Customer Success Platform (2025)

**Key Patterns:**
- **Flexible widget resizing** - vertical, horizontal, diagonal
- **Persistent sizing** - custom dimensions saved
- **Smart grid layout** - structured alignment
- **Centralised administration** for AI features
- **Attachments functionality** - centralised file management
- **C360/R360 tabs** - customer 360° view
- **Excellent UI** for seeing all customer info in one place

**Sources:**
- [Gainsight New UI 2025](https://decidesoftware.com/gainsight-new-ui-and-capabilities-for-customer-success/)
- [Gainsight CS Release Notes July 2025](https://support.gainsight.com/gainsight_nxt/Release_Notes/Current_Release_Notes_-_2025/02_Gainsight_CS_Release_Notes_July_2025)

### Linear Issue Tracking (2025)

**Key Patterns:**
- **Keyboard-first navigation** - every action via keyboard
- **Real-time sync** - updates in milliseconds
- **Clean, minimal UI** - no clutter, reduced visual noise
- **Opinionated workflows** - reduced decision fatigue
- **List and board views** with swimlanes
- **Inverted L-shape** - sidebar + top navigation
- **Increased hierarchy and density** of navigation
- **Fast performance** as core feature
- **Linear design trend** - bold typography, monochrome with accent colours

**Sources:**
- [How we redesigned the Linear UI](https://linear.app/now/how-we-redesigned-the-linear-ui)
- [Linear Design Trend](https://blog.logrocket.com/ux-design/linear-design/)
- [Linear App Case Study](https://www.eleken.co/blog-posts/linear-app-case-study)

### Stripe Dashboard (2025)

**Key Patterns:**
- **Details pages** for individual objects
- **UI extensions SDK** for custom apps
- **Limited custom styling** for consistency
- **High accessibility bar** - colour contrast standards
- **Sidebar organisation** - balance, transactions, customers
- **Home page analytics** with charts
- **Important notifications** surfaced prominently
- **Figma UI toolkit** for design consistency

**Sources:**
- [Stripe Apps Build UI](https://docs.stripe.com/stripe-apps/build-ui)
- [Stripe Apps Design Patterns](https://docs.stripe.com/stripe-apps/patterns)
- [Stripe Apps UI Toolkit](https://www.figma.com/community/file/1105918844720321397/stripe-apps-ui-toolkit)

### Notion Database Views (2025)

**Key Patterns:**
- **Multiple view layouts** - Table, Board, Timeline, Calendar, List, Gallery, Chart
- **Progressive disclosure** - hide complexity until needed
- **Collapsible menus** - revealed only when clicked
- **Contextual tooltips** - helpful without clutter
- **Data Sources architecture** - modular databases
- **View tabs** for different perspectives
- **Filters, sorts, and groups** per view
- **Clean visual hierarchy** - minimalist approach (June 2025 update)
- **Property management** - flexible data model

**Sources:**
- [Notion's New UI Update June 2025](https://theorganizednotebook.com/blogs/blog/notion-new-ui-design-update-june-2025)
- [Notion Data Sources 2025](https://www.notionapps.com/blog/notion-data-sources-update-2025)
- [Notion Databases Guide](https://bullet.so/blog/how-to-master-notion-databases/)

---

## Recommended Design

### Design Philosophy

**Core Principles:**
1. **Linear-inspired minimalism** - Clean, fast, keyboard-first
2. **HubSpot-style flexibility** - Multiple views, real-time updates
3. **Gainsight data richness** - Customer 360° insights
4. **Notion-like view modes** - Table, Grid, Board, Chart options
5. **Stripe-quality polish** - Consistent, accessible, professional

### Visual Hierarchy

```
┌─────────────────────────────────────────────────────────────────────────┐
│ STICKY HEADER                                                            │
│ ┌─────────────────────────────────────────────────────────────────┐    │
│ │ Client Profiles    [Refresh ●]           [Grid] [Table] [Chart] │    │
│ │ 26 active clients                                    [⌘K Search] │    │
│ └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ STICKY FILTER BAR                                                        │
│ ┌─────────────────────────────────────────────────────────────────┐    │
│ │ [🔍 Search...]  [Segment ▾]  [Status ▾]  [CSE ▾]     [+ Filter] │    │
│ │                                                                   │    │
│ │ Active filters: Health: At-risk ⊗  Segment: Giant ⊗   Clear all │    │
│ └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ QUICK STATS (Collapsed by default - expandable)                         │
│ ┌─────────────────────────────────────────────────────────────────┐    │
│ │  ☑ 18 Healthy    ⚠ 6 At-risk    ✗ 2 Critical    📈 Avg: 76    │    │
│ └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ MAIN CONTENT AREA (View-dependent)                                      │
│                                                                          │
│  [Grid View - Current]    OR    [Table View]    OR    [Chart View]     │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ BULK ACTIONS BAR (Appears when items selected)                          │
│ ┌─────────────────────────────────────────────────────────────────┐    │
│ │ 3 selected    [Assign CSE]  [Export]  [Tag]  [More ▾]  [Deselect]│   │
│ └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

### View Modes

#### 1. Grid View (Enhanced Current)

**Layout:**
```
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│  [Logo]  │  │  [Logo]  │  │  [Logo]  │  │  [Logo]  │
│          │  │          │  │          │  │          │
│ Client A │  │ Client B │  │ Client C │  │ Client D │
│ CSE: John│  │ CSE: Jane│  │ CSE: John│  │ CSE: Mike│
│          │  │          │  │          │  │          │
│ ●●●●●○○  │  │ ●●●○○○○  │  │ ●●●●●●●  │  │ ●●●●○○○  │
│   72     │  │   45     │  │   88     │  │   68     │
│          │  │          │  │          │  │          │
│ 📊 ▲─▲   │  │ 📊 ▼─▼   │  │ 📊 ▲▲▲   │  │ 📊 ──▲   │
│          │  │          │  │          │  │          │
│ [Giant]  │  │ [Nurture]│  │ [Collab] │  │ [Lever]  │
│          │  │          │  │          │  │          │
│ NPS: 8   │  │ NPS: 4   │  │ NPS: 9   │  │ NPS: 7   │
│ Comp:95% │  │ Comp:78% │  │ Comp:98% │  │ Comp:87% │
│ Acts:2/5 │  │ Acts:3/4 │  │ Acts:0/2 │  │ Acts:1/3 │
│          │  │          │  │          │  │          │
│ [☑ Select]│ │ [☑ Select]│ │ [☑ Select]│ │ [☑ Select]│
└──────────┘  └──────────┘  └──────────┘  └──────────┘
```

**Features:**
- Larger cards with more data
- Inline checkboxes for bulk selection
- Quick stats (NPS, Compliance, Actions)
- Health trend sparkline
- Hover shows quick actions menu
- Drag to reorder (optional)

#### 2. Table View (New)

**Layout:**
```
┌────┬─────────────┬──────────┬────────┬────────┬─────┬───────┬────────┬──────────┐
│ ☑  │ Client      │ CSE      │ Health │ Trend  │ NPS │ Comp% │ Actions│ Segment  │
├────┼─────────────┼──────────┼────────┼────────┼─────┼───────┼────────┼──────────┤
│ ☐  │ ◉ Client A  │ 👤 John  │ ●●●●●○ │ ▲─▲    │  8  │  95%  │  2/5   │ 👑 Giant │
│    │             │          │   72   │        │     │       │        │          │
├────┼─────────────┼──────────┼────────┼────────┼─────┼───────┼────────┼──────────┤
│ ☐  │ ◉ Client B  │ 👤 Jane  │ ●●●○○○ │ ▼─▼    │  4  │  78%  │  3/4   │ 🌱 Nurture│
│    │             │          │   45   │        │     │       │        │          │
├────┼─────────────┼──────────┼────────┼────────┼─────┼───────┼────────┼──────────┤
│ ☐  │ ◉ Client C  │ 👤 John  │ ●●●●●● │ ▲▲▲    │  9  │  98%  │  0/2   │ ⭐ Collab │
│    │             │          │   88   │        │     │       │        │          │
└────┴─────────────┴──────────┴────────┴────────┴─────┴───────┴────────┴──────────┘
```

**Features:**
- Dense data display
- Sortable columns (click header)
- Resizable columns (drag edge)
- Sticky header on scroll
- Inline editing (double-click cell)
- Row selection for bulk actions
- Export to CSV/Excel
- Column visibility toggle

#### 3. Chart View (New)

**Layout:**
```
┌─────────────────────────────────────────────────────────────────────┐
│ Health Score Distribution                                           │
│                                                                      │
│ Critical (0-50)    ████ 2 clients                                   │
│ At-risk (51-70)    ████████████ 6 clients                           │
│ Healthy (71-100)   ████████████████████████ 18 clients              │
│                                                                      │
├─────────────────────────────────────────────────────────────────────┤
│ By Segment                                                           │
│                                                                      │
│ Giant         ▮▮▮▮▮▮▮▮ 8 clients  Avg Health: 78                   │
│ Collaboration ▮▮▮▮ 4 clients      Avg Health: 82                   │
│ Leverage      ▮▮▮▮▮ 5 clients     Avg Health: 75                   │
│ Maintain      ▮▮▮ 3 clients       Avg Health: 68                   │
│ Nurture       ▮▮▮▮ 4 clients      Avg Health: 62                   │
│ Sleeping Giant ▮▮ 2 clients      Avg Health: 58                   │
│                                                                      │
├─────────────────────────────────────────────────────────────────────┤
│ Health Trend (30 days)                                               │
│                                                                      │
│  90┤                                   ╭─╮                          │
│    │                           ╭───╮   │ │                          │
│  70┤           ╭───╮       ╭───╯   ╰───╯ ╰──╮                      │
│    │   ╭───────╯   ╰───────╯              ╰───╮                    │
│  50┤───╯                                      ╰──                  │
│    └──────────────────────────────────────────────────             │
│       Dec 1        Dec 15        Jan 1         Today               │
└─────────────────────────────────────────────────────────────────────┘
```

**Features:**
- Portfolio health visualisations
- Segment comparison charts
- Trend analysis over time
- NPS distribution
- Compliance overview
- Interactive tooltips
- Export charts as PNG/SVG

---

## Key UI Patterns to Implement

### 1. Sticky Header with View Switcher

**Component:** `<ClientProfilesHeader />`

```tsx
<div className="sticky top-0 z-50 bg-white border-b shadow-sm">
  <div className="px-6 py-4 flex items-center justify-between">
    <div>
      <h1 className="text-2xl font-bold">Client Profiles</h1>
      <p className="text-sm text-gray-600">{filteredCount} clients</p>
    </div>

    <div className="flex items-center gap-4">
      {/* View Switcher */}
      <div className="flex bg-gray-100 rounded-lg p-1">
        <ViewButton icon={Grid3x3} view="grid" />
        <ViewButton icon={List} view="table" />
        <ViewButton icon={BarChart3} view="chart" />
      </div>

      {/* Command Palette */}
      <button className="flex items-center gap-2 px-3 py-2 bg-gray-100 rounded-lg">
        <Search size={16} />
        <span className="text-sm">⌘K</span>
      </button>
    </div>
  </div>
</div>
```

### 2. Advanced Filter Bar

**Component:** `<AdvancedFilterBar />`

```tsx
<div className="sticky top-16 z-40 bg-white border-b">
  <div className="px-6 py-3 flex items-center gap-3">
    {/* Quick Search */}
    <div className="flex-1 relative">
      <Search className="absolute left-3 top-1/2 -translate-y-1/2" />
      <input
        className="w-full pl-10 pr-4 py-2 border rounded-lg"
        placeholder="Search clients, CSE, or segment..."
      />
    </div>

    {/* Filter Dropdowns */}
    <FilterDropdown label="Segment" options={segments} />
    <FilterDropdown label="Status" options={statuses} />
    <FilterDropdown label="CSE" options={cses} />

    {/* Advanced Filters */}
    <button className="px-3 py-2 border rounded-lg">
      <Plus size={16} /> Filter
    </button>

    {/* Save View */}
    <button className="px-3 py-2 bg-purple-600 text-white rounded-lg">
      Save View
    </button>
  </div>

  {/* Active Filters */}
  {hasActiveFilters && (
    <div className="px-6 pb-3 flex items-center gap-2">
      <span className="text-sm text-gray-600">Active:</span>
      {filters.map(filter => (
        <FilterTag key={filter.id} filter={filter} onRemove={removeFilter} />
      ))}
      <button onClick={clearAll} className="text-sm text-purple-600">
        Clear all
      </button>
    </div>
  )}
</div>
```

### 3. Enhanced Grid Cards

**Component:** `<EnhancedClientCard />`

**Features:**
- Selection checkbox (top-left)
- More data visible (NPS, Compliance, Actions)
- Quick actions on hover
- Skeleton loading state
- Optimistic updates
- Drag handle (optional)

### 4. Table View with Inline Editing

**Component:** `<ClientProfilesTable />`

**Features:**
- Virtual scrolling for performance
- Sortable columns
- Resizable columns
- Inline editing (double-click)
- Bulk selection
- Sticky header
- Column visibility controls
- Export functionality

### 5. Command Palette (⌘K)

**Component:** `<CommandPalette />`

**Keyboard Shortcuts:**
```
⌘K       Open command palette
⌘F       Focus search
⌘1/2/3   Switch view (Grid/Table/Chart)
⌘A       Select all
⌘D       Deselect all
↑/↓      Navigate items
Enter    Open selected item
Esc      Close/Clear
G then H Go to healthy clients
G then A Go to at-risk clients
G then C Go to critical clients
```

**Commands:**
- Go to client...
- Filter by segment...
- Filter by CSE...
- Filter by health status...
- Export selected...
- Assign CSE to selected...
- View analytics...
- Create new client...

### 6. Bulk Actions Bar

**Component:** `<BulkActionsBar />`

```tsx
<div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50">
  <div className="bg-gray-900 text-white rounded-lg shadow-2xl px-6 py-3 flex items-center gap-4">
    <span className="text-sm">{selectedCount} selected</span>

    <div className="h-6 w-px bg-gray-700" />

    <button className="px-3 py-1.5 hover:bg-gray-800 rounded">
      Assign CSE
    </button>
    <button className="px-3 py-1.5 hover:bg-gray-800 rounded">
      Export
    </button>
    <button className="px-3 py-1.5 hover:bg-gray-800 rounded">
      Add Tag
    </button>
    <button className="px-3 py-1.5 hover:bg-gray-800 rounded">
      More ▾
    </button>

    <div className="h-6 w-px bg-gray-700" />

    <button onClick={deselectAll} className="text-gray-400 hover:text-white">
      ✕
    </button>
  </div>
</div>
```

### 7. Inline Editing

**Pattern:** Double-click to edit

```tsx
const [editing, setEditing] = useState(false)
const [value, setValue] = useState(initialValue)

return (
  <div onDoubleClick={() => setEditing(true)}>
    {editing ? (
      <input
        value={value}
        onChange={e => setValue(e.target.value)}
        onBlur={handleSave}
        onKeyDown={e => e.key === 'Enter' && handleSave()}
        autoFocus
      />
    ) : (
      <span>{value}</span>
    )}
  </div>
)
```

### 8. Quick Actions Menu

**Pattern:** Hover card with actions

```tsx
<Popover>
  <PopoverTrigger asChild>
    <button className="absolute top-2 right-2 opacity-0 group-hover:opacity-100">
      <MoreVertical />
    </button>
  </PopoverTrigger>

  <PopoverContent>
    <QuickAction icon={Eye} label="View Profile" onClick={viewProfile} />
    <QuickAction icon={Edit} label="Edit Details" onClick={edit} />
    <QuickAction icon={Calendar} label="Schedule Meeting" onClick={schedule} />
    <QuickAction icon={Mail} label="Send Email" onClick={email} />
    <div className="border-t my-1" />
    <QuickAction icon={Trash} label="Archive" onClick={archive} variant="danger" />
  </PopoverContent>
</Popover>
```

### 9. Health Score Visualisation

**Enhanced version with more context:**

```tsx
<div className="relative">
  {/* Circular progress */}
  <svg viewBox="0 0 100 100">
    <circle cx="50" cy="50" r="42" stroke="rgba(0,0,0,0.1)" strokeWidth="10" fill="none" />
    <circle
      cx="50" cy="50" r="42"
      stroke={healthColour}
      strokeWidth="10"
      fill="none"
      strokeDasharray={`${score * 2.64} 264`}
      transform="rotate(-90 50 50)"
    />
  </svg>

  {/* Score text */}
  <div className="absolute inset-0 flex flex-col items-center justify-center">
    <span className="text-3xl font-bold">{score}</span>
    <span className="text-xs text-gray-600">Health</span>
    {/* Trend indicator */}
    {trend > 0 ? (
      <TrendingUp className="h-3 w-3 text-green-600" />
    ) : (
      <TrendingDown className="h-3 w-3 text-red-600" />
    )}
  </div>
</div>
```

### 10. Timeline/Activity Feed

**Component:** `<ClientActivityFeed />`

**Show recent activities:**
- NPS responses
- Meetings scheduled/completed
- Actions created/completed
- Health score changes
- Compliance updates
- CSE changes

---

## Component Breakdown

### New Components to Create

1. **`<ClientProfilesHeader />`**
   - View switcher
   - Stats summary
   - Command palette trigger
   - Refresh indicator

2. **`<AdvancedFilterBar />`**
   - Quick search
   - Multi-select filters
   - Active filter tags
   - Save view button

3. **`<ClientProfilesTable />`**
   - Virtual scrolling
   - Sortable columns
   - Resizable columns
   - Inline editing
   - Selection checkboxes

4. **`<ChartView />`**
   - Health distribution chart
   - Segment breakdown
   - Trend analysis
   - NPS overview

5. **`<BulkActionsBar />`**
   - Fixed bottom bar
   - Action buttons
   - Selection count
   - Deselect button

6. **`<CommandPalette />`**
   - Fuzzy search
   - Keyboard navigation
   - Recent commands
   - Grouped commands

7. **`<QuickStatsBar />`**
   - Healthy/At-risk/Critical counts
   - Average health score
   - Collapsible
   - Animated transitions

8. **`<SavedViewsMenu />`**
   - Personal views
   - Team views
   - Create new view
   - Manage views

9. **`<EnhancedClientCard />`**
   - Checkbox selection
   - More data fields
   - Quick actions popover
   - Loading skeleton

10. **`<ColumnVisibilityControl />`**
    - Show/hide columns
    - Reorder columns
    - Reset to default

### Existing Components to Enhance

1. **`useClients` hook** - Add sorting, filtering, selection state
2. **`HealthSparkline`** - Add click to expand
3. **`ClientLogoDisplay`** - Add fallback states

---

## Implementation Phases

### Phase 1: Foundation (Week 1)
**Goal:** Core infrastructure and Grid view enhancement

- [ ] Set up view state management (Zustand store)
- [ ] Create `<ClientProfilesHeader />` with view switcher
- [ ] Enhance `<AdvancedFilterBar />` with multi-select
- [ ] Add selection state to grid cards
- [ ] Implement `<BulkActionsBar />`
- [ ] Add more data to grid cards (NPS, Compliance, Actions)
- [ ] Create skeleton loading states

**Deliverables:**
- Enhanced Grid view with selection
- Working bulk actions
- Improved filter bar
- Loading states

### Phase 2: Table View (Week 2)
**Goal:** Add dense table layout

- [ ] Create `<ClientProfilesTable />` component
- [ ] Implement virtual scrolling (@tanstack/react-virtual)
- [ ] Add sortable columns
- [ ] Add resizable columns
- [ ] Implement inline editing
- [ ] Add column visibility controls
- [ ] Create export functionality (CSV/Excel)

**Deliverables:**
- Functional table view
- Sorting and filtering
- Export capability

### Phase 3: Command Palette (Week 3)
**Goal:** Keyboard-first navigation

- [ ] Create `<CommandPalette />` with cmdk
- [ ] Implement keyboard shortcuts (⌘K, ⌘1/2/3, etc.)
- [ ] Add fuzzy search
- [ ] Create command groups
- [ ] Add recent commands
- [ ] Implement navigation commands

**Deliverables:**
- Working command palette
- Full keyboard navigation
- Documented shortcuts

### Phase 4: Chart View & Analytics (Week 4)
**Goal:** Visual insights

- [ ] Create `<ChartView />` component
- [ ] Implement health distribution chart (Recharts)
- [ ] Add segment breakdown
- [ ] Create trend analysis chart
- [ ] Add NPS overview
- [ ] Implement export charts as PNG

**Deliverables:**
- Chart view with insights
- Export functionality
- Interactive tooltips

### Phase 5: Advanced Features (Week 5)
**Goal:** Power user features

- [ ] Implement saved views (database-backed)
- [ ] Add `<SavedViewsMenu />`
- [ ] Create inline editing for all fields
- [ ] Add quick actions popover
- [ ] Implement drag-to-reorder (optional)
- [ ] Add client comparison mode
- [ ] Create advanced filter builder

**Deliverables:**
- Saved views system
- Inline editing
- Comparison mode

### Phase 6: Polish & Optimisation (Week 6)
**Goal:** Production-ready

- [ ] Add framer-motion animations
- [ ] Implement optimistic updates
- [ ] Add error boundaries
- [ ] Create comprehensive loading states
- [ ] Add empty states with illustrations
- [ ] Implement accessibility improvements (ARIA labels, keyboard nav)
- [ ] Add mobile-responsive design
- [ ] Performance optimisation (memoization, code splitting)
- [ ] Add unit tests
- [ ] Documentation and user guide

**Deliverables:**
- Polished, production-ready UI
- Full test coverage
- User documentation

---

## Accessibility Considerations

### WCAG 2.1 AA Compliance

1. **Keyboard Navigation**
   - All interactive elements accessible via keyboard
   - Visible focus indicators
   - Logical tab order
   - Keyboard shortcuts documented

2. **Screen Reader Support**
   - ARIA labels on all icons
   - ARIA live regions for dynamic content
   - Semantic HTML structure
   - Descriptive button labels

3. **Colour Contrast**
   - Minimum 4.5:1 for text
   - Minimum 3:1 for UI components
   - Don't rely on colour alone
   - Support for dark mode

4. **Visual Accessibility**
   - Scalable text (rem units)
   - Clear visual hierarchy
   - Sufficient whitespace
   - Icon + text labels

5. **Motion & Animations**
   - Respect prefers-reduced-motion
   - Disable animations if requested
   - No auto-playing content
   - Pausable animations

### Accessibility Testing Checklist

- [ ] Test with keyboard only
- [ ] Test with screen reader (VoiceOver/NVDA)
- [ ] Check colour contrast (WebAIM checker)
- [ ] Test with 200% zoom
- [ ] Verify focus management
- [ ] Test with prefers-reduced-motion
- [ ] Validate HTML semantics
- [ ] Check ARIA implementation

---

## Mobile Responsiveness

### Breakpoints

- **Mobile:** < 640px (sm)
- **Tablet:** 640px - 1024px (md/lg)
- **Desktop:** > 1024px (xl)

### Mobile Adaptations

**Grid View:**
- 1 column on mobile
- 2 columns on tablet
- 3-4 columns on desktop

**Table View:**
- Horizontal scroll on mobile
- Sticky first column
- Or card-based layout on mobile

**Filter Bar:**
- Drawer on mobile
- Inline on desktop
- Floating filter button

**Bulk Actions:**
- Bottom sheet on mobile
- Fixed bar on desktop

**Command Palette:**
- Full screen on mobile
- Centred overlay on desktop

---

## Performance Optimisation

### Strategies

1. **Virtual Scrolling**
   - Use @tanstack/react-virtual for long lists
   - Only render visible items
   - Estimated row heights

2. **Memoization**
   - useMemo for expensive calculations
   - useCallback for event handlers
   - React.memo for pure components

3. **Code Splitting**
   - Lazy load chart view
   - Lazy load table view
   - Dynamic imports for heavy components

4. **Optimistic Updates**
   - Update UI immediately
   - Roll back on error
   - Show loading indicators

5. **Caching**
   - Cache client data
   - Stale-while-revalidate pattern
   - Cache filter states

6. **Image Optimisation**
   - Use Next.js Image component
   - Lazy load images
   - Proper sizing

### Performance Targets

- **Initial Load:** < 2s
- **Time to Interactive:** < 3s
- **Grid Render:** < 100ms
- **Table Render (1000 rows):** < 200ms
- **Filter/Search:** < 50ms
- **View Switch:** < 150ms

---

## Technology Stack

### Core
- **Next.js 16** - React framework
- **React 19** - UI library
- **TypeScript** - Type safety
- **Tailwind CSS 4** - Styling

### UI Components
- **Radix UI** - Accessible primitives
- **Framer Motion** - Animations
- **Lucide React** - Icons
- **cmdk** - Command palette
- **Sonner** - Toast notifications

### Data Management
- **@tanstack/react-query** - Server state
- **Zustand** - Client state
- **@tanstack/react-virtual** - Virtual scrolling

### Visualisations
- **Recharts** - Charts and graphs

### Utilities
- **clsx / tailwind-merge** - Class names
- **date-fns** - Date formatting
- **react-hotkeys-hook** - Keyboard shortcuts

---

## Success Metrics

### User Experience
- ☐ 50% reduction in clicks to find client
- ☐ 80% of users use keyboard shortcuts within 1 week
- ☐ 90% satisfaction score on new design
- ☐ 3x faster bulk actions

### Performance
- ☐ < 2s page load
- ☐ < 100ms filter response
- ☐ Support 1000+ clients without lag

### Adoption
- ☐ 100% feature parity with old design
- ☐ Zero accessibility issues
- ☐ < 5 bugs reported in first month
- ☐ 70% users try table view in first week

---

## Future Enhancements

### Post-Launch Ideas

1. **AI-Powered Insights**
   - Suggested actions based on health trends
   - Anomaly detection
   - Predictive health scores
   - Natural language search

2. **Collaboration**
   - Share views with team
   - Comments on clients
   - @mentions in notes
   - Activity feed

3. **Advanced Analytics**
   - Custom dashboards
   - Trend forecasting
   - Segment analysis
   - Cohort analysis

4. **Integrations**
   - Slack notifications
   - Calendar integration
   - Email templates
   - CRM sync

5. **Customisation**
   - Custom fields
   - Custom calculations
   - Theme builder
   - Widget library

---

## References & Inspiration

### Design Systems
- [Salesforce Lightning Design System 2](https://www.lightningdesignsystem.com/)
- [Stripe Apps UI Toolkit](https://www.figma.com/community/file/1105918844720321397/stripe-apps-ui-toolkit)
- [HubSpot UI Extensions](https://developers.hubspot.com/docs/apps/developer-platform/add-features/ui-extensibility)

### Industry Research
- [HubSpot Record Design](https://product.hubspot.com/blog/rethinking-hubspots-record-design-with-usability-in-mind)
- [Linear UI Redesign](https://linear.app/now/how-we-redesigned-the-linear-ui)
- [Notion Database Updates 2025](https://www.notionapps.com/blog/notion-data-sources-update-2025)
- [Gainsight CS Platform](https://decidesoftware.com/gainsight-new-ui-and-capabilities-for-customer-success/)

### Design Trends
- [Linear Design Trend](https://blog.logrocket.com/ux-design/linear-design/)
- [Notion UI Update June 2025](https://theorganizednotebook.com/blogs/blog/notion-new-ui-design-update-june-2025)

---

## Appendix: Database Schema Reference

### Clients Table (from useClients hook)

**Key Fields:**
- `id` - UUID
- `name` - Client name
- `cse_name` - Assigned CSE
- `segment` - Giant, Collaboration, Leverage, etc.
- `nps_score` - Latest NPS
- `compliance_percentage` - Event compliance
- `percent_under_60_days` - Working capital metric
- `percent_under_90_days` - Working capital metric
- `total_actions_count` - Total actions
- `completed_actions_count` - Completed actions

**Calculated Fields:**
- `health_score` - 0-100 (from calculateHealthScore)
- `health_status` - healthy | at-risk | critical

---

**End of Document**
