import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_haptics.dart';
import 'package:maak_metro/core/motion/fade_indexed_stack.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/providers/library_provider.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/screens/library_screen.dart';
import 'package:maak_metro/screens/lines_screen.dart';
import 'package:maak_metro/screens/planner_screen.dart';
import 'package:maak_metro/screens/settings_screen.dart';
import 'package:provider/provider.dart';

/// Bottom bar on phones, side rail on tablets. The four tabs live in a
/// [FadeIndexedStack], so switching keeps their scroll position and state.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  /// Screens that move the user to another tab (the station sheet, opening a
  /// saved route) reach the shell through this.
  static HomeShellState of(BuildContext context) {
    final shell = context.findAncestorStateOfType<HomeShellState>();
    assert(shell != null, 'HomeShell is not an ancestor of this context');
    return shell!;
  }

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  int _index = 0;

  void select(int index) {
    if (index == _index) return;
    AppHaptics.tap();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loadFailed = context.watch<RouteProvider>().loadFailed;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= AppLayout.railBreakpoint;
        final content = loadFailed ? const _LoadFailure() : _tabs();

        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended:
                      constraints.maxWidth >= AppLayout.extendedRailBreakpoint,
                  selectedIndex: _index,
                  onDestinationSelected: select,
                  labelType:
                      constraints.maxWidth >= AppLayout.extendedRailBreakpoint
                      ? null
                      : NavigationRailLabelType.all,
                  destinations: _railDestinations(l10n),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: content),
              ],
            ),
          );
        }

        return Scaffold(
          body: content,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: select,
            destinations: _barDestinations(l10n),
          ),
        );
      },
    );
  }

  Widget _tabs() => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
      child: FadeIndexedStack(
        index: _index,
        children: const [
          PlannerScreen(),
          LinesScreen(),
          LibraryScreen(),
          SettingsScreen(),
        ],
      ),
    ),
  );

  List<NavigationDestination> _barDestinations(AppLocalizations l10n) => [
    NavigationDestination(
      icon: const Icon(Icons.alt_route),
      label: l10n.tabPlanner,
    ),
    NavigationDestination(
      icon: const Icon(Icons.subway_outlined),
      selectedIcon: const Icon(Icons.subway),
      label: l10n.tabLines,
    ),
    NavigationDestination(
      icon: const Icon(Icons.bookmark_border),
      selectedIcon: const Icon(Icons.bookmark),
      label: l10n.tabLibrary,
    ),
    NavigationDestination(
      icon: const Icon(Icons.settings_outlined),
      selectedIcon: const Icon(Icons.settings),
      label: l10n.tabSettings,
    ),
  ];

  List<NavigationRailDestination> _railDestinations(AppLocalizations l10n) => [
    for (final (icon, selectedIcon, label) in [
      (Icons.alt_route, Icons.alt_route, l10n.tabPlanner),
      (Icons.subway_outlined, Icons.subway, l10n.tabLines),
      (Icons.bookmark_border, Icons.bookmark, l10n.tabLibrary),
      (Icons.settings_outlined, Icons.settings, l10n.tabSettings),
    ])
      NavigationRailDestination(
        icon: Icon(icon),
        selectedIcon: Icon(selectedIcon),
        label: Text(label),
      ),
  ];
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.loadError,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.read<RouteProvider>().load();
                context.read<LibraryProvider>().refresh();
              },
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
