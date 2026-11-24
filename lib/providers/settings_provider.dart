import 'dart:ui' show Locale, TextDirection;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'locale';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs);

  final SharedPreferences _prefs;

  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  Future<void> load() async {
    _locale = Locale(_prefs.getString(_localeKey) == 'en' ? 'en' : 'ar');
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
}
