class FareBracket {
  const FareBracket({
    required this.maxStations,
    required this.priceEgp,
    this.ticketColor = '',
  });

  factory FareBracket.fromJson(Map<String, Object?> json) => FareBracket(
    maxStations: json['max_stations'] as int,
    priceEgp: json['price_egp'] as int,
    ticketColor: json['ticket_color'] as String? ?? '',
  );

  final int maxStations;
  final int priceEgp;
  final String ticketColor;
}
