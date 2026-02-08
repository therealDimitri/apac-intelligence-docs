# APAC Intelligence — Master Plan & Knowledge Base

> The skeleton that makes Claude Code 10x faster. Every section contains the context, conventions, and current state needed to work on any part of the system without re-exploration.

## What This Is

APAC Intelligence is an internal platform for Altera Digital Health's APAC team. It unifies client management, financial tracking, meeting workflows, and AI-powered insights into a single dashboard.

**Users:**
- **CSEs & CAMs** — Daily client activity management, meeting tracking, action follow-ups
- **Leadership & Senior Execs** — Business vs targets overview, portfolio health, strategic planning

**Solo developer project** built with Next.js + Supabase + Netlify.

## Knowledge Base Sections

| # | Section | Purpose | Key Files |
|---|---------|---------|-----------|
| 01 | [Vision](01-vision/) | Users, workflows, success metrics | users-and-workflows.md |
| 02 | [Data Pipeline](02-data-pipeline/) | How data enters the system | sync-architecture.md, burc-sync.md, data-quality.md |
| 03 | [AI & Intelligence](03-ai-intelligence/) | ChaSen AI, predictions, insights | chasen-architecture.md, tools.md, context-system.md |
| 04 | [User Experience](04-user-experience/) | Navigation, design system, workflows | navigation-map.md, design-system.md, workflows.md |
| 05 | [Feature Inventory](05-feature-inventory/) | What's live vs scaffolded | phase-audit.md, feature-matrix.md, phase-7-8-reference.md, phase-9-10-reference.md, domain-features.md |
| 06 | [Database](06-database/) | Schema, relationships, gotchas | tables.md, gotchas.md, migrations.md |
| 07 | [Infrastructure](07-infrastructure/) | Deploy, OneDrive, scripts | netlify.md, onedrive.md, scripts-submodule.md |
| 08 | [Roadmap](08-roadmap/) | What to build next | priorities.md, quick-wins.md, asana-inspired-enhancements.md, asana-implementation-plan.md |

## How Claude Code Should Use This

1. **Starting a task?** Read the relevant section's README first
2. **Touching data sync?** Read `02-data-pipeline/` before writing code
3. **Changing UI?** Read `04-user-experience/design-system.md` for conventions
4. **Adding a feature?** Check `05-feature-inventory/phase-audit.md` to understand what exists
5. **Writing queries?** Read `06-database/gotchas.md` to avoid known traps

## Architecture Overview

```
[OneDrive Excel Files]
        |
        v
[scripts/*.mjs] ──sync──> [Supabase PostgreSQL]
        |                          |
[lib/onedrive-paths.mjs]          v
                          [Next.js API Routes]
                                  |
                                  v
                          [React Dashboard UI]
                                  |
                                  v
                          [ChaSen AI Layer]
                           (context + tools)
```

## Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| Frontend | Next.js 14 (App Router) | TypeScript, Tailwind CSS, shadcn/ui |
| Database | Supabase (PostgreSQL) | Project: `usoyxsunetvxdjdglkmn`, ap-south-1 |
| Auth | NextAuth + Azure AD | SSO via Microsoft Entra ID |
| AI | Anthropic Claude API | Via `callMatchaAI()` wrapper |
| Deploy | Netlify | Auto-deploy on git push to main |
| Data Sync | Node.js scripts (.mjs) | Git submodule, OneDrive → Supabase |
| File Storage | OneDrive/SharePoint | Auto-detected via `onedrive-paths.mjs` resolver |

## Guiding Principles

1. **Data accuracy over features** — A wrong number erodes trust faster than a missing feature
2. **Automate everything** — CSEs shouldn't manually enter data that exists elsewhere
3. **Intelligent defaults** — Show the right information without requiring configuration
4. **Simple workflows** — Every click should feel purposeful, not navigational
5. **Graceful degradation** — AI features enhance but never block core workflows
