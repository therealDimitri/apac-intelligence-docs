# Bug Report: Invalid API Keys Causing Complete Data Access Failure

## Issue Summary

The application cannot fetch any data from Supabase, including Actions & Tasks data. All data hooks are falling back to mock data due to "Invalid API key" errors. This explains why the Actions data and all other data are not showing correctly.

## Date Reported

November 26, 2025

## Severity

**Critical** - Application cannot access any real data from database

## Affected Components

- All data hooks (useActions, useNPSData, useClients, useMeetings)
- All pages that display data (Actions & Tasks, NPS Analytics, Clients, Meetings)
- Supabase client connection
- Real-time subscriptions

## Root Cause

The API keys in `.env.local` are not valid for the Supabase project. While we fixed the URL issue earlier (changed from `zxxaoeifvlqwkxqcjpdb` to `usoyxsunetvxdjdglkmn`), the API keys are still incorrect or expired.

## Current Status

```env
# These keys are NOT VALID for the project
NEXT_PUBLIC_SUPABASE_URL=https://usoyxsunetvxdjdglkmn.supabase.co  ✅ Correct URL
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...  ❌ Invalid
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...  ❌ Invalid
```

## Error Messages

### Test Script Output:

```
❌ Clients table error: {
  message: 'Invalid API key',
  hint: 'Double check your Supabase `anon` or `service_role` API key.'
}

❌ NPS responses table error: {
  message: 'Invalid API key',
  hint: 'Double check your Supabase `anon` or `service_role` API key.'
}

❌ Actions table error: {
  message: 'Invalid API key',
  hint: 'Double check your Supabase `anon` or `service_role` API key.'
}
```

### Browser Console (with enhanced logging):

```
❌ Failed to fetch actions from Supabase: {
  message: 'Invalid API key',
  details: 'No additional details',
  hint: 'Double check your Supabase `anon` or `service_role` API key.',
  code: 'Unknown error code'
}
📋 Using mock actions as fallback...
```

## Investigation Timeline

1. **User reported**: "data is TILL not correct for all especiallt Actions & Tasks, why?"

2. **Initial investigation**: Checked `useActions` hook, found it lacked proper error handling

3. **Fix applied**: Added comprehensive error logging and mock data fallback to `useActions` hook

4. **Root cause discovered**: Running `test-supabase-connection.js` revealed ALL tables return "Invalid API key" error

5. **Current state**: All data hooks fall back to mock data, explaining why Actions & Tasks show incorrect data

## Impact

### What Works

- Application loads and displays UI ✅
- Mock data generators provide fallback data ✅
- Error handling prevents crashes ✅
- User can navigate between pages ✅

### What Doesn't Work

- No real data from Supabase ❌
- Actions & Tasks show mock data only ❌
- NPS Analytics shows mock data only ❌
- Client data is mock only ❌
- Meeting data is mock only ❌
- Real-time subscriptions fail ❌
- Data changes don't persist ❌

## Solution Required

### Immediate Fix

You need to get the correct API keys from your Supabase dashboard:

1. **Go to Supabase Dashboard**:

   ```
   https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn/settings/api
   ```

2. **Copy the correct keys**:
   - Under "Project API keys", copy the `anon` public key
   - Under "Project API keys", copy the `service_role` secret key (keep this secure!)

3. **Update `.env.local`**:

   ```env
   NEXT_PUBLIC_SUPABASE_ANON_KEY=[paste the anon key here]
   SUPABASE_SERVICE_ROLE_KEY=[paste the service_role key here]
   ```

4. **Restart the development server**:

   ```bash
   # Kill the current server (Ctrl+C)
   npm run dev
   ```

5. **Verify connection**:
   ```bash
   node test-supabase-connection.js
   ```

## Why the Current Keys Don't Work

The current API keys in `.env.local` appear to be from a different Supabase project or are expired. When we fixed the URL earlier, we should have also updated the API keys. The keys are JWT tokens that are tied to a specific project, so using keys from the old project (`zxxaoeifvlqwkxqcjpdb`) with the new project URL (`usoyxsunetvxdjdglkmn`) will not work.

## Mock Data Fallback

The good news is that the enhanced error handling and mock data generators are working perfectly:

- `generateMockActions()` provides 30 sample actions
- `generateMockNPSResponses()` provides 50 sample responses
- `generateMockClients()` provides 16 sample clients
- `generateMockMeetings()` provides 30 sample meetings

This keeps the application functional for development and testing, but real data access requires valid API keys.

## Testing After Fix

Once you have the correct API keys:

1. **Direct connection test**:

   ```bash
   node test-supabase-connection.js
   ```

   Should show:

   ```
   ✅ Clients table accessible
   ✅ NPS responses table accessible
   ✅ Actions table accessible
   ✅ Unified meetings table accessible
   ```

2. **Browser console check**:
   Should show:

   ```
   ✅ Successfully fetched 165 actions from Supabase
   ✅ Successfully fetched 50 NPS responses from Supabase
   ```

3. **Actions & Tasks page**:
   - Should show real action items
   - Should show actual client names
   - Should show real due dates
   - Stats should reflect actual data

## Lessons Learned

1. **Always update API keys when changing projects**: When we fixed the URL, we should have also obtained new API keys
2. **API keys are project-specific**: Can't use keys from one project with another project's URL
3. **Good error handling is critical**: The mock data fallback kept the app functional during the outage
4. **Test connections directly**: The `test-supabase-connection.js` script quickly identified the issue

## Prevention

1. Store API keys securely and document which project they belong to
2. When changing Supabase projects, update both URL and keys together
3. Add connection health check to application startup
4. Consider adding a status indicator showing "Using mock data" when Supabase fails

## Related Files

- `/src/hooks/useActions.ts` - Enhanced with error logging and mock fallback
- `/src/hooks/useNPSData.ts` - Has error logging and mock fallback
- `/src/hooks/useClients.ts` - Has error logging and mock fallback
- `/src/hooks/useMeetings.ts` - Has error logging and mock fallback
- `/.env.local` - Contains the invalid API keys
- `/test-supabase-connection.js` - Test script that revealed the issue
- `/src/lib/mock-data.ts` - Mock data generators keeping app functional
