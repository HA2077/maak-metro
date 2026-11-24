import 'models/models.dart';

abstract class MetroRepository {
  Future<NetworkData> loadNetwork();

  Future<List<FavoriteRoute>> getFavorites();

  Future<bool> isFavorite(String fromId, String toId);

  Future<void> addFavorite(String fromId, String toId);

  Future<void> removeFavorite(int id);

  Future<void> removeFavoriteByPair(String fromId, String toId);

  Future<List<HistoryEntry>> getHistory({int limit = 50});

  Future<void> addHistory(String fromId, String toId);

  Future<void> removeHistory(int id);

  Future<void> clearHistory();
}
