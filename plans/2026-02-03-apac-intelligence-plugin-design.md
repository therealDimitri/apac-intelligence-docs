# APAC Intelligence Plugin Design

**Date:** 2026-02-03
**Updated:** 2026-02-06
**Author:** Claude Code
**Status:** Implemented & Validated

## Overview

Global Claude Code plugin containing 9 project-specific skills for the APAC Intelligence codebase (apac-intelligence-v2, apac-intelligence-scripts, apac-intelligence-docs).

## Plugin Location

```
~/.claude/local-plugins/apac-intelligence/
├── plugin.json
└── skills/
    ├── test-generation/
    │   ├── SKILL.md
    │   ├── references/mock-patterns.md
    │   └── examples/
    │       ├── hook-test.ts
    │       └── api-route-test.ts
    ├── migration-workflow/
    │   ├── SKILL.md
    │   ├── references/common-migrations.md
    │   └── examples/
    │       └── add-column-migration.sql
    ├── documentation-generator/
    │   ├── SKILL.md
    │   ├── references/templates.md
    │   └── examples/
    │       └── bug-report.md
    ├── chasen-ai-dev/
    │   ├── SKILL.md
    │   └── references/
    │       ├── prompt-patterns.md
    │       └── knowledge-categories.md
    ├── news-intelligence/
    │   ├── SKILL.md
    │   └── references/source-config.md
    ├── script-scaffolder/
    │   ├── SKILL.md
    │   └── references/templates.md
    ├── burc-financial-data/
    │   ├── SKILL.md
    │   └── references/gotchas.md
    ├── cross-repo-workflow/
    │   └── SKILL.md
    └── schema-verification/
        ├── SKILL.md
        └── references/column-traps.md
```

**Total: 9 skills, 23 files, zero broken references.**

## Skills Summary

### 1. Test Generation

**Triggers:** "write tests", "add unit tests", "create test file", "test this component", "test this API route", "test this hook"

**Key Features:**
- Supabase mocking patterns (wrapper vs library)
- API response structure guidance (`json.data.data`)
- Hook and API route test templates
- Error handling patterns

**Reference files:**
- `references/mock-patterns.md` — Advanced Supabase mock patterns (multi-table, sequential, auth, MS Graph, ChaSen)
- `examples/hook-test.ts` — Real example based on `useAnomalyDetection` (renderHook, config, edge cases)
- `examples/api-route-test.ts` — Real example based on Outlook import (auth mocks, insert tracking, regression)

### 2. Migration Workflow

**Triggers:** "create a migration", "add database column", "modify schema", "run a migration", "add a table"

**Key Features:**
- pg client usage (no exec_sql RPC)
- Migration file naming convention
- Schema regeneration workflow
- RLS policy templates and debugging
- Common SQL patterns

**Reference files:**
- `references/common-migrations.md` — SQL templates for all common operations
- `examples/add-column-migration.sql` — Complete migration with tables, constraints, indexes, RLS

### 3. Documentation Generator

**Triggers:** "create documentation", "write bug report", "document process", "add to docs", "archive fixed bugs"

**Key Features:**
- File naming: `TYPE-YYYYMMDD-description.md`
- Bug report structure with Status header
- Process and data import templates
- Submodule commit workflow
- PDF export via Typora
- Data integrity warnings

**Reference files:**
- `references/templates.md` — Copy-paste templates for all document types
- `examples/bug-report.md` — Real bug report example (ChaSen context timing)

### 4. ChaSen AI Development

**Triggers:** "modify ChaSen", "update AI prompts", "add ChaSen knowledge", "test ChaSen responses", "sync knowledge"

**Key Features:**
- Architecture overview (8 core files, 4 API routes)
- Data source configuration
- Knowledge sync system and learning patterns
- Prompt development guidelines
- Multi-agent orchestration
- Memory system (short-term and long-term)

**Reference files:**
- `references/prompt-patterns.md` — Context injection, intent classification, methodology coaching
- `references/knowledge-categories.md` — 6 knowledge categories, priority levels, lifecycle, schema

### 5. News Intelligence

**Triggers:** "add news source", "configure RSS", "update news scoring", "fetch news", "scrape tenders"

