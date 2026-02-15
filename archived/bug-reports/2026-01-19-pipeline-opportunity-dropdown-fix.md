# Bug Fix: Pipeline Opportunity Dropdown Not Showing Options

**Date**: 2026-01-19
**Type**: Bug Fix
**Component**: Risk & Recovery Step (Strategic Planning Wizard)
**Status**: Resolved

## Description

The Pipeline Opportunity dropdown in the Risk & Recovery step of the Strategic Planning Wizard was not displaying any options when a portfolio client was selected. Users reported that clicking the dropdown only showed "Select opportunity..." with no available options.

## Root Cause

The `clientOpportunities` filter was using **exact string matching** between portfolio client names and opportunity `client_name` fields. This caused mismatches when:

1. **Portfolio client names differed from opportunity client names**:
   - Portfolio: `"Barwon Health"` vs Opportunity: `"Barwon Health Australia"`
   - Portfolio: `"Epworth Healthcare"` vs Opportunity: `"Epworth HealthCare"` (case difference)
   - Portfolio: `"WA Health"` vs Opportunity: `"Western Australia Department Of Health"`

2. **Portfolio clients with warning emoji** (⚠️ indicating at-risk status):
   - Selected value: `"Barwon Health ⚠️"` would never match `"Barwon Health Australia"`

### Original Code (Line 632-635)

```tsx
const clientOpportunities = useMemo(() => {
  if (!selectedClient) return []
  return opportunities.filter(o => o.client_name === selectedClient)
}, [selectedClient, opportunities])
```

## Solution

Implemented **flexible client name matching** that:

1. Removes the ⚠️ warning emoji from selected client names
2. Normalises both names (lowercase, trimmed)
3. Matches if either name contains the other (handles variations like "Barwon Health" matching "Barwon Health Australia")

### Fixed Code

```tsx
const clientOpportunities = useMemo(() => {
  if (!selectedClient) return []
  // Remove warning emoji and normalise for comparison
  const normalizedSelected = selectedClient
    .replace(/\s*⚠️\s*$/, '')
    .toLowerCase()
    .trim()
  return opportunities.filter(o => {
    if (!o.client_name) return false
    const normalizedOppClient = o.client_name.toLowerCase().trim()
    // Match if exact, or if one contains the other
    return (
      normalizedOppClient === normalizedSelected ||
      normalizedOppClient.includes(normalizedSelected) ||
      normalizedSelected.includes(normalizedOppClient)
    )
  })
}, [selectedClient, opportunities])
```

## Files Modified

1. `src/app/(dashboard)/planning/strategic/new/steps/RiskRecoveryStep.tsx`
   - Updated `clientOpportunities` useMemo filter (lines 631-647)

## Testing

### Before Fix
- Select "Barwon Health ⚠️" → Dropdown shows only "Select opportunity..."
- No opportunities available for selection

### After Fix
- Select "Barwon Health ⚠️" → Dropdown shows:
  - "Barwon Health - Services Retainer Q2 2026 ($23K)"
  - "Barwon Health - Optional Year 3 Opal Renewal 1OCT2026 to 30SEP2027 ($1K)"
- Works for all portfolio clients with name variations

## Verification Steps

1. Navigate to `/planning/strategic/new?id=<plan-id>`
2. Click on "Risks" step (Step 5)
3. Click "Add Risk" button
4. Select any portfolio client with ⚠️ indicator
5. Verify Pipeline Opportunity dropdown shows matching opportunities

## Commit

`725d0438` - fix: Pipeline Opportunity dropdown not showing options for portfolio clients
