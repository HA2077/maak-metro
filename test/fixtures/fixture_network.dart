import 'package:maak_metro/domain/models/models.dart';

const _lines = [
  Line(id: 1, nameAr: 'Line 1', nameEn: 'Line 1', colorHex: '#1E63B8'),
  Line(id: 2, nameAr: 'Line 2', nameEn: 'Line 2', colorHex: '#D01F2F'),
  Line(id: 3, nameAr: 'Line 3', nameEn: 'Line 3', colorHex: '#3A9E4D'),
];

Station _station(String id) =>
    Station(id: id, nameAr: 'محطة $id', nameEn: 'Station $id');

final _stations = [
  for (final id in [
    's1',
    's2',
    'x',
    's4',
    's5',
    't1',
    't2',
    't4',
    'm1',
    'k',
    'p1',
    'p2',
    'q1',
    'q2',
    'q3',
    'iso',
  ])
    _station(id),
];

const _branches = [
  LineBranch(lineId: 3, branch: 'br_a', startsAfter: 'k'),
  LineBranch(lineId: 3, branch: 'br_b', startsAfter: 'k'),
];

const _lineStations = [
  LineStation(lineId: 1, stationId: 's1', branch: 'main', seq: 1),
  LineStation(lineId: 1, stationId: 's2', branch: 'main', seq: 2),
  LineStation(lineId: 1, stationId: 'x', branch: 'main', seq: 3),
  LineStation(lineId: 1, stationId: 's4', branch: 'main', seq: 4),
  LineStation(lineId: 1, stationId: 's5', branch: 'main', seq: 5),
  LineStation(lineId: 2, stationId: 't1', branch: 'main', seq: 1),
  LineStation(lineId: 2, stationId: 't2', branch: 'main', seq: 2),
  LineStation(lineId: 2, stationId: 'x', branch: 'main', seq: 3),
  LineStation(lineId: 2, stationId: 't4', branch: 'main', seq: 4),
  LineStation(lineId: 3, stationId: 'm1', branch: 'main', seq: 1),
  LineStation(lineId: 3, stationId: 's4', branch: 'main', seq: 2),
  LineStation(lineId: 3, stationId: 'k', branch: 'main', seq: 3),
  LineStation(lineId: 3, stationId: 'p1', branch: 'br_a', seq: 1),
  LineStation(lineId: 3, stationId: 'p2', branch: 'br_a', seq: 2),
  LineStation(lineId: 3, stationId: 'q1', branch: 'br_b', seq: 1),
  LineStation(lineId: 3, stationId: 'q2', branch: 'br_b', seq: 2),
  LineStation(lineId: 3, stationId: 'q3', branch: 'br_b', seq: 3),
];

const _fares = [
  FareBracket(maxStations: 9, priceEgp: 10),
  FareBracket(maxStations: 16, priceEgp: 12),
  FareBracket(maxStations: 23, priceEgp: 15),
  FareBracket(maxStations: 39, priceEgp: 20),
];

NetworkData buildFixtureNetwork() => NetworkData(
  lines: _lines,
  stations: _stations,
  branches: _branches,
  lineStations: _lineStations,
  fares: _fares,
  snapshotDate: 'test',
);