**Key Features:**
- Source type and category definitions
- Scoring formula (0-100) with 5 weighted factors
- Junction table population workflow
- Tender scraping (AusTender specifics)
- Client matching workflow

**Reference files:**
- `references/source-config.md` — Source configuration SQL examples and management queries

### 6. Script Scaffolder

**Triggers:** "create a script", "write a new script", "scaffold a sync script", "create an import script", "add a fix script", "write an analysis script"

**Key Features:**
- 10 script prefix categories (apply-, sync-, fix-, add-, import-, analyse-, introspect-, validate-, seed-, enrich-)
- Database client selection rules (pg vs Supabase)
- ESM-only conventions
- Critical rules (parent env, __dirname, service role key)

**Reference files:**
- `references/templates.md` — 3 complete boilerplate templates + common patterns

### 7. BURC Financial Data

**Triggers:** "BURC", "financial data", "revenue figures", "ARR", "OPEX", "churn", "gross revenue", "waterfall", "financial targets"

**Key Features:**
- Golden rule: Always use `burc_annual_financials` for totals
- Detail table warnings (breakdowns don't match official totals)
- Authoritative column reference

**Reference files:**
- `references/gotchas.md` — Excel cell references, aggregate filtering, waterfall double-counting

### 8. Cross-Repo Workflow

**Triggers:** "commit across repos", "push changes", "update the submodule", "commit scripts", "commit docs", "sync repos"

**Key Features:**
- Repository map with paths and deploy info
- 4 commit ordering scenarios
- Push failure recovery
- Submodule status check
- Worktree awareness

**Reference files:** Self-contained (no separate references needed)

### 9. Schema Verification

**Triggers:** "verify schema", "check columns", "validate query", "what columns does X table have", writing any Supabase query, debugging column errors

**Key Features:**
- Golden rule: Never assume a column exists
- Verification workflow (4 steps)
- Quick column lookup commands
- UI vs DB column name traps

**Reference files:**
- `references/column-traps.md` — Actions table (capitalised), NPS, support, BURC, Supabase query gotchas

## Enabling the Plugin

Added to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "apac-intelligence@local": true
  }
}
```

## Usage

Skills are automatically triggered based on description keywords. Restart Claude Code session to load plugin changes.

### Testing Skills

| Skill | Test Prompt |
|-------|------------|
| test-generation | "write tests for the useNetworkGraph hook" |
| migration-workflow | "create a migration to add a column to news_articles" |
| documentation-generator | "write a bug report for the sentiment panel" |
| schema-verification | "what columns does the actions table have?" |
| script-scaffolder | "create a sync script for NPS data" |
| burc-financial-data | "show me ARR from BURC data" |
| cross-repo-workflow | "commit changes across all three repos" |
| chasen-ai-dev | "update ChaSen prompts for the planner agent" |
| news-intelligence | "add a new RSS news source" |

## Maintenance

### Updating Skills

1. Edit skill files in `~/.claude/local-plugins/apac-intelligence/skills/`
2. Restart Claude Code session to reload

### Adding New Skills

1. Create directory: `skills/new-skill-name/`
2. Add `SKILL.md` with frontmatter (name, description, version)
3. Add references/ and examples/ as needed
4. Restart session

### SKILL.md Frontmatter Requirements

```yaml
---
name: Skill Name
description: Detailed description with trigger phrases...
version: 1.0.0
---
```

All 3 fields (name, description, version) are required.

## Design Decisions

### Global vs Project-Specific

Chose global plugin because:
- Works across all 3 repositories
- Single maintenance point
- No duplication in submodules

### Skill Granularity

Created 9 focused skills rather than one large skill:
- Each skill targets specific workflows
- Progressive disclosure — only loaded when relevant
- Easier to maintain and update independently

### Reference File Organisation

Skills use `references/` for detailed content and `examples/` for real codebase samples:
- Keeps SKILL.md lean (under 2000 words)
- Detailed content loaded only when needed
- Examples sourced from real codebase (not generic templates)

## Validation History

| Date | Result | Issues Found | Fixed |
|------|--------|-------------|-------|
| 2026-02-06 | PASS | 6 broken references, 4 missing versions, 5 empty dirs | All resolved |
