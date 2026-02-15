# Floating Context-Aware ChaSen AI - Design Specification

## Executive Summary

Design a **non-intrusive, context-aware floating AI assistant** that appears on every page of the APAC Client Success Intelligence Dashboard, providing intelligent prompt suggestions based on the current page content and user activity.

## Design Inspiration from Top Tech Companies

### 1. **Intercom / Drift** - Chat Bubble Pattern

- Small circular button in bottom-right corner
- Unread badge when AI has suggestions
- Expands to chat widget on click
- Minimizes without losing state

### 2. **Linear** - Command Palette

- Cmd+K keyboard shortcut
- Slides up from bottom as overlay
- Context-aware suggested commands
- Fuzzy search for actions

### 3. **Notion** - Slash Commands

- In-context AI suggestions
- Appears near cursor/content
- Non-blocking popover design
- Dismissible with Esc

### 4. **GitHub Copilot** - Inline Suggestions

- Ghosted text suggestions
- Tab to accept
- Contextual to current task
- Learning from user patterns

### 5. **Vercel** - Smart Search

- Global search with AI-powered results
- Categorized suggestions
- Recent queries history
- Jump-to navigation

## Recommended Approach: Hybrid Multi-State Design

### States of the Floating Assistant

#### **State 1: Minimized Bubble (Default)**

```
┌────────┐
│   🧠   │  ← Small purple circle with brain icon
│  ChaSen│     Badge shows "3" (number of suggestions)
└────────┘
```

**Location**: Fixed bottom-right (16px from edges)
**Design**:

- 60x60px circular button
- Purple gradient (matching brand)
- Pulsing animation when new suggestions available
- Unread badge (small red circle with number)
- Shadow on hover
- Tooltip: "ChaSen AI has 3 suggestions for this page"

#### **State 2: Quick Suggestions Panel**

```
┌──────────────────────────────────┐
│  💡 Suggested Questions          │
│  ────────────────────────────    │
│  • What's the NPS trend for...   │
│  • Show me at-risk clients       │
│  • Summarize recent meetings     │
│  ────────────────────────────    │
│  [Ask anything...]               │
│  [Expand full chat]              │
└──────────────────────────────────┘
```

**Trigger**: Click on minimized bubble
**Location**: Anchored to bubble, expands upward
**Size**: 320px wide, auto height (max 400px)
**Design**:

- White card with shadow
- 3-5 context-aware suggested questions
- Click suggestion → sends to AI immediately
- Input box for custom question
- \"Expand\" button to full chat mode

#### **State 3: Full Chat Mode**

```
┌────────────────────────────────────────┐
│  ChaSen AI • NPS Analytics Page    [×] │
│  ──────────────────────────────────── │
│  🧠 I can help you analyse this data  │
│  • What's driving the NPS decline?    │
│  • Compare Q3 vs Q4 scores            │
│  • Show improvement recommendations   │
│  ──────────────────────────────────── │
│  [Chat history appears here...]       │
│  ──────────────────────────────────── │
│  [Type your question...]         [→]  │
└────────────────────────────────────────┘
```

**Trigger**: Click "Expand full chat" or keyboard shortcut (Cmd+K)
**Location**: Slides up from bottom, 480px wide, 600px tall
**Design**:

- Full chat interface
- Context indicator in header (current page name)
- Conversation history
- Model selector dropdown
- Minimize/Close buttons
- Draggable header for repositioning

## Context Awareness by Page

### **Command Centre (Dashboard)**

**Detected Context**: Portfolio overview, alerts, priority actions
**Suggested Prompts**:

1. "What are my top 3 risks right now?"
2. "Which clients need attention this week?"
3. "Summarize critical alerts"
4. "Show me CSE workload distribution"
5. "What's the overall portfolio health score?"

### **Client Health / Client Segmentation**

**Detected Context**: Client list, health scores, segments
**Suggested Prompts**:

