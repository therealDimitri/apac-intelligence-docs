# Limited Access Level Design

**Status:** Approved
**Date:** 2026-02-15
**Author:** Jimmy + Claude

## Problem

Some users (both existing and new) need full access to only Goals & Projects, Meetings, and Actions & Tasks — without access to the rest of the dashboard (financials, NPS, health scores, pipeline, compliance, etc.). ChaSen AI context must also be scoped to prevent data leakage. Additionally, only explicitly designated admins should be able to manage user access levels.

## Key Decisions

| Decision | Choice |
|----------|--------|
| Route enforcement | Middleware-based route guard (edge enforcement) |
| User identification | `access_level` column + `is_admin` boolean on `cse_profiles` |
| Landing page (Phase 1) | Redirect to `/goals-initiatives` (temporary) |
| Landing page (Phase 2) | Custom dashboard with charts + AI insights |
| Sidebar | Stripped — only allowed sections for limited users |
| ChaSen AI | Scoped context — exclude financial/analytics tables |
| Admin UI | Extend existing `/admin/users` page with access level column |
| Admin visibility | `is_admin = true` only (not role-based) |
| Default for unknown users | `access_level = 'limited'` (safe default) |

## Phasing

- **Phase 1**: Access control infrastructure (this document)
- **Phase 2**: Limited home page dashboard with charts and AI insights (separate design)

---

## Phase 1: Access Control Infrastructure

### 1. Database Migration

```sql
-- Add access level column
ALTER TABLE cse_profiles
ADD COLUMN access_level TEXT NOT NULL DEFAULT 'full'
  CHECK (access_level IN ('full', 'limited'));

-- Add admin flag (independent of role)
ALTER TABLE cse_profiles
ADD COLUMN is_admin BOOLEAN NOT NULL DEFAULT false;

-- Grant Jimmy admin
UPDATE cse_profiles
SET is_admin = true
WHERE email = 'dimitri.leimonitis@alterahealth.com';
```

- All existing users default to `access_level = 'full'` — zero disruption
- `is_admin` defaults to `false` — only explicitly granted
- `role` column stays untouched — used for personalisation, not access control

### 2. Access Control Matrix

| `is_admin` | `access_level` | Dashboard | Admin section | Can edit access levels | Sidebar |
|------------|----------------|-----------|---------------|------------------------|---------|
| `true` | `full` | Full | Yes | Yes | Full + Admin |
| `false` | `full` | Full | No | No | Full |
| `false` | `limited` | No | No | No | Stripped (3 pages) |
| `true` | `limited` | No | Yes | Yes | Stripped + Admin |

Three independent axes:
- **`role`** — what you *do* (CSE, manager, EVP, etc.) — personalisation only
- **`access_level`** — what you can *see* (full or limited page access)
- **`is_admin`** — what you can *manage* (user access levels, admin pages)

### 3. Auth — Embed in Session

**`src/auth.ts`** JWT callback changes:
- After sign-in, query `cse_profiles` for the user's `access_level` and `is_admin` by email
- Embed in JWT token as `token.accessLevel` and `token.isAdmin`
- Session callback exposes as `session.accessLevel` and `session.isAdmin`
- Users not in `cse_profiles` → default to `access_level = 'limited'`, `is_admin = false`

### 4. Middleware Route Guard

**`src/middleware.ts`**: Read `accessLevel` and `isAdmin` from JWT token.

**For limited users (`access_level = 'limited'`):**

Allowed page routes:
- `/goals-initiatives` and all sub-routes
- `/meetings` and all sub-routes
- `/actions` and all sub-routes
- `/settings` (for ChaSen preferences — admin cards hidden in UI)
- `/auth/*`, `/feedback` (existing public paths)
- `/admin/*` only if `is_admin = true`

Allowed API routes:
- `/api/goals/*`, `/api/actions/*`, `/api/meetings/*`
- `/api/chasen` (with scoped context — see section 7)
- `/api/search` (universal search — results scoped to allowed entities)
- `/api/cse-profiles`, `/api/auth/*`
- `/api/admin/*` only if `is_admin = true`
- All existing public API paths

All other routes → redirect to `/goals-initiatives` (Phase 1 temporary landing).

**For admin routes (`/admin/*`, `/api/admin/*`):**
- Reject with 403 unless `is_admin = true` (regardless of access_level)
- This replaces the current lightweight cookie-only check

### 5. Sidebar Navigation

**Desktop sidebar** (`src/components/layout/sidebar.tsx`):

When `access_level = 'limited'`, filter `navigationGroups` to show only:
- **Command Centre** → only "Goals & Projects" child
- **Action Hub** → "Meetings" and "Actions & Tasks" children
- **Admin** → only if `is_admin = true`

Hidden groups: Success Plans, Clients, Analytics, AI Lab, Visualisations, Resources.

ChaSen AI button, universal search, and user section remain visible for all users.

**Mobile bottom nav** (`src/components/layout/MobileBottomNav.tsx`):

When `access_level = 'limited'`, replace nav items:
- Home → Goals & Projects (`/goals-initiatives`)
- Clients → removed
- Meetings → kept
- Actions → kept

**Mobile drawer** (`src/components/layout/MobileDrawer.tsx`):
- Filter menu items same as desktop sidebar logic

### 6. Settings Page Visibility

**`src/app/(dashboard)/settings/page.tsx`**:
- ChaSen AI section → visible to all users
- Administration section → only rendered when `isAdmin === true`
- Limited users without admin see only ChaSen settings cards

### 7. ChaSen AI — Scoped Context

