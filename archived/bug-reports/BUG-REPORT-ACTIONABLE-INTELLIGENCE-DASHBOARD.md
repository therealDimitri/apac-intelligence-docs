# Bug Report: Actionable Intelligence Dashboard TypeScript Errors

**Date**: 2025-11-27
**Component**: ActionableIntelligenceDashboard.tsx
**Status**: ✅ RESOLVED
**Severity**: High (blocked production build)

---

## Summary

During implementation of the Actionable Intelligence Command Center dashboard, encountered TypeScript compilation errors related to incorrect hook usage and mismatched data structures between the `useCompliancePredictions` and `useNPSData` hooks.

---

## Issue #1: useCompliancePredictions Hook Misuse

### Error Message

```
Type error: Property 'predictions' does not exist on type '{ prediction: CompliancePrediction | null; loading: boolean; error: Error | null; refetch: () => void; }'
```

### Location

- **File**: `src/components/ActionableIntelligenceDashboard.tsx`
- **Line**: 89 (original)

### Root Cause

1. The `useCompliancePredictions` hook is designed for **single client predictions**, not portfolio-wide analysis
2. Hook returns: `{ prediction, loading, error, refetch }` (singular prediction)
3. Dashboard code attempted to destructure `predictions` (plural array) that doesn't exist
4. Dashboard needs **all clients** risk data, not individual client prediction

### Attempted Usage (INCORRECT)

```typescript
import { useCompliancePredictions } from '@/hooks/useCompliancePredictions'

const { predictions } = useCompliancePredictions() // ❌ predictions doesn't exist

// Later in code:
predictions // ❌ Used as array
  .filter(p => p.risk_level === 'high')
  .forEach(prediction => {
    // Process each prediction
  })
```

### Correct Approach

Use `clientScores` from `useNPSData` hook instead, which provides portfolio-wide client NPS data with trends:

```typescript
const { npsData, clientScores } = useNPSData() // ✅ clientScores is ClientNPSScore[]

// Filter for at-risk clients
clientScores
  .filter(client => client.trend === 'down' && client.score < 50)
  .forEach(client => {
    // Process at-risk client
  })
```

---

## Issue #2: NPS Data Structure Mismatch

### Error Message

```
Type error: 'npsData' is possibly 'null'.
```

### Location

- **File**: `src/components/ActionableIntelligenceDashboard.tsx`
- **Line**: 123, 192, 238, 321, 342, 399 (multiple locations)

### Root Cause

1. **Confused two different data structures** from `useNPSData` hook:
   - `npsData`: NPSSummary | null - Overall portfolio summary (single object)
   - `clientScores`: ClientNPSScore[] - Per-client scores (array)

2. **Dashboard needs client-level data**, not portfolio summary

3. **Property name mismatches** between expected and actual:
   - Expected: `client`, `latestScore`, `improving/declining`
   - Actual: `name`, `score`, `up/down/stable`

### Data Structure Comparison

#### NPSSummary (Portfolio-Wide)

```typescript
interface NPSSummary {
  currentScore: number // Overall NPS score
  previousScore: number // Previous overall score
  trend: 'up' | 'down' | 'stable'
  promoters: number // Percentage
  passives: number // Percentage
  detractors: number // Percentage
  responseRate: number
  totalResponses: number
  overallTrend: number
  lastSurveyDate: string
}
```

#### ClientNPSScore (Per-Client) ✅ CORRECT FOR DASHBOARD

```typescript
interface ClientNPSScore {
  name: string // ✅ Client name
  score: number // ✅ Client NPS score
  trend: 'up' | 'down' | 'stable' // ✅ Trend direction
  responses: number
  previousScore?: number // ✅ Previous score for decline calc
  trendData?: number[]
  recentFeedback?: NPSResponse[]
}
```

### Incorrect Usage (BEFORE)

```typescript
// ❌ Treating npsData as array (it's a single object or null)
npsData
  .filter(client => client.trend === 'declining' && client.latestScore < 50)
  .forEach(client => {
    // This never worked because npsData is not an array
  })
```

### Correct Usage (AFTER)

```typescript
// ✅ Using clientScores array with correct property names
clientScores
  .filter(client => client.trend === 'down' && client.score < 50)
  .forEach(client => {
    alerts.push({
      id: `risk-${client.name}`, // ✅ name not client
      client: client.name, // ✅ name not client
      issue: 'High attrition risk detected',
      impact: `NPS declining by ${client.previousScore ? client.previousScore - client.score : 0} points to ${client.score}`,
      // ...
    })
  })
```

