import 'package:flutter/material.dart';
import 'package:maak_metro/core/constants.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
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
          Text(
            l10n.language,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          SegmentedButton<Locale>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
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
            onSelectionChanged: (selection) =>
                settings.setLocale(selection.first),
          ),
          const SizedBox(height: AppSpace.xl),
          Text(
            l10n.about,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpace.sm),
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
                    l10n.dataSnapshot(snapshot.isEmpty ? '\u2014' : snapshot),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: Text(l10n.fareEffective(fareEffectiveDate)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
