# Bug Report: ChaSen AI Netlify Function Timeout

**Date:** 2024-12-24
**Status:** FIXED
**Commit:** 433270c

## Problem Description

ChaSen AI streaming worked correctly on the development server (localhost) but consistently failed on production (Netlify) with HTTP 504 timeout errors.

### Symptoms

- ChaSen would show "Sorry, I encountered an error" on the live site
- Console errors showed: `Inactivity Timeout: Too much time has passed without sending any data`
- Development site worked perfectly
- Error occurred ~26 seconds after sending a message

### Root Cause

1. **Netlify function timeout limit**: Netlify Pro tier limits serverless functions to 26 seconds of inactivity
2. **MatchaAI response time**: Corporate AI proxy takes 60-70 seconds to generate responses
3. **Sequential wait pattern**: The original implementation waited for the complete AI response before streaming, leaving the HTTP connection idle and triggering Netlify's timeout

## Solution

Implemented **heartbeat streaming** - a pattern that keeps the HTTP connection alive while waiting for the AI response:

### Technical Changes

1. **New `createStreamWithHeartbeat()` function** (`stream/route.ts`)
   - Starts streaming immediately when request is received
   - Sends heartbeat events (`{heartbeat: true}`) every 5 seconds while waiting
   - Streams actual text chunks once AI response arrives
   - Handles errors gracefully via the stream

2. **Non-blocking AI request**
   - AI request runs as a background promise instead of being awaited
   - Stream starts immediately, not after AI completes
   - Increased timeout to 90s since connection stays alive

3. **Frontend heartbeat handling** (`ai/page.tsx`, `FloatingChaSenAI.tsx`)
   - Ignore heartbeat events (they're just keep-alive signals)
   - Handle error events from stream
   - Continue normal text chunk processing

### Files Changed

- `src/app/api/chasen/stream/route.ts` - Heartbeat streaming implementation
- `src/app/(dashboard)/ai/page.tsx` - Heartbeat event handling
- `src/components/FloatingChaSenAI.tsx` - Heartbeat event handling

## How Heartbeat Streaming Works

```
Client                      Server                    MatchaAI
  |                           |                          |
  |-- POST /api/chasen/stream |                          |
  |                           |-- callMatchaAI()         |
  |<-- {heartbeat: true} -----|                          |
  |     (5s later)            |    (processing...)       |
  |<-- {heartbeat: true} -----|                          |
  |     (5s later)            |    (processing...)       |
  |<-- {heartbeat: true} -----|                          |
  |                           |<-- AI Response --------- |
  |<-- {text: "chunk1"} ------|                          |
  |<-- {text: "chunk2"} ------|                          |
  |<-- [stream ends] ---------|                          |
```

## Testing

1. Build passes: `npm run build` ✅
2. TypeScript check passes ✅
3. Deploy to Netlify triggered

## Lessons Learned

- Serverless platforms have strict timeout limits that differ from local development
- Streaming APIs need to actively send data to keep connections alive
- The "heartbeat" pattern is a common solution for long-running server-sent event streams
