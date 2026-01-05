# Pipeline UI/UX Redesign Specification

## Overview

A modern, low cognitive load pipeline interface aligned with BURC Dial 2 Risk Profile sections, incorporating best practices from Salesforce, HubSpot, Pipedrive, Linear, and Stripe.

---

## Design Philosophy

### Core Principles

1. **Progressive Disclosure** - Show 5 critical properties, reveal more on demand
2. **Recognition Over Recall** - All information needed visible at a glance
3. **Visual Chunking** - Group deals by section to reduce short-term memory load
4. **Low Cognitive Load** - Maximum 7+/-2 items per visual grouping

### Inspiration Sources

| Company | Pattern | Application |
|---------|---------|-------------|
| **Pipedrive** | Visual Kanban | Primary view structure |
| **HubSpot** | Traffic lights | Section colour coding |
| **Salesforce** | Path progression | Section headers |
| **Linear** | Minimal UI | Clean card design |
| **Stripe** | Micro-interactions | Hover states, animations |
| **Notion** | Database views | Filter/sort controls |

---

## Layout Structure

### Desktop Layout (1280px+)

```
+-----------------------------------------------------------------------+
|  Pipeline Overview                          [Filters v] [+ Add Deal]   |
|  $12.8M total | 73 opportunities | 45 forecasted                       |
+-----------------------------------------------------------------------+
|                                                                        |
|  +-- Summary Cards --------------------------------------------------+ |
|  | [In Forecast]        | [Pipeline]          | [Coverage]           | |
|  | $8.0M (30 deals)     | $4.8M (43 deals)    | 83% ratio            | |
|  +---------------------------------------------------------------+    |
|                                                                        |
|  +-- Section Bar (clickable to filter) ------------------------------+ |
|  | [=====GREEN 60%=====][=YLW 3%=][======PIPELINE 35%======][=R 3%=]  | |
|  +-------------------------------------------------------------------+ |
|                                                                        |
|  +-- Section Grid (2x2) --------------------------------------------+ |
|  |                                                                   | |
|  | +-Green (90%)---------+  +-Yellow (50%)--------+                  | |
|  | | $6.9M | 25 deals    |  | $205K | 5 deals     |                  | |
|  | | In Forecast         |  | In Forecast         |                  | |
|  | |                     |  |                     |                  | |
|  | | [Card] [Card] [Card]|  | [Card] [Card]       |                  | |
|  | | [Card] [Card] ...   |  | [Card] [Card]       |                  | |
|  | +---------------------+  +---------------------+                  | |
|  |                                                                   | |
|  | +-Pipeline (30%)------+  +-Red (20%)-----------+                  | |
|  | | $4.4M | 42 deals    |  | $328K | 1 deal      |                  | |
|  | | Not in Forecast     |  | At Risk             |                  | |
|  | |                     |  |                     |                  | |
|  | | [Card] [Card] [Card]|  | [Card]              |                  | |
|  | | [Card] [Card] ...   |  |                     |                  | |
|  | +---------------------+  +---------------------+                  | |
|  +-------------------------------------------------------------------+ |
+-----------------------------------------------------------------------+
```

### Mobile Layout (< 768px)

```
+---------------------------+
| Pipeline Overview    [+]  |
| $12.8M | 73 deals         |
+---------------------------+
| [Green|Yellow|Pipe|Red]   |  <- Tab navigation
+---------------------------+
|                           |
| Green Section (90%)       |
| $6.9M | 25 deals          |
| In Forecast               |
+---------------------------+
|                           |
| +---------------------+   |
| | [Logo] SA Health    |   |
| | SCM 25.1 Upgrade    |   |
| | $2.5M               |   |
| | [Forecasted] [JL]   |   |
| +---------------------+   |
|                           |
| +---------------------+   |
| | [Logo] SA Health    |   |
| | Renal              |   |
| | $1.2M               |   |
| | [Best Case] [JL]    |   |
| +---------------------+   |
|                           |
| [Load More...]            |
+---------------------------+
```

---

## Component Specifications

### 1. Deal Card

The primary unit of interaction. Must balance information density with clarity.

#### Card Anatomy

```
+--------------------------------------------------+
| [Logo]  Deal Name                           [:]  |  <- Kebab menu on hover
|         Client Name                              |
|                                                  |
| $XXX,XXX                        -> $XX,XXX       |  <- Net booking, Weighted
| Weighted: $XX,XXX                                |
|                                                  |
| [Forecasted]                            [Avatar] |  <- Badge + Owner
+--------------------------------------------------+
```

#### Card States

