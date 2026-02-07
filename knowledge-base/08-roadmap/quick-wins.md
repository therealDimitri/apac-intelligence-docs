# Quick Wins

Tasks that deliver visible improvement with minimal effort. Each should take < 1 day.

## Data Quality Quick Wins

### 1. Validate BURC Cell References
**File**: `scripts/sync-burc-data-supabase.mjs`
Add existence check before reading cells U36, U60, U101:
```javascript
const cell = sheet['U36']
if (!cell) throw new Error('Cell U36 not found - sheet structure may have changed')
```
**Why**: Silent failures when Excel structure changes are the #1 sync risk.

### 2. Document Excel Cell Mapping
Create `docs/burc-cell-mapping.md` listing every cell reference, which table/column it populates, and validation rules.
**Why**: Makes sheet restructure impact analysis possible without reading code.

### 3. Add Fiscal Year Parameter
Replace hardcoded `2026` in sync scripts with a config variable or CLI arg.
**Why**: Prevents code changes needed every January.

## UI Quick Wins

### 4. Hide Dev Pages
Add `if (process.env.NODE_ENV === 'production') return notFound()` to:
- `/test-ai/page.tsx`
- `/test-charts/page.tsx`
- `/chasen-icons/page.tsx`
**Why**: Internal pages visible in production create unprofessional appearance.

### 5. Create PageShell Component
Simple wrapper providing consistent page header:
```tsx
<PageShell title="NPS Analytics" description="Customer feedback tracking">
  {children}
</PageShell>
```
**Why**: Eliminates the most visible layout inconsistency across pages.

### 6. Wire useLeadingIndicators
Pass real `MetricData[]` from portfolio data into the existing hook.
**Why**: The hook is 100% complete — just needs data wired in dashboard.

## Automation Quick Wins

### 7. Schedule Activity Register Sync
Add a launchd plist for `sync-excel-activities.mjs` (similar to BURC plist).
**Why**: Currently requires manual CLI run; should sync when file changes.

### 8. Add Staleness Check to Dashboard
Show a banner when BURC data is > 24h old:
```tsx
{lastSyncAge > 24 * 60 * 60 * 1000 && <Banner>BURC data is {hours}h old</Banner>}
```
**Why**: Users should know when they're looking at stale data.

### 9. Seed Goal Hierarchy
Insert sample company_goals and team_goals data.
**Why**: Goal tables show 0 rows — either RLS-blocked or unseeded. Feature appears broken.

## Data Integrity Quick Wins

### 10. Centralise Remaining Client Name Mappings
Move hardcoded client name mappings from sync scripts into `client_name_aliases` table.
**Why**: 5+ scripts have independent mapping logic that can drift.

### 11. Add Sync Completion Notification
Log sync results to a `sync_audit_log` table with counts and status.
**Why**: No visibility into whether sync succeeded/failed without checking logs.

### 12. Fix Empty Admin Routes
Verify admin routes (`/admin/*`) have proper auth checks and consistent navigation.
**Why**: Admin pages exist but aren't discoverable from the main UI.

## Priority Order

Start with the ones that protect data accuracy:
1. Validate BURC cell references (#1)
2. Document Excel cell mapping (#2)
3. Centralise client name mappings (#10)
4. Hide dev pages (#4)
5. Create PageShell (#5)
6. Wire useLeadingIndicators (#6)
7. Schedule Activity Register sync (#7)
8. Add staleness banner (#8)
9. Seed goal hierarchy (#9)
10. Add fiscal year parameter (#3)
11. Add sync notification (#11)
12. Fix admin routes (#12)
