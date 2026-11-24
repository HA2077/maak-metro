import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_haptics.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/providers/settings_provider.dart';
import 'package:provider/provider.dart';

/// First launch only: language and appearance before the tabs, so the rest of
/// the app opens in the reader's own settings.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(AppSpace.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo.webp',
                      width: 120,
                      height: 120,
                      excludeFromSemantics: true,
                    ),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  Text(
                    l10n.onboardingTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    l10n.onboardingBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  SegmentedButton<Locale>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: const Locale('ar'),
                        label: Text(l10n.arabic),
                      ),
                      ButtonSegment(
                        value: const Locale('en'),
                        label: Text(l10n.english),
                      ),
                    ],
                    selected: {settings.locale},
                    onSelectionChanged: (selection) {
                      AppHaptics.tap();
                      settings.setLocale(selection.first);
                    },
                  ),
                  const SizedBox(height: AppSpace.md),
                  SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(l10n.themeSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(l10n.themeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(l10n.themeDark),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (selection) {
                      AppHaptics.tap();
                      settings.setThemeMode(selection.first);
                    },
                  ),
                  const SizedBox(height: AppSpace.xl),
                  FilledButton(
                    onPressed: () {
                      AppHaptics.action();
                      settings.completeOnboarding();
                    },
                    child: Text(l10n.onboardingStart),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
