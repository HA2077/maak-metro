class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.searchedAt,
  });

  final int id;
  final String fromId;
  final String toId;
  final DateTime searchedAt;
}
