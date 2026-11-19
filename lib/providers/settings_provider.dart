import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Arabic is the default; language and appearance are remembered across
/// restarts. scaffold: PROV-1 owns this provider, the surface follows the plan.
class SettingsProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';
  static const String _themeKey = 'theme_mode';

  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.system;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null && code != _locale.languageCode) {
      _locale = Locale(code);
    }
    final mode = prefs.getString(_themeKey);
    if (mode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (value) => value.name == mode,
        orElse: () => ThemeMode.system,
      );
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == _locale.languageCode) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }
}
