# APAC Intelligence Dashboard - Comprehensive Data Connections Audit

**Date**: 16 January 2026
**Author**: Data Analyst (AI-Assisted)
**Purpose**: Complete audit of all data connections, syncs, parsing, and AI context

---

## Executive Summary

This audit examines the complete data architecture of the APAC Intelligence Dashboard, including:
- Database schema and table relationships
- 24 sync scripts and their data sources
- API routes and data transformations
- Chasen AI context and knowledge base
- Materialised views and dependencies
- Identified discrepancies and recommendations

### Key Findings

| Metric | Value | Status |
|--------|-------|--------|
| BURC Match Rate | 37.4% | ⚠️ Needs Improvement |
| Client Table Sync | 15 missing entries | ⚠️ Needs Attention |
| Chasen Data Sources | 21 configured | ✅ Good |
| Health Data Linkage | 100% linked | ✅ Good |
| Strategic Plans | 6 active | ✅ Good |

---

## 1. Database Schema Overview

### Core Tables

| Table | Records | Purpose |
|-------|---------|---------|
| `clients` | 34 | Master client list with CSE assignments |
| `nps_clients` | 19 | Legacy NPS client reference |
| `sales_pipeline_opportunities` | 155 | Sales Budget pipeline data |
| `pipeline_opportunities` | 91 | BURC pipeline data |
| `client_health_history` | 598 | Health score snapshots |
| `unified_meetings` | 210 | Meeting records with AI analysis |
| `actions` | 160 | Action items and tasks |
| `nps_responses` | 199 | NPS survey responses |
| `strategic_plans` | 6 | Territory/account plans |

### Client Table Relationships

```
clients (34 records)
├── parent_id: NULL → 23 parent clients
└── parent_id: UUID → 11 child clients

Example Parent-Child:
  SA Health (parent)
  ├── SA Health (iPro)
  ├── SA Health (iQemo)
  └── SA Health (Sunrise)
```

### CSE Portfolio Distribution

| CSE | clients | nps_clients | sales_pipeline |
|-----|---------|-------------|----------------|
| Open Role | 14 | 5 | 45 |
| Tracey Bland | 5 | 5 | 61 |
| John Salisbury | 5 | 5 | 22 |
| Laura Messing | 4 | 4 | 27 |

---

## 2. Data Sources & Sync Scripts

### Primary Excel Sources

| Source File | Location | Sync Script |
|-------------|----------|-------------|
| 2026 APAC Performance.xlsx | OneDrive/APAC Leadership Team - General/Performance/Financials/BURC/2026/ | `sync-burc-pipeline-opportunities.mjs` |
| APAC 2026 Sales Budget 6Jan2026.xlsx | OneDrive/Documents/Client Success/Team Docs/Sales Targets/2026/ | `sync-sales-budget-pipeline.mjs` |

### Complete Sync Script Inventory (24 scripts)

**BURC Data Scripts:**
- `sync-burc-all-worksheets.mjs` - Master BURC importer
- `sync-burc-pipeline-opportunities.mjs` - Pipeline opportunities from BURC
- `sync-burc-comprehensive.mjs` - Comprehensive BURC data
- `sync-burc-data-supabase.mjs` - BURC to Supabase sync
- `sync-burc-enhanced.mjs` - Enhanced BURC with probabilities
- `sync-burc-historical.mjs` - Historical BURC data (2019-2025)
- `sync-burc-monthly.mjs` - Monthly BURC snapshots
- `sync-burc-attrition.mjs` - Attrition risk data
- `sync-burc-with-lineage-example.mjs` - Data lineage tracking

**Sales & Pipeline Scripts:**
- `sync-sales-budget-pipeline.mjs` - Sales Budget to sales_pipeline_opportunities
- `improve-burc-matching.mjs` - Cross-reference Sales Budget with BURC
- `sync-pipeline-and-attrition.mjs` - Combined pipeline/attrition sync

**Financial Scripts:**
- `sync-2025-revenue.mjs` - Historical revenue data
- `sync-2026-backlog-arr.mjs` - 2026 backlog and ARR
- `sync-invoice-tracker-to-database.mjs` - Invoice tracking
- `sync-planning-financials.mjs` - Financial data for planning

**Operations Scripts:**
- `sync-planning-compliance.mjs` - Compliance data
- `sync-sla-reports.mjs` - SLA and support metrics
- `sync-support-monthly-snapshot.mjs` - Support snapshots
- `sync-2026-csi-from-excel.mjs` - CSI data
- `sync-compliance-with-events.mjs` - Compliance events
- `sync-historical-revenue-from-excel.mjs` - Historical revenue
- `sync-alert-priorities.mjs` - Alert prioritisation

---

