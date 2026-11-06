# Habidz — GitHub-grid habit tracker (Flutter + Firebase free plan)

Features: email/password accounts (verify + reset), profile, change password, delete account,
habits with icon/color, vertical habit list with a horizontally-scrolling GitHub-style grid,
one-tap check, streaks, offline use (Firestore on-device cache), themes (system/light/dark/premium purple),
English / Français / العربية with RTL, JSON data export.

> STATUS: source written but **not yet compiled or run** (the authoring sandbox had no Flutter SDK).
> Expect to fix a few small compile issues on first build. Run `flutter analyze` and `flutter test` first.

## 1. Setup (about 15 minutes, all free)
1. Install Flutter (stable) and Android Studio (Android SDK). Run `flutter doctor`.
2. In this folder generate the native Android/iOS folders (keeps existing `lib/` and `pubspec.yaml`):
   ```
   flutter create --platforms=android,ios --project-name habidz --org com.habidz .
   ```
   If it replaced `lib/main.dart`, restore it from the zip.
3. Create a Firebase project at console.firebase.google.com (stay on the free **Spark** plan, no card):
   - Authentication → Sign-in method → enable **Email/Password**.
   - Authentication → Settings → keep "Email enumeration protection" ON.
   - Firestore Database → Create database (production mode, any region near your users).
4. Connect the app (this OVERWRITES `lib/firebase_options.dart`):
   ```
   npm i -g firebase-tools && firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
5. Publish the security rules (REQUIRED — without them your data is not protected):
   ```
   cd firebase && firebase use <your-project-id> && firebase deploy --only firestore:rules
   ```
6. Android: in `android/app/build.gradle(.kts)` set `minSdk = 23` (Firebase requirement) if it is lower.
7. Run: `flutter pub get && flutter run`. Build an APK to share: `flutter build apk --release`.
   (Release signing: see flutter.dev/to/android-deploy. For ~50 users you can send the APK directly.)
   iOS builds need a Mac + Xcode.

## 2. How it works
- Data: `users/{uid}/habits/{habitId}` and `.../years/{yyyy}` with a map `days: {"MM-DD": true}`.
  One tap = one small write; a grid loads from 2 documents.
- Offline: Firestore keeps a local database and queues writes; the banner shows when data is
  not yet confirmed by the server. Sign-up, first login, password change, reset, export-from-server
  and account deletion need internet.
- Security: users can only touch their own `users/{uid}/**` (see `firebase/firestore.rules`);
  passwords are handled only by Firebase Auth; no analytics, no secrets in the app.
  `firebase_options.dart` contains public client identifiers, not secrets.
- Account deletion: re-authenticates, deletes all habit data, then the Auth user (no paid server code needed).
- Free-tier limits (verify on firebase.google.com/pricing): ~50 users is far below them.

## 3. Known limitations / deviations from the plan
- Not compiled/tested yet (see status). `test/habit_test.dart` covers streak logic only.
- Logout does not wipe Firestore's local cache (the SDK cannot clear it while running). Cached data is only
  readable by the same signed-in user path; for a shared phone, uninstall/clear app data.
- App Check and Crashlytics from the plan are NOT included (optional; add later if needed).
- No reminders, widgets, reorder-by-drag (habits are ordered by creation).
- "Today" uses the phone's local date.
- No tested backup; the in-app JSON export (copied to clipboard) is a manual export only.
