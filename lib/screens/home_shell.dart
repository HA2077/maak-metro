import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/providers/library_provider.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/screens/library_screen.dart';
import 'package:maak_metro/screens/lines_screen.dart';
import 'package:maak_metro/screens/planner_screen.dart';
import 'package:maak_metro/screens/settings_screen.dart';
import 'package:provider/provider.dart';

/// Bottom-bar host. The four tabs live in an [IndexedStack], so switching tabs
/// keeps their scroll position and state.
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
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loadFailed = context.watch<RouteProvider>().loadFailed;
    return Scaffold(
      body: loadFailed
          ? const _LoadFailure()
          : IndexedStack(
              index: _index,
              children: const [
                PlannerScreen(),
                LinesScreen(),
                LibraryScreen(),
                SettingsScreen(),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: select,
        destinations: [
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
        ],
      ),
    );
  }
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
