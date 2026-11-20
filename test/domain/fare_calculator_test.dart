import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/domain/fare_calculator.dart';
import 'package:maak_metro/domain/models/models.dart';

const _brackets = [
  FareBracket(maxStations: 9, priceEgp: 10),
  FareBracket(maxStations: 16, priceEgp: 12),
  FareBracket(maxStations: 23, priceEgp: 15),
  FareBracket(maxStations: 39, priceEgp: 20),
];

const _calculator = FareCalculator(_brackets);
const _calculatorWithoutBoarding = FareCalculator(
  _brackets,
  countBoardingStation: false,
);

void main() {
  test('counts the boarding station by default', () {
    const expected = {
      0: 10,
      1: 10,
      9: 12,
      10: 12,
      16: 15,
      17: 15,
      23: 20,
      24: 20,
      39: 20,
      40: 20,
    };

    for (final entry in expected.entries) {
      expect(
        _calculator.fareFor(entry.key),
        entry.value,
        reason: 'stationCount ${entry.key}',
      );
    }
  });

  test('excludes the boarding station when disabled', () {
    const expected = {
      0: 10,
      1: 10,
      9: 10,
      10: 12,
      16: 12,
      17: 15,
      23: 15,
      24: 20,
      39: 20,
      40: 20,
    };

    for (final entry in expected.entries) {
      expect(
        _calculatorWithoutBoarding.fareFor(entry.key),
        entry.value,
        reason: 'stationCount ${entry.key}',
      );
    }
  });

  test('counts the boarding station for 8 and 9 stations', () {
    expect(_calculator.fareFor(8), 10);
    expect(_calculator.fareFor(9), 12);
  });

  test('throws when there are no brackets', () {
    expect(
      () => const FareCalculator(<FareBracket>[]).fareFor(1),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'No fare brackets',
        ),
      ),
    );
  });
}
