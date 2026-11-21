import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

const _seedPath = 'assets/metro_seed.json';

const _requiredKeys = <String>[
  'version',
  'snapshot_date',
  'lines',
  'stations',
  'line_branches',
  'line_stations',
  'fares',
];

final _hexPattern = RegExp(r'^#[0-9A-Fa-f]{6}$');
final _stationIdPattern = RegExp(r'^[a-z0-9_]+$');

Map<String, Object?> _readSeed() =>
    jsonDecode(File(_seedPath).readAsStringSync()) as Map<String, Object?>;

void _check(bool condition, String message) {
  if (!condition) fail(message);
}

Map<String, Object?> _object(Object? value, String label) {
  _check(value is Map<String, Object?>, '$label must be an object');
  return value as Map<String, Object?>;
}

List<Object?> _array(Object? value, String label) {
  _check(value is List<Object?>, '$label must be a list');
  return value as List<Object?>;
}

int _integer(Object? value, String label) {
  _check(value is int, '$label must be an int, got $value');
  return value as int;
}

String _text(Object? value, String label) {
  _check(
    value is String && value.trim().isNotEmpty,
    '$label must be a non-empty string, got $value',
  );
  return value as String;
}

bool _sameNumbers(List<int> actual, List<int> expected) {
  if (actual.length != expected.length) return false;
  for (var i = 0; i < actual.length; i++) {
    if (actual[i] != expected[i]) return false;
  }
  return true;
}

void _validate(Map<String, Object?> seed) {
  for (final key in _requiredKeys) {
    _check(seed.containsKey(key), 'seed is missing "$key"');
  }

  final version = seed['version'];
  _check(
    version is int && version >= 1,
    'seed.version must be an int >= 1, got $version',
  );
  _text(seed['snapshot_date'], 'seed.snapshot_date');

  final lines = _array(seed['lines'], 'seed.lines');
  final stations = _array(seed['stations'], 'seed.stations');
  final branches = _array(seed['line_branches'], 'seed.line_branches');
  final lineStations = _array(seed['line_stations'], 'seed.line_stations');
  final fares = _array(seed['fares'], 'seed.fares');

  final lineIds = <int>{};
  for (var i = 0; i < lines.length; i++) {
    final row = _object(lines[i], 'lines[$i]');
    final id = _integer(row['id'], 'lines[$i].id');
    final label = 'lines[id=$id]';
    _check(lineIds.add(id), '$label id is duplicated');
    _text(row['name_ar'], '$label.name_ar');
    _text(row['name_en'], '$label.name_en');
    final color = _text(row['color_hex'], '$label.color_hex');
    _check(
      _hexPattern.hasMatch(color),
      '$label.color_hex "$color" must match ^#[0-9A-Fa-f]{6}\$',
    );
  }

  final stationIds = <String>{};
  final englishNames = <String, String>{};
  for (var i = 0; i < stations.length; i++) {
    final row = _object(stations[i], 'stations[$i]');
    final id = _text(row['id'], 'stations[$i].id');
    final label = 'stations[id=$id]';
    _check(
      _stationIdPattern.hasMatch(id),
      '$label.id "$id" must match ^[a-z0-9_]+\$',
    );
    _check(stationIds.add(id), '$label id is duplicated');
    _text(row['name_ar'], '$label.name_ar');
    final nameEn = _text(row['name_en'], '$label.name_en');
    final previousId = englishNames[nameEn];
    if (previousId == null) {
      englishNames[nameEn] = id;
    } else if (previousId != id) {
      debugPrint(
        'Warning: stations[id=$previousId] and $label share English name "$nameEn"',
      );
    }
  }

  final lineStationPairs = <String>{};
  final usedStations = <String>{};
  final mainRows = <String>{};
  final usedBranches = <String>{};
  final seqByGroup = <String, List<int>>{};
  final groupLabels = <String, String>{};
  final lineIdsByStation = <String, Set<int>>{};

  for (var i = 0; i < lineStations.length; i++) {
    final row = _object(lineStations[i], 'line_stations[$i]');
    final lineId = _integer(row['line_id'], 'line_stations[$i].line_id');
    final stationId = _text(row['station_id'], 'line_stations[$i].station_id');
    final branch = _text(row['branch'], 'line_stations[$i].branch');
    final seq = _integer(row['seq'], 'line_stations[$i].seq');
    final label =
        'line_stations[line_id=$lineId, station_id=$stationId, branch=$branch, seq=$seq]';

    _check(
      lineIds.contains(lineId),
      '$label references unknown line_id $lineId',
    );
    _check(
      stationIds.contains(stationId),
      '$label references unknown station_id "$stationId"',
    );
    _check(
      lineStationPairs.add('$lineId:$stationId'),
      '$label duplicates (line_id, station_id) $lineId:$stationId',
    );

    usedStations.add(stationId);
    lineIdsByStation.putIfAbsent(stationId, () => <int>{}).add(lineId);

    final groupKey = '$lineId:$branch';
    groupLabels.putIfAbsent(
      groupKey,
      () => 'line_stations[line_id=$lineId, branch=$branch]',
    );
    seqByGroup.putIfAbsent(groupKey, () => <int>[]).add(seq);
    if (branch == 'main') {
      mainRows.add('$lineId:$stationId');
    } else {
      usedBranches.add(groupKey);
    }
  }

  for (final entry in seqByGroup.entries) {
    final actual = [...entry.value]..sort();
    final expected = List<int>.generate(
      entry.value.length,
      (index) => index + 1,
    );
    _check(
      _sameNumbers(actual, expected),
      '${groupLabels[entry.key]} seq must be exactly 1..${entry.value.length}, got $actual',
    );
  }

  for (final entry in lineIdsByStation.entries) {
    if (entry.value.length > 2) {
      final ids = entry.value.toList()..sort();
      debugPrint(
        'Warning: stations[id=${entry.key}] is used on ${ids.length} lines: $ids',
      );
    }
  }

  final declaredBranches = <String>{};
  for (var i = 0; i < branches.length; i++) {
    final row = _object(branches[i], 'line_branches[$i]');
    final lineId = _integer(row['line_id'], 'line_branches[$i].line_id');
    final branch = _text(row['branch'], 'line_branches[$i].branch');
    final startsAfter = _text(
      row['starts_after'],
      'line_branches[$i].starts_after',
    );
    final label = 'line_branches[line_id=$lineId, branch=$branch]';

    _check(
      lineIds.contains(lineId),
      '$label references unknown line_id $lineId',
    );
    _check(
      stationIds.contains(startsAfter),
      '$label references unknown starts_after "$startsAfter"',
    );
    _check(
      mainRows.contains('$lineId:$startsAfter'),
      '$label starts_after "$startsAfter" is not on line $lineId main branch',
    );
    _check(declaredBranches.add('$lineId:$branch'), '$label is duplicated');
  }

  for (final branchKey in usedBranches.difference(declaredBranches)) {
    _check(false, '${groupLabels[branchKey]} has no line_branches entry');
  }
  for (final branchKey in declaredBranches.difference(usedBranches)) {
    final parts = branchKey.split(':');
    _check(
      false,
      'line_branches[line_id=${parts.first}, branch=${parts.last}] has no non-main line_stations rows',
    );
  }

  for (final id in stationIds.difference(usedStations)) {
    _check(false, 'stations[id=$id] is not used by any line_stations row');
  }

  _check(fares.isNotEmpty, 'seed.fares must contain at least one bracket');
  var previousMax = 0;
  var previousPrice = 0;
  for (var i = 0; i < fares.length; i++) {
    final row = _object(fares[i], 'fares[$i]');
    final maxStations = _integer(row['max_stations'], 'fares[$i].max_stations');
    final price = _integer(row['price_egp'], 'fares[$i].price_egp');
    final label = 'fares[$i]';

    _check(
      maxStations > 0,
      '$label.max_stations must be positive, got $maxStations',
    );
    _check(price > 0, '$label.price_egp must be positive, got $price');
    if (i > 0) {
      _check(
        maxStations > previousMax,
        '$label.max_stations must be strictly increasing: $maxStations after $previousMax',
      );
      _check(
        price >= previousPrice,
        '$label.price_egp must be non-decreasing: $price after $previousPrice',
      );
    }
    previousMax = maxStations;
    previousPrice = price;
  }
}

