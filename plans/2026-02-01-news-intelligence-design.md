# News Intelligence System Design

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a comprehensive news intelligence system that surfaces high-quality, actionable articles about Altera clients, stakeholders, industry trends, and tender opportunities across APAC markets.

**Architecture:** Three-tier intelligence pipeline (Client Mentions → Market Intelligence → Tender Alerts) powered by ChaSen AI for relevance scoring and classification.

**Tech Stack:** Next.js API routes, Supabase, RSS parsing, web scraping, ChaSen AI (Claude)

---

## 1. Data Scope

### 1.1 Clients (18 across 5 countries)

**Australia (12):**
- Albury Wodonga Health
- Barwon Health Australia
- Department of Health - Victoria
- Epworth Healthcare
- Gippsland Health Alliance (GHA)
- Grampians Health
- Royal Victorian Eye and Ear Hospital
- SA Health (iPro, iQemo, Sunrise)
- WA Health
- Western Health

**Singapore (3):**
- Mount Alvernia Hospital
- NCS/MinDef Singapore
- SingHealth

**New Zealand (1):**
- Te Whatu Ora Waikato

**Philippines (1):**
- Saint Luke's Medical Centre (SLMC)

**Guam (1):**
- Guam Regional Medical City (GRMC)

### 1.2 Client Aliases (87 total)

Examples:
- SA Health → "South Australia Health", "Minister for Health"
- SingHealth → "Singapore Health Services"
- Te Whatu Ora Waikato → "Waikato", "Te Whatu Ora"
- GRMC → "Guam Regional Medical Centre"

### 1.3 Key Stakeholders (81 contacts)

Source: `nps_responses` table via `useClientContacts` hook

Examples by client:
- **SingHealth:** Kenneth Kwek, Clarence Kua, Benedict Tan, Henry Arianto
- **SA Health:** Ted Murphy, Barb Rotolo, Wendy Sutton, Santosh Verghese
- **Mount Alvernia:** Andy Kang, Bruce Leong, James Lam, Cecil Ng
- **Barwon Health:** Christopher Coghlan, Bronwen Alsop, Megan Williams

---

## 2. News Sources (59+)

### 2.1 Tier 1: Client Press Releases (12 sources)

| Client | URL |
|--------|-----|
| SingHealth | https://www.singhealth.com.sg/about-singhealth/newsroom |
| Mount Alvernia Hospital | https://mtalvernia.sg/news_cat/press-release/ |
| SA Health | https://www.sahealth.sa.gov.au/wps/wcm/connect/public+content/sa+health+internet/about+us/news+and+media/all+media+releases/media+releases |
| WA Health | https://www.health.wa.gov.au/news |
| Barwon Health | https://www.barwonhealth.org.au/news/ |
| Epworth Healthcare | https://www.epworth.org.au/newsroom |
| Grampians Health | https://www.gh.org.au/news/ |
| Western Health | https://westernhealth.org.au/news |
| Royal Victorian Eye & Ear | https://eyeandear.org.au |
| Te Whatu Ora Waikato | https://www.tewhatuora.govt.nz/corporate-information/news-and-updates?news-area=Waikato |
| St. Luke's Medical Center | https://www.stlukes.com.ph/news-and-events/news-and-press-release |
| GRMC Guam | https://www.grmc.gu/ |

### 2.2 Tier 2: Healthcare IT & Digital Health Publications (6 sources)

| Source | Focus |
|--------|-------|
| Healthcare IT News (Asia/APAC) | AI, EMR, FHIR standards, regional priorities |
| Pulse+IT News | My Health Record, FHIR, Epic/InterSystems/Cerner |
| HealthTechAsia | Daily healthcare innovation across Asia |
| MobiHealthNews (Asia) | Digital health funding, startups |
| Talking HealthTech | EMR-to-EHR transitions (Australia) |
| The Medical Republic | Clinician EMR usability perspectives |

### 2.3 Tier 3: Regional Industry & B2B Platforms (5 sources)

