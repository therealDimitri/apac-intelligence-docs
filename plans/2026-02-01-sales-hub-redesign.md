# Sales Hub Redesign — Client-First Command Centre

**Date:** 2026-02-01
**Status:** Design Complete
**Author:** Claude + Jimmy Leimonitis

---

## Executive Summary

A complete reimagining of the Sales Hub, transforming it from a product catalogue into an intelligent, client-centric sales workspace. The redesign addresses four key pain points: information overload, lack of client context, poor discoverability, and disconnected workflows.

**Key Design Decisions:**

1. Client selector as primary navigation — everything contextualises to the selected client
2. AI companion as persistent sidebar — proactive suggestions without blocking workflow
3. Unified News Intelligence — alerts, articles, and tenders woven throughout
4. Product logos from BU assets — professional branding with SVG icons
5. Vercel/Stripe aesthetic — glass-morphism, gradients, premium micro-animations
6. Fully responsive — desktop panels → tablet collapsible → mobile bottom sheets

---

## User Research Summary

### User Roles
- CSEs (Client Success Executives) — managing existing relationships
- CAMs (Client Account Managers) — renewals and upsells
- Sales/Business Development — prospecting new clients
- Managers — overseeing team activity and pipeline

### Use Cases
1. **Browsing/Discovery** — learning what products are available
2. **Client Preparation** — finding materials for upcoming meetings
3. **Recommendation Execution** — acting on AI suggestions
4. **Prospecting** — identifying new clients to sell to

### Pain Points Addressed
| Pain Point | Solution |
|------------|----------|
| Information overload | Client context filters to relevant items only |
| Lack of client context | Every view shows "why this matters for {Client}" |
| Poor discoverability | Dashboard mode surfaces opportunities, trending products |
| Disconnected workflow | Single view: client → products → news → action |

### Device Requirements
- Desktop at desk (large screen, focused work)
- Laptop in meetings (presenting, preparing)
- Mobile/tablet (quick lookups on the go)

---

## Page Architecture

### Overall Layout (Two-Column Adaptive)

```
┌─────────────────────────────────────────────────────────────┐
│  Header: Client Selector + Search + Quick Actions           │
├─────────────────────────────────────────┬───────────────────┤
│                                         │                   │
│  Main Content Area                      │  AI Companion     │
│  (Client context, products,             │  Panel            │
│   recommendations, news)                │  (Contextual      │
│                                         │   suggestions,    │
│  Scrollable, responsive grid            │   chat, insights) │
│                                         │                   │
├─────────────────────────────────────────┴───────────────────┤
│  Action Bar: Pinned items, recent, bulk actions (sticky)    │
└─────────────────────────────────────────────────────────────┘
```

### Responsive Breakpoints
- **Desktop (1280px+):** Two columns, AI panel always visible (320px width)
- **Laptop (1024px):** Two columns, AI panel collapsible (icon toggle)
- **Tablet (768px):** Single column, AI panel becomes floating button → slide-up sheet
- **Mobile (<768px):** Single column, AI accessible via bottom nav icon

---

## Header & Client Selector

### Header Bar (sticky, 64px height)

**No client selected (default state):**
```
┌─────────────────────────────────────────────────────────────┐
│ [Store] Sales Hub   [Search clients, products, or ask AI...]│
│                                        [Quick Actions ▾] ⚙️ │
└─────────────────────────────────────────────────────────────┘
```

**Client selected:**
```
┌─────────────────────────────────────────────────────────────┐
│ ← Back   [Barwon Health ▾]  ● Healthy  $2.4M ARR  VIC/ANZ   │
│          [Search products...]           [+ Add to Plan] ⚙️  │
└─────────────────────────────────────────────────────────────┘
```

### Client Selector Dropdown (glass-morphism panel)

**Smart Sections:**
- "Recent clients" — last 5 viewed
- "Upcoming meetings" — clients with meetings in next 7 days
- "Needs attention" — at-risk or critical health
- "Your portfolio" — assigned clients grouped by region

**Each client row displays:**
- Name
- Health badge (colour-coded circle)
- ARR value
- Region
- Last interaction date

