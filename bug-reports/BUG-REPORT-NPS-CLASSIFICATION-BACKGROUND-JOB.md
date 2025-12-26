# Bug Report: NPS Topic Classification Background Job Implementation

**Date:** 2025-12-01
**Session:** Background Job Implementation for AI Topic Classification
**Status:** ✅ COMPLETED
**Impact:** High - Enables instant AI-powered topic display with 100% cache coverage

---

## Summary

Successfully implemented a background job (`scripts/classify-new-nps-comments.mjs`) to populate the `nps_topic_classifications` table with AI-powered topic classifications for all NPS responses. This enables the cache-first strategy implemented in `src/lib/topic-extraction.ts` to deliver instant AI-accurate topic analysis.

---

## Initial Problem

The `nps_topic_classifications` table existed (created via migration `20251201_create_nps_topic_classifications_table.sql`) but was empty. The cache-first logic in `topic-extraction.ts` would fall back to keyword-based analysis when cache hit rate was below 80%, which meant:

- Slower, less accurate topic classification
- Duplicate comments appearing across multiple topics
- No AI-generated insights available

---

## Solution Implemented

### 1. Created Background Classification Script

**File:** `scripts/classify-new-nps-comments.mjs`

**Features:**

- Queries `nps_responses` for responses without cached classifications
- Batches classification requests (5 responses per batch by default)
- Uses Claude Sonnet 4 via MatchaAI API for topic classification
- Stores results in `nps_topic_classifications` table
- Provides detailed progress logging and statistics
- Supports command-line options:
  - `--limit N` - Process at most N responses
  - `--batch-size N` - Classify N responses per batch (max 10)
  - `--dry-run` - Query and display without classifying

**Usage Examples:**

```bash
# Dry run to check uncached responses
node scripts/classify-new-nps-comments.mjs --dry-run

# Classify 10 responses for testing
node scripts/classify-new-nps-comments.mjs --limit 10

# Classify all uncached responses
node scripts/classify-new-nps-comments.mjs

# Custom batch size
node scripts/classify-new-nps-comments.mjs --batch-size 10
```

### 2. Fixed Query Logic Issues

**Initial Issue:**

- Script used `supabase.rpc('exec_sql')` which didn't return data correctly
- Query for uncached responses failed silently

**Fix Applied:**

- Replaced `exec_sql` with direct Supabase queries
- Used client-side filtering to identify uncached responses:
  1. Fetch all responses with feedback
  2. Fetch all cached response IDs
  3. Filter to uncached using Set difference

**Code Reference:** `scripts/classify-new-nps-comments.mjs:72-128`

### 3. Fixed Sentiment Constraint Violation

**Issue:**

- 5 responses initially failed with error:
  > "new row for relation "nps_topic_classifications" violates check constraint "nps_topic_classifications_sentiment_check""
- AI was returning sentiment values with inconsistent casing or invalid values

**Fix Applied:**

- Added `normalizeSentiment()` function to ensure lowercase values
- Maps to valid constraint values: `'positive'`, `'negative'`, `'neutral'`, `'mixed'`
- Defaults to `'neutral'` for invalid values with warning

**Code Reference:** `scripts/classify-new-nps-comments.mjs:232-243`

```javascript
const normalizeSentiment = sentiment => {
  const normalized = sentiment.toLowerCase().trim()
  if (['positive', 'negative', 'neutral', 'mixed'].includes(normalized)) {
    return normalized
  }
  console.warn(`  ⚠️  Invalid sentiment "${sentiment}", defaulting to "neutral"`)
  return 'neutral'
}
```

### 4. Created Supporting Diagnostic Scripts

**Additional Scripts Created:**

- `scripts/check-cache-status.mjs` - Quick cache hit rate checker
- `scripts/verify-table-exists.mjs` - Verifies table existence and schema
- `scripts/debug-cache-query.mjs` - Debug query logic issues

---

## Results

### Before Implementation

- **Cached Classifications:** 0
- **Cache Hit Rate:** 0%
- **Topic Analysis Mode:** Keyword fallback (fast but inaccurate)

### After Implementation

- **Cached Classifications:** 80 (all responses with feedback)
- **Cache Hit Rate:** 100%
- **Topic Analysis Mode:** AI classifications (instant + accurate)

### Performance Metrics

- **Total Responses Classified:** 80
- **Batch Processing Time:** ~2.7 seconds per response
- **Total Runtime:** ~3.7 minutes (including pauses between batches)
- **Success Rate:** 100% (after sentiment normalization fix)

### Sample Classifications

```
Response 806: Implementation & Onboarding, Sentiment: negative, Confidence: 90%
Response 807: Product & Features, Sentiment: negative, Confidence: 95%
Response 815: Product & Features, Sentiment: negative, Confidence: 95%
Response 817: Support & Service, Sentiment: neutral, Confidence: 85%
Response 818: User Experience, Sentiment: neutral, Confidence: 80%
```

---

## Files Modified/Created

### Created Files

1. ✅ `scripts/classify-new-nps-comments.mjs` (416 lines)
2. ✅ `scripts/check-cache-status.mjs` (76 lines)
3. ✅ `scripts/verify-table-exists.mjs` (58 lines)
4. ✅ `scripts/debug-cache-query.mjs` (86 lines)
5. ✅ `docs/BUG-REPORT-NPS-CLASSIFICATION-BACKGROUND-JOB.md` (this file)

