import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_motion.dart';
import 'package:maak_metro/core/presentation/web_device_preview.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/features/network/presentation/network_cubit.dart';
import 'package:maak_metro/features/settings/presentation/onboarding_screen.dart';
import 'package:maak_metro/features/settings/presentation/settings_cubit.dart';

import 'home_shell.dart';

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

    final settings = context.watch<SettingsCubit>().state;
    final initError = context.select((NetworkCubit cubit) => cubit.state.error);
    if (initError != null) {
      return _errorApp(initError, context.read<NetworkCubit>().load);
    }

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      themeAnimationDuration: AppMotion.of(context, AppMotion.slow),
      themeAnimationCurve: AppMotion.standard,
      locale: settings.locale,
      localizationsDelegates: _delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => Directionality(
        textDirection: settings.textDirection,
        child: _withDevicePreview(context, child),
      ),
      home: settings.onboarded ? const HomeShell() : const OnboardingScreen(),
    );
  }

  Widget _errorApp(Object error, Future<void> Function() retry) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).loadError,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: _delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: _withDevicePreview,
      home: _ErrorScreen(error: error, retry: retry),
    );
  }
}

Widget _withDevicePreview(BuildContext context, Widget? child) {
  final content = child ?? const SizedBox.shrink();
  if (kIsWeb && kDebugMode) {
    final controller = DevicePreview.maybeController;
    if (controller != null) {
      return WebDevicePreview(controller: controller, child: content);
    }
  }
  return content;
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
