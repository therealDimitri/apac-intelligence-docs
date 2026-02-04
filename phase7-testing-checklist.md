# Phase 7 AI Integration - Testing Checklist

## ✅ Automated Tests (Completed)

- [x] All 118 Jest unit tests passing
- [x] TypeScript compilation successful (no errors)
- [x] Production build successful
- [x] ESLint checks passing
- [x] Pre-commit hooks passing

---

## Manual Browser Testing

### Test Environment Setup
- Start dev server: `npm run dev -- -p 3001`
- Open: http://localhost:3001

### A. AI Test Pages

#### `/test-ai` - AI Components Sandbox
- [ ] Page loads without errors
- [ ] PredictiveInput tab:
  - [ ] Ghost text appears after typing
  - [ ] Tab key accepts suggestion
  - [ ] Escape key dismisses suggestion
  - [ ] Multiple suggestions dropdown works
- [ ] Screenshot Analysis tab:
  - [ ] Paste image (Cmd+V) triggers analysis
  - [ ] Analysis results display correctly
- [ ] PDF Ingestion tab:
  - [ ] File upload works
  - [ ] Progress indicator shows
  - [ ] Extracted content displays
- [ ] Natural Language Charts tab:
  - [ ] Query input works
  - [ ] Chart generates from description
- [ ] Anomaly Detection tab:
  - [ ] Outlier badges appear on anomalous data
  - [ ] Tooltips show explanation
- [ ] Leading Indicators tab:
  - [ ] Alert cards display
  - [ ] Urgency levels color-coded

#### `/test-charts` - Chart Components
- [ ] Page loads without errors
- [ ] CoverageGauge renders correctly
- [ ] ForecastChart displays data
- [ ] HealthRadar shows metrics
- [ ] PipelineWaterfall visualises stages
- [ ] SharedCursors shows collaborator positions

---

### B. Strategic Planning Workflow

Navigate to: `/planning/strategic/new`

#### Step 1: Setup & Context
- [ ] Select CSE (John Salisbury or other)
- [ ] Portfolio loads correctly
- [ ] AI suggestions appear (if enabled)
- [ ] PredictiveInput for Plan Purpose:
  - [ ] Ghost text suggestions appear
  - [ ] Tab accepts, Escape dismisses

#### Step 2: Discovery & Diagnosis
- [ ] Portfolio health data loads
- [ ] LeadingIndicatorAlerts display:
  - [ ] Correct urgency levels (Critical/High/Medium)
  - [ ] Alert cards are actionable
- [ ] AnomalyBadge on outlier metrics:
  - [ ] Badge appears on anomalous values
  - [ ] Hover tooltip shows explanation
- [ ] Gap Analysis scores work

#### Step 3: Stakeholder Intelligence
- [ ] AIPrePopulation panel shows (if suggestions exist)
- [ ] Apply AI suggestion button works
- [ ] Apply All button works
- [ ] Add stakeholder form works
- [ ] Voss methodology scoring (1-5) works
- [ ] Black Swan discovery field accepts input
- [ ] Calibrated Questions can be added

#### Step 4: Opportunity Strategy
- [ ] AIPrePopulation panel displays
- [ ] MEDDPICC scoring (1-5) works
- [ ] Opportunity selection works
- [ ] StoryBrand narrative fields work

#### Step 5: Risk & Recovery
- [ ] Risk categorisation works
- [ ] Mitigation strategies input
- [ ] PredictiveInput for fields (if implemented)

#### Step 6: Action & Narrative
- [ ] AIPrePopulation panel shows (newly added)
- [ ] Apply suggestion works
- [ ] Add Action button works
- [ ] Action list displays correctly
- [ ] Edit action modal works
- [ ] Readiness assessment scores work

#### Save & Persist
- [ ] Save plan button works
- [ ] Data persists to Supabase
- [ ] Reload page shows saved data

---

### C. ChaSen AI Integration

#### Test ChaSen with Planning Context
1. Navigate to `/planning/strategic/new`
2. Select a client
3. Open ChaSen AI chat (Cmd+K or click icon)
4. Ask: "What are the key risks for [client name]?"
5. Verify:
   - [ ] ChaSen responds with relevant context
   - [ ] Response includes client-specific data
   - [ ] No errors in console

---

### D. Supabase Data Flow

#### Tables to Verify
Using Supabase dashboard or query:

```sql
-- Check strategic plans table
SELECT id, title, cse_id, status, created_at
FROM strategic_plans
ORDER BY created_at DESC LIMIT 5;

-- Check AI insights are being saved
SELECT id, plan_id, insight_type, created_at
FROM account_plan_ai_insights
ORDER BY created_at DESC LIMIT 5;

-- Check actions are saved
SELECT id, action, client, priority, created_at
FROM unified_actions
WHERE source = 'PLAN'
ORDER BY created_at DESC LIMIT 5;
```

- [ ] strategic_plans records have correct structure
- [ ] account_plan_ai_insights populated from AI calls
- [ ] Actions sync with planning workflow

---

### E. API Endpoint Testing

Using browser DevTools Network tab or curl:

#### AI Field Suggestions
```bash
curl -X POST http://localhost:3001/api/ai/field-suggestions \
  -H "Content-Type: application/json" \
  -d '{"fieldName":"plan_purpose","context":{"clientId":"test"},"currentValue":"Increase"}'
```
- [ ] Returns suggestions array
- [ ] Each suggestion has value, confidence, reason

#### Image Analysis (if implemented)
- [ ] POST to /api/ai/analyse-image with base64 image
- [ ] Returns analysis object

#### Generate Chart
```bash
curl -X POST http://localhost:3001/api/ai/generate-chart \
  -H "Content-Type: application/json" \
  -d '{"query":"Show revenue by quarter for 2025"}'
```
- [ ] Returns chart specification object

---

### F. Mobile Responsiveness

Test on mobile viewport (375px width):

- [ ] /test-ai - All components responsive
- [ ] /planning/strategic/new - Steps work on mobile
- [ ] PredictiveInput touch-friendly buttons appear
- [ ] AI suggestion panels scroll correctly

---

### G. Error Handling

- [ ] AI components wrapped in AIErrorBoundary
- [ ] Fallback UI shows when AI fails
- [ ] Network errors don't crash the page
- [ ] Console shows meaningful error messages

---

## Verification Summary

| Category | Status | Notes |
|----------|--------|-------|
| Unit Tests | ✅ Pass | 118/118 |
| TypeScript | ✅ Pass | No errors |
| Build | ✅ Pass | Production build OK |
| Test AI Page | ⬜ | Manual check needed |
| Test Charts Page | ⬜ | Manual check needed |
| Planning Workflow | ⬜ | All 6 steps |
| ChaSen AI | ⬜ | Context integration |
| Supabase Data | ⬜ | Record verification |
| API Endpoints | ⬜ | Curl tests |
| Mobile | ⬜ | Responsive design |
| Error Handling | ⬜ | Graceful degradation |

---

## Post-Testing Actions

After all tests pass:

1. **Push to remote**: `git push origin main`
2. **Verify Netlify deploy**: Check https://app.netlify.com for build status
3. **Production smoke test**: Verify on live URL

---

## Known Limitations

- AI suggestions require valid API keys configured
- Image analysis requires Claude Vision access
- PDF ingestion may have file size limits
- ChaSen AI context limited to available data

---

*Generated: 2026-02-04*
*Phase 7 AI Integration - APAC Intelligence v2*
