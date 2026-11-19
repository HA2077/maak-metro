import 'package:flutter/material.dart';
import 'package:maak_metro/core/motion/app_motion.dart';

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
  static const double field = 16;
  static const double card = 20;
  static const double sheet = 28;
}

/// Widest the reading column gets on tablets and foldables. Phones ignore it.
abstract final class AppLayout {
  static const double maxContentWidth = 720;
  static const double railBreakpoint = 720;
  static const double extendedRailBreakpoint = 1080;
}

/// Transit blue for every action, map neutral for every surface. The only
/// saturated colour that belongs to content is a metro line colour, which comes
/// from the database, so the chrome stays one hue.
abstract final class AppTheme {
  static const String fontFamily = 'IBM Plex Sans Arabic';

  static const Color seed = Color(0xFF2563EB);

  static final ColorScheme lightScheme = ColorScheme.fromSeed(seedColor: seed)
      .copyWith(
        primary: const Color(0xFF1D4ED8),
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFDCE7FF),
        onPrimaryContainer: const Color(0xFF0B2559),
        secondary: const Color(0xFF0E7490),
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFD5F1F7),
        onSecondaryContainer: const Color(0xFF063741),
        tertiary: const Color(0xFF9A5B00),
        onTertiary: Colors.white,
        tertiaryContainer: const Color(0xFFFFE2BA),
        onTertiaryContainer: const Color(0xFF2E1800),
        surface: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF0F172A),
        surfaceContainerLowest: const Color(0xFFFFFFFF),
        surfaceContainerLow: const Color(0xFFF6F8FC),
        surfaceContainer: const Color(0xFFF0F4FA),
        surfaceContainerHigh: const Color(0xFFE9EFF7),
        surfaceContainerHighest: const Color(0xFFE2E9F3),
        onSurfaceVariant: const Color(0xFF475569),
        outline: const Color(0xFF94A3B8),
        outlineVariant: const Color(0xFFDDE5F0),
        error: const Color(0xFFB3261E),
        onError: Colors.white,
        errorContainer: const Color(0xFFF9DEDC),
        onErrorContainer: const Color(0xFF410E0B),
        surfaceTint: Colors.transparent,
      );

  static final ColorScheme darkScheme =
      ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFF9DC0FF),
        onPrimary: const Color(0xFF06255C),
        primaryContainer: const Color(0xFF1E3A8A),
        onPrimaryContainer: const Color(0xFFDCE7FF),
        secondary: const Color(0xFF5FD3E8),
        onSecondary: const Color(0xFF00363F),
        secondaryContainer: const Color(0xFF0B4A57),
        onSecondaryContainer: const Color(0xFFB8ECF7),
        tertiary: const Color(0xFFF3BE7A),
        onTertiary: const Color(0xFF3E2600),
        tertiaryContainer: const Color(0xFF5B3A00),
        onTertiaryContainer: const Color(0xFFFFE2BA),
        surface: const Color(0xFF0F1826),
        onSurface: const Color(0xFFE6EDF7),
        surfaceContainerLowest: const Color(0xFF080F1A),
        surfaceContainerLow: const Color(0xFF121C2C),
        surfaceContainer: const Color(0xFF162234),
        surfaceContainerHigh: const Color(0xFF1B2A3F),
        surfaceContainerHighest: const Color(0xFF22334B),
        onSurfaceVariant: const Color(0xFFA6B6CC),
        outline: const Color(0xFF52658A),
        outlineVariant: const Color(0xFF22304A),
        error: const Color(0xFFFFB4AB),
        onError: const Color(0xFF690005),
        errorContainer: const Color(0xFF93000A),
        onErrorContainer: const Color(0xFFFFDAD6),
        surfaceTint: Colors.transparent,
      );

  static ThemeData get light => _build(lightScheme, dark: false);

  static ThemeData get dark => _build(darkScheme, dark: true);

  /// Figures that keep their width while they animate, so a count-up does not
  /// shuffle the text left and right.
  static TextStyle? numeric(TextStyle? style) =>
      style?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  static ThemeData _build(ColorScheme scheme, {required bool dark}) {
    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: dark ? Brightness.dark : Brightness.light,
    );
    final text = _textTheme(base.textTheme);
    final canvas = dark ? scheme.surface : scheme.surfaceContainerLow;
    final card = dark ? scheme.surfaceContainerLow : scheme.surface;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: canvas,
      canvasColor: canvas,
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: canvas,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        height: 76,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: canvas,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: text.labelLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: text.labelLarge?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
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
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          disabledBackgroundColor: scheme.surfaceContainerHighest,
          disabledForegroundColor: scheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
          textStyle: text.labelLarge?.copyWith(fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.primaryContainer
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurface,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: scheme.outline)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        hintStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(scheme.primary, 1.6),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
        minVerticalPadding: 14,
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        dividerColor: scheme.outlineVariant,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: text.labelLarge?.copyWith(color: scheme.onSurface),
        shape: const StadiumBorder(),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        collapsedIconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        collapsedTextColor: scheme.onSurface,
        shape: const Border(),
        collapsedShape: const Border(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: card,
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.fuchsia: AppPageTransitionsBuilder(),
          TargetPlatform.windows: AppPageTransitionsBuilder(),
          TargetPlatform.linux: AppPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Arabic sits taller than Latin at the same size, so line heights are
  /// generous and letterspacing is zero.
  static TextTheme _textTheme(TextTheme base) {
    TextStyle? at(
      TextStyle? style,
      double size,
      double height, [
      FontWeight weight = FontWeight.w400,
    ]) => style?.copyWith(
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      letterSpacing: 0,
    );

    return base.copyWith(
      displaySmall: at(base.displaySmall, 36, 48, FontWeight.w700),
      headlineMedium: at(base.headlineMedium, 30, 40, FontWeight.w700),
      headlineSmall: at(base.headlineSmall, 26, 34, FontWeight.w700),
      titleLarge: at(base.titleLarge, 21, 30, FontWeight.w700),
      titleMedium: at(base.titleMedium, 17, 26, FontWeight.w600),
      titleSmall: at(base.titleSmall, 15, 23, FontWeight.w600),
      bodyLarge: at(base.bodyLarge, 17, 28),
      bodyMedium: at(base.bodyMedium, 15, 25),
      bodySmall: at(base.bodySmall, 13, 21),
      labelLarge: at(base.labelLarge, 15, 22, FontWeight.w600),
      labelMedium: at(base.labelMedium, 13, 19, FontWeight.w600),
      labelSmall: at(base.labelSmall, 12, 17, FontWeight.w600),
    );
  }
}
