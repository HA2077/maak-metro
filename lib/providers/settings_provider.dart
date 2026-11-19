import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Arabic is the default; the choice is remembered across restarts.
/// scaffold: PROV-1 owns this provider. API mirrors the plan (locale,
/// setLocale) so it can be replaced without touching screens.
class SettingsProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';

  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code == null || code == _locale.languageCode) return;
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == _locale.languageCode) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}
