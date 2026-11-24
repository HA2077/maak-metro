import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_haptics.dart';
import 'package:maak_metro/core/motion/fade_indexed_stack.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/screens/library_screen.dart';
import 'package:maak_metro/screens/lines_screen.dart';
import 'package:maak_metro/screens/planner_screen.dart';
import 'package:maak_metro/screens/settings_screen.dart';

/// Bottom bar on phones, side rail on tablets. The four tabs live in a
/// [FadeIndexedStack], so switching keeps their scroll position and state.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  /// Index of the Planner tab.
  static const int plannerIndex = 0;

  /// Switches to the Planner tab from any tab that can reach this state.
  static void openPlanner(BuildContext context) {
    context.findAncestorStateOfType<HomeShellState>()?.select(plannerIndex);
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= AppLayout.railBreakpoint;
        if (wide) {
          final extended =
              constraints.maxWidth >= AppLayout.extendedRailBreakpoint;
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: extended,
                  selectedIndex: _index,
                  onDestinationSelected: select,
                  labelType: extended ? null : NavigationRailLabelType.all,
                  destinations: [
                    for (final (icon, selectedIcon, label) in [
                      (Icons.alt_route, Icons.alt_route, l10n.tabPlanner),
                      (Icons.subway_outlined, Icons.subway, l10n.tabLines),
                      (Icons.bookmark_border, Icons.bookmark, l10n.tabLibrary),
                      (
                        Icons.settings_outlined,
                        Icons.settings,
                        l10n.tabSettings,
                      ),
                    ])
                      NavigationRailDestination(
                        icon: Icon(icon),
                        selectedIcon: Icon(selectedIcon),
                        label: Text(label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _tabs()),
              ],
            ),
          );
        }

        return Scaffold(
          body: _tabs(),
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
}
