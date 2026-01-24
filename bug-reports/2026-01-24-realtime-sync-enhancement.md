# Enhancement: Event-Driven Sync Using Supabase Realtime

**Date**: 2026-01-24
**Type**: Enhancement
**Status**: Completed

## Summary

Implemented event-driven synchronisation using Supabase Realtime to replace polling-based refresh patterns across the application. This provides instant data updates when database changes occur, reducing server load and improving user experience.

## Changes Made

### 1. Enhanced `useRealtimeSubscription.ts`

Added two new utility hooks for easier integration:

- **`useRealtimeTableSync`**: Subscribe to a single table and trigger a refetch callback on changes. Includes debouncing to handle rapid changes gracefully.

- **`useRealtimeMultiTableSync`**: Subscribe to multiple tables and trigger a single sync callback when any of them change. Useful for dashboards that depend on multiple data sources.

**File**: `/src/hooks/useRealtimeSubscription.ts`

Key features:
- Debounced sync callbacks (default 500ms) to prevent overwhelming the server with rapid changes
- Connection status tracking
- Automatic reconnection with exponential backoff
- Change count and timestamp tracking
- Enable/disable capability

### 2. Updated `useRealtimeSubscriptions.ts`

Added `client_health_history` table to the consolidated realtime subscription:

- New callback: `onHealthHistoryChange`
- Cache invalidation for `health` and `clients` patterns

**File**: `/src/hooks/useRealtimeSubscriptions.ts`

### 3. Updated Components (Polling Replaced with Realtime)

#### BURCExecutiveDashboard.tsx
- **Before**: `setInterval(fetchData, 5 * 60 * 1000)` (5-minute polling)
- **After**: Subscribes to `unified_meetings`, `actions`, `client_health_history`, and `nps_clients` changes
- Initial load only, then realtime handles subsequent updates

#### DataFreshnessHeader.tsx
- **Before**: `setInterval(fetchData, 5 * 60 * 1000)` (5-minute polling)
- **After**: Subscribes to meetings, actions, clients, and NPS changes
- Instant refresh when data health status changes

#### BURCInsightsWidget.tsx
- **Before**: `setInterval(fetchInsights, 5 * 60 * 1000)` (5-minute polling)
- **After**: Subscribes to actions, meetings, health history, and clients
- Insights refresh immediately when underlying data changes

#### FinancialActionsWidget.tsx
- **Before**: `setInterval(fetchData, 5 * 60 * 1000)` (5-minute polling)
- **After**: Subscribes to actions, clients, and health history
- Financial alerts update in real-time

#### useDailyInsights.ts Hook
- **Before**: `setInterval(fetchInsights, refreshInterval)` with configurable polling interval
- **After**: Realtime subscriptions to meetings, actions, health history, and clients
- `refreshInterval` parameter deprecated (kept for backwards compatibility)

## Tables Now Subscribed To

The consolidated realtime subscription (`useRealtimeSubscriptions`) now monitors:

1. `nps_clients` - Client data changes
2. `nps_responses` - NPS survey responses
3. `unified_meetings` - Meeting records
4. `actions` - Action items
5. `segmentation_events` - Compliance events
6. `segmentation_event_compliance` - Compliance tracking
7. `client_health_history` - **NEW** - Health score snapshots

## Usage Examples

### Simple Single-Table Sync
```tsx
import { useRealtimeTableSync } from '@/hooks/useRealtimeSubscription'

function MyComponent() {
  const [data, setData] = useState(null)

  const fetchData = async () => {
    const response = await fetch('/api/my-data')
    setData(await response.json())
  }

  // Subscribe to table changes
  const { connectionStatus, lastChange } = useRealtimeTableSync({
    table: 'unified_meetings',
    onSync: fetchData,
    debounceMs: 1000,
  })

  // Initial load
  useEffect(() => { fetchData() }, [])

  return (
    <div>
      <span>Status: {connectionStatus}</span>
      <span>Last update: {lastChange?.toLocaleTimeString()}</span>
    </div>
  )
}
```

### Using Consolidated Subscriptions
```tsx
import { useRealtimeSubscriptions } from '@/hooks/useRealtimeSubscriptions'

function Dashboard() {
  const fetchData = useCallback(() => { /* ... */ }, [])

  // Subscribe to multiple tables with a single WebSocket
  useRealtimeSubscriptions({
    onMeetingsChange: fetchData,
    onActionsChange: fetchData,
    onHealthHistoryChange: fetchData,
  }, {
    enableCacheInvalidation: true,
  })

  return <div>...</div>
}
```

## Performance Benefits

1. **Reduced Server Load**: No more 5-minute polling from multiple components
2. **Single WebSocket Connection**: All table subscriptions share one connection
3. **Instant Updates**: Data refreshes within 500ms of database changes
4. **Efficient Cache Invalidation**: Automatic cache clearing on relevant changes
5. **Debounced Syncs**: Rapid changes are consolidated into single refreshes

## Testing

Verified with:
- `npx tsc --noEmit` - TypeScript compilation passes
- `npm run build` - Production build succeeds
- Manual testing of realtime updates in development

## Migration Notes

Components using the old polling pattern can be migrated by:

1. Import `useRealtimeSubscriptions` or `useRealtimeTableSync`
2. Wrap your fetch function with `useCallback`
3. Replace `setInterval` with the realtime subscription
4. Keep the initial `useEffect` for first load only

## Files Changed

- `/src/hooks/useRealtimeSubscription.ts` - Added `useRealtimeTableSync` and `useRealtimeMultiTableSync`
- `/src/hooks/useRealtimeSubscriptions.ts` - Added `client_health_history` subscription
- `/src/components/burc/BURCExecutiveDashboard.tsx` - Replaced polling with realtime
- `/src/components/DataFreshnessHeader.tsx` - Replaced polling with realtime
- `/src/components/burc/BURCInsightsWidget.tsx` - Replaced polling with realtime
- `/src/components/FinancialActionsWidget.tsx` - Replaced polling with realtime
- `/src/hooks/useDailyInsights.ts` - Replaced polling with realtime
