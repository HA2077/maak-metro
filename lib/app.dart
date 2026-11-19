import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_motion.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/providers/settings_provider.dart';
import 'package:maak_metro/screens/home_shell.dart';
import 'package:provider/provider.dart';

class MaakMetroApp extends StatelessWidget {
  const MaakMetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      themeAnimationDuration: AppMotion.of(context, AppMotion.slow),
      themeAnimationCurve: AppMotion.standard,
      locale: settings.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeShell(),
    );
  }
}
