# Bug Report: Hydration Mismatch and Build Errors

## Date: November 25, 2025

## Project: APAC Intelligence v2 Dashboard

---

## Issue Summary

Multiple hydration mismatch errors and build errors occurred when connecting real data from Supabase to the dashboard pages. The main issues were related to date formatting inconsistencies between server and client rendering, and syntax errors during the data migration.

---

## Issues Identified

### 1. Hydration Mismatch - Date Formatting

**Error Message:**

```
Hydration failed because the server rendered text didn't match the client.
- Server: 28/11/2025
- Client: 11/28/2025
```

**Root Cause:**
Using `toLocaleDateString()` method caused different date formats on server vs client based on locale settings. This is a common issue in SSR applications where the server and client may have different locale configurations.

**Files Affected:**

- `/src/app/(dashboard)/actions/page.tsx` (line 240)
- `/src/app/(dashboard)/nps/page.tsx` (line 247)

### 2. Build Error - Unterminated Regexp Literal

**Error Message:**

```
Parsing ecmascript source code failed
./src/app/(dashboard)/actions/page.tsx:259:10
Unterminated regexp literal
```

**Root Cause:**
Missing closing parenthesis for ternary operator when refactoring the Actions page to use real data. The structure had:

```jsx
) : (
  // content
  </div>
</div>  // Missing )}
```

**Files Affected:**

- `/src/app/(dashboard)/actions/page.tsx` (line 258-259)

---

## Solutions Implemented

### 1. Date Formatting Fix

Created a consistent date formatting function that always returns the same format regardless of locale:

```typescript
// Helper function for consistent date formatting
const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  const month = (date.getMonth() + 1).toString().padStart(2, '0')
  const day = date.getDate().toString().padStart(2, '0')
  const year = date.getFullYear()
  return `${month}/${day}/${year}` // MM/DD/YYYY format
}
```

Replaced all instances of `toLocaleDateString()` with this function.

### 2. Syntax Error Fix

Added the missing closing parenthesis and bracket for the ternary operator:

```jsx
// Before (incorrect)
))}
          </div>
        </div>

// After (correct)
))}
            </div>
          )}  // Added this line
        </div>
```

---

## Files Modified

1. **Actions Page** (`/src/app/(dashboard)/actions/page.tsx`)
   - Added formatDate helper function
   - Replaced toLocaleDateString with formatDate
   - Fixed missing closing parenthesis
   - Connected useActions hook for real data

2. **NPS Analytics Page** (`/src/app/(dashboard)/nps/page.tsx`)
   - Added formatDate helper function
   - Replaced toLocaleDateString with formatDate
   - Connected useNPSData hook for real data
   - Updated field references (e.g., `response.client` → `response.client_name`)

---

## Testing & Verification

1. ✅ Hydration errors resolved - no console warnings
2. ✅ Build compiles successfully
3. ✅ Dates display consistently as MM/DD/YYYY
4. ✅ Real data loads from Supabase
5. ✅ Loading states and error handling work correctly

---

## Lessons Learned

1. **Always use consistent date formatting** in SSR applications to avoid hydration mismatches
2. **Be careful with ternary operators** when refactoring - ensure all brackets and parentheses match
3. **Test hydration** by checking both server and client rendered output
4. **Use TypeScript** to catch potential type mismatches early

---

## Prevention Measures

1. Create utility functions for date formatting at project start
2. Use ESLint rules to catch missing brackets/parentheses
3. Implement unit tests for date formatting functions
4. Consider using date libraries like `date-fns` for consistent formatting

---

## Related Commits

- Fixed hydration mismatch errors and connected real data to Actions page
- Updated NPS Analytics page with real data and fixed date formatting
- Fixed syntax error in Actions page (missing closing parenthesis)
