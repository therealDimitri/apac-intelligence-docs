# Bug Report: Attendee Search Failing in Dev Mode with 401 Errors

**Date**: November 27, 2025
**Severity**: Medium
**Status**: ✅ Resolved
**Environment**: Development Mode

---

## Issue Summary

When opening the Schedule Meeting modal in development mode and attempting to search for organisation users (e.g., searching for "todd"), the attendee search was returning 401 Unauthorized errors. No users were being displayed in the dropdown, making it impossible to add attendees to meetings during local development.

---

## Symptoms

### User Experience

- Opening Schedule Meeting modal showed empty attendee suggestions
- Searching for known users (like "todd") returned no results
- No error messages displayed to the user
- Console showed diagnostic logging but no data

### Console Logs

```
[Attendee Search] Searching Microsoft Graph for: "todd"...
[Attendee Search] Response status: 401 Unauthorized
[Attendee Search] Microsoft Graph returned 0 results for "todd"
[Attendee Search] Failed to fetch people: 401 Unauthorized
```

### Server Logs

```
GET /api/organisation/people?search=todd 401 in 76ms
[auth][error] JWTSessionError: Read more at https://errors.authjs.dev#jwtsessionerror
[auth][cause]: JWEInvalid: Invalid Compact JWE
```

---

## Root Cause Analysis

### Authentication Flow in Development vs Production

The application uses **NextAuth v5** with Azure AD authentication to provide Microsoft Graph API access tokens. The authentication flow works differently in dev vs production:

**Production Flow:**

1. User signs in via Azure AD OAuth
2. NextAuth receives `access_token` and `refresh_token` from Azure
3. Token is stored in encrypted JWE session token
4. `auth()` function decrypts session and provides `accessToken`
5. API routes use `accessToken` to call Microsoft Graph API

**Development Flow (Before Fix):**

1. User clicks dev login button
2. `/api/auth/dev-login` creates a simple JWT token with `jwt.sign()`
3. NextAuth tries to decrypt the token as JWE → **fails**
4. `auth()` returns `null` session
5. API route checks `if (!session)` → returns **401**
6. Microsoft Graph API is never called

### The Core Problem

The dev login endpoint was creating tokens using `jsonwebtoken`'s `jwt.sign()` method:

```typescript
// dev-login/route.ts (attempted fix - didn't work)
const token = jwt.sign(
  {
    user: { email, name, id },
    accessToken: 'dev-mock-access-token', // ❌ This never made it through
    exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24,
  },
  process.env.NEXTAUTH_SECRET || 'dev-secret'
)
```

However, **NextAuth v5 uses JWE (JSON Web Encryption)**, not plain JWT signing. When the API route called `auth()`, it couldn't decrypt the manually-signed token, resulting in `null` session and immediate 401 response.

---

## Failed Solutions

### Attempt 1: Add accessToken to JWT in dev-login

**Approach**: Modified `/api/auth/dev-login/route.ts` to include `accessToken: 'dev-mock-access-token'` in the JWT payload

**Why it failed**: NextAuth v5 uses JWE encryption. The `auth()` function couldn't decrypt the manually-signed JWT, returned `null`, and the API route hit the `if (!session)` check before any mock token logic could execute.

### Attempt 2: Add fallback mock token after session check

**Approach**: Modified the API route to check `if (!accessToken && NODE_ENV === 'development')` and provide a mock token

**Why it failed**: Same root cause - since the session was `null`, the code never reached the access token check. The 401 was returned earlier in the flow.

---

## Final Solution

### Strategy: Bypass Authentication in Development Mode

Instead of trying to fix the session/token creation, bypass the entire authentication flow when in development mode by checking `NODE_ENV` **before** calling `auth()`.

### Implementation

#### File 1: `/src/app/api/organisation/people/route.ts`

Added development mode check at the **start** of the GET handler:

