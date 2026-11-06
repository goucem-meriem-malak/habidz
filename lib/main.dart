import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'auth_screen.dart';
import 'firebase_options.dart';
import 'home_screen.dart';
import 'l10n.dart';
import 'settings.dart';
import 'splash_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await settings.load();
  runApp(const HabidzApp());
}

class HabidzApp extends StatelessWidget {
  const HabidzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final purple = settings.theme == 'purple';
        return MaterialApp(
          title: 'Habidz',
          debugShowCheckedModeBanner: false,
          locale: Locale(settings.lang),
          supportedLocales: supportedLangs.map(Locale.new).toList(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: purple ? purpleTheme : lightTheme,
          darkTheme: purple ? purpleTheme : darkTheme,
          themeMode: switch (settings.theme) {
            'light' || 'purple' => ThemeMode.light,
            'dark' => ThemeMode.dark,
            _ => ThemeMode.system,
          },
          home: const SplashScreen(next: AuthGate()),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snap.data == null ? const AuthScreen() : const HomeScreen();
      },
    );
  }
}