| State | Visual Treatment |
|-------|------------------|
| Default | 1px border, subtle shadow |
| Hover | 2px border (section colour), elevated shadow, show kebab |
| Focus | 3px outline (accessibility) |
| Dragging | 95% opacity, large shadow, cursor: grabbing |
| Selected | 2px border + background tint |

#### Card CSS

```css
.deal-card {
  background: #FFFFFF;
  border: 1px solid #E5E7EB;
  border-radius: 12px;
  padding: 16px;
  width: 100%;
  min-height: 140px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  transition: all 200ms cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
  position: relative;
}

.deal-card:hover {
  border-color: var(--section-color);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.12);
  transform: translateY(-2px);
}

.deal-card:focus-visible {
  outline: 3px solid var(--section-color);
  outline-offset: 2px;
}

/* Typography - CRITICAL: Use tabular numerals */
.deal-value {
  font-size: 24px;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
  font-family: 'Inter', system-ui, sans-serif;
  color: #111827;
}

.deal-weighted {
  font-size: 14px;
  color: #6B7280;
  font-variant-numeric: tabular-nums;
}
```

### 2. Section Header

Visual anchors for each BURC section.

```
+----------------------------------------------------------------+
| [Icon] Green Section  (90%)  In Forecast     25 deals | $6.9M  |
+----------------------------------------------------------------+
```

#### Section Colours (WCAG AA Compliant)

| Section | Background | Border | Text | Icon |
|---------|------------|--------|------|------|
| Green | #ECFDF5 | #16A34A | #14532D | CheckCircle |
| Yellow | #FEF3C7 | #D97706 | #78350F | AlertTriangle |
| Pipeline | #EFF6FF | #3B82F6 | #1E3A8A | TrendingUp |
| Red | #FEE2E2 | #DC2626 | #7F1D1D | XCircle |

### 3. Context Menu (Right-Click)

Available on every deal card.

```
+---------------------------+
| Assign Owner...           |
| Create Action Item        |
| Mark as Forecasted        |
|---------------------------|
| Move to Green             |
| Move to Yellow            |
| Move to Pipeline          |
| Move to Red               |
|---------------------------|
| Edit Details...           |
| Duplicate                 |
|---------------------------|
| Delete                    |  <- Disabled if no permission
+---------------------------+
```

#### Context Menu CSS

```css
.context-menu {
  position: absolute;
  background: #FFFFFF;
  border: 1px solid #E5E7EB;
  border-radius: 8px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
  padding: 6px;
  min-width: 200px;
  z-index: 1000;
}

.context-menu-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border-radius: 6px;
  font-size: 14px;
  color: #374151;
  cursor: pointer;
  transition: background 100ms;
}

.context-menu-item:hover {
  background: #F3F4F6;
}

.context-menu-item.danger:hover {
  background: #FEE2E2;
  color: #DC2626;
}
```

### 4. Summary Metrics Bar

Top-line KPIs for quick scanning.

```
+-----------------------------------------------------------------------+
| Total Net Booking    | Weighted Revenue    | Opportunities | Coverage |
| $12.8M               | $9.2M               | 73            | 83%      |
| +8.3% vs LM          | +$1.2M vs LM        | +5 new        |          |
+-----------------------------------------------------------------------+
```

#### Metric Card CSS

```css
.metric-card {
  background: #F9FAFB;
  border: 1px solid #E5E7EB;
  border-radius: 8px;
  padding: 16px;
}

.metric-primary {
  background: linear-gradient(135deg, #EFF6FF 0%, #DBEAFE 100%);
  border-color: #3B82F6;
}

.metric-value {
  font-size: 32px;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
  color: #111827;
}

.metric-change.positive {
  color: #16A34A;
}

.metric-change.negative {
  color: #DC2626;
}
```

---

## Interactions

### Drag and Drop

For moving deals between sections.

| Interaction | Behaviour |
|-------------|-----------|
| Grab | Card lifts with cursor: grabbing |
| Drag | Card follows cursor at 95% opacity |
| Valid Drop | Target section highlights with dashed border |
| Invalid Drop | Red border, cursor: not-allowed |
| Drop | 250ms spring animation to new position |
| Cancel (Esc) | 300ms return to origin |

**Accessibility Alternative:**
- Keyboard: Tab to card, Enter to pick up, Arrow keys to move, Enter to drop
- Screen reader: ARIA live regions announce movements

### Hover States

| Element | Hover Effect | Duration |
|---------|--------------|----------|
| Deal Card | Lift 2px, border highlight | 200ms |
| Section Header | Subtle background darken | 150ms |
| Context Menu Item | Background tint | 100ms |
| Kebab Button | Opacity from 0 to 1 | 200ms |

### Click Actions