| Source | Focus |
|--------|-------|
| Healthcare Asia Magazine | Hospital operations, medtech innovations |
| BioSpectrum Asia | Life sciences, medical devices, digital health |
| APACCIO Outlook | EMR vendor rankings, solution provider profiles |
| Hospital Management Asia (HMA) | SE Asian EMR trends |
| Black Book Research | State-of-market reports (Australian/NZ Healthcare IT) |

### 2.4 Tier 4: Professional Associations & Research Bodies (6 sources)

| Organisation | Key Outputs |
|--------------|-------------|
| APACMed | Position papers, digital health regulations |
| AIDH (Australasian Institute of Digital Health) | News, workforce development |
| APAMI | Medical informatics, health data research |
| Signify Research | APAC EHR market growth reports |
| IQVIA APAC | Health sciences sector research |
| Mordor Intelligence | APAC healthcare IT market analysis |

### 2.5 Tier 5: Government & Regulatory Sources

**Australia (Federal):**
| Source | Focus |
|--------|-------|
| Australian Digital Health Agency (ADHA) | National Digital Health Strategy, EMR/EHR standards |
| AusTender | Federal healthcare tenders |

**Australia (State Tender Portals):**
| Portal | State |
|--------|-------|
| Tenders.vic | Victoria |
| NSW eTendering | New South Wales |
| QTenders | Queensland |
| SA Tenders | South Australia |
| WA Tenders | Western Australia |
| Tasmanian Government Tenders | Tasmania |
| Quotations & Tenders NT | Northern Territory |
| ACT Government Tenders | ACT |

**Australia (State Health Departments):**
| Source | State |
|--------|-------|
| SA Health Media | South Australia |
| WA Health Media | Western Australia |
| NSW Health Media | New South Wales |
| Queensland Health | Queensland |
| Vic Health | Victoria |
| TAS Health | Tasmania |
| NT Health | Northern Territory |
| ACT Health | ACT |

**New Zealand:**
| Source | Focus |
|--------|-------|
| Te Whatu Ora | Shared Digital Health Record (SDHR) project |
| Beehive.govt.nz | Ministerial releases, HealthX innovation hubs |
| GETS | Government tenders |

**Singapore:**
| Source | Focus |
|--------|-------|
| Synapxe (National HealthTech Agency) | NGEMR, NEHR system updates |
| GovInsider | Gov tech, interoperability standards |
| GeBIZ | Government tenders |

**Philippines:**
| Source | Focus |
|--------|-------|
| DOH Philippines | National digitalisation priorities |
| PhilGEPS | Government procurement |

**Guam:**
| Source | Focus |
|--------|-------|
| Guam DPHSS | Federal EHR modernisation grants |
| GMHA (Guam Memorial Hospital) | Local EMR vendor news |

---

## 3. ChaSen AI Algorithm

### 3.1 Relevance Scoring Formula (0-100)

```
RELEVANCE_SCORE = (
    CLIENT_MATCH      × 0.30 +
    TOPIC_RELEVANCE   × 0.25 +
    ACTION_POTENTIAL  × 0.20 +
    SOURCE_AUTHORITY  × 0.15 +
    RECENCY           × 0.10
)
```

### 3.2 CLIENT_MATCH Scoring

| Match Type | Score |
|------------|-------|
| Exact client name | 100 |
| Client alias | 95 |
| Key stakeholder name + context | 90 |
| Stakeholder name only | 60 |
| Client region + healthcare | 40 |
| No match | 0 |

### 3.3 TOPIC_RELEVANCE Scoring

**Altera Company & Brand (Score: 100)**
- Altera Digital Health, Altera, Allscripts (legacy)

**Sunrise Family (Score: 100)**
- Sunrise EMR, Sunrise Acute Care, Sunrise Emergency Care
- Sunrise Mobile, Sunrise Health Record
- Sunrise Axon, Sunrise CarePath, Sunrise Thread AI
- Sunrise BCMA, Sunrise Surgical Care, Sunrise Oncology
- Sunrise Working Diagnosis, Sunrise Medical Photography
- Sunrise FHIR AU Core

