# Modal Design Quick Reference Guide

**Quick visual guide for implementing standardised modals**

---

## Visual Hierarchy at a Glance

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER (Fixed, No Scroll)                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ [Icon] Modal Title                            [X]     │  │
│  │        Subtitle/Context                               │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌── Optional Tabs ────────────────────────────────────┐   │
│  │ [Active Tab] [Inactive Tab]                         │   │
│  └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│ CONTENT (Scrollable)                            ↕ Scroll    │
│                                                             │
│  ┌─ AI Suggestions (Optional, Collapsible) ──────────────┐ │
│  │ 🤖 Smart suggestion content here                      │ │
│  │ [Use Suggestion] [Dismiss]                            │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  Label Text *                                               │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Input field with placeholder                        │  │
│  └─────────────────────────────────────────────────────┘  │
│  Help text appears here (grey, small)                      │
│                                                             │
│  Multi-Select Label                                         │
│  Selected: [Chip 1 ×] [Chip 2 ×]                           │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Search or select...                          [▼]    │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌─ Advanced Options (Collapsed by default) ─────────────┐ │
│  │ ▶ Click to expand                                     │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│ FOOTER (Fixed, No Scroll)                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ [Delete]              [Cancel] [Primary Action]      │  │
│  │ ← Destructive         ← Secondary  ← Primary →       │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Spacing Cheat Sheet (8px Grid)

| Element | Spacing |
|---------|---------|
| Modal outer padding | 24px (3 units) |
| Between form fields | 20px (2.5 units) |
| Between sections | 32px (4 units) |
| Inline element gaps | 12px (1.5 units) |
| Chip/pill gap | 8px (1 unit) |
| Input padding (horizontal) | 16px (2 units) |
| Input padding (vertical) | 10px (1.25 units) |
| Button padding (horizontal) | 20px (2.5 units) |
| Button padding (vertical) | 10px (1.25 units) |

---

## Colour States Reference

### Input Field States

| State | Border | Background | Text | Ring |
|-------|--------|------------|------|------|
| Default | Gray 300 | White | Gray 900 | None |
| Hover | Gray 400 | White | Gray 900 | None |
| Focus | Purple 600 (2px) | White | Gray 900 | Purple 100 (3px) |
| Error | Red 500 (2px) | Red 50 | Gray 900 | Red 100 (3px) |
| Success | Green 500 (2px) | White | Gray 900 | None |
| Disabled | Gray 200 | Gray 100 | Gray 400 | None |

### Button States

| Type | Default BG | Hover BG | Active BG | Text |
|------|-----------|----------|-----------|------|
| Primary | Purple 600 | Purple 700 | Purple 800 | White |
| Secondary | White | Gray 50 | Gray 100 | Gray 700 |
| Destructive | Red 600 | Red 700 | Red 800 | White |
| Ghost | Transparent | Gray 100 | Gray 200 | Gray 700 |

---

## Component Sizing

### Modal Widths

| Size | Width | Use Case |
|------|-------|----------|
| sm | 480px | Simple forms (3-5 fields) |
| md | 640px | Standard forms (6-10 fields) **← Default** |
| lg | 800px | Complex forms with sections |
| xl | 1024px | Multi-column layouts |

### Mobile Behaviour

- **< 640px**: Full-screen modal (100% width/height)
- **640px - 1023px**: 90% width, centred
- **≥ 1024px**: Fixed width based on size prop

---

## Typography Quick Copy

```css
/* Header Title */
font-size: 20px;
font-weight: 600;
line-height: 1.2;
colour: #111827; /* Gray 900 */

/* Field Labels */
font-size: 14px;
font-weight: 500;
line-height: 1.5;
colour: #374151; /* Gray 700 */

/* Input Text */
font-size: 14px;
font-weight: 400;
line-height: 1.5;
colour: #111827; /* Gray 900 */

/* Help Text */
font-size: 12px;
font-weight: 400;
line-height: 1.4;
colour: #6B7280; /* Gray 500 */

/* Error Messages */
font-size: 13px;
font-weight: 500;
line-height: 1.4;
colour: #B91C1C; /* Red 700 */
```

