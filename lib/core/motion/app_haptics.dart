import 'package:flutter/services.dart';

/// Short taps the user can feel. The OS silence and haptics settings still win;
/// these are fire-and-forget and never block the interaction.
abstract final class AppHaptics {
  /// A selection moved: tab switch, row picked, language changed.
  static void tap() => HapticFeedback.selectionClick();

  /// Something happened: swap, delete, favourite.
  static void action() => HapticFeedback.lightImpact();

  /// A result arrived: route calculated, station set.
  static void confirm() => HapticFeedback.mediumImpact();
}