## 3. Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DATA FLOW DIAGRAM                            │
└─────────────────────────────────────────────────────────────────────┘

Excel Files (OneDrive)
    │
    ▼
┌──────────────────────┐    ┌──────────────────────┐
│  BURC Master File    │    │  Sales Budget File   │
│  (Performance.xlsx)  │    │  (Sales Budget.xlsx) │
└─────────┬────────────┘    └─────────┬────────────┘
          │                           │
          ▼                           ▼
┌─────────────────────┐     ┌─────────────────────┐
│ sync-burc-pipeline- │     │ sync-sales-budget-  │
│ opportunities.mjs   │     │ pipeline.mjs        │
└─────────┬───────────┘     └─────────┬───────────┘
          │                           │
          ▼                           ▼
┌─────────────────────┐     ┌─────────────────────┐
│ pipeline_           │     │ sales_pipeline_     │
│ opportunities       │     │ opportunities       │
│ (91 records)        │     │ (155 records)       │
└─────────┬───────────┘     └─────────┬───────────┘
          │                           │
          └─────────┬─────────────────┘
                    ▼
          ┌─────────────────────┐
          │ improve-burc-       │
          │ matching.mjs        │
          └─────────┬───────────┘
                    ▼
          ┌─────────────────────┐
          │ burc_pipeline_id    │
          │ burc_matched        │
          │ burc_match_         │
          │ confidence          │
          └─────────────────────┘
                    │
                    ▼
          ┌─────────────────────┐
          │  API Routes         │
          │  /api/planning/*    │
          │  /api/pipeline/*    │
          └─────────┬───────────┘
                    ▼
          ┌─────────────────────┐
          │  UI Components      │
          │  Strategic Wizard   │
          │  Dashboards         │
          └─────────────────────┘
```

---

## 4. BURC Matching Analysis

### Current State

| Metric | Count | Percentage |
|--------|-------|------------|
| Total Sales Pipeline | 155 | 100% |
| Matched to BURC | 58 | 37.4% |
| Unmatched | 97 | 62.6% |

### Match Confidence Breakdown

| Confidence Level | Count | Description |
|------------------|-------|-------------|
| Oracle | 23 | Oracle quote number exact match (100% confidence) |
| Exact | 10 | Exact opportunity name match |
| Fuzzy | 13 | High similarity match (>70%) |
| High | 1 | High confidence composite score |
| Medium | 1 | Medium confidence composite score |
| Low | 5 | Low confidence - needs review |
| Unknown | 5 | Null confidence - legacy data |

### Top Unmatched Accounts

| Account Name | Opportunities | Issue |
|--------------|---------------|-------|
| Department of Health - Victoria | 28 | Not in CLIENT_NORMALISATION |
| Minister for Health aka SA Health | 14 | Needs mapping to 'sa health' |
| Strategic Asia Pacific Partners, Incorporated | 10 | Already mapped but not matching |
| St Luke's Medical Center Global City Inc | 10 | Not in CLIENT_NORMALISATION |
| Gippsland Health Alliance | 8 | Needs mapping to 'gha' |
| Western Australia Department Of Health | 4 | Should map to 'wa health' |
| Mount Alvernia Hospital | 4 | Needs mapping to 'mount alvernia' |
| NCS PTE Ltd | 3 | Needs mapping to 'ncs mindef' |
| Barwon Health Australia | 2 | Already mapped |
| Synapxe Pte Ltd | 2 | Needs mapping to 'synapxe' |

---

## 5. Chasen AI Data Context

### Active Data Sources (21 configured)

| Source Table | Priority | Row Limit | Purpose |
|--------------|----------|-----------|---------|
| client_health_history | 95 | 50 | Health score trends |
| nps_responses | 90 | 10 | NPS feedback |
| client_segmentation | 85 | 30 | Client tiers |
| health_status_alerts | 85 | 10 | Status change alerts |
| actions | 85 | 15 | Action items |
| unified_meetings | 80 | 10 | Recent meetings |
| aging_accounts | 75 | 15 | AR data |
| portfolio_initiatives | 75 | 20 | Strategic initiatives |
| client_products | 75 | 500 | Product installations |
| aged_accounts_history | 70 | 7 | AR trends |

### Knowledge Base

| Category | Entries | Examples |
|----------|---------|----------|
| General | 11 | Business context, workflows |
| Definitions | 3 | NRR, GRR, Rule of 40 |
| Formulas | 2 | Health score calculation |
| Business Rules | 2 | Escalation paths |
| Processes | 1 | Planning workflows |
| Data Sources | 1 | Source documentation |

### BURC Context Integration

Chasen AI receives real-time BURC context via `chasen-burc-context.ts`:
- NRR: 90.96%
- GRR: 98.03%
- Rule of 40: 47.5

---

## 6. Identified Issues

### Critical Issues

1. **Low BURC Match Rate (37.4%)**
   - Impact: 97 opportunities not linked to BURC pipeline
   - Cause: Missing client name mappings in `CLIENT_NORMALISATION`
   - Fix: Add mappings for top unmatched accounts

2. **Client Table Sync Gap**
   - Impact: 15 clients in `clients` table but not in `nps_clients`
   - Cause: Legacy NPS system not synced with master client list
   - Fix: Either sync tables or consolidate to single client table

### Minor Issues

3. **Unassigned CSE Clients**
   - 6 clients have no CSE assignment
   - These are primarily system/internal clients

4. **Unknown Match Confidence**
   - 5 opportunities have `burc_match_confidence: null`
   - Likely from older sync before confidence tracking was added

---

## 7. Recommendations

### Immediate Actions

1. **Add CLIENT_NORMALISATION Mappings**

   ```javascript
   // Add to improve-burc-matching.mjs CLIENT_NORMALISATION
   'department of health - victoria': 'doh victoria',
   'department of health': 'doh victoria',
   'doh': 'doh victoria',

   "st luke's medical center global city inc": 'st lukes',
   "st luke's medical centre": 'st lukes',
   'slmc': 'st lukes',

   'ncs pte ltd': 'ncs mindef',
   'ncs pte': 'ncs mindef',
   ```

2. **Run Updated BURC Matching**
   ```bash
   node scripts/improve-burc-matching.mjs --dry-run  # Preview
   node scripts/improve-burc-matching.mjs            # Apply
   ```

3. **Sync Client Tables**
   - Either: Add missing clients to `nps_clients`
   - Or: Migrate to single source of truth (`clients` table)

### Process Improvements

4. **Schedule Regular Syncs**
   - Add cron/launchd job for BURC syncs
   - Run after each Excel file update

5. **Data Validation Checks**
   - Add validation script to CI/CD
   - Alert on match rate drops

6. **Chasen Knowledge Expansion**
   - Add BURC matching explanations to knowledge base
   - Document client name variations

---

## 8. Appendix: API Route Inventory

### Planning API Routes

| Route | Method | Purpose |
|-------|--------|---------|
| `/api/planning/strategic` | GET/POST | Strategic plans CRUD |
| `/api/planning/wizard/ai-suggestions` | POST | AI-generated suggestions |
| `/api/planning/financials/territory` | GET | Territory financials |
| `/api/planning/financials/account` | GET | Account financials |
| `/api/planning/client-arr` | GET | Client ARR data |
| `/api/planning/nps-themes` | GET | NPS topic analysis |
| `/api/planning/predictive/health` | GET | Health predictions |

### Client API Routes

| Route | Method | Purpose |
|-------|--------|---------|
| `/api/clients` | GET | Client list with health |
| `/api/clients/health-history` | GET | Health score history |
| `/api/clients/health-alerts` | GET | Status change alerts |
| `/api/clients/[clientId]/support-metrics` | GET | Support statistics |

### Pipeline API Routes

| Route | Method | Purpose |
|-------|--------|---------|
| `/api/pipeline/2026` | GET | 2026 pipeline data |
| `/api/invoice-tracker/aging` | GET | AR aging data |

---

## 9. Conclusion

The APAC Intelligence Dashboard has a well-structured data architecture with 24 sync scripts feeding data from Excel sources into Supabase. The main areas requiring attention are:

1. **BURC Matching** - Improve from 37.4% to >80% by adding client name mappings
2. **Client Table Consolidation** - Resolve discrepancy between `clients` and `nps_clients`
3. **Automated Syncs** - Implement scheduled syncs to keep data current

The Chasen AI context is well-configured with 21 data sources and 20 knowledge entries, providing comprehensive business intelligence capabilities.

---

## 10. Executive Strategic Analysis

### Root Cause: Data Source Coverage Gap

The 37.4% BURC match rate is not primarily a name normalisation issue. The fundamental problem is **data coverage asymmetry**:

| Metric | BURC Pipeline | Sales Budget |
|--------|---------------|--------------|
| Unique Clients | 18 | 25+ |
| Opportunities | 91 | 155 |

**28 Department of Health - Victoria opportunities in Sales Budget have NO corresponding BURC entries.**

This reveals a process gap where Sales Budget tracks opportunities not yet entered into the BURC planning system.

### Strategic Data Architecture Recommendations

#### 1. Unified Pipeline Data Model

**Current State:** Two disconnected pipeline sources operating independently

**Future State:** Single source of truth with bidirectional sync

```
┌─────────────────────────────────────────────────────────────────┐
│                    UNIFIED PIPELINE HUB                         │
│                                                                 │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐     │
│   │ Sales Budget │←→  │ BURC Master  │ ←→ │   CRM/SF     │     │
│   │    Excel     │    │    Excel     │    │  (Future)    │     │
│   └──────────────┘    └──────────────┘    └──────────────┘     │
│                            │                                    │
│                            ▼                                    │
│                  ┌─────────────────────┐                       │
│                  │ pipeline_unified    │                       │
│                  │ (Single Table)      │                       │
│                  └─────────────────────┘                       │
└─────────────────────────────────────────────────────────────────┘
```

#### 2. AI-Driven Client Resolution

Implement intelligent entity resolution using:
- **Semantic matching**: LLM-based company name understanding
- **Context-aware linking**: Match by project name, Oracle quote, ACV proximity
- **Confidence scoring**: Machine learning model for match quality

```typescript
// Future Architecture
interface IntelligentMatcher {
  semanticClientMatch(name: string): Promise<MatchResult[]>
  projectContextMatch(opportunity: Opportunity): Promise<MatchResult[]>
  consolidateMatches(results: MatchResult[][]): ConsolidatedMatch
}
```

#### 3. Real-Time Data Quality Monitoring

Deploy automated data quality dashboards:
- Match rate trending over time
- Data freshness indicators
- Anomaly detection for sudden drops
- Slack/Teams alerts on quality thresholds

#### 4. Process Integration Points

| Integration | Current | Recommended |
|-------------|---------|-------------|
| Excel → DB | Manual script execution | File watch + auto-sync |
| BURC ↔ Sales | No bidirectional sync | Real-time reconciliation |
| CRM → Dashboard | N/A | Webhook integration |
| Data Quality | Post-hoc analysis | Real-time monitoring |

### AI Context Optimisation

#### Current Chasen AI Architecture (21 data sources)

The Chasen AI context builder is well-structured but could be enhanced:

1. **Dynamic Priority Adjustment**: Boost recently-accessed client data
2. **Semantic Caching**: Pre-compute embeddings for faster retrieval
3. **Multi-Modal Context**: Include chart visualisations in context
4. **Conversational Memory**: Cross-session learning from user interactions

#### Recommended Knowledge Graph Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    CHASEN KNOWLEDGE GRAPH                       │
│                                                                 │
│   Clients ────────────── Opportunities ────────────── Products  │
│      │                        │                          │      │
│      ▼                        ▼                          ▼      │
│   Health ←──────────── Financial Metrics ──────────→ Contracts  │
│      │                        │                          │      │
│      └────────── Actions ─────┴────── Meetings ──────────┘      │
│                                                                 │
│   Vector Index: 50k+ embeddings for RAG retrieval              │
│   Graph Index: Neo4j-style relationship traversal              │
└─────────────────────────────────────────────────────────────────┘
```

### Business Impact Analysis

**Current State Revenue at Risk:**
- 97 unmatched opportunities = potential blind spots
- DoH Victoria: 28 opportunities = significant pipeline not tracked in BURC
- Match rate < 50% = unreliable cross-referencing for strategic planning

**Target State Benefits:**
- 95%+ match rate = full pipeline visibility
- Real-time sync = immediate strategy adjustments
- AI-enhanced matching = reduced manual reconciliation (est. 4-6 hrs/week saved)

### Implementation Roadmap

| Phase | Actions | Timeline |
|-------|---------|----------|
| 1 | Add missing BURC entries for DoH Victoria, Synapxe, etc. | Week 1 |
| 2 | Deploy improved-burc-matching.mjs with new mappings | Week 1 |
| 3 | Implement file-watch automation for sync scripts | Week 2 |
| 4 | Build data quality monitoring dashboard | Week 3-4 |
| 5 | Design unified pipeline schema | Week 4-6 |
| 6 | Pilot AI-driven entity resolution | Week 6-8 |

---

## 11. Conclusion

The APAC Intelligence Dashboard has a solid foundation with comprehensive sync scripts and well-structured Chasen AI context. The primary gap is **pipeline data coverage** rather than matching logic.

**Immediate Action Required:**
1. Ensure all Sales Budget clients have corresponding BURC entries
2. Run `improve-burc-matching.mjs` after each BURC update
3. Establish regular sync cadence (daily automated preferred)

**Strategic Investment Areas:**
1. Unified pipeline data model
2. AI-powered entity resolution
3. Real-time data quality monitoring
4. Knowledge graph for Chasen AI

This positions APAC Intelligence as a best-in-class AI-driven business intelligence platform with enterprise-grade data governance.

---

*Document generated by comprehensive data audit on 16 January 2026*
*Analysis performed with advanced AI-assisted business intelligence methodology*
