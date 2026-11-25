import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maak_metro/core/constants.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/fade_slide_in.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/utils/digits.dart';
import 'package:maak_metro/features/network/presentation/network_cubit.dart';
import 'package:maak_metro/features/settings/presentation/widgets/date_text.dart';

import 'settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = context.watch<SettingsCubit>().state;
    final network = context.select((NetworkCubit cubit) => cubit.state.network);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(AppSpace.xl),
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
                onSelectionChanged: (selection) =>
                    context.read<SettingsCubit>().setLocale(selection.first),
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
                onSelectionChanged: (selection) =>
                    context.read<SettingsCubit>().setThemeMode(selection.first),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          FadeSlideIn(
            index: 2,
            child: _Section(
              title: l10n.about,
              child: Card(
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
                            'assets/images/logo.png',
                            width: 104,
                            height: 104,
                            excludeFromSemantics: true,
                          ),
                          const SizedBox(height: AppSpace.md),
                          Text(
                            l10n.appName,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.versionLabel(
                              localizedDigits(context, AppConstants.appVersion),
                            ),
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
                      title: Text(l10n.dataSnapshotTitle),
                      trailing: network == null
                          ? null
                          : DateText(network.snapshotDate),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.payments_outlined),
                      title: Text(l10n.fareEffectiveTitle),
                      trailing: DateText(AppConstants.fareEffectiveFrom),
                    ),
                  ],
                ),
              ),
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
          padding: const EdgeInsetsDirectional.only(bottom: AppSpace.md),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
