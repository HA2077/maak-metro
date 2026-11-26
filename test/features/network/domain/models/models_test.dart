import 'package:flutter_test/flutter_test.dart';

import 'package:maak_metro/features/network/domain/models/models.dart';

const _line1 = Line(
  id: 1,
  nameAr: 'الخط الأول',
  nameEn: 'Line 1',
  colorHex: '#1E63B8',
);
const _line2 = Line(
  id: 2,
  nameAr: 'الخط الثاني',
  nameEn: 'Line 2',
  colorHex: '#D01F2F',
);
const _line3 = Line(
  id: 3,
  nameAr: 'الخط الثالث',
  nameEn: 'Line 3',
  colorHex: '#3A9E4D',
);
const _sadat = Station(id: 'sadat', nameAr: 'السادات', nameEn: 'Sadat');
const _kitKat = Station(id: 'kit_kat', nameAr: 'كيت كات', nameEn: 'Kit Kat');
const _rod1 = Station(id: 'rod_el_farag_1', nameAr: 'محطة ١', nameEn: 'Rod 1');
const _rod2 = Station(id: 'rod_el_farag_2', nameAr: 'محطة ٢', nameEn: 'Rod 2');
const _cairo1 = Station(
  id: 'cairo_uni_1',
  nameAr: 'محطة ٣',
  nameEn: 'Cairo Uni 1',
);
const _cairo2 = Station(
  id: 'cairo_uni_2',
  nameAr: 'محطة ٤',
  nameEn: 'Cairo Uni 2',
);

NetworkData _network() => NetworkData(
  lines: const [_line1, _line2, _line3],
  stations: const [_sadat, _kitKat, _rod1, _rod2, _cairo1, _cairo2],
  branches: const [
    LineBranch(lineId: 3, branch: 'rod_el_farag', startsAfter: 'kit_kat'),
    LineBranch(lineId: 3, branch: 'cairo_uni', startsAfter: 'kit_kat'),
  ],
  lineStations: const [
    LineStation(lineId: 3, stationId: 'kit_kat', branch: 'main', seq: 1),
    LineStation(
      lineId: 3,
      stationId: 'rod_el_farag_2',
      branch: 'rod_el_farag',
      seq: 2,
    ),
    LineStation(
      lineId: 3,
      stationId: 'cairo_uni_2',
      branch: 'cairo_uni',
      seq: 2,
    ),
    LineStation(
      lineId: 3,
      stationId: 'rod_el_farag_1',
      branch: 'rod_el_farag',
      seq: 1,
    ),
    LineStation(
      lineId: 3,
      stationId: 'cairo_uni_1',
      branch: 'cairo_uni',
      seq: 1,
    ),
    LineStation(lineId: 1, stationId: 'sadat', branch: 'main', seq: 1),
    LineStation(lineId: 2, stationId: 'sadat', branch: 'main', seq: 2),
  ],
  fares: const [
    FareBracket(maxStations: 16, priceEgp: 12),
    FareBracket(maxStations: 9, priceEgp: 10),
  ],
  snapshotDate: '2026-11-18',
);

