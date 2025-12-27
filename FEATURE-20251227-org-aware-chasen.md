# Feature: Org-Aware ChaSen AI

**Date:** 27 December 2025
**Commit:** `ebc2113`

## Overview

ChaSen now understands the APAC team's organisational structure, enabling personalised responses that reference managers and direct reports contextually.

## Changes

### Database Schema

Added two columns to `cse_profiles`:

| Column | Type | Description |
|--------|------|-------------|
| `reports_to` | TEXT | Email of the user's manager |
| `is_global_role` | BOOLEAN | True for global roles (not APAC-specific) |

**Migration:** `docs/migrations/20251227_add_reports_to_column.sql`

### ChaSen System Prompt

Added `**ORGANISATIONAL CONTEXT:**` section that dynamically shows:

- Whether user is in a GLOBAL role (e.g., Cristina Ortenzi, Todd Duncan)
- Who they report to (manager name and role)
- Their direct reports (names and roles)
- Instructions to reference direct reports when asked about "my team"

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
