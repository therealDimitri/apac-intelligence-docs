# Bug Fix: Trend Calculation Using Relative Dates

**Date:** 2026-01-16
**Severity:** High (Data Display)
**Status:** ✅ Fixed

## Problem Description

Health and NPS trend indicators in the Planning Wizard were always showing `0` (stable) for all clients, even when significant changes had occurred in the historical data.

### Example Issues
| Client | Expected Trend | Actual (Before Fix) |
|--------|---------------|---------------------|
| Te Whatu Ora Waikato | Health: -15 (DOWN) | 0 (STABLE) |
| Epworth Healthcare | Health: -10 (DOWN) | 0 (STABLE) |
| SA Health (iPro) | Health: -9 (DOWN) | 0 (STABLE) |
| Mount Alvernia Hospital | Health: -4 (STABLE) | 0 (STABLE) |

## Root Cause

The trend calculation compared snapshots older than **7 days from today**, but the latest snapshot was already older than 7 days from today. This caused the code to match the latest snapshot as both "current" AND "previous", resulting in a diff of 0.

### Buggy Code
```typescript
// Calculate 7 days ago from TODAY
const sevenDaysAgo = new Date()
sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)

// Find previous snapshot older than 7 days from today
const previousSnapshot = snapshots.find(s => {
  const snapshotDate = new Date(s.snapshot_date)
  return snapshotDate < sevenDaysAgo  // BUG: Latest is already < sevenDaysAgo
})
```

### Timeline Example
- Today: January 16, 2026
- 7 days ago: January 9, 2026
- Latest snapshot: January 4, 2026 (already older than Jan 9)
- Result: Latest snapshot matches the filter, diff = 0

## Solution

Changed to compare snapshots 7+ days **before the latest snapshot**, not before today:

### Fixed Code
```typescript
// FIXED: Compare to snapshot 7+ days BEFORE the latest snapshot
const latestDate = new Date(latest.snapshot_date)
const comparisonThreshold = new Date(latestDate)
comparisonThreshold.setDate(comparisonThreshold.getDate() - 7)

const previousSnapshot = snapshots.find(s => {
  const snapshotDate = new Date(s.snapshot_date)
  return snapshotDate < comparisonThreshold  // Now finds snapshot before Dec 28
})
```

### Timeline Example (Fixed)
- Latest snapshot: January 4, 2026
- Comparison threshold: December 28, 2025 (7 days before latest)
- Previous snapshot found: December 27, 2025
- Result: Correct diff calculated (e.g., 75 - 90 = -15)

## Files Modified

1. **`src/app/(dashboard)/planning/strategic/new/page.tsx`**
   - Lines 1594-1602: Fixed trend comparison logic

## Verification

```bash
# Build passes
npm run build

# Test script confirms correct trends:
node -e "
require('dotenv').config({ path: '.env.local' });
const { createClient } = require('@supabase/supabase-js');
// ... test code showing correct diffs now calculated
"

# Results:
# Te Whatu Ora Waikato: Health diff: -15 → DOWN ✅
# Epworth Healthcare: Health diff: -10 → DOWN ✅
# SA Health (iPro): Health diff: -9 → DOWN ✅
# Mount Alvernia Hospital: Health diff: -4 → STABLE ✅
```

## Results

| Client | Before | After |
|--------|--------|-------|
| Te Whatu Ora Waikato | 0 (STABLE) | -15 (DOWN) |
| Epworth Healthcare | 0 (STABLE) | -10 (DOWN) |
| SA Health (iPro) | 0 (STABLE) | -9 (DOWN) |
| Mount Alvernia Hospital | 0 (STABLE) | -4 (STABLE) |

## Notes on Support Trends

Support trends (`supportTrend`) are not currently available because:
1. `support_health_points` is always `null` in `client_health_history`
2. `support_sla_metrics` only has 1-2 periods per client (insufficient for trends)

Support trends will remain unavailable until either:
- `support_health_points` is populated in daily health snapshots
- More historical periods are added to `support_sla_metrics`

## Related

- `client_health_history` table - Source of health snapshots
- `/planning/strategic/new` - Planning Wizard page
- `DiscoveryDiagnosisStep.tsx` - UI component displaying trends
