import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maak_metro/features/settings/data/preferences_settings_repository.dart';
import 'package:maak_metro/features/settings/presentation/settings_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a fresh install opens in Arabic, follows the system and has not '
      'onboarded', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final settings = SettingsCubit(
      PreferencesSettingsRepository(await SharedPreferences.getInstance()),
    );

    addTearDown(settings.close);

    expect(settings.state.locale, const Locale('ar'));
    expect(settings.state.textDirection, TextDirection.rtl);
    expect(settings.state.themeMode, ThemeMode.system);
    expect(settings.state.onboarded, isFalse);
  });

  test('the first run and the theme choice survive a restart', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final first = SettingsCubit(
      PreferencesSettingsRepository(await SharedPreferences.getInstance()),
    );

    await first.setLocale(const Locale('en'));
    await first.setThemeMode(ThemeMode.dark);
    await first.completeOnboarding();
    await first.close();
    SharedPreferences.resetStatic();

    final second = SettingsCubit(
      PreferencesSettingsRepository(await SharedPreferences.getInstance()),
    );
    addTearDown(second.close);

    expect(second.state.locale, const Locale('en'));
    expect(second.state.themeMode, ThemeMode.dark);
    expect(second.state.onboarded, isTrue);
  });

  test('an unknown stored theme falls back to the system', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'theme_mode': 'hotdog',
    });
    final settings = SettingsCubit(
      PreferencesSettingsRepository(await SharedPreferences.getInstance()),
    );

    addTearDown(settings.close);

    expect(settings.state.themeMode, ThemeMode.system);
  });
}
