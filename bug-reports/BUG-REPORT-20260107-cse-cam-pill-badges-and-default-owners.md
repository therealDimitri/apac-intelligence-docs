# Bug Report: CSE/CAM Pill Badges and Region-Based Default Action Owners

**Date:** 2026-01-07
**Status:** Resolved
**Priority:** Medium
**Component:** Dashboard-wide (Client Profiles, Compliance, Actions)

---

## Issue Summary

1. **CSE/CAM display format**: CSE and CAM roles were displayed inconsistently across the dashboard using `:CSE` and `:CAM` text suffixes
2. **Missing CAM on Client Profiles**: The main Client Profiles page only showed CSE, not CAM
3. **Default action owners**: Actions were not automatically assigned to the appropriate owner based on client region

---

## Solution Implemented

### 1. CSE/CAM Pill Badge Format

Converted all CSE and CAM displays to use consistent pill badge format:

```
[Photo] [FirstName] [CSE] - Blue pill badge
[Photo] [FirstName] [CAM] - Purple pill badge
```

**Files Modified:**

| File | Changes |
|------|---------|
| `src/app/(dashboard)/clients/page.tsx` | Added CAM data fetching, converted table and sidebar modal to pill badges |
| `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` | Converted hero card CSE/CAM to pill badges |
| `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx` | Converted Team tab CSE/CAM to pill badges |
| `src/components/compliance/ClientComplianceCard.tsx` | Added CSE display, converted both to pill badges |

### 2. CAM Data Integration on Clients Page

Added CAM data fetching from `nps_clients` table:

```typescript
// Fetch CAM mappings from nps_clients table
useEffect(() => {
  async function fetchCAMData() {
    const supabase = createClient(...)
    const { data } = await supabase
      .from('nps_clients')
      .select('client_name, cam')
      .not('cam', 'is', null)

    // Create mapping: clientName -> camName
    if (data) {
      const mapping: Record<string, string> = {}
      data.forEach(row => {
        if (row.client_name && row.cam) {
          mapping[row.client_name] = row.cam
        }
      })
      setCamMap(mapping)
    }
  }
  fetchCAMData()
}, [])
```

### 3. Region-Based Default Action Owners

**File:** `src/components/modern-actions/ActionSlideOutCreate.tsx`

Added new props and logic for automatic owner assignment:

```typescript
// New props
interface ActionSlideOutCreateProps {
  // ... existing props
  cseName?: string        // CSE name for ANZ clients
  clientRegion?: string   // Client region (ANZ, Asia, etc.)
}

// Default owner logic
function getDefaultOwner(
  clientRegion?: string,
  cseName?: string,
  contextClient?: string,
  currentUser?: string
): string[] {
  const region = clientRegion?.toLowerCase() || ''
  const clientName = contextClient?.toLowerCase() || ''

  // Asia/Guam clients → Nikki Wei
  if (region.includes('asia') || clientName.includes('guam')) {
    return ['Nikki Wei']
  }

  // ANZ clients → CSE
  if (region.includes('anz') || region.includes('australia') || region.includes('new zealand')) {
    return cseName ? [cseName] : currentUser ? [currentUser] : []
  }

  // Fallback to CSE if available, otherwise current user
  return cseName ? [cseName] : currentUser ? [currentUser] : []
}
```

---

## Badge Styling

### CSE Badge (Blue)
```css
bg-blue-50 border-blue-200 rounded-full
Photo: bg-blue-200 text-blue-700
Name: text-blue-700 font-medium
Role: text-blue-500 bg-blue-100 font-bold
```

### CAM Badge (Purple)
```css
bg-purple-50 border-purple-200 rounded-full
Photo: bg-purple-200 text-purple-700
Name: text-purple-700 font-medium
Role: text-purple-500 bg-purple-100 font-bold
```

---

## Testing Verification

- [x] TypeScript compilation passes (`npx tsc --noEmit`)
- [x] CSE pill badges display correctly on Client Profiles page
- [x] CAM pill badges display correctly on Client Profiles page
- [x] CSE/CAM badges show on individual client profile hero card
- [x] CSE/CAM badges show in Team tab with correct role labels
- [x] ClientComplianceCard shows both CSE and CAM badges
- [x] Default owner logic correctly assigns Nikki Wei for Asia/Guam clients
- [x] Default owner logic correctly assigns CSE for ANZ clients

---

## Usage Notes

### Passing CSE/CAM context to ActionSlideOutCreate

When using the action create component, you can now pass region context:

```tsx
<ActionSlideOutCreate
  isOpen={showActionCreate}
  onClose={() => setShowActionCreate(false)}
  onSubmit={handleSubmit}
  contextClient={client.name}
  currentUser={session?.user?.name}
  cseName={client.cse_name}
  clientRegion={cseProfile?.region}
/>
```

The component will automatically set the default owner based on the region:
- **Asia/Guam**: Nikki Wei
- **ANZ (Australia/New Zealand)**: The assigned CSE
- **Fallback**: Current user or CSE if available

---

## Database Context

CAM data is sourced from `nps_clients.cam` field:
- The `cam` field stores the Client Account Manager's name
- Data is fetched and cached on page load
- No database changes required
