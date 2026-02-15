# Feature: Perplexity-Style ChaSen Input Redesign

**Date:** 2024-12-24
**Status:** Implemented
**Commit:** 423e8c6

## Overview

Redesigned the ChaSen AI input to match modern AI interfaces like Perplexity, with a unified container, mode toggles, and professional animations.

## Before vs After

### Before

```
┌─────────────────────────────────────────┐ ┌──────────────┐
│ Ask me anything about your portfolio... │ │ Send Button  │
└─────────────────────────────────────────┘ └──────────────┘
         Separate input                        Separate button
```

### After

```
┌────────────────────────────────────────────────────────────────────────────┐
│  ┌─────┬─────┬─────┐                                    ┌───┬───┬───┬─────┐│
│  │ 🔍 │ 📊 │ 🧭 │  Ask a quick question...             │ 🗑 │ 📎│ 🎤│  ↑  ││
│  │Quick│Deep │Coach│                                    │   │   │   │     ││
│  └─────┴─────┴─────┘                                    └───┴───┴───┴─────┘│
│  ═══════════════════════════════ shimmer ═══════════════════════════════  │
└────────────────────────────────────────────────────────────────────────────┘
```

## Features

### 1. Mode Toggles (Left Side)

| Mode          | Icon        | Description            | System Prompt Addition                            |
| ------------- | ----------- | ---------------------- | ------------------------------------------------- |
| Quick         | `Search`    | Fast, concise answers  | "Provide a concise, direct answer"                |
| Deep Analysis | `BarChart2` | Comprehensive insights | "Provide comprehensive analysis with data points" |
| Coach         | `Compass`   | Strategic guidance     | "Act as a strategic coach with recommendations"   |

### 2. Action Buttons (Right Side)

| Button | Icon        | Action                                                     |
| ------ | ----------- | ---------------------------------------------------------- |
| Clear  | `Trash2`    | Start new conversation (only shows when chat has messages) |
| Attach | `Paperclip` | Upload document (PDF, DOCX, TXT, CSV, XLSX)                |
| Voice  | `Mic`       | Voice input (shows only if speech supported)               |
| Submit | `ArrowUp`   | Send message                                               |

### 3. Animations

**Thinking Indicator (Submit Button):**

- Outer pulsing ring (`animate-ping`)
- Middle pulsing dot (`animate-pulse`)
- Spinning progress ring (`animate-spin`)

**Loading Progress Bar:**

- Shimmer animation across bottom of input container
- Purple gradient (`from-purple-500 via-indigo-500 to-purple-500`)

**CSS Animations Added:**

```css
/* Shimmer loading bar */
@keyframes shimmer { ... }
.animate-shimmer { ... }

/* Thinking dots */
@keyframes thinkingDot { ... }
.thinking-dot-1, .thinking-dot-2, .thinking-dot-3 { ... }

/* Pulse glow effect */
@keyframes pulseGlow { ... }
.animate-pulse-glow { ... }

/* Brain thinking animation */
@keyframes brainThink { ... }
.animate-brain-think { ... }
```

### 4. Contextual Placeholders

| State                   | Placeholder                      |
| ----------------------- | -------------------------------- |
| Empty chat + Quick mode | "Ask a quick question..."        |
| Empty chat + Deep mode  | "Request a detailed analysis..." |
| Empty chat + Coach mode | "Ask for strategic advice..."    |
| Has messages (any mode) | "Ask a follow-up..."             |

### 5. Visual States

**Default:**

- White background, gray-200 border
- Subtle shadow

**Hover:**

- Gray-300 border
- Increased shadow

**Focus:**

- Purple-400 border
- Purple shadow glow

**Loading:**

- Purple-300 border
- Purple shadow
- Shimmer progress bar

**Submit Button States:**

- Empty input: Gray background, disabled
- Has input: Purple gradient, shadow, hover scale effect
- Loading: Purple-100 background with animated indicator

## Implementation Details

### Files Modified

1. **`src/app/(dashboard)/ai/page.tsx`**
   - Added imports: `Search`, `BarChart2`, `Compass`, `Trash2`, `Paperclip`, `Mic`, `MicOff`, `ArrowUp`, `StopCircle`
   - Added `QueryMode` type and `QUERY_MODE_CONFIG` constant
   - Added `queryMode` state
   - Replaced message input JSX with new Perplexity-style component

2. **`src/app/globals.css`**
   - Added shimmer animation
   - Added thinking dot animations
   - Added pulse glow animation
   - Added brain think animation

### Code Structure

```typescript
// Query mode configuration
const QUERY_MODE_CONFIG = {
  quick: {
    label: 'Quick',
    description: 'Fast, concise answers',
    icon: Search,
    placeholder: 'Ask a quick question...',
    systemPromptAddition: '...',
  },
  deep: { ... },
  coach: { ... },
}

// State
const [queryMode, setQueryMode] = useState<QueryMode>('quick')

// JSX structure
<div className="unified-container">
  <div className="mode-toggles">...</div>
  <input className="input-field" />
  <div className="action-buttons">...</div>
  <div className="loading-progress-bar">...</div>
</div>
```

## Design Tokens

```css
/* Container */
border-radius: 1rem (rounded-2xl)
shadow: shadow-sm → shadow-md on hover
border: gray-200 → gray-300 on hover → purple-400 on focus

/* Mode toggle - active */
background: purple-100
color: purple-700

/* Submit button - active */
background: gradient from-purple-600 to-indigo-600
shadow: shadow-md → shadow-lg on hover
scale: 1.05 on hover
```

## Future Enhancements

1. **Voice Input Implementation** - Currently shows button but needs WebSpeech API integration
2. **Mode affects API call** - Pass `queryMode` to stream API to modify system prompt
3. **Keyboard shortcuts** - Add `Cmd+1/2/3` to switch modes
4. **Mode persistence** - Save selected mode to localStorage
