# Limited Access Level — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add access_level ('full'|'limited') and is_admin (boolean) to cse_profiles, then enforce route restrictions, sidebar filtering, ChaSen AI context scoping, and an admin UI for managing access levels.

**Architecture:** Middleware-based route guard reads access_level and is_admin from the JWT token. Limited users can only access Goals & Projects, Meetings, and Actions & Tasks. ChaSen AI context loaders are filtered to exclude financial/analytics data. Admin UI extends the existing /admin/users page.

**Tech Stack:** Next.js 16, NextAuth v5, Supabase (PostgreSQL), TypeScript, Tailwind CSS

**Design doc:** `docs/plans/2026-02-15-limited-access-design.md`

---

### Task 1: Database Migration

**Files:**
- Create: `supabase/migrations/20260215_access_level_and_admin.sql`

**Step 1: Write the migration SQL**

```sql
-- Add access level column (controls which pages a user can see)
ALTER TABLE cse_profiles
ADD COLUMN IF NOT EXISTS access_level TEXT NOT NULL DEFAULT 'full';

-- Add check constraint
ALTER TABLE cse_profiles
ADD CONSTRAINT cse_profiles_access_level_check
CHECK (access_level IN ('full', 'limited'));

-- Add admin flag (controls who can manage access levels)
ALTER TABLE cse_profiles
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT false;

-- Grant Jimmy admin access
UPDATE cse_profiles
SET is_admin = true
WHERE email = 'dimitri.leimonitis@alterahealth.com';

-- Index for middleware JWT lookup performance
CREATE INDEX IF NOT EXISTS idx_cse_profiles_email_access
ON cse_profiles (email, access_level, is_admin);
```

**Step 2: Apply migration via Supabase MCP**

Run: Use Supabase MCP `apply_migration` tool with the SQL above.

**Step 3: Verify migration applied**

Run: Use Supabase MCP `execute_sql` to verify:
```sql
SELECT email, access_level, is_admin
FROM cse_profiles
WHERE email = 'dimitri.leimonitis@alterahealth.com';
```
Expected: `access_level = 'full'`, `is_admin = true`

**Step 4: Regenerate database types**

Run: `cd ~/GitHub/apac-intelligence-v2 && npm run db:refresh`

**Step 5: Commit**

```bash
git add supabase/migrations/20260215_access_level_and_admin.sql src/types/database.generated.ts
git commit -m "feat: add access_level and is_admin columns to cse_profiles"
```

---

### Task 2: NextAuth Type Declarations

**Files:**
- Modify: `src/types/next-auth.d.ts`

**Step 1: Add accessLevel and isAdmin to session and JWT types**

Replace entire file contents with:

```typescript
import { DefaultSession } from "next-auth"

declare module "next-auth" {
  interface Session {
    accessToken?: string
    accessLevel?: "full" | "limited"
    isAdmin?: boolean
    error?: string
    user: {
      email?: string | null
      name?: string | null
      image?: string | null
    } & DefaultSession["user"]
  }
}

declare module "next-auth/jwt" {
  interface JWT {
    accessToken?: string
    refreshToken?: string
    accessTokenExpires?: number
    accessLevel?: "full" | "limited"
    isAdmin?: boolean
    error?: string
  }
}
```

**Step 2: Commit**

```bash
git add src/types/next-auth.d.ts
git commit -m "feat: add accessLevel and isAdmin to NextAuth type declarations"
```

---

### Task 3: Auth — Embed Access Level in JWT

**Files:**
- Modify: `src/auth.ts:303-390` (jwt and session callbacks)

**Step 1: Add Supabase import at top of file**

Add after the existing imports (line ~4):

```typescript
import { getServiceSupabase } from '@/lib/supabase'
```

**Step 2: Add access level lookup helper**

Add before the `authConfig` export (around line 230):

