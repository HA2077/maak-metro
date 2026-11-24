import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_motion.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/providers/settings_provider.dart';
import 'package:maak_metro/screens/home_shell.dart';
import 'package:provider/provider.dart';

const _delegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

class MaakMetroApp extends StatelessWidget {
  const MaakMetroApp({super.key, this.startupError, this.onRetry});

  final Object? startupError;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final startup = startupError;
    if (startup != null) {
      return _errorApp(startup, onRetry ?? () async {});
    }

    final settings = context.watch<SettingsProvider>();
    final route = context.watch<RouteProvider>();
    final initError = route.initError;
    if (initError != null) {
      return _errorApp(initError, route.init);
    }

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      themeAnimationDuration: AppMotion.of(context, AppMotion.slow),
      themeAnimationCurve: AppMotion.standard,
      locale: settings.locale,
      localizationsDelegates: _delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => Directionality(
        textDirection: settings.textDirection,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const HomeShell(),
    );
  }

  Widget _errorApp(Object error, Future<void> Function() retry) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).loadError,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: _delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _ErrorScreen(error: error, retry: retry),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error, required this.retry});

  final Object error;
  final Future<void> Function() retry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.loadError)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(
                l10n.loadError,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(error.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(onPressed: retry, child: Text(l10n.retry)),
            ],
          ),
        ),
      ),
    );
  }
}