**Interactions:**
- Search input at top with keyboard shortcut hint (⌘K)
- Gradient hover states (purple-50 → purple-100)
- Click or keyboard select to choose

### Quick Actions Menu
- New recommendation
- Browse all products
- View my saved items
- Export to PDF

---

## Main Content — Dashboard Mode (No Client Selected)

When no client is selected, display an actionable dashboard:

```
┌─────────────────────────────────────────────────────────────┐
│  [Target] Top Opportunities                        View all →│
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐           │
│  │ Client  │ │ Client  │ │ Client  │ │ Client  │           │
│  │ Card    │ │ Card    │ │ Card    │ │ Card    │           │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘           │
├─────────────────────────────────────────────────────────────┤
│  [TrendingUp] Trending Products This Month         View all →│
│  ┌─────────┐ ┌─────────┐ ┌─────────┐                       │
│  │ Product │ │ Product │ │ Product │                       │
│  └─────────┘ └─────────┘ └─────────┘                       │
├─────────────────────────────────────────────────────────────┤
│  [Newspaper] Industry News                         View all →│
│  ┌─────────────────────────────────────────────────────────┐│
│  │ Compact news list with client mentions highlighted     ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### Top Opportunities Cards
- Clients with highest AI recommendation scores
- Shows: Client name, health status, top recommended product, match score (gradient ring)
- Hover: Glass card lifts with subtle shadow, "View recommendations" CTA appears
- Click: Selects that client, transitions to client view

### Trending Products
- Products most added to plans this month across the team
- Horizontal scroll on mobile, grid on desktop
- Shows: Product name, family badge, usage count sparkline

### Industry News
- Recent articles mentioning APAC healthcare, grouped by region
- Client mentions highlighted with pill badges
- Click article → modal reader; click client pill → selects client

---

## Main Content — Client Context Mode (Client Selected)

When a client is selected, the main area becomes a contextual workspace:

```
┌─────────────────────────────────────────────────────────────┐
│  [BarChart] Client Snapshot                            [−]  │
│  ┌──────────┬──────────┬──────────┬──────────┐             │
│  │ Health   │ NPS      │ ARR      │ Last     │             │
│  │ Score    │ Trend    │ Value    │ Meeting  │             │
│  │ ● 82     │ ↑ +12    │ $2.4M    │ 3 days   │             │
│  └──────────┴──────────┴──────────┴──────────┘             │
│                                                             │
│  Current Stack: [Sunrise EHR] [dbMotion] [Axon] +2 more    │
│                                                  View all → │
├─────────────────────────────────────────────────────────────┤
│  [Star] Recommended for Barwon Health          [Filter ▾]  │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ Product cards with match scores, evidence tags,        ││
│  │ "Why this?" expandable, Add to Plan button             ││
│  └─────────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────┤
│  [Package] Products They Don't Have (Stack Gaps)  View all →│
│  Horizontal scroll of product cards                         │
├─────────────────────────────────────────────────────────────┤
│  [Calendar] Upcoming & Recent Meetings            View all →│
│  Compact meeting list with extracted topics                 │
├─────────────────────────────────────────────────────────────┤
│  [Newspaper] News About Barwon Health             View all →│
│  Articles mentioning this client or their region            │
└─────────────────────────────────────────────────────────────┘
```

### Client Snapshot Bar
- Four metric cards with gradient backgrounds based on status
- Micro-sparklines for trends where applicable
- Click any metric → deep-links to relevant dashboard page
- Current Stack: Inline pill badges showing owned products (colour-coded by family)

### Recommended Products Section
- AI-scored recommendations with gradient score rings (0-100)
- Evidence tags: "Mentioned in meeting," "NPS keyword match," "Stack gap," "High ARR fit"
- Expandable "Why this?" accordion showing scoring breakdown
- Bulk select + "Add all to plan" action

---

## AI Companion Panel

Persistent right-hand panel providing contextual intelligence:

```
┌───────────────────────┐
│  [Sparkles] ChaSen AI │
│                  [−]  │
├───────────────────────┤
│  [Lightbulb]          │
│  Suggested Actions    │
│  ┌─────────────────┐  │
│  │ "Schedule QBR — │  │
│  │ last one was    │  │
│  │ 94 days ago"    │  │
│  │        [Do it →]│  │
│  └─────────────────┘  │
│  ┌─────────────────┐  │
│  │ "Discuss Thread │  │
│  │ AI — mentioned  │  │
│  │ in NPS feedback"│  │
│  │    [See details]│  │
│  └─────────────────┘  │
├───────────────────────┤
│  [MessageSquare]      │
│  Ask anything...      │
│  ┌─────────────────┐  │
│  │                 │  │
│  │  Chat input     │  │
│  │           [Send]│  │
│  └─────────────────┘  │
├───────────────────────┤
│  [FileText]           │
│  Recent Insights      │
│  • ARR grew 12% YoY   │
│  • 3 open support     │
│    cases              │
│  • Renewal in 47 days │
└───────────────────────┘
```

### Contextual Behaviour

| State | AI Panel Shows |
|-------|----------------|
| No client selected | "Select a client to get personalised suggestions" + trending insights |
| Client selected | Proactive suggestions based on client data, meeting history, NPS, health |
| Product hovered/selected | "Why this fits {Client}" explanation, objection handling tips |
| Building a plan | Checklist of talking points, gap analysis, meeting prep summary |

### Visual Treatment
- Subtle purple gradient background (purple-50/5 → transparent)
- Glass-morphism border with backdrop blur
- Suggestion cards have soft shadows and gradient hover states

### Mobile Behaviour
- Collapses to floating button (bottom-right, pulsing gradient border when new suggestions)
- Tap → slides up as bottom sheet (60% screen height)
- Swipe down to dismiss

---

## News Intelligence Integration

News Intelligence is a first-class citizen throughout, not a separate tab.

### Urgent News Banner (Global)

```
┌─────────────────────────────────────────────────────────────┐
│ [AlertTriangle] 2 Urgent Alerts: "SA Health RFP closes in  │
│                  3 days" +1                    [View All →] │
└─────────────────────────────────────────────────────────────┘
```

- Background: `bg-red-50` with `border-l-4 border-red-500`
- `AlertTriangle` icon in red-500
- Dismissible per-session, reappears for new alerts

### Client Card News Badge

```
┌─────────────────────────────────────────┐
│  [Building2] Barwon Health              │
│  [●] 82  [Newspaper] 3                  │
│  $2.4M ARR · VIC · Last: 3 days ago     │
└─────────────────────────────────────────┘
```

- News count badge shows articles matched to client
- Orange badge if any are "urgent_action" or "opportunity"

### Client Context Mode — News Section

```
┌─────────────────────────────────────────────────────────────┐
│  [Newspaper] News & Tenders for Barwon Health     View all →│
│  ┌─────────────────────────────────────────────────────────┐│
│  │ [AlertTriangle] URGENT                                 ││
│  │ "VIC Health tenders $12M EHR upgrade"                  ││
│  │ Closes: 14 Feb · Mentions: Sunrise, Epic               ││
│  │ AI: "High fit - client has Sunrise, expand scope"      ││
│  │                             [Track Tender] [Dismiss]   ││
│  ├─────────────────────────────────────────────────────────┤│
│  │ [TrendingUp] OPPORTUNITY                               ││
│  │ "Barwon CEO talks digital strategy"                    ││
│  │ 2 days ago · Stakeholder: Dr Sarah Chen (CEO)          ││
│  │ AI: "Schedule meeting - leadership aligned to IT"      ││
│  │                             [Create Action] [Dismiss]  ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### Data Sources Integration

