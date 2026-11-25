import 'package:shared_preferences/shared_preferences.dart';

import 'package:maak_metro/features/settings/domain/settings_repository.dart';

const _localeKey = 'locale';
const _themeModeKey = 'theme_mode';
const _onboardedKey = 'onboarded';

class PreferencesSettingsRepository implements SettingsRepository {
  PreferencesSettingsRepository(this._preferences);

  final SharedPreferences _preferences;

  @override
  AppSettings load() => (
    languageCode: _preferences.getString(_localeKey) == 'en' ? 'en' : 'ar',
    brightness: switch (_preferences.getString(_themeModeKey)) {
      'light' => AppBrightness.light,
      'dark' => AppBrightness.dark,
      _ => AppBrightness.system,
    },
    onboarded: _preferences.getBool(_onboardedKey) ?? false,
  );

  @override
  Future<void> saveLanguage(String languageCode) async {
    if (!await _preferences.setString(_localeKey, languageCode)) {
      throw StateError('Could not save the language preference.');
    }
  }

  @override
  Future<void> saveBrightness(AppBrightness brightness) async {
    if (!await _preferences.setString(_themeModeKey, brightness.name)) {
      throw StateError('Could not save the theme preference.');
    }
  }

  @override
  Future<void> completeOnboarding() async {
    if (!await _preferences.setBool(_onboardedKey, true)) {
      throw StateError('Could not save onboarding completion.');
    }
  }
}
