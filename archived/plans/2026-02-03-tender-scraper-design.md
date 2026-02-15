# Tender Scraper Design: GitHub Actions + Playwright

**Date:** 2026-02-03
**Status:** Approved
**Author:** Claude + Jimmy

## Overview

Implement headless browser scraping for Australian government tender portals using GitHub Actions and Playwright. Supports manual trigger from Sales Hub UI and scheduled daily runs.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        APAC Intelligence                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐   │
│  │ Sales Hub UI │────▶│ API Route    │────▶│ GitHub API   │   │
│  │ "Fetch Now"  │     │ /api/admin/  │     │ workflow     │   │
│  │   button     │     │ trigger-...  │     │ dispatch     │   │
│  └──────────────┘     └──────────────┘     └──────────────┘   │
└────────────────────────────────────────────────────────────────┘
                                                     │
                    ┌────────────────────────────────▼───────────┐
                    │            GitHub Actions                   │
                    │  tender-scraper.yml                        │
                    │  - Playwright + Chromium                   │
                    │  - Runs scraper scripts                    │
                    │  - Triggers: manual OR daily 6am AEST      │
                    └────────────────────────────────────────────┘
                                         │
                    ┌────────────────────▼────────────────────────┐
                    │              Supabase                        │
                    │  tender_opportunities table                  │
                    └─────────────────────────────────────────────┘
```

## Target Portals

| Portal | URL | Challenge | Strategy |
|--------|-----|-----------|----------|
| AusTender | tenders.gov.au | Form submission | Fill form, paginate results |
| Victoria | tenders.vic.gov.au | 403 bot protection | Stealth headers, realistic timing |
| NSW | buy.nsw.gov.au | React SPA | Wait for hydration |
| QLD | qtenders.hpw.qld.gov.au | Blazor WASM | Wait for Blazor init |

## File Structure

```
.github/workflows/
└── tender-scraper.yml

scripts/tender-scraper/
├── index.ts                  # Main orchestrator
├── scrapers/
│   ├── base-scraper.ts       # Abstract base class
│   ├── austender.ts
│   ├── victoria.ts
│   ├── nsw.ts
│   └── qld.ts
├── utils/
│   ├── supabase.ts
│   └── healthcare-filter.ts
└── types.ts

src/app/api/admin/
└── trigger-tender-scrape/
    └── route.ts
```

## GitHub Actions Workflow

- **Manual trigger:** workflow_dispatch with portal selection
- **Scheduled:** Daily at 6am AEST (cron: '0 20 * * *')
- **Timeout:** 30 minutes
- **Debug:** Screenshots uploaded on failure

## Required Secrets

- `SUPABASE_URL` (existing)
- `SUPABASE_SERVICE_ROLE_KEY` (existing)
- `GITHUB_PAT` (new - for API trigger)

## Scraper Base Class

```typescript
abstract class BaseTenderScraper {
  abstract name: string;
  abstract baseUrl: string;
  abstract scrape(page: Page): Promise<TenderResult[]>;

  protected parseAustralianDate(dateStr: string): string | null;
  protected isHealthcareRelated(title: string, desc?: string): boolean;
}
```

## Resilience Patterns

- Retry with exponential backoff (3 attempts)
- Screenshot on failure
- Graceful degradation (continue if one portal fails)
- Healthcare keyword filtering on all results

## Future Enhancements

- RSS feed monitoring as lightweight supplement
- Email alert parsing via webhooks
- Proxy rotation if bot protection increases
