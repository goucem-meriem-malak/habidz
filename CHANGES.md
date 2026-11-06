# Update 1 - changed files only
Copy these into your project (same paths, overwrite):
- assets/logo.png, assets/logo_splash.png   (NEW - your logo)
- lib/splash_screen.dart                    (NEW - animated splash)
- lib/main.dart                             (starts with the splash)
- lib/home_screen.dart                      (offline banner fix, clearer resend-email errors)
- lib/habit_repo.dart                       (offline flag now updates when the server confirms)
- lib/habit_editor.dart                     (keyboard closes when you scroll/pick an icon; toARGB32 fix)
- pubspec.yaml                              (assets + splash/icon config; if you changed yours, merge by hand)

Then in the project folder:
  flutter pub get
  dart run flutter_native_splash:create
  dart run flutter_launcher_icons
  flutter run
