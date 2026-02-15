# Phase 8 API Routes Reference

Phase 8 introduces experimental features across Deal Intelligence, Autonomous Features, Real-Time Intelligence, and Immersive Features.

## Overview

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/volatility` | GET | Portfolio volatility metrics |
| `/api/deals/genome` | GET, POST | Deal pattern analysis |
| `/api/competitors` | GET, POST, DELETE | Competitor event tracking |
| `/api/competitors/insights` | GET | Competitive position analytics |
| `/api/triggers/evaluate` | POST | Event trigger evaluation |
| `/api/escalations` | GET, POST, PUT | Escalation management |
| `/api/briefings/generate` | GET | Executive briefing generation |
| `/api/briefings/audio` | GET | Audio briefing generation |
| `/api/timeline` | GET | Timeline replay data |
| `/api/economic/indicators` | GET, POST | Economic indicators |

---

## Portfolio Volatility

### GET /api/volatility

Returns portfolio volatility metrics for deal velocity tracking.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `cseName` | string | Filter by CSE name |
| `alertsOnly` | boolean | Only return alerts (volatility > threshold) |

**Response:**
```json
{
  "success": true,
  "data": {
    "volatility": [...],
    "alerts": [...],
    "generated_at": "2026-02-05T..."
  }
}
```

---

## Deal Genome Engine

### GET /api/deals/genome

Returns stored deal patterns.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "pattern_name": "Enterprise Healthcare Win",
      "win_rate": 0.72,
      "avg_deal_size": 250000,
      "key_factors": {"champion_identified": 0.9}
    }
  ]
}
```

### POST /api/deals/genome

Extract patterns or analyse a specific deal.

**Request Body:**
```json
{
  "action": "extract" | "analyse",
  "deal_id": "uuid" // required for analyse
}
```

---

## Competitor Tracking

### GET /api/competitors

Returns competitor events.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `client_id` | string | Filter by client |
| `days` | number | Time window (default: 90) |

### POST /api/competitors

Create a competitor event.

**Request Body:**
```json
{
  "client_id": "uuid",
  "competitor_name": "Cerner",
  "event_type": "win" | "loss" | "threat" | "displacement",
  "product_area": "EHR",
  "deal_value": 100000,
  "notes": "Lost renewal",
  "source": "news" | "meeting" | "manual"
}
```

### GET /api/competitors/insights

Returns competitive position analytics.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `days` | number | Time window (default: 90) |

---

## Escalations

### GET /api/escalations

Returns pending escalations.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `status` | string | Filter by status (pending, acknowledged, resolved) |

### POST /api/escalations

Evaluate escalations for client(s).

**Request Body:**
```json
{
  "client_ids": ["uuid1", "uuid2"]
}
```

### PUT /api/escalations

Update escalation status.

**Request Body:**
```json
{
  "escalation_id": "uuid",
  "action": "acknowledge" | "resolve",
  "resolution_notes": "Issue addressed"
}
```

---

## Executive Briefing

### GET /api/briefings/generate

Generate or retrieve cached executive briefing.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `period` | string | daily, weekly, monthly (default: weekly) |
| `cseName` | string | Filter by CSE |
| `refresh` | boolean | Force regeneration |

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "briefing-...",
    "period": "weekly",
    "summary": "AI-generated executive summary...",
    "sections": [...],
    "key_metrics": {
      "total_clients": 45,
      "avg_health_score": 72,
      "at_risk_clients": 3
    }
  }
}
```

---

## Audio Briefing

### GET /api/briefings/audio

Generate spoken audio briefing using OpenAI TTS.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `period` | string | daily, weekly, monthly |
| `cseName` | string | Filter by CSE |
| `voice` | string | alloy, echo, fable, onyx, nova, shimmer |
| `speed` | number | 0.25 to 4.0 (default: 1.0) |
| `format` | string | audio (mp3 stream) or json (base64) |

**Response (format=audio):**
- Content-Type: audio/mpeg
- Headers: X-Duration-Estimate, X-Voice, X-Generated-At

**Response (format=json):**
```json
{
  "success": true,
  "data": {
    "audio_base64": "...",
    "duration_estimate_seconds": 120,
    "script": "Good morning. Here's your daily briefing...",
    "voice": "nova"
  }
}
```

---

## Timeline Replay

### GET /api/timeline

Get timeline data for client history replay.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `client_id` | string | Yes | Client UUID |
| `start_date` | string | No | ISO date (default: 90 days ago) |
| `end_date` | string | No | ISO date (default: today) |
| `granularity` | string | No | day, week, month (default: week) |

**Response:**
```json
{
  "success": true,
  "data": {
    "client_id": "uuid",
    "client_name": "Example Hospital",
    "start_date": "2025-11-01T...",
    "end_date": "2026-02-01T...",
    "states": [
      {
        "timestamp": "2025-11-01T...",
        "health_score": 65,
        "nps_score": 7,
        "arr_usd": 150000,
        "risk_level": "medium"
      }
    ],
    "events": [
      {
        "id": "event-...",
        "timestamp": "2025-11-15T...",
        "type": "health_change",
        "title": "Health score increased",
        "impact": "positive"
      }
    ],
    "key_moments": [...]
  }
}
```

---

## Economic Indicators

### GET /api/economic/indicators

Get economic indicators snapshot.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `refresh` | boolean | Force refresh from sources |
| `region` | string | Filter by region (national, nsw, vic, etc.) |
| `types` | string | Comma-separated indicator types |
| `snapshot` | boolean | Return full analysis (default: true) |

**Response:**
```json
{
  "success": true,
  "data": {
    "generated_at": "2026-02-05T...",
    "indicators": [
      {
        "type": "cash_rate",
        "latest": {
          "name": "RBA Cash Rate Target",
          "value": 4.35,
          "unit": "%"
        },
        "trend": "stable",
        "health_impact": "neutral",
        "health_impact_reason": "Stable rates provide predictable financing"
      }
    ],
    "overall_outlook": "positive",
    "outlook_summary": "Economic conditions favourable..."
  }
}
```

### POST /api/economic/indicators

Trigger indicator refresh from external sources.

**Response:**
```json
{
  "success": true,
  "data": {
    "refreshed_at": "2026-02-05T...",
    "indicator_count": 12
  }
}
```

---

## Database Tables

Phase 8 introduces the following tables:

| Table | Purpose |
|-------|---------|
| `escalation_rules` | Configurable escalation trigger rules |
| `escalations` | Triggered escalation records |
| `executive_briefings` | Cached briefing documents |
| `economic_indicators` | Cached economic data |
| `deal_patterns` | Extracted deal success patterns |
| `competitor_events` | Competitive win/loss tracking |

---

## Error Responses

All endpoints return errors in this format:

```json
{
  "success": false,
  "error": "Error message description"
}
```

Common HTTP status codes:
- `400` - Invalid parameters
- `404` - Resource not found
- `500` - Server error
- `503` - External service unavailable (e.g., OpenAI API)