1. "Which clients are declining in health?"
2. "Compare Tier 1 vs Tier 2 performance"
3. "Who should I prioritise this month?"
4. "Analyze {VisibleClientName}'s health trend"
5. "Show me all critical-status clients"

### **NPS Analytics**

**Detected Context**: NPS scores, trends, detractors/promoters
**Suggested Prompts**:

1. "What's driving the NPS decline for {ClientName}?"
2. "Show me all detractor feedback"
3. "Compare Q3 vs Q4 NPS scores"
4. "Which clients improved the most?"
5. "Generate improvement action plan"

### **Client Segmentation - Individual Client View**

**Detected Context**: Single client focus, compliance data, events
**Suggested Prompts**:

1. "Summarize {ClientName}'s compliance status"
2. "What events are overdue for {ClientName}?"
3. "Show {ClientName}'s health breakdown"
4. "Generate QBR talking points for {ClientName}"
5. "Compare {ClientName} to similar clients"

### **Meetings / Briefing Room**

**Detected Context**: Meeting calendar, schedules, attendees
**Suggested Prompts**:

1. "Prepare me for today's meetings"
2. "What topics should I cover with {ClientName}?"
3. "Show meeting notes from last month"
4. "Who should I schedule meetings with?"
5. "Generate meeting agenda for {ClientName}"

### **Actions & Tasks**

**Detected Context**: Action items, due dates, owners
**Suggested Prompts**:

1. "What actions are overdue?"
2. "Show me {CSEName}'s action load"
3. "Prioritize my tasks for this week"
4. "Which actions are blocking client health?"
5. "Generate action plan for at-risk clients"

## Technical Implementation

### **Component Structure**

```typescript
// FloatingChaSenAI.tsx
interface FloatingChaSenProps {
  // No props needed - detects context from route
}

type AssistantState = 'minimized' | 'suggestions' | 'full-chat'
type PageContext = 'dashboard' | 'clients' | 'nps' | 'segmentation' | 'meetings' | 'actions' | 'ai'

interface ContextualPrompt {
  id: string
  text: string
  category: 'insight' | 'action' | 'analysis' | 'navigation'
  relevance: number // 0-100 score
}
```

### **Context Detection Logic**

```typescript
// Detect current page from URL
const detectPageContext = (): PageContext => {
  const path = window.location.pathname
  if (path === '/') return 'dashboard'
  if (path.startsWith('/clients') || path.startsWith('/segmentation')) return 'clients'
  if (path.startsWith('/nps')) return 'nps'
  if (path.startsWith('/meetings')) return 'meetings'
  if (path.startsWith('/actions')) return 'actions'
  if (path.startsWith('/ai')) return 'ai'
  return 'dashboard'
}

// Detect visible data context
const detectVisibleContext = () => {
  // Extract client names from visible cards
  const visibleClients = Array.from(document.querySelectorAll('[data-client-name]')).map(el =>
    el.getAttribute('data-client-name')
  )

  // Check URL params for client filter
  const urlParams = new URLSearchParams(window.location.search)
  const clientParam = urlParams.get('clients')

  // Check if single client modal is open
  const modalClient = document
    .querySelector('[data-client-modal]')
    ?.getAttribute('data-client-name')

  return {
    visibleClients,
    filteredClient: clientParam,
    focusedClient: modalClient,
    segment: urlParams.get('segment'),
    filter: urlParams.get('filter'),
  }
}
```

### **Prompt Generation**

