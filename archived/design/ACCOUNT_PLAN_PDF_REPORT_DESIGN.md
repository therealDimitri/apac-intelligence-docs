# Account Plan PDF Report - Comprehensive Design Specification

**Version**: 2.0
**Date**: 2026-01-20
**Status**: Design Proposal
**Author**: Claude (AI-assisted design)

---

## Executive Summary

This document proposes a complete redesign of the Account Plan PDF export to transform it from a sparse, data-dump style report into a compelling, executive-ready strategic document that articulates the plan to achieve ACV targets through deep customer understanding.

### Current State Issues
- Minimal content (only actions table shown)
- No visual hierarchy or data visualisation
- Missing financial plan, methodology scores, stakeholder map
- No narrative structure connecting insights to strategy
- Lacks executive summary and KPI dashboard

### Proposed Solution
A **12-16 page comprehensive report** following BI best practices from Tableau, Salesforce, and Gartner, featuring:
- Executive KPI dashboard with health indicators
- Financial plan with targets vs actuals visualisation
- Stakeholder influence map
- Opportunity whitespace analysis with MEDDPICC scoring
- Risk heat map with mitigation strategies
- Sales methodology outcomes (Gap Selling, StoryBrand)
- Action plan timeline

---

## Document Structure (16 Pages)

