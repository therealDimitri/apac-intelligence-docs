# Feature Implementation Report: Planning Hub AI API Routes

**Date:** 2026-01-09
**Type:** Feature Implementation
**Status:** Complete
**Component:** Planning Hub API

## Summary

Implemented four new AI-powered API routes for the Account Planning Hub feature, enabling intelligent insights generation, next best actions recommendations, MEDDPICC analysis, and automated plan generation.

## Files Created

### 1. `/src/app/api/planning/ai/insights/route.ts`
**Purpose:** Generate and fetch AI-powered insights for accounts

**Endpoints:**
- `GET /api/planning/ai/insights` - Fetch existing insights
- `POST /api/planning/ai/insights` - Generate new AI insights

**Features:**
- Risk identification and opportunity detection
- Stakeholder analysis recommendations
- Engagement pattern analysis
- Confidence scoring and priority assignment
- Data source tracking
- Insight expiration management
- Caching to prevent duplicate generation

**Query Parameters (GET):**
- `clientId` or `clientName` (required)
- `type` - Filter by insight type
- `includeExpired` - Include expired insights
- `limit` - Maximum results (default: 20)

**Request Body (POST):**
```typescript
{
  clientId?: string
  clientName: string // Required
  planId?: string
  insightTypes?: ('risk' | 'opportunity' | 'action' | 'stakeholder' | 'meddpicc' | 'engagement')[]
  forceRefresh?: boolean
}
```

---

### 2. `/src/app/api/planning/ai/next-best-actions/route.ts`
**Purpose:** Get and manage AI-recommended next best actions

**Endpoints:**
- `GET /api/planning/ai/next-best-actions` - Fetch recommended actions
- `POST /api/planning/ai/next-best-actions` - Generate new recommendations
- `PATCH /api/planning/ai/next-best-actions` - Update action status

**Features:**
- Multi-scope support (client, territory, portfolio)
- Priority scoring algorithm
- Urgency level classification
- Action type categorisation
- Status workflow (pending/accepted/completed/dismissed)
- Trigger reason tracking
- Expiration management

**Action Types:**
- `engagement` - Meeting and check-in recommendations
- `nps_followup` - NPS response follow-ups
- `risk_mitigation` - Health decline interventions
- `relationship` - Stakeholder relationship building
- `financial` - AR and renewal discussions
- `expansion` - Upsell/cross-sell opportunities
- `compliance` - Meeting frequency requirements

---

### 3. `/src/app/api/planning/ai/meddpicc/route.ts`
**Purpose:** MEDDPICC framework analysis and scoring

**Endpoints:**
- `GET /api/planning/ai/meddpicc` - Fetch MEDDPICC scores
- `POST /api/planning/ai/meddpicc` - Generate AI MEDDPICC analysis
- `PATCH /api/planning/ai/meddpicc` - Update manual scores

**Features:**
- Eight MEDDPICC component scoring (0-100)
- AI evidence detection with confidence scores
- Weighted overall score calculation
- Gap analysis generation
- Recommended improvement actions
- Evidence snippet extraction
- Manual score override capability

**MEDDPICC Components:**
| Component | Weight | Description |
|-----------|--------|-------------|
| Metrics | 15% | Quantifiable business outcomes |
| Economic Buyer | 15% | Ultimate decision maker |
| Decision Criteria | 12.5% | Selection requirements |
| Decision Process | 12.5% | Steps to make decision |
| Paper Process | 10% | Legal/procurement steps |
| Identify Pain | 15% | Business challenges |
| Champion | 15% | Internal advocate |
| Competition | 5% | Alternative solutions |

---

### 4. `/src/app/api/planning/ai/generate-plan/route.ts`
**Purpose:** Auto-generate account plan drafts using AI

**Endpoints:**
- `GET /api/planning/ai/generate-plan` - Fetch generated plan components
- `POST /api/planning/ai/generate-plan` - Generate new account plan draft

**Features:**
- Section-by-section generation
- Account and territory plan support
- Integration with existing plan tables
- Comprehensive context gathering
- Automatic draft saving
- Metadata tracking

**Available Sections:**
- `executive_summary` - Strategic overview and key highlights
- `stakeholders` - Stakeholder mapping and engagement strategy
- `engagement` - Engagement scoring and activity planning
- `opportunities` - Identified opportunities with pipeline value
- `risks` - Risk assessment and mitigation strategies
- `action_plan` - Quarterly actions and milestones
- `meddpicc` - MEDDPICC summary
- `financials` - Financial metrics summary

## Database Tables Used

### New Tables (from migration 20260109)
- `account_plan_ai_insights` - Stores generated insights
- `next_best_actions` - Stores recommended actions
- `meddpicc_scores` - Stores MEDDPICC analyses

### Existing Tables Referenced
- `unified_meetings` - Meeting history
- `nps_responses` - NPS feedback data
- `actions` - Action tracking
- `client_health_history` - Health score trends
- `client_segmentation` - Client tier assignments
- `stakeholder_relationships` - Known stakeholders
- `account_plans` - Account plan storage
- `territory_strategies` - Territory plan storage

## AI Integration

All routes use the MatchaAI integration pattern:
- API Key: `MATCHAAI_API_KEY`
- Base URL: `MATCHAAI_BASE_URL`
- Mission ID: `MATCHAAI_MISSION_ID`
- Default Model: Claude Sonnet 4.5 (LLM ID: 71)

## Error Handling

All routes implement:
- Rate limiting via `applyRateLimit()`
- Input sanitisation via `sanitisePrompt()`
- Standardised error responses via `createErrorResponse()`
- Comprehensive logging
- Graceful degradation on AI failures

## Testing

To test the routes locally:

```bash
# Generate insights for a client
curl -X POST http://localhost:3000/api/planning/ai/insights \
  -H "Content-Type: application/json" \
  -d '{"clientName": "Test Client"}'

# Get next best actions for a CSE
curl "http://localhost:3000/api/planning/ai/next-best-actions?cseName=John%20Smith"

# Generate MEDDPICC analysis
curl -X POST http://localhost:3000/api/planning/ai/meddpicc \
  -H "Content-Type: application/json" \
  -d '{"clientName": "Test Client"}'

# Generate account plan draft
curl -X POST http://localhost:3000/api/planning/ai/generate-plan \
  -H "Content-Type: application/json" \
  -d '{"planType": "account", "clientName": "Test Client", "fiscalYear": 2026}'
```

## Related Documentation

- Migration: `supabase/migrations/20260109_planning_hub_enhancements.sql`
- Feature Spec: `docs/features/account-planning-hub-enhancements-v2.md`
- Database Schema: `docs/database-schema.md`

## Future Enhancements

1. Add webhook notifications for high-priority insights
2. Implement batch processing for portfolio-wide analysis
3. Add scheduled regeneration for stale insights
4. Integrate with Microsoft Graph for calendar blocking
5. Add embedding-based semantic search for historical patterns
