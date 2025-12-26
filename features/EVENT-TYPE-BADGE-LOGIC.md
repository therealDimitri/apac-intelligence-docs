# Event Type Badge Logic Documentation

## Overview

Event Type Visualization displays two types of badges for each event:

1. **Priority Badge** (high/medium/low)
2. **Severity Badge** (critical/warning/normal)

## Current Implementation

### Badge Logic Location

**File**: `src/app/api/event-types/route.ts` (lines 78-88)

### 1. Priority Badge Logic

```typescript
const getPriority = (freq: string): 'high' | 'medium' | 'low' => {
  if (freq.includes('Per Month')) return 'high'
  if (freq.includes('Per Quarter')) return 'medium'
  return 'low'
}
```

**Mapping**:

- **HIGH** → Events with frequency "Per Month"
- **MEDIUM** → Events with frequency "Per Quarter"
- **LOW** → All other frequencies (typically "Per Year")

**Business Logic**: More frequent events have higher priority because they require more regular attention and resources.

### 2. Severity Badge Logic

```typescript
const getSeverity = (priority: string): 'critical' | 'warning' | 'normal' => {
  if (priority === 'high') return 'critical'
  if (priority === 'medium') return 'warning'
  return 'normal'
}
```

**Mapping**:

- **CRITICAL** → High priority events (Per Month)
- **WARNING** → Medium priority events (Per Quarter)
- **NORMAL** → Low priority events (Per Year)

**Business Logic**: Severity directly correlates with priority. More frequent events are more critical to complete.

## Visual Representation

### Priority Badge Colors

- **HIGH**: Orange background (`bg-orange-100 text-orange-700`)
- **MEDIUM**: Yellow background (`bg-yellow-100 text-yellow-700`)
- **LOW**: Gray background (`bg-gray-100 text-gray-700`)

### Severity Badge Colors

- **CRITICAL**: Red background (`bg-red-100 text-red-700`)
- **WARNING**: Yellow background (`bg-yellow-100 text-yellow-700`)
- **NORMAL**: Gray background (`bg-gray-100 text-gray-700`)

**Location**: `src/components/EventTypeVisualization.tsx` (lines 250-273)

## Examples

### Example 1: Monthly Event

- **Frequency**: "Per Month"
- **Priority**: HIGH (orange badge)
- **Severity**: CRITICAL (red badge)
- **Interpretation**: This event happens monthly and requires critical attention

### Example 2: Quarterly Event

- **Frequency**: "Per Quarter"
- **Priority**: MEDIUM (yellow badge)
- **Severity**: WARNING (yellow badge)
- **Interpretation**: This event happens quarterly and requires moderate attention

### Example 3: Yearly Event

- **Frequency**: "Per Year"
- **Priority**: LOW (gray badge)
- **Severity**: NORMAL (gray badge)
- **Interpretation**: This event happens yearly and requires standard attention

## Confirmed Business Logic (2025-01-28)

✅ **Frequency determines priority** - This is the correct approach for this business
✅ **Severity directly maps to priority** - Should NOT consider additional factors like business impact
✅ **Current implementation is correct** - No changes needed to badge logic

### Rationale

- More frequent events (monthly) require more regular attention and resources → Higher priority
- Event frequency is a reliable indicator of criticality in this context
- Simple, consistent logic that users can easily understand

## Change History

- **2025-01-28**: Initial documentation created
- **Current Version**: Simple frequency-based mapping (v1.0)