```
┌─────────────────────────────────────────────────────────────────┐
│  PAGE 1: Cover Page                                             │
├─────────────────────────────────────────────────────────────────┤
│  PAGE 2: Executive Summary & KPI Dashboard                      │
├─────────────────────────────────────────────────────────────────┤
│  PAGE 3: Account Profile & Strategic Context                    │
├─────────────────────────────────────────────────────────────────┤
│  PAGE 4: Stakeholder Intelligence Map                           │
├─────────────────────────────────────────────────────────────────┤
│  PAGE 5-6: Financial Plan & Revenue Strategy                    │
├─────────────────────────────────────────────────────────────────┤
│  PAGE 7: Customer Understanding (Gap Analysis)                  │
├─────────────────────────────────────────────────────────────────┤
│  PAGE 8-9: Opportunity Pipeline & MEDDPICC Scorecard            │
├─────────────────────────────────────────────────────────────────┤
│  PAGE 10: Risk Assessment & Heat Map                            │
├─────────────────────────────────────────────────────────────────┤
│  PAGE 11: Strategic Narrative (StoryBrand)                      │
├─────────────────────────────────────────────────────────────────┤
│  PAGE 12-13: Action Plan & Timeline                             │
├─────────────────────────────────────────────────────────────────┤
│  PAGE 14-16: Appendices (Detailed Data)                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Page-by-Page Design Specifications

### PAGE 1: Cover Page

**Purpose**: Professional first impression, immediate context

**Layout**:
```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌──────────┐                              [ALTERA LOGO]        │
│  │ CLIENT   │                                                   │
│  │  LOGO    │                                                   │
│  └──────────┘                                                   │
│                                                                 │
│  ═══════════════════════════════════════════════════════════    │
│                                                                 │
│                   STRATEGIC ACCOUNT PLAN                        │
│                        FY2026                                   │
│                                                                 │
│                    [CLIENT NAME]                                │
│                                                                 │
│  ═══════════════════════════════════════════════════════════    │
│                                                                 │
│  ┌───────────────────────────────────────────────────────┐      │
│  │  CSE: John Salisbury          Territory: VIC, WA      │      │
│  │  Status: ACTIVE               Plan Period: FY2026     │      │
│  │  Last Updated: 20/01/2026     Version: 2.3            │      │
│  └───────────────────────────────────────────────────────┘      │
│                                                                 │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ HEALTH: 73  │  │ ARR: $2.4M  │  │ NPS: +42    │              │
│  │   ● Good    │  │   ▲ +12%    │  │  Promoter   │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
│                                                                 │
│                          CONFIDENTIAL                           │
└─────────────────────────────────────────────────────────────────┘
```

**Data Fields**:
- Client logo (from client profile)
- Altera Health logo
- Client name (large, prominent)
- Fiscal year
- CSE name and territory
- Plan status (Draft/Active/Completed)
- Last updated timestamp
- 3 headline KPIs: Health Score, ARR, NPS

---

### PAGE 2: Executive Summary & KPI Dashboard

**Purpose**: One-page strategic overview for executives who won't read further

**Layout**:
```
┌─────────────────────────────────────────────────────────────────┐
│  EXECUTIVE SUMMARY                                    Page 2    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              STRATEGIC OBJECTIVE                         │    │
│  │  "Grow [Client] from $2.4M to $3.2M ARR by expanding    │    │
│  │   Sunrise deployment and securing iQemo pilot"          │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────┐           │
│  │ TARGET  │ CURRENT │  GROWTH │ PIPELINE│ HEALTH  │           │
│  │  ARR    │   ARR   │  RATE   │  VALUE  │  SCORE  │           │
│  │ $3.2M   │  $2.4M  │  +33%   │  $890K  │   73    │           │
│  │  ━━━━━  │  ━━━━━  │   ▲     │  Wtd:   │  Good   │           │
│  │ FY26 Tgt│ Current │  YoY    │  $445K  │ ●●●●○   │           │
│  └─────────┴─────────┴─────────┴─────────┴─────────┘           │
│                                                                 │
│  KEY INSIGHTS                          PLAN STATUS              │
│  ┌────────────────────────────┐    ┌────────────────────┐      │
│  │ ✓ Champion identified       │    │ Completion: 85%    │      │
│  │ ✓ Budget confirmed Q2       │    │ ████████████░░░    │      │
│  │ ⚠ Competitor active (Epic)  │    │                    │      │
│  │ ⚠ Key sponsor retiring Q3   │    │ ● Gap Analysis  ✓  │      │
│  │ ✗ No C-suite engagement yet │    │ ● MEDDPICC      ✓  │      │
│  └────────────────────────────┘    │ ● Stakeholders  ✓  │      │
│                                     │ ● Actions       ◐  │      │
│  FINANCIAL SNAPSHOT                 └────────────────────┘      │
│  ┌──────────────────────────────────────────────────────┐      │
│  │ Revenue Target          Progress           Gap       │      │
│  │ ═══════════════════════════════════════════════════  │      │
│  │ Renewal ($2.1M)         ████████████████░░ 88%  $252K│      │
│  │ Expansion ($800K)       ████████░░░░░░░░░░ 45%  $440K│      │
│  │ New Business ($300K)    ██░░░░░░░░░░░░░░░░ 12%  $264K│      │
│  └──────────────────────────────────────────────────────┘      │
│                                                                 │
│  TOP 3 ACTIONS THIS QUARTER                                     │
│  ┌──────────────────────────────────────────────────────┐      │
│  │ 1. Schedule C-suite intro meeting (Due: 15 Feb)      │      │
│  │ 2. Deliver iQemo ROI analysis (Due: 28 Feb)          │      │
│  │ 3. Renew Sunrise support contract (Due: 31 Mar)      │      │
│  └──────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────┘
```

**Data Fields**:
- Strategic objective statement (from plan narrative)
- 5 headline KPIs with targets
- Key insights (✓ strengths, ⚠ warnings, ✗ gaps)
- Plan completion percentage with methodology checklist
- Financial progress bars (renewal, expansion, new business)
- Top 3 priority actions

---

### PAGE 3: Account Profile & Strategic Context

**Purpose**: Deep understanding of the customer's business and environment

**Layout**:
```
┌─────────────────────────────────────────────────────────────────┐
│  ACCOUNT PROFILE & STRATEGIC CONTEXT                  Page 3    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  COMPANY OVERVIEW                    RELATIONSHIP TIMELINE      │
│  ┌────────────────────────┐         ┌─────────────────────┐    │
│  │ [CLIENT LOGO]          │         │  2019 ────●──────── │    │
│  │                        │         │       Initial Sale   │    │
│  │ Industry: Healthcare   │         │  2020 ────●──────── │    │
│  │ HQ: Melbourne, VIC     │         │       Sunrise Go-Live│    │
│  │ Employees: 4,500       │         │  2022 ────●──────── │    │
│  │ Annual Budget: $45M IT │         │       iPro Expansion │    │
│  │ Fiscal Year End: June  │         │  2024 ────●──────── │    │
│  │                        │         │       Support Renewal│    │
│  │ Primary Contact:       │         │  2026 ────◐──────── │    │
│  │ Jane Smith, CIO        │         │       iQemo Proposal │    │
│  └────────────────────────┘         └─────────────────────┘    │
│                                                                 │
│  CURRENT PRODUCT FOOTPRINT                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Product        │ Adoption │ Users │ ARR     │ Health     │  │
│  │────────────────┼──────────┼───────┼─────────┼────────────│  │
│  │ Sunrise EMR    │ ████ 85% │ 2,100 │ $1.8M   │ ●●●●○ Good │  │
│  │ iPro Analytics │ ██░░ 45% │   450 │ $420K   │ ●●●○○ Fair │  │
│  │ Support Basic  │ ████ 90% │   N/A │ $180K   │ ●●●●● Exc. │  │
│  │ iQemo (Pilot)  │ ░░░░  0% │     0 │   $0    │ Proposed   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  CLIENT PRIORITIES (From Discovery)     OUR ALIGNMENT          │
│  ┌─────────────────────────────────┐   ┌───────────────────┐   │
│  │ 1. Reduce ED wait times by 20%  │   │ ✓ Sunrise ED Mod  │   │
│  │ 2. Improve medication safety    │   │ ✓ iQemo Platform  │   │
│  │ 3. Reduce clinician burnout     │   │ ◐ Mobile Access   │   │
│  │ 4. Meet state reporting reqs    │   │ ✓ Analytics Suite │   │
│  │ 5. Integrate with pathology     │   │ ✗ Gap - Need API  │   │
│  └─────────────────────────────────┘   └───────────────────┘   │
│                                                                 │
│  COMPETITIVE LANDSCAPE                                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Incumbent (Us)  │ Challenger      │ Threat Level         │  │
│  │─────────────────┼─────────────────┼──────────────────────│  │
│  │ Sunrise EMR     │ Epic            │ ████░ HIGH - Active  │  │
│  │ iPro            │ Oracle Health   │ ██░░░ MED - Quoted   │  │
│  │ iQemo           │ Cerner (Oracle) │ █░░░░ LOW - No engage│  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Data Fields**:
- Company profile (industry, location, size, budget)
- Relationship timeline (key milestones)
- Product footprint table with adoption %, users, ARR, health
- Client priorities mapped to our solutions
- Competitive landscape with threat levels

---

### PAGE 4: Stakeholder Intelligence Map

**Purpose**: Visual representation of decision-makers, influencers, and relationships

