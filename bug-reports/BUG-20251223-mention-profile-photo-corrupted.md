# Bug Report: Profile Photo Corrupted When Using @Mentions

**Date:** 23 December 2025
**Status:** Fixed
**Severity:** Medium
**Component:** RichTextEditor, @Mentions, CSE Profiles

---

## Problem Description

Profile photos appeared corrupted or failed to load in the @mention autocomplete dropdown when typing `@` to mention team members.

---

## Root Cause Analysis

The photo URLs were being constructed inconsistently across different files. The `photo_url` column in `cse_profiles` stores values in the format `/photos/{Name}.jpeg` (with a leading slash).

### Inconsistent URL Construction

**MentionSuggestion.tsx (BROKEN):**

```tsx
photo_url: profile.photo_url
  ? `${SUPABASE_URL}/storage/v1/object/public/cse-photos${profile.photo_url}`
  : null,
```

If `photo_url = "/photos/Name.jpeg"`:

- Result: `.../cse-photos/photos/Name.jpeg` (happens to work because slash joins correctly)

If `photo_url = "photos/Name.jpeg"` (no leading slash):

- Result: `.../cse-photosphotos/Name.jpeg` (BROKEN - missing slash!)

**useUserProfile.ts (INCONSISTENT):**

```tsx
photoUrl = `${SUPABASE_URL}/storage/v1/object/public/cse-photos/${cseProfile.photo_url}`
```

If `photo_url = "/photos/Name.jpeg"`:

- Result: `.../cse-photos//photos/Name.jpeg` (DOUBLE SLASH - might work due to URL normalisation)

**useCSEProfiles.ts (CORRECT):**

```tsx
const photoPath = profile.photo_url.startsWith('/')
  ? profile.photo_url.substring(1)
  : profile.photo_url
return `${SUPABASE_URL}/storage/v1/object/public/cse-photos/${photoPath}`
```

This properly handles both formats.

---

## Solution Implemented

Applied the correct pattern from `useCSEProfiles.ts` to both affected files:

### MentionSuggestion.tsx (Fixed)

```tsx
// Construct full photo URL - handle both "/path" and "path" formats
let photoUrl: string | null = null
if (profile.photo_url) {
  const photoPath = profile.photo_url.startsWith('/')
    ? profile.photo_url.substring(1)
    : profile.photo_url
  photoUrl = `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/cse-photos/${photoPath}`
}
```

### useUserProfile.ts (Fixed)

```tsx
if (cseProfile.photo_url) {
  // Construct full URL to Supabase storage - handle both "/path" and "path" formats
  const photoPath = cseProfile.photo_url.startsWith('/')
    ? cseProfile.photo_url.substring(1)
    : cseProfile.photo_url
  photoUrl = `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/cse-photos/${photoPath}`
}
```

---

## Files Changed

| File                                            | Changes                                                            |
| ----------------------------------------------- | ------------------------------------------------------------------ |
| `src/components/comments/MentionSuggestion.tsx` | Fixed photo URL construction to handle leading slash               |
| `src/hooks/useUserProfile.ts`                   | Fixed photo URL construction to handle leading slash               |
| `src/components/AddNoteModal.tsx`               | Changed to use CSE profile photo instead of MS Graph session photo |

---

## Testing Steps

1. Navigate to any page with RichTextEditor (Client Profile > Add Note, Edit Meeting, etc.)
2. Type `@` to trigger mention autocomplete
3. Verify profile photos load correctly in the dropdown
4. Select a team member and verify the mention is inserted correctly

---

## Notes

### Photo URL Construction

The `cse-photos` bucket in Supabase stores photos with the path `/photos/{Name}.jpeg`. The database stores this relative path. When constructing the full URL, we must:

1. Remove the leading slash if present (to avoid double slashes)
2. Add our own trailing slash after the bucket name
3. Append the cleaned path

This ensures consistent URL construction regardless of how the path is stored.

### Why session.user.image Doesn't Work

The `session.user.image` from NextAuth with Azure AD returns a Microsoft Graph photo URL that requires authentication. These URLs cannot be used as public image sources in `<img>` tags because:

- MS Graph photos require an access token in the request header
- The browser cannot add auth headers when loading images via `src` attribute

**Solution:** Use the CSE profile photo stored in Supabase storage instead (public bucket, no auth required).