| Source | Where it appears | How it's used |
|--------|------------------|---------------|
| NPS Responses | Client Snapshot, Evidence chips | Keywords match to product capabilities |
| Meeting Notes | Meetings section, Evidence chips | Topics extracted → matched to products |
| Health Score | Client Snapshot, Card sorting | At-risk clients surface recommendations |
| Support Cases | AI Companion insights, Evidence chips | Open cases → suggest relevant solutions |
| News Articles | News section, AI alerts, Evidence chips | Client mentions trigger alerts |
| Renewal Data | AI Companion, Client Snapshot | Approaching renewals trigger upsell recs |
| ARR & Financials | Client Snapshot, Recommendation scoring | High-value clients weighted in rankings |
| Stakeholder Data | Persona matching, AI talking points | CFO products matched to CFO contacts |

---

## Product & Bundle Cards (Redesigned)

### Product Card

```
┌─────────────────────────────────────────┐
│  ┌─────┐                                │
│  │[Sun]│  Sunrise Thread AI             │
│  │.svg │  ─────────────────────         │
│  └─────┘  [Sunrise] [AI/ML]             │
│                                         │
│  Native documentation assistant built   │
│  directly into the EHR...               │
│                                         │
│  Why this for Barwon Health:            │
│  • Mentioned "documentation burden"     │
│    in Q4 NPS feedback                   │
│  • 3 support cases about manual notes   │
│  • Recent news: "AI adoption in VIC"    │
│  • CFO stakeholder → ROI messaging      │
│                                         │
│  ┌────────────────────────────────────┐ │
│  │ [Target] 92% │ Stack gap │ NPS fit │ │
│  └────────────────────────────────────┘ │
│                                         │
│  [Globe] APAC  UK  EMEA  +2             │
│                         [+ Add to Plan] │
└─────────────────────────────────────────┘
```