**Layout**:
```
┌─────────────────────────────────────────────────────────────────┐
│  STAKEHOLDER INTELLIGENCE MAP                         Page 4    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  POWER/INFLUENCE GRID                                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           LOW INTEREST              HIGH INTEREST         │  │
│  │  HIGH  ┌─────────────────────┬─────────────────────────┐ │  │
│  │  POWER │ KEEP SATISFIED      │ MANAGE CLOSELY          │ │  │
│  │        │                     │  ★ Jane Smith (CIO)     │ │  │
│  │        │ ○ CFO               │  ★ Dr. Lee (CMIO)       │ │  │
│  │        │   (Budget holder)   │  ● Mark Jones (IT Dir)  │ │  │
│  │        │                     │                         │ │  │
│  │        ├─────────────────────┼─────────────────────────┤ │  │
│  │  LOW   │ MONITOR             │ KEEP INFORMED           │ │  │
│  │  POWER │                     │  ● Sarah Chen (PM)      │ │  │
│  │        │ ○ Legal             │  ● Nursing Mgrs (5)     │ │  │
│  │        │ ○ Procurement       │  ▲ Tom (Blocker)        │ │  │
│  │        │                     │                         │ │  │
│  │        └─────────────────────┴─────────────────────────┘ │  │
│  │  Legend: ★ Champion  ● Supporter  ○ Neutral  ▲ Blocker   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  KEY STAKEHOLDER PROFILES                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ ┌──────────┐  Jane Smith, CIO           CHAMPION         │  │
│  │ │ [Photo]  │  ● Economic Buyer: Yes                      │  │
│  │ │          │  ● Relationship: Strong (8/10)              │  │
│  │ └──────────┘  ● Last Contact: 15 Jan 2026                │  │
│  │               ● Black Swan: Retiring in 18 months        │  │
│  │               ● Success Driver: Legacy project success   │  │
│  │               ● Calibrated Q: "How do you see the...?"   │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ ┌──────────┐  Dr. Lee, CMIO             CHAMPION         │  │
│  │ │ [Photo]  │  ● Clinical Sponsor: Yes                    │  │
│  │ │          │  ● Relationship: Strong (9/10)              │  │
│  │ └──────────┘  ● Last Contact: 10 Jan 2026                │  │
│  │               ● Black Swan: Wants board seat             │  │
│  │               ● Success Driver: Clinical outcomes        │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ ┌──────────┐  Tom Wilson, Dep IT Dir    BLOCKER          │  │
│  │ │ [Photo]  │  ● Influence: Medium                        │  │
│  │ │          │  ● Relationship: Weak (3/10)                │  │
│  │ └──────────┘  ● Last Contact: Never (avoid us)           │  │
│  │               ● Concern: Prefers Oracle (former employer)│  │
│  │               ● Tactical Empathy: "You might think..."   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Data Fields** (from V2 Methodology - Stakeholder Intelligence):
- Power/Interest grid with stakeholder positions
- Key stakeholder profiles with photos
- Relationship scores (1-10)
- Black swan discoveries (career goals, political dynamics)
- Calibrated questions for each stakeholder
- Champion/Blocker/Neutral classification

---

### PAGE 5-6: Financial Plan & Revenue Strategy

**Purpose**: Articulate the path to ACV target achievement

**Layout (Page 5)**:
```
┌─────────────────────────────────────────────────────────────────┐
│  FINANCIAL PLAN & REVENUE STRATEGY                    Page 5    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  FY2026 REVENUE TARGET BREAKDOWN                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                                                          │  │
│  │  TARGET: $3.2M ARR │██████████████████████████████│ 100% │  │
│  │                    │                                    │  │
│  │  RENEWAL  $2.1M    │████████████████░░░░░░░░░░░░░░│ 65%  │  │
│  │  Secured: $1.85M   │████████████████              │      │  │
│  │  At Risk: $252K    │              ░░░░            │      │  │
│  │                    │                              │      │  │
│  │  EXPANSION $800K   │████████░░░░░░░░░░░░░░░░░░░░░░│ 25%  │  │
│  │  Pipeline: $450K   │████████                      │      │  │
│  │  Upside: $350K     │        ░░░░░░░░              │      │  │
│  │                    │                              │      │  │
│  │  NEW BIZ  $300K    │███░░░░░░░░░░░░░░░░░░░░░░░░░░░│ 10%  │  │
│  │  Pipeline: $180K   │███                           │      │  │
│  │  Target: $120K     │   ░░░░                       │      │  │
│  │                    │                              │      │  │
│  │  Legend: █ Secured/Pipeline  ░ Gap to Target             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  QUARTERLY REVENUE FORECAST                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │      │   Q1    │   Q2    │   Q3    │   Q4    │  TOTAL   │  │
│  │──────┼─────────┼─────────┼─────────┼─────────┼──────────│  │
│  │Target│ $600K   │ $750K   │ $900K   │ $950K   │  $3.2M   │  │
│  │──────┼─────────┼─────────┼─────────┼─────────┼──────────│  │
│  │Renew │ $525K   │ $525K   │ $525K   │ $525K   │  $2.1M   │  │
│  │Expand│ $50K    │ $200K   │ $250K   │ $300K   │  $800K   │  │
│  │NewBiz│ $25K    │ $25K    │ $125K   │ $125K   │  $300K   │  │
│  │──────┼─────────┼─────────┼─────────┼─────────┼──────────│  │
│  │TOTAL │ $600K   │ $750K   │ $900K   │ $950K   │  $3.2M   │  │
│  │Status│ ● On Trk│ ◐ At Rsk│ ○ Pndng │ ○ Pndng │          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  PIPELINE CONFIDENCE ANALYSIS                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Weighted Pipeline: $445K    Unweighted: $890K            │  │
│  │ Pipeline Coverage: 1.4x     Target Coverage: 3.0x        │  │
│  │ ⚠ BELOW TARGET - Need additional $500K qualified opps    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Layout (Page 6 - Whitespace Analysis)**:
```
┌─────────────────────────────────────────────────────────────────┐
│  WHITESPACE & EXPANSION OPPORTUNITY                   Page 6    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PRODUCT EXPANSION MATRIX                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Product/Module    │ Current │ Potential │ Gap    │ Prob  │  │
│  │───────────────────┼─────────┼───────────┼────────┼───────│  │
│  │ Sunrise Core      │ $1.8M   │ $2.0M     │ $200K  │ HIGH  │  │
│  │ ├─ ED Module      │ $0      │ $180K     │ $180K  │ HIGH  │  │
│  │ ├─ Theatre Module │ $0      │ $120K     │ $120K  │ MED   │  │
│  │ ├─ Mobility       │ $0      │ $95K      │ $95K   │ MED   │  │
│  │ iPro Analytics    │ $420K   │ $600K     │ $180K  │ HIGH  │  │
│  │ ├─ Adv Reporting  │ $0      │ $85K      │ $85K   │ HIGH  │  │
│  │ iQemo Platform    │ $0      │ $350K     │ $350K  │ MED   │  │
│  │ Support Premium   │ $0      │ $45K      │ $45K   │ LOW   │  │
│  │───────────────────┼─────────┼───────────┼────────┼───────│  │
│  │ TOTAL             │ $2.22M  │ $3.48M    │ $1.26M │       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  EXPANSION OPPORTUNITY HEATMAP                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │               │ Q1 2026 │ Q2 2026 │ Q3 2026 │ Q4 2026   │  │
│  │───────────────┼─────────┼─────────┼─────────┼───────────│  │
│  │ ED Module     │ ███████ │         │         │           │  │
│  │ iPro Adv Rpt  │         │ ███████ │         │           │  │
│  │ Theatre Mod   │         │         │ ███████ │           │  │
│  │ iQemo Pilot   │         │ ██████░ │ ███████ │           │  │
│  │ Mobility      │         │         │         │ ███████   │  │
│  │───────────────┴─────────┴─────────┴─────────┴───────────│  │
│  │ Legend: ███ Targeted Close  ░░░ Proposal Stage           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  KEY REVENUE DRIVERS                                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 1. Sunrise ED Module ($180K) - CIO approved, Q1 decision │  │
│  │    Champion: Dr. Lee | Next: Demo to ED Director         │  │
│  │                                                          │  │
│  │ 2. iQemo Platform Pilot ($350K) - Strategic priority     │  │
│  │    Champion: Jane Smith | Next: Business case review     │  │
│  │                                                          │  │
│  │ 3. iPro Advanced Reporting ($85K) - Quick win            │  │
│  │    Champion: Mark Jones | Next: SOW signature            │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Data Fields**:
- Target ARR breakdown (renewal, expansion, new business)
- Quarterly forecast with status indicators
- Pipeline confidence analysis
- Whitespace/expansion matrix
- Product penetration heat map
- Key revenue drivers with next actions

---

### PAGE 7: Customer Understanding (Gap Analysis)

**Purpose**: Demonstrate deep understanding of customer problems and desired outcomes

**Layout**:
```
┌─────────────────────────────────────────────────────────────────┐
│  CUSTOMER UNDERSTANDING - GAP ANALYSIS                Page 7    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  GAP SELLING FRAMEWORK                                          │
│                                                                 │
│  ┌─────────────┐      ┌─────────────┐      ┌─────────────┐     │
│  │  CURRENT    │      │             │      │   FUTURE    │     │
│  │   STATE     │ ───► │   THE GAP   │ ───► │   STATE     │     │
│  │ (Problems)  │      │ (Our Value) │      │  (Success)  │     │
│  └─────────────┘      └─────────────┘      └─────────────┘     │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                    CURRENT STATE                        │    │
│  │                                                         │    │
│  │ PROBLEMS IDENTIFIED:                                    │    │
│  │ • ED wait times averaging 6.2 hours (target: 4 hours)  │    │
│  │ • 12% medication error rate (industry avg: 3%)         │    │
│  │ • Clinician overtime at 145% budget                    │    │
│  │ • Manual reporting taking 40 hours/week                │    │
│  │                                                         │    │
│  │ SUFFERING METRICS (Quantified Pain):                   │    │
│  │ • $2.4M annual cost of ED inefficiency                 │    │
│  │ • $890K risk exposure from medication errors           │    │
│  │ • $1.1M in clinician overtime annually                 │    │
│  │                                                         │    │
│  │ ROOT CAUSE:                                             │    │
│  │ Legacy systems not integrated; manual workflows        │    │
│  │                                                         │    │
│  │ COST OF INACTION: $4.4M/year + regulatory risk         │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                    FUTURE STATE                         │    │
│  │                                                         │    │
│  │ DESIRED OUTCOMES:                                       │    │
│  │ • ED wait time under 4 hours (35% reduction)           │    │
│  │ • Medication error rate below 2% (83% reduction)       │    │
│  │ • Clinician overtime at 100% budget                    │    │
│  │ • Automated reporting (save 35 hours/week)             │    │
│  │                                                         │    │
│  │ SUCCESS METRICS:                                        │    │
│  │ • Patient satisfaction: 75 → 90 NPS                    │    │
│  │ • Staff satisfaction: 62 → 80                          │    │
│  │ • Operational savings: $3.2M annually                  │    │
│  │                                                         │    │
│  │ QUANTIFIED IMPACT: $3.2M savings / $800K investment    │    │
│  │                    = 4.0x ROI over 3 years             │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  GAP ANALYSIS CONFIDENCE SCORE: 22/25 (88%)                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Understand Problems    ●●●●● 5/5  │ Future State  ●●●●○ 4/5│  │
│  │ Quantified Impact      ●●●●○ 4/5  │ Root Cause    ●●●●● 5/5│  │
│  │ Cost of Inaction       ●●●●○ 4/5  │                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Data Fields** (from V2 Methodology - Gap Selling):
- Current state problems (text)
- Suffering metrics (quantified impacts)
- Root cause analysis
- Cost of inaction
- Desired future state
- Success metrics
- Quantified impact/ROI
- Gap analysis confidence scores