void main() {
  group('fromJson', () {
    test('Line', () {
      final line = Line.fromJson({
        'id': 1,
        'name_ar': 'الخط الأول',
        'name_en': 'Line 1',
        'color_hex': '#1E63B8',
      });

      expect(line.id, 1);
      expect(line.nameAr, 'الخط الأول');
      expect(line.nameEn, 'Line 1');
      expect(line.colorHex, '#1E63B8');
    });

    test('Station', () {
      final station = Station.fromJson({
        'id': 'sadat',
        'name_ar': 'السادات',
        'name_en': 'Sadat',
      });

      expect(station.id, 'sadat');
      expect(station.nameAr, 'السادات');
      expect(station.nameEn, 'Sadat');
    });

    test('LineStation', () {
      final lineStation = LineStation.fromJson({
        'line_id': 3,
        'station_id': 'kit_kat',
        'branch': 'main',
        'seq': 1,
      });

      expect(lineStation.lineId, 3);
      expect(lineStation.stationId, 'kit_kat');
      expect(lineStation.branch, 'main');
      expect(lineStation.seq, 1);
    });

    test('LineBranch', () {
      final branch = LineBranch.fromJson({
        'line_id': 3,
        'branch': 'cairo_uni',
        'starts_after': 'kit_kat',
      });

      expect(branch.lineId, 3);
      expect(branch.branch, 'cairo_uni');
      expect(branch.startsAfter, 'kit_kat');
    });

    test('FareBracket', () {
      final fare = FareBracket.fromJson({'max_stations': 9, 'price_egp': 10});

      expect(fare.maxStations, 9);
      expect(fare.priceEgp, 10);
    });

    test('v2 terminus and ticket color fields', () {
      final line = Line.fromJson({
        'id': 1,
        'name_ar': 'الخط الأول',
        'name_en': 'Line 1',
        'color_hex': '#1E63B8',
        'terminus_a_ar': 'حلوان',
        'terminus_a_en': 'Helwan',
        'terminus_b_ar': 'المرج الجديدة',
        'terminus_b_en': 'New El-Marg',
      });
      expect(line.terminusAEn, 'Helwan');
      expect(line.terminusBAr, 'المرج الجديدة');

      final branch = LineBranch.fromJson({
        'line_id': 3,
        'branch': 'cairo_uni',
        'starts_after': 'kit_kat',
        'terminus_ar': 'جامعة القاهرة',
        'terminus_en': 'Cairo University',
      });
      expect(branch.terminusEn, 'Cairo University');

      final fare = FareBracket.fromJson({
        'max_stations': 9,
        'price_egp': 10,
        'ticket_color': 'yellow',
      });
      expect(fare.ticketColor, 'yellow');

      expect(
        Line.fromJson({
          'id': 1,
          'name_ar': 'الخط الأول',
          'name_en': 'Line 1',
          'color_hex': '#1E63B8',
        }).terminusAEn,
        '',
      );
      expect(
        FareBracket.fromJson({'max_stations': 9, 'price_egp': 10}).ticketColor,
        '',
      );
    });
  });

  group('localizedName', () {
    test('Line returns Arabic for ar and English otherwise', () {
      expect(_line1.localizedName('ar'), 'الخط الأول');
      expect(_line1.localizedName('en'), 'Line 1');
      expect(_line1.localizedName('fr'), 'Line 1');
    });

    test('Station returns Arabic for ar and English otherwise', () {
      expect(_sadat.localizedName('ar'), 'السادات');
      expect(_sadat.localizedName('en'), 'Sadat');
      expect(_sadat.localizedName('fr'), 'Sadat');
    });
  });

  group('NetworkData', () {
    test('sorts fares and keeps the snapshot date', () {
      final data = _network();

      expect(data.fares.map((fare) => fare.maxStations), [9, 16]);
      expect(data.snapshotDate, '2026-11-18');
    });

    test('finds stations and lines by id', () {
      final data = _network();

      expect(data.stationById('sadat'), _sadat);
      expect(data.stationById('missing'), isNull);
      expect(data.lineById(2), _line2);
      expect(data.lineById(99), isNull);
    });

    test('lists the lines serving a station in line order', () {
      final data = _network();

      expect(data.linesServing('sadat'), [_line1, _line2]);
      expect(data.linesServing('missing'), isEmpty);
    });

    test('lists line stations with main first, then branches by seq', () {
      final data = _network();

      expect(data.stationsOfLine(3).map((station) => station.stationId), [
        'kit_kat',
        'rod_el_farag_1',
        'rod_el_farag_2',
        'cairo_uni_1',
        'cairo_uni_2',
      ]);
      expect(data.stationsOfLine(99), isEmpty);
    });
  });
}
