import 'dart:ui' show Locale, TextDirection;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'locale';
const _themeModeKey = 'theme_mode';
const _onboardedKey = 'onboarded';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs);

  final SharedPreferences _prefs;

  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.system;
  bool _onboarded = false;

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  /// Follows the system until the reader picks otherwise.
  ThemeMode get themeMode => _themeMode;

  /// False until the first run has been answered, so the tabs never open in a
  /// language or a brightness the reader did not choose.
  bool get onboarded => _onboarded;

  Future<void> load() async {
    _locale = Locale(_prefs.getString(_localeKey) == 'en' ? 'en' : 'ar');
    _themeMode = switch (_prefs.getString(_themeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _onboarded = _prefs.getBool(_onboardedKey) ?? false;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final languageCode = locale.languageCode == 'en' ? 'en' : 'ar';
    await _prefs.setString(_localeKey, languageCode);
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> toggle() =>
      setLocale(isArabic ? const Locale('en') : const Locale('ar'));

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name);
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardedKey, true);
    _onboarded = true;
    notifyListeners();
  }
}
