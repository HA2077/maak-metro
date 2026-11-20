class Station {
  const Station({required this.id, required this.nameAr, required this.nameEn});

  factory Station.fromJson(Map<String, Object?> json) => Station(
    id: json['id'] as String,
    nameAr: json['name_ar'] as String,
    nameEn: json['name_en'] as String,
  );

  final String id;
  final String nameAr;
  final String nameEn;

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;
}
