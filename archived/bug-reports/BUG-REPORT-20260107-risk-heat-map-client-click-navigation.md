# Bug Report: Risk Heat Map Client Click Navigation

**Date:** 2026-01-07
**Status:** Resolved
**Priority:** Medium
**Component:** Compliance Dashboard - Risk Heat Map

---

## Issue Summary

When clicking a client in the Risk Heat Map, the Segmentation Compliance modal appeared but navigated to the client profile page when closed. Users expected to remain on the Compliance Dashboard page.

---

## Root Cause

The `handleClientClick` function was directly navigating to the client profile page:

```typescript
const handleClientClick = (clientName: string) => {
  // Navigate to v2 client profile with compliance section open
  router.push(`/clients/${encodeURIComponent(clientName)}/v2?section=compliance`)
}
```

This caused users to leave the Compliance Dashboard when they only wanted to view client details.

---

## Solution Implemented

Added a Client Compliance Detail Modal that displays client compliance information without leaving the page.

### Changes Made

**File:** `src/app/(dashboard)/compliance/page.tsx`

1. **Added modal state:**
```typescript
const [showClientDetailModal, setShowClientDetailModal] = useState(false)
```

2. **Added computed client data:**
```typescript
const selectedClientData = useMemo(() => {
  if (!selectedClient) return null
  return clients.find(c => c.client_name === selectedClient) || null
}, [selectedClient, clients])
```

3. **Changed click handler to open modal:**
```typescript
const handleClientClick = (clientName: string) => {
  // Open client compliance detail modal instead of navigating away
  setSelectedClient(clientName)
  setShowClientDetailModal(true)
}
```

4. **Added separate navigation handler:**
```typescript
const handleViewClientProfile = (clientName: string) => {
  // Navigate to v2 client profile with compliance section open
  router.push(`/clients/${encodeURIComponent(clientName)}/v2?section=compliance`)
}
```

5. **Added Client Compliance Detail Modal with:**
   - Client logo and name
   - Segment badge with colour coding
   - Overall compliance percentage and status
   - CSE/CAM assignments
   - Event compliance breakdown (each event type with actual vs expected)
   - Status indicators (compliant/non-compliant per event type)
   - "Close" button to stay on page
   - "View Full Profile" button for navigation

---

## Modal Features

| Feature | Description |
|---------|-------------|
| Client Header | Logo, name, and segment badge |
| Overall Score | Large percentage display with status badge |
| Assignments | CSE and CAM names if assigned |
| Event Breakdown | List of each event type with actual/expected counts |
| Colour Coding | Green for compliant, red for non-compliant |
| Action Buttons | Close (stay on page) and View Full Profile (navigate) |

---

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/compliance/page.tsx` | Added modal state, client data useMemo, modal component, separated click handlers |

---

## Testing Verification

- [x] TypeScript compilation passes (`npx tsc --noEmit`)
- [x] Clicking client in Risk Heat Map opens modal
- [x] Modal displays correct client information
- [x] Close button closes modal and stays on Compliance page
- [x] View Full Profile button navigates to client profile
- [x] Modal resets selectedClient when closed

---

## User Flow

**Before:**
1. Click client in Risk Heat Map
2. Navigate to client profile page
3. Click back to return to Compliance Dashboard

**After:**
1. Click client in Risk Heat Map
2. Modal opens with client compliance details
3. Click "Close" to dismiss and stay on Compliance Dashboard
4. OR click "View Full Profile" to navigate to client profile

---

## Related Files

- `src/components/compliance/EnhancedManagerDashboard.tsx` - RiskHeatMap component
- `src/hooks/useComplianceDashboard.ts` - Client compliance data hook
- `src/components/ClientLogoDisplay.tsx` - Client logo component