**Opal Family (Score: 100)**
- Altera Opal, Opal Assessment, Opal Support Services

**dbMotion Family (Score: 100)**
- dbMotion, dbMotion Health Plan, Health Information Exchange

**Paragon Family (Score: 100)**
- Paragon, Paragon Denali, Paragon CarePath
- Paragon Ambient Listening, Paragon Gold Standard
- Paragon Operating Room Management

**TouchWorks Family (Score: 100)**
- TouchWorks EHR, TouchWorks Mobile
- TouchWorks Chart Preview, TouchWorks Note+
- TouchWorks Schedule Glance, TouchWorks Waypoint

**Clinical Performance & Analytics (Score: 100)**
- Altera CPM, CareInTelligence, MLM Analytics
- Patient Flow, Working Diagnosis

**Specialty Products (Score: 100)**
- iQemo, Provation iPro, CareFX, Altera eLink

**Solution Bundles (Score: 100)**
- Clinical Excellence Bundle
- Interoperability Suite
- Revenue Cycle Optimisation
- Patient Engagement Suite
- Population Health Analytics
- Emergency Department Optimisation
- Perioperative Excellence
- Ambulatory Care Transformation

**Managed Services (Score: 95)**
- Altera Cloud, Altera Hosting
- Application Management Services
- Robotic Process Automation (RPA)

**Competitor Products (Score: 95)**
| Vendor | Products |
|--------|----------|
| Epic | Epic, MyChart, Caboodle, Cosmos, Care Everywhere |
| Oracle Health | Cerner, PowerChart, Millennium |
| MEDITECH | MEDITECH Expanse, MEDITECH 6.x |
| InterSystems | TrakCare, HealthShare, IRIS |
| Orion Health | Amadeus, Rhapsody, Orchestral |

**Other Topics:**
| Topic | Score |
|-------|-------|
| Digital Transformation (FHIR, interoperability, API) | 90 |
| IT Infrastructure (cloud, cybersecurity) | 85 |
| Clinical Systems (CPOE, documentation) | 80 |
| AI/Analytics | 75 |
| Revenue Cycle | 70 |
| Patient Engagement | 65 |
| General Healthcare | 50 |

### 3.4 ACTION_POTENTIAL Scoring

| Trigger Type | Score | Examples |
|--------------|-------|----------|
| RFI/Tender | 100 | "Request for proposal", "tender released" |
| Leadership change | 95 | "New CIO appointed", "CEO transition" |
| IT project announced | 90 | "EMR upgrade", "digital transformation" |
| Budget/Funding | 85 | "Allocated $X million" |
| Partnership/Vendor | 80 | "Partnered with", "selected vendor" |
| Expansion/Merger | 75 | "New facility", "acquisition" |
| Pain point signal | 70 | "System outage", "staff concerns" |
| Competitor win/loss | 95 | "Selected Epic", "replacing Sunrise" |
| General announcement | 40 | Awards, achievements |
| No action required | 10 | Historical, opinion |

### 3.5 SOURCE_AUTHORITY Scoring

| Source Tier | Score |
|-------------|-------|
| Client direct (press releases) | 100 |
| Government official | 95 |
| Specialist healthcare IT | 90 |
| Industry bodies | 85 |
| Major news outlets | 75 |
| Trade publications | 70 |
| Google News aggregated | 50 |
| Unknown/blog | 30 |

### 3.6 RECENCY Scoring

| Age | Score |
|-----|-------|
| Today | 100 |
| 1-3 days | 90 |
| 4-7 days | 75 |
| 8-14 days | 50 |
| 15-30 days | 25 |
| 30+ days | 10 |

### 3.7 Article Categories