### Product Logos (BU Assets)

| Product Family | Logo File |
|----------------|-----------|
| Sunrise | `Altera-App-Icon_Sun.svg` |
| dbMotion | `Altera-App-Icon_dbM.svg` |
| Opal | `Altera-App-Icon_Opal.svg` |
| Paragon | `Altera-App-Icon_Par-1.svg` |
| TouchWorks | `Altera-App-Icon_TW.svg` |
| Clinical Documentation | `Altera-App-Icon_CD.svg` |
| Clinical Flex | `Altera-App-Icons_CFX.png` |

### Visual Enhancements
- **Match score ring:** Gradient arc (purple → green) showing 0-100
- **Product family icon:** Custom logos in coloured circle
- **Evidence chips:** Small pills showing why it's recommended
- **Hover state:** Card lifts (translateY -2px), shadow deepens, gradient border
- **Selected state:** Purple gradient left border (4px), background tint

### Progressive Disclosure (on expand)
- Full description
- Key value propositions (3 bullets)
- Target personas with coloured avatars
- "View full details" → opens detail panel

---

## Action Bar (Sticky Bottom)

```
┌─────────────────────────────────────────────────────────────┐
│  [Bookmark] 3 Saved  [Clock] 5 Recent  │  Selection: 2 items│
│                                        │  [Add to Plan] [Share] [Export] │
└─────────────────────────────────────────────────────────────┘
```

### Visual Treatment
- Frosted glass: `backdrop-blur-xl bg-white/80`
- Subtle top border: `border-t border-gray-200/50`
- Shadow upward: `shadow-[0_-4px_20px_rgba(0,0,0,0.08)]`

### Left Section — Quick Access
| Element | Icon | Behaviour |
|---------|------|-----------|
| Saved Items | `Bookmark` | Popover showing bookmarked items |
| Recent | `Clock` | Popover showing last 10 viewed |
| Pinned Clients | `Pin` | Quick-switch between pinned clients |

### Right Section — Contextual Actions

| State | Actions Shown |
|-------|---------------|
| Nothing selected | Greyed out placeholder |
| 1+ products selected | `[Add to Plan]` `[Compare]` `[Share]` |
| 1+ tenders selected | `[Track]` `[Assign to Me]` `[Export]` |
| Client + products | `[Add to Plan for {Client}]` `[Create Meeting]` |

### Selection Behaviour
- Checkbox on card hover (top-left)
- Shift+click for range select
- Selected cards: `ring-2 ring-purple-500/50`
- Count badge updates with scale animation

---

## Mobile & Tablet Responsive Design

### Tablet (768px - 1024px)

