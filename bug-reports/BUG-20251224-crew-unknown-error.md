# Bug Report: AI Crew Shows "Unknown error" Instead of Actual Error Message

**Date:** 24 December 2025
**Status:** Fixed
**Severity:** Medium
**Component:** ChaSen AI > AI Crews

---

## Problem Description

When running an AI Crew (Client Report or Meeting Prep), if the crew failed, the error message displayed was always "Crew failed: Unknown error" instead of the actual error message from the API.

### User Experience Issue

- User clicks "Client Report Crew" without entering a client name
- API returns a proper error: "clientName is required for client-report crew"
- Frontend displays: "Crew failed: Unknown error"
- User has no idea what went wrong

---

## Root Cause Analysis

### Issue 1: API/Frontend Field Name Mismatch

The API route returns error messages in the `message` field, but the frontend was looking for the `error` field.

**API Response (route.ts:116-121):**

```ts
return NextResponse.json(
  {
    status: 'error',
    message: error instanceof Error ? error.message : 'Crew execution failed',
  },
  { status: 500 }
)
```

**Frontend Handling (page.tsx:593):**

```ts
toast.error('Crew failed: ' + (data.error || 'Unknown error'))
// data.error is undefined, so "Unknown error" is shown
```

### Issue 2: Missing Client-Side Validation

The "Client Report" and "Meeting Prep" crews both require a `clientName` parameter, but the frontend allowed users to run these crews without entering a client name first.

---

## Solution Implemented

### 1. Fixed Error Message Handling

Updated frontend to check both `error` and `message` fields from API response:

```ts
const errorMsg = data.error || data.message || 'Crew failed'
setCrewResult({
  success: false,
  finalOutput: errorMsg,
  totalDuration: 0,
  tasks: [],
})
toast.error('Crew failed: ' + errorMsg)
```

### 2. Added Client Name Validation

Added validation at the start of `runCrew()` to require client name before calling API:

```ts
const runCrew = async (crewType: 'client-report' | 'meeting-prep') => {
  // Validate client name is provided for crews that require it
  if (!selectedCrewClient?.trim()) {
    toast.error('Please enter a client name first')
    return
  }
  // ... rest of function
}
```

---

## Files Changed

| File                              | Changes                                                          |
| --------------------------------- | ---------------------------------------------------------------- |
| `src/app/(dashboard)/ai/page.tsx` | Added client name validation, fixed error message field handling |

---

## Behaviour Summary

| Scenario                     | Before Fix      | After Fix                                                  |
| ---------------------------- | --------------- | ---------------------------------------------------------- |
| No client name entered       | "Unknown error" | "Please enter a client name first" (toast before API call) |
| API returns validation error | "Unknown error" | Shows actual error message                                 |
| API returns execution error  | "Unknown error" | Shows actual error message                                 |

---

## Testing Steps

1. Navigate to ChaSen AI page (`/ai`)
2. Expand "AI Crews" section in sidebar
3. **Without** entering a client name, click "Client Report Crew"
4. Verify toast shows "Please enter a client name first"
5. Enter a client name (e.g., "Test Client")
6. Click "Client Report Crew"
7. If crew fails, verify actual error message is displayed

---

## Related Systems

- Crew API: `/api/chasen/crew` - Returns `message` field for errors
- Multi-Agent System: `src/lib/multi-agent.ts`
- AI Providers: `src/lib/ai-providers.ts`
