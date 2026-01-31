# Bug Report: ChaSen Profile Photos Not Rendering

**Date:** 27 December 2025
**Severity:** Low
**Status:** Fixed
**Commits:** `6271337`, `b96cb1c`

## Summary

Profile photos referenced in ChaSen responses were not rendering as images. Instead, markdown image syntax `![Name](url)` was displaying as broken links showing "! Name" with the URL as a clickable link.

## Root Causes

Two separate issues contributed to this bug:

### 1. Photo URLs were just filenames, not full URLs

The `cse_profiles` table stores photo URLs as just filenames (e.g., `Nikki-Wei.jpeg`) rather than full Supabase Storage URLs.

**Location:** `src/app/api/chasen/stream/route.ts`

**Before:**
```typescript
const photoInfo = dr.photo_url ? ` | Photo: ${dr.photo_url}` : ''
```

**After:**
```typescript
const getPhotoUrl = (filename: string | null): string | null => {
  if (!filename) return null
  if (filename.startsWith('http')) return filename
  return `https://usoyxsunetvxdjdglkmn.supabase.co/storage/v1/object/public/cse-photos/${filename}`
}
const photoUrl = getPhotoUrl(dr.photo_url)
const photoInfo = photoUrl ? ` | Photo: ${photoUrl}` : ''
```

### 2. Markdown renderer didn't support image syntax

The `renderMarkdownContent` function in `markdown-renderer.tsx` handled links `[text](url)` but not images `![alt](url)`.

**Location:** `src/lib/markdown-renderer.tsx`

**Fix:** Added image pattern matching before link matching:
```typescript
// Process markdown images ![alt](url) - must be before links to prevent partial matching
.replace(/!\[([^\]]*)\]\(((?:[^()]|\([^)]*\))+)\)/g, (_, altText, url) => {
  return `<img src="${url}" alt="${altText}" class="inline-block rounded-full w-10 h-10 object-cover mr-2 align-middle shadow-sm border border-gray-200" onerror="this.style.display='none'" />`
})
```

## Additional Fix: Bullet Formatting

Also updated the system prompt to explicitly prohibit underscore (`_`) bullets and require proper bullet characters (`•`, `-`, or numbered lists).

## Files Modified

| File | Changes |
|------|---------|
| `src/app/api/chasen/stream/route.ts` | Added `getPhotoUrl()` helper to construct full URLs, changed context bullets from `-` to `•` |
| `src/lib/markdown-renderer.tsx` | Added markdown image rendering support |

## Verification

After the fix:
1. Photo URLs are now full Supabase Storage URLs
2. Images render as 40px circular avatars with shadow and border
3. Images gracefully hide on load error (onerror handler)

## Testing

1. Navigate to `/ai` (ChaSen AI page)
2. Ask "Tell me about Nikki Wei's role"
3. Verify Nikki's profile photo displays as a circular avatar next to her name
4. Verify proper bullet formatting (no underscore bullets)

## Related

- [Stream Org Context Bug](./BUG-REPORT-20251227-chasen-stream-missing-org-context.md)
- [Job Descriptions Feature](./FEATURE-20251227-job-descriptions.md)