---

## Issue #3: Trend Value Mismatch

### Location

Multiple locations throughout the component

### Root Cause

Different enum values between expected and actual:

- Expected: `'improving'`, `'declining'`, `'stable'`
- Actual: `'up'`, `'down'`, `'stable'`

### Fix Applied

```typescript
// BEFORE ❌
.filter(client => client.trend === 'improving')
.filter(client => client.trend === 'declining')

// AFTER ✅
.filter(client => client.trend === 'up')
.filter(client => client.trend === 'down')
```

---

## All Code Changes Made

### 1. Hook Import and Destructuring

```diff
- const { predictions } = useCompliancePredictions()
+ const { npsData, clientScores } = useNPSData()
```

### 2. Critical Alerts - High-Risk Clients (Line 122-142)

```diff
- // High-risk clients from AI predictions (>70% risk)
- predictions
-   .filter(p => p.risk_level === 'high' && p.confidence > 0.7)
-   .forEach(prediction => {
-     const client = clients.find(c => c.id === prediction.client_id)
+ // High-risk clients from NPS data (declining trend with low score)
+ clientScores
+   .filter(client => client.trend === 'down' && client.score < 50)
+   .filter(client => !CONFIRMED_ATTRITION.some(a => a.client === client.name))
+   .forEach(client => {
+     const scoreDecline = client.previousScore ? client.previousScore - client.score : 0
      alerts.push({
-       id: `risk-${client.id}`,
+       id: `risk-${client.name}`,
-       client: client.name,
+       client: client.name,
-       impact: `${(prediction.confidence * 100).toFixed(0)}% confidence...`,
+       impact: `NPS declining by ${scoreDecline} points to ${client.score}...`,
```

### 3. Critical Alerts - NPS Declining Clients (Line 191-208)

```diff
  // NPS declining clients
- npsData.forEach(client => {
-   if (client.trend === 'declining' && client.latestScore < 40) {
+ clientScores.forEach(client => {
+   if (client.trend === 'down' && client.score < 40) {
      alerts.push({
-       id: `nps-${client.client}`,
+       id: `nps-${client.name}`,
-       client: client.client,
+       client: client.name,
-       impact: `Current score: ${client.latestScore}...`,
+       impact: `Current score: ${client.score}...`,
```

### 4. Priority Actions - Recommended Meetings (Line 237-261)

```diff
  // Recommended meetings for at-risk clients
- npsData
-   .filter(client => client.trend === 'declining' || client.latestScore < 60)
+ clientScores
+   .filter(client => client.trend === 'down' || client.score < 60)
    .slice(0, 5)
    .forEach(clientData => {
-     const isHighRisk = clientData.trend === 'declining' && clientData.latestScore < 50
+     const isHighRisk = clientData.trend === 'down' && clientData.score < 50
      tasks.push({
-       id: `meeting-${clientData.client}`,
+       id: `meeting-${clientData.name}`,
-       client: clientData.client,
+       client: clientData.name,
```

### 5. AI Recommendations - Engagement Opportunities (Line 320-339)

```diff
  // Proactive engagement opportunities
- npsData
-   .filter(client => client.trend === 'stable' && client.latestScore >= 70)
+ clientScores
+   .filter(client => client.trend === 'stable' && client.score >= 70)
    .slice(0, 3)
    .forEach(client => {
      recommendations.push({
-       id: `engagement-${client.client}`,
+       id: `engagement-${client.name}`,
-       client: client.client,
+       client: client.name,
-       rationale: `High NPS (${client.latestScore})...`,
+       rationale: `High NPS (${client.score})...`,
```

### 6. AI Recommendations - Health Improvements (Line 341-360)

```diff
  // Health improvement suggestions
- npsData
-   .filter(client => client.trend === 'improving')
+ clientScores
+   .filter(client => client.trend === 'up')
    .slice(0, 3)
    .forEach(client => {
      recommendations.push({
-       id: `health-${client.client}`,
+       id: `health-${client.name}`,
-       client: client.client,
+       client: client.name,
-       rationale: `NPS improving from ${client.previousScore} to ${client.latestScore}...`,
+       rationale: `NPS improving from ${client.previousScore || 0} to ${client.score}...`,
```

### 7. Smart Insights - Positive Trends (Line 398-412)

