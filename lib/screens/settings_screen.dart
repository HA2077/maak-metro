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
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: AppSpace.xl,
                          bottom: AppSpace.lg,
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/logo.webp',
                              width: 104,
                              height: 104,
                              excludeFromSemantics: true,
                            ),
                            const SizedBox(height: AppSpace.md),
                            Text(
                              l10n.appName,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.versionLabel(appVersion),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.event_outlined),
                        title: Text(l10n.dataSnapshot),
                        trailing: _date(context, snapshot),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.payments_outlined),
                        title: Text(l10n.fareEffective),
                        trailing: _date(context, fareEffectiveDate),
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

/// Drops a leading zero: an Arabic-Indic zero is a dot, and ٠٣ reads as a
/// decimal point next to the ٣.
String _plain(String value) => int.tryParse(value)?.toString() ?? value;

/// Day first in the reading order: in Arabic the day sits at the right, so the
/// row runs right-to-left as day, month, year. Each field is its own text
/// because Arabic-Indic numbers are one right-to-left run and bidi would
/// reorder the three fields inside a single string.
Widget _date(BuildContext context, String isoDate) {
  final theme = Theme.of(context);
  final style = theme.textTheme.bodyLarge?.copyWith(
    fontWeight: FontWeight.w600,
  );
  final parts = isoDate.split('-');
  if (parts.length != 3) {
    return Text(isoDate.isEmpty ? '\u2014' : isoDate, style: style);
  }
  final day = localizedDigits(context, _plain(parts[2]));
  final month = localizedDigits(context, _plain(parts[1]));
  final year = localizedDigits(context, _plain(parts[0]));
  final arabic = Localizations.localeOf(context).languageCode == 'ar';

  return Row(
    mainAxisSize: MainAxisSize.min,
    textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
    children: [
      Text(day, style: style),
      Text('-', style: style),
      Text(month, style: style),
      Text('-', style: style),
      Text(year, style: style),
    ],
  );
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
