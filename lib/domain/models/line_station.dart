class LineStation {
  const LineStation({
    required this.lineId,
    required this.stationId,
    required this.branch,
    required this.seq,
  });

  factory LineStation.fromJson(Map<String, Object?> json) => LineStation(
    lineId: json['line_id'] as int,
    stationId: json['station_id'] as String,
    branch: json['branch'] as String,
    seq: json['seq'] as int,
  );

  final int lineId;
  final String stationId;
  final String branch;
  final int seq;
}