```
┌─────────────────────────────────────────┐
│  Header: Client selector (full width)   │
│  [Search...]           [Filter] [AI]    │
├─────────────────────────────────────────┤
│                                         │
│  Main Content (single column)           │
│  Cards stack vertically                 │
│  2-column grid for smaller cards        │
│                                         │
├─────────────────────────────────────────┤
│  Action Bar (sticky bottom)             │
└─────────────────────────────────────────┘
```

AI Panel: Tap [AI] button → slides in from right (80% width)

### Mobile (<768px)

```
┌─────────────────────────────────────────┐
│  Sales Hub              [Filter] [···]  │
│  [Select Client ▾]                      │
├─────────────────────────────────────────┤
│                                         │
│  Vertical card stack                    │
│  Swipe left → quick actions             │
│  Pull to refresh                        │
│                                         │
├─────────────────────────────────────────┤
│  [Home] [Search] [AI] [Saved] [More]    │
└─────────────────────────────────────────┘
```

### Mobile Gestures

| Gesture | Action |
|---------|--------|
| Tap client selector | Full-screen modal with search |
| Swipe card left | Reveal: `[Add to Plan]` `[Save]` `[Share]` |
| Swipe card right | Dismiss/hide from view |
| Long-press card | Enter multi-select mode |
| Tap AI button | Bottom sheet (60% height) |
| Pull down | Refresh content |

### Bottom Navigation
- `Home` → Dashboard mode
- `Search` → Focus search input
- `Sparkles` → AI companion sheet
- `Bookmark` → Saved items sheet
- `MoreHorizontal` → Settings, export, help

### Card Adaptations
- Product logo: 24px (vs 32px desktop)
- Description: truncated to 2 lines
- Match score: small badge, not full ring
- Evidence chips: hidden, shown on expand
- Touch targets: minimum 44px

---

## Visual Design System

### Colour Palette

| Token | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| `--bg-primary` | `#FFFFFF` | `#0A0A0B` | Page background |
| `--bg-secondary` | `#FAFAFA` | `#141415` | Card backgrounds |
| `--bg-tertiary` | `#F4F4F5` | `#1F1F23` | Hover states |
| `--accent-primary` | `#7C3AED` | `#A78BFA` | Primary actions |
| `--accent-gradient` | `purple-600 → violet-500` | `purple-400 → violet-400` | CTAs |
| `--success` | `#10B981` | `#34D399` | Healthy |
| `--warning` | `#F59E0B` | `#FBBF24` | At-risk |
| `--error` | `#EF4444` | `#F87171` | Critical |
| `--text-primary` | `#18181B` | `#FAFAFA` | Headings |
| `--text-secondary` | `#52525B` | `#A1A1AA` | Body text |
| `--text-tertiary` | `#A1A1AA` | `#71717A` | Captions |

### Glass-Morphism Effects

```css
/* AI Companion Panel */
.glass-panel {
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
}

/* Action Bar */
.glass-bar {
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(16px);
  border-top: 1px solid rgba(0, 0, 0, 0.05);
}

/* Dropdown Menus */
.glass-dropdown {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(12px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.12);
}
```

### Gradient Treatments

| Element | Gradient |
|---------|----------|
| Primary CTA buttons | `bg-gradient-to-r from-purple-600 to-violet-500` |
| Match score rings | `conic-gradient` purple-600 → emerald-500 |
| Urgent alert banner | `bg-gradient-to-r from-red-50 to-orange-50` |
| Card hover glow | `shadow-[0_0_20px_rgba(124,58,237,0.15)]` |

### Typography Scale

| Element | Size | Weight | Tracking |
|---------|------|--------|----------|
| Page title | 24px | semibold | -0.025em |
| Section header | 18px | medium | -0.015em |
| Card title | 16px | medium | normal |
| Body text | 14px | normal | normal |
| Caption | 12px | normal | 0.01em |
| Badge | 12px | medium | 0.02em |

### Micro-Animations

