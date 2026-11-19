import 'package:maak_metro/domain/models/metro_models.dart';

/// Small hand-written network for widget tests. Not the real seed: names are
/// here only to exercise Arabic line lengths and a Line 3 fork.
NetworkData sampleNetwork() => const NetworkData(
  snapshotDate: '2026-11-18',
  lines: [
    Line(id: 1, nameAr: 'الخط الأول', nameEn: 'Line 1', colorHex: '#D01F2F'),
    Line(id: 2, nameAr: 'الخط الثاني', nameEn: 'Line 2', colorHex: '#F58220'),
    Line(id: 3, nameAr: 'الخط الثالث', nameEn: 'Line 3', colorHex: '#00A651'),
  ],
  stations: [
    Station(id: 'marg', nameAr: 'المرج', nameEn: 'El Marg'),
    Station(
      id: 'zaitoun',
      nameAr: 'حدائق الزيتون',
      nameEn: 'Hadayek El Zaitoun',
    ),
    Station(id: 'shohadaa', nameAr: 'الشهداء', nameEn: 'Al-Shohadaa'),
    Station(id: 'nasser', nameAr: 'ناصر', nameEn: 'Nasser'),
    Station(id: 'kit_kat', nameAr: 'الكيت كات', nameEn: 'Kit Kat'),
    Station(id: 'uni', nameAr: 'جامعة القاهرة', nameEn: 'Cairo University'),
    Station(id: 'attaba', nameAr: 'العتبة', nameEn: 'Attaba'),
    Station(id: 'imbaba', nameAr: 'إمبابة', nameEn: 'Imbaba'),
  ],
  branches: [
    LineBranch(lineId: 3, branch: 'rod_el_farag', startsAfter: 'kit_kat'),
    LineBranch(lineId: 3, branch: 'cairo_uni', startsAfter: 'kit_kat'),
  ],
  lineStations: [
    LineStation(lineId: 1, stationId: 'marg', branch: 'main', seq: 1),
    LineStation(lineId: 1, stationId: 'zaitoun', branch: 'main', seq: 2),
    LineStation(lineId: 1, stationId: 'shohadaa', branch: 'main', seq: 3),
    LineStation(lineId: 1, stationId: 'nasser', branch: 'main', seq: 4),
    LineStation(lineId: 2, stationId: 'shohadaa', branch: 'main', seq: 1),
    LineStation(lineId: 2, stationId: 'attaba', branch: 'main', seq: 2),
    LineStation(lineId: 3, stationId: 'attaba', branch: 'main', seq: 1),
    LineStation(lineId: 3, stationId: 'nasser', branch: 'main', seq: 2),
    LineStation(lineId: 3, stationId: 'kit_kat', branch: 'main', seq: 3),
    LineStation(lineId: 3, stationId: 'imbaba', branch: 'rod_el_farag', seq: 1),
    LineStation(lineId: 3, stationId: 'uni', branch: 'cairo_uni', seq: 1),
  ],
  fares: [
    FareBracket(maxStations: 9, priceEgp: 10),
    FareBracket(maxStations: 16, priceEgp: 12),
    FareBracket(maxStations: 23, priceEgp: 15),
    FareBracket(maxStations: 39, priceEgp: 20),
  ],
);

/// Route across two lines and a Line 3 branch change.
RouteResult sampleResult() => const RouteResult(
  fromId: 'marg',
  toId: 'uni',
  legs: [
    RouteLeg(
      lineId: 1,
      branch: 'main',
      stationIds: ['marg', 'zaitoun', 'shohadaa', 'nasser'],
    ),
    RouteLeg(lineId: 3, branch: 'main', stationIds: ['nasser', 'kit_kat']),
    RouteLeg(lineId: 3, branch: 'cairo_uni', stationIds: ['kit_kat', 'uni']),
  ],
  stationCount: 5,
  transfers: 2,
  estimatedMinutes: 27.5,
  fareEgp: 12,
);
