# Feature: Webhook Management System

**Date**: 2025-12-21
**Status**: Implemented
**Related Files**:

- `src/lib/webhook-delivery.ts` - Core delivery service
- `src/app/api/webhooks/outbound/route.ts` - CRUD API
- `src/app/api/webhooks/outbound/test/route.ts` - Test endpoint
- `src/app/api/webhooks/invoice-tracker/route.ts` - Inbound webhook receiver
- `src/components/aged-accounts/WebhookConfigModal.tsx` - UI component
- `supabase/migrations/20251221_create_webhook_logs_table.sql` - Migration

## Overview

The webhook management system enables outbound webhook notifications for threshold alerts and other system events. It includes subscription management, HMAC-signed payloads, retry logic with exponential backoff, and delivery logging.

## Features

### 1. Webhook Subscriptions

- Create, read, update, delete webhook subscriptions
- Subscribe to specific event types:
  - `threshold.warning` - Compliance drops below warning threshold
  - `threshold.critical` - Compliance drops below critical threshold
  - `invoice.aging` - Invoices move to older aging buckets
- Auto-generated HMAC secret for payload signing
- Auto-disable after 5 consecutive failures

### 2. Webhook Delivery Service (`src/lib/webhook-delivery.ts`)

- **HMAC-SHA256 Signing**: All payloads are signed with the subscription's secret
- **Retry Logic**: 3 attempts with exponential backoff (1s, 5s, 15s)
- **Timeout**: 10 second request timeout
- **Headers Sent**:
  - `X-Webhook-Signature` - HMAC signature
  - `X-Webhook-Timestamp` - Unix timestamp
  - `X-Webhook-Event` - Event type
  - `X-Webhook-ID` - Unique delivery ID
  - `User-Agent: APAC-Intelligence-Webhook/1.0`

### 3. Test Webhooks

- Send test webhook from UI (lightning bolt icon)
- Test endpoint: `POST /api/webhooks/outbound/test`
- Uses realistic test payload with mock data

### 4. Inbound Webhooks

- Receive webhooks from Invoice Tracker system
- HMAC signature verification
- Timestamp validation (5 minute window)
- Event types: `invoice.created`, `invoice.updated`, `invoice.paid`, `invoice.deleted`

## API Endpoints

### Outbound Subscriptions

```
GET    /api/webhooks/outbound     - List all subscriptions
POST   /api/webhooks/outbound     - Create subscription
PATCH  /api/webhooks/outbound     - Update subscription
DELETE /api/webhooks/outbound?id= - Delete subscription
POST   /api/webhooks/outbound/test - Send test webhook
```

### Inbound (Invoice Tracker)

```
GET  /api/webhooks/invoice-tracker - Health check
POST /api/webhooks/invoice-tracker - Receive webhook
```

## Payload Format

Outbound webhooks send JSON payloads:

```json
{
  "event": "threshold.critical",
  "timestamp": "2025-12-21T10:30:00.000Z",
  "client": {
    "name": "Example Health",
    "compliance_under_60": 85.5,
    "compliance_under_90": 92.3,
    "total_outstanding": 150000
  },
  "threshold": {
    "type": "under_60",
    "target": 90,
    "actual": 85.5,
    "breached": true
  }
}
```

## Signature Verification

Receivers should verify the HMAC-SHA256 signature:

```javascript
const crypto = require('crypto')

function verifySignature(payload, signature, timestamp, secret) {
  const message = `${timestamp}.${payload}`
  const expected = crypto.createHmac('sha256', secret).update(message).digest('hex')

  return signature === expected
}
```

## Database Tables

### webhook_subscriptions

Stores subscription configuration including URL, events, and secret.

### webhook_logs (Optional)

Stores delivery attempts for debugging. Table must be created manually:

```sql
-- Run: supabase/migrations/20251221_create_webhook_logs_table.sql
-- Or use: node scripts/create-webhook-logs-table.mjs
```

## Integration with Aging Alerts

The webhook delivery is integrated with the aging alerts system at:
`src/app/api/aging-alerts/check/route.ts`

When a threshold breach is detected, webhooks are dispatched via `dispatchThresholdBreach()`.

## UI Access

The webhook configuration modal is accessible from the Aged Accounts dashboard via the settings/webhook button (Webhook icon).

## Environment Variables

- `INVOICE_TRACKER_WEBHOOK_SECRET` - Secret for verifying inbound Invoice Tracker webhooks

## Notes

- The webhook_logs table requires manual creation as the direct database connection was not available
- Webhooks are sent in parallel to all active subscriptions
- Failed deliveries increment `failure_count`; after 5 failures, subscription is auto-disabled
