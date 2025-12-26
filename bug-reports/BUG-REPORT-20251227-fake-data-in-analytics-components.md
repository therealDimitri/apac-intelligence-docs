# Bug Report: Fake/Random Data in Analytics Components

**Date:** 27 December 2025
**Status:** RESOLVED
**Severity:** Medium
**Affected Pages:** CSE Workload View, Policy Compliance Indicators, Write-Off Analysis

## Summary

Multiple analytics components were using `Math.random()` to generate fake data for metrics that should either display real data or indicate "no data available". This caused:
1. Inconsistent values on page refresh (numbers would change randomly)
2. Misleading information presented to users
3. No clear indication that data was simulated vs real

## Components Fixed

### 1. CSEWorkloadView.tsx

**Location:** `src/components/CSEWorkloadView.tsx`

**Issue:** AI Performance metrics (aiAccuracy, recommendationAdoption) were randomly generated:
```typescript
// BEFORE - Fake data
const aiAccuracy = 75 + Math.round(Math.random() * 20) // Simulated 75-95%
const recommendationAdoption = 60 + Math.round(Math.random() * 30) // Simulated 60-90%
```

**Solution:**
- Removed `aiAccuracy` and `recommendationAdoption` from the interface and calculations
- Removed the "AI Performance Insights" section from the expanded CSE details
- Changed metrics grid from 5 columns to 4 columns
- Removed unused imports (`Lightbulb`, `Zap`, `TrendingUp`)

**Rationale:** AI prediction tracking doesn't exist in the current system. Showing fake percentages was misleading.

### 2. PolicyComplianceIndicators.tsx

**Location:** `src/app/(dashboard)/aging-accounts/compliance/components/PolicyComplianceIndicators.tsx`

**Issues:**
1. Random contact compliance assumption: `if (Math.random() < 0.15) clientsWithNoContact30Days++`
2. Mock violation generator using `Math.random()` for severity, dates, amounts, etc.
3. Random `previousRate` values for trend indicators

**Solution:**
- Removed the random 15% contact assumption - contact tracking requires CRM integration
- Removed `generateViolations()` function entirely
- Set `violations: []` for all policies (violation tracking requires compliance monitoring system)
- Set `previousRate: undefined` for all policies (historical tracking not implemented)
- Policies without tracking data now show `complianceRate: 0` with `status: 'at_risk'`

**Rationale:** Policies based on aging data (60-day, 90-day thresholds) still show real calculated values. Policies requiring external system integration (contact frequency, documentation, approvals) now correctly show no data.

### 3. WriteOffAnalysis.tsx

**Location:** `src/app/(dashboard)/aging-accounts/compliance/components/WriteOffAnalysis.tsx`

**Issues:**
1. Mock write-off record generation with random categories, amounts, dates
2. Random `previousTotal` for comparison percentage

**Solution:**
```typescript
// AFTER - Returns provided data only, no mock generation
const writeOffData = useMemo((): WriteOffRecord[] => {
  return historicalWriteOffs || []
}, [historicalWriteOffs])

// Historical comparison set to 0 (no comparison available)
const changePercent = 0
```

**Rationale:** Write-off tracking requires integration with finance/ERP system. When no historical data is provided, the component now shows empty state instead of fake records.

## Verification

- TypeScript compilation passes without errors
- All three components now display only real data or appropriate "no data" states
- Metrics grids adjusted to show only available real metrics
- No `Math.random()` calls remain in these components for data generation

## Files Modified

1. `src/components/CSEWorkloadView.tsx`
   - Removed AI Performance metrics and related UI section
   - Reduced metrics grid from 5 to 4 columns
   - Removed unused Lucide icon imports

2. `src/app/(dashboard)/aging-accounts/compliance/components/PolicyComplianceIndicators.tsx`
   - Removed mock violation generation
   - Set empty violations arrays
   - Removed random previousRate calculations
   - Updated policies without tracking to show 0% compliance

3. `src/app/(dashboard)/aging-accounts/compliance/components/WriteOffAnalysis.tsx`
   - Removed mock write-off record generation
   - Returns empty array when no historical data provided
   - Removed random change percentage calculation

## Impact

### Positive
- Users no longer see misleading fake metrics
- Data integrity improved - all displayed data is now real
- Clear indication when data is not available

### Considerations
- Some dashboard sections will appear empty until proper integrations are implemented
- Policies for contact frequency, documentation, and approvals now show 0% compliance (requires system integration)
- Write-off analysis will be empty until historical write-off data is provided

## Future Enhancements

To restore these metrics with real data, the following integrations are needed:

1. **AI Performance Metrics:** Implement prediction tracking system to measure accuracy of AI recommendations
2. **Contact Tracking:** Integrate with CRM to track client contact attempts
3. **Violation Monitoring:** Implement compliance monitoring system to detect and track policy violations
4. **Write-Off History:** Integrate with finance/ERP system to retrieve historical write-off records
5. **Historical Trends:** Implement period-over-period tracking for compliance metrics

## Related Documentation

- `docs/bug-reports/BUG-REPORT-SPARKLINE-FAKE-DATA.md` - Previous NPS sparkline fix
- `docs/bug-reports/BUG-REPORT-20251227-kanban-badge-sizes-inconsistent.md` - Related UI fix