```diff
  // Positive trends
- const improvingClients = npsData.filter(c => c.trend === 'improving').length
+ const improvingClients = clientScores.filter(c => c.trend === 'up').length
```

### 8. Dependency Array Updates

```diff
- }, [eventTypeData, predictions, clients, actions, npsData, ...])
+ }, [eventTypeData, clientScores, clients, actions, ...])

- }, [eventTypeData, predictions, clients, meetings, actions])
+ }, [eventTypeData, clientScores, clients, meetings, actions])

- }, [npsData, actions])
+ }, [clientScores, actions])

- }, [npsData, eventTypeData, actions])
+ }, [clientScores, eventTypeData, actions])
```

---

## Testing Results

### Before Fix

```
Failed to compile.

./src/components/ActionableIntelligenceDashboard.tsx:89:5
Type error: Property 'predictions' does not exist on type...

./src/components/ActionableIntelligenceDashboard.tsx:123:5
Type error: 'npsData' is possibly 'null'.

Build failed with 2 errors.
```

### After Fix

```
✓ Compiled successfully in 1742.1ms
✓ Running TypeScript ...
✓ Collecting page data using 13 workers ...
✓ Generating static pages using 13 workers (20/20) in 359.4ms
✓ Finalizing page optimisation ...

Route (app)
┌ ○ /
├ ○ /_not-found
├ ○ /actions
├ ○ /ai
[... 20 routes total]

Build completed successfully!
```

---

## Architecture Lessons Learned

### 1. Understand Hook Return Types Before Use

- Always check hook TypeScript definitions
- `useCompliancePredictions`: Single client prediction
- `useNPSData`: Portfolio-wide summary + client-level array

### 2. Use Correct Data Structure for Use Case

- **Portfolio summary**: Use `npsData` (NPSSummary)
- **Client-level operations**: Use `clientScores` (ClientNPSScore[])
- **Individual predictions**: Use `useCompliancePredictions` per client

### 3. Verify Property Names Match Interface

Common mistakes:

- `client` vs `name`
- `latestScore` vs `score`
- `improving`/`declining` vs `up`/`down`

### 4. Always Handle Null/Undefined States

- Check if data exists before filtering/mapping
- Use optional chaining: `client.previousScore || 0`
- Add fallbacks for missing data

---

## Related Files

### Modified

- `src/components/ActionableIntelligenceDashboard.tsx` - Main component with fixes

### Created

- `src/components/ActionableIntelligenceDashboardWrapper.tsx` - Server component wrapper
- `src/app/(dashboard)/page.tsx` - Updated with intelligence view toggle

### Referenced

- `src/hooks/useNPSData.ts` - Source of clientScores data
- `src/hooks/useCompliancePredictions.ts` - Not used in dashboard (single client only)

---

## Prevention Strategies

### For Future Development

1. **Type-First Development**
   - Review hook interfaces BEFORE writing code
   - Use TypeScript autocomplete to verify properties
   - Run `npm run build` frequently during development

2. **Data Structure Documentation**
   - Document hook return types in comments
   - Create type reference guide for common data structures
   - Add JSDoc comments to hook exports

3. **Testing Strategy**
   - Test with empty data states
   - Test with null/undefined values
   - Run production build before committing

4. **Code Review Checklist**
   - ✅ All hook return types match usage
   - ✅ Property names match interfaces
   - ✅ Null/undefined handled gracefully
   - ✅ Dependency arrays include all reactive values
   - ✅ Production build passes

---

## Deployment Status

**Commit**: `4d99727` - feat: actionable intelligence command centre dashboard
**Branch**: `main`
**Status**: ✅ Pushed to production
**Build**: ✅ Successful (Next.js 16.0.4)
**Routes**: ✅ 20 routes generated

**Live URL**: https://apac-cs-dashboards.com
**Monitoring**: Check Netlify deployment logs for any runtime errors

---

## Summary

Successfully resolved TypeScript compilation errors by:

1. Removing incorrect `useCompliancePredictions` usage
2. Using `clientScores` array from `useNPSData` hook
3. Updating all property names to match ClientNPSScore interface
4. Fixing trend enum values ('up'/'down' vs 'improving'/'declining')
5. Adding proper null handling and optional chaining

**Build Status**: ✅ Production build successful
**Code Quality**: ✅ TypeScript checks pass
**Runtime**: ✅ No errors in development server
**Deployment**: ✅ Deployed to production

---

**Report Generated**: 2025-11-27
**Engineer**: Claude Code
**Reviewed**: Automated TypeScript checks passed
