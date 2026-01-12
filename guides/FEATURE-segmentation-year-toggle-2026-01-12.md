# Feature: Segmentation Page Year Toggle and Responsive Design

**Date:** 2026-01-12
**Type:** Feature Enhancement
**Status:** Completed
**Commit:** 6f4315ae

## Summary

Added a year toggle (2025/2026) to the Segmentation Events page, allowing users to filter compliance events by year. Also improved responsive design for laptop/MacBook screens.

## Changes Made

### 1. Year Toggle Implementation

**File:** `src/app/(dashboard)/segmentation/page.tsx`

- Added state variable `selectedYear` defaulting to current year (2026)
- Added year toggle UI in the header alongside view mode buttons
- Updated `useAllClientsCompliance` hook to use `selectedYear` instead of hardcoded `currentYear`
- Updated `ClientEventDetailPanel` to pass `selectedYear` as the year prop

```typescript
// Year toggle state - default to current year
const currentYear = new Date().getFullYear()
const [selectedYear, setSelectedYear] = useState<number>(currentYear)

// Hook now uses selected year
const { allCompliance, loading, error } = useAllClientsCompliance(selectedYear)

// Event detail panel uses selected year
<ClientEventDetailPanel clientName={client.name} year={selectedYear} />
```

### 2. Responsive Design Improvements

**Files:**
- `src/app/(dashboard)/segmentation/page.tsx`
- `src/components/CSEWorkloadView.tsx`

Improvements for laptop/MacBook screen sizes:
- Adjusted summary stat card padding and font sizes with breakpoints (lg, xl, 2xl)
- Optimised segment stats grid from 5 columns to 3 columns on smaller screens
- Made health/compliance progress bars narrower on laptop screens
- Hidden "View Profile" text on laptop screens (icon only), full text on xl+
- Adjusted CSE Workload View statistics grid for better laptop display

## UI Changes

### Year Toggle Component
- Located in the header, left of view mode buttons
- Pill-style toggle with "Year:" label
- Active state: white background, purple text, shadow
- Inactive state: grey text, hover state
- Defaults to current year (2026)

### Responsive Breakpoints
- `lg` (1024px): Laptop-optimised sizing
- `xl` (1280px): Standard desktop sizing
- `2xl` (1536px): Large screen full features

## Testing

1. Navigate to `/segmentation`
2. Verify year toggle displays with 2026 selected by default
3. Click 2025 to switch years
4. Verify compliance data updates accordingly
5. Expand a client row to verify event details show correct year data
6. Resize browser to verify responsive design works on laptop screens

## Related Files

- `src/hooks/useAllClientsCompliance.ts` - Hook that fetches compliance data by year
- `src/components/ClientEventDetailPanel.tsx` - Event detail component receiving year prop

## Notes

- The year toggle only affects compliance event data display
- Both years (2025/2026) are available as fixed options
- Design matches existing view mode toggle styling
