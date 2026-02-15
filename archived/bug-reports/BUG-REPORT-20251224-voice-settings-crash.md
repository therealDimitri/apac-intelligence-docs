# Bug Report: Voice Settings Modal Crash

**Date:** 24 December 2025
**Severity:** Critical
**Status:** Fixed
**Commit:** 3a84721

## Summary

Clicking the Voice Settings button in ChaSen AI caused the entire dashboard to crash with an unhandled exception.

## Error Message

```
Uncaught Error: A <Select.Item /> must have a value prop that is not an empty string.
This is because the Select value can be set to an empty string to clear the selection
and show the placeholder.
```

## Root Cause

Some browser speech synthesis voices have empty string names (`voice.name === ""`). When these voices were rendered as `<option>` elements in the voice selector dropdown, it violated the requirement that Select items must have non-empty values.

## Affected Files

- `src/components/VoiceSettings.tsx`

## Solution

Added filters to exclude voices with empty or whitespace-only names in two locations:

### 1. `groupVoicesByLanguage` function

```typescript
// Filter out voices with empty names to prevent Select.Item errors
voices
  .filter(voice => voice.name && voice.name.trim() !== '')
  .forEach(voice => {
    // ... grouping logic
  })
```

### 2. Option rendering

```typescript
{groupedVoices[group]
  .filter(voice => voice.name && voice.name.trim() !== '')
  .sort((a, b) => { /* sorting logic */ })
  .map(voice => (
    <option key={voice.name} value={voice.name}>
      {voice.name}
    </option>
  ))}
```

## Testing

1. Navigate to ChaSen AI page
2. Send any message to get a response
3. Click the Voice Settings button (gear icon)
4. Modal should open without errors
5. Voice dropdown should display available voices grouped by language

## Prevention

When working with browser APIs that return lists (like `speechSynthesis.getVoices()`), always validate that required fields are non-empty before rendering them in UI components that require values.