| Category | Icon | Criteria | Action |
|----------|------|----------|--------|
| 🔴 Urgent Action | Alert | RFI/Tender, leadership change, competitor win | Immediate |
| 🟠 Opportunity | Lightbulb | IT project, budget, expansion | This week |
| 🟡 Monitor | Eye | Pain points, vendor news, trends | Track |
| 🟢 FYI | Info | General news, achievements | None |

### 3.8 Quality Filters

| Filter | Threshold |
|--------|-----------|
| Minimum relevance score | ≥ 50 |
| Client match confidence | ≥ 70 |
| Duplicate detection (cosine similarity) | < 0.85 |

---

## 4. Database Schema

### 4.1 news_sources

```sql
CREATE TABLE news_sources (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  source_type TEXT NOT NULL,  -- 'rss', 'scrape', 'api', 'tender_portal'
  url TEXT NOT NULL,
  region TEXT[],
  category TEXT,              -- 'client_direct', 'healthcare_it', 'government', 'tender'
  authority_score INT,
  fetch_frequency TEXT,       -- 'hourly', 'daily', 'weekly'
  last_fetched_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  config JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.2 news_articles

```sql
CREATE TABLE news_articles (
  id SERIAL PRIMARY KEY,
  source_id INT REFERENCES news_sources(id),
  title TEXT NOT NULL,
  content TEXT,
  summary TEXT,
  source_url TEXT UNIQUE,
  published_date DATE,
  fetched_at TIMESTAMPTZ DEFAULT NOW(),

  -- ChaSen AI scoring
  relevance_score INT,
  client_match_score INT,
  topic_relevance_score INT,
  action_potential_score INT,

  -- Classification
  category TEXT,              -- 'urgent_action', 'opportunity', 'monitor', 'fyi'
  trigger_type TEXT,
  matched_clients INT[],
  matched_stakeholders TEXT[],
  relevant_products TEXT[],

  -- AI-generated
  ai_summary TEXT,
  recommended_action TEXT,
  key_quote TEXT,

  -- Metadata
  regions TEXT[],
  topics TEXT[],
  is_verified BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.3 news_article_clients

```sql
CREATE TABLE news_article_clients (
  id SERIAL PRIMARY KEY,
  article_id INT REFERENCES news_articles(id) ON DELETE CASCADE,
  client_id INT REFERENCES nps_clients(id) ON DELETE CASCADE,
  match_type TEXT,
  match_confidence INT,
  matched_entity TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(article_id, client_id)
);
```

### 4.4 news_stakeholder_mentions

```sql
CREATE TABLE news_stakeholder_mentions (
  id SERIAL PRIMARY KEY,
  article_id INT REFERENCES news_articles(id) ON DELETE CASCADE,
  stakeholder_name TEXT NOT NULL,
  client_id INT REFERENCES nps_clients(id),
  context_snippet TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.5 tender_opportunities

```sql
CREATE TABLE tender_opportunities (
  id SERIAL PRIMARY KEY,
  article_id INT REFERENCES news_articles(id),
  tender_reference TEXT,
  issuing_body TEXT,
  title TEXT NOT NULL,
  description TEXT,
  region TEXT,
  close_date DATE,
  estimated_value TEXT,
  relevant_products TEXT[],
  status TEXT DEFAULT 'open',
  assigned_to TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 5. Cron Schedule

| Job | Schedule | Description |
|-----|----------|-------------|
| Tier 1: Client Press Releases | Every 2 hours | Direct client newsrooms |
| Tier 2: Tender Portals | Every 4 hours | AusTender, GeBIZ, etc. |
| Tier 3: Healthcare IT Pubs | Every 6 hours | Pulse+IT, Healthcare IT News |
| Tier 4: Industry/Government | Daily 6am | ADHA, Synapxe, state health |
| Tier 5: General News | Daily 6am | Google News client searches |
| Cleanup | Daily midnight | Deactivate articles > 90 days |

---

## 6. API Endpoints

```
POST /api/cron/news-intelligence/fetch     # Trigger fetch cycle
GET  /api/cron/news-intelligence/status    # Pipeline health

GET  /api/sales-hub/news/urgent            # Urgent action articles
GET  /api/sales-hub/news/client/:clientId  # Client-specific news
GET  /api/sales-hub/news/tenders           # Active tenders
GET  /api/sales-hub/news/feed              # Paginated feed

POST /api/sales-hub/news/:id/dismiss       # Mark reviewed
POST /api/sales-hub/news/:id/assign        # Assign to CSE/CAM
POST /api/sales-hub/tenders/:id/track      # Track tender
```

---

## 7. UI Components

| Component | Location | Purpose |
|-----------|----------|---------|
| Urgent Alerts Banner | Sales Hub top | Tenders, leadership changes |
| News Intelligence Dashboard | New Sales Hub tab | Filterable news feed |
| Client News Section | Client Profile | Client-specific news |
| Stakeholder Mentions | Client Profile Team tab | Contact mentions |
| Tender Tracker Pipeline | New Sales Hub section | Opportunity tracking |

---

## 8. Implementation Phases

### Phase 1: Database & Infrastructure (Week 1)
- Create all database tables
- Seed 59+ news sources
- Create indexes

### Phase 2: Fetcher Engine (Week 2)
- RSS feed parser
- Web scraper for non-RSS
- Tender portal scrapers
- Main cron job

### Phase 3: ChaSen AI Integration (Week 3)
- Scoring prompt templates
- Client/stakeholder matcher
- Topic classifier
- Action detector
- Duplicate detection

### Phase 4: API Endpoints (Week 4)
- All GET/POST endpoints
- Filtering and pagination
- Assignment workflow

### Phase 5: UI Components (Week 5)
- Urgent alerts banner
- News dashboard
- Tender tracker
- Enhanced client news

### Phase 6: Testing & Deployment (Week 6)
- Unit/integration tests
- UAT with account managers
- Production deployment
- Threshold tuning

---

## 9. Success Metrics

| Metric | Target |
|--------|--------|
| Articles processed daily | 200-500 |
| False positive rate | < 10% |
| Urgent alerts surfaced | 5-15/week |
| Tender capture rate | 100% |
| AM engagement rate | > 70% |
| Time to surface news | < 4 hours |

---

## 10. Altera Product Keywords Reference

```javascript
const ALTERA_KEYWORDS = {
  company: ['Altera Digital Health', 'Altera', 'Allscripts'],

  sunrise: [
    'Sunrise EMR', 'Sunrise Acute', 'Sunrise Emergency', 'Sunrise Mobile',
    'Sunrise Health Record', 'Sunrise Axon', 'Sunrise CarePath',
    'Sunrise Thread AI', 'Sunrise BCMA', 'Sunrise Surgical',
    'Sunrise Oncology', 'Working Diagnosis', 'Sunrise FHIR'
  ],

  opal: ['Altera Opal', 'Opal Assessment', 'Opal EMR'],

  dbmotion: ['dbMotion', 'Health Information Exchange', 'HIE'],

  paragon: [
    'Paragon EHR', 'Paragon Denali', 'Paragon CarePath',
    'Paragon Ambient', 'Paragon Gold Standard'
  ],

  touchworks: ['TouchWorks', 'TouchWorks EHR', 'TouchWorks Mobile'],

  specialty: [
    'iQemo', 'Provation iPro', 'CareFX', 'CareInTelligence',
    'Patient Flow', 'Altera CPM', 'MLM Analytics'
  ],

  bundles: [
    'Clinical Excellence Bundle', 'Interoperability Suite',
    'Revenue Cycle Optimisation', 'Patient Engagement Suite',
    'Population Health Analytics', 'Emergency Department Optimisation',
    'Perioperative Excellence', 'Ambulatory Care Transformation'
  ],

  competitors: [
    'Epic', 'MyChart', 'Cerner', 'Oracle Health', 'PowerChart',
    'MEDITECH', 'Expanse', 'InterSystems', 'TrakCare',
    'Orion Health', 'Amadeus', 'Rhapsody'
  ]
}
```
