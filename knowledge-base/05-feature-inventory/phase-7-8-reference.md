# Phase 7-8 Developer Reference

> Detailed API routes, components, hooks, and integration patterns for Phase 7 (AI Components) and Phase 8 (Automation & Experimental Features).

## Phase 7: AI Components

### Component Locations

- **AI Components**: `/src/components/ai/` - PredictiveInput, LeadingIndicatorAlerts, AnomalyHighlight, AIErrorBoundary, FeedbackButtons
- **Chart Enhancements**: `/src/components/charts/` - CoverageGauge, ForecastChart, HealthRadar, NarrativeDashboard, PipelineWaterfall, SharedCursors

### AI Hooks

- `useAnomalyDetection` - IQR-based statistical outlier detection for time-series data
- `useLeadingIndicators` - Early warning signal detection from portfolio metrics
- `usePredictiveField` - Ghost text suggestions with debounced API calls
- `useImageAnalysis` - Clipboard paste-to-analyse with Claude Vision
- `usePdfIngestion` - PDF upload with progress tracking and text extraction
- `useNaturalLanguageChart` - Convert natural language to chart specifications
- `useDismissalLearning` - Learn from user feedback to filter unwanted suggestions
- `useAmbientAwareness` - Track cursor, scroll, focus for contextual AI

### AI API Routes

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/ai/field-suggestions` | POST | Context-aware field suggestions |
| `/api/ai/analyse-image` | POST | Claude Vision image analysis |
| `/api/ai/analyse-pdf` | POST | PDF content analysis |
| `/api/ai/extract-pdf` | POST | PDF text extraction |
| `/api/ai/generate-chart` | POST | Natural language to chart spec |
| `/api/ai/parse-action` | POST | Natural language command parsing |
| `/api/ai/execute-action` | POST | Execute parsed action |

### Data Transformation Utilities

- `portfolioClientsToMetrics()` - Transform portfolio data for LeadingIndicatorAlerts
- `clientsToHealthDataPoints()` - Transform health scores for AnomalyHighlight
- Located in `src/lib/transform-metrics.ts`

### Integration Pattern

```tsx
// Always wrap AI components in error boundary
<AIErrorBoundary fallback={<ManualInput />}>
  <PredictiveInput
    fieldName="plan_purpose"
    context={{ clientId, planType }}
    onSuggestionAccept={recordAcceptance}
  />
</AIErrorBoundary>
```

### Strategic Planning AI Integration

| Step | Component | AI Features |
|------|-----------|-------------|
| 1. Context | ContextStep | PredictiveInput for Plan Purpose |
| 2. Discovery | DiscoveryDiagnosisStep | LeadingIndicatorAlerts, AnomalyBadge |
| 3. Stakeholder | StakeholderIntelligenceStep | PredictiveInput for Black Swans |
| 4. Opportunity | OpportunityStrategyStep | StoryBrand PredictiveInputs, MEDDPICC Coach |
| 5. Risk | RiskRecoveryStep | PredictiveInput for Mitigation |
| 6. Action | ActionNarrativeStep | PredictiveInput, NextBestActions |

### ESLint Patterns for AI Hooks

- **useState with lazy init**: Use `useState(() => computeInitial())` not `useEffect` + `setState`
- **Date.now() in useMemo**: Track time in state with `setInterval`, not inline calls
- **Refs with null type**: Type as `| null`, initialise in guarded block, use `!` assertion after guard

---

## Phase 8: Experimental Features

### Component Locations

- **Analytics**: `/src/components/analytics/` - CompetitorInsights, VolatilityIndicator
- **Planning**: `/src/components/planning/` - ExecutiveBriefing, TimelineReplay
- **UI**: `/src/components/ui/` - AudioPlayer (AudioBriefingPlayer)

### Phase 8 Hooks

- `useTimelineReplay` - Playback state management for historical timeline scrubbing
- `useHapticFeedback` - Enhanced contextual haptic patterns (stageAdvance, riskAlert, goalAchieved, etc.)
- `useDraftGenerator` - AI email draft generation with context
- `useAutopilotSuggestions` - Fetch and manage autopilot touchpoint suggestions
- `useRecognitionOccasions` - Fetch and manage recognition opportunities

### Phase 8 Components

- **Communications**: `DraftComposer`, `ContextualDraftButton` (also `CheckInButton`, `NPSFollowupButton`, `RenewalButton`)
- **Autopilot**: `AutopilotDashboard`, `TouchpointSuggestionCard`
- **Recognition**: `RecognitionDashboard`, `OccasionCard`

### Phase 8 Page Routes

| Route | Page | Purpose |
|-------|------|---------|
| `/planning/autopilot` | `AutopilotDashboard` | Relationship nurturing touchpoint mgmt |
| `/planning/recognition` | `RecognitionDashboard` | Client recognition occasions & gifts |

### Phase 8 API Routes

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/volatility` | GET | Portfolio volatility metrics |
| `/api/deals/genome` | GET, POST | Deal pattern extraction and analysis |
| `/api/competitors` | GET, POST, DELETE | Competitor event tracking |
| `/api/competitors/insights` | GET | Competitive position analytics |
| `/api/triggers/evaluate` | POST | Event trigger evaluation |
| `/api/escalations` | GET, POST, PUT | Auto-escalation management |
| `/api/briefings/generate` | GET | Executive briefing generation |
| `/api/briefings/audio` | GET | Audio briefing (ElevenLabs → MeloTTS → OpenAI fallback) |
| `/api/timeline` | GET | Timeline replay data |
| `/api/economic/indicators` | GET, POST | Economic indicators snapshot |
| `/api/communications/draft` | GET, POST | AI-generated email drafts |
| `/api/communications/draft/[id]` | GET, PUT, DELETE | Manage individual draft |
| `/api/autopilot/rules` | GET, POST | Relationship autopilot rules |
| `/api/autopilot/rules/[id]` | GET, PUT, DELETE | Manage individual rule |
| `/api/autopilot/suggestions` | GET | Pending touchpoint suggestions |
| `/api/autopilot/suggestions/[id]` | PUT | Confirm/snooze/skip suggestion |
| `/api/recognition/occasions` | GET | Recognition opportunities |
| `/api/recognition/occasions/[id]` | GET, PUT | Manage occasion status |
| `/api/cron/autopilot-evaluate` | GET | Daily autopilot rule evaluation |
| `/api/cron/recognition-detect` | GET | Weekly recognition detection |