```typescript
/**
 * Fetch access_level and is_admin from cse_profiles for a given email.
 * Returns safe defaults ('limited', false) if user is not found.
 */
async function getUserAccessInfo(email: string): Promise<{
  accessLevel: 'full' | 'limited'
  isAdmin: boolean
}> {
  try {
    const supabase = getServiceSupabase()
    const { data } = await supabase
      .from('cse_profiles')
      .select('access_level, is_admin')
      .eq('email', email)
      .single()

    return {
      accessLevel: (data?.access_level as 'full' | 'limited') || 'limited',
      isAdmin: data?.is_admin ?? false,
    }
  } catch {
    // Default to limited access for unknown users
    return { accessLevel: 'limited', isAdmin: false }
  }
}
```

**Step 3: Update JWT callback to store access info on sign-in**

In the `jwt` callback (line ~303), modify the initial sign-in block (`if (account && user)`) to:

```typescript
    async jwt({ token, account, user }) {
      // Initial sign in - store access token, user info, and access level
      if (account && user) {
        // Fetch access level from database
        const accessInfo = await getUserAccessInfo(user.email || '')

        return {
          ...token,
          accessToken: account.access_token,
          refreshToken: account.refresh_token,
          accessTokenExpires: account.expires_at,
          accessLevel: accessInfo.accessLevel,
          isAdmin: accessInfo.isAdmin,
          user: {
            ...user,
            email: user.email,
            name: user.name,
            image: user.image,
          },
        }
      }
```

**Step 4: Update session callback to expose access info**

In the `session` callback (line ~355), add `accessLevel` and `isAdmin` to the returned session:

```typescript
    async session({ session, token }: any) {
      return {
        ...session,
        accessToken: token.accessToken,
        accessLevel: token.accessLevel || 'limited',
        isAdmin: token.isAdmin || false,
        // ... rest of existing session callback unchanged
```

**Step 5: Verify TypeScript compiles**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -20`
Expected: No errors related to auth.ts

**Step 6: Commit**

```bash
git add src/auth.ts
git commit -m "feat: embed accessLevel and isAdmin in JWT and session"
```

---

### Task 4: Middleware Route Guard

**Files:**
- Modify: `src/middleware.ts:36-117`

**Step 1: Add route allowlists after the existing `adminPaths` constant (line ~30)**

```typescript
// Routes accessible to limited-access users
const limitedAllowedPages = [
  '/goals-initiatives',
  '/meetings',
  '/actions',
  '/settings',
  '/auth/',
  '/feedback',
  '/api/auth',
  '/api/goals',
  '/api/actions',
  '/api/meetings',
  '/api/chasen',
  '/api/search',
  '/api/cse-profiles',
  '/api/emails/feedback',
]

// Routes that require is_admin flag
const adminOnlyPaths = ['/admin/', '/api/admin/']
```

**Step 2: Add JWT decode helper**

Add after the constants:

```typescript
/**
 * Lightweight JWT payload extraction from session cookie.
 * Decodes the JWT payload without full cryptographic verification
 * (NextAuth handles that in route handlers via auth()).
 * Returns null if no valid token found.
 */
