# Hugging Face Integration — Phases 1-3

**Status:** Planning
**Created:** 2026-02-09
**Goal:** Replace high-volume, low-complexity AI tasks with local inference to reduce API costs and improve response times.

---

## Phase 1: Transformers.js for NPS Sentiment + Action Categorisation

### Overview
Install Transformers.js and run lightweight classification models locally in Next.js API routes. Target the two highest-volume classification tasks first.

### Tasks

#### 1.1 Install and Configure Transformers.js
- Install `@huggingface/transformers` (previously `@xenova/transformers`)
- Create `src/lib/local-inference.ts` — singleton model loader with lazy initialisation
- Models are downloaded on first use and cached locally (~50-100MB)
- Handle Netlify: skip local inference in serverless (model too large for cold starts) — fall back to API

#### 1.2 NPS Sentiment Classification
- **Current state**: NPS comments classified via API calls (Claude or MatchaAI)
- **Target**: Local classification using `distilbert-base-uncased-finetuned-sst-2-english` or similar sentiment model
- **Implementation**:
  - Create `src/lib/nps/local-classifier.ts`
  - Input: NPS verbatim comment text
  - Output: sentiment label (positive/negative/neutral) + confidence score
  - Integrate into `scripts/classify-new-nps-comments.mjs`
  - Keep existing API classifier as fallback when confidence < threshold
- **Expected impact**: ~500 tokens/comment saved, instant classification vs ~1-2s API latency

#### 1.3 Action Auto-Categorisation
- **Current state**: Actions manually categorised or inferred by Claude
- **Target**: Zero-cost auto-tagging using zero-shot classification
- **Implementation**:
  - Create `src/lib/actions/auto-categorise.ts`
  - Model: `Xenova/mobilebert-uncased-mnli` (small, fast zero-shot classifier)
  - Categories: escalation, renewal, onboarding, billing, compliance, relationship, technical
  - Run on action creation (API route `POST /api/actions`)
  - Store as `auto_category` field alongside any manual override
- **DB change**: Add `auto_category` column to `actions` table (nullable text)

#### 1.4 Testing and Validation
- Compare local model accuracy vs Claude classifications on 100 historical NPS comments
- Measure inference latency (target: <100ms per classification)
- Verify Netlify build still works (models must not be bundled in deploy)

### Technical Decisions to Make
- [ ] Where to cache downloaded models — `node_modules/.cache` or a dedicated `.models/` directory?
- [ ] Should models load at server startup or lazy-load on first request?
- [ ] Threshold for falling back to Claude when confidence is low?

---

## Phase 2: Local Embeddings + Supabase pgvector for ChaSen

### Overview
Generate text embeddings locally using Transformers.js and store them in Supabase pgvector for semantic retrieval. This upgrades ChaSen's context system from keyword matching to meaning-based search.

### Prerequisites
- Phase 1 complete (Transformers.js installed and proven)
- Supabase pgvector extension enabled

### Tasks

#### 2.1 Enable pgvector in Supabase
- Run migration: `CREATE EXTENSION IF NOT EXISTS vector;`
- Add `embedding vector(384)` column to relevant tables:
  - `chasen_knowledge_base` — Q&A pairs
  - `topics` — meeting topics/notes
  - `actions` — action descriptions
  - `nps_responses` — verbatim comments
- Create HNSW index for fast similarity search

#### 2.2 Embedding Generation Service
- **Model**: `Xenova/all-MiniLM-L6-v2` (384 dimensions, ~23MB, excellent quality/speed ratio)
- Create `src/lib/embeddings.ts`:
  - `generateEmbedding(text: string): Promise<number[]>`
  - `generateBatchEmbeddings(texts: string[]): Promise<number[][]>`
  - Singleton model instance, lazy loaded
- Embed text on insert/update via API routes or background jobs

#### 2.3 Backfill Existing Data
- Create script `scripts/backfill-embeddings.mjs`
- Process existing records in batches of 50
- Log progress and handle interruption gracefully
- Estimated: ~5,000 records across all tables, ~10 minutes locally

#### 2.4 Semantic Search for ChaSen
- Create `src/lib/chasen/semantic-search.ts`
- Replace or augment `getLiveDashboardContext()` with embedding-based retrieval
- Query: embed user question → cosine similarity search → return top-K relevant records
- Supabase query: `SELECT *, 1 - (embedding <=> $1) AS similarity FROM table ORDER BY similarity DESC LIMIT 10`

#### 2.5 Universal Search Enhancement
- Add semantic search as a secondary ranking signal in `/api/search/route.ts`
- Blend text match score + semantic similarity score
- UI: no changes needed — results just become more relevant

### Technical Decisions to Make
- [ ] Embed on write (real-time) or batch job (periodic)?
- [ ] Embedding dimension: 384 (MiniLM) or 768 (larger model, better quality)?
- [ ] How to handle embedding drift when models are updated?

---

## Phase 3: Zero-Shot Classification Across the Platform

### Overview
Extend the zero-shot classification pattern from Phase 1 to auto-tag meetings, risks, and client interactions without any model training.

### Prerequisites
- Phase 1 complete (classification pipeline proven)
- Phase 2 complete (embeddings infrastructure available)

### Tasks

#### 3.1 Meeting Intent Classification
- Auto-classify meetings on creation/sync:
  - Categories: QBR, escalation, routine check-in, onboarding, renewal discussion, training, executive briefing
- Integrate into Outlook sync pipeline (`src/lib/microsoft-graph.ts`)
- Store as `meeting_type_auto` in meetings data
- Use in Briefing Room filters and ChaSen context

#### 3.2 Risk Auto-Classification
- Classify risks from planning steps by type:
  - Categories: churn risk, commercial risk, technical risk, relationship risk, compliance risk
- Integrate into planning workflow (ContextStep, RisksStep)
- Feed into client health score calculation as a signal

#### 3.3 Client Interaction Tagging
- Tag all client touchpoints (meetings, actions, NPS, emails) with unified topic labels
- Build a "topic heatmap" per client — what are we talking about most?
- Surface in client profile view as an insights panel

#### 3.4 Classification Feedback Loop
- Add thumbs up/down on auto-classifications in the UI
- Log corrections to `classification_feedback` table
- Future: use feedback data to fine-tune a custom model (Phase 4+)

### Technical Decisions to Make
- [ ] Shared category taxonomy or per-entity categories?
- [ ] Show auto-classifications to users or keep them internal for AI context?
- [ ] How to handle multi-label scenarios (a meeting can be both "escalation" and "renewal")?

---

## Success Metrics

| Metric | Phase 1 Target | Phase 2 Target | Phase 3 Target |
|--------|---------------|---------------|---------------|
| API token reduction | 30% fewer classification calls | 50% fewer context retrieval calls | 70% fewer tagging calls |
| Classification latency | <100ms local vs ~1-2s API | <50ms embedding generation | <100ms per classification |
| Search relevance | N/A | 20% improvement in ChaSen answer quality | N/A |
| Auto-tag accuracy | >85% on NPS, >80% on actions | N/A | >80% on meetings, >75% on risks |

## Dependencies

- `@huggingface/transformers` — core inference library
- Supabase pgvector extension (Phase 2)
- ~100MB disk for cached models
- Node.js 20+ (WASM/ONNX runtime support)

## Risks

- **Netlify serverless**: Models too large for cold-start functions. Solution: local inference for dev/scripts, API fallback for serverless.
- **Model accuracy**: Smaller models less accurate than Claude. Solution: confidence thresholds + fallback.
- **Embedding drift**: If the embedding model changes, all stored embeddings become incompatible. Solution: version the model, re-embed on upgrade.
