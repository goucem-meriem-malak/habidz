import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n.dart';

/// Per-device preferences (theme + language). Not sensitive.
class Settings extends ChangeNotifier {
  String theme = 'system'; // system | light | dark | purple
  String lang = 'en';
  SharedPreferences? _p;

  Future<void> load() async {
    try {
      _p = await SharedPreferences.getInstance();
      theme = _p!.getString('theme') ?? 'system';
      final device = ui.PlatformDispatcher.instance.locale.languageCode;
      lang = _p!.getString('lang') ?? (supportedLangs.contains(device) ? device : 'en');
    } catch (_) {}
  }

  void setTheme(String v) {
    theme = v;
    _p?.setString('theme', v);
    notifyListeners();
  }

  void setLang(String v) {
    lang = v;
    _p?.setString('lang', v);
    notifyListeners();
  }
}

final settings = Settings();
