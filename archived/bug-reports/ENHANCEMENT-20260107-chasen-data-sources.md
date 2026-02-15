# Enhancement: ChaSen AI Data Source Access

**Date**: 7 January 2026
**Status**: Implemented
**Severity**: Enhancement
**Component**: ChaSen AI Chat API

## Summary

Enhanced ChaSen AI with access to two additional data sources for more comprehensive analytics and trend analysis.

## New Data Sources Added

### 1. Client Health History (`client_health_history`)
Provides health score trends over time for each client.

**Query:**
```typescript
supabase
  .from('client_health_history')
  .select('client_name, health_score, nps_score, compliance_score, snapshot_date')
  .order('snapshot_date', { ascending: false })
  .limit(500)
```

**Context Structure:**
```typescript
healthHistory: {
  all: [...],           // All history records
  count: number,        // Total records
  byClient: {...},      // Grouped by client name
  trends: [...],        // Calculated trends per client
  improving: [...],     // Clients with >5 point improvement
  declining: [...],     // Clients with >5 point decline
  byClientFocus: [...]  // Filtered for focus client
}
```

### 2. Clients Table (`clients`)
Provides full client information including segment, country, CSE/CAM assignments.

**Query:**
```typescript
supabase
  .from('clients')
  .select('id, canonical_name, display_name, segment, tier, country, region, cse_name, cam_name, is_active')
  .eq('is_active', true)
```

**Context Structure:**
```typescript
clientsData: {
  all: [...],           // All active clients
  count: number,        // Total client count
  bySegment: {...},     // Grouped by segment
  byCSE: {...},         // Grouped by CSE name
  byCountry: {...},     // Grouped by country
  byClientFocus: {...}  // Single client if focus specified
}
```

## Files Modified

- `src/app/api/chasen/chat/route.ts`
  - Added `clientHealthHistoryData` and `clientsTableData` to destructuring array
  - Added two new Supabase queries to Promise.all
  - Added processed data to return context object

## ChaSen Can Now Answer Questions About

1. **Health Score Trends**
   - "Which clients have improving health scores?"
   - "Show me clients with declining health over the past month"
   - "What's the health trend for [client name]?"

2. **Client Demographics**
   - "How many clients do we have by country?"
   - "List all clients in the Leverage segment"
   - "Who is the CSE for [client name]?"

## Existing Data Sources (Reference)

ChaSen already had access to 27+ data sources including:
- nps_clients, unified_meetings, actions
- nps_responses, client_arr, aging_accounts
- client_segmentation, client_health_summary
- portfolio_initiatives, cse_profiles
- burc_historical_revenue_detail
- And many more...

## Testing

Ask ChaSen:
- "Which clients have declining health scores this month?"
- "Show me the health trend for GHA"
- "How many clients are in each segment?"
- "List clients by country"
