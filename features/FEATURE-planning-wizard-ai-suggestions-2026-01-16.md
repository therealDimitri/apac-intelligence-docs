# Feature: Planning Wizard AI Suggestions

**Date:** 2026-01-16
**Type:** Enhancement
**Status:** ✅ Implemented

## Overview

AI-powered suggestions for the strategic planning wizard that analyse client data, meeting notes, NPS responses, and other data sources to pre-populate form fields with intelligent recommendations.

## Architecture

### New Files Created

1. **`/src/app/api/planning/wizard/ai-suggestions/route.ts`**
   - Main API endpoint for generating AI suggestions
   - Rate limiting: 20 requests per minute per user
   - Returns suggestions with confidence levels and data evidence

2. **`/src/lib/planning/wizard-ai-data-gatherer.ts`**
   - Data gathering functions for each wizard step
   - Queries multiple data sources in parallel for efficiency
   - Implements data sufficiency checks

3. **`/src/lib/planning/wizard-ai-prompts.ts`**
   - Step-specific prompt templates for each methodology
   - Gap Selling prompts for Discovery step
   - Voss negotiation prompts for Stakeholder step
   - MEDDPICC + StoryBrand prompts for Opportunity step
   - Accusation Audit + Recovery Story prompts for Risk step

4. **`/src/lib/planning/wizard-ai-parser.ts`**
   - Response parsing and validation
   - Confidence level normalisation
   - Fallback suggestion generation
   - In-memory caching with 5-minute TTL

### Files Modified

1. **`/src/hooks/useQuestionnaireAI.ts`**
   - Updated to call the new endpoint
   - Maintains client-side caching
   - Handles error states gracefully

## API Design

### Request
```typescript
POST /api/planning/wizard/ai-suggestions
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

### Response
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

## Data Sources Per Step

### 1. Discovery & Diagnosis (Gap Selling)
| Data Source | Purpose |
|-------------|---------|
| `client_health_history` | Health trends, score changes |
| `unified_meetings` | Topics, risks, sentiment, AI summaries |
| `nps_responses` + `nps_topic_classifications` | Themes, scores |
| `actions` | Open/overdue actions |
| `aging_accounts` | Financial stress indicators |

**Generates suggestions for:**
- Current problems understanding
- Desired future state
- Quantified gap impact
- Root cause analysis
- Cost of inaction

### 2. Stakeholder Intelligence (Voss)
| Data Source | Purpose |
|-------------|---------|
| `unified_meetings.attendees` | Meeting participants, frequency |
| `nps_responses` | Contact details, roles, scores |

**Generates suggestions for:**
- Career goals per stakeholder
- Political dynamics
- "That's Right" moments
- Unspoken concerns
- Calibrated questions

### 3. Opportunity Strategy (MEDDPICC/StoryBrand)
| Data Source | Purpose |
|-------------|---------|
| `client_segmentation` | Tier, CSE, segment |
| `client_health_history` | Expansion indicators |
| `unified_meetings` | Decision process insights |

**Generates suggestions for:**
- MEDDPICC element assessments (Metrics, Economic Buyer, etc.)
- StoryBrand narrative (Hero, Villain, Guide, Plan, Success Vision)

### 4. Risk & Recovery
| Data Source | Purpose |
|-------------|---------|
| `health_status_alerts` | Health status changes |
| `nps_responses` (detractors) | Low score feedback |
| `aging_accounts` | Overdue amounts |
| `actions` (overdue) | Missed commitments |

**Generates suggestions for:**
- Risk descriptions
- Accusation audit statements
- Empathy response frameworks
- Recovery story suggestions

## Caching Strategy

- **Server-side**: In-memory cache with 5-minute TTL
- **Cache key**: `wizard-ai-${step}-${clientName}`
- **Invalidation**: On data hash change
- **Force refresh**: Supported via `forceRefresh` flag

## Error Handling

| Scenario | Response |
|----------|----------|
| Insufficient data | Empty suggestions with `dataGaps` array |
| AI failure | Rule-based fallback suggestions |
| Timeout (45s) | Return partial results if available |
| Rate limit | 429 response with retry-after header |

## AI Provider

Uses **MatchaAI** provider via existing integration:
- Model: `claude-sonnet-4-5` (ID 28)
- Temperature: 0.7
- Max tokens: 4096
- Timeout: 45 seconds

## Usage

### In React Component
```tsx
import { useQuestionnaireAI } from '@/hooks/useQuestionnaireAI'

function WizardStep() {
  const { state, loadSuggestions, applySuggestion } = useQuestionnaireAI()

  const handleLoadSuggestions = async () => {
    await loadSuggestions(currentStep, {
      clientName: 'Example Client',
      territory: 'ANZ',
      healthScore: 75,
      nps: 45,
    })
  }

  return (
    <div>
      {state.suggestions.map(suggestion => (
        <SuggestionCard
          key={suggestion.fieldId}
          suggestion={suggestion}
          onApply={() => applySuggestion(suggestion.fieldId, suggestion.suggestedValue, setValue)}
        />
      ))}
    </div>
  )
}
```

### Via API
```bash
curl -X POST https://apac-cs-dashboards.com/api/planning/wizard/ai-suggestions \
  -H "Content-Type: application/json" \
  -d '{
    "clientName": "Example Client",
    "step": "discovery",
    "portfolioContext": {
      "territory": "ANZ",
      "healthScore": 75
    }
  }'
```

## Verification

```bash
# Build verification
npm run build

# Manual test
1. Navigate to /planning/strategic/new
2. Select owner and proceed to Step 2 (Discovery)
3. Click "AI Ready" badge or load suggestions button
4. Verify suggestions appear with confidence indicators
5. Verify evidence sources are displayed
6. Apply suggestions and verify form population
```

## Related

- `/api/chasen/methodology` - Legacy ChaSen AI endpoint
- `/api/planning/ai/insights` - General AI insights
- `useQuestionnaireAI` hook - Client-side integration
- `AISuggestion` type in `/src/lib/planning/types.ts`