```typescript
export async function GET(request: NextRequest) {
  try {
    // Development mode: Allow unauthenticated access with mock token
    if (process.env.NODE_ENV === 'development') {
      console.log('[API /organisation/people] Dev mode: Using mock access token')

      // Get query parameters
      const searchParams = request.nextUrl.searchParams
      const searchQuery = searchParams.get('search')
      const limit = searchParams.get('limit')

      let users

      if (searchQuery) {
        // Search for specific users
        const maxResults = limit ? parseInt(limit) : 20
        users = await searchOrganizationUsers('dev-mock-access-token', searchQuery, maxResults)
      } else {
        // Get frequently contacted people
        const maxResults = limit ? parseInt(limit) : 50
        users = await fetchOrganizationPeople('dev-mock-access-token', maxResults)
      }

      return NextResponse.json({ users })
    }

    // Production mode: Require authentication
    const session = await auth()

    if (!session) {
      return NextResponse.json(
        { error: 'Unauthorized. Please sign in.' },
        { status: 401 }
      )
    }

    // ... rest of production logic
  }
}
```

**Key change**: The `process.env.NODE_ENV === 'development'` check happens **before** calling `auth()`, completely bypassing the authentication flow in dev mode.

#### File 2: `/src/lib/microsoft-graph.ts`

Added mock data functions that detect the `dev-mock-access-token` and return fake users:

```typescript
// In fetchOrganizationPeople function:
export async function fetchOrganizationPeople(
  accessToken: string,
  maxResults: number = 50
): Promise<GraphUser[]> {
  if (!accessToken) {
    throw new Error('Access token is required to fetch organisation people')
  }

  // Development mode: Return mock data
  if (accessToken === 'dev-mock-access-token') {
    return getMockOrganizationPeople(maxResults)
  }

  // Production: Call real Microsoft Graph API
  const response = await fetch(
    `https://graph.microsoft.com/v1.0/me/people?$top=${maxResults}&$select=id,displayName,scoredEmailAddresses,jobTitle,department,officeLocation`,
    {
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
    }
  )
  // ... rest of implementation
}

// In searchOrganizationUsers function:
export async function searchOrganizationUsers(
  accessToken: string,
  searchQuery: string,
  maxResults: number = 20
): Promise<GraphUser[]> {
  if (!accessToken) {
    throw new Error('Access token is required to search users')
  }

  if (!searchQuery || searchQuery.trim().length < 2) {
    return []
  }

  // Development mode: Return filtered mock data
  if (accessToken === 'dev-mock-access-token') {
    return searchMockOrganizationPeople(searchQuery, maxResults)
  }

  // Production: Call real Microsoft Graph API
  const response = await fetch(
    `https://graph.microsoft.com/v1.0/users?$search="displayName:${encodeURIComponent(searchQuery)}" OR "mail:${encodeURIComponent(searchQuery)}"&$top=${maxResults}&$select=id,displayName,mail,userPrincipalName,jobTitle,department,officeLocation`,
    {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        ConsistencyLevel: 'eventual',
        'Content-Type': 'application/json',
      },
    }
  )
  // ... rest of implementation
}

