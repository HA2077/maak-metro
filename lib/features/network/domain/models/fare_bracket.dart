class FareBracket {
  const FareBracket({required this.maxStations, required this.priceEgp});

  factory FareBracket.fromJson(Map<String, Object?> json) => FareBracket(
    maxStations: json['max_stations'] as int,
    priceEgp: json['price_egp'] as int,
  );

  final int maxStations;
  final int priceEgp;
}
