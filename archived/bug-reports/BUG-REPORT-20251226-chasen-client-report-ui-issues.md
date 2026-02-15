# Bug Report: ChaSen Client Report Crew UI Issues

**Date**: 26 December 2025
**Severity**: Medium
**Status**: Fixed
**Related**: BUG-REPORT-20251226-chasen-meeting-prep-data-not-found.md

---

## Summary

Multiple UI/UX issues in the ChaSen AI crews affecting user experience:

1. **Client logo not displayed** - Key Insights card showed generic person icon instead of client logo
2. **Missing Quick Action links** - Client Report missing "View Meetings", Meeting Prep missing "View NPS"
3. **Incorrect scroll behaviour** - Follow-up questions scrolled to top of page instead of user message

## Issues & Fixes

### 1. Client Logo Not Displayed

**Location**: `src/app/(dashboard)/ai/page.tsx` (lines 2212-2216)

**Problem**: The `clientContext` card used a generic `<User />` icon instead of the client's actual logo.

**Fix**: Imported and used `ClientLogoDisplay` component with new 'xs' size (40px).

```tsx
// Before
<div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
  <User className="h-5 w-5 text-gray-600" />
</div>

// After
<ClientLogoDisplay
  clientName={chat.clientContext.name}
  size="xs"
  className="rounded-full"
/>
```

### 2. Missing Quick Action Links

**Location**: `src/app/api/chasen/crew/route.ts`

**Problem**:

- Client Report crew was missing "View Meetings" link
- Meeting Prep crew was missing "View NPS" link

**Fix**: Added missing links for consistency across all crews:

```typescript
// Client Report Quick Actions now includes:
{ label: 'View Meetings', type: 'view-meetings', url: getMeetingsUrl(clientName) }

// Meeting Prep Quick Actions now includes:
{ label: 'View NPS', type: 'view-nps', url: getNPSUrl(clientName) }
```

### 3. Incorrect Scroll Behaviour (Race Condition)

**Location**: `src/app/(dashboard)/ai/page.tsx` (lines 781-800)

**Problem**: When clicking a follow-up question, the page would "bounce back" to the top:

1. User message was added to chatHistory
2. `chatHistory.length` changed, triggering the useEffect
3. But React hadn't re-rendered yet, so `latestResponseRef.current` still pointed to the OLD assistant message
4. Scroll happened using the stale ref, scrolling back to the previous response
5. THEN React re-rendered and updated the ref (too late)

This was a classic **race condition** between the useEffect and React's render cycle.

**Fix**: Always scroll to `messagesEndRef` (end of chat) for ALL new messages. This avoids the race condition entirely since `messagesEndRef` is a static element at the bottom.

```typescript
// Before: Tried to scroll to latestResponseRef which was stale
if (latestMessage?.type === 'assistant' && latestResponseRef.current) {
  latestResponseRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

// After: Always scroll to end - no race condition
messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
```

## Files Changed

| File                                   | Change                                                                 |
| -------------------------------------- | ---------------------------------------------------------------------- |
| `src/components/ClientLogoDisplay.tsx` | Added 'xs' size option (40px)                                          |
| `src/app/(dashboard)/ai/page.tsx`      | Import ClientLogoDisplay, use in client context card, fix scroll logic |
| `src/app/api/chasen/crew/route.ts`     | Add missing Quick Action links                                         |

## Testing

1. Open ChaSen AI (`Cmd+K` or navigate to `/ai`)
2. Select any crew (e.g., "Client Report")
3. Enter a client name (e.g., "GHA")
4. Verify:
   - [ ] Client logo displays in Key Insights card (not generic icon)
   - [ ] All Quick Actions are present (View Profile, Schedule Meeting, Create Action, View Meetings, View Actions, View NPS)
   - [ ] Clicking a follow-up question scrolls to show your message + loading indicator
   - [ ] When response arrives, page scrolls to start of assistant response

## Prevention

This reinforces the importance of:

1. Using existing components (`ClientLogoDisplay`) instead of inline fallbacks
2. Ensuring consistent Quick Actions across all crew types
3. Testing user flows end-to-end (not just data retrieval)
4. Considering scroll behaviour from the user's perspective
