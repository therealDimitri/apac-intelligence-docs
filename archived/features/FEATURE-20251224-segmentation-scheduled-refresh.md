# Feature: Segmentation Event Compliance Scheduled Refresh

**Date:** 2024-12-24
**Status:** Implemented

## Overview

Implemented automated daily refresh of segmentation event compliance counts. This ensures the `segmentation_event_compliance.actual_count` values stay synchronised with completed events in the `segmentation_events` table.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     Segmentation Data Flow                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────┐     ┌──────────────────┐     ┌────────────────┐  │
│  │  Excel File      │ ──► │ Import Script    │ ──► │ segmentation_  │  │
│  │  (OneDrive)      │     │ (local/manual)   │     │ events         │  │
│  └──────────────────┘     └──────────────────┘     └───────┬────────┘  │
│                                                             │          │
│                                                             ▼          │
│  ┌──────────────────┐     ┌──────────────────┐     ┌────────────────┐  │
│  │  Health Score    │ ◄── │ Scheduled Func   │ ──► │ segmentation_  │  │
│  │  Calculations    │     │ (daily 6am AEDT) │     │ event_         │  │
│  └──────────────────┘     └──────────────────┘     │ compliance     │  │
│                                                     └────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

## Components

### 1. Netlify Scheduled Function

**File:** `netlify/functions/segmentation-refresh.mts`

- Runs daily at 6:00 AM Sydney (19:00 UTC)
- Counts completed events per client per event type
- Updates `actual_count` in compliance table where mismatched
- Refreshes materialised view if available

### 2. API Endpoint

**File:** `src/app/api/cron/segmentation-refresh/route.ts`

- Same logic as scheduled function
- Can be triggered manually for testing
- Authorisation via:
  - Netlify scheduled header (`x-netlify-event: schedule`)
  - Admin API key (`Authorization: Bearer {CRON_SECRET}`)
  - Localhost (development)

### 3. netlify.toml Configuration

```toml
[functions."segmentation-refresh"]
  schedule = "0 19 * * *"  # 6:00 AM Sydney
```

## Schedule

| Time (Sydney AEDT) | Time (UTC) | Frequency |
| ------------------ | ---------- | --------- |
| 6:00 AM            | 7:00 PM    | Daily     |

## Sync Logic

1. **Get Event Types** - Fetch all event types from `segmentation_event_types`
2. **Count Completed Events** - For each type, count completed events per client in current year
3. **Compare with Compliance** - Get compliance records and compare actual_count
4. **Update Mismatches** - Update any records where count differs
5. **Refresh View** - Call `refresh_event_compliance_view()` RPC if available

### Client Name Matching

Uses fuzzy matching with normalisation:

```typescript
function normaliseClientName(name: string): string {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9]/g, '')
    .replace(/health$/, '')
    .replace(/hospital$/, '')
}
```

Matches if:

- Exact normalised match
- One name contains the other

## Response Format

```json
{
  "success": true,
  "timestamp": "2024-12-24T19:00:00.000Z",
  "year": 2024,
  "summary": {
    "eventTypesProcessed": 12,
    "complianceRecordsChecked": 156,
    "recordsUpdated": 3
  },
  "updates": [
    {
      "client": "Example Health",
      "eventType": "Quarterly Business Review",
      "oldCount": 2,
      "newCount": 3
    }
  ]
}
```

## Manual Testing

### Via cURL

```bash
# Development
curl -X POST http://localhost:3000/api/cron/segmentation-refresh

# Production (with auth)
curl -X POST https://your-app.netlify.app/api/cron/segmentation-refresh \
  -H "Authorization: Bearer YOUR_CRON_SECRET"
```

### Via Netlify CLI

```bash
netlify functions:invoke segmentation-refresh --no-identity
```

## Excel Import (Separate Process)

The scheduled refresh only syncs counts from existing database records. To import from the Excel file:

### Local Import Script

```bash
node scripts/import-segmentation-events-2025.mjs
```

### File Watcher (Development)

```bash
node scripts/watch-segmentation-file.mjs
```

**Note:** The Excel file is stored on OneDrive. For fully automated cloud-based import, Microsoft Graph API integration would be required.

## Files

| File                                             | Purpose                      |
| ------------------------------------------------ | ---------------------------- |
| `netlify/functions/segmentation-refresh.mts`     | Scheduled function           |
| `src/app/api/cron/segmentation-refresh/route.ts` | API endpoint                 |
| `netlify.toml`                                   | Schedule configuration       |
| `scripts/import-segmentation-events-2025.mjs`    | Excel import script          |
| `scripts/watch-segmentation-file.mjs`            | File watcher for development |

## Environment Variables Required

- `NEXT_PUBLIC_SUPABASE_URL` - Supabase project URL
- `SUPABASE_SERVICE_ROLE_KEY` - Supabase service role key
- `CRON_SECRET` (optional) - For manual API trigger authorisation
