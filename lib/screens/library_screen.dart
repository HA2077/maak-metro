import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_haptics.dart';
import 'package:maak_metro/core/motion/fade_slide_in.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/domain/domain.dart';
import 'package:maak_metro/providers/library_provider.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/screens/home_shell.dart';
import 'package:maak_metro/screens/route_result_screen.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  Future<void> _open(
    BuildContext context, {
    required String fromId,
    required String toId,
  }) async {
    final route = context.read<RouteProvider>();
    final network = route.network;
    if (network == null) return;
    final from = network.stationById(fromId);
    final to = network.stationById(toId);
    if (from == null || to == null) return;
    route.setFrom(from);
    route.setTo(to);
    final found = await route.calculate(saveToHistory: false);
    if (!found || !context.mounted) return;
    AppHaptics.confirm();
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RouteResultScreen()));
  }

  Future<void> _confirmClear(
    BuildContext context,
    LibraryProvider library,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: Text(l10n.clearHistory),
          content: Text(l10n.clearHistoryConfirm),
          titlePadding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 8),
          contentPadding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 20),
          actionsPadding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 10),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: scheme.error),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
    if (confirmed ?? false) {
      AppHaptics.action();
      await library.clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final library = context.watch<LibraryProvider>();
    final network = context.watch<RouteProvider>().network;
    final history = library.history;
    final favorites = library.favorites;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.libraryTitle),
          actions: [
            IconButton(
              onPressed: history.isEmpty
                  ? null
                  : () => _confirmClear(context, library, l10n),
              tooltip: l10n.clearHistory,
              iconSize: 30,
              icon: const Icon(Icons.delete_sweep),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.favorites),
              Tab(text: l10n.history),
            ],
          ),
        ),
        body: network == null
            ? const SizedBox.shrink()
            : TabBarView(
                children: [
                  favorites.isEmpty
                      ? _EmptyState(
                          icon: Icons.star_border,
                          text: l10n.noFavorites,
                        )
                      : ListView.separated(
                          padding: const EdgeInsetsDirectional.all(18),
                          itemCount: favorites.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpace.sm),
                          itemBuilder: (context, index) {
                            final favorite = favorites[index];
                            return FadeSlideIn(
                              index: index,
                              child: Dismissible(
                                key: ValueKey('favorite-${favorite.id}'),
                                direction: DismissDirection.horizontal,
                                background: const _DismissBackground(),
                                onDismissed: (_) {
                                  AppHaptics.action();
                                  library.removeFavorite(favorite.id);
                                },
                                child: _RouteTile(
                                  network: network,
                                  fromId: favorite.fromId,
                                  toId: favorite.toId,
                                  onTap: () => _open(
                                    context,
                                    fromId: favorite.fromId,
                                    toId: favorite.toId,
                                  ),
                                  onDelete: () {
                                    AppHaptics.action();
                                    library.removeFavorite(favorite.id);
                                  },
                                  deleteTooltip: l10n.removeFavorite,
                                ),
                              ),
                            );
                          },
                        ),
                  history.isEmpty
                      ? _EmptyState(icon: Icons.history, text: l10n.noHistory)
                      : ListView.separated(
                          padding: const EdgeInsetsDirectional.all(18),
                          itemCount: history.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpace.sm),
                          itemBuilder: (context, index) {
                            final entry = history[index];
                            return FadeSlideIn(
                              index: index,
                              child: Dismissible(
                                key: ValueKey('history-${entry.id}'),
                                direction: DismissDirection.horizontal,
                                background: const _DismissBackground(),
                                onDismissed: (_) {
                                  AppHaptics.action();
                                  library.removeHistory(entry.id);
                                },
                                child: _RouteTile(
                                  network: network,
                                  fromId: entry.fromId,
                                  toId: entry.toId,
                                  onTap: () => _open(
                                    context,
                                    fromId: entry.fromId,
                                    toId: entry.toId,
                                  ),
                                  onDelete: () {
                                    AppHaptics.action();
                                    library.removeHistory(entry.id);
                                  },
                                  deleteTooltip: l10n.removeFromHistory,
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
      ),
    );
  }
}

class _RouteTile extends StatelessWidget {
  const _RouteTile({
    required this.network,
    required this.fromId,
    required this.toId,
    required this.onTap,
    this.onDelete,
    this.deleteTooltip,
  });

  final NetworkData network;
  final String fromId;
  final String toId;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final String? deleteTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final delete = onDelete;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trip_origin, size: 14, color: color),
                        const SizedBox(width: AppSpace.sm),
                        Expanded(
                          child: Text(
                            stationNameById(context, network, fromId),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Row(
                      children: [
                        Icon(Icons.place, size: 14, color: color),
                        const SizedBox(width: AppSpace.sm),
                        Expanded(
                          child: Text(
                            stationNameById(context, network, toId),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (delete != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: AppSpace.xs),
              child: IconButton(
                onPressed: delete,
                tooltip: deleteTooltip,
                icon: const Icon(Icons.delete_outline),
              ),
            ),
        ],
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(end: AppSpace.xl),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpace.md),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            FilledButton.tonal(
              onPressed: () => HomeShell.openPlanner(context),
              child: Text(l10n.planTrip),
            ),
          ],
        ),
      ),
    );
  }
}
