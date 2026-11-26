import 'package:flutter_test/flutter_test.dart';

import 'package:maak_metro/core/utils/directions.dart';
import 'package:maak_metro/features/network/domain/models/models.dart';
import 'package:maak_metro/features/planner/domain/models/models.dart';

NetworkData _network() => NetworkData(
  lines: [
    Line(
      id: 1,
      nameAr: 'الخط الأول',
      nameEn: 'Line 1',
      colorHex: '#000000',
      terminusAAr: 'حلوان',
      terminusAEn: 'Helwan',
      terminusBAr: 'المرج الجديدة',
      terminusBEn: 'New El-Marg',
    ),
    Line(
      id: 3,
      nameAr: 'الخط الثالث',
      nameEn: 'Line 3',
      colorHex: '#000000',
      terminusAAr: 'عدلي منصور',
      terminusAEn: 'Adly Mansour',
      terminusBAr: 'محور روض الفرج / جامعة القاهرة',
      terminusBEn: 'Rod El-Farag Corridor / Cairo University',
    ),
  ],
  stations: const [],
  branches: const [
    LineBranch(
      lineId: 3,
      branch: 'rod_el_farag',
      startsAfter: 'kit_kat',
      terminusAr: 'محور روض الفرج',
      terminusEn: 'Rod El-Farag Corridor',
    ),
  ],
  lineStations: const [
    LineStation(lineId: 1, stationId: 'helwan', branch: 'main', seq: 1),
    LineStation(lineId: 1, stationId: 'marg', branch: 'main', seq: 2),
    LineStation(lineId: 3, stationId: 'adly', branch: 'main', seq: 1),
    LineStation(lineId: 3, stationId: 'kit_kat', branch: 'main', seq: 2),
    LineStation(lineId: 3, stationId: 'r1', branch: 'rod_el_farag', seq: 1),
    LineStation(lineId: 3, stationId: 'r2', branch: 'rod_el_farag', seq: 2),
  ],
  fares: const [],
  snapshotDate: 'test',
);

void main() {
  final network = _network();

  test('line terminus header is bidirectional and localized', () {
    expect(
      lineTerminusHeader(network.lineById(1)!, 'en'),
      'Helwan ↔ New El-Marg',
    );
    expect(
      lineTerminusHeader(network.lineById(1)!, 'ar'),
      'حلوان ↔ المرج الجديدة',
    );
  });

  test('main-line direction follows the travel direction', () {
    expect(
      legTerminus(
        const RouteLeg(
          lineId: 1,
          branch: 'main',
          stationIds: ['helwan', 'marg'],
        ),
        network,
        'en',
      ),
      'New El-Marg',
    );
    expect(
      legTerminus(
        const RouteLeg(
          lineId: 1,
          branch: 'main',
          stationIds: ['marg', 'helwan'],
        ),
        network,
        'en',
      ),
      'Helwan',
    );
  });

  test('line 3 main towards the fork shows the western split', () {
    expect(
      legTerminus(
        const RouteLeg(
          lineId: 3,
          branch: 'main',
          stationIds: ['adly', 'kit_kat'],
        ),
        network,
        'en',
      ),
      'Rod El-Farag Corridor / Cairo University',
    );
  });

  test(
    'branch direction uses the branch terminus outward and line A inward',
    () {
      expect(
        legTerminus(
          const RouteLeg(
            lineId: 3,
            branch: 'rod_el_farag',
            stationIds: ['kit_kat', 'r1', 'r2'],
          ),
          network,
          'en',
        ),
        'Rod El-Farag Corridor',
      );
      expect(
        legTerminus(
          const RouteLeg(
            lineId: 3,
            branch: 'rod_el_farag',
            stationIds: ['r2', 'r1', 'kit_kat'],
          ),
          network,
          'ar',
        ),
        'عدلي منصور',
      );
    },
  );
}
