# Habidz — Documentation

One file with everything: what the app is, what it is built with, how it works, how to run and ship it, and how to fix the problems we already hit.

> Facts about free-tier limits and prices are from general knowledge and were **not** verified against official pages. Check firebase.google.com/pricing before relying on them.

## Contents
1. [What it is](#1-what-it-is)
2. [Everything that was used](#2-everything-that-was-used)
3. [How the app works](#3-how-the-app-works)
4. [Data model and security rules](#4-data-model-and-security-rules)
5. [Security and privacy](#5-security-and-privacy)
6. [Offline behaviour](#6-offline-behaviour)
7. [Design, branding, languages](#7-design-branding-languages)
8. [Performance](#8-performance)
9. [Setup, run and build](#9-setup-run-and-build)
10. [Git and secrets checklist](#10-git-and-secrets-checklist)
11. [Troubleshooting](#11-troubleshooting)
12. [Costs and limits](#12-costs-and-limits)
13. [Testing status](#13-testing-status)
14. [Known limitations and ideas](#14-known-limitations-and-ideas)

---

## 1. What it is
Habidz is a habit tracker whose main view is a GitHub-style contribution grid. Each habit is a card with a year of squares; one tap marks today. Accounts sync across devices through Firebase, and the app keeps working offline.

Target: individuals, worldwide. Languages: English, French, Arabic (RTL). Platform: Android first (Flutter code is cross-platform, iOS untested).

## 2. Everything that was used

| Area | What | Why | License / cost |
|---|---|---|---|
| Framework | Flutter + Dart | One codebase, fast UI | BSD-3 / free |
| Login | Firebase Authentication (`firebase_auth`) | Hashing, sessions, reset and verification emails handled by Google | Free on Spark (email/password) |
| Database | Cloud Firestore (`cloud_firestore`) | Sync, security rules, built-in offline cache | Free Spark quota |
| Firebase core | `firebase_core`, FlutterFire CLI (`flutterfire configure`) | Connects the app to the project | Free |
| Local settings | `shared_preferences` | Theme and language per device | BSD-3 / free |
| Dates and localisation | `intl`, `flutter_localizations` | Month names, Material widgets in EN/FR/AR | BSD-3 / free |
| Splash | `flutter_native_splash` | Plain white native launch screen | MIT / free |
| App icon | `flutter_launcher_icons` | Generates all icon sizes from `assets/logo.png` | MIT / free |
| Name font | Krona One (`assets/fonts/KronaOne-Regular.ttf`) | Wide, bold tech look for "HABIDZ" | SIL OFL 1.1 / free |
| Lints and tests | `flutter_lints`, `flutter_test` | Code quality, streak tests | BSD-3 / free |
| Rules deploy | Firebase CLI (`firebase-tools`, needs Node.js) | Publishes `firestore.rules` | Free |
| Source control | Git + GitHub | Versioning | Free |
| IDE | Android Studio | Run, debug, emulator | Free |

State management is plain Flutter on purpose (`ChangeNotifier`, `ListenableBuilder`, `StreamBuilder`). No state package, no code generation, no custom backend, no analytics SDK. Check each package's page on pub.dev for its exact current license.

## 3. How the app works

**Start-up (`main.dart`)**: initialise Firebase, load saved theme and language, then show `SplashScreen`. The splash animates the logo and name, then fades into `AuthGate`, which listens to `FirebaseAuth.userChanges()`: signed out shows `AuthScreen`, signed in shows `HomeScreen`. Firebase restores the session offline.

**Screens**

| Screen | File | What it does |
|---|---|---|
| Splash | `splash_screen.dart` | Logo pops in, name slides up, cross-fade to the app. Skips most of it if the phone has "remove animations" on |
| Sign in / up | `auth_screen.dart` | One screen, two modes; reset password; generic errors that do not reveal which emails exist |
| Home | `home_screen.dart` | Vertical list of habit cards, "+" button, one-line verify-email notice (opens a sheet with Resend / I verified and a spam hint), offline notice |
| Habit card | `habit_card.dart` | Icon, name, streak, big check button, the grid. Listens to this year's and last year's day documents |
| Grid | `habit_grid.dart` | 53 weeks x 7 days painted by one `CustomPainter`; tap a square to toggle |
| Editor | `habit_editor.dart` | Name (max 40), 30 icons, colour or Auto, archive, delete |
| Profile | `profile_screen.dart` | Name, theme, language, change password, export JSON, log out, delete account |

**Data access** lives only in `habit_repo.dart`. UI code never touches Firestore directly, so the database could be replaced later.

**Writes are not awaited.** A Firestore write only completes when the server confirms. The UI calls writes without waiting, so taps feel instant and offline edits are applied locally at once and synced later.

**Streaks (`habit.dart`)**: current streak counts back from today (or yesterday if today is not checked yet); best streak is the longest run of consecutive days. Pure functions, unit-tested.

**Days** are device-local calendar dates stored as `MM-DD` keys inside a year document, never as timestamps, so time zones cannot split a day.

## 4. Data model and security rules

```
users/{uid}                               displayName, createdAt, schemaVersion
users/{uid}/habits/{habitId}              name, icon, color (int or null), order, archived, createdAt, updatedAt
users/{uid}/habits/{habitId}/years/{yyyy} days: { "03-14": true, ... }
```

One document per habit per year means: checking a day is one small write, loading a grid is two reads (this year + last year), and a year document stays tiny (max 366 keys). That keeps a small app well inside the free quota.

Edit/undo: set the key to `true` or delete the key with `FieldValue.delete()` (merge write). Concurrent offline edits of different days never conflict; the same day is last-write-wins.

**`firebase/firestore.rules`** (summary):
- Everything is denied by default.
- Only the signed-in owner (`request.auth.uid == uid`) can read, write or delete under `users/{uid}/**`.
- User doc: only `displayName`, `createdAt`, `schemaVersion` allowed; name is a string up to 60 characters.
- Habit doc: only the listed fields; name 1–40 characters; `archived` is a bool; `color` is an int or null; icon is a string up to 30 characters.
- Year doc: id matches `YYYY`; only a `days` map with at most 366 entries.

**Deploy the rules after any change**, otherwise the live database uses the old ones: `firebase deploy --only firestore:rules`.

## 5. Security and privacy

| Question | Answer |
|---|---|
| Are passwords hashed? | Yes, by Firebase Auth on Google's servers (a salted scrypt variant as far as we know). The app never sees or stores the password |
| Encryption in transit | TLS (HTTPS) for all Firebase traffic |
| Encryption at rest (cloud) | Google encrypts Firestore data by default |
| Encryption on the phone | The offline cache is not separately encrypted by the app; it relies on Android's app sandbox and the device lock |
| End-to-end encrypted? | No. The project owner can read habit names in the Firebase console |
| Who can read my data? | Only my signed-in account (rules), plus the project owner via the console |
| Sensitive actions | Change password and delete account require re-entering the password |
| Data collected | Email, display name, habit names and check-in dates. No location, contacts, ads or analytics |
| Delete / export | In-app account deletion and JSON export |

**Delete account flow**: re-authenticate (needs internet, so an offline attempt stops before anything is deleted) → delete every year document and habit → delete the user document → delete the Auth user. If interrupted, run it again.

**Are the Firebase keys secret?** `firebase_options.dart` and `google-services.json` contain public client identifiers, not secrets; the rules protect the data. Still, keep them out of Git (see section 10) and restrict the API key to your app in Google Cloud Console. Never commit signing keys (`*.jks`, `*.keystore`, `key.properties`) or service-account JSON files.

**Not done yet**: Firebase App Check (blocks non-app clients), Crashlytics, logout does not wipe the local cache (the SDK cannot clear it while running).

## 6. Offline behaviour

| Works offline | Needs internet |
|---|---|
| View habits and grids, add / edit / delete habits, check and uncheck days, change theme and language | Sign up, first login, forgot / change password, verification email, delete account |

Firestore keeps a local database and queues writes. The home screen listens with metadata changes and shows "Offline or syncing" only if data stays unconfirmed for more than 3 seconds, so it does not flash on normal starts.

## 7. Design, branding, languages

**Themes** (`theme.dart`): System, Light (white / near-black), Dark (GitHub-like `#0D1117`), Premium purple (deep violet with lavender accent). Cards and inputs use rounded corners. Each habit has a colour from a 10-colour palette or *Auto* (the theme's accent: black, white or lavender).

**Logo (`assets/logo.png`)**: must be a single-colour PNG on a transparent background (about 512x512). The `LogoMark` widget recolours it to the theme's text colour (black on light, white on dark and purple), so one file works everywhere. The splash always uses black on white. A multi-colour logo would lose its colours with this approach; in that case use two files instead.

**Name style (`brand.dart`)**: "HABIDZ" in Krona One with letter-spacing. Arabic has no glyphs in that font, so Arabic shows the translated name in the normal bold style.

**App icon and splash**: `flutter_launcher_icons` builds the launcher icon (and Android adaptive icon with a white background) from `assets/logo.png`; `flutter_native_splash` makes the plain white native launch screen. Re-run both after changing the logo:
```
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
then `flutter clean`, **uninstall the app** and run again (Android caches launcher icons).

**Languages (`l10n.dart`)**: one map of strings for `en`, `fr`, `ar`, read with `context.t('key')`; missing keys fall back to English. Add a key to all three languages together. Layout direction and Material widgets switch automatically with the locale. The habit grid always runs oldest to newest, left to right, even in Arabic (it is a chart). The language defaults to the phone's language if supported.

**Accessibility**: 44 dp check button, semantic label on each grid, text scales with the system setting, splash respects "remove animations". Contrast of the habit palette was chosen for dark surfaces but has not been formally audited.

## 8. Performance
- All 371 squares are painted by one `CustomPainter` inside a `RepaintBoundary` instead of 371 widgets; it repaints only when the data or theme changes.
- Habit cards are kept alive while scrolling so their Firestore listeners are not recreated.
- A habit costs about 2 document reads on load, 1 write per tap.
- Judge speed in a **release** build (`flutter run --release`); debug mode is much slower.
- Some phones show rendering glitches (thin lines, flicker) with Flutter's Impeller renderer. See troubleshooting.

## 9. Setup, run and build

Prerequisites: Flutter (stable), Android Studio with the Android SDK, Node.js (for the Firebase CLI), a free Firebase project. Run `flutter doctor` and fix what it reports.

1. `flutter pub get`
2. If the `android/` and `ios/` folders do not exist: `flutter create --platforms=android,ios --project-name habidz --org com.habidz .` (keeps your `lib/`; if it replaces `lib/main.dart`, restore it).
3. Firebase console (stay on the free **Spark** plan): enable **Email/Password**, keep "email enumeration protection" on, create a Firestore database in production mode.
4. `npm i -g firebase-tools`, `firebase login`, `dart pub global activate flutterfire_cli`, `flutterfire configure` (this overwrites `lib/firebase_options.dart`).
5. Deploy rules: `cd firebase`, `firebase use YOUR_PROJECT_ID`, `firebase deploy --only firestore:rules`.
6. In `android/app/build.gradle(.kts)` make sure `minSdk` is at least 23.
7. Icon and splash commands from section 7, then `flutter run`.
8. Share an APK: `flutter build apk --release` (file in `build/app/outputs/flutter-apk/`). Friends must allow "install unknown apps". For a store release you need your own signing key (keep it out of Git) and a developer account (Google Play about US$25 once, Apple about US$99 per year, unverified).

Open the **project folder that contains `pubspec.yaml`** in Android Studio, not its parent or the `android` subfolder.

## 10. Git and secrets checklist

Add to `.gitignore` before the first commit:
```
lib/firebase_options.dart
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
firebase.json
.firebaserc
.env
android/key.properties
*.jks
*.keystore
```
(`firebase/firestore.rules` must stay committed.) Anyone who clones the project runs `flutterfire configure` to recreate the ignored files.

Before pushing, both commands should print nothing:
```
git ls-files | Select-String "firebase_options|google-services|GoogleService|\.jks|\.keystore|key\.properties|\.env"
git grep -n "AIza"
```
Ignoring a file does not remove it from history if it was committed earlier: run `git rm --cached FILE` and commit; treat a leaked signing key as compromised.

## 11. Troubleshooting

| Problem | Cause and fix |
|---|---|
| Red cross on the `main.dart` run configuration, "Entrypoint isn't within the current project" | Android Studio opened the wrong folder. Close the project, delete the `.idea` folder, then Open the folder that contains `pubspec.yaml` |
| App crashes on start with `REPLACE_ME` / Firebase errors | `flutterfire configure` has not been run (placeholder `firebase_options.dart`) |
| `The getter 'ltr' isn't defined for the type 'TextDirection'` | `intl` exports its own `TextDirection`. Import it as `import 'package:intl/intl.dart' show DateFormat;` |
| "`value` is deprecated" on colours | Use `color.toARGB32()` |
| Permission denied / data not saving | Security rules not deployed or you are signed out: `firebase deploy --only firestore:rules` |
| No verification email | Check Spam and Promotions (Firebase's default sender is often filtered); the email can take a minute; many Resend taps get throttled (`too-many-requests`); check Authentication > Templates is enabled |
| "Offline or syncing" shows although online | Fixed by listening to metadata changes; update to the latest code |
| Faint lines across the icon picker or flicker | Likely a GPU / Impeller glitch. Add `<meta-data android:name="io.flutter.embedding.android.EnableImpeller" android:value="false"/>` inside `<application>` in `AndroidManifest.xml`, then stop and re-run (hot reload is not enough). Also check Developer options: "Pointer location" and "Show touches" |
| Vertical list is laggy | Test in release mode; the grid is already painted by one painter |
| App icon did not change | Run `dart run flutter_launcher_icons`, `flutter clean`, **uninstall the app**, run again. Do not delete `ic_launcher` by hand |
| New font or asset not showing | Check `pubspec.yaml` indentation, run `flutter pub get`, do a full restart (not hot reload) |
| `flutter` not found in the IDE terminal | Add Flutter's `bin` folder to PATH or set the SDK path in Android Studio > Settings > Languages & Frameworks > Flutter |
| `git push` rejected | The remote has newer commits: `git pull --rebase origin main`, then push again |

## 12. Costs and limits
Everything used is free at small scale (Spark plan, no card needed). Unverified figures to confirm on the official pricing page: Firestore free quota about 1 GiB storage, 50,000 reads/day, 20,000 writes/day, 20,000 deletes/day. With about 10 habits and about 5 check-ins per user per day, that is roughly 1,500–2,500 daily active users (an estimate, not a guarantee); a 50-user app is far below it. When a quota is exceeded on Spark, requests fail until it resets (no surprise bill). Cloud Functions, managed backups and scheduled exports need the paid Blaze plan, which is why account deletion runs inside the app. Subscriptions and store fees are out of scope for the current version.

## 13. Testing status
- `test/habit_test.dart`: date keys and streak logic (current streak, best streak, gaps, today not yet checked).
- Everything else has been checked by hand on one Android phone only.
- Not tested: automated UI tests, Firestore rules unit tests (the Firebase Emulator Suite is the recommended next step), iOS builds, accessibility audit, performance measurements.

## 14. Known limitations and ideas
- Verification emails come from Firebase's default sender and often land in spam.
- "Today" uses the phone's local date; travelling across time zones can shift it by a day.
- Logout keeps Firestore's local cache; on a shared phone clear the app data.
- No backups on the free plan; the JSON export is manual.
- No App Check yet, so a leaked API key could be used to create accounts: restrict the key.
- Not included: reminders, home-screen widget, drag-to-reorder, notes per day, per-habit statistics screen, Google or Apple sign-in, subscriptions, tablet layouts.
- Ideas for later: Firebase Emulator tests for the rules, App Check, scheduled export on Blaze, a streak/stat detail screen.

## Credits and licenses
Habidz is released under the MIT License (see `LICENSE`). Krona One by Sorkin Type Co is under the SIL Open Font License 1.1 (`assets/fonts/OFL.txt`). Flutter, Firebase and the packages listed in section 2 are used under their own licenses.
