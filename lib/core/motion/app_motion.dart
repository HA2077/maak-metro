import 'package:flutter/material.dart';

/// One place for every duration and curve. Entrances decelerate, exits
/// accelerate, and nothing loops unless it is a loader.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 280);
  static const Duration page = Duration(milliseconds: 320);

  /// Number count-ups: slower than a transition so the change can be read.
  static const Duration counter = Duration(milliseconds: 800);

  /// Material 3 emphasized easing.
  static const Curve decelerate = Cubic(0.05, 0.7, 0.1, 1);
  static const Curve accelerate = Cubic(0.3, 0, 0.8, 0.15);
  static const Curve standard = Cubic(0.2, 0, 0, 1);

  /// Distance between staggered list items.
  static const Duration stagger = Duration(milliseconds: 40);

  /// True when the system asks for reduced motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Collapses [duration] to zero under reduced motion.
  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;

  /// Delay before item [index] starts entering; capped so a long list never
  /// feels slow.
  static Duration delayFor(BuildContext context, int index) {
    if (reduced(context)) return Duration.zero;
    const maxIndex = 5;
    return stagger * (index > maxIndex ? maxIndex : index);
  }
}

/// The app's push transition: a short fade with 8dp of upward travel. Cheaper
/// to read than the platform default and it never slides the whole width.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppMotion.page;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AppMotion.reduced(context)) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.decelerate,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
