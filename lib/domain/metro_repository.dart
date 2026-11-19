import 'package:maak_metro/domain/models/metro_models.dart';

/// Storage contract. The UI only ever talks to this interface, so the engine
/// under it can move from SQLite to anything else.
abstract class MetroRepository {
  Future<NetworkData> loadNetwork();
  Future<List<FavoriteRoute>> getFavorites();
  Future<void> addFavorite(String fromId, String toId);
  Future<void> removeFavorite(int id);
  Future<List<HistoryEntry>> getHistory({int limit = 50});
  Future<void> addHistory(String fromId, String toId);
  Future<void> clearHistory();
}
