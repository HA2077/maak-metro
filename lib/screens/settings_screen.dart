import 'package:flutter/material.dart';
import 'package:maak_metro/core/constants.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/providers/settings_provider.dart';
import 'package:provider/provider.dart';

/// Language switch and an About section with the data snapshot and fare dates.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final network = context.watch<RouteProvider>().network;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpace.md),
          SegmentedButton<Locale>(
            segments: [
              ButtonSegment<Locale>(
                value: const Locale('ar'),
                label: Text(l10n.arabic),
              ),
              ButtonSegment<Locale>(
                value: const Locale('en'),
                label: Text(l10n.english),
              ),
            ],
            selected: {settings.locale},
            onSelectionChanged: (selection) =>
                settings.setLocale(selection.first),
          ),
          const SizedBox(height: AppSpace.xxl),
          Text(l10n.about, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpace.sm),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.apps),
                  title: Text(l10n.appName),
                ),
                const Divider(height: 1),
                if (network != null)
                  ListTile(
                    leading: const Icon(Icons.dataset_outlined),
                    title: Text(l10n.dataSnapshot(network.snapshotDate)),
                  ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: Text(
                    l10n.fareEffective(AppConstants.fareEffectiveFrom),
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
