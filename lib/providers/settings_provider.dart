import 'package:flutter/material.dart';
import 'package:maak_metro/core/utils/dates.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Arabic is the default; language and appearance are remembered across
/// restarts. scaffold: PROV-1 owns this provider, the surface follows the plan.
class SettingsProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';
  static const String _themeKey = 'theme_mode';
  static const String _onboardedKey = 'onboarded';
  static const String _dateStyleKey = 'date_style';

  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.system;
  DateStyle _dateStyle = DateStyle.numeric;

  /// Assume an existing user until [load] says otherwise: only a real stored
  /// "false" (or a fresh install) sends anyone back to the intro.
  bool _onboarded = true;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  DateStyle get dateStyle => _dateStyle;
  bool get onboarded => _onboarded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _onboarded = prefs.getBool(_onboardedKey) ?? false;
    final dateStyle = prefs.getString(_dateStyleKey);
    if (dateStyle != null) {
      _dateStyle = DateStyle.values.firstWhere(
        (value) => value.name == dateStyle,
        orElse: () => DateStyle.numeric,
      );
    }
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

  Future<void> setDateStyle(DateStyle style) async {
    if (style == _dateStyle) return;
    _dateStyle = style;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dateStyleKey, style.name);
  }

  Future<void> completeOnboarding() async {
    if (_onboarded) return;
    _onboarded = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardedKey, true);
  }
}