```typescript
const generateContextualPrompts = (
  pageContext: PageContext,
  visibleContext: any
): ContextualPrompt[] => {
  const prompts: ContextualPrompt[] = []

  switch (pageContext) {
    case 'dashboard':
      prompts.push(
        {
          id: '1',
          text: 'What are my top 3 risks right now?',
          category: 'insight',
          relevance: 100,
        },
        {
          id: '2',
          text: 'Which clients need attention this week?',
          category: 'action',
          relevance: 95,
        },
        { id: '3', text: 'Summarize critical alerts', category: 'insight', relevance: 90 }
      )
      break

    case 'clients':
      if (visibleContext.focusedClient) {
        prompts.push(
          {
            id: '1',
            text: `Analyze ${visibleContext.focusedClient}'s health trend`,
            category: 'analysis',
            relevance: 100,
          },
          {
            id: '2',
            text: `What's driving ${visibleContext.focusedClient}'s score?`,
            category: 'insight',
            relevance: 95,
          }
        )
      } else {
        prompts.push(
          {
            id: '1',
            text: 'Which clients are declining in health?',
            category: 'insight',
            relevance: 100,
          },
          {
            id: '2',
            text: 'Compare Tier 1 vs Tier 2 performance',
            category: 'analysis',
            relevance: 90,
          }
        )
      }
      break

    // ... other cases
  }

  return prompts.sort((a, b) => b.relevance - a.relevance).slice(0, 5)
}
```

### **Component Behavior**

#### **Auto-Update Triggers**

- Route change → Update context immediately
- Modal open/close → Regenerate prompts
- Filter change → Adjust suggestions
- New data load → Refresh relevance scores

#### **User Interaction**

- Click bubble → Show suggestions panel
- Click suggestion → Send to ChaSen API immediately, show loading state
- Type in input → Standard chat flow
- Click \"Expand\" → Full chat mode
- Press Esc → Minimize to bubble
- Click outside → Minimize to bubble (not close)

#### **Keyboard Shortcuts**

- `Cmd+K` / `Ctrl+K` → Open quick suggestions
- `Cmd+Shift+K` → Open full chat
- `Esc` → Minimize
- `↑` / `↓` → Navigate suggestions
- `Enter` → Send selected suggestion

### **Visual States**

#### **Minimized Bubble**

```css
.chasen-bubble {
  position: fixed;
  bottom: 16px;
  right: 16px;
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: linear-gradient(135deg, #7c3aed, #6366f1);
  box-shadow: 0 4px 12px rgba(124, 58, 237, 0.3);
  cursor: pointer;
  transition: all 0.3s ease;
  z-index: 9999;
}

.chasen-bubble:hover {
  transform: scale(1.1);
  box-shadow: 0 6px 20px rgba(124, 58, 237, 0.5);
}

.chasen-bubble.has-suggestions {
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%,
  100% {
    box-shadow: 0 4px 12px rgba(124, 58, 237, 0.3);
  }
  50% {
    box-shadow: 0 4px 20px rgba(124, 58, 237, 0.6);
  }
}
```

#### **Suggestions Panel**

```css
.chasen-suggestions {
  position: fixed;
  bottom: 84px;
  right: 16px;
  width: 320px;
  max-height: 400px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
  padding: 16px;
  animation: slideUp 0.2s ease-out;
  z-index: 9998;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

#### **Full Chat Mode**

```css
.chasen-full-chat {
  position: fixed;
  bottom: 16px;
  right: 16px;
  width: 480px;
  height: 600px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 12px 48px rgba(0, 0, 0, 0.15);
  display: flex;
  flex-direction: column;
  animation: scaleIn 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  z-index: 9998;
}

@keyframes scaleIn {
  from {
    opacity: 0;
    transform: scale(0.8) translateY(20px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}
```

## Mobile Considerations

### **< 768px (Mobile)**

- Bubble moves to bottom-centre
- Full chat takes full screen (100vw x 100vh)
- Slides up from bottom like native drawer
- Close button in top-right
- Swipe down to minimize

### **768px - 1024px (Tablet)**

- Bubble stays bottom-right
- Chat width: 400px (reduced from 480px)
- Height: 500px (reduced from 600px)

## Privacy & Data Handling

### **User Preferences**

- Remember minimized/expanded state (localStorage)
- Track dismissed suggestions (don't show again)
- Save chat position if dragged
- Opt-out of auto-suggestions

### **Data Sent to API**

```typescript
interface ChatSenRequest {
  question: string
  context: {
    page: PageContext
    visibleClients?: string[]
    focusedClient?: string
    segment?: string
    filter?: string
    url: string
  }
  conversation_id?: string // Resume existing conversation
  model_id: number
}
```

## Accessibility

### **ARIA Labels**

- `aria-label=\"ChaSen AI Assistant\"` on bubble
- `aria-expanded` state for panel
- `role=\"dialogue\"` for full chat
- `aria-live=\"polite\"` for new suggestions

### **Keyboard Navigation**

- Tab through suggestions
- Focus trap in full chat mode
- Escape to close
- Screen reader announcements

## Performance Optimization

### **Lazy Loading**

- Component only mounts on first interaction
- Context detection throttled (max once per second)
- Suggestions cached per page (5 min TTL)
- Chat history paginated (load more on scroll)

### **Bundle Size**

- Code-split from main bundle
- Dynamic import when bubble is clicked
- Shared ChaSen API logic with /ai page

## Recommended Phased Rollout

### **Phase 1: Minimized Bubble + Suggestions Panel** (MVP)

- Floating bubble on all pages
- Click → Show 3-5 contextual prompts
- Click prompt → Send to ChaSen API, show inline response
- Simple input for custom questions

### **Phase 2: Full Chat Mode**

- Expand button to full chat interface
- Conversation history
- Model selector
- Draggable positioning

### **Phase 3: Advanced Context Detection**

- Track user scroll position
- Detect highlighted text
- Learn from past queries
- Personalized suggestions

### **Phase 4: Proactive Suggestions**

- Badge appears without click when anomalies detected
- Auto-suggest when user hovers over data
- Smart notifications (\"ChaSen noticed X is at risk\")

## Success Metrics

### **Engagement**

- % users who click the bubble (target: >40%)
- Avg suggestions clicked per session (target: >2)
- Repeat usage rate (target: >60%)

### **Usefulness**

- Suggestion acceptance rate (target: >30%)
- Custom questions vs suggested (ratio: 40/60)
- Chat completion rate (target: >80%)

### **Performance**

- Time to first suggestion (target: <500ms)
- Context detection accuracy (target: >90%)
- Chat response time (target: <3s)

## Implementation Checklist

- [ ] Create FloatingChaSenAI.tsx component
- [ ] Add to layout.tsx (global positioning)
- [ ] Implement page context detection
- [ ] Generate prompt templates for each page
- [ ] Build minimized bubble UI
- [ ] Build suggestions panel UI
- [ ] Build full chat mode UI
- [ ] Integrate with /api/chasen/chat endpoint
- [ ] Add keyboard shortcuts
- [ ] Add mobile responsiveness
- [ ] Add localStorage persistence
- [ ] Add ARIA labels and focus management
- [ ] Test on all dashboard pages
- [ ] Add telemetry/analytics
- [ ] Deploy to staging

## Files to Create/Modify

**New Files**:

- `src/components/FloatingChaSenAI.tsx` - Main component
- `src/hooks/useChaSenContext.ts` - Context detection hook
- `src/lib/chasen-prompts.ts` - Prompt templates by page
- `src/types/chasen.ts` - TypeScript interfaces

**Modified Files**:

- `src/app/(dashboard)/layout.tsx` - Add FloatingChaSenAI
- `src/app/api/chasen/chat/route.ts` - Accept context parameter
- `src/components/layout/sidebar.tsx` - Keep existing ChaSen nav link

## Conclusion

This floating context-aware ChaSen AI design provides:
✅ **Non-intrusive**: Minimizes to small bubble when not needed
✅ **Context-aware**: Intelligent suggestions based on current page
✅ **Accessible**: Keyboard shortcuts, ARIA labels, focus management
✅ **Performant**: Lazy loading, caching, throttled context detection
✅ **Mobile-friendly**: Responsive design with native-like drawers
✅ **Scalable**: Easy to add new page contexts and prompt templates

The hybrid multi-state approach balances discoverability (always visible bubble) with functionality (full chat when needed) while never being intrusive or blocking the user's workflow.
