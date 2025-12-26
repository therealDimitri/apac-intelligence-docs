# Feature: Historical Client Health Score Tracking

**Date:** 2024-12-20
**Status:** Implemented
**Type:** Enhancement
**Priority:** High

## Feature Description

Added the ability to track and measure historical client health scores with daily snapshots, trend visualisations, and status change alerts.

### User Requirements

- **Snapshot Frequency**: Daily captures of all client health scores
- **Retention**: Unlimited historical data
- **Visualisation**: Line chart on detail pages + Sparklines on list views
- **Alerts**: Automatic alerts when client status changes (Healthy ↔ At-Risk ↔ Critical)

## Implementation Summary

### Database Changes

Created two new tables and a PostgreSQL function:

1. **`client_health_history`** - Daily snapshots of health scores
   - Stores score, status, component breakdown (NPS, Compliance, Working Capital)
   - Tracks status changes with `status_changed` flag
   - Unique constraint on `(client_name, snapshot_date)`

2. **`health_status_alerts`** - Status change alerts
   - Records when a client moves between health status categories
   - Includes direction (improved/declined), acknowledgement tracking
   - Links to CSE for notification routing

3. **`capture_health_snapshot()`** - PostgreSQL function
   - Refreshes materialized view for fresh data
   - Iterates all clients, calculates components, inserts snapshot
   - Detects status changes and creates alerts
   - Supports re-runs (upsert on conflict)

**Migration File**: `docs/migrations/20251220_create_health_history_tables.sql`

### API Routes

| Route | Method | Purpose |
|-------|--------|---------|
| `/api/clients/health-history` | GET | Fetch historical data (single client or all sparklines) |
| `/api/clients/health-alerts` | GET | Fetch status change alerts |
| `/api/clients/health-alerts` | PATCH | Acknowledge alerts |
| `/api/cron/health-snapshot` | GET/POST | Trigger daily snapshot (cron job) |

### React Hooks

| Hook | Purpose |
|------|---------|
| `useHealthHistory` | Fetch client's historical data, calculate trend metrics |
| `useHealthSparklines` | Fetch all clients' 30-day sparkline data with caching |
| `useHealthAlerts` | Fetch/acknowledge status change alerts |

### UI Components

1. **HealthTrendChart** (`src/components/charts/HealthTrendChart.tsx`)
   - Full Recharts AreaChart with gradient fill
   - Reference lines at thresholds (70 healthy, 60 at-risk)
   - Custom tooltip showing component breakdown
   - Displays on client detail pages

2. **HealthSparkline** (`src/components/HealthSparkline.tsx`)
   - Lightweight SVG mini chart (80x24px default)
   - Trend indicator with arrow and delta value
   - Colour-coded by trend direction
   - Displays on client profile cards

### Integration Points

1. **Client Detail Page** (`LeftColumn.tsx`)
   - New "Health Score Trend" card below main health score
   - Shows 90-day trend with point delta

2. **Client Profiles Page** (`page.tsx`)
   - Sparklines appear on each client card
   - Shows 30-day trend when data is available

3. **Alert System** (`src/lib/alert-system.ts`)
   - New `health_status_change` alert category added
   - `detectHealthStatusChangeAlerts()` function converts database alerts to standard format
   - Integrated into `detectAllAlerts()` for unified alert detection
   - Alerts shown for status improvements and declines

## Files Created

```
docs/migrations/20251220_create_health_history_tables.sql
src/app/api/clients/health-history/route.ts
src/app/api/clients/health-alerts/route.ts
src/app/api/cron/health-snapshot/route.ts
src/hooks/useHealthHistory.ts
src/hooks/useHealthSparklines.ts
src/hooks/useHealthAlerts.ts
src/components/charts/HealthTrendChart.tsx
src/components/HealthSparkline.tsx
netlify/functions/health-snapshot-scheduled.mts
```

## Files Modified

```
src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx
src/app/(dashboard)/client-profiles/page.tsx
src/lib/alert-system.ts
netlify.toml
```

## Setup Instructions

### 1. Apply Database Migration

Run the SQL migration in Supabase:
```sql
-- Execute docs/migrations/20251220_create_health_history_tables.sql
```

### 2. Regenerate Schema

```bash
npm run introspect-schema
```

### 3. Seed Initial Data

Trigger the first snapshot to populate historical data:
```bash
# Via API (development)
curl http://localhost:3000/api/cron/health-snapshot

# Or via SQL
SELECT capture_health_snapshot();
```

### 4. Configure Cron Job

The cron job is configured as a Netlify scheduled function.

**Add CRON_SECRET to Netlify Environment Variables:**
1. Go to Netlify Dashboard → Site Settings → Environment Variables
2. Add a new variable:
   - Key: `CRON_SECRET`
   - Value: Generate a secure random string (32+ characters)
   - Example: `openssl rand -base64 32`

**Schedule:** Runs daily at 20:00 UTC (6 AM AEST / 7 AM AEDT)

**Files Created:**
- `netlify/functions/health-snapshot-scheduled.mts` - Scheduled function
- Updated `netlify.toml` with functions configuration

**Manual Testing:**
```bash
# Trigger manually via API (development)
curl http://localhost:3000/api/cron/health-snapshot

# Or via SQL
SELECT capture_health_snapshot();
```

## Health Score Formula Reference

Uses the formula from `src/lib/health-score-config.ts`:
- **NPS (40pts)**: `((nps + 100) / 200) * 40`
- **Compliance (50pts)**: `(compliance_percentage / 100) * 50`
- **Working Capital (10pts)**: `(percent_under_90_days / 100) * 10`

**Status Thresholds**:
- Healthy: >= 70 points
- At-Risk: 60-69 points
- Critical: < 60 points

## Testing Checklist

- [x] Migration applies without errors
- [x] Snapshot function creates records for all clients
- [x] Health history API returns correct data
- [x] Trend chart displays on client detail page
- [x] Sparklines display on client profile cards (requires 2+ snapshots for trend)
- [x] Alerts generated when status changes
- [x] Alert acknowledgement works
- [x] Cron job configured with CRON_SECRET in Netlify

## Future Enhancements

- [ ] Email notifications for status changes
- [ ] Configurable snapshot frequency
- [ ] Historical comparison reports
- [ ] Export health history to CSV/Excel
- [ ] Dashboard widget for portfolio health trends
