# Hugging Face — Future Opportunities

**Status:** Backlog
**Created:** 2026-02-09
**Prerequisites:** Complete Phases 1-3 (see `huggingface-phases-1-3.md`)

These are additional Hugging Face opportunities to revisit once the core local inference pipeline is proven.

---

## Opportunity 1: Summarisation Models for Cost Reduction

### Problem
Long meeting transcripts and client activity histories sent to Claude for summarisation consume significant tokens. A single meeting transcript can be 5,000-10,000 tokens.

### Solution
Use a local summarisation model to pre-process text before sending to Claude.

### Implementation Sketch
- **Model**: `Xenova/distilbart-cnn-12-6` (~500MB) or `facebook/bart-large-cnn`
- Create `src/lib/summarise.ts`:
  - `summariseText(text: string, maxLength?: number): Promise<string>`
- **Use cases**:
  - Meeting transcripts: Summarise 10,000 tokens → 500 tokens before Claude analysis
  - Client activity digest: Weekly summary of all interactions per client
  - ChaSen context preparation: Summarise retrieved documents before injecting into prompt
- **Expected savings**: 60-80% token reduction on summarisation tasks

### Trade-offs
- Larger model (~500MB vs ~50MB for classifiers)
- Local summaries less nuanced than Claude's
- Best as pre-processing step, not a replacement for Claude's reasoning

---

## Opportunity 2: Named Entity Recognition (NER)

### Problem
Structured data (names, dates, amounts, organisations) buried in unstructured text (meeting notes, emails, transcripts) requires manual extraction.

### Solution
Run NER locally to auto-extract entities and populate structured fields.

### Implementation Sketch
- **Model**: `Xenova/bert-base-NER` or `dslim/bert-base-NER`
- Create `src/lib/ner/extract-entities.ts`:
  - `extractEntities(text: string): Promise<Entity[]>`
  - Entity types: PERSON, ORG, DATE, MONEY, PRODUCT
- **Use cases**:
  - Auto-populate action items from meeting transcripts (who, what, when)
  - Extract stakeholder names from email threads for contact management
  - Cross-reference extracted client names against `client_name_aliases` for data quality
  - Pull dollar amounts from renewal discussions for pipeline updates
- **Integration points**:
  - Meeting notes editor (TipTap) — highlight entities inline
  - Action creation flow — pre-fill fields from selected meeting text
  - BURC data validation — flag mismatched client names

### Trade-offs
- NER models trained on general text, not APAC business terminology
- May need custom training data for industry-specific entities (product names, contract terms)
- Consider as an enhancement layer, not a replacement for manual entry

---

## Opportunity 3: HF Inference API as Claude Fallback

### Problem
Claude API outages or rate limits block ChaSen and automated workflows. MatchaAI is already a secondary provider but coverage is limited.

### Solution
Use Hugging Face Inference API as a third-tier fallback for text generation tasks.

### Implementation Sketch
- **Service**: HF Inference API (hosted) — `https://api-inference.huggingface.co`
- **Models**: `mistralai/Mistral-7B-Instruct-v0.3` or `meta-llama/Llama-3-8B-Instruct`
- Create `src/lib/ai/hf-fallback.ts`:
  - Same interface as existing Claude/MatchaAI clients
  - Triggered when primary + secondary providers fail
- **Pricing**: Free tier (rate-limited) or Pro ($9/month for higher limits)
- **Use cases**:
  - Simple factual queries in ChaSen
  - Batch classification when local models aren't suitable
  - Non-critical generation (email drafts, template suggestions)

### Trade-offs
- Quality significantly below Claude for complex reasoning
- Free tier has strict rate limits
- Another API dependency to manage
- Best as a "keep the lights on" fallback, not a primary provider

---

## Opportunity 4: Fine-Tuned Custom Models

### Problem
General-purpose HF models lack domain knowledge about APAC client success terminology, workflows, and business context.

### Solution
Fine-tune small models on your own data for domain-specific tasks.

### Prerequisites
- Substantial training data (1,000+ labelled examples per task)
- Classification feedback loop from Phase 3 collecting corrections

### Potential Fine-Tuning Targets

| Task | Base Model | Training Data Source | Expected Improvement |
|------|-----------|---------------------|---------------------|
| NPS theme extraction | `distilbert-base` | Historical NPS with manual themes | 15-20% accuracy gain |
| Meeting categorisation | `mobilebert` | Meeting history with types | 10-15% accuracy gain |
| Client risk detection | `distilbert-base` | Health score changes + preceding interactions | New capability |
| Action priority prediction | `mobilebert` | Historical action outcomes | New capability |

### Implementation Sketch
- Export training data from Supabase
- Fine-tune using HF `transformers` Python library or AutoTrain
- Convert to ONNX for Transformers.js compatibility
- Deploy as versioned model files alongside existing general models

### Trade-offs
- Requires Python toolchain for training (not Node.js)
- Training data quality directly impacts model quality
- Models need periodic retraining as business context evolves
- Cost: HF AutoTrain or local GPU time

---

## Opportunity 5: Multilingual Support (APAC Languages)

### Problem
APAC region includes clients/stakeholders who communicate in languages other than English. Meeting notes, NPS comments, and emails may contain non-English content.

### When to Consider
- When user base expands beyond English-speaking APAC markets
- When NPS comments start arriving in local languages

### Implementation Sketch
- **Translation**: `Xenova/opus-mt-{src}-{tgt}` models for offline translation
- **Multilingual embeddings**: `Xenova/multilingual-e5-small` — embeds 100+ languages into same vector space
- **Language detection**: `Xenova/multilingual-bert` — detect language before routing

### Trade-offs
- Significant model size increase (~200MB per language pair)
- Translation quality varies by language pair
- Low priority unless user base demands it

---

## Opportunity 6: Document Intelligence

### Problem
PDFs, Word docs, and spreadsheets uploaded to client profiles contain valuable unstructured data that isn't searchable or analysable.

### When to Consider
- After Phase 2 embeddings infrastructure is mature
- When document volume justifies the investment

### Implementation Sketch
- **OCR**: `Xenova/trocr-base-handwritten` for scanned documents
- **Table extraction**: HF models for parsing tables from PDFs
- **Document embeddings**: Chunk documents → embed → store in pgvector
- **Search**: "Find all contracts mentioning auto-renewal clauses"

### Trade-offs
- Heavy processing for large documents
- OCR accuracy varies with document quality
- Existing Office extraction (`unzip -p`) covers basic text; this adds visual understanding

---

## Priority Matrix

| Opportunity | Impact | Effort | Priority |
|---|---|---|---|
| Summarisation models | High (token savings) | Medium | Next after Phase 3 |
| Named Entity Recognition | Medium (automation) | Medium | After summarisation |
| HF Inference API fallback | Low (resilience) | Low | Quick win anytime |
| Fine-tuned custom models | High (accuracy) | High | After 6+ months of data |
| Multilingual support | Low (current users) | High | Only if user base demands |
| Document intelligence | Medium (search) | High | After embeddings mature |

---

## Cost Estimates

| Item | Cost | Notes |
|------|------|-------|
| Transformers.js | Free | Open source, runs locally |
| HF Inference API (Pro) | $9/month | Optional fallback tier |
| HF AutoTrain | ~$50-200/model | One-time fine-tuning cost |
| Disk for models | ~500MB-1GB | Cached locally |
| Supabase pgvector | Included | Part of existing plan |