| Interaction | Animation |
|-------------|-----------|
| Card hover | `translateY(-2px)` 150ms ease-out |
| Button press | `scale(0.98)` 100ms |
| Panel slide | `translateX(100%) → 0` 300ms cubic-bezier |
| Score ring | `stroke-dashoffset` 800ms ease-out |
| Skeleton | shimmer 1.5s infinite |
| Badge count | `scale(1.2) → 1` bounce |

### Border Radius

| Element | Radius |
|---------|--------|
| Buttons, badges | 6px |
| Cards | 12px |
| Panels, modals | 16px |
| Avatars, icons | full |
| Inputs | 8px |

---

## States

### Loading (Skeleton UI)
- Shimmer animation: gradient sweep left-to-right
- Maintains layout structure (no shift)
- Colour: `bg-gray-200` with shimmer
- Minimum 300ms display to avoid flicker

### Empty States

| Context | Icon | Message | Action |
|---------|------|---------|--------|
| No client selected | `Building2` | "Select a client to see personalised recommendations" | `[Browse Clients]` |
| No products match | `SearchX` | "No products match your filters" | `[Clear Filters]` |
| No news for client | `Newspaper` | "No recent news about {Client}" | `[View Industry News]` |
| No saved items | `Bookmark` | "Items you save will appear here" | `[Browse Products]` |

### Error States

| Type | Treatment |
|------|-----------|
| API failure | Inline card with `AlertCircle`, retry button |
| Network offline | Toast + greyed content overlay |
| Permission denied | Redirect with message |
| Partial failure | Show loaded content, error badge on failed section |

---

## Accessibility

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘ + K` | Open client search |
| `⌘ + /` | Focus AI chat |
| `⌘ + S` | Save selected |
| `⌘ + Enter` | Add to plan |
| `Escape` | Close/clear |
| `Tab` | Navigate cards |
| `Enter/Space` | Select card |
| `Arrows` | Navigate grid |
| `?` | Show shortcuts |

### Focus Management
- Visible ring: `ring-2 ring-purple-500 ring-offset-2`
- Focus trap in modals
- Return focus on close
- Skip-to-content link

### ARIA

| Element | Attributes |
|---------|------------|
| Client selector | `role="combobox"` `aria-expanded` |
| Product grid | `role="grid"` with `role="gridcell"` |
| AI panel | `role="complementary"` |
| Match score | `role="meter"` `aria-valuenow` |
| Alerts | `role="alert"` `aria-live="polite"` |
| Action bar | `role="toolbar"` |

### Colour Contrast
- All text meets WCAG AA (4.5:1 body, 3:1 large)
- Status colours paired with icons
- Focus visible in both modes

---

## Component Architecture

### New Components

| Component | Location | Purpose |
|-----------|----------|---------|
| `ClientSelector` | `components/sales-hub/` | Searchable dropdown |
| `ClientSnapshotBar` | `components/sales-hub/` | Health, NPS, ARR, stack |
| `ProductCardV2` | `components/sales-hub/` | Redesigned card |
| `BundleCardV2` | `components/sales-hub/` | Redesigned bundle |
| `AICompanionPanel` | `components/sales-hub/` | Persistent AI sidebar |
| `ActionBar` | `components/sales-hub/` | Sticky bulk actions |
| `UrgentAlertsBanner` | `components/sales-hub/` | News urgent items |
| `NewsCard` | `components/sales-hub/` | Article card |
| `TenderCard` | `components/sales-hub/` | Tender card |
| `MatchScoreRing` | `components/ui/` | Animated progress |
| `GlassPanel` | `components/ui/` | Glass-morphism container |
| `SkeletonCard` | `components/ui/` | Loading placeholder |

### Modified Pages

| Page | Changes |
|------|---------|
| `/sales-hub/page.tsx` | Complete rewrite |
| Remove: `ProductsTab`, `BundlesTab`, `RecommendationsTab` | Replaced by unified view |
| Keep: `UnifiedDetailPanel` | Enhanced styling |

### Data Flow

```
User selects client
       ↓
┌──────────────────────────────────────────────────────┐
│  Parallel API calls:                                 │
│  • /api/clients/{id}                                │
│  • /api/sales-hub/recommendations?client={id}       │
│  • /api/sales-hub/news/client/{id}                  │
│  • /api/sales-hub/products?exclude=owned            │
│  • /api/meetings?client={id}&upcoming=true          │
└──────────────────────────────────────────────────────┘
       ↓
