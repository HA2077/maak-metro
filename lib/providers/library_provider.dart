import 'package:flutter/foundation.dart';

import 'package:maak_metro/domain/domain.dart';
import 'package:maak_metro/domain/metro_repository.dart';

class LibraryProvider extends ChangeNotifier {
  LibraryProvider(this._repo);

  final MetroRepository _repo;

  List<FavoriteRoute> _favorites = const <FavoriteRoute>[];
  List<HistoryEntry> _history = const <HistoryEntry>[];

  List<FavoriteRoute> get favorites => _favorites;

  List<HistoryEntry> get history => _history;

  Future<void> refresh() async {
    _favorites = await _repo.getFavorites();
    _history = await _repo.getHistory();
    notifyListeners();
  }

  Future<void> removeFavorite(int id) async {
    await _repo.removeFavorite(id);
    await refresh();
  }

  Future<void> removeHistory(int id) async {
    await _repo.removeHistory(id);
    await refresh();
  }

  Future<void> clearHistory() async {
    await _repo.clearHistory();
    await refresh();
  }
}
