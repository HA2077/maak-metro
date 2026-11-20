class RouteLeg {
  const RouteLeg({
    required this.lineId,
    required this.branch,
    required this.stationIds,
  });

  final int lineId;
  final String branch;
  final List<String> stationIds;
}
