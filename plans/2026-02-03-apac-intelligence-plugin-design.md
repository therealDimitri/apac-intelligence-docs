# APAC Intelligence Plugin Design

**Date:** 2026-02-03
**Author:** Claude Code
**Status:** Implemented

## Overview

Created a global Claude Code plugin containing 5 project-specific skills for the APAC Intelligence codebase (apac-intelligence-v2, apac-intelligence-scripts, apac-intelligence-docs).

## Plugin Location

```
~/.claude/plugins/local/apac-intelligence/
├── plugin.json
└── skills/
    ├── test-generation/
    │   ├── SKILL.md
    │   └── references/mock-patterns.md
    ├── migration-workflow/
    │   ├── SKILL.md
    │   └── references/common-migrations.md
    ├── documentation-generator/
    │   ├── SKILL.md
    │   └── references/templates.md
    ├── chasen-ai-dev/
    │   ├── SKILL.md
    │   └── references/prompt-patterns.md
    └── news-intelligence/
        ├── SKILL.md
        └── references/source-config.md
```

## Skills Summary

### 1. Test Generation

**Triggers:** "write tests", "add unit tests", "test this component"

**Key Features:**
- Supabase mocking patterns (wrapper vs library)
- API response structure guidance (`json.data.data`)
- Hook and API route test templates
- Error handling patterns

### 2. Migration Workflow

**Triggers:** "create a migration", "add database column", "modify schema"

**Key Features:**
- pg client usage (no exec_sql RPC)
- Migration file naming convention
- Schema regeneration workflow
- RLS policy templates
- Common SQL patterns

### 3. Documentation Generator

**Triggers:** "create documentation", "write bug report", "document process"

**Key Features:**
- File naming: `TYPE-YYYYMMDD-description.md`
- Bug report structure with Status header
- Process and data import templates
- Submodule commit workflow
- PDF export via Typora

### 4. ChaSen AI Development

**Triggers:** "modify ChaSen", "update AI prompts", "sync knowledge"

**Key Features:**
- Architecture overview (agents, prompts, learning)
- Data source configuration
- Knowledge sync patterns
- Prompt development guidelines
- Multi-agent orchestration

### 5. News Intelligence

**Triggers:** "add news source", "configure RSS", "fetch news"

**Key Features:**
- Source type and category definitions
- Scoring formula (0-100)
- Junction table population
- Tender scraping (AusTender specifics)
- Client matching workflow

## Enabling the Plugin

Added to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "apac-intelligence@local": true,
    ...
  }
}
```

## Usage

Skills are automatically triggered based on description keywords. Restart Claude Code session to load the new plugin.

### Manual Invocation

Skills can also be used with the Skill tool if needed for explicit invocation.

## Maintenance

### Updating Skills

1. Edit skill files in `~/.claude/plugins/local/apac-intelligence/skills/`
2. Restart Claude Code session to reload

### Adding New Skills

1. Create directory: `skills/new-skill-name/`
2. Add `SKILL.md` with frontmatter (name, description, version)
3. Add references/ and examples/ as needed
4. Restart session

## Design Decisions

### Global vs Project-Specific

Chose global plugin because:
- Works across all 3 repositories
- Single maintenance point
- No duplication in submodules

### Skill Granularity

Created 5 focused skills rather than one large skill:
- Each skill targets specific workflows
- Progressive disclosure - only loaded when relevant
- Easier to maintain and update independently

### Reference File Organisation

Each skill has a `references/` directory:
- Keeps SKILL.md lean (under 2000 words)
- Detailed content loaded only when needed
- Templates and patterns easily accessible