---

### PAGE 8-9: Opportunity Pipeline & MEDDPICC Scorecard

**Purpose**: Show qualified opportunities with methodology-based scoring

**Layout (Page 8)**:
```
┌─────────────────────────────────────────────────────────────────┐
│  OPPORTUNITY PIPELINE & QUALIFICATION                 Page 8    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PIPELINE SUMMARY                                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Total Pipeline: $890K    Weighted: $445K    Opps: 4     │  │
│  │  Avg MEDDPICC: 28/40 (70%)    Avg Stage: Proposal        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  OPPORTUNITY DETAILS                                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Opportunity      │ ACV    │ Stage    │ Close  │ MEDDPICC │  │
│  │──────────────────┼────────┼──────────┼────────┼──────────│  │
│  │ Sunrise ED Module│ $180K  │ Proposal │ Q1 '26 │ 32/40 ●● │  │
│  │ iQemo Platform   │ $350K  │ Discovery│ Q2 '26 │ 24/40 ●○ │  │
│  │ iPro Adv Reports │ $85K   │ Negotiate│ Q1 '26 │ 36/40 ●●●│  │
│  │ Support Upgrade  │ $45K   │ Qualify  │ Q3 '26 │ 18/40 ○○ │  │
│  │──────────────────┼────────┼──────────┼────────┼──────────│  │
│  │ TOTAL            │ $660K  │          │        │ 28 avg   │  │
│  │ + Renewals       │ $2.1M  │ Secured  │ Various│ N/A      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  PIPELINE BY STAGE (FUNNEL VIEW)                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                                                          │  │
│  │   QUALIFY        ████████████████░░░░░░░░░░░░  $45K      │  │
│  │   DISCOVERY      ████████████████████████████  $350K     │  │
│  │   PROPOSAL       ███████████████░░░░░░░░░░░░░  $180K     │  │
│  │   NEGOTIATE      █████████░░░░░░░░░░░░░░░░░░░  $85K      │  │
│  │   CLOSED WON     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░  $0        │  │
│  │                                                          │  │
│  │   Legend: ████ Weighted Value  ░░░░ Unweighted           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  PIPELINE RISK INDICATORS                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ ⚠ iQemo: No Economic Buyer access yet (MEDDPICC E: 2/5) │  │
│  │ ⚠ Support: Decision criteria unclear (MEDDPICC D1: 1/5) │  │
│  │ ✓ ED Module: Strong champion, budget confirmed           │  │
│  │ ✓ iPro Reports: Paper process underway, Q1 close likely  │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Layout (Page 9 - MEDDPICC Scorecard)**:
```
┌─────────────────────────────────────────────────────────────────┐
│  MEDDPICC QUALIFICATION SCORECARD                     Page 9    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  TOP OPPORTUNITY: Sunrise ED Module ($180K)                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                                                          │  │
│  │  M  Metrics           ●●●●○ 4/5  ✓ ED wait time targets │  │
│  │     "35% reduction in wait times = $720K annual savings" │  │
│  │                                                          │  │
│  │  E  Economic Buyer    ●●●●● 5/5  ✓ Jane Smith (CIO)     │  │
│  │     "Budget authority confirmed, aligned on ROI"         │  │
│  │                                                          │  │
│  │  D  Decision Criteria ●●●●○ 4/5  ✓ Integration, UX      │  │
│  │     "Must integrate with existing Sunrise, minimal train"│  │
│  │                                                          │  │
│  │  D  Decision Process  ●●●○○ 3/5  ◐ Need CFO sign-off    │  │
│  │     "CIO approve → CFO budget → Board rubber stamp"      │  │
│  │                                                          │  │
│  │  P  Paper Process     ●●●●○ 4/5  ✓ Standard procurement │  │
│  │     "3-week procurement cycle, no unusual requirements"  │  │
│  │                                                          │  │
│  │  I  Implicate Pain    ●●●●● 5/5  ✓ ED overcrowding      │  │
│  │     "Patient complaints to board, regulatory scrutiny"   │  │
│  │                                                          │  │
│  │  C  Champion          ●●●●● 5/5  ✓ Dr. Lee (CMIO)       │  │
│  │     "Actively selling internally, provides intel"        │  │
│  │                                                          │  │
│  │  C  Competition       ●●○○○ 2/5  ⚠ Epic evaluating      │  │
│  │     "Epic proposed full replacement - higher risk"       │  │
│  │                                                          │  │
│  │  ─────────────────────────────────────────────────────── │  │
│  │  TOTAL SCORE: 32/40 (80%)              STATUS: QUALIFIED │  │
│  │  Recommendation: Proceed to proposal with urgency        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  MEDDPICC SCORES BY OPPORTUNITY (Radar View)                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           M                                              │  │
│  │          /|\                    ─── ED Module (32)       │  │
│  │         / | \                   - - iQemo (24)           │  │
│  │    C2  /  |  \  E               ... iPro (36)            │  │
│  │       /   |   \                                          │  │
│  │      /    |    \                                         │  │
│  │  C1 ──────●──────── D1                                   │  │
│  │      \    |    /                                         │  │
│  │       \   |   /                                          │  │
│  │    I   \  |  /  D2                                       │  │
│  │         \ | /                                            │  │
│  │          \|/                                             │  │
│  │           P                                              │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Data Fields**:
- Pipeline summary metrics
- Opportunity table with ACV, stage, close date, MEDDPICC score
- Pipeline funnel visualisation
- Risk indicators
- Full MEDDPICC breakdown for top opportunities
- Evidence for each element
- Radar chart comparing opportunity scores

