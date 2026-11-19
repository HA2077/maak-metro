import 'package:flutter/material.dart';
import 'package:maak_metro/core/constants.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_haptics.dart';
import 'package:maak_metro/core/motion/fade_slide_in.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/utils/digits.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final snapshot = context.watch<RouteProvider>().network.snapshotDate;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(AppSpace.lg),
        children: [
          FadeSlideIn(
            child: _Section(
              title: l10n.language,
              child: SegmentedButton<Locale>(
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
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          FadeSlideIn(
            index: 1,
            child: _Section(
              title: l10n.appearance,
              child: SegmentedButton<ThemeMode>(
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
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          FadeSlideIn(
            index: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSpace.xs,
                    bottom: AppSpace.sm,
                  ),
                  child: Text(
                    l10n.about,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.subway_outlined),
                        title: Text(l10n.appName),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.event_outlined),
                        title: Text(
                          l10n.dataSnapshot(
                            snapshot.isEmpty ? '\u2014' : snapshot,
                          ),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.payments_outlined),
                        title: Text(
                          localizedDigits(
                            context,
                            l10n.fareEffective(fareEffectiveDate),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: AppSpace.xs,
            bottom: AppSpace.sm,
          ),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
