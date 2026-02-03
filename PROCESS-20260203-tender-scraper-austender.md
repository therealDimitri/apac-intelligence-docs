# AusTender Scraper Implementation - 3 Feb 2026

## Status: COMPLETED

The AusTender Playwright-based scraper is now fully functional and collecting 12 months of historical Contract Notices.

---

## What Was Done

### 1. Fixed Form Navigation
- **Problem**: Original scraper couldn't find the keyword input field
- **Solution**: Switched from using the keyword search to the "View by Publish Date" / Advanced Search approach
- **File**: `scripts/tender-scraper/scrapers/austender.ts`

### 2. Implemented 12-Month Date Range
- **Problem**: Scraper only fetched today's tenders
- **Solution**: Added logic to fill the Advanced Search "Date Range" fields with past 12 months
- **Date format**: `DD-MMM-YYYY` (e.g., "03-Feb-2025" to "03-Feb-2026")
- **Code location**: Lines 32-90 in `austender.ts`

### 3. Fixed Search Button Click
- **Problem**: Search button selector wasn't matching
- **Solution**: Used `page.evaluate()` to find and click submit buttons by checking visibility and type
- **Code location**: Lines 127-180 in `austender.ts`

### 4. Fixed Pagination
- **Problem**: Pagination used ">" character, not "Next" text
- **Solution**: Updated selector to find links with ">" or "›" text content
- **Code location**: Lines 206-270 in `austender.ts`

### 5. Increased Page Limit
- **Changed**: `maxPages` from 5 to 50 in `scripts/tender-scraper/types.ts`
- **Result**: Can now fetch ~1000+ Contract Notices per run

### 6. Fixed Database Insertion
- **Problem**: `source_url` column doesn't exist in `tender_opportunities` table
- **Solution**: Store source URL in the `notes` field instead
- **File**: `scripts/tender-scraper/utils/supabase.ts`

---

## Test Results

**Last run (3 Feb 2026):**
- Pages scraped: 50 (hit maxPages limit)
- Total Contract Notices found: 1,004
- Healthcare-related filtered: 56
- New tenders inserted: 56
- Duration: ~119 seconds

**Database state:**
- Total tenders: 93
- Healthcare agencies captured include:
  - Department of Health, Disability and Aged Care
  - Department of Defence (pharmaceutical/medical)
  - Various state health departments

---

## Key Files Modified

| File | Changes |
|------|---------|
| `scripts/tender-scraper/scrapers/austender.ts` | Complete rewrite of scraping logic |
| `scripts/tender-scraper/types.ts` | Increased `maxPages` to 50 |
| `scripts/tender-scraper/utils/supabase.ts` | Fixed env var loading, removed source_url |

---

## Git Commits

1. **Scripts submodule** (`eeb1f70`):
   ```
   feat(tender-scraper): add 12-month date range and fix pagination
   ```

2. **Parent repo** (`26b22aa3`):
   ```
   chore: update scripts submodule with tender scraper 12-month date range
   ```

---

## How to Run

```bash
# From apac-intelligence-v2 root directory
export $(cat .env.local | grep -v '^#' | xargs)
PORTALS=austender npx tsx scripts/tender-scraper/index.ts
```

---

## Potential Future Work

### Not Started
1. **Other portal scrapers**: Victoria, NSW, QLD scrapers may need similar fixes
2. **ATM (Approach to Market) scraping**: Currently only scraping Contract Notices (awarded contracts), not open tenders
3. **Tender-client matching**: Create `tender_client_matches` junction table to link tenders to relevant clients
4. **Full-text search**: Add PostgreSQL FTS index on tender title/description

### From Original Plan (see `~/.claude/plans/floating-juggling-wozniak.md`)
- Stack gap analysis API (`/api/sales-hub/stack-gaps/[clientId]`)
- Client meetings section (`/api/sales-hub/meetings/client/[clientId]`)
- Tender search enhancements in NewsIntelligenceTab

---

## Healthcare Keyword Patterns

The scraper filters for healthcare-related Contract Notices using these patterns:
```typescript
const healthcareAgencyPatterns = [
  /health/i,
  /hospital/i,
  /medical/i,
  /ndis/i,
  /aged care/i,
  /disability/i,
  /pharmaceutical/i,
  /therapeutic/i,
  /nursing/i,
  /ambulance/i,
]
```

---

## Debug Screenshots

Screenshots are saved to `scripts/tender-scraper/screenshots/` with timestamps:
- `austender-cn-search-*.png` - Search form page
- `austender-dates-filled-*.png` - After filling date fields
- `austender-cn-results-*.png` - Results page
- `austender-error-*.png` - Error state captures

---

## Environment Variables Required

```
SUPABASE_URL or NEXT_PUBLIC_SUPABASE_URL
SUPABASE_SERVICE_ROLE_KEY
```