// Mock data functions
function getMockOrganizationPeople(maxResults: number = 50): GraphUser[] {
  const mockUsers: GraphUser[] = [
    {
      id: 'mock-1',
      displayName: 'Todd Williams',
      mail: 'todd.williams@alterahealth.com',
      userPrincipalName: 'todd.williams@alterahealth.com',
      jobTitle: 'Senior Client Success Executive',
      department: 'Client Success',
      officeLocation: 'Sydney',
    },
    {
      id: 'mock-2',
      displayName: 'Laura Messing',
      mail: 'laura.messing@alterahealth.com',
      userPrincipalName: 'laura.messing@alterahealth.com',
      jobTitle: 'Client Success Manager',
      department: 'Client Success',
      officeLocation: 'Melbourne',
    },
    {
      id: 'mock-3',
      displayName: 'Tracey Bland',
      mail: 'tracey.bland@alterahealth.com',
      userPrincipalName: 'tracey.bland@alterahealth.com',
      jobTitle: 'VP Client Success',
      department: 'Client Success',
      officeLocation: 'Melbourne',
    },
    {
      id: 'mock-4',
      displayName: 'Gilbert So',
      mail: 'gilbert.so@alterahealth.com',
      userPrincipalName: 'gilbert.so@alterahealth.com',
      jobTitle: 'Client Success Executive',
      department: 'Client Success',
      officeLocation: 'Melbourne',
    },
    {
      id: 'mock-5',
      displayName: 'Jonathan Salisbury',
      mail: 'jonathan.salisbury@alterahealth.com',
      userPrincipalName: 'jonathan.salisbury@alterahealth.com',
      jobTitle: 'Senior Client Success Manager',
      department: 'Client Success',
      officeLocation: 'Sydney',
    },
    {
      id: 'mock-6',
      displayName: 'Nikki Wei',
      mail: 'nikki.wei@alterahealth.com',
      userPrincipalName: 'nikki.wei@alterahealth.com',
      jobTitle: 'Client Success Manager',
      department: 'Client Success',
      officeLocation: 'Melbourne',
    },
    {
      id: 'mock-7',
      displayName: 'BoonTeck Lim',
      mail: 'boonteck.lim@alterahealth.com',
      userPrincipalName: 'boonteck.lim@alterahealth.com',
      jobTitle: 'Senior Solutions Architect',
      department: 'Engineering',
      officeLocation: 'Singapore',
    },
    {
      id: 'mock-8',
      displayName: 'Dimitri Leimonitis',
      mail: 'dimitri.leimonitis@alterahealth.com',
      userPrincipalName: 'dimitri.leimonitis@alterahealth.com',
      jobTitle: 'CEO',
      department: 'Executive',
      officeLocation: 'Melbourne',
    },
  ]

  return mockUsers.slice(0, maxResults)
}