AI Companion receives context → generates suggestions
       ↓
UI renders client context view
```

### State Management (Zustand)

| Store | State |
|-------|-------|
| `useSalesHubStore` | `selectedClient`, `selectedItems`, `viewMode`, `filters` |
| `useAICompanionStore` | `suggestions`, `chatHistory`, `isExpanded` |
| `useNewsStore` | `urgentAlerts`, `dismissedIds`, `trackedTenders` |

---

## Icon Reference (Lucide React)

| Concept | Icon Name |
|---------|-----------|
| Urgent/Alert | `AlertTriangle` |
| Opportunity | `TrendingUp` |
| News | `Newspaper` |
| Health score | `Circle` (filled) |
| Tender | `FileText` |
| Client | `Building2` |
| Match score | `Target` |
| Stakeholder | `User` |
| Calendar | `Calendar` |
| Dismiss | `X` |
| Action | `ArrowRight` |
| Track | `Bookmark` |
| Competitor | `Scale` |
| AI/Assistant | `Sparkles` |
| Search | `Search` |
| Settings | `Settings` |
| Save | `Bookmark` |
| Recent | `Clock` |
| Pin | `Pin` |
| Add | `Plus` |
| Compare | `Columns` |
| Share | `Share2` |
| Export | `Download` |
| Filter | `SlidersHorizontal` |

---

## Implementation Notes

### Phase 1: Core Layout
1. New page structure with two-column layout
2. Client selector component
3. Basic responsive breakpoints

### Phase 2: Client Context
1. Client snapshot bar
2. Recommendations integration
3. Current stack display

### Phase 3: Cards & Visuals
1. ProductCardV2 with logos
2. Match score rings
3. Glass-morphism styling

### Phase 4: AI Companion
1. Panel component
2. Contextual suggestions logic
3. Chat interface

### Phase 5: News Integration
1. Urgent alerts banner
2. News cards in client view
3. Tender tracking

### Phase 6: Polish
1. Animations & transitions
2. Loading states
3. Empty states
4. Dark mode

### Phase 7: Mobile
1. Bottom navigation
2. Gesture support
3. Bottom sheets

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Time to find relevant product | < 30 seconds (from 2+ minutes) |
| Products added to plans per session | +40% |
| AI suggestion click-through | > 25% |
| Mobile usage | +50% increase |
| User satisfaction (survey) | > 4.5/5 |

---

## Open Questions

1. Should dark mode be opt-in via settings or follow system preference?
2. How many pinned clients should be allowed?
3. Should AI suggestions be dismissible permanently or per-session?
4. Integration with CRM for tender tracking?

---

## Appendix: File Locations

**Product Logos:**
```
~/Library/CloudStorage/OneDrive-AlteraDigitalHealth/
  Marketing - Altera Templates & Tools/BU Logos/
  ├── Altera-App-Icon_Sun.svg
  ├── Altera-App-Icon_dbM.svg
  ├── Altera-App-Icon_Opal.svg
  ├── Altera-App-Icon_Par-1.svg
  ├── Altera-App-Icon_TW.svg
  ├── Altera-App-Icon_CD.svg
  ├── Altera-App-Icons_CFX.png
  └── Altera-App-Icons_Ven.png
```

**Current Sales Hub:**
```
src/app/(dashboard)/sales-hub/
  ├── page.tsx
  └── components/
      ├── ProductsTab.tsx
      ├── BundlesTab.tsx
      ├── RecommendationsTab.tsx
      ├── NewsIntelligenceTab.tsx
      └── UnifiedDetailPanel.tsx
```

**News Intelligence:**
```
src/lib/news-intelligence/
  ├── rss-fetcher.ts
  ├── chasen-scorer.ts
  ├── article-filters.ts
  └── healthcare-gate.ts

src/app/api/sales-hub/news/
  ├── feed/
  ├── urgent/
  ├── client/[clientId]/
  └── tenders/
```
