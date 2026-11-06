# Habidz — Implementation roadmap, TODO & test plan
All statuses: Not Started. Effort in focused dev-days (rough, ±50%).

## Milestones
| M | Goal | Exit gate |
|---|---|---|
| M0 Setup | Flutter project, Firebase Spark project, emulators, CI, l10n skeleton, verify pricing | app launches on Android emulator; CI green; pricing re-verified |
| M1 Auth | Sign up/login/logout/verify/reset, session restore, router guards | auth integration tests pass on emulator |
| M2 Habits core | Habit CRUD, grid widget, check/uncheck, Firestore schema + rules + rules tests | R-05/06/07 acceptance met; rules tests pass |
| M3 Offline & sync | Offline behavior, banner, logout wipe, persistence checks | R-08 test passes (airplane-mode script) |
| M4 Themes, i18n, RTL, icons/colors | 3 themes, en/fr/ar, RTL review, icon+color picker, a11y pass | R-09/R-10 checked on devices |
| M5 Profile & account | Profile edit, change password, delete account, export JSON, streaks | R-04 test passes; 0 orphan docs |
| M6 Hardening & release | App Check, Crashlytics, perf check, privacy policy page, store listings, release builds | release gate checklist all Verified |
| M7 (optional, needs approval) | Subscription via RevenueCat | separate scope/cost approval |

## Tasks
| ID | Task | Pri | Depends | Effort | Req | Acceptance | Verify |
|---|---|---|---|---|---|---|---|
| T0.1 | Create Flutter app, folder structure, lints | M | – | 0.5 | – | `flutter analyze` clean | run |
| T0.2 | Firebase project (Spark), FlutterFire config, emulator suite | M | T0.1 | 0.5 | R-11 | app talks to emulator | run |
| T0.3 | CI: analyze + test on push | S | T0.1 | 0.5 | – | green run | CI |
| T0.4 | Re-verify quotas/prices from official docs; update TECH doc | M | – | 0.25 | – | doc dated | review |
| T1.1 | Auth repository + screens (signup/login/reset/verify) | M | T0.2 | 3 | R-01,02 | valid/invalid/offline cases | integration |
| T1.2 | Session restore, router guard, logout | M | T1.1 | 1 | R-01 | kill/restart keeps session | integration |
| T2.1 | Firestore schema + **security rules + rules tests** | M | T0.2 | 2 | R-11 | other-user/unauth denied | emulator tests |
| T2.2 | Grid widget (53×7, scroll to today, RTL-safe) | M | T0.1 | 2.5 | R-06 | 60 fps scroll w/ 10 habits | profile mode |
| T2.3 | Habit CRUD + check/uncheck + past-day toggle | M | T2.1,T2.2 | 3 | R-05,07 | persists, undo works | widget+integration |
| T3.1 | Offline banner, persistence, logout wipe | M | T2.3 | 1.5 | R-08 | airplane-mode scenario | manual + integration |
| T4.1 | Theme system (Light/Dark/Purple/System) | M | T0.1 | 1.5 | R-09 | contrast ≥ AA | checker + visual |
| T4.2 | ARB strings en/fr/ar + RTL pass | M | T2.3 | 2.5 | R-10 | no hardcoded text; mirrors | RTL screenshot review |
| T4.3 | Icon + color picker | M | T2.3 | 1.5 | R-05 | saved & rendered | widget test |
| T5.1 | Profile + change password (re-auth) | M | T1.2 | 1.5 | R-03 | works online, error offline | integration |
| T5.2 | Delete account flow | M | T2.3,T5.1 | 2 | R-04,12 | 0 docs, Auth user gone, retry-safe | emulator test |
| T5.3 | Streaks + JSON export | S | T2.3 | 1.5 | R-13,15 | unit tests on streak logic | unit |
| T6.1 | App Check + Crashlytics (no PII) | M | M5 | 1 | R-11 | enforced in release | manual |
| T6.2 | Privacy policy/terms page, store listings, release signing | M | M5 | 2 | R-12 | URL live | review |
| T6.3 | Perf/a11y/security checklist run | M | all | 1.5 | R-11 | checklist Verified | report |

Total ≈ 28–32 dev-days for one developer (estimate).

## Requirements → tests (critical)
R-04 → T5.2 emulator test · R-07 → T2.3 widget/integration · R-08 → T3.1 airplane script · R-10 → T4.2 RTL review · R-11 → T2.1 rules tests + T6.3 checklist · R-01/02 → T1.1.
Statuses distinguish planned / implemented / executed / passed; none executed yet.
