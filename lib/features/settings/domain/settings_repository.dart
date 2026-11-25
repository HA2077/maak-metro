enum AppBrightness { system, light, dark }

typedef AppSettings = ({
  String languageCode,
  AppBrightness brightness,
  bool onboarded,
});

abstract interface class SettingsRepository {
  AppSettings load();

  Future<void> saveLanguage(String languageCode);

  Future<void> saveBrightness(AppBrightness brightness);

  Future<void> completeOnboarding();
}
