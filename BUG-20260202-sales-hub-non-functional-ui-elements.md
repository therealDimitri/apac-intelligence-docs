# BUG-20260202: Sales Hub Non-Functional UI Elements

**Status:** Fixed
**Date:** 2026-02-02
**Commit:** `218b44f1`
**Files Modified:** 10

## Summary

Multiple UI elements on the Sales Hub page were non-functional - clicking buttons, links, and icons produced no response. This affected header controls, navigation links, AI companion suggestions, and mobile navigation.

## Root Cause

UI elements were rendered with visual styling but lacked:
1. `onClick` handlers or navigation logic
2. State management for expand/collapse functionality
3. Proper `href` props on Link components
4. Router integration for SPA navigation

## Elements Fixed

### Header Controls (3 items)

| Element | Issue | Fix |
|---------|-------|-----|
| Settings icon | No onClick handler | Added `router.push('/settings/sales-hub')` |
| Filter icon | No toggle functionality | Added `showFilters` state toggle |
| Add to Plan button | No navigation | Added navigation to planning coach with client context |

### View All Links (6 instances)

| Section | Issue | Fix |
|---------|-------|-----|
| Top Opportunities | No expand logic | Added `showAll` state, displays 4→all |
| Trending Products | Only 3 products shown | Added 3 more products + expand/collapse |
| Industry News | Limited to few articles | Increased limit to 20 + expand/collapse |
| Client News | "View X more" non-functional | Fixed button to expand article list |
| Stack Gaps | Non-functional link | Removed (feature coming soon) |
| Meetings | No navigation | Added Link to `/meetings?search={client}` |

### ChaSen AI Panel (3 items)

| Element | Issue | Fix |
|---------|-------|-----|
| Quick Insights | Plain text, not clickable | Made links with navigation hrefs |
| Suggested Actions | Buttons did nothing | Added working hrefs to all suggestions |
| SuggestionCard | Used `window.location.href` | Changed to `router.push()` for SPA navigation |

### Other Elements (2 items)

| Element | Issue | Fix |
|---------|-------|-----|
| Urgent Alerts "Take action" | No handler | Added `handleTakeAction()` with context-aware navigation |
| Mobile Saved button | No sheet display | Added `showSavedSheet` state and full saved items sheet |

## Code Changes

### src/app/(dashboard)/sales-hub/page.tsx
```typescript
// Added router and state
const router = useRouter()
const [showFilters, setShowFilters] = useState(false)

// Settings button
<button onClick={() => router.push('/settings/sales-hub')}>

// Filter toggle
<button onClick={() => setShowFilters(!showFilters)}>

// Add to Plan with client context
const handleAddToPlan = () => {
  if (selectedClient) {
    router.push(`/planning/strategic/new?client=${encodeURIComponent(selectedClient.name)}`)
  }
}
```

### src/components/sales-hub/AICompanionPanel.tsx
```typescript
// Made Quick Insights clickable
function InsightRow({ label, value, positive, neutral, href }: InsightRowProps) {
  if (href) {
    return (
      <Link href={href} className="group flex items-center justify-between...">
        {content}
      </Link>
    )
  }
  return <div className="flex items-center justify-between...">{content}</div>
}

// Added hrefs to all insights
<InsightRow label="At-Risk Clients" value="5" positive={false} href="/client-profiles?filter=at-risk" />
<InsightRow label="Meetings Today" value="3" neutral href="/meetings?date=today" />
<InsightRow label="New Opportunities" value="12" positive href="/pipeline?filter=new" />
```

### src/components/sales-hub/SuggestionCard.tsx
```typescript
// Changed from window.location to router for SPA navigation
const router = useRouter()

const handleAction = () => {
  if (action?.onClick) {
    action.onClick()
  } else if (action?.href) {
    router.push(action.href)
  }
}
```

### src/components/sales-hub/UrgentAlertsBanner.tsx
```typescript
const handleTakeAction = (alert: UrgentAlert) => {
  if (alert.clientName) {
    router.push(`/clients?search=${encodeURIComponent(alert.clientName)}`)
  } else if (alert.type === 'rfi' || alert.type === 'tender') {
    router.push('/pipeline')
  } else {
    router.push('/sales-hub?tab=news&filter=urgent')
  }
}
```

### src/components/sales-hub/MobileBottomNav.tsx
```typescript
// Added saved items sheet
const [showSavedSheet, setShowSavedSheet] = useState(false)

// Saved button opens sheet
{
  id: 'saved',
  onClick: () => setShowSavedSheet(!showSavedSheet),
}

// Full saved items sheet with backdrop, list, empty state
{showSavedSheet && (
  <div className="fixed inset-0 z-50 lg:hidden">
    <div className="absolute inset-0 bg-black/50" onClick={() => setShowSavedSheet(false)} />
    <GlassPanel className="absolute bottom-0 left-0 right-0 rounded-t-2xl max-h-[70vh]">
      {/* Sheet content */}
    </GlassPanel>
  </div>
)}
```

## Testing

Verified in browser via Playwright:
- Settings icon → navigated to `/settings/sales-hub`
- Quick Insight "At-Risk Clients" → navigated to `/client-profiles?filter=at-risk`
- ChaSen AI suggestions visible with action buttons
- Industry News shows 20 articles with "View all" option

## Prevention

1. **Always wire up onClick handlers** when adding interactive elements
2. **Use router.push() for SPA navigation** instead of window.location
3. **Test all clickable elements** during development
4. **Add expand/collapse state** when showing limited items with "View all"

## Related

- Commit: `218b44f1`
- Netlify deploy: Successful
- Files: 10 modified, 333 insertions, 115 deletions
