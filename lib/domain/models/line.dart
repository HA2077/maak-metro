class Line {
  const Line({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.colorHex,
  });

  factory Line.fromJson(Map<String, Object?> json) => Line(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String,
    nameEn: json['name_en'] as String,
    colorHex: json['color_hex'] as String,
  );

  final int id;
  final String nameAr;
  final String nameEn;
  final String colorHex;

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;
}
