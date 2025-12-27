# Feature: Job Descriptions for ChaSen Context

**Date:** 27 December 2025
**Commits:** `1b22f74`, `ff43380`

## Overview

Added detailed job descriptions to all team member profiles, enabling ChaSen to understand each person's responsibilities and provide more contextually relevant responses.

## Database Changes

Added `job_description` column to `cse_profiles` table:

```sql
ALTER TABLE cse_profiles ADD COLUMN IF NOT EXISTS job_description TEXT;
```

**Migration:** `docs/migrations/20251227_add_job_descriptions.sql`

## Job Descriptions by Role

| Role | Job Description |
|------|-----------------|
| EVP APAC | Executive Vice President responsible for overall APAC business strategy, P&L ownership, and regional leadership. Oversees all functional areas including Sales, Client Success, Solutions, and Support. |
| AVP Client Success, APAC | Leads the Client Success team across APAC, driving customer retention, satisfaction, and growth. Manages CSE team performance, develops success strategies, and serves as executive sponsor for key accounts. |
| VP Business Support | Oversees business operations, project delivery, and support functions. Ensures operational excellence and coordinates cross-functional initiatives. |
| VP Solutions | Leads pre-sales and solutions consulting, working with prospects and clients to design optimal Altera solutions. Manages clinical and technical consulting resources. |
| Client Success Executive | Primary client relationship owner responsible for client health, satisfaction, and retention. Conducts regular check-ins, coordinates support issues, and drives adoption of Altera solutions. |
| Client Account Manager | Manages commercial aspects of client relationships including contract renewals, upsells, and account growth opportunities. Works closely with CSEs on account strategy. |
| Director Solutions | Senior solutions consultant providing technical and clinical expertise for complex implementations and strategic accounts. |
| Chief Medical Officer | Provides clinical leadership and healthcare industry expertise. Advises on product direction, clinical workflows, and healthcare regulations. |
| Project Manager | Manages client implementation projects, coordinating resources, timelines, and deliverables. Ensures successful go-lives and client satisfaction. |
| AVP Support | Leads the support organisation, ensuring timely resolution of client issues and maintaining high service levels. |
| Business Operations | Supports operational processes, reporting, and administrative functions for the APAC team. |
| Sr Field Marketing, APAC | Develops and executes regional marketing campaigns, events, and demand generation activities. |
| Sr HR Business Partner | Partners with APAC leadership on talent management, employee engagement, and HR initiatives. |
| Country Manager | Oversees all Altera operations within assigned country, managing local teams and client relationships. |
| SVP Client Success & Operations | Global leader for Client Success and Operations, setting strategy and best practices across all regions. |
| VP Client Success | Leads global Client Success initiatives, driving methodology, tools, and team development. |
| Marketing Manager | Manages marketing programs and campaigns, coordinating with regional teams on content and messaging. |
| AVP Program Delivery | Manages program delivery and implementation coordination across the APAC region. |

## ChaSen Integration

The chat route (`/api/chasen/chat/route.ts`) now includes job descriptions in the org context:

1. **User's own role:** Shows their job description at the start of org context
2. **Manager's role:** When user reports to someone, shows manager's responsibilities
3. **Direct reports:** Each direct report listed with their job description

### Example Org Context Output

For Dimitri (AVP Client Success):

```
- Dimitri's Role: Leads the Client Success team across APAC, driving customer retention, satisfaction, and growth...
- Reports to: Todd Haebich (EVP APAC)
  Manager's responsibilities: Executive Vice President responsible for overall APAC business strategy...
- Direct Reports (7):
  * Gilbert So (Client Success Executive): Primary client relationship owner responsible for client health...
  * Tracey Bland (Client Success Executive): Primary client relationship owner responsible for client health...
  * Laura Messing (Client Success Executive): Primary client relationship owner responsible for client health...
  * Nikki Wei (Client Account Manager): Manages commercial aspects of client relationships...
  ...
```

## Files Modified

| File | Changes |
|------|---------|
| `src/app/api/chasen/chat/route.ts` | Added `job_description` to select query, enhanced org context builder |
| `src/types/database.generated.ts` | Auto-generated types updated |
| `docs/database-schema.md` | Schema documentation updated |

## Usage

ChaSen can now answer questions like:
- "What does my manager do?"
- "What are my team's responsibilities?"
- "Who handles support issues?"

With accurate, role-specific context from the job descriptions.

## Related

- [Org-Aware ChaSen](./FEATURE-20251227-org-aware-chasen.md) - Parent feature for org structure awareness
- [Stream Role Mapping Bug](./BUG-REPORT-20251227-chasen-stream-role-mapping.md) - Related fix for role display
