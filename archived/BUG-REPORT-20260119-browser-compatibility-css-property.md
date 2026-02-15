# Bug Report: Browser Compatibility - CSS @property Rule

**Date:** 2026-01-19
**Status:** Fixed
**Severity:** Critical (production display failure)
**Component:** globals.css - CSS Houdini @property

## Summary

Production site (https://apac-cs-dashboards.com) failed to display in Safari browsers, then after an incorrect fix, failed to display in Chrome browsers. Both issues were related to the CSS `@property` rule used for animated border gradients.

## Timeline

### Issue 1: Safari Display Failure
**Symptom:** Blank white page on Safari browsers.

**Root Cause:** CSS `@property` rule (used for animated `--angle` variable in rotating gradient borders) requires Safari 16.4+. While the user had Safari 26.2, the initial investigation led to an incorrect fix.

### Issue 2: Chrome Display Failure (After Safari Fix)
**Symptom:** After applying Safari fix, site displayed blank white page on Chrome.

**Root Cause:** The Safari "fix" wrapped `@property` in an incorrect `@supports` query:

```css
/* INCORRECT - This checks for CSS Paint API, not @property support */
@supports (background: paint(something)) {
  @property --angle {
    syntax: '<angle>';
    initial-value: 0deg;
    inherits: false;
  }
}
```

The `@supports (background: paint(something))` query checks for CSS Paint API support with a fictional worklet name. Since `paint(something)` doesn't exist as a registered worklet, Chrome returns `false` for this query, causing the entire block (including the `@property` declaration) to be skipped.

Without the `@property --angle` declaration, the `rotateGlow` animation that uses `--angle` failed to work, breaking the page.

## Resolution

Removed the incorrect `@supports` wrapper entirely. Since:
- Safari 16.4+ supports `@property` natively
- Chrome 85+ supports `@property`
- Edge 85+ supports `@property`
- Firefox 129+ supports `@property`

The `@property` rule works in all modern browsers without needing a feature query.

**Before (broken):**
```css
@supports (background: paint(something)) {
  @property --angle {
    syntax: '<angle>';
    initial-value: 0deg;
    inherits: false;
  }
}
```

**After (working):**
```css
/* CSS Houdini @property for animated CSS variables */
/* Supported by Chrome 85+, Safari 16.4+, Edge 85+, Firefox 129+ */
@property --angle {
  syntax: '<angle>';
  initial-value: 0deg;
  inherits: false;
}
```

## Files Modified

| File | Changes |
|------|---------|
| `src/app/globals.css` | Removed incorrect `@supports` wrapper, added browser compatibility comments |

## Key Learnings

1. **CSS Paint API ≠ @property**: The CSS Paint API (`paint()` function) and CSS Houdini `@property` are different features. Testing for one doesn't guarantee the other.

2. **Feature queries with fictional values fail**: Using `@supports (background: paint(something))` with a non-existent worklet name will always return `false`.

3. **Modern browsers support @property**: As of 2025-2026, all major browsers support `@property`:
   - Chrome 85+ (August 2020)
   - Edge 85+ (August 2020)
   - Safari 16.4+ (March 2023)
   - Firefox 129+ (August 2024)

4. **Test across browsers after CSS changes**: CSS feature support varies, and what works in one browser may break in another.

## Verification

1. https://apac-cs-dashboards.com displays correctly in:
   - Chrome (latest)
   - Safari 26.2
   - Edge (latest)
   - Firefox (latest)

2. Animated gradient borders (using `--angle`) work as expected

## Related Commits

- `ef157006` - Fix potential Safari CSS parsing issue with @property rule (caused Chrome issue)
- `049e93dd` - Fix @property CSS rule - remove incorrect @supports wrapper
