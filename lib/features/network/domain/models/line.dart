class Line {
  const Line({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.colorHex,
    this.terminusAAr = '',
    this.terminusAEn = '',
    this.terminusBAr = '',
    this.terminusBEn = '',
  });

  factory Line.fromJson(Map<String, Object?> json) => Line(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String,
    nameEn: json['name_en'] as String,
    colorHex: json['color_hex'] as String,
    terminusAAr: json['terminus_a_ar'] as String? ?? '',
    terminusAEn: json['terminus_a_en'] as String? ?? '',
    terminusBAr: json['terminus_b_ar'] as String? ?? '',
    terminusBEn: json['terminus_b_en'] as String? ?? '',
  );

  final int id;
  final String nameAr;
  final String nameEn;
  final String colorHex;
  final String terminusAAr;
  final String terminusAEn;
  final String terminusBAr;
  final String terminusBEn;

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;
}
