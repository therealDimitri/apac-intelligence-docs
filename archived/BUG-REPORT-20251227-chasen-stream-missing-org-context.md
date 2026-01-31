# Bug Report: ChaSen Stream Endpoint Missing Org Context

**Date:** 27 December 2025
**Severity:** Medium
**Status:** Fixed
**Commit:** TBD

## Summary

ChaSen's Quick mode (stream endpoint) was not recognising Client Account Managers (CAMs) as direct reports, only showing Client Success Executives (CSEs).

## Root Cause

The `/api/chasen/stream/route.ts` endpoint did not query `cse_profiles` for organisational structure data. While the chat endpoint (`/api/chasen/chat/route.ts`) had org context including `reports_to` relationships, the stream endpoint was only using client assignments from the dashboard context.

This meant:
- The LLM only saw CSE-to-client assignments
- It had no access to the actual org hierarchy (`reports_to` field)
- CAMs were not visible as direct reports

## Symptoms

When asking "Who reports to me?" in Quick mode:
- Only 5 CSEs were listed
- CAMs (Nikki Wei, Anupama Pradhan) were missing or mislabelled
- Response said "your direct reports are the Client Success Executives"

## Fix Applied

Added org context fetching to the stream endpoint:

### 1. Query cse_profiles for org structure

```typescript
// Fetch org structure context for direct reports and manager info
let orgContext = ''
if (effectiveUserEmail) {
  try {
    const supabase = getServiceSupabase()
    const { data: cseProfiles } = await supabase
      .from('cse_profiles')
      .select('id, full_name, first_name, email, role, reports_to, job_description')
      .eq('active', true)
    // ... build org context
  } catch (err) {
    console.warn('[ChaSen Stream] Org context fetch failed:', err)
  }
}
```

### 2. Build org context with direct reports and manager

```typescript
if (cseProfiles && cseProfiles.length > 0) {
  const userProfile = cseProfiles.find(cse => cse.email === effectiveUserEmail)
  const directReports = cseProfiles.filter(cse => cse.reports_to === effectiveUserEmail)
  const manager = userProfile?.reports_to
    ? cseProfiles.find(cse => cse.email === userProfile.reports_to)
    : null
  // ... format context
}
```

### 3. Add org context to system prompt

```typescript
${
  orgContext
    ? `
## ORGANISATIONAL CONTEXT
${orgContext}
`
    : ''
}
```

## Files Modified

| File | Changes |
|------|---------|
| `src/app/api/chasen/stream/route.ts` | Added cse_profiles query and org context section to system prompt |

## Verification

After the fix, the stream endpoint correctly:
1. Fetches cse_profiles with `reports_to` field
2. Identifies all 7 direct reports (5 CSEs + 2 CAMs)
3. Includes their correct role titles in the context
4. Passes org context to the LLM

Server log confirmation:
```
[ChaSen Stream] Org context loaded: 7 direct reports
```

Response now includes:
- Gilbert So: Client Success Executive
- Tracey Bland: Client Success Executive
- Laura Messing: Client Success Executive
- John Salisbury: Client Success Executive
- BoonTeck Lim: Client Success Executive
- Anupama Pradhan: Client Account Manager
- Nikki Wei: Client Account Manager

## Testing

1. Navigate to `/ai` (ChaSen AI page)
2. Ensure Quick mode is selected
3. Ask "Who reports to me?"
4. Verify all 7 direct reports are listed with correct roles

## Related

- [Org-Aware ChaSen Feature](./FEATURE-20251227-org-aware-chasen.md)
- [Job Descriptions Feature](./FEATURE-20251227-job-descriptions.md)
- [Stream Role Mapping Bug](./BUG-REPORT-20251227-chasen-stream-role-mapping.md)
