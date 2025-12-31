# Bug Report: Multi-Client Urgency Sorting and Deep Link Improvements

**Date:** 31 December 2025
**Status:** Fixed
**Severity:** Medium (UX Enhancement)
**Component:** Priority Matrix Context Menu (QuickActionsMenu)

## Summary

The Priority Matrix context menu's "Open Most Urgent Client" action was not actually sorting clients by urgency - it simply took the first client in the array. This has been fixed with a proper urgency calculation algorithm, and a new "Choose Client to Open" submenu allows users to select any client from multi-client cards.

## Root Cause

In `QuickActionsMenu.tsx`, the original code was:
```tsx
const mostUrgentClient = clients[0] // Just takes first client, NOT sorted by urgency
```

The label said "Open Most Urgent Client" but no urgency calculation existed.

## Solution

### 1. Urgency Calculation Algorithm

Added a scoring system that considers:
- **Status** (most impactful): Critical = -30 points, At-risk = -15 points
- **Health Score**: Lower health score = more urgent (scaled -15 to +15 points)
- **NPS Score**: Lower NPS = more urgent (scaled -10 to +10 points)

```tsx
const getUrgencyScore = useCallback(
  (clientName: string): number => {
    const data = clientDataLookup?.(clientName)
    if (!data) return 50 // Default middle priority

    let score = 50

    // Status-based scoring (most impactful)
    if (data.status === 'critical') score -= 30
    else if (data.status === 'at-risk') score -= 15

    // Health score (lower health = more urgent)
    if (data.healthScore !== null && data.healthScore !== undefined) {
      score += (data.healthScore - 50) * 0.3 // Range: -15 to +15
    }

    // NPS score (lower NPS = more urgent)
    if (data.npsScore !== null && data.npsScore !== undefined) {
      score += data.npsScore * 0.1 // Range: -10 to +10
    }

    return score
  },
  [clientDataLookup]
)

// Sort clients by urgency (most urgent first)
const sortedClients = useMemo(() => {
  if (!hasMultipleClients) return clients
  return [...clients].sort((a, b) => getUrgencyScore(a) - getUrgencyScore(b))
}, [clients, hasMultipleClients, getUrgencyScore])
```

### 2. Client Picker Submenu

Added a new "Choose Client to Open" action for multi-client cards that displays all clients sorted by urgency:

```tsx
if (hasMultipleClients) {
  quickActions.push({
    label: 'Choose Client to Open',
    description: `Select from ${sortedClients.length} clients`,
    icon: Users,
    onClick: () => setShowClientMenu(true),
  })
}
```

The submenu shows:
- Each client name
- Urgency reason (e.g., "Health: 43", "Critical status", "At risk")
- "Most urgent" badge on the first client

### 3. Data Lookup Function

Added `getClientDataByName` in `PriorityMatrix.tsx` to provide client health data:

```tsx
const getClientDataByName = useCallback(
  (clientName: string) => {
    const client = clients.find(c => c.name.toLowerCase() === clientName.toLowerCase())
    if (!client) return undefined
    return {
      name: client.name,
      healthScore: client.health_score,
      npsScore: client.nps_score,
      status: client.status as 'healthy' | 'at-risk' | 'critical' | undefined,
    }
  },
  [clients]
)
```

## Deep Link Verification

Verified that context menu actions correctly navigate to client profiles:

### Single-Client Cards
- **Action:** "Open Client Profile"
- **Deep Link:** `/clients/${clientId}/v2` (direct) or `/client-profiles?search=${clientName}` (fallback)

### Multi-Client Cards (Compliance/Segmentation)
- **Action:** "Open Most Urgent Client" or "Choose Client to Open"
- **Deep Link:** `/clients/${clientId}/v2?section=compliance&highlight=${eventType}`
- Opens compliance section with relevant event highlighted

## Files Modified

| File | Change |
|------|--------|
| `src/components/priority-matrix/QuickActionsMenu.tsx` | Added urgency scoring, sorted clients, client picker submenu |
| `src/components/priority-matrix/PriorityMatrix.tsx` | Added `getClientDataByName` function, passed to QuickActionsMenu |

## Testing Performed

Using Playwright browser automation:

### Test 1: Single-Client Deep Link
1. Right-clicked on "Prepare RVEEH renewal" card
2. Clicked "Open Client Profile"
3. Navigated to `/client-profiles?search=RVEEH` (fallback because alias not found)
4. Search results showed Royal Victorian Eye and Ear Hospital

**Result:** PASS (fallback works correctly)

### Test 2: Multi-Client Context Menu
1. Right-clicked on "Health Check (Opal)" card (2 clients: SingHealth, WA Health)
2. Context menu showed:
   - "Open Most Urgent Client" with "WA Health • Health: 43"
   - "Choose Client to Open" with "Select from 2 clients"

**Result:** PASS (WA Health correctly identified as more urgent)

### Test 3: Client Picker Submenu
1. Clicked "Choose Client to Open"
2. Submenu displayed:
   - WA Health (Health: 43) with "Most urgent" badge
   - SingHealth (Health: 44)
3. Clicked on SingHealth

**Result:** PASS (clients correctly sorted by urgency)

### Test 4: Compliance Deep Link
1. Selected SingHealth from client picker
2. Navigated to `/clients/10/v2?section=compliance&highlight=Health%20Check%20(Opal)`
3. Compliance panel opened showing SingHealth's 33% compliance
4. Event Type Breakdown showed "Health Check (Opal)" at 0%

**Result:** PASS (deep link with section and highlight parameters works)

## UI/UX Improvements

1. **Urgency Visibility:** Most urgent client now shown in action description
2. **Client Choice:** Users can select any client from multi-client cards
3. **Urgency Reasons:** Health score, status, and NPS displayed for context
4. **Visual Hierarchy:** Most urgent client highlighted with purple badge

## Deployment

- **Commit:** (pending)
- **Message:** "fix: Implement proper urgency sorting and client picker for multi-client Priority Matrix cards"
