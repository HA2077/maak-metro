import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maak_metro/features/settings/domain/settings_repository.dart';

class SettingsState {
  const SettingsState(this._settings);

  final AppSettings _settings;

  Locale get locale => Locale(_settings.languageCode);

  TextDirection get textDirection =>
      _settings.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  ThemeMode get themeMode => switch (_settings.brightness) {
    AppBrightness.system => ThemeMode.system,
    AppBrightness.light => ThemeMode.light,
    AppBrightness.dark => ThemeMode.dark,
  };

  bool get onboarded => _settings.onboarded;
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(SettingsState(_repository.load()));

  final SettingsRepository _repository;

  Future<void> setLocale(Locale locale) async {
    final code = locale.languageCode == 'en' ? 'en' : 'ar';
    await _repository.saveLanguage(code);
    if (isClosed) return;
    emit(
      SettingsState((
        languageCode: code,
        brightness: state._settings.brightness,
        onboarded: state.onboarded,
      )),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final brightness = switch (mode) {
      ThemeMode.system => AppBrightness.system,
      ThemeMode.light => AppBrightness.light,
      ThemeMode.dark => AppBrightness.dark,
    };
    await _repository.saveBrightness(brightness);
    if (isClosed) return;
    emit(
      SettingsState((
        languageCode: state._settings.languageCode,
        brightness: brightness,
        onboarded: state.onboarded,
      )),
    );
  }

  Future<void> completeOnboarding() async {
    await _repository.completeOnboarding();
    if (isClosed) return;
    emit(
      SettingsState((
        languageCode: state._settings.languageCode,
        brightness: state._settings.brightness,
        onboarded: true,
      )),
    );
  }
}