**`src/app/api/chasen/stream/route.ts`**:
- Read `accessLevel` from session/token at start of POST handler
- Pass to `getLiveDashboardContext()` and `getDynamicDashboardContext()`

**`getLiveDashboardContext(clientName, accessLevel)`** — when `'limited'`, only query:
- `unified_meetings` — meetings data
- `actions` — tasks data
- `apac_planning_goals` / `portfolio_initiatives` — goals data
- `comments` — discussion context
- `action_activity_log` — activity context

Skip all: NPS (`nps_responses`, `nps_topic_classifications`), health scores (`client_health_history`), BURC/financials (`burc_*`), aging accounts, pipeline, compliance, support metrics, segmentation, alerts.

**`getDynamicDashboardContext(clientName, excludeTables, accessLevel)`** — when `'limited'`:
- Filter `chasen_data_sources` to exclude `'analytics'` and `'operations'` categories
- Only allow sources relevant to meetings/actions/goals

**System prompt addition** for limited users:
> "You only have access to Goals, Meetings, and Actions data. If the user asks about financials, NPS, health scores, pipeline, compliance, or other restricted topics, explain that this information is not available in their current access level."

### 8. Admin UI — Access Level Management

**Extend existing `/admin/users` page** (`src/app/(dashboard)/admin/users/page.tsx`):
- Add **Access Level** column to the users table with inline `<Select>` dropdown: `Full` | `Limited`
- Add **Admin** column with a toggle/checkbox for `is_admin`
- On change → PATCH `/api/admin/users/access-level`
- Show confirmation toast on save
- Only accessible when `is_admin = true` (enforced by both middleware and UI)

**New API endpoint** (`src/app/api/admin/users/access-level/route.ts`):
- PATCH handler: accepts `{ email, access_level?, is_admin? }`
- Validates `is_admin` from session before allowing changes
- Updates `cse_profiles` record
- Returns updated user record
- Audit log entry for access level changes

### 9. useUserProfile Hook

**`src/hooks/useUserProfile.ts`**:
- Add `accessLevel: 'full' | 'limited'` to `UserProfile` interface
- Add `isAdmin: boolean` to `UserProfile` interface
- Query `access_level` and `is_admin` from `cse_profiles` alongside existing fields
- Default to `access_level = 'limited'`, `is_admin = false` if user not found

### 10. Type Updates

**`src/types/database.generated.ts`**: Auto-updated by `npm run db:refresh` after migration.

**NextAuth type declarations**: Extend session and JWT types to include `accessLevel` and `isAdmin`.

---

## Phase 2: Limited Home Page Dashboard (Future — Separate Design)

Custom dashboard at `/limited-home` combining all three domains with AI intelligence.

### Widget Grid (2x2)

| Widget | Source | Chart Type |
|--------|--------|------------|
| Goal Progress Overview | `apac_planning_goals` | Donut/bar by status (on track, at risk, overdue, completed) |
| Action Status Snapshot | `actions` | Stacked bar + overdue count callout |
| Meeting Activity | `unified_meetings` | Sparkline/calendar heatmap — meetings per week |
| Overdue & Stale Items | Goals + Actions | Sorted attention list — days overdue |

### AI Intelligence Panel

| Section | Content |
|---------|---------|
| Today's Priorities (nudges) | "3 actions due today", "Meeting with ClientX in 2hrs — no prep notes", "Goal Y status update overdue by 5 days" |
| Weekly Trends (patterns) | "Action completion rate: 72% (down 8% from last week)", "2 goals unchanged for 14+ days", "Meeting frequency down 20% vs last month" |

### Open Design Questions
- Visual design (reuse CardContainer, StatusBadge, Recharts)
- API endpoint for AI insights (new route vs ChaSen stream with specific prompt)
- Refresh cadence (real-time on mount vs cached/periodic)
- Widget drill-down behaviour (click to navigate to respective page)

---

## Files Changed (Phase 1)

| File | Change |
|------|--------|
| New migration | `access_level` column + `is_admin` boolean on `cse_profiles` |
| `src/auth.ts` | Query access_level + is_admin in JWT callback, expose in session |
| `src/middleware.ts` | Route allowlist guard for limited users, admin check for /admin/* |
| `src/components/layout/sidebar.tsx` | Filter nav groups by access level + is_admin |
| `src/components/layout/MobileBottomNav.tsx` | Swap nav items for limited users |
| `src/components/layout/MobileDrawer.tsx` | Filter drawer items |
| `src/app/(dashboard)/settings/page.tsx` | Hide Administration section for non-admin users |
| `src/app/(dashboard)/admin/users/page.tsx` | Add Access Level + Admin columns with inline editing |
| `src/app/api/admin/users/access-level/route.ts` | New PATCH endpoint for access level + admin changes |
| `src/app/api/chasen/stream/route.ts` | Pass access level to context loaders |
| `src/lib/chasen-dynamic-context.ts` | Filter data sources by access level |
| `src/hooks/useUserProfile.ts` | Expose `accessLevel` and `isAdmin` from profile |
| NextAuth type declarations | Add `accessLevel` and `isAdmin` to session/JWT types |

## What Stays Unchanged

- All existing full-access users — zero impact, no behaviour change
- Dashboard (`/`) — completely untouched for full-access users
- Database schema for goals, meetings, actions — untouched
- Page components for the 3 allowed pages — no changes needed
- API routes for goals, meetings, actions — no changes needed
- Existing `role` field and role-based personalisation — untouched
- Pre-commit hooks, tests, CI — no changes
