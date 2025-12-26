# Bug Report: Client Logos Missing in Segment Headers

**Date:** 26 December 2025
**Status:** RESOLVED
**Severity:** Low
**Affected Pages:** NPS Analytics - Top Topics by Client Segment

## Summary

Client logos were not displaying in segment headers on the NPS Analytics page. Some clients showed coloured initials instead of their actual logos.

## Root Cause

The `nps_clients` table contains client names that didn't exactly match the fallback aliases in `client-logos-local.ts`. When Supabase aliases hadn't loaded yet (race condition), these clients fell back to showing initials.

**Missing alias mappings:**
- `Guam Regional Medical City (GRMC)` - Database had this format but aliases had `GUAM Regional Medical City` (without parentheses)
- Other clients were already mapped correctly but needed verification

## Solution

Added missing client name aliases to `FALLBACK_ALIASES` in `src/lib/client-logos-local.ts`:

```typescript
// Added aliases for exact database names
'Guam Regional Medical City (GRMC)': 'GRMC (Guam Regional Medical Centre)',
'Guam Regional Medical City': 'GRMC (Guam Regional Medical Centre)',
```

## Verification

Verified all 18 clients in `nps_clients` table now resolve to logos:

| Client Name | Logo File |
|-------------|-----------|
| Te Whatu Ora Waikato | te-whatu-ora-waikato.webp |
| SA Health (iPro) | sa-health-ipro.webp |
| SA Health (Sunrise) | sa-health-sunrise.webp |
| Grampians Health | grampians-health-alliance.png |
| Albury Wodonga Health | albury-wodonga-health.svg |
| NCS/MinDef Singapore | mindef-singapore.webp |
| Mount Alvernia Hospital | mount-alvernia-hospital.webp |
| Western Health | western-health.png |
| Saint Luke's Medical Centre (SLMC) | st-lukes-medical-center.webp |
| Gippsland Health Alliance (GHA) | gippsland-health-alliance.png |
| Guam Regional Medical City (GRMC) | guam-regional-medical-centre.png |
| Royal Victorian Eye and Ear Hospital | rveeh.webp |
| Barwon Health Australia | barwon-health.svg |
| Epworth Healthcare | epworth-healthcare.webp |
| SA Health (iQemo) | sa-health-iqemo.webp |
| Department of Health - Victoria | vic-health.webp |
| WA Health | wa-health.webp |
| SingHealth | singhealth.png |

## Files Modified

1. `src/lib/client-logos-local.ts` - Added missing FALLBACK_ALIASES entries

## Lessons Learned

1. **Database name consistency:** Client names in database tables should match exactly with logo alias mappings
2. **Race condition handling:** FALLBACK_ALIASES is critical for immediate logo display before Supabase aliases load
3. **Testing alias coverage:** When adding new clients to the database, ensure corresponding aliases exist

## Related Documentation

- `docs/bug-reports/BUG-REPORT-20251226-client-logos-not-displaying.md` - Previous logo fix for Next.js Image issues
- `src/lib/client-logos-local.ts` - Logo resolution logic
- `src/components/TopTopicsBySegment.tsx` - Segment header rendering
