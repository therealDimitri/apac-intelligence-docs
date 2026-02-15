# Sales Hub Consolidation Design

**Date:** 2026-01-31
**Status:** Approved
**Approach:** Tabbed Interface with Unified Search (Option 1)

## Overview

Consolidate four separate Sales Hub pages into one unified page:
- `/sales-hub` (Products)
- `/sales-hub/bundles` (Solution Bundles)
- `/sales-hub/search` (Search)
- `/sales-hub/recommendations` (AI Recommendations)

Design inspired by: Notion, Linear, Stripe

---

## Section 1: Page Header & Unified Search

### Layout
```
┌─────────────────────────────────────────────────────────────┐
│  🏪 Sales Hub                                    [Sync All] │
│  Your complete sales toolkit - products, bundles & AI      │
├─────────────────────────────────────────────────────────────┤
│  🔍 Search products, bundles, and recommendations...    ✕   │
└─────────────────────────────────────────────────────────────┘
```

### Behaviour
- Unified search at top searches across ALL content (products, bundles)
- As user types, results appear in a dropdown grouped by type:
  - `Products (5 matches)` → shows top 3
  - `Bundles (2 matches)` → shows top 2
- Clicking a result opens the detail panel
- "Sync All" button triggers bulk sync to ChaSen knowledge base
- Search persists when switching tabs

### Styling
- Header: `bg-white shadow-sm border-b border-gray-200 px-6 py-4`
- Search input: `w-full max-w-2xl pl-12 pr-12 py-3 text-lg border-2 border-gray-200 rounded-xl focus:border-purple-500`
- Icon positioning: `absolute left-4 top-1/2 -translate-y-1/2`

---

## Section 2: Tab Navigation Structure

### Layout
```
┌─────────────────────────────────────────────────────────────┐
│  Products (42)  │  Solution Bundles (8)  │  AI Recommendations │
│  ━━━━━━━━━━━━━━                                              │
└─────────────────────────────────────────────────────────────┘
```

### Behaviour
- Three tabs with counts showing total items
- Active tab: `border-b-2 border-purple-600 text-purple-600`
- Inactive tabs: `text-gray-500 hover:text-gray-700 hover:border-gray-300`
- Tab state persists in URL hash (`#products`, `#bundles`, `#recommendations`)
- Keyboard navigation: Arrow keys move between tabs, Enter selects

### Tab Content

| Tab | Content | Filters |
|-----|---------|---------|
| Products | Product grid grouped by content type | Region, Type, Family |
| Solution Bundles | Bundle cards with persona badges | Region only |
| AI Recommendations | Client selector + generated recommendations | Client selection |

### Styling
```tsx
<div className="flex border-b border-gray-200 mb-6">
  {tabs.map(tab => (
    <button
      className={`flex items-center gap-2 px-4 py-3 text-sm font-medium border-b-2 -mb-px transition-colors ${
        activeTab === tab.key
          ? 'border-purple-600 text-purple-600'
          : 'border-transparent text-gray-500 hover:text-gray-700'
      }`}
    >
      <tab.icon className="h-4 w-4" />
      {tab.label}
      <span className="text-xs bg-gray-100 px-2 py-0.5 rounded-full">{tab.count}</span>
    </button>
  ))}
</div>
```

---

## Section 3: Products Tab Content

### Layout
```
┌─────────────────────────────────────────────────────────────┐
│  [Region ▼]  [Content Type ▼]  [Product Family ▼]   42 items│
├─────────────────────────────────────────────────────────────┤
│  ── Sales Briefs (3) ──────────────────────────────────────│
│  ┌────────┐ ┌────────┐ ┌────────┐                          │
│  └────────┘ └────────┘ └────────┘                          │
│  ── Datasheets (12) ───────────────────────────────────────│
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐               │
│  └────────┘ └────────┘ └────────┘ └────────┘               │
└─────────────────────────────────────────────────────────────┘
```

### Behaviour
- Grouped by content type (Sales Briefs, Datasheets, Brochures, etc.)
- Filters apply immediately (no submit button)
- Cards show: title, product family badge, elevator pitch preview, region tags
- Click card → opens unified detail panel
- Empty state: "No products match your filters" with clear filters button

### Styling
- Filter bar: `flex items-center gap-4 mb-6`
- Select: `px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-purple-500`
- Grid: `grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4`
- Card: `bg-white rounded-lg border shadow-sm hover:shadow-md transition-shadow cursor-pointer p-4`

---

## Section 4: Solution Bundles Tab Content

