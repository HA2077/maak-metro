import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a fresh install opens in Arabic, follows the system and has not '
      'onboarded', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final settings = SettingsProvider(await SharedPreferences.getInstance());

    await settings.load();

    expect(settings.locale, const Locale('ar'));
    expect(settings.textDirection, TextDirection.rtl);
    expect(settings.themeMode, ThemeMode.system);
    expect(settings.onboarded, isFalse);
  });

  test('the first run and the theme choice survive a restart', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final first = SettingsProvider(await SharedPreferences.getInstance());
    await first.load();

    await first.setThemeMode(ThemeMode.dark);
    await first.completeOnboarding();

    final second = SettingsProvider(await SharedPreferences.getInstance());
    await second.load();

    expect(second.themeMode, ThemeMode.dark);
    expect(second.onboarded, isTrue);
  });

  test('an unknown stored theme falls back to the system', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'theme_mode': 'hotdog',
    });
    final settings = SettingsProvider(await SharedPreferences.getInstance());

    await settings.load();

    expect(settings.themeMode, ThemeMode.system);
  });
}
