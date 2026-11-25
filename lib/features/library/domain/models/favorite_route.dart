class FavoriteRoute {
  const FavoriteRoute({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.createdAt,
  });

  final int id;
  final String fromId;
  final String toId;
  final DateTime createdAt;
}
