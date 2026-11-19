import 'package:flutter/foundation.dart';
import 'package:maak_metro/domain/metro_repository.dart';
import 'package:maak_metro/domain/models/metro_models.dart';

/// scaffold: PROV-3 owns this provider. Same surface the screens use in the
/// plan (favorites, history, toggle, clear), backed by [MetroRepository].
class LibraryProvider extends ChangeNotifier {
  LibraryProvider({required this.repository});

  final MetroRepository repository;
  List<FavoriteRoute> _favorites = const [];
  List<HistoryEntry> _history = const [];

  List<FavoriteRoute> get favorites => _favorites;
  List<HistoryEntry> get history => _history;

  bool isFavorite(String fromId, String toId) =>
      _favorites.any((f) => f.fromId == fromId && f.toId == toId);

  Future<void> refresh() async {
    _favorites = await repository.getFavorites();
    _history = await repository.getHistory();
    notifyListeners();
  }

  Future<void> toggleFavorite(String fromId, String toId) async {
    final existing = _favorites.where(
      (f) => f.fromId == fromId && f.toId == toId,
    );
    if (existing.isEmpty) {
      await repository.addFavorite(fromId, toId);
    } else {
      await repository.removeFavorite(existing.first.id);
    }
    await refresh();
  }

  Future<void> removeFavorite(int id) async {
    await repository.removeFavorite(id);
    await refresh();
  }

  Future<void> clearHistory() async {
    await repository.clearHistory();
    await refresh();
  }
}
