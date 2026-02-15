# Product Analytics UI Design

**Date:** 2026-02-03
**Status:** Approved

## Overview

Add product analytics UI with two components:
1. **Quick Stats Bar** - Embedded in Product Library page
2. **Admin Analytics Page** - Full dashboard at `/settings/product-analytics`

---

## Section 1: Quick Stats Bar

### Location
Top of Product Library page, below header, above search/filters.

### Layout
```
┌─────────────────────────────────────────────────────────────────────────┐
│  📈 Most Viewed              🔍 Recent Searches       🎯 Popular Filters │
│  ┌──────────────────┐        ┌─────────────────┐      ┌───────────────┐ │
│  │ 1. Sunrise Axon  │        │ "sunrise"       │      │ Workflow (45) │ │
│  │ 2. dbMotion HIE  │        │ "documentation" │      │ Compliance    │ │
│  │ 3. TouchWorks EHR│        │ "billing"       │      │ Revenue       │ │
│  └──────────────────┘        └─────────────────┘      └───────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

### Behaviour
- Collapsible (remembers preference in localStorage)
- Updates on page load (SWR with 5-minute revalidation)
- Clicking a product navigates to its detail page
- Clicking a search term populates the search box
- Clicking a filter applies that pain point filter

---

## Section 2: Admin Analytics Page (`/settings/product-analytics`)

### Layout
```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Product Analytics                                    [Last 7 days ▼]       │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │   Total Views   │  │  Total Searches │  │  Unique Users   │             │
│  │      247        │  │       89        │  │       12        │             │
│  │   ↑ 23% vs prev │  │   ↑ 15% vs prev │  │   ↓ 5% vs prev  │             │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘             │
│                                                                             │
│  ┌─────────────────────────────────────┐  ┌─────────────────────────────┐  │
│  │         Views Over Time             │  │     Top Products            │  │
│  │    (Area Chart)                     │  │  1. Sunrise Axon      45    │  │
│  │                                     │  │  2. dbMotion HIE      38    │  │
│  │                                     │  │  3. TouchWorks EHR    27    │  │
│  └─────────────────────────────────────┘  └─────────────────────────────┘  │
│                                                                             │
│  ┌─────────────────────────────────────┐  ┌─────────────────────────────┐  │
│  │      Recent Search Queries          │  │    Filter Usage             │  │
│  │  "sunrise documentation"     12x    │  │  (Horizontal Bar Chart)     │  │
│  │  "billing integration"        8x    │  │                             │  │
│  └─────────────────────────────────────┘  └─────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Components
| Component | Data Source | Charting |
|-----------|-------------|----------|
| Summary Cards | Aggregated counts with period comparison | None (text) |
| Views Over Time | Daily view counts | Recharts AreaChart |
| Top Products | Product view counts ranked | Horizontal bar list |
| Recent Searches | Search queries with frequency | Table with counts |
| Filter Usage | Pain point filter usage % | Horizontal bar chart |

### Date Range Options
- Last 7 days (default)
- Last 30 days
- Last 90 days

### Access Control
- Only visible to users with `role = 'Admin'` or `role = 'Manager'`

---

## Section 3: API Endpoint (`/api/product-analytics/summary`)

### Response Structure
```typescript
{
  quickStats: {
    topProducts: [{ id, title, product_family, views }],
    recentSearches: [{ query, count, lastSearched }],
    popularFilters: [{ category, count }]
  },
  adminStats: {
    summary: {
      totalViews, totalSearches, uniqueUsers,
      periodComparison: { views, searches, users }
    },
    viewsOverTime: [{ date, views }],
    topProducts: [{ id, title, product_family, views }],
    searchQueries: [{ query, count }],
    filterUsage: [{ category, count, percentage }]
  }
}
```

### Query Parameters
- `type`: `'quick'` | `'admin'` | `'all'`
- `days`: `7` | `30` | `90`

---

## Section 4: Implementation

### Tech Stack
- Charts: Recharts
- Data fetching: SWR
- Icons: Lucide React

### File Structure
```
src/
├── app/api/product-analytics/summary/route.ts
├── app/(dashboard)/settings/product-analytics/page.tsx
├── components/product-library/QuickStatsBar.tsx
└── hooks/useProductAnalytics.ts (extend with useSummary)
```

### Build Sequence
1. Create `/api/product-analytics/summary` endpoint
2. Add `useSummary` hook
3. Build `QuickStatsBar` component
4. Integrate into `ProductLibrary`
5. Build admin analytics page
6. Add settings sidebar link
7. Test and deploy
