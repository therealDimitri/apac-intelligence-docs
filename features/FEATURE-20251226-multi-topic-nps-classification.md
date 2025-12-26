# Feature: Multi-Topic NPS Comment Classification

**Date:** 26 December 2025
**Status:** IMPLEMENTED
**Impact:** High - Improves accuracy of NPS topic analysis

## Summary

Enhanced the NPS topic classification system to extract **multiple topics with per-topic sentiment** from each comment, replacing the previous single-topic-per-comment approach.

## Problem Statement

NPS comments often contain feedback about multiple distinct topics with different sentiments. The previous system assigned only ONE topic per comment, which:
- Missed important secondary topics
- Forced mixed-sentiment comments into a single sentiment value
- Reduced the accuracy of topic-based filtering and analysis

**Example:** The comment:
> "Altera seems outdated and clunky to navigate. It's difficult to get customer service to respond. The reps on-site have been pleasant and helpful."

Was previously classified as just `User Experience (negative)`, missing the `Support & Service (negative)` and `Account Management (positive)` topics entirely.

## Solution

Implemented multi-topic extraction with:
1. **Per-topic sentiment** - Each topic gets its own positive/negative/neutral sentiment
2. **Primary topic identification** - Tracks which topic is most emphasised
3. **Overall sentiment** - Captures mixed/positive/negative/neutral for the whole comment
4. **Excerpts** - Brief quotes showing evidence for each topic classification

## Topic Categories

Expanded from 7 to **11 topic categories**:

| # | Topic | Description |
|---|-------|-------------|
| 1 | Product & Features | Core functionality, capabilities, defects, QA |
| 2 | User Experience | UI/UX, navigation, workflow efficiency, ease of use |
| 3 | Support & Service | Help desk quality, ticket resolution, responsiveness |
| 4 | Account Management | CSE relationship, vendor engagement, on-site visits |
| 5 | Upgrade/Fix Delivery | Patch timelines, upgrade processes, fix turnaround |
| 6 | Performance & Reliability | Speed, uptime, stability, bugs, crashes |
| 7 | Training & Documentation | Learning resources, guides, tutorials |
| 8 | Implementation & Onboarding | Setup, integration, deployment, go-live |
| 9 | Value & Pricing | Cost, ROI, value perception |
| 10 | Configuration & Customisation | Client-specific setup, config limitations |
| 11 | Collaboration & Partnership | Trust building, flexibility, receptiveness to feedback |

## New Classification Format

```typescript
interface TopicSentiment {
  topic: string
  sentiment: 'positive' | 'negative' | 'neutral'
  excerpt: string  // Brief evidence quote (max 80 chars)
}

interface MultiTopicClassification {
  id: string | number
  classifications: TopicSentiment[]  // All topics found (1-4 typical)
  primary_topic: string              // Most emphasised topic
  primary_sentiment: 'positive' | 'neutral' | 'negative'
  overall_sentiment: 'positive' | 'neutral' | 'negative' | 'mixed'
  confidence: number                 // 0-100
}
```

## Files Modified

| File | Changes |
|------|---------|
| `src/app/api/topics/classify/route.ts` | New multi-topic prompt, updated validation, legacy format compatibility |
| `src/lib/topic-extraction.ts` | New interfaces, multi-topic cache handling, sentiment breakdown per topic |
| `scripts/classify-new-nps-comments.mjs` | Multi-topic prompt, flattened record storage |
| `scripts/test-multi-topic-classification.mjs` | Test script with example comments |

## Database Storage

The existing `nps_topic_classifications` table already supports multiple records per response via `UNIQUE(response_id, topic_name)`. Each topic extraction creates a separate record:

```sql
-- Example: One comment generates 3 records
INSERT INTO nps_topic_classifications (response_id, topic_name, sentiment, insight, ...)
VALUES
  ('resp-123', 'User Experience', 'negative', 'outdated and clunky [PRIMARY]', ...),
  ('resp-123', 'Support & Service', 'negative', 'difficult to get customer service', ...),
  ('resp-123', 'Account Management', 'positive', 'reps on-site were pleasant', ...);
```

## Test Results

Tested with 4 example comments matching user-provided expected classifications:

| Comment | Expected Topics | Matched | Notes |
|---------|-----------------|---------|-------|
| test-1: EHR criticism with positive on-site reps | 3 | 3/3 ✅ | Perfect match |
| test-2: Flexible solutions with product issues | 4 | 3/4 | Account Mgmt merged into Collaboration |
| test-3: Vendor engagement, config limitations | 2 | 1/2 | Config sentiment debatable (neutral vs negative) |
| test-4: Delivery challenges | 1 | 1/1 ✅ | Perfect match |

**Overall Accuracy: 80%** with 2.3 topics per comment average

## Backwards Compatibility

The API returns both new and legacy formats:
- `classifications` - New multi-topic format
- `legacy_classifications` - Single-topic format for backwards compatibility

## Usage

### API Endpoint
```bash
POST /api/topics/classify
{
  "comments": [
    { "id": "123", "feedback": "...", "score": 7 }
  ]
}
```

### Background Classification
```bash
# Classify uncached responses (multi-topic mode)
node scripts/classify-new-nps-comments.mjs --limit 50

# Test classification with examples
node scripts/test-multi-topic-classification.mjs
```

## Future Enhancements

1. **Database schema update** - Add `is_primary` and `overall_sentiment` columns to `nps_topic_classifications`
2. **Re-classify existing cache** - Update old single-topic classifications to multi-topic
3. **UI updates** - Display multiple topic badges per comment in NPS Analytics

## Related Documentation

- `docs/architecture/DATABASE_STANDARDS.md` - Database conventions
- `src/lib/topic-extraction.ts` - Topic extraction logic
- `src/app/(dashboard)/nps/page.tsx` - NPS Analytics page
