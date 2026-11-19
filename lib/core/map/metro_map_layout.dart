import 'dart:ui';

import 'package:maak_metro/domain/models/metro_models.dart';

/// The canvas the schematic is drawn on.
const double mapWidth = 1000;
const double mapHeight = 1400;

/// Hand-placed anchors, roughly where the lines sit on the printed network
/// map: Line 1 runs north-south through the middle, Line 2 crosses it twice,
/// Line 3 comes in from the north-east and forks after Kit Kat. Every station
/// that is not an anchor is spread evenly between the anchors around it.
const Map<String, Offset> _anchors = {
  // Line 1, north-south through the middle
  'helwan': Offset(560, 1330),
  'maadi': Offset(560, 1180),
  'dar_el_salam': Offset(560, 1080),
  'mar_girgis': Offset(560, 960),
  'el_sayeda_zeinab': Offset(560, 900),
  'sadat': Offset(560, 840),
  'nasser': Offset(560, 780),
  'shohadaa': Offset(560, 660),
  'ghamra': Offset(560, 560),
  'el_matareya': Offset(560, 340),
  'ain_shams': Offset(560, 240),
  'ezbet_el_nakhl': Offset(560, 180),
  'marg': Offset(560, 120),
  'marg_el_gedida': Offset(560, 60),

  // Line 2, south-west to north, doubling back through Attaba
  'mounib': Offset(110, 1120),
  'giza': Offset(230, 1080),
  'uni': Offset(300, 1060),
  'dokki': Offset(450, 940),
  'opera': Offset(520, 900),
  'mohamed_naguib': Offset(600, 800),
  'attaba': Offset(640, 760),
  'massara': Offset(510, 620),
  'rod_el_farag': Offset(450, 580),
  'shobra_el_kheima': Offset(380, 500),

  // Line 3, Adly Mansour south-west to Attaba
  'adly_mansour': Offset(980, 80),
  'el_haykestep': Offset(960, 130),
  'heliopolis': Offset(850, 280),
  'el_ahram': Offset(800, 340),
  'el_estad': Offset(750, 420),
  'abbasiya': Offset(700, 520),
  'bab_el_shaaria': Offset(660, 640),
  'maspero': Offset(470, 800),
  'safaa_hegazy': Offset(420, 830),
  'kit_kat': Offset(370, 880),

  // Line 3, Rod El Farag branch
  'sudan': Offset(330, 840),
  'imbaba': Offset(290, 790),
  'el_qawmeya': Offset(230, 700),
  'rod_el_farag_axis_station': Offset(170, 600),

  // Line 3, Cairo University branch
  'el_tawfiqia': Offset(390, 930),
  'wadi_el_nil': Offset(400, 980),
  'arab_league': Offset(390, 1020),
  'boulaq_el_dakrour': Offset(355, 1048),
};

/// One drawn run of track: a line's trunk or one of its branches.
typedef MapTrack = ({int lineId, List<String> ids});

/// Station positions and the ordered station ids of every line and branch.
class MetroMapLayout {
  const MetroMapLayout({required this.points, required this.paths});

  final Map<String, Offset> points;

  /// One entry per line and branch, in travel order. A branch starts at the
  /// station it forks from, so the fork has no gap in it.
  final List<MapTrack> paths;

  factory MetroMapLayout.of(NetworkData network) {
    final points = <String, Offset>{};
    final paths = <MapTrack>[];

    for (final line in network.lines) {
      for (final branch in ['main', ...network.branchesOf(line.id)]) {
        final ids = [
          for (final station in network.stationsOf(line.id, branch)) station.id,
        ];
        if (ids.length < 2) continue;
        if (branch != 'main') {
          final fork = network.branches.firstWhere(
            (row) => row.lineId == line.id && row.branch == branch,
          );
          ids.insert(0, fork.startsAfter);
        }
        _place(points, ids);
        paths.add((lineId: line.id, ids: ids));
      }
    }
    return MetroMapLayout(points: points, paths: paths);
  }

  /// Pins every anchored station, then spreads the rest evenly between them.
  static void _place(Map<String, Offset> points, List<String> ids) {
    final fixed = [
      for (var index = 0; index < ids.length; index++)
        if (_anchors.containsKey(ids[index])) index,
    ];
    if (fixed.isEmpty) return;

    for (final index in fixed) {
      points.putIfAbsent(ids[index], () => _anchors[ids[index]]!);
    }

    for (var segment = 0; segment < fixed.length - 1; segment++) {
      final from = fixed[segment];
      final to = fixed[segment + 1];
      final start = points[ids[from]]!;
      final end = points[ids[to]]!;
      final steps = to - from;
      for (var step = 1; step < steps; step++) {
        final t = step / steps;
        points.putIfAbsent(ids[from + step], () => Offset.lerp(start, end, t)!);
      }
    }
  }
}
