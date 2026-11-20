class LineBranch {
  const LineBranch({
    required this.lineId,
    required this.branch,
    required this.startsAfter,
  });

  factory LineBranch.fromJson(Map<String, Object?> json) => LineBranch(
    lineId: json['line_id'] as int,
    branch: json['branch'] as String,
    startsAfter: json['starts_after'] as String,
  );

  final int lineId;
  final String branch;
  final String startsAfter;
}
