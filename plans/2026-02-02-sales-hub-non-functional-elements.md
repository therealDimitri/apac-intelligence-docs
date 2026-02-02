# Sales Hub Non-Functional UI Elements

**Date:** 2026-02-02
**Status:** Planning
**Priority:** High

## Executive Summary

The Sales Hub page has 15+ interactive elements that are non-functional - they display but do nothing when clicked. This creates a broken user experience where buttons and links appear clickable but have no behaviour.

## Issue Categories

### 1. Critical: Header Controls (No handlers at all)

| Element | File | Line | Current State |
|---------|------|------|---------------|
| Settings icon (gear) | `page.tsx` | Header | `<button>` with no `onClick` |
| Filter icon (sliders) | `page.tsx` | Header | `<button>` with no `onClick` |
| "+ Add to Plan" button | `page.tsx` | Header | `<button>` with no `onClick` |

### 2. Critical: "View all" Links (6 instances, none work)

| Section | File | Current State |
|---------|------|---------------|
| Top Opportunities | `TopOpportunitiesSection.tsx` | Button, no handler |
| Trending This Month | `TrendingProductsSection.tsx` | Button, no handler |
| Industry News | `DashboardView.tsx` | Button, no handler |
| Stack Gaps | `ClientContextView.tsx` | Button, no handler |
| Upcoming Meetings | `ClientContextView.tsx` | Button, no handler |
| Client News | `ClientNewsSection.tsx` | Button, no handler |

### 3. Critical: Quick Insights (Not clickable at all)

| Element | File | Should Navigate To |
|---------|------|-------------------|
| At-Risk Clients (5) | `AICompanionPanel.tsx` | `/client-profiles?filter=at-risk` |
| Meetings Today (3) | `AICompanionPanel.tsx` | `/meetings?date=today` |
| New Opportunities (12) | `AICompanionPanel.tsx` | `/pipeline?filter=new` |

### 4. Medium: ChaSen AI Suggested Actions (Handlers exist but no callbacks)

| Action | File | Issue |
|--------|------|-------|
| "Review clients →" | `SuggestionCard.tsx` | `action.onClick` never assigned |
| "View details →" | `SuggestionCard.tsx` | `action.href` never assigned |
| "View RFI →" | `SuggestionCard.tsx` | `action.onClick` never assigned |
| "Schedule meeting" | `SuggestionCard.tsx` | `action.onClick` never assigned |

### 5. Medium: Other Non-Functional Elements

| Element | File | Issue |
|---------|------|-------|
| "Take action" (Urgent Alert) | `UrgentAlertsBanner.tsx` | No `onClick` |
| "View X more articles" | `ClientNewsSection.tsx` | No `onClick` |
| Mobile "Saved Items" | `MobileBottomNav.tsx` | `onClick={() => {}}` empty |

### 6. Low: Placeholder Implementations (console.log only)

| Element | File | Issue |
|---------|------|-------|
| Export (bulk action) | `ActionBar.tsx` | Logs to console |
| Share (bulk action) | `ActionBar.tsx` | Logs to console |
| Add to Collection | `ActionBar.tsx` | Logs to console |

## Implementation Plan

### Phase 1: Header Controls

**Settings Icon** → Open settings modal or navigate to `/settings/sales-hub`
```typescript
// Option A: Navigate
<Link href="/settings/sales-hub">
  <Settings className="w-5 h-5" />
</Link>

// Option B: Modal (if settings are quick toggles)
onClick={() => setShowSettingsModal(true)}
```

**Filter Icon** → Open filter panel/modal
- Filter by: Category, Region, Date range, Relevance score
- Store filter state in `useSalesHubStore`

**"+ Add to Plan" Button** → Add selected items to Account Plan
- Requires `selectedItems` from store
- Opens modal to select which plan to add to

### Phase 2: "View all" Links

Each "View all" should navigate to the appropriate full-page view:

| Section | Target | Implementation |
|---------|--------|----------------|
| Top Opportunities | Recommendations tab | `onClick={() => setActiveTab('recommendations')}` |
| Trending Products | Products tab | `onClick={() => setActiveTab('products')}` |
| Industry News | News tab | `onClick={() => setActiveTab('news')}` |
| Stack Gaps | Products tab (filtered) | `onClick={() => { setActiveTab('products'); setFilter('gaps') }}` |
| Meetings | `/meetings` page | `<Link href="/meetings">` |
| Client News | News tab (client filtered) | Expand inline or navigate |

### Phase 3: Quick Insights Navigation

Make each insight a clickable link:

```typescript
<Link href="/client-profiles?filter=at-risk" className="hover:text-purple-600">
  <span className="text-purple-600 font-medium">5</span>
</Link>
```

### Phase 4: ChaSen AI Suggested Actions

Pass `onClick` callbacks from `AICompanionPanel` to `SuggestionCard`:

```typescript
// In AICompanionPanel.tsx - when generating suggestions
const suggestions = [
  {
    id: '1',
    title: '5 Clients Need Attention',
    action: {
      label: 'Review clients',
      onClick: () => router.push('/client-profiles?filter=at-risk'),
      // OR
      href: '/client-profiles?filter=at-risk'
    }
  }
]
```

### Phase 5: Remaining Elements

- **"Take action"** on alerts → Navigate to client or opportunity detail
- **"View X more articles"** → Expand to show all or navigate to news tab
- **Mobile Saved Items** → Navigate to saved items view or open panel

## Files to Modify

1. `src/app/(dashboard)/sales-hub/page.tsx` - Header controls
2. `src/components/sales-hub/TopOpportunitiesSection.tsx` - View all link
3. `src/components/sales-hub/TrendingProductsSection.tsx` - View all link
4. `src/components/sales-hub/DashboardView.tsx` - Industry News view all
5. `src/components/sales-hub/AICompanionPanel.tsx` - Quick Insights + suggestion callbacks
6. `src/components/sales-hub/SuggestionCard.tsx` - Action button handling
7. `src/components/sales-hub/ClientContextView.tsx` - Stack Gaps + Meetings view all
8. `src/components/sales-hub/ClientNewsSection.tsx` - View all + more articles
9. `src/components/sales-hub/UrgentAlertsBanner.tsx` - Take action button
10. `src/components/sales-hub/MobileBottomNav.tsx` - Saved items button

## Decision Points

1. **Settings**: Modal or dedicated page?
2. **Filters**: Inline panel or modal?
3. **"View all"**: Navigate to tab or expand inline?
4. **Quick Insights**: Navigate to existing pages or show inline modal?
5. **Bulk actions**: What should Export/Share actually do?

## Testing Checklist

- [ ] Settings icon opens settings
- [ ] Filter icon opens filter panel
- [ ] All 6 "View all" links navigate correctly
- [ ] Quick Insights numbers are clickable and navigate
- [ ] ChaSen AI suggested actions execute their callbacks
- [ ] "Take action" on alerts works
- [ ] "View more articles" expands or navigates
- [ ] Mobile saved items button works
- [ ] No console errors on any click
