# Bug Report: Stream Responses Force Scroll to Bottom

**Date:** 2024-12-24
**Status:** Fixed
**Commits:** 8c60dc5

## Problem

During streaming responses in ChaSen AI, the UI automatically scrolled to the bottom of the chat with every new chunk of content. This forced users who wanted to read from the beginning of a long response to constantly scroll back up, creating a frustrating UX.

## Root Cause

The `useEffect` hook that handled scrolling was triggered on every `chatHistory` change without checking if the user had intentionally scrolled up:

```typescript
useEffect(() => {
  messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
}, [chatHistory])
```

## Solution

Implemented smart scroll behaviour that respects user scroll position:

### 1. Scroll Position Tracking

Added refs and state to track scroll position:

```typescript
const messagesContainerRef = useRef<HTMLDivElement>(null)
const [shouldAutoScroll, setShouldAutoScroll] = useState(true)
const [showScrollButton, setShowScrollButton] = useState(false)
```

### 2. Bottom Detection

Added function to check if user is near the bottom:

```typescript
const checkIfAtBottom = useCallback(() => {
  const container = messagesContainerRef.current
  if (!container) return true

  // Consider "at bottom" if within 100px of the bottom
  const threshold = 100
  const distanceFromBottom = container.scrollHeight - container.scrollTop - container.clientHeight
  return distanceFromBottom <= threshold
}, [])
```

### 3. Scroll Event Handler

Track when user scrolls up and update state:

```typescript
const handleScroll = useCallback(() => {
  const isAtBottom = checkIfAtBottom()
  setShouldAutoScroll(isAtBottom)

  if (!isAtBottom && chatHistory.length > 0) {
    setShowScrollButton(true)
  } else {
    setShowScrollButton(false)
  }
}, [checkIfAtBottom, chatHistory.length])
```

### 4. Smart Auto-Scroll

Only auto-scroll if user is already at the bottom:

```typescript
useEffect(() => {
  if (shouldAutoScroll) {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  } else if (isStreaming || isLoading) {
    setShowScrollButton(true)
  }
}, [chatHistory, shouldAutoScroll, isStreaming, isLoading])
```

### 5. Floating "New Content" Button

Added a floating button that appears when user has scrolled up and new content arrives:

```tsx
{
  showScrollButton && (
    <button
      onClick={scrollToBottom}
      className="absolute bottom-24 left-1/2 transform -translate-x-1/2 bg-purple-600 text-white px-4 py-2 rounded-full shadow-lg flex items-center space-x-2 hover:bg-purple-700 transition-all z-10 animate-bounce"
    >
      <ChevronDown className="h-4 w-4" />
      <span className="text-sm font-medium">New content below</span>
    </button>
  )
}
```

## Files Modified

- `src/app/(dashboard)/ai/page.tsx`
  - Lines 421-424: Added refs and state variables
  - Lines 871-910: Added scroll logic functions
  - Lines 1920-1925: Added ref and onScroll handler to container
  - Lines 2461-2471: Added floating scroll button

## Testing

1. Start a conversation with a long query (e.g., "Give me a detailed analysis of all clients")
2. While streaming, scroll up to read the beginning of the response
3. Verify the "New content below" button appears
4. Continue scrolling and verify auto-scroll doesn't force you down
5. Click the button to smoothly scroll to the latest content
6. Verify that when you're at the bottom, auto-scroll works normally

## UX Improvement

| Before                                  | After                              |
| --------------------------------------- | ---------------------------------- |
| Users forced to bottom during streaming | Users can read at their own pace   |
| Must constantly scroll up               | Auto-scroll only when at bottom    |
| No indication of new content            | Floating button shows new content  |
| Frustrating experience                  | Smooth, user-controlled experience |
