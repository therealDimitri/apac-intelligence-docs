# Phase 3 & 4 API Reference

Documentation for the dashboard data connection enhancements implemented in Phases 3 and 4.

---

## Table of Contents

1. [Predictive Health Alerting](#predictive-health-alerting)
2. [Real-Time BURC Pipeline](#real-time-burc-pipeline)
3. [Graph Relationship Engine](#graph-relationship-engine)
4. [Federated Query Engine](#federated-query-engine)

---

## Predictive Health Alerting

### Overview

ML-lite algorithms that detect clients at risk before problems materialise. Generates alerts for:
- Predicted health decline (30/90 day projections)
- High churn risk detection
- Engagement velocity decline
- Peer underperformance
- Expansion opportunities (positive alerts)

### Endpoints

#### GET /api/alerts/predictive

Fetch predictive alerts for all clients or a specific client.

**Authentication:** Session required

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `clientId` | string | Filter alerts for specific client UUID |
| `clientName` | string | Filter alerts for specific client name |
| `churnCheck` | boolean | Quick churn risk check mode |

**Response:**

```json
{
  "success": true,
  "data": {
    "alerts": [
      {
        "id": "pred-health-decline-ClientName-2026-01-26",
        "clientId": "uuid",
        "clientName": "Client Name",
        "type": "health_trajectory",
        "severity": "critical",
        "title": "Predicted Health Decline",
        "description": "Client Name's health score is projected to drop by 18 points...",
        "confidence": 0.85,
        "predictedValue": 52,
        "currentValue": 70,
        "recommendedActions": ["Schedule executive check-in", "Review recent NPS feedback"]
      }
    ],
    "clientsAnalysed": 36,
    "alertCount": 12,
    "summary": {
      "critical": 2,
      "high": 4,
      "medium": 4,
      "low": 2
    },
    "byCategory": {
      "health_trajectory": 3,
      "churn_risk": 2,
      "engagement_decline": 3,
      "peer_underperformance": 2,
      "expansion_opportunity": 2
    }
  }
}
```

#### POST /api/alerts/predictive

Manually trigger predictive alert detection and persistence.

**Authentication:** Session required

**Request Body:**

```json
{
  "persist": true,
  "autoCreateActions": true
}
```

**Response:** Same as GET with additional persistence stats.

---

#### GET /api/cron/predictive-health-alerts

Cron endpoint for scheduled predictive alert detection.

**Authentication:** Bearer token (CRON_SECRET)

**Schedule:** Daily at 7:00 AM AEST

**Headers:**
```
Authorization: Bearer {CRON_SECRET}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "summary": {
      "clients_analysed": 36,
      "alerts_detected": 15,
      "alerts_persisted": 15,
      "new_alerts": 8,
      "duplicates": 7,
      "actions_created": 2
    },
    "duration_ms": 4523
  }
}
```

---

## Real-Time BURC Pipeline

### Overview

Real-time BURC data synchronisation using webhooks, file change detection, and push notifications.

### Endpoints

#### POST /api/webhooks/burc

Webhook endpoint for external BURC sync triggers.

**Authentication:** Webhook secret (x-webhook-secret header or Bearer token)

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `action` | string | Action type (see below) |

**Actions:**

| Action | Description |
|--------|-------------|
| `trigger-sync` | Trigger a new BURC sync (default) |
| `file-changed` | Notify of file changes |
| `sync-complete` | Notify sync completion |
| `check-file` | Check if BURC file has changed |
| `update-registry` | Update file registry after sync |

**Request Body (trigger-sync):**

```json
{
  "scope": "all",
  "year": 2026,
  "triggeredBy": "external-system",
  "force": false
}
```

**Request Body (file-changed):**

```json
{
  "filePath": "/path/to/file.xlsx",
  "fileHash": "abc123...",
  "lastModified": "2026-01-26T10:30:00Z",
  "triggeredBy": "onedrive-watcher"
}
```

**Request Body (sync-complete):**

```json
{
  "batchId": "uuid",
  "recordsInserted": 150,
  "recordsUpdated": 45,
  "recordsDeleted": 3,
  "tablesUpdated": ["burc_ebita_monthly", "burc_arr"],
  "errors": []
}
```

**Response (trigger-sync):**

```json
{
  "success": true,
  "data": {
    "message": "BURC sync triggered",
    "batchId": "uuid",
    "scope": "all",
    "status": "pending"
  }
}
```

#### GET /api/webhooks/burc

Check webhook status and recent events.

**Authentication:** Webhook secret required

**Response:**

```json
{
  "success": true,
  "data": {
    "webhookStatus": "active",
    "syncThrottle": {
      "canSync": true,
      "lastSyncAt": "2026-01-26T09:00:00Z",
      "waitMs": 0
    },
    "recentSyncs": [...],
    "recentEvents": [...],
    "fileRegistry": [...]
  }
}
```

---

#### GET /api/cron/burc-file-watcher

Cron endpoint for periodic BURC file change detection.

**Authentication:** Bearer token (CRON_SECRET)

**Schedule:** Every 15 minutes during business hours (6 AM - 8 PM AEST, Mon-Fri)

**Response:**

```json
{
  "success": true,
  "data": {
    "status": "change_detected",
    "changeEvent": {
      "type": "file_changed",
      "filePath": "/path/to/file.xlsx",
      "previousHash": "abc123",
      "currentHash": "def456"
    },
    "autoSync": {
      "enabled": false,
      "triggered": false,
      "batchId": null
    },
    "duration_ms": 234
  }
}
```

---

## Graph Relationship Engine

### Overview

Graph-based relationship discovery and querying for:
- Client ↔ CSE relationships (assignment history, meeting frequency)
- Client ↔ Contact relationships (stakeholders, influence levels)
- Client ↔ Client relationships (shared CSE, same tier, business groups)

### Endpoints

#### GET /api/graph/relationships

Query relationships with filters.

**Authentication:** Session required

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `clientName` | string | Get relationships for specific client |
| `entityId` | string | Filter by entity ID |
| `entityType` | string | Filter by entity type (client, cse, contact) |
| `relationshipType` | string | Filter by relationship type |
| `minStrength` | number | Minimum relationship strength (0-100) |
| `minConfidence` | number | Minimum confidence (0-1) |
| `limit` | number | Max results (default 50) |
| `summary` | boolean | Return graph summary statistics |
| `insights` | boolean | Return AI-ready insights for client |
| `contacts` | boolean | Return ranked contacts for client |
| `related` | boolean | Return related clients |

**Example: Get related clients**
```
GET /api/graph/relationships?clientName=Acme%20Corp&related=true
```

**Response:**

```json
{
  "success": true,
  "data": {
    "clientName": "Acme Corp",
    "relatedClients": [
      {
        "client": "Beta Industries",
        "relationship": {
          "id": "client-client-cse-Acme Corp-Beta Industries",
          "relationshipType": "related_to",
          "strength": 65,
          "confidence": 0.8,
          "metadata": {
            "notes": "Shared CSE: john.smith@alterahealth.com"
          }
        }
      }
    ],
    "relatedCount": 3
  }
}
```

**Example: Get graph summary**
```
GET /api/graph/relationships?summary=true
```

**Response:**

```json
{
  "success": true,
  "data": {
    "summary": {
      "totalEntities": 156,
      "totalRelationships": 423,
      "averageStrength": 48.5,
      "strongRelationships": 87,
      "byType": {
        "assigned_to": 36,
        "has_contact": 312,
        "related_to": 75
      }
    }
  }
}
```

**Example: Get client insights**
```
GET /api/graph/relationships?clientName=Acme%20Corp&insights=true
```

**Response:**

```json
{
  "success": true,
  "data": {
    "clientName": "Acme Corp",
    "insights": [
      {
        "type": "common_cse",
        "relatedEntities": [
          {"id": "Beta Industries", "type": "client", "name": "Beta Industries"}
        ],
        "explanation": "Acme Corp shares a CSE with Beta Industries. Consider cross-pollination of best practices.",
        "confidence": 0.85
      },
      {
        "type": "shared_contact",
        "relatedEntities": [
          {"id": "john.doe@acme.com", "type": "contact", "name": "john.doe@acme.com"}
        ],
        "explanation": "Acme Corp's most engaged stakeholders are john.doe@acme.com based on meeting attendance and NPS responses.",
        "confidence": 0.9
      }
    ]
  }
}
```

#### POST /api/graph/relationships

Refresh relationships for a client or trigger full refresh.

**Request Body:**

```json
{
  "clientName": "Acme Corp"
}
```

Or for full refresh:

```json
{
  "fullRefresh": true
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "message": "Relationships refreshed for Acme Corp",
    "clientName": "Acme Corp",
    "cseRelationships": 1,
    "contactRelationships": 15,
    "clientRelationships": 4,
    "totalRelationships": 20
  }
}
```

---

## Federated Query Engine

### Overview

Unified query interface across 13 data sources with parallel execution, schema introspection, and cross-source aggregation.

### Available Data Sources

| Source | Tables | Client Identifier |
|--------|--------|-------------------|
| `clients` | nps_clients, client_segmentation | client_name |
| `nps` | nps_responses | client_name |
| `meetings` | unified_meetings | client_name |
| `actions` | actions | client |
| `health` | client_health_history | client_name |
| `burc_financial` | burc_ebita_monthly, burc_waterfall, burc_arr | client_name |
| `burc_pipeline` | burc_ps_pipeline | client |
| `burc_nrr` | burc_nrr | client_name |
| `compliance` | segmentation_events, segmentation_event_compliance | client_name |
| `chasen_knowledge` | chasen_knowledge | client_name |
| `planning` | portfolio_initiatives | client_name |
| `alerts` | health_status_alerts | client_name |
| `notifications` | notifications | user_email |

### Endpoints

#### GET /api/federated/query

Quick queries and schema introspection.

**Authentication:** Session required

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `clientName` | string | Get comprehensive client data |
| `cseEmail` | string | Get CSE dashboard data |
| `aggregate` | boolean | Return aggregated summary (with clientName) |
| `schema` | string | Get schema (use "all" or source name) |
| `field` | string | Find sources containing field |
| `joinable` | string | Find joinable sources for given source |
| `includeBURC` | boolean | Include BURC data (with clientName) |
| `dateFrom` | string | Filter from date (ISO format) |
| `dateTo` | string | Filter to date (ISO format) |

**Example: Get all schemas**
```
GET /api/federated/query?schema=all
```

**Response:**

```json
{
  "success": true,
  "data": {
    "schemas": {
      "clients": {
        "source": "clients",
        "tables": ["nps_clients", "client_segmentation"],
        "primaryKey": "id",
        "clientIdentifier": "client_name",
        "availableFields": ["client_name", "segment", "arr", "health_score", "cse_name"],
        "dateFields": ["effective_from", "effective_to", "created_at"]
      }
    },
    "availableSources": ["clients", "nps", "meetings", "actions", "health", ...]
  }
}
```

**Example: Get aggregated client data**
```
GET /api/federated/query?clientName=Acme%20Corp&aggregate=true
```

**Response:**

```json
{
  "success": true,
  "data": {
    "clientName": "Acme Corp",
    "summary": {
      "npsCount": 8,
      "npsAverage": 7.5,
      "meetingCount": 24,
      "actionCount": 15,
      "openActions": 3,
      "alertCount": 2,
      "openAlerts": 1,
      "lastMeetingDate": "2026-01-20",
      "lastNPSDate": "2026-01-15",
      "healthScore": 72,
      "healthTrend": "stable"
    },
    "sourceAvailability": {
      "clients": true,
      "nps": true,
      "meetings": true,
      "actions": true,
      "health": true,
      "alerts": true
    }
  }
}
```

**Example: Find sources with a field**
```
GET /api/federated/query?field=health_score
```

**Response:**

```json
{
  "success": true,
  "data": {
    "field": "health_score",
    "sources": ["clients", "health"],
    "sourceCount": 2
  }
}
```

#### POST /api/federated/query

Execute custom federated query across multiple sources.

**Request Body:**

```json
{
  "sources": ["clients", "nps", "meetings", "health"],
  "clientFilter": {
    "clientName": "Acme Corp"
  },
  "dateFilter": {
    "from": "2025-07-01",
    "to": "2026-01-26"
  },
  "limit": 50,
  "enableCache": true,
  "cacheTTL": 300
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "data": {
      "clients": [...],
      "nps": [...],
      "meetings": [...],
      "health": [...]
    },
    "metadata": {
      "sources": [
        {"source": "clients", "recordCount": 1, "executionTimeMs": 45, "fromCache": false},
        {"source": "nps", "recordCount": 8, "executionTimeMs": 52, "fromCache": false},
        {"source": "meetings", "recordCount": 24, "executionTimeMs": 67, "fromCache": false},
        {"source": "health", "recordCount": 12, "executionTimeMs": 38, "fromCache": false}
      ],
      "executionTimeMs": 123,
      "fromCache": false,
      "totalRecords": 45
    }
  }
}
```

**Example: BURC Financial Query**

```json
{
  "queryType": "burc_financial",
  "burcYear": 2026,
  "burcClients": ["Acme Corp", "Beta Industries"]
}
```

---

## Error Responses

All endpoints return errors in a consistent format:

```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Authentication required"
  }
}
```

Common error codes:
- `UNAUTHORIZED` (401) - Authentication required or invalid
- `VALIDATION_ERROR` (400) - Invalid request parameters
- `NOT_FOUND` (404) - Resource not found
- `THROTTLED` (429) - Rate limited (sync throttling)
- `DATABASE_ERROR` (500) - Database operation failed

---

## Real-Time Subscriptions

The `useRealtimeSubscriptions` hook now includes BURC table listeners:

```tsx
import { useRealtimeSubscriptions } from '@/hooks/useRealtimeSubscriptions'

function Dashboard() {
  useRealtimeSubscriptions({
    onBURCDataChange: (tableName) => {
      console.log(`BURC table ${tableName} changed`)
      // Refetch BURC data
    },
    onBURCSyncChange: () => {
      console.log('Sync status changed')
      // Update sync status indicator
    },
    onBURCEventBroadcast: () => {
      console.log('New BURC event broadcast')
      // Show notification
    }
  })

  return <div>...</div>
}
```

**BURC Tables Monitored:**
- burc_ebita_monthly
- burc_waterfall
- burc_client_maintenance
- burc_ps_pipeline
- burc_nrr
- burc_arr
- burc_quarterly_data
- burc_ps_margins
- burc_sync_batches
- burc_realtime_events

---

## Configuration

### Environment Variables

```env
# Predictive Health Alerting
CRON_SECRET=your-cron-secret

# BURC Webhook
BURC_WEBHOOK_SECRET=your-webhook-secret

# Optional: Custom thresholds stored in predictive_alert_thresholds table
```

### BURC Sync Configuration

Located in `src/lib/burc-config.ts`:

```typescript
export const BURC_SYNC_CONFIG = {
  watchInterval: 60000,      // 1 minute
  minSyncInterval: 300000,   // 5 minutes
  enableAutoSync: false,     // Set true to auto-sync on file change
  notifyOnChange: true,      // Send push notifications
}
```