Map<String, Object?> _fixtureSeed() => <String, Object?>{
  'version': 1,
  'snapshot_date': '2026-01-01',
  'lines': <Object?>[
    <String, Object?>{
      'id': 1,
      'name_ar': 'خط',
      'name_en': 'Line 1',
      'color_hex': '#123456',
    },
  ],
  'stations': <Object?>[
    <String, Object?>{'id': 'a', 'name_ar': 'أ', 'name_en': 'A'},
    <String, Object?>{'id': 'b', 'name_ar': 'ب', 'name_en': 'B'},
    <String, Object?>{'id': 'c', 'name_ar': 'ج', 'name_en': 'C'},
  ],
  'line_branches': <Object?>[],
  'line_stations': <Object?>[
    <String, Object?>{
      'line_id': 1,
      'station_id': 'a',
      'branch': 'main',
      'seq': 1,
    },
    <String, Object?>{
      'line_id': 1,
      'station_id': 'b',
      'branch': 'main',
      'seq': 2,
    },
    <String, Object?>{
      'line_id': 1,
      'station_id': 'c',
      'branch': 'main',
      'seq': 3,
    },
  ],
  'fares': <Object?>[
    <String, Object?>{'max_stations': 1, 'price_egp': 1},
  ],
};

void _expectFailure(Map<String, Object?> seed, String messageSnippet) {
  Object? error;
  try {
    _validate(seed);
  } catch (caught) {
    error = caught;
  }
  expect(error, isNotNull, reason: 'expected validation to fail');
  expect(error.toString(), contains(messageSnippet));
}

void main() {
  final seed = _readSeed();
  final version = seed['version'];

  test(
    'metro_seed.json is valid',
    () => _validate(seed),
    skip: version == 0
        ? 'assets/metro_seed.json is version 0 (stub); validation skipped'
        : false,
  );

  group('seed validator', () {
    test('reports a seq gap with the exact group', () {
      final seed = _fixtureSeed();
      final rows = _array(seed['line_stations'], 'fixture.line_stations');
      _object(rows[2], 'fixture.line_stations[2]')['seq'] = 4;

      _expectFailure(
        seed,
        'line_stations[line_id=1, branch=main] seq must be exactly 1..3, got [1, 2, 4]',
      );
    });

    test('reports a missing station reference', () {
      final seed = _fixtureSeed();
      final rows = _array(seed['line_stations'], 'fixture.line_stations');
      _object(rows[2], 'fixture.line_stations[2]')['station_id'] = 'missing';

      _expectFailure(
        seed,
        'line_stations[line_id=1, station_id=missing, branch=main, seq=3] references unknown station_id "missing"',
      );
    });

    test('reports a bad hex colour', () {
      final seed = _fixtureSeed();
      final lines = _array(seed['lines'], 'fixture.lines');
      _object(lines[0], 'fixture.lines[0]')['color_hex'] = '#XYZ123';

      _expectFailure(
        seed,
        'lines[id=1].color_hex "#XYZ123" must match ^#[0-9A-Fa-f]{6}\$',
      );
    });
  });
}
