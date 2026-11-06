# Habidz — Tech stack decision, offline strategy, costs & ownership

> Verification note: web search returned only third-party pages (no official page content) in this planning session. All quota/price figures below are **UNVERIFIED — from general knowledge; confirm on firebase.google.com/pricing and the store/RevenueCat pages (date: 2026-10-26) before Milestone 0 ends.**

## 1. Architecture alternatives
| | A. Flutter + Firebase Auth + Firestore (built-in offline cache) | B. Flutter + Drift/SQLite local DB + Firestore sync | C. Flutter + Supabase (Postgres) |
|---|---|---|---|
| Matches your preference | Yes | Yes | No |
| Offline | Good: SDK cache + queued writes, automatic | Best control, fully local-first; you write the sync | Needs own local DB + sync |
| Complexity / effort | Low (~baseline) | Medium-high (+25–40%: outbox, conflict, migrations) | Medium-high |
| Free tier (unverified) | Spark: no card needed | same | Free projects pause after inactivity (unverified) |
| Server-side code | None needed (see rules) | None | None |
| Security model | Firestore Security Rules + Auth | same | Postgres RLS |
| Lock-in | Medium-high (proprietary Firestore) | Medium (local DB is portable) | Low (Postgres) |
| Account deletion | Client-side batch (Functions need paid Blaze) | same | simple SQL |

**Recommendation: A.** Firestore's mobile SDK already persists data in an on-device database and queues offline writes, so it *is* the "offline db" you asked for, with far less code and fewer sync bugs. Choose B only if you later need: long offline periods with heavy history, custom merge logic, or you want to leave Firestore later. Choose C if lock-in or Firestore quota/pricing becomes the main worry.
Caveat: Firestore's cache is not encrypted at rest beyond OS app sandboxing and is wiped on logout by our code.

## 2. Final stack (if approved)
Flutter (stable) + Dart · Riverpod (state) · go_router · firebase_auth · cloud_firestore · firebase_app_check · firebase_crashlytics (crash only, no analytics) · flutter_localizations/intl (ARB: en, fr, ar) · flutter_secure_storage (only if needed) · shared_preferences (theme/lang) · flutter_test + integration_test + Firebase Emulator Suite (local tests, free) · GitHub (repo) + GitHub Actions (CI, free tier).
All licenses are open-source (BSD/Apache/MIT); Flutter + packages are free for commercial use.

## 3. Data-cost design (why Firestore stays free longer)
One Firestore doc per habit **per year** holds all days of that year as a map, so a toggle = 1 write and loading a grid = 1–2 reads, not 365.
Rough capacity estimate (unverified quotas 50k reads/day, 20k writes/day, 1 GiB): cold-open ≈ 10 habits × 2 docs = 20 reads (cache reduces it); ~5 writes/user/day → free tier supports on the order of **1,500–2,500 daily active users** before reads are the limit. Estimate, not a guarantee.
If quota is hit on Spark, requests fail until reset (no surprise bill). Upgrading to Blaze needs a billing card; mitigate with budget alerts.

## 4. Costs
| Item | Who | Cost (unverified) |
|---|---|---|
| Flutter, VS Code/Android Studio, Firebase Spark, GitHub, emulators | you | $0 |
| Google Play developer account | publisher | ~US$25 one-time |
| **Apple Developer Program (required to publish on iOS)** | publisher | ~US$99/year — **not free; unavoidable** |
| iOS builds need macOS/Xcode: own Mac, or CI (Codemagic / GitHub Actions macOS) free minutes limited | you | $0 if free minutes suffice, else a Mac or paid minutes |
| Domain + hosted privacy-policy page | publisher | $0 (GitHub Pages / Firebase Hosting) or ~US$10/yr domain |
| Subscriptions (later): store commission 15–30%; RevenueCat free up to a revenue threshold | — | % of revenue; $0 fixed initially |
| Growth scenario (>~2k DAU) | owner | Blaze pay-as-you-go: likely single/double-digit USD/month at that scale (estimate) |

"All technologies free": true for **software and hosting at launch scale**; false for the iOS store fee. Free tiers can change; the plan keeps data exportable (R-15) and the repo provider-agnostic at the repository layer so Firestore can be replaced.

## 5. Ownership
You are the product owner (individual): create the Firebase project, Play and Apple accounts under **your own** Google/Apple identity; source in your GitHub. Nothing depends on a developer's personal account. No client handover needed; a short operations checklist (rotate keys, quota alerts, backups) lives in the deployment doc created in Milestone 6.

## 6. Backups
Firestore managed backups/exports need Blaze. On Spark: rely on Google's durability + user-level JSON export (R-15). This is **not** a tested backup/restore; stated as a limitation. Add scheduled export when/if on Blaze.
