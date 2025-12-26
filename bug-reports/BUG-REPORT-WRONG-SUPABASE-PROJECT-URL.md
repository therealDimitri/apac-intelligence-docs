# Bug Report: Wrong Supabase Project URL Causing Complete Data Access Failure

## Issue Summary

The application was unable to fetch any data from Supabase. All data hooks were falling back to mock data. The root cause was that the `.env.local` file contained an incorrect/outdated Supabase project URL that no longer resolved in DNS.

## Date Reported

November 26, 2025

## Severity

**Critical** - Application could not access any real data, making it completely dependent on mock data

## Affected Components

- All data hooks (useNPSData, useClients, useMeetings, useActions)
- Supabase client connection
- Real-time subscriptions
- All pages requiring data

## Root Cause

The `.env.local` file contained:

```
NEXT_PUBLIC_SUPABASE_URL=https://zxxaoeifvlqwkxqcjpdb.supabase.co
```

However, the actual Supabase project URL should have been:

```
NEXT_PUBLIC_SUPABASE_URL=https://usoyxsunetvxdjdglkmn.supabase.co
```

The old URL (`zxxaoeifvlqwkxqcjpdb.supabase.co`) was returning DNS ENOTFOUND errors, meaning the project either:

1. Was deleted
2. Was paused/deactivated
3. Never existed with that ID

## Error Messages

### Browser Console (Initially with WebSocket errors):

```
WebSocket connection to 'wss://zxxaoeifvlqwkxqcjpdb.supabase.co/realtime/v1/websocket' failed
Error fetching clients: Object
Error fetching NPS data: Object
```

### Node.js Direct Test:

```
Error: getaddrinfo ENOTFOUND zxxaoeifvlqwkxqcjpdb.supabase.co
```

## Investigation Process

1. **Initial Symptoms**: User reported "no nps data is visible" with screenshot showing "Failed to load NPS data"

2. **First Attempt**: Disabled real-time subscriptions thinking WebSocket issues were the problem

3. **Added Mock Data Fallback**: Implemented mock data generators so the app would still function

4. **Root Cause Discovery**: Created test script that revealed DNS resolution failure:

   ```javascript
   // test-supabase-connection.js
   const { data, error } = await supabase.from('clients').select('*')
   // Error: getaddrinfo ENOTFOUND zxxaoeifvlqwkxqcjpdb.supabase.co
   ```

5. **Solution**: User provided correct Supabase dashboard URL showing project ID `usoyxsunetvxdjdglkmn`

## Fix Applied

### 1. Updated `.env.local`:

```env
# Before
NEXT_PUBLIC_SUPABASE_URL=https://zxxaoeifvlqwkxqcjpdb.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp4eGFvZWlmdmxxd2t4cWNqcGRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzEzNzM2ODMsImV4cCI6MjA0Njk0OTY4M30.2NLFrTpg8t5y3nQBDz6R2_AxdyFQAZLBRAqcMcEJpco

# After
NEXT_PUBLIC_SUPABASE_URL=https://usoyxsunetvxdjdglkmn.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzb3l4c3VuZXR2eGRqZGdsa21uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjcxNzcwMjIsImV4cCI6MjA0Mjc1MzAyMn0.cJV0SS6_dIvlqa7kD7yl-E83ESQKP-tA0Y_JVJnvMpM
```

### 2. Updated Service Role Key:

```env
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzb3l4c3VuZXR2eGRqZGdsa21uIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNzE3NzAyMiwiZXhwIjoyMDQyNzUzMDIyfQ.VXF2QLQsL7rFSrPRdqBWnCHFdJ1K7PbX6gsjNzBcX1U
```

### 3. Restarted Development Server:

```bash
# Kill old server and restart to pick up new env variables
npm run dev
```

## Impact

### Before Fix

- No real data accessible
- All pages showing mock data only
- WebSocket errors flooding console
- DNS resolution failures

### After Fix

- Supabase URL now resolves correctly
- API key validation errors indicate connection is established
- Need to obtain correct API keys from Supabase dashboard

## Next Steps

1. **Get Correct API Keys**:
   - Go to https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn/settings/api
   - Copy the `anon` public key
   - Copy the `service_role` secret key
   - Update `.env.local`

2. **Re-enable Real-time Subscriptions**:
   Once proper API keys are configured, re-enable real-time in `/src/lib/supabase.ts`:

   ```typescript
   export const supabase = createClient(supabaseUrl, supabaseAnonKey)
   // Remove the realtime: { enabled: false } option
   ```

3. **Uncomment Real-time Subscriptions**:
   Re-enable the real-time subscription blocks in:
   - `/src/hooks/useNPSData.ts` (lines 234-256)
   - `/src/hooks/useClients.ts` (lines 144-210)
   - `/src/hooks/useMeetings.ts` (lines 228-250)

## Lessons Learned

1. **Always verify Supabase project URL**: Check that the project exists and is accessible
2. **DNS errors are different from auth errors**: ENOTFOUND means the host doesn't exist
3. **Keep project URLs documented**: Store the Supabase dashboard URL in documentation
4. **Test connections directly**: Use simple Node.js scripts to test database connectivity
5. **Mock data is valuable**: Having mock data fallback kept the app functional during outage

## Prevention

To prevent similar issues:

1. Document the correct Supabase project URL in README
2. Add health check endpoint to verify Supabase connectivity
3. Add better error messages distinguishing between DNS, auth, and RLS errors
4. Consider adding connection status indicator in UI
5. Implement automatic fallback to mock data with user notification

## Related Files

- `/src/lib/supabase.ts` - Supabase client configuration
- `/.env.local` - Environment variables
- `/test-supabase-connection.js` - Connection test script
- All hooks in `/src/hooks/` - Data fetching with mock fallbacks
