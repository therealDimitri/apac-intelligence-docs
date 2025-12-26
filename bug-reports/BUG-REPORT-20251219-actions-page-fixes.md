# Bug Report: Actions Page Fixes - Dropdowns, Logos, and Grouping

## Date

19 December 2025

## Issues Summary

Multiple issues were identified and fixed on the Actions page:

1. **Department/Activity Type Dropdowns Not Working** - Dropdowns in Create/Edit Action modals were not opening when clicked
2. **Client Logo TypeScript Error** - Build failed due to `logo_url` property not existing on `Client` type
3. **Collapsible Groups Expand/Collapse** - Previous fix for component placement (components were defined after return statement)

## Symptoms

### 1. Dropdown Issue

- Department and Activity Type dropdowns showed placeholder text but did not open when clicked
- No visual feedback when clicking the dropdown buttons
- Priority dropdown (native `<select>`) worked correctly

### 2. Logo Issue

- TypeScript build error: `Property 'logo_url' does not exist on type 'Client'`
- Build failed at line 727 in actions/page.tsx

### 3. Grouping Issue (from previous session)

- Collapsible groups were displayed but clicking expand did nothing
- Components were defined after the return statement (unreachable code)

## Root Cause Analysis

### 1. Dropdown Issue

**Root Cause**: Tremor's `<Select>` component renders its dropdown in a portal at the document root level. The CreateActionModal uses `z-[100]` which is higher than Tremor's default portal z-index, causing the dropdown options to render behind the modal.

```tsx
// Modal container has z-[100]
<div className="fixed inset-0 bg-black/30 backdrop-blur-sm flex items-center justify-center z-[100] ...">
```

Tremor's Select dropdown portal doesn't have a z-index high enough to appear above this modal.

### 2. Logo Issue

**Root Cause**: The `getClientLogo` helper function was incorrectly trying to access `client?.logo_url` from the `Client` interface, but `logo_url` doesn't exist on that type. Client logos are stored locally in `/public/logos/` and accessed via the `getClientLogo` function from `@/lib/client-logos-local`.

### 3. Grouping Issue

**Root Cause**: The `CollapsibleActionGroup` and `ActionCard` components were defined after the main return statement (line 1490+), making them unreachable code.

## Solutions

### 1. Dropdown Fix

Replaced Tremor's `<Select>` component with native HTML `<select>` elements in both DepartmentSelector and ActivityTypeSelector components. Native select elements don't use portals and render inline with the form, avoiding z-index conflicts.

**Files Modified:**

- `src/components/internal-ops/DepartmentSelector.tsx`
- `src/components/internal-ops/ActivityTypeSelector.tsx`

**Before (Tremor Select):**

```tsx
import { Select, SelectItem } from '@tremor/react'

;<Select value={value} onValueChange={handleChange} placeholder="Select department...">
  {departments.map(dept => (
    <SelectItem key={dept.code} value={dept.code}>
      {dept.name}
    </SelectItem>
  ))}
</Select>
```

**After (Native Select):**

```tsx
<select
  value={value || ''}
  onChange={e => onChange(e.target.value)}
  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent appearance-none bg-white cursor-pointer"
>
  <option value="">Select department...</option>
  {departments.map(dept => (
    <option key={dept.code} value={dept.code}>
      {dept.name}
    </option>
  ))}
</select>
```

### 2. Logo Fix

- Added import for `getClientLogo` from `@/lib/client-logos-local`
- Removed the incorrect local `getClientLogo` function that tried to access `client?.logo_url`

**File Modified:** `src/app/(dashboard)/actions/page.tsx`

```tsx
// Added import
import { getClientLogo } from '@/lib/client-logos-local'

// Removed incorrect local function:
// const getClientLogo = (clientName: string) => {
//   const client = clients.find(c => c.name === clientName)
//   return client?.logo_url || null  // ❌ logo_url doesn't exist
// }
```

### 3. Grouping Fix (from previous session)

- Moved `toggleGroupExpanded`, `CollapsibleActionGroup`, and `ActionCard` components from after line 1490 to before the main return statement (before line 723)
- These components are now properly accessible and functional

## Testing

- ✅ Build passes with no TypeScript errors
- ✅ Department dropdown opens and shows 10 departments
- ✅ Activity Type dropdown opens and shows 13 activity types
- ✅ Client logos display correctly in action cards
- ✅ Collapsible similar action groups expand and collapse properly
- ✅ Client logos display in collapsed group headers (up to 5 logos with overflow indicator)

## Technical Details

### Tremor Select vs Native Select Trade-offs

| Feature          | Tremor Select                                     | Native Select         |
| ---------------- | ------------------------------------------------- | --------------------- |
| Z-index handling | Portal-based (conflicts with high z-index modals) | Inline (no conflicts) |
| Styling          | Custom Tremor styles                              | Requires custom CSS   |
| Accessibility    | Built-in                                          | Standard HTML         |
| Search/Filter    | Available                                         | Not available         |
| Complexity       | Higher                                            | Lower                 |

For simple dropdowns in modals, native `<select>` elements are more reliable.

### Affected Components

1. **DepartmentSelector** - Now uses native `<select>` with Tailwind styling
2. **ActivityTypeSelector** - Now uses native `<select>` with Tailwind styling
3. **Actions page** - Fixed logo imports and component placement

## Prevention

- When using Tremor Select in modals with high z-index, consider using native `<select>` instead
- Always import helper functions from the correct source (check existing patterns in codebase)
- Ensure components are defined before the return statement where they are used
- Verify against `docs/database-schema.md` and type definitions before assuming property existence

## Related Bug Reports

- `BUG-2024-12-06-empty-dropdowns-rls-policy-fix.md` - Previous RLS policy issue (different root cause)
- `BUG-REPORT-20251219-collapsible-similar-actions.md` - Collapsible grouping feature documentation
- `BUG-REPORT-20251219-actions-page-ux-redesign.md` - Compact view implementation

## Commits

- Pending commit for dropdown fix and logo import fix
