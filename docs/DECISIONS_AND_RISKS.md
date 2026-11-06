# Habidz — Decisions & risks

## Open decisions (recommended default first)
| ID | Question | Default | Consequence |
|---|---|---|---|
| D1 | Offline engine | **A: Firestore built-in cache** | B (Drift/SQLite + own sync) adds ~25–40% effort |
| D2 | iOS publishing | Accept US$99/yr Apple fee | Without it: Android only |
| D3 | Subscription | **Ship v1 free; add RevenueCat in M7** after you define what is premium (suggestion: >5 habits, Premium Purple theme, export) | Needs store accounts, tax setup, review of subscription rules |
| D4 | Past-day editing | Allow within visible grid | Could be limited to e.g. 7 days to preserve streak honesty |
| D5 | Grid direction in Arabic | Keep oldest→newest left→right | Alternative: mirror grid |
| D6 | Admin panel | None; use Firebase console | Needed only if support/moderation needed later |
| D7 | Minimum age | 16+ in terms, no age data collected | Targeting kids triggers COPPA/GDPR-K work |
| D8 | Auth providers | Email/password only | Google/Apple sign-in = more setup, Apple login mandatory if any social login on iOS |

## Risks
| Risk | Impact | Mitigation |
|---|---|---|
| Free-tier terms/quotas change | Cost or outage | Verify in M0; repository abstraction; budget alerts; JSON export |
| "All free" vs Apple fee | Budget | D2 |
| Firestore read quota at growth | Writes/reads blocked | year-doc design, cache, upgrade path to Blaze |
| No tested backup on Spark | Data loss (provider-side) | Disclosed; user export; scheduled export on Blaze |
| Client-side account deletion can be interrupted | Orphan data | idempotent retry, `deletionRequested` marker, emulator test |
| Time-zone/travel causes odd "today" | Streak confusion | Local-date keys; documented limitation |
| Arabic RTL visual bugs | Poor UX | RTL test pass in M4 on real device |
| Store rejection (privacy/deletion/subscription rules) | Delay | R-12, accurate store data-safety forms |
| Apple review needs a test account | Delay | prepare demo account (synthetic) |
