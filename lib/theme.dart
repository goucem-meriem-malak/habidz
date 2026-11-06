import 'package:flutter/material.dart';

ThemeData _build(ColorScheme cs, Color bg) => ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg, foregroundColor: cs.onSurface, elevation: 0, scrolledUnderElevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary, foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );

final ThemeData lightTheme = _build(
  const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF111111), onPrimary: Colors.white,
    secondary: Color(0xFF57606A), onSecondary: Colors.white,
    error: Color(0xFFCF222E), onError: Colors.white,
    surface: Colors.white, onSurface: Color(0xFF1F2328),
  ),
  const Color(0xFFF6F8FA),
);

final ThemeData darkTheme = _build(
  const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF0F6FC), onPrimary: Color(0xFF0D1117),
    secondary: Color(0xFF8B949E), onSecondary: Color(0xFF0D1117),
    error: Color(0xFFFF7B72), onError: Color(0xFF0D1117),
    surface: Color(0xFF161B22), onSurface: Color(0xFFE6EDF3),
  ),
  const Color(0xFF0D1117),
);

final ThemeData purpleTheme = _build(
  const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFB388FF), onPrimary: Color(0xFF1A0B33),
    secondary: Color(0xFF9575CD), onSecondary: Color(0xFF1A0B33),
    error: Color(0xFFFF8A80), onError: Color(0xFF1A0B33),
    surface: Color(0xFF211338), onSurface: Color(0xFFF1E9FF),
  ),
  const Color(0xFF140B26),
);

/// Habit color choices. `null` = automatic (theme accent: black/white/lavender).
const List<Color> habitPalette = [
  Color(0xFF2EA043), Color(0xFF1F6FEB), Color(0xFF8957E5), Color(0xFFDB61A2),
  Color(0xFFF85149), Color(0xFFF0883E), Color(0xFFD29922), Color(0xFF39C5CF),
  Color(0xFF3FB950), Color(0xFFA371F7),
];

const Map<String, IconData> habitIcons = {
  'check': Icons.check_circle_outline, 'run': Icons.directions_run, 'book': Icons.menu_book,
  'water': Icons.water_drop_outlined, 'sleep': Icons.bedtime_outlined, 'gym': Icons.fitness_center,
  'meditate': Icons.self_improvement, 'code': Icons.code, 'music': Icons.music_note,
  'write': Icons.edit_note, 'food': Icons.restaurant, 'no_smoke': Icons.smoke_free,
  'walk': Icons.directions_walk, 'bike': Icons.directions_bike, 'study': Icons.school_outlined,
  'pray': Icons.mosque_outlined, 'heart': Icons.favorite_border, 'sun': Icons.wb_sunny_outlined,
  'clean': Icons.cleaning_services_outlined, 'money': Icons.savings_outlined,
  'phone_off': Icons.phone_disabled_outlined, 'plant': Icons.eco_outlined,
  'art': Icons.brush_outlined, 'language': Icons.translate, 'call': Icons.call_outlined,
  'tooth': Icons.clean_hands_outlined, 'pill': Icons.medication_outlined,
  'star': Icons.star_border, 'bolt': Icons.bolt, 'coffee': Icons.local_cafe_outlined,
};