---

### PAGE 10: Risk Assessment & Heat Map

**Purpose**: Visual risk analysis with mitigation strategies

**Layout**:
```
┌─────────────────────────────────────────────────────────────────┐
│  RISK ASSESSMENT & MITIGATION                        Page 10    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  RISK HEAT MAP                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              IMPACT →                                     │  │
│  │              Low      Med      High     Critical          │  │
│  │        ┌─────────┬─────────┬─────────┬─────────┐         │  │
│  │  HIGH  │         │         │    2    │    1    │  ← Most │  │
│  │   ↑    │         │         │ (Epic)  │(Sponsor)│    Risk │  │
│  │        ├─────────┼─────────┼─────────┼─────────┤         │  │
│  │  Prob- │         │    4    │    3    │         │         │  │
│  │  abil- │         │(Support)│(Budget) │         │         │  │
│  │  ity   ├─────────┼─────────┼─────────┼─────────┤         │  │
│  │        │    5    │         │         │         │         │  │
│  │  LOW   │(Integr) │         │         │         │         │  │
│  │        └─────────┴─────────┴─────────┴─────────┘         │  │
│  │                                                           │  │
│  │  Total Risks: 5    Critical: 1    High: 2    Med: 2      │  │
│  │  Total Revenue at Risk: $890K (28% of target ARR)        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  RISK DETAIL & MITIGATION PLAN                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                                                          │  │
│  │  1. SPONSOR RETIREMENT (CRITICAL)           Rev: $350K   │  │
│  │  ─────────────────────────────────────────────────────   │  │
│  │  Risk: CIO Jane Smith retiring in 18 months              │  │
│  │  Churn Probability: 40%                                  │  │
│  │                                                          │  │
│  │  Accusation Audit (Chris Voss):                          │  │
│  │  "You might be thinking that without Jane, this project  │  │
│  │   will lose momentum and potentially stall..."           │  │
│  │                                                          │  │
│  │  Mitigation:                                             │  │
│  │  • Multi-thread to Dr. Lee and Mark Jones                │  │
│  │  • Accelerate iQemo decision before Q3                   │  │
│  │  • Document value realisation for successor              │  │
│  │                                                          │  │
│  │  Owner: John Salisbury    Due: 28 Feb 2026               │  │
│  │                                                          │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │                                                          │  │
│  │  2. COMPETITIVE THREAT (HIGH)               Rev: $180K   │  │
│  │  ─────────────────────────────────────────────────────   │  │
│  │  Risk: Epic actively proposing full EMR replacement      │  │
│  │  Churn Probability: 25%                                  │  │
│  │                                                          │  │
│  │  Recovery Story (Wortmann):                              │  │
│  │  "Melbourne Health faced the same Epic proposal.         │  │
│  │   They chose to expand Sunrise because migration risk    │  │
│  │   outweighed benefits. 2 years later: 40% cost savings." │  │
│  │                                                          │  │
│  │  Mitigation:                                             │  │
│  │  • Prepare TCO comparison vs Epic                        │  │
│  │  • Arrange reference call with Melbourne Health          │  │
│  │  • Highlight integration complexity of rip-and-replace   │  │
│  │                                                          │  │
│  │  Owner: John Salisbury    Due: 15 Feb 2026               │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Data Fields** (from V2 Methodology - Risk & Recovery):
- Risk heat map (probability × impact matrix)
- Total revenue at risk
- Risk details with descriptions
- Churn probability percentages
- Accusation audit statements (Chris Voss)
- Recovery stories (Wortmann)
- Mitigation plans with owners and due dates
- Mitigation score

---

### PAGE 11: Strategic Narrative (StoryBrand)

**Purpose**: Compelling narrative that connects strategy to outcomes

**Layout**:
```
┌─────────────────────────────────────────────────────────────────┐
│  STRATEGIC NARRATIVE                                 Page 11    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  THE STORYBRAND FRAMEWORK                                       │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                                                          │  │
│  │      ┌─────────┐                      ┌─────────┐        │  │
│  │      │  HERO   │                      │ SUCCESS │        │  │
│  │      │ [Client]│ ─────────────────►   │ [Vision]│        │  │
│  │      └────┬────┘                      └─────────┘        │  │
│  │           │                                 ▲            │  │
│  │           │ faces                           │            │  │
│  │           ▼                                 │            │  │
│  │      ┌─────────┐      ┌─────────┐          │            │  │
│  │      │ VILLAIN │      │  GUIDE  │──────────┘            │  │
│  │      │[Problem]│◄─────│  [Us]   │                       │  │
│  │      └─────────┘      └────┬────┘                       │  │
│  │                            │                             │  │
│  │                       with a                             │  │
│  │                            ▼                             │  │
│  │                       ┌─────────┐                        │  │
│  │                       │  PLAN   │                        │  │
│  │                       │[Steps]  │                        │  │
│  │                       └─────────┘                        │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  OUR NARRATIVE FOR [CLIENT NAME]                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                                                          │  │
│  │  🎯 THE HERO: [Client Name]                              │  │
│  │  A leading regional health provider committed to         │  │
│  │  delivering exceptional patient care while managing      │  │
│  │  increasing operational complexity.                      │  │
│  │                                                          │  │
│  │  👹 THE VILLAIN: System Fragmentation                    │  │
│  │  Legacy disconnected systems causing ED delays,          │  │
│  │  medication errors, and clinician burnout - putting      │  │
│  │  patient safety and staff wellbeing at risk.             │  │
│  │                                                          │  │
│  │  🧭 THE GUIDE: Altera Health                             │  │
│  │  With 15+ years partnering with Australian healthcare,   │  │
│  │  we understand the unique challenges of regional         │  │
│  │  hospitals balancing quality care with tight budgets.    │  │
│  │                                                          │  │
│  │  📋 THE PLAN:                                            │  │
│  │  1. Optimise existing Sunrise ED workflow (Q1)           │  │
│  │  2. Pilot iQemo for medication safety (Q2)               │  │
│  │  3. Expand analytics for real-time visibility (Q3)       │  │
│  │                                                          │  │
│  │  ✅ SUCCESS: A Connected Healthcare Ecosystem            │  │
│  │  35% faster ED throughput, 80% fewer med errors,         │  │
│  │  clinicians freed to focus on care not paperwork.        │  │
│  │                                                          │  │
│  │  ❌ FAILURE (If We Don't Act):                           │  │
│  │  Continued patient complaints, regulatory scrutiny,      │  │
│  │  staff attrition, and $4.4M annual inefficiency cost.    │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  CALL TO ACTION                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Schedule executive briefing with Jane Smith to present   │  │
│  │ iQemo business case and ED module ROI analysis.          │  │
│  │                                                          │  │
│  │ Proposed Date: Week of 10 February 2026                  │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Data Fields** (from V2 Methodology - StoryBrand Narrative):
- Hero (the client)
- Villain (the problem/competitor)
- Guide (Altera's role)
- Plan (solution steps)
- Success vision (desired outcome)
- Failure vision (cost of inaction)
- Call to action

---

### PAGE 12-13: Action Plan & Timeline

**Purpose**: Clear, accountable action items with timeline

**Layout (Page 12)**:
```
┌─────────────────────────────────────────────────────────────────┐
│  ACTION PLAN & EXECUTION TIMELINE                    Page 12    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ACTION PLAN SUMMARY                                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Total Actions: 12    Complete: 4    In Progress: 5       │  │
│  │ Overdue: 1           Coming Due: 2                       │  │
│  │ Action Completeness Score: 38/50 (76%)                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Q1 2026 TIMELINE (GANTT VIEW)                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Jan     Feb     Mar                    │  │
│  │ ──────────────────┬───────┬───────┬───────┐              │  │
│  │ C-Suite Meeting   │███░░░░│       │       │ Due: 15 Feb  │  │
│  │ ED Demo           │  █████│███    │       │ Due: 28 Feb  │  │
│  │ iQemo ROI         │       │███████│       │ Due: 28 Feb  │  │
│  │ Sunrise Renewal   │       │       │███████│ Due: 31 Mar  │  │
│  │ iPro SOW          │███████│       │       │ Due: 31 Jan  │  │
│  │ Reference Call    │    ███│███    │       │ Due: 15 Feb  │  │
│  │ ──────────────────┴───────┴───────┴───────┘              │  │
│  │                                                          │  │
│  │ Legend: ███ In Progress  ░░░ Planned  ▓▓▓ Complete       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  PRIORITY ACTIONS (Next 30 Days)                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ #  │ Action                     │ Owner │ Due    │Status │  │
│  │────┼────────────────────────────┼───────┼────────┼───────│  │
│  │ 1  │ Schedule C-suite intro     │ JS    │ 31 Jan │ ⚠ Due │  │
│  │ 2  │ Finalise iPro SOW          │ JS    │ 31 Jan │ ● Prog│  │
│  │ 3  │ Arrange Melbourne ref call │ JS    │ 15 Feb │ ○ Plan│  │
│  │ 4  │ Prepare Epic TCO analysis  │ PS    │ 15 Feb │ ○ Plan│  │
│  │ 5  │ ED module demo to ED Dir   │ JS    │ 28 Feb │ ○ Plan│  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  RESPONSIBILITY MATRIX (RACI)                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Activity             │ John │ Pre-Sales│ Manager│ Client │  │
│  │──────────────────────┼──────┼──────────┼────────┼────────│  │
│  │ Executive Engagement │  R   │    C     │   A    │   I    │  │
│  │ Technical Demo       │  A   │    R     │   I    │   C    │  │
│  │ Proposal Development │  R   │    C     │   A    │   I    │  │
│  │ Contract Negotiation │  C   │    I     │   R    │   A    │  │
│  │ Implementation Plan  │  C   │    R     │   I    │   A    │  │
│  │──────────────────────┴──────┴──────────┴────────┴────────│  │
│  │ R=Responsible  A=Accountable  C=Consulted  I=Informed    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Layout (Page 13 - Full Action List)**:
```
┌─────────────────────────────────────────────────────────────────┐
│  COMPLETE ACTION LIST                                Page 13    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ALL ACTIONS BY STATUS                                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                                                          │  │
│  │  ⚠ OVERDUE (1)                                           │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │  • Schedule C-suite intro meeting                        │  │
│  │    Owner: John Salisbury | Due: 15 Jan | Client: [Name]  │  │
│  │    Link: Risk #1 (Sponsor Retirement)                    │  │
│  │                                                          │  │
│  │  ● IN PROGRESS (5)                                       │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │  • Finalise iPro Advanced Reporting SOW                  │  │
│  │    Owner: John Salisbury | Due: 31 Jan | Client: [Name]  │  │
│  │    Link: Opp #3 (iPro Reports $85K)                      │  │
│  │                                                          │  │
│  │  • Prepare iQemo ROI business case                       │  │
│  │    Owner: Pre-Sales Team | Due: 28 Feb | Client: [Name]  │  │
│  │    Link: Opp #2 (iQemo Platform $350K)                   │  │
│  │                                                          │  │
│  │  • Multi-thread to Dr. Lee and Mark Jones                │  │
│  │    Owner: John Salisbury | Due: 28 Feb | Client: [Name]  │  │
│  │    Link: Risk #1 (Sponsor Retirement)                    │  │
│  │                                                          │  │
│  │  • Arrange reference call with Melbourne Health          │  │
│  │    Owner: John Salisbury | Due: 15 Feb | Client: [Name]  │  │
│  │    Link: Risk #2 (Competitive Threat)                    │  │
│  │                                                          │  │
│  │  • Document value realisation for successor              │  │
│  │    Owner: John Salisbury | Due: 31 Mar | Client: [Name]  │  │
│  │    Link: Risk #1 (Sponsor Retirement)                    │  │
│  │                                                          │  │
│  │  ○ PLANNED (4)                                           │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │  • ED module demo to ED Director                         │  │
│  │    Owner: Pre-Sales | Due: 28 Feb | Client: [Name]       │  │
│  │                                                          │  │
│  │  • Prepare Epic TCO comparison analysis                  │  │
│  │    Owner: Pre-Sales | Due: 15 Feb | Client: [Name]       │  │
│  │                                                          │  │
│  │  • Sunrise support contract renewal                      │  │
│  │    Owner: John Salisbury | Due: 31 Mar | Client: [Name]  │  │
│  │                                                          │  │
│  │  • iQemo pilot proposal presentation                     │  │
│  │    Owner: John Salisbury | Due: 30 Apr | Client: [Name]  │  │
│  │                                                          │  │
│  │  ✓ COMPLETED (4)                                         │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │  • Initial discovery meeting                  ✓ 10 Jan   │  │
│  │  • Stakeholder mapping complete               ✓ 12 Jan   │  │
│  │  • Gap analysis workshop                      ✓ 15 Jan   │  │
│  │  • MEDDPICC qualification for ED Module       ✓ 18 Jan   │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Data Fields**:
- Action summary statistics
- Gantt timeline view
- Priority actions table
- RACI responsibility matrix
- Full action list grouped by status
- Links to related risks/opportunities

---

### PAGE 14-16: Appendices

**Content**:
- Page 14: Detailed financial data tables
- Page 15: Meeting history and engagement log
- Page 16: Product roadmap alignment, glossary

---

## Visual Design System

### Altera Brand Identity

**Brand Source**: Official Altera Digital Health 2026 Templates
**Logo Files**: `Altera_logo_rgb_logomark.svg`, `Altera_logo_rgb_graphicmark.svg`

### Colour Palette (Altera Brand)

| Colour | Hex | Usage |
|--------|-----|-------|
| **Altera Purple (Primary)** | #393391 | Headers, section titles, primary CTA |
| **Altera Purple Light** | #4c47c3 | Secondary headers, gradients |
| **Altera Purple Gradient** | #707cf1 | Highlights, hover states |
| **Altera Coral (Accent)** | #f46e7b | Call to action, important highlights |
| **Altera Coral Light** | #f68f99 | Secondary accent, badges |
| **Altera Navy (Dark)** | #151744 | Dark backgrounds, footer |
| Success Green | #22C55E | Positive metrics, on-track status |
| Warning Amber | #F59E0B | Attention needed, partial completion |
| Error Red | #EF4444 | Critical risks, off-track metrics |
| Neutral Grey | #6B7280 | Secondary text, borders |
| Light Grey | #F3F4F6 | Backgrounds, table stripes |
| Dark Grey | #1F2937 | Primary text |

### Brand Gradient
```css
/* Primary Altera Gradient (from logo) */
background: linear-gradient(135deg, #151744 0%, #2c2b7a 34%, #3d3aa1 63%, #4843ba 86%, #4c47c3 100%);
```

### Typography (Montserrat)

| Element | Font | Size | Weight |
|---------|------|------|--------|
| H1 (Page Title) | Montserrat | 24pt | Bold (700) |
| H2 (Section) | Montserrat | 18pt | SemiBold (600) |
| H3 (Subsection) | Montserrat | 14pt | Medium (500) |
| Body | Montserrat | 10pt | Regular (400) |
| Table | Montserrat | 9pt | Regular (400) |
| Caption | Montserrat | 8pt | Regular (400) |
| KPI Large | Montserrat | 36pt | Bold (700) |
| KPI Label | Montserrat | 8pt | SemiBold (600) |

### Font Embedding Note
Montserrat must be embedded in the PDF for consistent rendering. The font files are available at:
- `/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/Marketing - Altera Templates & Tools/Montserrat.zip`

Required font weights to embed:
- Montserrat-Regular.ttf (400)
- Montserrat-Medium.ttf (500)
- Montserrat-SemiBold.ttf (600)
- Montserrat-Bold.ttf (700)

### Chart Types

| Data Type | Recommended Chart |
|-----------|-------------------|
| Target vs Actual | Bullet chart or overlaid bar |
| Progress | Horizontal progress bar |
| Pipeline stages | Funnel chart |
| Risk assessment | Heat map (2D matrix) |
| MEDDPICC scores | Radar/spider chart |
| Timeline | Gantt chart |
| Stakeholder influence | Quadrant scatter plot |
| Trend over time | Line chart |

---

## Implementation Recommendations

### Phase 1: Core Structure (Week 1-2)
1. Update PDF generation to use new page structure
2. Implement cover page with KPI badges
3. Add executive summary dashboard
4. Enhance financial plan visualisation

### Phase 2: Methodology Integration (Week 3-4)
1. Add Gap Selling current/future state layout
2. Implement MEDDPICC scorecard with radar chart
3. Add risk heat map with mitigation details
4. Include StoryBrand narrative section

### Phase 3: Visual Enhancements (Week 5-6)
1. Add Gantt timeline for actions
2. Implement stakeholder influence grid
3. Add pipeline funnel visualisation
4. Include whitespace matrix

### Phase 4: Polish & Testing (Week 7-8)
1. Colour palette implementation
2. Typography consistency
3. Mobile/tablet rendering tests
4. User acceptance testing

---

## Success Metrics

| Metric | Current | Target |
|--------|---------|--------|
| Pages in PDF | 2-3 | 12-16 |
| Sections covered | 3 | 11 |
| Visual elements | 1 table | 15+ charts/visuals |
| Methodology integration | None | Full (Gap, MEDDPICC, StoryBrand) |
| User satisfaction | TBD | >4.5/5 |
| Export usage | TBD | +50% increase |

---

## Appendix: Data Source Mapping

| PDF Section | Data Source | Table/API |
|-------------|-------------|-----------|
| Cover Page | Account Plan | `account_plans` |
| Executive Summary | Multiple | Aggregated from plan data |
| Account Profile | Client, Plan | `clients`, `account_plans` |
| Stakeholder Map | V2 Methodology | Plan form data |
| Financial Plan | Plan + Financials | `account_plans`, `planning-financials` |
| Gap Analysis | V2 Methodology | Plan form data |
| Opportunity Pipeline | Plan + Pipeline | `account_plans`, `sales_pipeline_opportunities` |
| MEDDPICC | V2 Methodology | Plan form data |
| Risk Assessment | V2 Methodology | Plan form data |
| StoryBrand | V2 Methodology | Plan form data |
| Action Plan | Actions | `actions` table |

---

**Document End**
