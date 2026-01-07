# Bug Report: Compliance Page Navigation, Filters, and Event Type Expansion

**Date:** 2026-01-07
**Status:** Resolved
**Priority:** Medium
**Component:** Compliance Dashboard

---

## Issues Summary

1. **View All button non-functional**: Clicking "View All" in the alert banner did nothing
2. **Event Type cards not expandable**: Clicking Compliance by Event Type cards had no interaction
3. **Missing search filter**: No way to filter by CSE/CAM name or Client Name
4. **Heat Map broken navigation**: Clicking clients in Heat Map opened broken link showing "Client Not Found"

---

## Solutions Implemented

### 1. View All Button - Scroll to Alerts Section

Added `useRef` to track the alerts section and scroll to it smoothly:

```typescript
// Ref for scrolling to alerts section
const alertsSectionRef = useRef<HTMLDivElement>(null)

// Scroll to alerts section handler
const handleViewAllAlerts = useCallback(() => {
  alertsSectionRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}, [])

// Added ref to alerts section div
<div ref={alertsSectionRef} className="rounded-xl shadow-sm bg-white scroll-mt-24">
```

The `scroll-mt-24` class provides proper offset for the fixed header.

### 2. Expandable Event Type Cards

Added state and handlers for expanding/collapsing event type cards with client lists:

```typescript
// State for expanded event type
const [expandedEventType, setExpandedEventType] = useState<string | null>(null)

// Toggle expanded event type
const handleEventTypeClick = useCallback((eventCode: string) => {
  setExpandedEventType(prev => (prev === eventCode ? null : eventCode))
}, [])
```

Updated `EventTypeSummary` component to:
- Accept `expandedEventCode` and `onEventTypeClick` props
- Display expandable client list showing:
  - Client name with CSE
  - Events completed vs required (e.g., "2/3 Events")
  - Status indicator (met/not-met)
  - Traffic light colour coding (green for met, red for not met)
- Sort clients: not-met first, then alphabetically

### 3. Search Bar Filter

Added search functionality filtering by client name, CSE name, or CAM name:

```typescript
// State for search query
const [searchQuery, setSearchQuery] = useState('')

// Filter clients by search query (name, CSE, or CAM)
const filteredClients = useMemo(() => {
  let result = complianceData || []
  if (searchQuery.trim()) {
    const query = searchQuery.toLowerCase()
    result = result.filter(
      c =>
        c.client_name.toLowerCase().includes(query) ||
        c.cse?.toLowerCase().includes(query) ||
        c.cam?.toLowerCase().includes(query)
    )
  }
  // ... other filters
}, [complianceData, filters, searchQuery])
```

Updated search placeholder text to: `"Search by client, CSE, or CAM..."`

### 4. Heat Map Client Navigation

Fixed navigation to use v2 client profile with compliance section:

```typescript
// Before (broken)
router.push(`/clients/${encodeURIComponent(client.clientName)}`)

// After (working)
router.push(`/clients/${encodeURIComponent(clientName)}/v2?section=compliance`)
```

This opens the v2 client profile page and automatically triggers the Compliance detail modal.

---

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/compliance/page.tsx` | Added scroll ref, search filter, event type expansion, fixed navigation |
| `src/components/compliance/EnhancedProgressRing.tsx` | Added `onEventTypeClick` and `expandedEventCode` props to `EventTypeProgressGrid` |

---

## Component Updates

### EventTypeSummary Component

Completely redesigned to include:
- Clickable event type cards with highlight ring when expanded
- Expandable client list with `AnimatePresence` for smooth animations
- Client breakdown showing:
  - Status dot (green/red)
  - Client name with CSE in pill badge
  - Events count (completed/required)
  - Met/Not Met status badge
- Sort order: not-met clients first for easy identification
- Click-through to client profile with compliance modal

### EventTypeProgressGrid Component

Updated to accept new props:
```typescript
export function EventTypeProgressGrid({
  items,
  className = '',
  onEventTypeClick,
  expandedEventCode,
}: {
  items: EventTypeProgress[]
  className?: string
  onEventTypeClick?: (eventCode: string) => void
  expandedEventCode?: string | null
})
```

---

## Testing Verification

- [x] TypeScript compilation passes (`npx tsc --noEmit`)
- [x] View All button scrolls smoothly to Compliance Alerts section
- [x] Event Type cards expand on click showing client breakdown
- [x] Expanded cards collapse when clicking again or clicking another
- [x] Search filters by client name, CSE name, and CAM name
- [x] Heat Map client clicks navigate to v2 profile with compliance modal
- [x] Not-met clients appear first in expanded list
- [x] CSE names display in pill badges in expanded list

---

## URL Navigation Pattern

Client navigation now consistently uses:
```
/clients/{clientName}/v2?section=compliance
```

The `section=compliance` query parameter triggers the ComplianceModal to open automatically on page load.

---

## Related Files

- `src/hooks/useEventCompliance.ts` - Provides `EventTypeCompliance` interface with `event_code` property
- `src/components/compliance/EnhancedProgressRing.tsx` - Progress ring and grid components
- `src/components/compliance/AlertBanner.tsx` - Alert banner with View All button
