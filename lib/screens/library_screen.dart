import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/domain/domain.dart';
import 'package:maak_metro/providers/library_provider.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/screens/route_result_screen.dart';
import 'package:maak_metro/widgets/summary_stat.dart';
import 'package:provider/provider.dart';

/// Saved routes and recent searches, in two tabs.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.libraryTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.favorites),
              Tab(text: l10n.history),
            ],
          ),
        ),
        body: const TabBarView(children: [_FavoritesTab(), _HistoryTab()]),
      ),
    );
  }
}

/// Opens the result screen for a stored pair without recording a new history
/// entry.
Future<void> _openPair(
  BuildContext context,
  NetworkData network,
  String fromId,
  String toId,
) async {
  final route = context.read<RouteProvider>();
  final from = network.stationById(fromId);
  final to = network.stationById(toId);
  if (from == null || to == null) return;

  route.setFrom(from);
  route.setTo(to);
  final found = await route.calculate(saveToHistory: false);
  if (!found || !context.mounted) return;
  await Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const RouteResultScreen()));
}

/// Renders "From ← To" in the active language, or null when either station is
/// no longer in the network.
String? _pairLabel(
  BuildContext context,
  NetworkData network,
  String fromId,
  String toId,
) {
  final from = network.stationById(fromId);
  final to = network.stationById(toId);
  if (from == null || to == null) return null;
  final language = Localizations.localeOf(context).languageCode;
  return '${from.localizedName(language)} ← ${to.localizedName(language)}';
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final network = context.watch<RouteProvider>().network;
    final library = context.watch<LibraryProvider>();

    if (network == null) {
      return EmptyHint(icon: Icons.bookmark_border, message: l10n.loadError);
    }
    if (library.favorites.isEmpty) {
      return EmptyHint(icon: Icons.star_border, message: l10n.noFavorites);
    }

    return ListView.separated(
      itemCount: library.favorites.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final favorite = library.favorites[index];
        final label = _pairLabel(
          context,
          network,
          favorite.fromId,
          favorite.toId,
        );
        if (label == null) return const SizedBox.shrink();

        return Dismissible(
          key: ValueKey('favorite-${favorite.id}'),
          direction: DismissDirection.horizontal,
          background: const _DeleteBackground(),
          secondaryBackground: const _DeleteBackground(),
          onDismissed: (_) => library.removeFavorite(favorite.id),
          child: ListTile(
            leading: const Icon(Icons.star),
            title: Text(label),
            onTap: () =>
                _openPair(context, network, favorite.fromId, favorite.toId),
          ),
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final network = context.watch<RouteProvider>().network;
    final library = context.watch<LibraryProvider>();

    if (network == null) {
      return EmptyHint(icon: Icons.history, message: l10n.loadError);
    }
    if (library.history.isEmpty) {
      return EmptyHint(icon: Icons.history, message: l10n.noHistory);
    }

    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpace.lg,
              vertical: AppSpace.sm,
            ),
            child: TextButton.icon(
              onPressed: () => _confirmClear(context, library),
              icon: const Icon(Icons.delete_sweep_outlined),
              label: Text(l10n.clearHistory),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: library.history.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = library.history[index];
              final label = _pairLabel(
                context,
                network,
                entry.fromId,
                entry.toId,
              );
              if (label == null) return const SizedBox.shrink();

              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(label),
                onTap: () =>
                    _openPair(context, network, entry.fromId, entry.toId),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    LibraryProvider library,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.clearHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await library.clearHistory();
    }
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.errorContainer,
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(end: AppSpace.lg),
      child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
    );
  }
}