| Element | Click | Double-Click |
|---------|-------|--------------|
| Deal Card | Select / Show detail panel | Open full modal |
| Section Header | Collapse/expand section | - |
| Filter Chip | Toggle filter | - |
| Section Bar Segment | Filter to that section | - |

---

## Filter & Sort

### Filter Bar

```
[All Deals v] [Forecasted v] [Section v] [Owner v] [Search...]
```

#### Filter Options

| Filter | Options |
|--------|---------|
| View | All Deals, Forecasted Only, Pipeline Only |
| Section | Green, Yellow, Pipeline, Red, All |
| Owner | All, [CSE List] |
| Category | Best Case, Business Case, Pipeline |
| Date Range | This Quarter, Next Quarter, This Year |

### Sort Options

- Net Booking (default, descending)
- Weighted Revenue
- Closure Date
- Client Name (A-Z)
- Recently Updated

---

## Responsive Breakpoints

| Breakpoint | Layout | Cards per Row |
|------------|--------|---------------|
| < 640px | Single column, tabs | 1 |
| 640-1024px | 2 columns | 2 |
| 1024-1280px | 2x2 grid | 2-3 per section |
| > 1280px | 2x2 grid, expanded | 3-4 per section |

---

## Accessibility Requirements

### WCAG 2.2 AA Compliance

| Requirement | Implementation |
|-------------|----------------|
| Colour contrast | 4.5:1 for text, 3:1 for UI |
| Keyboard navigation | Full tab order, arrow keys |
| Screen reader | ARIA labels on all elements |
| Focus indicators | 3px visible outline |
| Touch targets | 48x48px minimum |
| Colour alone | Never - always icon + text |

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Tab | Navigate cards |
| Enter | Open card / Confirm |
| Space | Select card |
| Arrow Keys | Move within section |
| Esc | Close modal / Cancel drag |
| ? | Show keyboard shortcuts |

---

## Data Display

### Number Formatting

| Value Type | Format | Example |
|------------|--------|---------|
| Currency | $X.XXM (millions) | $2.5M |
| Currency (small) | $XXX,XXX | $156,000 |
| Percentage | XX% | 90% |
| Count | XX deals | 25 deals |

### Date Formatting

| Type | Format | Example |
|------|--------|---------|
| Closure Date | DD MMM YYYY | 15 Mar 2026 |
| Relative | "X days" / "X months" | "45 days" |

---

## Animation Specifications

| Animation | Duration | Easing |
|-----------|----------|--------|
| Card hover | 200ms | cubic-bezier(0.4, 0, 0.2, 1) |
| Card lift | 150ms | ease-out |
| Drop | 250ms | spring(1, 80, 10) |
| Menu open | 150ms | ease-out |
| Menu close | 100ms | ease-in |
| Section collapse | 300ms | ease-in-out |

---

## Component Structure

```
src/components/pipeline/
├── PipelineView.tsx           # Main container
├── PipelineSummary.tsx        # Top-line metrics
├── SectionBreakdownBar.tsx    # Clickable segment bar
├── PipelineSection.tsx        # Section container
├── SectionHeader.tsx          # Section header
├── DealCard.tsx               # Individual deal card
├── DealCardCompact.tsx        # Condensed card variant
├── DealContextMenu.tsx        # Right-click menu
├── DealDetailPanel.tsx        # Slide-out detail panel
├── PipelineFilters.tsx        # Filter bar
├── AssignOwnerModal.tsx       # Owner assignment
├── CreateActionModal.tsx      # Quick action creation
└── index.ts                   # Exports
```

---

## Implementation Phases

### Phase 1: Core Layout (Week 1)
- [ ] PipelineView container
- [ ] PipelineSummary metrics
- [ ] SectionBreakdownBar
- [ ] PipelineSection grid
- [ ] Basic DealCard

### Phase 2: Interactions (Week 2)
- [ ] DealContextMenu
- [ ] Right-click handler
- [ ] Drag and drop
- [ ] Keyboard navigation

### Phase 3: Detail & Actions (Week 3)
- [ ] DealDetailPanel
- [ ] AssignOwnerModal
- [ ] CreateActionModal
- [ ] Section filtering

### Phase 4: Polish (Week 4)
- [ ] Micro-interactions
- [ ] Mobile responsiveness
- [ ] Accessibility audit
- [ ] Performance optimization

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Time to find deal | < 5 seconds |
| Actions per deal | 2 clicks max |
| Mobile usability | SUS score > 80 |
| Accessibility | WCAG 2.2 AA pass |
| Lighthouse Performance | > 90 |

---

*Document Version: 1.0*
*Created: 2026-01-05*
*Author: Claude Code*
