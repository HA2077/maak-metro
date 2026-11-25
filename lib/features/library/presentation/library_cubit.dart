import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maak_metro/features/library/domain/library_repository.dart';
import 'package:maak_metro/features/library/domain/models/favorite_route.dart';
import 'package:maak_metro/features/library/domain/models/history_entry.dart';

class LibraryState {
  const LibraryState._(this.favorites, this.history);

  final List<FavoriteRoute> favorites;
  final List<HistoryEntry> history;

  List<HistoryEntry> get recentSearches {
    final pairs = <(String, String)>{};
    return history
        .where((entry) => pairs.add((entry.fromId, entry.toId)))
        .take(3)
        .toList(growable: false);
  }

  bool isFavorite(String fromId, String toId) =>
      favorites.any((entry) => entry.fromId == fromId && entry.toId == toId);
}

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(this._repository) : super(const LibraryState._([], []));

  final LibraryRepository _repository;

  Future<void> _pendingOperation = Future<void>.value();

  Future<void> refresh() => _update();

  Future<void> recordSearch(String fromId, String toId) =>
      _update(() => _repository.addHistory(fromId, toId));

  Future<void> toggleFavorite(String fromId, String toId) {
    if (fromId == toId) return Future<void>.value();
    return _update(() async {
      if (await _repository.isFavorite(fromId, toId)) {
        await _repository.removeFavoriteByPair(fromId, toId);
      } else {
        await _repository.addFavorite(fromId, toId);
      }
    });
  }

  Future<void> removeFavorite(int id) =>
      _update(() => _repository.removeFavorite(id));

  Future<void> removeHistory(int id) =>
      _update(() => _repository.removeHistory(id));

  Future<void> clearHistory() => _update(_repository.clearHistory);

  Future<void> _update([Future<void> Function()? action]) {
    final operation = _pendingOperation.then((_) async {
      await action?.call();
      final favorites = await _repository.getFavorites();
      final history = await _repository.getHistory();
      if (!isClosed) {
        emit(
          LibraryState._(
            List.unmodifiable(favorites),
            List.unmodifiable(history),
          ),
        );
      }
    });
    // Keep the queue usable after a failed write. The caller receives the error.
    _pendingOperation = operation.then<void>((_) {}, onError: (Object _) {});
    return operation;
  }
}
