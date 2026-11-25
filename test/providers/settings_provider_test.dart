import 'dart:ui' show Locale, TextDirection;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefsWith([
  Map<String, Object> values = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  group('SettingsProvider', () {
    test('defaults to Arabic and RTL', () async {
      final provider = SettingsProvider(await _prefsWith());

      expect(provider.locale, const Locale('ar'));
      expect(provider.isArabic, isTrue);
      expect(provider.textDirection, TextDirection.rtl);
    });

    test('load reads a stored English locale and notifies', () async {
      final provider = SettingsProvider(
        await _prefsWith(<String, Object>{'locale': 'en'}),
      );
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.load();

      expect(provider.locale, const Locale('en'));
      expect(provider.isArabic, isFalse);
      expect(provider.textDirection, TextDirection.ltr);
      expect(notifications, 1);
    });

    test('load falls back to Arabic for unknown or missing values', () async {
      final unknown = SettingsProvider(
        await _prefsWith(<String, Object>{'locale': 'fr'}),
      );
      await unknown.load();
      expect(unknown.locale, const Locale('ar'));
      expect(unknown.textDirection, TextDirection.rtl);

      final missing = SettingsProvider(await _prefsWith());
      await missing.load();
      expect(missing.locale, const Locale('ar'));
    });

    test('setLocale persists, notifies and survives a restart', () async {
      final prefs = await _prefsWith();
      final provider = SettingsProvider(prefs);
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.setLocale(const Locale('en'));

      expect(prefs.getString('locale'), 'en');
      expect(provider.locale, const Locale('en'));
      expect(provider.textDirection, TextDirection.ltr);
      expect(notifications, 1);

      await prefs.reload();
      final restored = SettingsProvider(prefs);
      await restored.load();
      expect(restored.locale, const Locale('en'));
    });

    test('setLocale normalizes unsupported languages to Arabic', () async {
      final prefs = await _prefsWith();
      final provider = SettingsProvider(prefs);

      await provider.setLocale(const Locale('fr'));

      expect(prefs.getString('locale'), 'ar');
      expect(provider.locale, const Locale('ar'));
    });

    test('toggle flips locale, direction and stored value', () async {
      final prefs = await _prefsWith();
      final provider = SettingsProvider(prefs);
      await provider.load();
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.toggle();

      expect(provider.locale, const Locale('en'));
      expect(provider.textDirection, TextDirection.ltr);
      expect(prefs.getString('locale'), 'en');
      expect(notifications, 1);

      await provider.toggle();

      expect(provider.locale, const Locale('ar'));
      expect(provider.isArabic, isTrue);
      expect(provider.textDirection, TextDirection.rtl);
      expect(prefs.getString('locale'), 'ar');
      expect(notifications, 2);
    });
  });

  group('first run and appearance', () {
    test('a fresh install follows the system and has not onboarded', () async {
      final provider = SettingsProvider(await _prefsWith());

      await provider.load();

      expect(provider.themeMode, ThemeMode.system);
      expect(provider.onboarded, isFalse);
    });

    test(
      'the theme choice and the finished first run survive a restart',
      () async {
        final prefs = await _prefsWith();
        final first = SettingsProvider(prefs);
        await first.load();

        await first.setThemeMode(ThemeMode.dark);
        await first.completeOnboarding();

        await prefs.reload();
        final second = SettingsProvider(prefs);
        await second.load();

        expect(second.themeMode, ThemeMode.dark);
        expect(second.onboarded, isTrue);
      },
    );

    test('an unknown stored theme falls back to the system', () async {
      final provider = SettingsProvider(
        await _prefsWith(<String, Object>{'theme_mode': 'hotdog'}),
      );

      await provider.load();

      expect(provider.themeMode, ThemeMode.system);
    });
  });
}
