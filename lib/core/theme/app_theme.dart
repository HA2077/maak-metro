import 'package:flutter/material.dart';

/// Spacing scale in logical pixels. Use with directional insets so the same
/// values work in Arabic (RTL) and English (LTR).
abstract final class AppSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class AppRadius {
  static const double field = 14;
  static const double card = 16;
  static const double sheet = 28;
}

/// One light theme for the whole app.
///
/// The seed is a near-black ink on purpose: the only saturated colour in the
/// product is a metro line colour, and those come from the database, so the
/// chrome must stay out of their way.
abstract final class AppTheme {
  static const Color seed = Color(0xFF1B2A38);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    final text = base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.5,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.secondaryContainer,
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
          textStyle: text.labelLarge?.copyWith(fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpace.lg,
          vertical: AppSpace.md,
        ),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(scheme.primary, 1.6),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpace.lg,
        ),
        minVerticalPadding: AppSpace.md,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
    );
  }
}
