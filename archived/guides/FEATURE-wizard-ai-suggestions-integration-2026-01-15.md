# Feature: Planning Wizard AI Suggestions Integration

**Date:** 2026-01-15
**Status:** Implemented
**Type:** New Feature

## Summary

Added backend API endpoints to generate AI-powered suggestions for the strategic planning wizard. The system uses client data from multiple sources (meeting notes, NPS responses, health history, aging accounts) to provide intelligent pre-population of wizard fields.

## Components Created

### 1. Data Gatherer (`/src/lib/planning/wizard-ai-data-gatherer.ts`)

Gathers client-specific data from Supabase for AI context:

- **Discovery Step**: Health history, meetings, NPS responses, actions, financials
- **Stakeholder Step**: Meeting attendees, NPS contacts, attendance frequency
- **Opportunity Step**: Client segmentation, health data, meeting insights
- **Risk Step**: Health alerts, NPS detractors, overdue AR, overdue actions

Key functions:
- `gatherDiscoveryData()` - Collects data for Gap Selling methodology
- `gatherStakeholderData()` - Collects stakeholder/contact information
- `gatherOpportunityData()` - Collects expansion/growth indicators
- `gatherRiskData()` - Collects risk signals and warning signs
- `gatherDataForStep()` - Main entry point that routes to correct gatherer
- `checkDataSufficiency()` - Validates if enough data exists for AI

### 2. Prompt Templates (`/src/lib/planning/wizard-ai-prompts.ts`)

Step-specific AI prompts following established methodologies:

- **Discovery**: Gap Selling framework (problems, suffering, future state, root cause)
- **Stakeholder**: Voss negotiation techniques (black swans, calibrated questions)
- **Opportunity**: MEDDPICC + StoryBrand narrative
- **Risk**: Accusation Audit + Recovery Story approaches

All prompts:
- Use Australian English
- Request JSON response format
- Include confidence scoring criteria
- Provide specific field suggestions

### 3. Response Parser (`/src/lib/planning/wizard-ai-parser.ts`)

Handles AI response processing:

- Cleans markdown code blocks from responses
- Parses and validates JSON structure
- Transforms to `AISuggestion[]` format
- Validates confidence levels (high/medium/low)
- In-memory caching with 5-minute TTL
- Generates rule-based fallback suggestions when AI unavailable

### 4. API Route (`/src/app/api/planning/wizard/ai-suggestions/route.ts`)

POST endpoint for AI suggestions:

**Request:**
```typescript
{
  clientName: string;
  clientId?: string;
  step: 'discovery' | 'stakeholder' | 'opportunity' | 'risk';
  portfolioContext?: {
    territory?: string;
    segment?: string;
    healthScore?: number;
    nps?: number;
  };
  forceRefresh?: boolean;
}
```

**Response:**
```typescript
{
  success: true;
  data: {
    suggestions: AISuggestion[];
    evidence: DataEvidence[];
    dataGaps?: string[];
    generatedAt: string;
    model: string;
  };
  cached?: boolean;
}
```

Features:
- Rate limiting (20 requests/minute)
- Caching with data hash validation
- Fallback suggestions on AI failure
- Data sufficiency checking

### 5. Hook Update (`/src/hooks/useQuestionnaireAI.ts`)

Updated to use new endpoint instead of legacy ChaSen methodology API.

## Data Flow

```
User clicks "AI Ready" badge
        ↓
useQuestionnaireAI hook
        ↓
POST /api/planning/wizard/ai-suggestions
        ↓
Check cache (5-min TTL + data hash)
        ↓ (cache miss)
gatherDataForStep() → Supabase queries
        ↓
checkDataSufficiency()
        ↓ (sufficient data)
buildPromptForStep()
        ↓
callMatchaAI() → MatchaAI API
        ↓
parseAIResponse()
        ↓
cacheSuggestions()
        ↓
Return suggestions + evidence
```

## AI Provider

Uses MatchaAI corporate proxy:
- Model: `claude-sonnet-4-5` (LLM ID: 28)
- Temperature: 0.7
- Max tokens: 4096
- Timeout: 45 seconds

## Fallback Behaviour

When AI is unavailable or insufficient data exists:
1. Rule-based suggestions generated from available data
2. Health score thresholds trigger specific suggestions
3. NPS score < 7 triggers satisfaction-related suggestions
4. Segment classification provides contextual suggestions
5. Detractor presence triggers Accusation Audit suggestions
6. Overdue items trigger action-focused suggestions

## Testing

1. Navigate to `/planning/strategic/new`
2. Select owner (e.g., Dimitri Leimonitis)
3. Go to Step 2 (Discovery & Diagnosis)
4. Click the "AI Ready" badge
5. Verify suggestions appear with confidence levels and evidence

## Files Changed

| File | Change |
|------|--------|
| `src/lib/planning/wizard-ai-data-gatherer.ts` | New file |
| `src/lib/planning/wizard-ai-prompts.ts` | New file |
| `src/lib/planning/wizard-ai-parser.ts` | New file |
| `src/app/api/planning/wizard/ai-suggestions/route.ts` | New file |
| `src/hooks/useQuestionnaireAI.ts` | Updated to use new endpoint |

## Future Enhancements

1. Add support for 'action' step suggestions
2. Implement Redis caching for multi-instance deployments
3. Add streaming response support for large suggestions
4. Enhance fallback suggestions with more data sources
5. Add A/B testing for different prompt variations