function getTokenPayload(request: NextRequest): {
  accessLevel?: string
  isAdmin?: boolean
} | null {
  const allCookies = request.cookies.getAll()
  // Find the session token cookie
  const sessionCookie = allCookies.find(
    c =>
      c.name === 'authjs.session-token' ||
      c.name === '__Secure-authjs.session-token'
  )
  if (!sessionCookie?.value) return null

  try {
    // NextAuth v5 uses JWE (encrypted JWT), not plain JWT
    // We cannot decode it in middleware without the encryption key
    // Instead, we use a lightweight approach: store access info in a separate cookie
    // set during the session callback
    const accessCookie = request.cookies.get('access-info')
    if (accessCookie?.value) {
      return JSON.parse(atob(accessCookie.value))
    }
    return null
  } catch {
    return null
  }
}
```

**Important note:** NextAuth v5 uses JWE (encrypted tokens), so we cannot decode the JWT payload directly in middleware. Instead, we set a lightweight `access-info` cookie during session creation. See Task 3b below.

**Step 3: Add access level checking in the middleware function**

After the existing `hasSessionCookie` check succeeds (both dev and production paths), add:

```typescript
    // Check access level for authenticated users
    const tokenPayload = getTokenPayload(request)

    // Admin-only paths: require is_admin flag
    if (adminOnlyPaths.some(path => pathname.startsWith(path))) {
      if (!tokenPayload?.isAdmin) {
        // Redirect non-admins away from admin pages
        return NextResponse.redirect(new URL('/goals-initiatives', request.url))
      }
      return NextResponse.next()
    }

    // Limited access users: restrict to allowed pages only
    if (tokenPayload?.accessLevel === 'limited') {
      const isAllowed = limitedAllowedPages.some(path => pathname.startsWith(path))
      if (!isAllowed) {
        // Redirect to goals as temporary landing page
        return NextResponse.redirect(new URL('/goals-initiatives', request.url))
      }
    }

    return NextResponse.next()
```

**Step 4: Verify dev server still works**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | head -20`

**Step 5: Commit**

```bash
git add src/middleware.ts
git commit -m "feat: add middleware route guard for limited access and admin-only paths"
```

---

### Task 3b: Access Info Cookie

Because NextAuth v5 encrypts JWT tokens (JWE), middleware cannot decode them. We need a lightweight unencrypted cookie to carry access info.

**Files:**
- Modify: `src/auth.ts` (session callback, around line 355)

**Step 1: Set access-info cookie in session callback**

The session callback returns a session object but cannot set cookies directly. Instead, use NextAuth's `jwt` callback to set a response header. However, the cleanest approach is to set this cookie via middleware response manipulation.

Alternative approach — modify the middleware to read from a separate API endpoint on first request, then cache in cookie. But this adds latency.

**Simplest approach:** Instead of decoding the JWT in middleware, use a dedicated API route that the middleware calls on first request, or set the cookie from the client via `useSession`.

**Recommended approach:** Set the `access-info` cookie from the layout component on mount. The layout already has access to the session via `SessionProvider`.

Add to `src/app/(dashboard)/layout.tsx` inside `DashboardLayoutContent`:

```typescript
import { useSession } from 'next-auth/react'

// Inside DashboardLayoutContent:
const { data: session } = useSession()

// Set access-info cookie for middleware consumption
useEffect(() => {
  if (session) {
    const accessInfo = btoa(JSON.stringify({
      accessLevel: (session as any).accessLevel || 'full',
      isAdmin: (session as any).isAdmin || false,
    }))
    document.cookie = `access-info=${accessInfo};path=/;max-age=${30 * 24 * 60 * 60};samesite=lax`
  }
}, [session])
```

**Note:** On the very first request after login (before layout mounts), the cookie won't exist yet. The middleware should treat missing `access-info` cookie as `'full'` access to avoid blocking users during the brief window between login and layout mount. Once the layout renders and sets the cookie, subsequent requests are properly gated.

**Step 2: Update middleware fallback**

In the `getTokenPayload` function, ensure it returns `null` when cookie is missing, and update the middleware to treat `null` as unrestricted (the first request after login scenario):

```typescript
    // If no access info cookie yet (first request after login), allow through
    // The layout will set the cookie on mount, and subsequent requests will be gated
    if (!tokenPayload) {
      return NextResponse.next()
    }
```

**Step 3: Commit**

```bash
git add src/auth.ts src/app/\(dashboard\)/layout.tsx src/middleware.ts
git commit -m "feat: set access-info cookie from layout for middleware consumption"
```

---

### Task 5: useUserProfile — Expose Access Level

**Files:**
- Modify: `src/hooks/useUserProfile.ts:24-56` (UserProfile interface) and `~268-274` (query)

**Step 1: Add fields to UserProfile interface**

Add after `photoUrl` (around line 48):

