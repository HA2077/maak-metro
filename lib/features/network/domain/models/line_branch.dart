class LineBranch {
  const LineBranch({
    required this.lineId,
    required this.branch,
    required this.startsAfter,
    this.terminusAr = '',
    this.terminusEn = '',
  });

  factory LineBranch.fromJson(Map<String, Object?> json) => LineBranch(
    lineId: json['line_id'] as int,
    branch: json['branch'] as String,
    startsAfter: json['starts_after'] as String,
    terminusAr: json['terminus_ar'] as String? ?? '',
    terminusEn: json['terminus_en'] as String? ?? '',
  );

  final int lineId;
  final String branch;
  final String startsAfter;
  final String terminusAr;
  final String terminusEn;
}
