# Feature: Org-Aware ChaSen AI

**Date:** 27 December 2025
**Commit:** `ebc2113`

## Overview

ChaSen now understands the APAC team's organisational structure, enabling personalised responses that reference managers and direct reports contextually.

## Changes

### Database Schema

Added three columns to `cse_profiles`:

| Column | Type | Description |
|--------|------|-------------|
| `reports_to` | TEXT | Email of the user's manager |
| `is_global_role` | BOOLEAN | True for global roles (not APAC-specific) |
| `job_description` | TEXT | Detailed role responsibilities for context |

**Migrations:**
- `docs/migrations/20251227_add_reports_to_column.sql`
- `docs/migrations/20251227_add_job_descriptions.sql`

### ChaSen System Prompt

Added `**ORGANISATIONAL CONTEXT:**` section that dynamically shows:

- User's job description (responsibilities)
- Whether user is in a GLOBAL role (e.g., Cristina Ortenzi, Todd Duncan)
- Who they report to (manager name, role, and job description)
- Their direct reports (names, roles, and job descriptions)
- Instructions to reference direct reports when asked about "my team"

### Job Descriptions

All 18 team members now have detailed job descriptions:

| Role | Description |
|------|-------------|
| EVP APAC | Overall APAC business strategy, P&L ownership, regional leadership |
| AVP Client Success | Leads CS team, drives retention, manages CSE performance |
| VP Business Support | Business operations, project delivery, support functions |
| VP Solutions | Pre-sales, solutions consulting, clinical/technical resources |
| Client Success Executive | Primary client relationship owner, health & retention |
| Client Account Manager | Commercial aspects, renewals, upsells, account growth |
| Director Solutions | Senior consulting for complex implementations |
| Chief Medical Officer | Clinical leadership, healthcare industry expertise |
| Project Manager | Implementation projects, timelines, go-lives |
| AVP Support | Leads support organisation, service levels |
| Business Operations | Operational processes, reporting, admin functions |
| Sr Field Marketing | Regional campaigns, events, demand generation |
| Sr HR Business Partner | Talent management, employee engagement |
| Country Manager | Local operations and client relationships |
| SVP Client Success & Ops | Global CS & Ops strategy |
| VP Client Success | Global CS methodology and tools |
| Marketing Manager | Marketing programs and campaigns |

### New Role Types

Added role-specific context for 8 additional roles:

| Role | Example Team Member |
|------|---------------------|
| `svp` | Cristina Ortenzi |
| `vp` | Dimitri Leimonitis, Dominic Wilson-Ing, Todd Duncan |
| `solutions` | Ben Stevenson, Tash Kowalczuk |
| `marketing` | Priscilla Lynch, Christina Tan |
| `program` | Keryn Kondoprias |
| `clinical` | Carol-Lynne Lloyd |
| `hr` | Cara Cortese |
| `support` | Stephen Oster |

### Role Mapping Fix

Fixed role mapping logic so "VP Business Support" correctly maps to `vp` instead of `operations`.

## Org Structure

```
Todd Haebich (EVP APAC)
├── Dimitri Leimonitis (AVP Client Success)
│   ├── Gilbert So (CSE)
│   ├── Tracey Bland (CSE)
│   ├── Laura Messing (CSE)
│   ├── BoonTeck Lim (CSE)
│   ├── John Salisbury (CSE)
│   ├── Nikki Wei (CAM)
│   └── Anupama Pradhan (CAM)
├── Ben Stevenson (VP Solutions)
│   ├── Tash Kowalczuk (Director Solutions)
│   └── Carol-Lynne Lloyd (CMO)
├── Dominic Wilson-Ing (VP Business Support)
│   ├── Keryn Kondoprias (Project Manager)
│   └── Stephen Oster (AVP Support)
│       └── Soumiya Mani (Business Operations)
├── Corey Popelier (AVP Program Delivery)
├── Christina Tan (Sr Field Marketing)
├── Cara Cortese (Sr HR Business Partner)
└── Kenny Gan (Country Manager)

Cristina Ortenzi (SVP - Global)
└── Todd Duncan (VP Client Success - Global)
    └── Priscilla Lynch (Marketing Manager)
```

## Files Modified

| File | Changes |
|------|---------|
| `src/app/api/chasen/chat/route.ts` | Added org context, role-specific prompts, updated type definitions |
| `src/hooks/useUserProfile.ts` | Fixed role mapping order for VP-level roles |
| `scripts/test-role-mappings.mjs` | Updated to match new role mapping logic |

## Testing

Run the role mapping test:

```bash
node scripts/test-role-mappings.mjs
```

## Usage Examples

When Dimitri asks ChaSen "How is my team performing?", ChaSen now knows:
- Dimitri has 7 direct reports (Gilbert, Tracey, Laura, BoonTeck, John, Nikki, Anu)
- Can reference specific team members by name
- Uses manager-focused language ("your team's portfolio")

When Stephen asks about "my team", ChaSen knows:
- Stephen has 1 direct report (Soumiya)
- Stephen reports to Dominic Wilson-Ing
