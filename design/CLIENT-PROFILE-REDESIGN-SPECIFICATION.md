# Client Profile Page - Design Specification v2.0

> **Purpose**: Figma-ready design specification for the modernised Client Profile page
> **Created**: 4 January 2026
> **Status**: Design Phase
> **Aligned to**: Linear, Notion, Stripe, Salesforce Lightning design patterns

---

## Table of Contents

1. [Design System Foundations](#1-design-system-foundations)
2. [Page Layout Architecture](#2-page-layout-architecture)
3. [Component Specifications](#3-component-specifications)
4. [Responsive Breakpoints](#4-responsive-breakpoints)
5. [Animation & Micro-interactions](#5-animation--micro-interactions)
6. [Accessibility Requirements](#6-accessibility-requirements)
7. [Figma Component Library Structure](#7-figma-component-library-structure)

---

## 1. Design System Foundations

### 1.1 Colour Palette

#### Primary Colours
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `--brand-purple-50` | #F5F3FF | 245, 243, 255 | Light backgrounds |
| `--brand-purple-100` | #EDE9FE | 237, 233, 254 | Hover states |
| `--brand-purple-500` | #8B5CF6 | 139, 92, 246 | Secondary accent |
| `--brand-purple-600` | #7C3AED | 124, 58, 237 | Primary brand |
| `--brand-purple-700` | #6D28D9 | 109, 40, 217 | Pressed states |

#### Semantic Colours
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `--success-50` | #ECFDF5 | 236, 253, 245 | Success backgrounds |
| `--success-500` | #10B981 | 16, 185, 129 | Healthy status |
| `--success-600` | #059669 | 5, 150, 105 | Healthy text |
| `--warning-50` | #FFFBEB | 255, 251, 235 | Warning backgrounds |
| `--warning-500` | #F59E0B | 245, 158, 11 | At-risk status |
| `--warning-600` | #D97706 | 217, 119, 6 | At-risk text |
| `--danger-50` | #FEF2F2 | 254, 242, 242 | Danger backgrounds |
| `--danger-500` | #EF4444 | 239, 68, 68 | Critical status |
| `--danger-600` | #DC2626 | 220, 38, 38 | Critical text |

#### Neutral Colours
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `--neutral-50` | #F9FAFB | 249, 250, 251 | Page background |
| `--neutral-100` | #F3F4F6 | 243, 244, 246 | Card hover |
| `--neutral-200` | #E5E7EB | 229, 231, 235 | Borders |
| `--neutral-300` | #D1D5DB | 209, 213, 219 | Disabled borders |
| `--neutral-400` | #9CA3AF | 156, 163, 175 | Placeholder text |
| `--neutral-500` | #6B7280 | 107, 114, 128 | Secondary text |
| `--neutral-600` | #4B5563 | 75, 85, 99 | Tertiary text |
| `--neutral-700` | #374151 | 55, 65, 81 | Labels |
| `--neutral-800` | #1F2937 | 31, 41, 55 | Headings |
| `--neutral-900` | #111827 | 17, 24, 39 | Primary text |
| `--white` | #FFFFFF | 255, 255, 255 | Card backgrounds |

### 1.2 Typography Scale

**Font Family**: Inter (Primary), SF Pro Display (Fallback), System UI

| Token | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| `--text-display` | 36px | 700 | 40px (1.11) | -0.02em | Page titles |
| `--text-h1` | 28px | 700 | 34px (1.21) | -0.02em | Client name |
| `--text-h2` | 20px | 600 | 28px (1.4) | -0.01em | Section headers |
| `--text-h3` | 16px | 600 | 24px (1.5) | 0 | Card titles |
| `--text-body` | 15px | 400 | 24px (1.6) | 0 | Body text |
| `--text-body-sm` | 14px | 400 | 20px (1.43) | 0 | Secondary body |
| `--text-caption` | 12px | 500 | 16px (1.33) | 0.02em | Captions, labels |
| `--text-overline` | 11px | 600 | 16px (1.45) | 0.08em | Overline text |
| `--text-metric-lg` | 48px | 700 | 52px (1.08) | -0.02em | Large KPIs |
| `--text-metric-md` | 32px | 700 | 36px (1.13) | -0.02em | Medium KPIs |
| `--text-metric-sm` | 24px | 600 | 28px (1.17) | -0.01em | Small KPIs |

### 1.3 Spacing Scale

Based on 4px base unit:

| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Inline spacing, icon gaps |
| `--space-2` | 8px | Tight padding |
| `--space-3` | 12px | Card internal padding |
| `--space-4` | 16px | Standard padding |
| `--space-5` | 20px | Medium gaps |
| `--space-6` | 24px | Section spacing |
| `--space-8` | 32px | Large gaps |
| `--space-10` | 40px | Section dividers |
| `--space-12` | 48px | Major section breaks |
| `--space-16` | 64px | Page margins |

### 1.4 Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `--radius-sm` | 4px | Small buttons, badges |
| `--radius-md` | 8px | Cards, inputs |
| `--radius-lg` | 12px | Large cards, modals |
| `--radius-xl` | 16px | Hero sections |
| `--radius-2xl` | 24px | Feature cards |
| `--radius-full` | 9999px | Pills, avatars |

### 1.5 Shadow System

| Token | Value | Usage |
|-------|-------|-------|
| `--shadow-xs` | 0 1px 2px rgba(0,0,0,0.05) | Subtle elevation |
| `--shadow-sm` | 0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06) | Cards |
| `--shadow-md` | 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06) | Dropdowns |
| `--shadow-lg` | 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05) | Modals |
| `--shadow-xl` | 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04) | Popovers |
| `--shadow-hover` | 0 8px 16px -4px rgba(124,58,237,0.15) | Card hover (with brand tint) |
| `--shadow-glow-success` | 0 0 20px rgba(16,185,129,0.3) | Health glow |
| `--shadow-glow-warning` | 0 0 20px rgba(245,158,11,0.3) | Warning glow |
| `--shadow-glow-danger` | 0 0 20px rgba(239,68,68,0.3) | Critical glow |

---

## 2. Page Layout Architecture

### 2.1 Bento Grid Layout

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                           STICKY HEADER (64px)                                  │
│  [←] Client Profiles / Grampians Health          [ChaSen] [Share] [Export]     │
├────────────────────────────────────────────────────────────────────────────────┤
│                           HERO SECTION (200px)                                  │
│  ┌─────────┐  Grampians Health                                                 │
│  │  LOGO   │  Giant • Victoria • Active                    ┌─────────────────┐ │
│  │  80x80  │                                               │  HEALTH GAUGE   │ │
│  └─────────┘  CSE: Dimitri Leimonitis                      │      78         │ │
│               Last Contact: 2 days ago                     │     /100        │ │
│                                                            └─────────────────┘ │
├────────────────────────────────────────────────────────────────────────────────┤
│                           ACTION BAR (48px)                                     │
│  [All ▼] [Actions ▼] [Meetings] [Notes]     Sort: [Date ▼]    [+ New Action]   │
├─────────────────────────┬──────────────────────────────────┬───────────────────┤
│   LEFT COLUMN (360px)   │      CENTRE COLUMN (Flex)        │ RIGHT COL (380px) │
│                         │                                   │                   │
│  ┌───────────────────┐  │  ┌─────────────────────────────┐  │ ┌───────────────┐ │
│  │   NPS CARD        │  │  │        TODAY                │  │ │   TABS        │ │
│  │   ┌─────────┐     │  │  │                             │  │ │ Overview|Team │ │
│  │   │  DONUT  │ +67 │  │  │  ┌───────────────────────┐  │  │ │ Insights|Notes│ │
│  │   └─────────┘     │  │  │  │ ▌ Action Card         │  │  │ └───────────────┘ │
│  │   12P 5N 2D       │  │  │  │   Review contract     │  │  │                   │
│  └───────────────────┘  │  │  │   [In Progress ▼]     │  │  │ ┌───────────────┐ │
│                         │  │  └───────────────────────┘  │  │ │ AI INSIGHTS   │ │
│  ┌───────────────────┐  │  │                             │  │ │               │ │
│  │   COMPLIANCE      │  │  │  ┌───────────────────────┐  │  │ │ ⚠ Risk:       │ │
│  │   ████████░░ 82%  │  │  │  │ ▌ Meeting Card        │  │  │ │ Compliance    │ │
│  │   8/10 events     │  │  │  │   QBR @ 10:00 AM      │  │  │ │ may slip...   │ │
│  │   [View Details]  │  │  │  │   [Completed ▼]       │  │  │ │               │ │
│  └───────────────────┘  │  │  └───────────────────────┘  │  │ │ 💡 Recommend: │ │
│                         │  │                             │  │ │ Schedule...   │ │
│  ┌───────────────────┐  │  │        YESTERDAY           │  │ └───────────────┘ │
│  │   FINANCIAL       │  │  │                             │  │                   │
│  │   HEALTH          │  │  │  ┌───────────────────────┐  │  │ ┌───────────────┐ │
│  │   ┌─────────────┐ │  │  │  │ ▌ Note Card           │  │  │ │ TEAM          │ │
│  │   │ STACKED BAR │ │  │  │  │   Client feedback...  │  │  │ │               │ │
│  │   └─────────────┘ │  │  │  │   by Sarah            │  │  │ │ ●─●─● CSE     │ │
│  │   $125,000 total  │  │  │  └───────────────────────┘  │  │ │ Dimitri L.    │ │
│  │   ✓ Meets goals   │  │  │                             │  │ │               │ │
│  └───────────────────┘  │  │        THIS WEEK            │  │ │ Stakeholders  │ │
│                         │  │                             │  │ │ John Smith    │ │
│  ┌───────────────────┐  │  │  ┌───────────────────────┐  │  │ │ Jane Doe      │ │
│  │   SEGMENT         │  │  │  │ ...more items         │  │  │ │ [+ Add]       │ │
│  │   INFO            │  │  │  └───────────────────────┘  │  │ └───────────────┘ │
│  │   Giant → Giant   │  │  │                             │  │                   │
│  │   No change       │  │  │                             │  │ ┌───────────────┐ │
│  └───────────────────┘  │  │                             │  │ │ PRODUCTS      │ │
│                         │  │                             │  │ │ Opal ▪ PAS    │ │
│                         │  │                             │  │ └───────────────┘ │
└─────────────────────────┴──────────────────────────────────┴───────────────────┘
```

### 2.2 Grid Specifications

| Region | Width | Behaviour |
|--------|-------|-----------|
| **Container** | max-width: 1920px | Centred, with 24px side padding |
| **Left Column** | 360px fixed | Sticky at top: 88px (header height) |
| **Centre Column** | Flex (min 400px) | Scrollable, main content |
| **Right Column** | 380px fixed | Sticky at top: 88px |
| **Gap** | 24px | Between all columns |

---

## 3. Component Specifications

### 3.1 Sticky Header

```
┌────────────────────────────────────────────────────────────────┐
│  Height: 64px                                                   │
│  Background: rgba(255,255,255,0.85)                            │
│  Backdrop-filter: blur(12px)                                   │
│  Border-bottom: 1px solid var(--neutral-200)                   │
│  Position: sticky, top: 0, z-index: 40                         │
├────────────────────────────────────────────────────────────────┤
│  ┌────┐                                                        │
│  │ ←  │  Client Profiles / Grampians Health                    │
│  └────┘  ↑ 40x40px button                                      │
│          Breadcrumb: 14px, --neutral-500                       │
│          Client name: 16px, 600, --neutral-900                 │
│                                                                │
│                              [ChaSen] [Share] [Export]         │
│                              ↑ 36px height buttons             │
│                              Gap: 8px                          │
└────────────────────────────────────────────────────────────────┘
```

**States:**
- **Default**: Full height, all elements visible
- **Scrolled (>100px)**: Reduce to 56px, hide breadcrumb, show compact name

### 3.2 Hero Section

```
┌────────────────────────────────────────────────────────────────┐
│  Height: 200px                                                  │
│  Background: linear-gradient(135deg, --purple-50, --white)     │
│  Padding: 32px                                                 │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌────────┐   CLIENT NAME                        ┌──────────┐  │
│  │  LOGO  │   36px, 700 weight                  │ HEALTH   │  │
│  │ 80x80  │                                     │  GAUGE   │  │
│  │ radius │   ┌─────────┐ ┌─────────┐           │          │  │
│  │  12px  │   │ Giant   │ │Victoria │           │   78     │  │
│  └────────┘   └─────────┘ └─────────┘           │  /100    │  │
│               Segment      State badge           │          │  │
│               24px pill    24px pill             │  140px   │  │
│                                                  │  diameter│  │
│  CSE: Dimitri Leimonitis                        └──────────┘  │
│  14px, --neutral-500                                          │
│  Last contact: 2 days ago                                     │
│  12px, --neutral-400                                          │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### 3.3 Health Score Radial Gauge

```
                    ┌─────────────────────┐
                    │   RADIAL GAUGE      │
                    │                     │
                    │   Diameter: 140px   │
                    │   Stroke: 12px      │
                    │                     │
         Progress   │      ╭─────────╮    │
         Track      │    ╱ ▓▓▓▓▓▓▓▓▓ ╲   │   ▓ = Filled (gradient)
         (grey)     │   │  ▓▓▓▓▓▓▓▓▓  │   │   ░ = Empty (neutral-200)
                    │   │  ▓▓  78  ▓▓  │   │
         Score      │   │  ▓▓▓▓▓▓▓▓▓  │   │   Score: 48px, 700 weight
         Text       │    ╲ ▓▓▓▓░░░░░ ╱   │   /100: 14px, 400, neutral-400
                    │      ╰─────────╯    │
                    │                     │
                    │   ┌─────────────┐   │   Sparkline: 80px × 24px
                    │   │ ↗ +5 trend  │   │   Shows 90-day trend
                    │   └─────────────┘   │   Green if positive
                    │                     │
                    └─────────────────────┘
```

**Colour Gradient Based on Score:**
- **0-49 (Critical)**: `linear-gradient(135deg, #EF4444, #DC2626)`
- **50-69 (At-Risk)**: `linear-gradient(135deg, #F59E0B, #D97706)`
- **70-100 (Healthy)**: `linear-gradient(135deg, #10B981, #059669)`

**Glow Effect:**
- Apply `box-shadow: var(--shadow-glow-{status})` to create ambient glow

### 3.4 NPS Donut Chart Card

```
┌─────────────────────────────────────────┐
│  Padding: 20px                          │
│  Background: white                      │
│  Border-radius: 12px                    │
│  Border: 1px solid var(--neutral-200)   │
├─────────────────────────────────────────┤
│                                         │
│  NPS Score                              │  Label: 12px, 500, neutral-500
│                                         │
│  ┌───────────────┐                      │
│  │               │   ┌───────────────┐  │
│  │    DONUT      │   │    +67        │  │  Score: 32px, 700
│  │   ╭─────╮     │   │   Promoter    │  │  Status: 14px, 500, success-600
│  │  ╱ ▓▓▓▓▓ ╲    │   └───────────────┘  │
│  │ │ ▓▓   ▓▓ │   │                      │  Donut: 100px diameter
│  │ │ ▓▓ P ▓▓ │   │   Promoters: 12      │  Stroke: 16px
│  │  ╲ ░░░░░ ╱    │   Passives: 5        │
│  │   ╰─────╯     │   Detractors: 2      │  Legend: 13px, 400
│  └───────────────┘                      │
│                                         │
│  ▓ Promoters (63%)                      │  Inline legend below
│  ░ Passives (26%)                       │  with colour dots
│  ▪ Detractors (11%)                     │
│                                         │
└─────────────────────────────────────────┘
```

**Donut Segments:**
- **Promoters**: `#10B981` (success-500)
- **Passives**: `#9CA3AF` (neutral-400)
- **Detractors**: `#EF4444` (danger-500)

**Hover Interaction:**
- Segment expands outward by 4px
- Tooltip shows exact count and percentage

### 3.5 Compliance Progress Card

```
┌─────────────────────────────────────────┐
│  Event Compliance                       │  Label: 12px, 500, neutral-500
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ ████████████████████░░░░░░░░░░░ │    │  Progress bar: height 8px
│  └─────────────────────────────────┘    │  radius: 4px
│  ↑ 82% complete                         │
│                                         │
│  ┌─────┐  82%        8 of 10 events     │  Score: 24px, 700
│  │ ✓   │  On Track   completed          │  Status: 13px, 500, success-600
│  └─────┘                                │  Details: 13px, 400, neutral-500
│                                         │
│  [View Detailed Breakdown →]            │  Link: 13px, 500, purple-600
│                                         │
└─────────────────────────────────────────┘
```

### 3.6 Financial Health Stacked Bar

```
┌─────────────────────────────────────────┐
│  Working Capital                        │  Label: 12px, 500, neutral-500
│                                         │
│  $125,000 Outstanding                   │  Total: 20px, 700
│                                         │
│  ┌─────────────────────────────────┐    │  Stacked bar: height 24px
│  │ ▓▓▓▓▓▓▓▓▓▓▓▓░░░░▒▒▒▒▒▓▓▓▓▓▓    │    │  radius: 6px
│  └─────────────────────────────────┘    │
│  ↑ Current   ↑ 1-30  ↑ 31-60  ↑ 61+    │  Segments labelled on hover
│                                         │
│  ┌──────────────────┐ ┌────────────────┐│
│  │ ✓ 90% < 60 days  │ │ ✓ 100% < 90d  ││  Status pills: 28px height
│  │   (target: 90%)  │ │   (target)    ││  Green if met, amber if not
│  └──────────────────┘ └────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

**Bar Segment Colours:**
| Bucket | Colour | Meaning |
|--------|--------|---------|
| Current | `#10B981` | On time |
| 1-30 days | `#34D399` | Acceptable |
| 31-60 days | `#FBBF24` | Attention |
| 61-90 days | `#F59E0B` | Warning |
| 91+ days | `#EF4444` | Critical |

### 3.7 Timeline Activity Card

```
┌─────────────────────────────────────────────────────────────────┐
│  Height: Auto (min 80px)                                         │
│  Background: white                                               │
│  Border-radius: 12px                                             │
│  Border: 1px solid var(--neutral-200)                           │
│  Border-left: 4px solid {type-colour}                           │
│  Padding: 16px                                                   │
│  Transition: all 200ms ease-out                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────┐  Action Title Here                      ┌───┐          │
│  │ 🎯  │  15px, 600 weight                       │ ⋮ │          │  Icon: 36px container
│  │     │                                         └───┘          │  Title: 15px, 600
│  └─────┘  Assigned to: Dimitri • Due: 15 Jan                    │  Meta: 13px, neutral-500
│           13px, neutral-500                                      │
│                                                                  │
│  Optional description text goes here. This can wrap              │  Description: 14px, neutral-600
│  to multiple lines if needed. Max 2 lines with...               │  Line clamp: 2
│                                                                  │
│  ┌──────────────┐  ┌────────┐                    ┌────┐ ┌────┐  │
│  │ In Progress ▼│  │ High   │                    │ ✎ │ │ 🗑 │  │  Status: dropdown, 28px
│  └──────────────┘  └────────┘                    └────┘ └────┘  │  Priority: pill, 24px
│  ↑ Inline status   ↑ Priority                    ↑ Quick actions│  Actions: 32px buttons
│    dropdown          badge                         (on hover)   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Type Colours (left border):**
| Type | Colour |
|------|--------|
| Action | `#7C3AED` (purple-600) |
| Meeting | `#3B82F6` (blue-500) |
| Note | `#10B981` (success-500) |
| Email | `#6366F1` (indigo-500) |

**Hover State:**
- `transform: translateY(-2px)`
- `box-shadow: var(--shadow-hover)`
- Quick action buttons fade in (opacity 0 → 1)

### 3.8 AI Insight Card

```
┌─────────────────────────────────────────┐
│  Background: linear-gradient(           │
│    135deg,                              │
│    var(--warning-50),                   │
│    var(--white)                         │
│  )                                       │
│  Border-radius: 12px                    │
│  Border: 1px solid var(--warning-200)   │
│  Padding: 16px                          │
├─────────────────────────────────────────┤
│                                         │
│  ⚠️  Compliance Risk                    │  Icon: 20px
│      14px, 600, warning-700             │  Title: 14px, 600
│                                         │
│  Client may miss Q1 compliance target   │  Body: 14px, 400, neutral-700
│  based on current event velocity.       │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ Confidence: ████████░░ 78%     │    │  Progress bar: 6px height
│  └─────────────────────────────────┘    │
│                                         │
│  ┌────────────────┐  ┌─────────────┐    │
│  │ Create Action  │  │   Dismiss   │    │  Buttons: 32px height
│  └────────────────┘  └─────────────┘    │  Primary + Ghost style
│                                         │
└─────────────────────────────────────────┘
```

**Variants:**
- **Risk**: Warning gradient, amber border, ⚠️ icon
- **Opportunity**: Blue gradient, blue border, 💡 icon
- **Prediction**: Purple gradient, purple border, ✨ icon

### 3.9 Team Member Avatar Stack

```
┌─────────────────────────────────────────┐
│  Team                                   │  Label: 12px, 500, neutral-500
│                                         │
│  ┌───┬───┬───┬───┐                      │  Avatar stack:
│  │ D │ S │ J │+2 │    CSE: Dimitri L.   │  - 36px diameter each
│  └───┴───┴───┴───┘    Last: 2 days ago  │  - -8px overlap
│  ↑ Avatar stack        ↑ Details        │  - 2px white border
│    Max 4 visible                        │  - +N counter for overflow
│                                         │
│  [Click to expand team list]            │
│                                         │
└─────────────────────────────────────────┘
```

**Online Indicator:**
- 10px diameter green dot
- Position: bottom-right of avatar
- Border: 2px solid white
- Animation: subtle pulse (opacity 0.7 → 1)

---

## 4. Responsive Breakpoints

### 4.1 Breakpoint Definitions

| Name | Range | Layout |
|------|-------|--------|
| **Mobile** | 0 - 767px | Single column, stacked |
| **Tablet** | 768 - 1023px | Two columns |
| **Desktop** | 1024 - 1439px | Three columns, compact |
| **Wide** | 1440 - 1919px | Three columns, standard |
| **Ultrawide** | 1920px+ | Three columns, max-width container |

### 4.2 Mobile Layout (< 768px)

```
┌────────────────────────────┐
│   HEADER (56px, sticky)    │
│   [←] Grampians [Share]    │
├────────────────────────────┤
│   HEALTH GAUGE (100px)     │
│        ╭─────╮             │
│       │  78  │             │
│        ╰─────╯             │
├────────────────────────────┤
│   SEGMENTED CONTROL        │
│   [Profile][Activity][Info]│
├────────────────────────────┤
│                            │
│   SELECTED TAB CONTENT     │
│   (Scrollable)             │
│                            │
│   NPS Card (full width)    │
│   Compliance Card          │
│   Financial Card           │
│   Timeline Cards           │
│                            │
├────────────────────────────┤
│   FLOATING ACTION BUTTON   │
│              [+]           │
└────────────────────────────┘
```

**Mobile-Specific Rules:**
- Header shrinks to 56px
- Hero section replaced with compact health gauge (100px)
- Segmented control for tab switching
- All cards stack vertically, full width
- Touch targets minimum 48×48px
- Bottom sheet modals instead of side drawers
- FAB for primary action (+ New Action)

### 4.3 Tablet Layout (768 - 1023px)

```
┌───────────────────────────────────────┐
│            HEADER (64px)              │
├────────────────┬──────────────────────┤
│   LEFT (280px) │   CENTRE (Flex)      │
│                │                      │
│   Health Gauge │   Activity Timeline  │
│   NPS Card     │                      │
│   Compliance   │   Cards scroll       │
│   Financial    │   independently      │
│                │                      │
└────────────────┴──────────────────────┘
```

**Tablet-Specific Rules:**
- Right column hidden (accessed via tabs in header)
- Left column fixed at 280px
- Centre column takes remaining space
- Team/Insights accessible via header dropdown

---

## 5. Animation & Micro-interactions

### 5.1 Timing Functions

| Name | Value | Usage |
|------|-------|-------|
| `--ease-out` | cubic-bezier(0, 0, 0.2, 1) | Most transitions |
| `--ease-in-out` | cubic-bezier(0.4, 0, 0.2, 1) | Modals, drawers |
| `--ease-bounce` | cubic-bezier(0.68, -0.55, 0.265, 1.55) | Playful elements |
| `--spring` | cubic-bezier(0.175, 0.885, 0.32, 1.275) | Success states |

### 5.2 Duration Scale

| Token | Value | Usage |
|-------|-------|-------|
| `--duration-fast` | 100ms | Hover states, color changes |
| `--duration-normal` | 200ms | Standard transitions |
| `--duration-slow` | 300ms | Complex transitions |
| `--duration-slower` | 500ms | Modals, page transitions |

### 5.3 Animation Specifications

#### Card Hover
```css
.card {
  transition: transform var(--duration-normal) var(--ease-out),
              box-shadow var(--duration-normal) var(--ease-out);
}
.card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-hover);
}
```

#### Button Press
```css
.button:active {
  transform: scale(0.98);
  transition: transform var(--duration-fast) var(--ease-out);
}
```

#### Skeleton Loading
```css
@keyframes skeleton-pulse {
  0%, 100% { opacity: 0.5; }
  50% { opacity: 1; }
}
.skeleton {
  background: linear-gradient(90deg, var(--neutral-200), var(--neutral-100), var(--neutral-200));
  background-size: 200% 100%;
  animation: skeleton-pulse 1.5s ease-in-out infinite;
}
```

#### Health Gauge Fill
```css
@keyframes gauge-fill {
  from { stroke-dashoffset: 440; } /* Full circumference */
  to { stroke-dashoffset: calc(440 - (440 * var(--score) / 100)); }
}
.gauge-progress {
  animation: gauge-fill 1s var(--ease-out) forwards;
  animation-delay: 300ms;
}
```

#### Status Change Success
```css
@keyframes status-success {
  0% { background-color: var(--success-500); transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { background-color: var(--success-100); transform: scale(1); }
}
```

### 5.4 Scroll-Triggered Animations

#### Sticky Header Shrink
```javascript
// Trigger at scroll > 100px
const scrolled = window.scrollY > 100;
header.classList.toggle('header--compact', scrolled);

// CSS
.header { height: 64px; transition: height var(--duration-slow) var(--ease-out); }
.header--compact { height: 56px; }
.header--compact .breadcrumb { opacity: 0; height: 0; }
```

#### Lazy Load Fade-Up
```css
.card[data-animate] {
  opacity: 0;
  transform: translateY(20px);
}
.card[data-animate].visible {
  opacity: 1;
  transform: translateY(0);
  transition: opacity var(--duration-slow), transform var(--duration-slow);
  transition-timing-function: var(--ease-out);
}
```

---

## 6. Accessibility Requirements

### 6.1 WCAG 2.1 AA Compliance

| Requirement | Implementation |
|-------------|----------------|
| **Colour Contrast** | All text: minimum 4.5:1 ratio |
| **Focus Indicators** | 2px solid var(--brand-purple-600) outline |
| **Touch Targets** | Minimum 44×44px on mobile |
| **Keyboard Navigation** | Full tab order, arrow keys in components |
| **Screen Readers** | ARIA labels on all interactive elements |
| **Reduced Motion** | Respect `prefers-reduced-motion` |

### 6.2 Focus States

```css
:focus-visible {
  outline: 2px solid var(--brand-purple-600);
  outline-offset: 2px;
  border-radius: var(--radius-sm);
}

/* Remove default browser outline */
:focus:not(:focus-visible) {
  outline: none;
}
```

### 6.3 ARIA Patterns

#### Health Gauge
```html
<div role="meter"
     aria-label="Health Score"
     aria-valuenow="78"
     aria-valuemin="0"
     aria-valuemax="100"
     aria-valuetext="78 out of 100, healthy">
```

#### Tabs
```html
<div role="tablist" aria-label="Client sections">
  <button role="tab" aria-selected="true" aria-controls="panel-overview">Overview</button>
  <button role="tab" aria-selected="false" aria-controls="panel-team">Team</button>
</div>
<div id="panel-overview" role="tabpanel" aria-labelledby="tab-overview">
```

#### Timeline
```html
<ol role="feed" aria-label="Client activity timeline" aria-busy="false">
  <li role="article" aria-labelledby="item-1-title" aria-describedby="item-1-desc">
```

### 6.4 Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }

  .gauge-progress {
    animation: none;
    stroke-dashoffset: calc(440 - (440 * var(--score) / 100));
  }
}
```

---

## 7. Figma Component Library Structure

### 7.1 Page Structure

```
📁 Client Profile Redesign
├── 📄 Cover
├── 📄 Design Tokens
│   ├── Colours
│   ├── Typography
│   ├── Spacing
│   ├── Shadows
│   └── Radii
├── 📄 Components
│   ├── Atoms
│   │   ├── Buttons
│   │   ├── Badges
│   │   ├── Avatars
│   │   ├── Icons
│   │   └── Progress bars
│   ├── Molecules
│   │   ├── Card headers
│   │   ├── Metric displays
│   │   ├── Status pills
│   │   └── Action menus
│   └── Organisms
│       ├── Health Gauge
│       ├── NPS Donut Card
│       ├── Compliance Card
│       ├── Financial Health Card
│       ├── Timeline Card
│       ├── AI Insight Card
│       ├── Team Stack
│       └── Sticky Header
├── 📄 Layouts
│   ├── Desktop (1440px)
│   ├── Wide (1920px)
│   ├── Tablet (768px)
│   └── Mobile (375px)
├── 📄 States
│   ├── Loading (Skeleton)
│   ├── Empty
│   ├── Error
│   └── Success
├── 📄 Interactions
│   ├── Hover states
│   ├── Focus states
│   ├── Active states
│   └── Disabled states
└── 📄 Prototypes
    ├── Desktop flow
    ├── Mobile flow
    └── Micro-interactions
```

### 7.2 Component Variants

Each component should have the following variants in Figma:

| Variant | Properties |
|---------|------------|
| **State** | Default, Hover, Active, Focus, Disabled, Loading |
| **Size** | Small, Medium, Large |
| **Theme** | Light, Dark |
| **Status** | Success, Warning, Danger, Neutral |
| **Breakpoint** | Mobile, Tablet, Desktop |

### 7.3 Auto Layout Settings

| Component Type | Direction | Spacing | Padding |
|----------------|-----------|---------|---------|
| **Cards** | Vertical | 16px | 20px |
| **Button groups** | Horizontal | 8px | 0 |
| **Form fields** | Vertical | 8px | 0 |
| **Metric rows** | Horizontal | 16px | 0 |
| **Timeline** | Vertical | 12px | 0 |

---

## Appendix A: Implementation Checklist

### Phase 1: Foundation (Week 1-2)
- [ ] Set up design tokens in Figma variables
- [ ] Create colour palette with semantic naming
- [ ] Build typography scale
- [ ] Define spacing and shadow scales
- [ ] Create base component frame templates

### Phase 2: Atoms & Molecules (Week 2-3)
- [ ] Design button variants (6 states × 3 sizes)
- [ ] Create badge/pill components
- [ ] Build avatar with status indicator
- [ ] Design progress bar variants
- [ ] Create icon set (16px, 20px, 24px)

### Phase 3: Organisms (Week 3-4)
- [ ] Health Gauge component with animation spec
- [ ] NPS Donut Card with interactive states
- [ ] Compliance Progress Card
- [ ] Financial Health Stacked Bar
- [ ] Timeline Activity Card (4 type variants)
- [ ] AI Insight Card (3 type variants)
- [ ] Team Avatar Stack

### Phase 4: Layouts (Week 4-5)
- [ ] Desktop layout (1440px)
- [ ] Wide layout (1920px)
- [ ] Tablet layout (768px)
- [ ] Mobile layout (375px)
- [ ] Responsive behaviour documentation

### Phase 5: States & Interactions (Week 5-6)
- [ ] Loading/skeleton states for all cards
- [ ] Empty states with illustrations
- [ ] Error states
- [ ] Hover/focus state specifications
- [ ] Micro-interaction prototypes

### Phase 6: Handoff (Week 6)
- [ ] Developer handoff annotations
- [ ] CSS export for design tokens
- [ ] Component API documentation
- [ ] Accessibility audit checklist

---

## Appendix B: Design References

### Inspiration Sources
- **Linear** - Clean card layouts, subtle animations
- **Notion** - Bento grid, progressive disclosure
- **Stripe Dashboard** - Data visualisation, colour coding
- **Salesforce Lightning** - Enterprise patterns, accessibility
- **Figma** - Real-time collaboration UI

### Resources
- [Tailwind CSS Colour Palette](https://tailwindcss.com/docs/customizing-colors)
- [Inter Font Family](https://rsms.me/inter/)
- [Lucide Icons](https://lucide.dev/)
- [Radix UI Primitives](https://www.radix-ui.com/)

---

*Document Version: 2.0*
*Last Updated: 4 January 2026*
*Author: Claude Code*