```typescript
  accessLevel: 'full' | 'limited'
  isAdmin: boolean
```

**Step 2: Update the cse_profiles query to include new columns**

At line ~270, update the `.select()` call:

```typescript
        .select(
          'full_name, first_name, role, photo_url, job_description, is_global_role, reports_to, access_level, is_admin'
        )
```

**Step 3: Add variables after the existing role/roleTitle declarations (around line ~265)**

```typescript
      let accessLevel: UserProfile['accessLevel'] = 'limited'
      let isAdmin = false
```

**Step 4: Set values from profile data (after line ~274, inside the `if (cseProfile)` block)**

```typescript
        accessLevel = (cseProfile.access_level as UserProfile['accessLevel']) || 'limited'
        isAdmin = cseProfile.is_admin ?? false
```

**Step 5: Include in the returned profile object (around line ~510)**

Add to the object that's being set via `setProfile(...)`:

```typescript
        accessLevel,
        isAdmin,
```

**Step 6: Verify TypeScript compiles**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | grep -i "useUserProfile" | head -10`

**Step 7: Commit**

```bash
git add src/hooks/useUserProfile.ts
git commit -m "feat: expose accessLevel and isAdmin from useUserProfile hook"
```

---

### Task 6: Desktop Sidebar — Filter Navigation

**Files:**
- Modify: `src/components/layout/sidebar.tsx:54-137` (navigationGroups) and `~139+` (Sidebar component)

**Step 1: Add access-level-aware navigation filtering**

Inside the `Sidebar()` function (after `const { profile, updatePreferences } = useUserProfile()` at line ~210), add:

```typescript
  // Filter navigation groups based on access level
  const filteredGroups = useMemo(() => {
    const accessLevel = profile?.accessLevel || 'full'
    const isAdmin = profile?.isAdmin || false

    if (accessLevel === 'full') {
      // Full access users: show everything, but Admin group only if is_admin
      return isAdmin
        ? navigationGroups
        : navigationGroups.filter(g => g.name !== 'Admin')
    }

    // Limited access users: only show allowed groups with filtered children
    const allowedGroups: NavigationGroup[] = []

    // Command Centre → only Goals & Projects
    const commandCentre = navigationGroups.find(g => g.name === 'Command Centre')
    if (commandCentre) {
      allowedGroups.push({
        ...commandCentre,
        children: commandCentre.children.filter(c => c.href === '/goals-initiatives'),
      })
    }

    // Action Hub → Meetings and Actions & Tasks only
    const actionHub = navigationGroups.find(g => g.name === 'Action Hub')
    if (actionHub) {
      allowedGroups.push({
        ...actionHub,
        children: actionHub.children.filter(
          c => c.href === '/meetings' || c.href === '/actions'
        ),
      })
    }

    // Admin group → only if is_admin
    if (isAdmin) {
      const adminGroup = navigationGroups.find(g => g.name === 'Admin')
      if (adminGroup) allowedGroups.push(adminGroup)
    }

    return allowedGroups
  }, [profile?.accessLevel, profile?.isAdmin])