function searchMockOrganizationPeople(query: string, maxResults: number = 20): GraphUser[] {
  const allMockUsers = getMockOrganizationPeople(50)
  const lowerQuery = query.toLowerCase()

  const filtered = allMockUsers.filter(
    user =>
      user.displayName.toLowerCase().includes(lowerQuery) ||
      user.mail.toLowerCase().includes(lowerQuery) ||
      (user.jobTitle?.toLowerCase() || '').includes(lowerQuery) ||
      (user.department?.toLowerCase() || '').includes(lowerQuery)
  )

  return filtered.slice(0, maxResults)
}
```

---

## Testing & Verification

### Test Steps

1. Started dev server: `npm run dev`
2. Navigated to http://localhost:3001
3. Clicked "Schedule Meeting" button
4. Observed attendee dropdown populated with 8 mock users
5. Typed "todd" in search box
6. Verified that only "Todd Williams" appeared in filtered results

### Success Criteria ✅

- Server logs showed: `[API /organisation/people] Dev mode: Using mock access token`
- Console logs showed: `[Attendee Search] Microsoft Graph returned 1 results for "todd"`
- Dropdown displayed Todd Williams with full details:
  - Name: Todd Williams
  - Email: todd.williams@alterahealth.com
  - Job Title: Senior Client Success Executive
  - Department: Client Success

### Screenshot Evidence

![Attendee search working with "todd" query showing Todd Williams in results]

---

## Impact Assessment

### Before Fix

- ❌ Attendee search completely broken in dev mode
- ❌ Developers unable to test meeting scheduling features
- ❌ Required production deployment to test attendee functionality
- ❌ Console filled with 401 errors and JWE decryption errors

### After Fix

- ✅ Attendee search fully functional in dev mode
- ✅ 8 realistic mock users available for testing
- ✅ Search filtering works correctly (e.g., searching "todd" returns only Todd Williams)
- ✅ No authentication errors in dev mode
- ✅ Production authentication flow remains unchanged

---

## Related Files

### Modified Files

- `/src/app/api/organisation/people/route.ts` (lines 14-37)
- `/src/lib/microsoft-graph.ts` (added mock data functions)

### Reference Files

- `/src/components/AttendeeSelector.tsx` (contains diagnostic logging added in commit 9370227)
- `/src/app/api/auth/dev-login/route.ts` (attempted fix location)
- `/src/auth.ts` (NextAuth v5 configuration)

---

## Lessons Learned

### NextAuth v5 Session Management

- NextAuth v5 uses **JWE (JSON Web Encryption)** for session tokens, not plain JWT
- Manually creating tokens with `jwt.sign()` won't work with NextAuth's `auth()` function
- Dev mode authentication requires either:
  - Full JWE token creation (complex)
  - **Bypass authentication checks entirely** (simpler, used here)

### Development Mode Patterns

- When real authentication isn't available in dev mode, bypass auth checks at the **earliest point**
- Mock data should be realistic and match production data structure
- Mock functions should be clearly labeled and only trigger on specific conditions (e.g., `accessToken === 'dev-mock-access-token'`)

### API Route Architecture

- Check for dev mode **before** calling any authentication functions
- Dev mode checks should return early to avoid unnecessary auth logic
- Mock responses should match exact production response structure

---

## Security Considerations

### Production Safety

- ✅ Dev mode bypass only activates when `NODE_ENV === 'development'`
- ✅ Production deployments use real Azure AD authentication
- ✅ No security implications for production environment
- ✅ Mock token string is clearly identifiable and won't match real tokens

### Development Environment

- ⚠️ Dev mode completely bypasses authentication (expected behavior)
- ⚠️ Mock data is hardcoded (acceptable for development)
- ℹ️ Developers should be aware that dev mode auth doesn't reflect production behavior

---

## Deployment Notes

### No Production Changes Required

This fix is development-mode only. The production authentication flow remains unchanged:

- Azure AD OAuth still required in production
- Real Microsoft Graph access tokens still used in production
- No environment variable changes needed
- No Azure AD configuration changes needed

### What Gets Deployed

- Modified `/src/app/api/organisation/people/route.ts` (contains dev mode check)
- Modified `/src/lib/microsoft-graph.ts` (contains mock data functions)

Both modifications are safe for production because:

1. Dev mode checks only activate when `NODE_ENV === 'development'`
2. Mock data functions only trigger when `accessToken === 'dev-mock-access-token'`
3. Production environment will never set `NODE_ENV` to `'development'`

---

## Future Improvements

### Mock Data Management

- Consider moving mock users to a separate config file (e.g., `/src/lib/mock-data.ts`)
- Add more diverse mock users for testing edge cases
- Consider adding environment variable to control mock data set

### Dev Mode Authentication

- Explore NextAuth v5 documentation for proper dev mode session creation
- Consider implementing a custom session encryption/decryption for dev mode
- Investigate if NextAuth provides built-in dev mode helpers

### Testing

- Add integration tests that verify dev mode authentication bypass
- Add unit tests for mock data search/filter functions
- Consider adding E2E tests for attendee search in both dev and production modes

---

## References

- Previous debugging commit: `9370227` - "debug: add comprehensive logging for attendee search diagnostics"
- NextAuth v5 documentation: https://authjs.dev/
- Microsoft Graph API documentation: https://learn.microsoft.com/en-us/graph/api/overview
- JWE specification: https://tools.ietf.org/html/rfc7516

---

## Git Commit

```bash
git add src/app/api/organisation/people/route.ts src/lib/microsoft-graph.ts
git commit -m "fix: attendee search 401 errors in dev mode

## Issue
Attendee search was failing in development mode with 401 Unauthorized errors
because dev mode authentication doesn't provide real Microsoft Graph access tokens.

## Root Cause
- Dev login creates simple JWT tokens with jwt.sign()
- NextAuth v5 uses JWE (JSON Web Encryption), not plain JWT
- auth() function couldn't decrypt manually-signed tokens
- API route returned 401 before any mock token logic could execute

## Solution
1. Modified /api/organisation/people/route.ts to check for dev mode FIRST,
   before calling auth() function
2. Added mock data functions to microsoft-graph.ts that detect
   'dev-mock-access-token' and return realistic test data
3. Created 8 mock users including Todd Williams, Laura Messing, etc.

## Testing
- Opened Schedule Meeting modal in dev mode
- Searched for 'todd' and got filtered result showing only Todd Williams
- Console logs confirmed: 'Microsoft Graph returned 1 results for todd'
- Server logs confirmed: 'Dev mode: Using mock access token'

## Files Changed
- src/app/api/organisation/people/route.ts: Added dev mode bypass
- src/lib/microsoft-graph.ts: Added mock data functions

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

**Resolution Date**: November 27, 2025
**Resolved By**: Claude Code
**Verification Status**: ✅ Tested and confirmed working
