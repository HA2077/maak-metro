import 'models/fare_bracket.dart';

class FareCalculator {
  const FareCalculator(this.brackets, {this.countBoardingStation = true});

  final List<FareBracket> brackets;
  final bool countBoardingStation;

  int fareFor(int stationCount) {
    if (brackets.isEmpty) throw StateError('No fare brackets');

    final n = countBoardingStation ? stationCount + 1 : stationCount;
    if (n <= 0) return brackets.first.priceEgp;

    for (final bracket in brackets) {
      if (n <= bracket.maxStations) return bracket.priceEgp;
    }
    return brackets.last.priceEgp;
  }
}