```

Add `useMemo` to the existing imports from React (line ~2).

**Step 2: Replace `navigationGroups` references with `filteredGroups`**

In the JSX rendering (around line ~348), change:

```typescript
// Before:
{navigationGroups.map(group => {
// After:
{filteredGroups.map(group => {
```

Also update the SSR placeholder (around line ~427):

```typescript
// Before:
{navigationGroups.map(group => (
// After:
{filteredGroups.map(group => (
```

**Step 3: Verify TypeScript compiles**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | grep -i "sidebar" | head -10`

**Step 4: Commit**

```bash
git add src/components/layout/sidebar.tsx
git commit -m "feat: filter sidebar navigation by access level and admin status"
```

---

### Task 7: Mobile Bottom Nav — Filter Items

**Files:**
- Modify: `src/components/layout/MobileBottomNav.tsx:70-85`

**Step 1: Add useUserProfile import and access level filtering**

Add import at top:

```typescript
import { useUserProfile } from '@/hooks/useUserProfile'
```

Inside the `MobileBottomNav` component (after line ~76), add:

```typescript
  const { profile } = useUserProfile()
  const isLimited = profile?.accessLevel === 'limited'
```

**Step 2: Replace the hardcoded navItems with access-level-aware items**

Replace the `navItems` declaration (line ~80):

```typescript
  const navItems = isLimited
    ? [
        { name: 'Goals', href: '/goals-initiatives', icon: Target, badgeKey: 'home' as const },
        { name: 'Meetings', href: '/meetings', icon: Calendar, badgeKey: 'meetings' as const },
        { name: 'Actions', href: '/actions', icon: CheckSquare, badgeKey: 'actions' as const },
      ]
    : [
        { name: 'Home', href: '/', icon: Home, badgeKey: 'home' as const },
        { name: 'Clients', href: '/client-profiles', icon: Users, badgeKey: 'clients' as const },
        { name: 'Meetings', href: '/meetings', icon: Calendar, badgeKey: 'meetings' as const },
        { name: 'Actions', href: '/actions', icon: CheckSquare, badgeKey: 'actions' as const },
      ]
```

Add `Target` to the lucide-react imports.

**Step 3: Commit**

```bash
git add src/components/layout/MobileBottomNav.tsx
git commit -m "feat: filter mobile bottom nav items by access level"
```

---

### Task 8: Mobile Drawer — Filter Groups

**Files:**
- Modify: `src/components/layout/MobileDrawer.tsx:30-73` (navigationGroups) and `~86+`

**Step 1: Add useUserProfile import and filtering logic**

Add import at top:

```typescript
import { useUserProfile } from '@/hooks/useUserProfile'
```

Inside the `MobileDrawer` component (after line ~96), add:

```typescript
  const { profile } = useUserProfile()

  // Filter navigation groups based on access level
  const filteredGroups = useMemo(() => {
    const accessLevel = profile?.accessLevel || 'full'
    if (accessLevel === 'full') return navigationGroups

    return [
      {
        ...navigationGroups.find(g => g.name === 'Command Centre')!,
        children: [{ name: 'Goals & Projects', href: '/goals-initiatives', description: 'Goals & projects' }],
      },
      navigationGroups.find(g => g.name === 'Action Hub')!,
    ].filter(Boolean)
  }, [profile?.accessLevel])
```

Add `useMemo` to the React imports.

**Step 2: Replace `navigationGroups` in the JSX rendering (line ~250)**

```typescript
// Before:
{navigationGroups.map(group => {
// After:
{filteredGroups.map(group => {
```

**Step 3: Commit**

```bash
git add src/components/layout/MobileDrawer.tsx
git commit -m "feat: filter mobile drawer navigation by access level"
```

---

### Task 9: Settings Page — Hide Admin Section

**Files:**
- Modify: `src/app/(dashboard)/settings/page.tsx`

**Step 1: Convert to client component and add access check**

Add `'use client'` at top and import useUserProfile:

```typescript
'use client'

import { useUserProfile } from '@/hooks/useUserProfile'
```

**Step 2: Use profile in the component**

Inside `SettingsPage()`, add:

```typescript
  const { profile } = useUserProfile()
  const isAdmin = profile?.isAdmin || false
```

**Step 3: Conditionally render admin section**

Wrap the Administration section (around line ~180):

```typescript
      {/* Admin Settings — only visible to admins */}
      {isAdmin && (
        <div>
          <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
            <SettingsIcon className="h-5 w-5 text-purple-600" />
            Administration
          </h2>
          <div className="grid gap-4">{adminCards.map(renderCard)}</div>
        </div>
      )}
```

**Step 4: Commit**

```bash
git add src/app/\(dashboard\)/settings/page.tsx
git commit -m "feat: hide admin settings section for non-admin users"
```

---

### Task 10: Admin Users Page — Access Level Column

**Files:**
- Modify: `src/app/(dashboard)/admin/users/page.tsx`

**Step 1: Add access_level and is_admin to the UserProfile interface (line ~48)**

```typescript
interface UserProfile {
  // ... existing fields ...
  access_level: 'full' | 'limited'
  is_admin: boolean
}
```

**Step 2: Add Access Level and Admin columns to the table**

In the table header row, add after the existing role column header:

```tsx
<TableHead>Access Level</TableHead>
<TableHead>Admin</TableHead>
```

**Step 3: Add inline editing cells in the table body**

In the table row rendering, add after the role cell:

```tsx
<TableCell>
  <Select
    value={user.access_level || 'full'}
    onValueChange={(value) => handleAccessLevelChange(user.email, value as 'full' | 'limited')}
  >
    <SelectTrigger className="w-[100px] h-8">
      <SelectValue />
    </SelectTrigger>
    <SelectContent>
      <SelectItem value="full">Full</SelectItem>
      <SelectItem value="limited">Limited</SelectItem>
    </SelectContent>
  </Select>
</TableCell>
<TableCell>
  <input
    type="checkbox"
    checked={user.is_admin || false}
    onChange={(e) => handleAdminToggle(user.email, e.target.checked)}
    className="h-4 w-4 rounded border-gray-300 text-purple-600 focus:ring-purple-500"
  />
</TableCell>
```

**Step 4: Add handler functions inside the component**

```typescript
  const handleAccessLevelChange = async (email: string, accessLevel: 'full' | 'limited') => {
    try {
      const res = await fetch('/api/admin/users/access-level', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, access_level: accessLevel }),
      })
      if (!res.ok) throw new Error('Failed to update access level')
      // Update local state
      setUsers(prev => prev.map(u => u.email === email ? { ...u, access_level: accessLevel } : u))
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update access level')
    }
  }

  const handleAdminToggle = async (email: string, isAdmin: boolean) => {
    try {
      const res = await fetch('/api/admin/users/access-level', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, is_admin: isAdmin }),
      })
      if (!res.ok) throw new Error('Failed to update admin status')
      setUsers(prev => prev.map(u => u.email === email ? { ...u, is_admin: isAdmin } : u))
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update admin status')
    }
  }
```

**Step 5: Commit**

```bash
git add src/app/\(dashboard\)/admin/users/page.tsx
git commit -m "feat: add access level and admin columns to user management page"
```

---

### Task 11: Admin API Endpoint

**Files:**
- Create: `src/app/api/admin/users/access-level/route.ts`

**Step 1: Create the PATCH endpoint**

```typescript
/**
 * Access Level Management API
 *
 * PATCH: Update a user's access_level or is_admin flag.
 * SECURITY: Requires is_admin = true (checked via cse_profiles lookup).
 */

import { validateSession } from '@/lib/session-validator'
import { createSuccessResponse, createErrorResponse } from '@/lib/api-utils'
import { getServiceSupabase } from '@/lib/supabase'

export async function PATCH(request: Request) {
  try {
    const session = await validateSession()
    if (!session?.user?.email) {
      return createErrorResponse('UNAUTHORIZED', 'Authentication required', 401)
    }

    // Verify the requesting user is an admin
    const supabase = getServiceSupabase()
    const { data: requester } = await supabase
      .from('cse_profiles')
      .select('is_admin')
      .eq('email', session.user.email)
      .single()

    if (!requester?.is_admin) {
      return createErrorResponse('FORBIDDEN', 'Admin access required', 403)
    }

    const body = await request.json()
    const { email, access_level, is_admin } = body

    if (!email) {
      return createErrorResponse('VALIDATION', 'Email is required', 400)
    }

    // Build update object with only provided fields
    const updates: Record<string, unknown> = {}
    if (access_level !== undefined) {
      if (!['full', 'limited'].includes(access_level)) {
        return createErrorResponse('VALIDATION', 'access_level must be "full" or "limited"', 400)
      }
      updates.access_level = access_level
    }
    if (is_admin !== undefined) {
      if (typeof is_admin !== 'boolean') {
        return createErrorResponse('VALIDATION', 'is_admin must be a boolean', 400)
      }
      // Prevent removing own admin access
      if (email === session.user.email && !is_admin) {
        return createErrorResponse('VALIDATION', 'Cannot remove your own admin access', 400)
      }
      updates.is_admin = is_admin
    }

    if (Object.keys(updates).length === 0) {
      return createErrorResponse('VALIDATION', 'No fields to update', 400)
    }

    const { data, error } = await supabase
      .from('cse_profiles')
      .update(updates)
      .eq('email', email)
      .select('email, full_name, access_level, is_admin')
      .single()

    if (error) {
      return createErrorResponse('DATABASE', error.message, 500)
    }

    if (!data) {
      return createErrorResponse('NOT_FOUND', 'User not found', 404)
    }

    return createSuccessResponse(data)
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Internal server error'
    return createErrorResponse('INTERNAL', message, 500)
  }
}
```

**Step 2: Verify TypeScript compiles**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty 2>&1 | grep -i "access-level" | head -10`

**Step 3: Commit**

```bash
git add src/app/api/admin/users/access-level/route.ts
git commit -m "feat: add PATCH endpoint for managing user access levels"
```

---

### Task 12: ChaSen AI — Scoped Context

**Files:**
- Modify: `src/app/api/chasen/stream/route.ts:254` (getLiveDashboardContext)
- Modify: `src/app/api/chasen/stream/route.ts:2141` (POST handler)
- Modify: `src/lib/chasen-dynamic-context.ts:617` (getDynamicDashboardContext)

**Step 1: Add accessLevel parameter to getLiveDashboardContext**

At line ~254, change the function signature:

```typescript
async function getLiveDashboardContext(
  clientName?: string,
  accessLevel: 'full' | 'limited' = 'full'
): Promise<string> {
```

**Step 2: Add early return guard for limited users**

After the `const parts: string[] = []` line (~256), add:

```typescript
  // Limited access users only get goals, meetings, and actions context
  if (accessLevel === 'limited') {
    try {
      // Goals data
      const { data: goals } = await supabase
        .from('apac_planning_goals')
        .select('title, status, goal_type, owner_name, due_date, updated_at')
        .order('updated_at', { ascending: false })
        .limit(30)

      if (goals?.length) {
        parts.push('## Goals & Projects')
        for (const g of goals) {
          parts.push(`- **${g.title}** (${g.goal_type}): ${g.status} — Owner: ${g.owner_name || 'Unassigned'}`)
        }
      }

      // Actions data
      const { data: actions } = await supabase
        .from('actions')
        .select('Action_ID, Subject, Status, Due_Date, Assigned_To, Priority')
        .order('Due_Date', { ascending: true })
        .limit(30)

      if (actions?.length) {
        parts.push('\n## Actions & Tasks')
        for (const a of actions) {
          parts.push(`- [${a.Action_ID}] **${a.Subject}**: ${a.Status} — Due: ${a.Due_Date || 'No date'}, Assigned: ${a.Assigned_To || 'Unassigned'}`)
        }
      }

      // Recent meetings
      const { data: meetings } = await supabase
        .from('unified_meetings')
        .select('subject, client_name, start_time, status')
        .order('start_time', { ascending: false })
        .limit(20)

      if (meetings?.length) {
        parts.push('\n## Recent Meetings')
        for (const m of meetings) {
          parts.push(`- **${m.subject}** (${m.client_name || 'No client'}): ${m.status} — ${m.start_time}`)
        }
      }

      return parts.join('\n')
    } catch (error) {
      console.warn('[ChaSen] Limited context fetch failed:', error)
      return ''
    }
  }
```

**Step 3: Update getDynamicDashboardContext to accept accessLevel**

At `src/lib/chasen-dynamic-context.ts:617`, update the signature:

```typescript
export async function getDynamicDashboardContext(
  clientName?: string,
  excludeTables: string[] = [],
  accessLevel: 'full' | 'limited' = 'full'
): Promise<string> {
```

Add after the existing `excludeTables` filtering:

```typescript
  // Limited access: only allow client-category sources related to goals/meetings/actions
  if (accessLevel === 'limited') {
    configs = configs.filter(c =>
      c.category === 'client' &&
      ['apac_planning_goals', 'portfolio_initiatives', 'actions', 'unified_meetings', 'comments', 'action_activity_log']
        .includes(c.table_name)
    )
  }
```

**Step 4: Update the POST handler to pass accessLevel**

In the POST handler (~line 2141), read the access level from the session. Find where `getLiveDashboardContext` is called (~line 2353) and pass it:

```typescript
    // Determine access level (from session or default to full)
    const accessLevel = ((session as any)?.accessLevel || 'full') as 'full' | 'limited'
```

Update the call at ~line 2353:

```typescript
    getLiveDashboardContext(clientName, accessLevel),
```

Update the getDynamicDashboardContext call at ~line 2373:

```typescript
    getDynamicDashboardContext(clientName, LIVE_CONTEXT_TABLES, accessLevel),
```

**Step 5: Add system prompt scoping**

Find where the system prompt is assembled in the POST handler. Add after the existing system prompt:

```typescript
    // Scope ChaSen's knowledge boundary for limited users
    if (accessLevel === 'limited') {
      systemPrompt += `\n\nIMPORTANT: You only have access to Goals, Meetings, and Actions data. If the user asks about financials, NPS, health scores, pipeline, compliance, BURC, revenue, or other restricted topics, explain that this information is not available in their current access level. Do not speculate or provide information you don't have context for.`
    }
```

**Step 6: Commit**

```bash
git add src/app/api/chasen/stream/route.ts src/lib/chasen-dynamic-context.ts
git commit -m "feat: scope ChaSen AI context for limited access users"
```

---

### Task 13: Update Admin Users API to Return New Fields

**Files:**
- Modify: `src/app/api/admin/users/route.ts:45`

**Step 1: Ensure the GET query returns access_level and is_admin**

The existing query at line ~45 uses `.select('*')` which will automatically include the new columns. Verify the `UserProfile` interface at line ~12 includes them:

```typescript
interface UserProfile {
  // ... existing fields ...
  access_level: 'full' | 'limited'
  is_admin: boolean
}
```

**Step 2: Commit**

```bash
git add src/app/api/admin/users/route.ts
git commit -m "feat: include access_level and is_admin in admin users API response"
```

---

### Task 14: Integration Verification

**Step 1: Run TypeScript check**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx tsc --noEmit --pretty`
Expected: No errors

**Step 2: Run existing tests**

Run: `cd ~/GitHub/apac-intelligence-v2 && npm test -- --passWithNoTests 2>&1 | tail -20`
Expected: All existing tests pass (or only pre-existing failures)

**Step 3: Manual verification checklist**

Start dev server: `cd ~/GitHub/apac-intelligence-v2 && npm run dev`

Test as full-access user (Jimmy):
- [ ] Dashboard (/) loads normally
- [ ] All sidebar groups visible + Admin group visible
- [ ] Settings page shows Administration section
- [ ] /admin/users shows Access Level and Admin columns
- [ ] Can toggle another user's access level

Test as limited user (change a test user to `limited` via admin UI):
- [ ] Navigating to / redirects to /goals-initiatives
- [ ] Sidebar shows only Goals & Projects, Meetings, Actions
- [ ] Settings shows only ChaSen section
- [ ] ChaSen AI only returns goals/meetings/actions context
- [ ] Direct URL to /client-profiles redirects to /goals-initiatives

**Step 4: Final commit (if any fixes needed)**

```bash
git add -A
git commit -m "fix: integration fixes for limited access feature"
```
