# Bug Report: Support Health Card Restyling & CSE/CAM Filters

**Date:** 8 January 2026
**Status:** Fixed

## Issues Addressed

### 1. SupportHealthCard Not Matching Dashboard Style

**Problem:** The Support Health card on client profile pages used a different styling pattern (shadcn/ui variables like `bg-card`, `border-border`) compared to the rest of the dashboard which uses explicit Tailwind classes (`bg-white`, `border-gray-200`).

**Solution:** Completely restyled the SupportHealthCard component to match the dashboard card pattern:

- Card container: `bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm`
- Header: Dynamic gradient based on health status with status badge
- Content: Large KPI score, progress bar, 2x2 metrics grid
- Removed dependency on TooltipProvider (simplified UI)

**Styling Pattern Applied:**

```tsx
// Header gradient based on health status
const headerGradient = isHealthy
  ? 'from-emerald-500 to-green-500'
  : isAtRisk
    ? 'from-amber-500 to-yellow-500'
    : 'from-red-500 to-rose-500'

// Status badge with white background
<span className={`inline-flex items-center gap-1.5 px-3 py-1 ${badgeBg} ${scoreColour} text-xs font-semibold rounded-full`}>
  <StatusIcon className="h-3.5 w-3.5" />
  {statusLabel}
</span>
```

### 2. Missing CAM Filter on Support Health Page

**Problem:** The Support Health overview page only had CSE filter, no way to filter by Client Account Manager (CAM).

**Solution:**
1. Updated API to fetch CAM data from `clients` table
2. Added `cam_name` field to SupportMetrics interface
3. Added `?cam=<name>` query parameter support
4. Added `camList` to API response for dropdown
5. Added CAM filter dropdown next to CSE filter

**Database Query Enhancement:**

```typescript
// Fetch clients table for CAM assignments
const { data: clientsData } = await supabase
  .from('clients')
  .select('canonical_name, display_name, cam_name, cse_name')
  .eq('is_active', true)

// Build CAM lookup map
const camMap = new Map<string, string>()
clientsData?.forEach(c => {
  if (c.cam_name) {
    if (c.canonical_name) camMap.set(c.canonical_name.toLowerCase(), c.cam_name)
    if (c.display_name) camMap.set(c.display_name.toLowerCase(), c.cam_name)
  }
})
```

### 3. Enhanced Client Row Display

**Change:** Client rows now show both CSE and CAM names when available:

```
WA Health
CSE: Tracey Bland • CAM: Anu Sharma
```

## Files Modified

### API Route
**`src/app/api/support-metrics/route.ts`**
- Added `cam_name` to SupportMetrics interface
- Added `camFilter` query parameter handling
- Fetch CAM data from `clients` table
- Build `camMap` for lookup
- Apply CAM filter when provided
- Return `camList` for dropdown

### Components

**`src/components/support/SupportHealthCard.tsx`**
- Complete restyle to match dashboard card pattern
- Removed TooltipProvider dependency
- Added gradient header with status badge
- Added progress bar visualisation
- Updated loading skeleton
- Updated error/empty states

**`src/components/support/SupportOverviewTable.tsx`**
- Added `cam_name` to SupportMetrics interface
- Added `camList` state
- Added `selectedCAM` state
- Updated useEffect to include CAM in API params
- Added CAM filter dropdown
- Enhanced client row to show CSE • CAM

## UI Changes

### Before
- SupportHealthCard used different styling (rounded borders, muted colours)
- Only CSE filter available
- Only CSE shown in client rows

### After
- SupportHealthCard matches dashboard gradient style
- Both CSE and CAM filters available
- Client rows show "CSE: Name • CAM: Name"
- Progress bar shows health score visually

## Data Source

| Field | Source Table | Column |
|-------|--------------|--------|
| CSE Name | `client_segmentation` | `cse_name` |
| CAM Name | `clients` | `cam_name` |
| Client UUID | `client_segmentation` | `client_uuid` |

## Verification

- TypeScript: Passed
- ESLint: Passed
- API returns both `cseList` and `camList`
- Filters work independently and together
