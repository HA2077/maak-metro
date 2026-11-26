/// App-wide constants that are not user facing and must not be localised.
abstract final class AppConstants {
  /// The date the Cairo Metro fare brackets last changed tariff.
  ///
  /// Mirrors `fare_brackets.effective_from` in `assets/metro_seed.json`. Shown on
  /// the Settings screen next to the fare. Update both places together.
  static const String fareEffectiveFrom = '2026-03-27';

  /// Shown in the About card. Keep in step with `version:` in pubspec.yaml.
  static const String appVersion = '1.0.7';
}
