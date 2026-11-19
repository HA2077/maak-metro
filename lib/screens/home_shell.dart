import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/screens/library_screen.dart';
import 'package:maak_metro/screens/lines_screen.dart';
import 'package:maak_metro/screens/planner_screen.dart';
import 'package:maak_metro/screens/settings_screen.dart';

/// Bottom-bar host. The four tabs live in an [IndexedStack], so switching tabs
/// keeps their scroll position and state.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

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
    return Scaffold(
      body: IndexedStack(
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