---

## Icon Usage Guide

### Common Icons (Lucide React)

| Context | Icon | Usage |
|---------|------|-------|
| Close modal | `<X />` | Always top-right of header |
| Calendar/Date | `<Calendar />` | Date picker fields |
| People/Attendees | `<Users />` | Attendee selection |
| Edit action | `<FileText />` | Action/note fields |
| AI suggestion | `<Sparkles />` | AI-powered features |
| Success | `<CheckCircle2 />` | Success confirmations |
| Error | `<AlertCircle />` | Error messages |
| Warning | `<AlertTriangle />` | Warning states |
| Loading | `<Loader2 className="animate-spin" />` | Async operations |
| Dropdown | `<ChevronDown />` | Select fields |

### Icon Sizing

- **Field icons (inside input)**: 20px (h-5 w-5)
- **Button icons**: 16px (h-4 w-4)
- **Header icons**: 24px (h-6 w-6)
- **Decorative icons**: 16px (h-4 w-4)

---

## Accessibility Checklist

Quick checks before shipping:

- [ ] **Tab order** follows visual order
- [ ] **Focus visible** on all interactive elements (3px purple ring)
- [ ] **Escape key** closes modal
- [ ] **Enter key** submits form (when appropriate)
- [ ] **Labels** associated with inputs (`<label for="id">`)
- [ ] **Error messages** linked with `aria-describedby`
- [ ] **Focus trapped** inside modal (can't tab to background)
- [ ] **Focus returns** to trigger element on close
- [ ] **Screen reader** announces modal on open
- [ ] **Colour contrast** meets 4.5:1 ratio
- [ ] **Icons** have `aria-label` or text equivalent
- [ ] **Loading states** announced to screen readers

---

## Validation Timing

| Validation Type | When to Trigger | Example |
|----------------|-----------------|---------|
| Format validation | As you type (debounced) | Email format, phone number |
| Required check | On blur (leaving field) | Empty required field |
| Uniqueness check | On blur | Duplicate action title |
| Cross-field validation | On submit | End date > start date |
| Server-side | On submit | Duplicate client name |

---

## Error Message Formula

```
❌ DON'T: "Invalid input"
✅ DO: "[What's wrong] + [Why it matters] + [How to fix]"

Examples:

❌ "Error"
✅ "Email must include @ symbol (e.g., user@company.com)"

❌ "Invalid date"
✅ "Due date must be in the future. Please select tomorrow or later."

❌ "Field required"
✅ "Client name is required to create this meeting."
```

---

## Animation Timing

| Animation | Duration | Easing | Notes |
|-----------|----------|--------|-------|
| Modal open | 250ms | ease-out | Slide up + fade |
| Modal close | 200ms | ease-in | Slide down + fade |
| Focus ring | 150ms | ease-out | Expand from 0 to 3px |
| Button hover | 150ms | ease-out | Scale 1.02 |
| Field validation | 200ms | ease-out | Icon pop-in |
| Error shake | 300ms | ease-out | 3px horizontal |
| Success tick | 400ms | ease-out | Draw animation |

**Important:** Always respect `prefers-reduced-motion` user preference.

---

## Mobile-Specific Patterns

### Touch Targets

- **Minimum size**: 44×44px (iOS standard)
- **Recommended**: 48×48px (Material Design)
- **Spacing between targets**: Minimum 8px

### Gestures

- **Swipe down**: Dismiss modal (when at top of scroll)
- **Tap backdrop**: Close modal (with confirmation if unsaved changes)
- **Pull to refresh**: Not applicable in modals

### Layout Adaptations

| Desktop | Mobile |
|---------|--------|
| 2-column form | 1-column stacked |
| Inline buttons | Stacked full-width buttons |
| Dropdown menu | Bottom sheet |
| Tooltip on hover | Tap to reveal |
| Modal dialogue | Full-screen (< 640px) |

---

## Common Patterns Reference

### Multi-Step Form Progress

```
Step 1 of 3: Basic Information
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
●━━━━━━━━━━━○━━━━━━━━━━━○  ← Progress dots
```

### Inline Success Message

```
┌─────────────────────────────────────────┐
│ ✅ Meeting scheduled successfully!      │
│                                         │
│ What's next?                            │
│ • Calendar invite sent to 4 attendees   │
│ • Teams link created                    │
│                                         │
│ [View Meeting]  [Schedule Another]      │
└─────────────────────────────────────────┘
```

### Smart Suggestion Card

```
┌─ 🤖 AI Suggestion ──────────────────────┐
│ Schedule QBR with Epworth Healthcare    │
│                                         │
│ Suggested: Wed 15 Jan, 2:00 PM          │
│ Duration: 60 minutes                    │
│ Attendees: John Smith, Sarah Lee        │
│                                         │
│ [Use This]  [Dismiss]                   │
└─────────────────────────────────────────┘
```

### Collapsible Advanced Section

```
▶ Advanced Options                  ← Collapsed (default)
  Click to expand

▼ Advanced Options                  ← Expanded
  ┌─────────────────────────────┐
  │ Internal Operations          │
  │ Department: [Select...]      │
  │ Activity Type: [Select...]   │
  └─────────────────────────────┘
```

---

## Developer Quick Start

### Basic Modal Usage

```tsx
<UnifiedModal
  isOpen={isOpen}
  onClose={handleClose}
  onSuccess={handleSuccess}
  mode="create-action"
  size="md"
  initialData={{
    title: "Follow up on demo",
    client: "Epworth Healthcare"
  }}
  features={{
    aiSuggestions: true,
    richTextEditor: true
  }}
/>
```

### Custom Validation

```tsx
import { z } from 'zod'

const actionSchema = z.object({
  title: z.string().min(3, "Title must be at least 3 characters"),
  client: z.string().min(1, "Client is required"),
  dueDate: z.date().min(new Date(), "Due date must be in the future")
})

<UnifiedModal
  validationSchema={actionSchema}
  // ... other props
/>
```

---

## Common Mistakes to Avoid

| ❌ Don't | ✅ Do |
|---------|-------|
| Use `onClick` on non-button elements | Use semantic `<button>` elements |
| Forget to disable submit during save | Show loading state and disable button |
| Auto-focus first field on mobile | Let user tap to focus (prevents keyboard jump) |
| Use placeholder as label | Always provide separate label element |
| Nest modals | Close current modal before opening new one |
| Use tiny close button (< 40px) | Minimum 44×44px touch target |
| Show validation errors immediately | Wait for blur or submit |
| Use red for non-errors | Reserve red for actual errors only |
| Animate everything | Respect `prefers-reduced-motion` |
| Forget to trap focus | Keep keyboard navigation inside modal |

---

## Testing Commands

```bash
# Accessibility audit
npm run test:a11y

# Visual regression tests
npm run test:visual

# Keyboard navigation test
npm run test:keyboard

# Mobile responsiveness
npm run test:responsive

# Performance test (time to interactive)
npm run test:performance
```

---

## Resources & References

- **Design System**: [File path to Figma/design system]
- **Component Library**: `src/components/unified-modal/`
- **Full Documentation**: `docs/guides/MODAL-DESIGN-STANDARDS.md`
- **Accessibility Guidelines**: WCAG 2.2 Level AA
- **Icon Library**: [Lucide React](https://lucide.dev/)
- **Animation Library**: Framer Motion (if used)

---

**Quick Reference Version:** 1.0
**Last Updated:** 2026-01-07
**For Full Details:** See MODAL-DESIGN-STANDARDS.md