### Layout
```
┌─────────────────────────────────────────────────────────────┐
│  [Region ▼]                                        8 bundles│
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐ ┌──────────────────┐ ┌──────────────┐│
│  │ 📦 Toolkit Name  │ │ 📦 Toolkit Name  │ │              ││
│  │ Bundle Title     │ │ Bundle Title     │ │              ││
│  │ 🎯 KPI • KPI     │ │ 🎯 KPI • KPI     │ │              ││
│  │ CFO CIO CMIO     │ │ CFO COO          │ │              ││
│  │ AU NZ        →   │ │ AU           →   │ │              ││
│  └──────────────────┘ └──────────────────┘ └──────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### Behaviour
- Region filter only (bundles don't have content type/family filters)
- Cards show: Toolkit badge, bundle name, tagline, KPI preview, persona badges, region tags
- Click card → opens unified detail panel with full bundle info

### Detail Panel Content (Bundles)
- What It Is / What It Does
- What It Means (tabbed: Financial/Clinical/Operational)
- KPIs with targets and proof points
- Market Drivers
- Persona Talking Points
- Conversation Starters
- Asset link

---

## Section 5: AI Recommendations Tab Content

### Layout
```
┌─────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────────┐│
│  │ 👥 Select Client Context                                ││
│  │ ┌────────────┐ ┌────────────┐ ┌────────────┐            ││
│  │ │ Barwon ❤️85│ │ Eastern  ⚠️│ │ Monash  ❤️ │            ││
│  │ └────────────┘ └────────────┘ └────────────┘            ││
│  └─────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────┐│
│  │ 📈 Recommendations for Barwon Health        [Refresh 🔄]││
│  │  ① Bundle Name                    [Bundle] [92% match] ││
│  │  ② Product Title                  [Product] [88% match]││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### Behaviour
- Client selector grid at top (scrollable, max 6 visible)
- Each client card shows: name, health status badge, current products, recent topic tags
- Selecting a client triggers recommendation generation (1.5s delay with spinner)
- Recommendations list shows ranked results mixing products AND bundles
- Each recommendation: rank number, title, type badge, match percentage, reason text
- Reason text always includes client name
- Click recommendation → opens unified detail panel
- Refresh button regenerates recommendations

---

## Section 6: Unified Detail Panel

### Layout
```
┌──────────────────────────────────────┐
│  [Product Family Badge]          ✕   │
│  Title of Product or Bundle          │
├──────────────────────────────────────┤
│  (Content adapts to type)            │
│  ── Products: value props, FAQ, etc  │
│  ── Bundles: personas, KPIs, etc     │
├──────────────────────────────────────┤
│  [🔗 Open Asset]                     │
└──────────────────────────────────────┘
```

### Behaviour
- Single reusable component that renders differently based on content type
- Slides in from right with backdrop overlay
- Close via X button, backdrop click, or Escape key
- Content adapts to item type

### Component Interface
```tsx
type DetailPanelProps = {
  item: Product | SolutionBundle | null
  type: 'product' | 'bundle'
  onClose: () => void
}
```

### Styling
- Backdrop: `fixed inset-0 bg-black/30 z-40`
- Panel: `fixed right-0 top-0 h-full w-full max-w-2xl bg-white shadow-xl z-50 overflow-y-auto`
- Content: `p-6`

---

## Section 7: State Management & Data Flow

### State Structure
```tsx
// Main page state
const [activeTab, setActiveTab] = useState<'products' | 'bundles' | 'recommendations'>('products')
const [searchQuery, setSearchQuery] = useState('')
const [selectedItem, setSelectedItem] = useState<{ item: Product | Bundle; type: 'product' | 'bundle' } | null>(null)

// Filter state (Products tab)
const [productFilters, setProductFilters] = useState({
  region: 'all',
  contentType: 'all',
  productFamily: 'all'
})

// Filter state (Bundles tab)
const [bundleRegion, setBundleRegion] = useState('all')

// AI Recommendations state
const [selectedClient, setSelectedClient] = useState<ClientContext | null>(null)
```

### Data Flow
```
Hooks (data fetching)
├── useProductCatalog() → products
├── useSolutionBundles() → bundles
├── useToolkits() → toolkits
└── useClientContext() → clients
           ↓
Unified Search (filters both products + bundles)
└── searchResults = [...matchedProducts, ...matchedBundles]
           ↓
Tab Content (filtered by tab-specific filters)
├── Products: groupedByContentType(filtered)
├── Bundles: filteredByRegion
└── AI: generateRecommendations(client, products, bundles)
           ↓
UnifiedDetailPanel (renders based on selected item type)
```

### URL Sync
- Tab persists in hash: `#products`, `#bundles`, `#recommendations`
- Enables direct linking and back button support

---

## File Structure

### New Structure
```
src/app/(dashboard)/sales-hub/
├── page.tsx                    # Main consolidated page
├── components/
│   ├── SalesHubHeader.tsx      # Header + unified search
│   ├── SalesHubTabs.tsx        # Tab navigation
│   ├── ProductsTab.tsx         # Products grid + filters
│   ├── BundlesTab.tsx          # Bundles grid + filters
│   ├── RecommendationsTab.tsx  # Client selector + AI results
│   └── UnifiedDetailPanel.tsx  # Shared slide-out panel
```

### Files to Remove
```
src/app/(dashboard)/sales-hub/bundles/page.tsx
src/app/(dashboard)/sales-hub/search/page.tsx
src/app/(dashboard)/sales-hub/recommendations/page.tsx
```

---

## Implementation Notes

1. **Preserve existing hooks** - `useProductCatalog`, `useSolutionBundles`, `useToolkits`, `useClientContext` remain unchanged
2. **Unified search** - New feature combining product + bundle search
3. **Detail panel** - Consolidate existing slide-out panels into one component
4. **Styling** - Follow existing dashboard patterns (purple brand, shadow-sm cards, rounded-lg)
5. **Client names in AI** - Always include client name in recommendation reasons (per CLAUDE.md rule)
