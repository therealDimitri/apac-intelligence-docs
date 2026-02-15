# Bug Report: Duplicate NPS Alerts for Same Client in Priority Matrix

**Date:** 2025-12-17
**Status:** Fixed
**Severity:** Medium (UX/Noise issue)
**Component:** Priority Matrix / ActionableIntelligenceDashboard

## Issue Description

The Priority Matrix was displaying multiple overlapping alerts for the same client when they had NPS issues. For example, St Luke's Medical Centre (NPS score -100, trending down) showed 3 separate alerts:

1. "High attrition risk detected" (CRITICAL)
2. "NPS score trending - engagement opportunity" (HIGH)
3. "Schedule engagement meeting" (HIGH)

All three alerts are essentially about the same underlying issue (NPS problems) and should be consolidated.

## Root Cause

The alert generation logic in `ActionableIntelligenceDashboard.tsx` had three separate generators with overlapping conditions:

### Alert Generator 1 (Lines 264-296)

```typescript
// Condition: trend === 'down' && score < 50
// Creates: "High attrition risk detected" (CRITICAL)
```

### Alert Generator 2 (Lines 395-423)

```typescript
// Condition: trend === 'down' && score < 40
// Creates: "NPS score trending - engagement opportunity" (HIGH)
```

### Priority Action Generator (Lines 524-560)

```typescript
// Condition: (trend === 'down' || score < 60) && no recent meeting
// Creates: "Schedule engagement meeting" (HIGH)
```

For St Luke's with score -100 and trend "down":

- Matches ALL three conditions
- Results in 3 separate action items for the same issue

## Solution

Implemented **Smart Alert Consolidation** with deduplication logic:

### 1. Track clients with NPS alerts

```typescript
const clientsWithNPSAlerts = new Set<string>()

// When creating critical NPS alerts:
clientsWithNPSAlerts.add(client.name)
```

### 2. Skip duplicate NPS alerts

```typescript
// In secondary NPS alert generator:
if (clientsWithNPSAlerts.has(client.name)) {
  console.log(`[Alert Consolidation] Skipping duplicate NPS alert for ${client.name}`)
  return
}
```

### 3. Skip meeting recommendations for clients with critical alerts

```typescript
const clientsWithCriticalAlerts = new Set(
  criticalAlerts
    .filter(alert => alert.type === 'risk' && alert.severity === 'critical')
    .map(alert => alert.client)
)

// Skip if client already has critical alert:
if (clientsWithCriticalAlerts.has(clientData.name)) {
  return
}
```

## Files Modified

- `src/components/ActionableIntelligenceDashboard.tsx`
  - Added `clientsWithNPSAlerts` Set to track clients with critical NPS alerts
  - Modified secondary NPS alert generator to skip clients already tracked
  - Modified meeting recommendation generator to skip clients with critical alerts

## Result

St Luke's now shows ONE consolidated critical alert instead of 3 overlapping alerts. The "High attrition risk detected" alert (most severe) is displayed, and the redundant "NPS trending" and "Schedule meeting" alerts are suppressed.

## Prevention

When adding new alert generators:

1. Check existing alert conditions for overlap
2. Use Sets to track which clients already have alerts
3. Add deduplication logic to skip redundant alerts
4. Prioritise showing the most severe/actionable alert

## Commit

`e959685` - fix(priority-matrix): consolidate duplicate NPS alerts for same client