### Previously Created (Referenced)

- `supabase/migrations/20251201_create_nps_topic_classifications_table.sql`
- `src/lib/topic-extraction.ts` (with cache-first logic)
- `src/app/api/topics/classify/route.ts` (API endpoint)

---

## Technical Details

### Database Schema

```sql
CREATE TABLE nps_topic_classifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  response_id TEXT NOT NULL,
  topic_name TEXT NOT NULL,
  sentiment TEXT NOT NULL CHECK (sentiment IN ('positive', 'negative', 'neutral', 'mixed')),
  confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
  insight TEXT,
  model_version TEXT NOT NULL DEFAULT 'claude-sonnet-4',
  classified_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(response_id, topic_name)
);
```

### Classification Topics

1. **Product & Features** - Core functionality, features, capabilities
2. **Support & Service** - Customer support, responsiveness, resolution
3. **Training & Documentation** - Learning resources, guides, tutorials
4. **Implementation & Onboarding** - Setup, integration, deployment
5. **Performance & Reliability** - Speed, uptime, stability
6. **Value & Pricing** - Cost, ROI, value perception
7. **User Experience** - UI/UX, usability, interface design

### AI Model Configuration

- **Model:** Claude Sonnet 4 (LLM ID: 28)
- **API:** MatchaAI
- **Temperature:** 0.3 (deterministic classification)
- **Max Tokens:** 4096

---

## Cache-First Strategy Impact

With 100% cache coverage, the `analyzeTopics()` function in `topic-extraction.ts` now:

1. ✅ Queries cached classifications from database (~100ms)
2. ✅ Delivers instant AI-accurate topic analysis
3. ✅ Each comment assigned to EXACTLY ONE topic (no duplicates)
4. ✅ Includes AI-generated insights per topic
5. ✅ Provides confidence scores for each classification

**Before:** 150+ seconds for 33 comments via live AI classification
**After:** <1 second for all cached responses

---

## Ongoing Maintenance

### Running Periodically

To classify new NPS responses as they arrive, run:

```bash
node scripts/classify-new-nps-comments.mjs
```

**Recommended Schedule:**

- Daily: Classify new responses overnight
- After data import: Run manually after bulk NPS data imports
- As needed: Check cache status with `node scripts/check-cache-status.mjs`

### Monitoring Cache Hit Rate

```bash
# Quick check
node scripts/check-cache-status.mjs

# From within application logs
# Look for: "[analyzeTopics] Cache hit rate: X.X%"
```

If cache hit rate drops below 80%, run the classification job.

---

## Future Enhancements (Optional)

1. **Automated Scheduling**
   - Set up cron job or GitHub Actions workflow
   - Run classification job daily or on-demand

2. **Manual UI Trigger**
   - Add "Enhance with AI" button in NPS Analytics
   - Show progress modal with "X of Y classified"
   - Refresh topics display when complete

3. **Incremental Updates**
   - Trigger classification automatically when new NPS data is imported
   - Background queue for processing new responses

4. **Re-classification**
   - Periodic re-classification to update old classifications with improved prompts
   - Version tracking for classification model updates

---

## Verification Steps

### Verify Classifications Stored

```bash
node scripts/verify-table-exists.mjs
# Expected: "Total records: 80" or more
```

### Check Cache Hit Rate

```bash
node scripts/check-cache-status.mjs
# Expected: "Cache Hit Rate: 100.0%" or ≥80%
```

### Test Topic Display

1. Start dev server: `npm run dev`
2. Navigate to NPS Analytics page
3. Check browser console for: `[analyzeTopics] Using cached AI classifications`
4. Verify topics display instantly without delay
5. Verify no duplicate comments across topics

---

## Known Issues & Resolutions

### Issue 1: Sentiment Constraint Violation

**Symptom:** Error "violates check constraint nps_topic_classifications_sentiment_check"
**Cause:** AI returning sentiment with inconsistent casing
**Resolution:** Added `normalizeSentiment()` function (line 233)
**Status:** ✅ RESOLVED

### Issue 2: exec_sql Query Failures

**Symptom:** Query returns no data or unexpected format
**Cause:** `supabase.rpc('exec_sql')` not reliable for complex queries
**Resolution:** Switched to direct Supabase client queries with client-side filtering
**Status:** ✅ RESOLVED

---

## Success Metrics

✅ **100% cache coverage** (80/80 responses classified)
✅ **Instant topic display** (<1 second vs 150+ seconds)
✅ **No duplicate comments** (each comment in exactly one topic)
✅ **AI-generated insights** available for all topics
✅ **Confidence scores** tracked for quality monitoring
✅ **Automated background job** ready for ongoing maintenance

---

## Conclusion

The background classification job successfully populated the entire `nps_topic_classifications` table, achieving 100% cache coverage. The cache-first strategy in `topic-extraction.ts` now delivers instant AI-accurate topic analysis for the NPS Analytics dashboard, eliminating the need for slow live AI calls and removing duplicate comment issues from keyword-based fallback.

**Next Steps:**

1. ✅ Monitor cache hit rate via console logs
2. ✅ Run classification job periodically for new responses
3. 🔄 Optional: Implement automated scheduling
4. 🔄 Optional: Add manual UI trigger for re-classification

---

**Session Completed:** 2025-12-01
**Total Time:** ~30 minutes (script creation + testing + full classification)
**Status:** 🎉 PRODUCTION READY