### Phase 8 Database Tables

| Table | Purpose |
|-------|---------|
| `escalation_rules` | Configurable escalation trigger rules |
| `escalations` | Triggered escalation records |
| `executive_briefings` | Cached briefing documents |
| `economic_indicators` | Cached economic data from RBA/ABS |
| `communication_drafts` | AI-generated email drafts |
| `relationship_autopilot_rules` | Autopilot nurturing rules |
| `scheduled_touchpoints` | Suggested touchpoints from autopilot |
| `recognition_occasions` | Detected recognition opportunities |
| `recognition_suggestions` | Suggestions per occasion |
| `client_milestones` | Recurring milestone tracking |

### Integration Points

- **Dashboard**: ExecutiveBriefing (compact) + AudioBriefingPlayer after PortfolioHealthStats
- **Client Detail**: TimelineReplay tab in RightColumn
- **Analytics**: CompetitorInsights + VolatilityIndicator after Key Insights section

### Audio Briefing — TTS Provider Chain

Three-tier fallback: **ElevenLabs** (primary) → **MeloTTS** (local) → **OpenAI** (final).

**Environment variables:**
| Variable | Required | Description |
|---|---|---|
| `ELEVENLABS_API_KEY` | Yes (primary) | ElevenLabs API key. Free tier: 10K chars/month (~3 briefings) |
| `MELOTTS_URL` | No | MeloTTS server URL (default: `http://localhost:5050`) |
| `OPENAI_API_KEY` | No | OpenAI fallback. Only used if both ElevenLabs and MeloTTS fail |

**Voices (12 total across 3 providers):**
| Provider | Voices | Default | Notes |
|---|---|---|---|
| ElevenLabs | `charlie`, `daniel`, `george` | `charlie` | Charlie = Australian male, natural. Uses `eleven_multilingual_v2` model |
| MeloTTS | `EN-AU`, `EN-BR`, `EN-US` | `EN-AU` | Local Python server (`prototypes/tts-eval/melotts-server.py`). Returns WAV |
| OpenAI | `alloy`, `echo`, `fable`, `onyx`, `nova`, `shimmer` | `echo` | Uses `tts-1-hd` model. Returns MP3 |

**Voice mapping (ElevenLabs → OpenAI fallback):** When ElevenLabs fails and OpenAI is used as fallback, voices are mapped to preserve gender/character: `charlie` → `echo` (warm male), `daniel` → `onyx` (authoritative male), `george` → `fable` (expressive male).

**Smart routing:** Requesting an OpenAI voice skips straight to OpenAI. Requesting a MeloTTS voice starts from MeloTTS. ElevenLabs voices try the full chain.

**Running MeloTTS locally:**
```bash
source prototypes/tts-eval/.venv/bin/activate
python prototypes/tts-eval/melotts-server.py
# POST /tts {text, speaker, speed} → audio/wav
# GET /health → {status: "ok"}
```

**API response:** Returns MP3 (ElevenLabs/OpenAI) or WAV (MeloTTS). JSON format includes `provider` field. Headers include `X-Provider` and `X-Voice`.

### Executive Briefing Structure

The executive briefing (`src/lib/executive-briefing.ts`) generates comprehensive operational reports with 12 data sections:

**Strategic Sections:**
1. **Portfolio Health** - `getPortfolioHealth()` queries `portfolio_clients`
2. **Opportunities** - `getOpportunities()` queries `pipeline_deals`
3. **Financial Performance** - `getFinancialSummary()` queries `burc_annual_financials` (authoritative source)

**Operational Sections:**
4. **CS Operating Rhythm** - `getOperatingRhythmProgress()` queries `segmentation_events`
5. **Segmentation Progress** - `getSegmentationProgress()` queries `event_compliance_summary`
6. **Meeting Activity** - `getMeetingActivity()` queries `unified_meetings`

**Risk Management Sections:**
7. **Risk Alerts** - `getRiskAlerts()` queries `escalations`
8. **Pending Actions** - `getRecommendedActions()` queries `actions` (capitalized columns: `Status`, `Due_Date`)
9. **Working Capital** - `getWorkingCapital()` queries `aging_accounts`

**Customer Voice Sections:**
10. **NPS Analytics** - `getNPSSummary()` queries `nps_responses`
11. **Support Health** - `getSupportHealth()` queries `support_sla_latest` VIEW (NOT `support_cases`)
12. **News Highlights** - `getNewsHighlights()` queries `news_articles`

**Key Implementation Details:**
- All sections query in parallel via `Promise.all()`
- AI summary uses Matcha AI with coach-like, encouraging tone
- Caching via `executive_briefings` table (4h daily, 24h weekly)
- Cache bypass: `?refresh=true` query param
- Clear cache: `DELETE FROM executive_briefings;`

**Data Source Validation (Critical):**
- Support Health: Uses `support_sla_latest` VIEW (not `support_cases`) — returns 0 if wrong table
- Working Capital: Uses `aging_accounts` with `days_91_to_120`, `days_121_to_180` (not `ar_aging`)
