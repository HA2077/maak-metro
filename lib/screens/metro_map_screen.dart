import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/map/metro_map_layout.dart';
import 'package:maak_metro/core/motion/app_haptics.dart';
import 'package:maak_metro/core/motion/app_motion.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/theme/line_colors.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/domain/models/metro_models.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:provider/provider.dart';

/// The whole network as a schematic: tap a line to light it up and fade the
/// others, and the current route is drawn over the top when there is one.
class MetroMapScreen extends StatefulWidget {
  const MetroMapScreen({super.key});

  @override
  State<MetroMapScreen> createState() => _MetroMapScreenState();
}

class _MetroMapScreenState extends State<MetroMapScreen>
    with SingleTickerProviderStateMixin {
  final TransformationController _transform = TransformationController();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  int? _selected;
  bool _fitted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _pulse.stop();
      _pulse.value = 0.75;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _toggle(int lineId) {
    AppHaptics.tap();
    setState(() => _selected = _selected == lineId ? null : lineId);
    // The glow only exists while a line is selected, so nothing animates at
    // rest and tests can settle.
    if (_selected == null || AppMotion.reduced(context)) {
      _pulse.stop();
      _pulse.value = 0.75;
    } else {
      _pulse.repeat(reverse: true);
    }
  }

  void _clear() {
    if (_selected == null) return;
    setState(() => _selected = null);
    _pulse.stop();
    _pulse.value = 0.75;
  }

  void _handleTap(Offset local, MetroMapLayout layout) {
    var best = 30.0;
    int? hit;
    for (final track in layout.paths) {
      final path = [
        for (final id in track.ids)
          if (layout.points[id] != null) layout.points[id]!,
      ];
      for (var index = 0; index < path.length - 1; index++) {
        final distance = _distanceToSegment(
          local,
          path[index],
          path[index + 1],
        );
        if (distance < best) {
          best = distance;
          hit = track.lineId;
        }
      }
    }
    if (hit == null) {
      _clear();
    } else {
      _toggle(hit);
    }
  }

  static double _distanceToSegment(Offset point, Offset a, Offset b) {
    final ab = b - a;
    final lengthSquared = ab.dx * ab.dx + ab.dy * ab.dy;
    if (lengthSquared == 0) return (point - a).distance;
    final t =
        (((point - a).dx * ab.dx + (point - a).dy * ab.dy) / lengthSquared)
            .clamp(0.0, 1.0);
    return (point - (a + ab * t)).distance;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final route = context.watch<RouteProvider>();
    final network = route.network;
    final layout = MetroMapLayout.of(network);
    final result = route.result;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mapTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpace.lg,
              AppSpace.sm,
              AppSpace.lg,
              AppSpace.sm,
            ),
            child: Text(
              l10n.mapHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpace.lg,
            ),
            child: Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [
                for (final line in network.lines)
                  _LineLegend(
                    line: line,
                    selected: _selected == line.id,
                    onTap: () => _toggle(line.id),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (!_fitted) {
                  _fitted = true;
                  final scale = min(
                    constraints.maxWidth / mapWidth,
                    constraints.maxHeight / mapHeight,
                  );
                  final dx = (constraints.maxWidth - mapWidth * scale) / 2;
                  final dy = (constraints.maxHeight - mapHeight * scale) / 2;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    _transform.value = Matrix4.identity()
                      ..translateByDouble(dx, dy, 0, 1)
                      ..scaleByDouble(scale, scale, 1, 1);
                  });
                }
                return InteractiveViewer(
                  transformationController: _transform,
                  constrained: false,
                  minScale: 0.2,
                  maxScale: 6,
                  boundaryMargin: const EdgeInsets.all(240),
                  child: SizedBox(
                    width: mapWidth,
                    height: mapHeight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (details) =>
                          _handleTap(details.localPosition, layout),
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, _) => CustomPaint(
                          painter: MetroMapPainter(
                            layout: layout,
                            network: network,
                            selectedLine: _selected,
                            glow: _pulse.value,
                            routeLegs: result?.legs ?? const [],
                            surface: theme.colorScheme.surface,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LineLegend extends StatelessWidget {
  const _LineLegend({
    required this.line,
    required this.selected,
    required this.onTap,
  });

  final Line line;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(line.colorHex);
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: CircleAvatar(backgroundColor: color, radius: 6),
      label: Text(lineName(context, line)),
    );
  }
}

class MetroMapPainter extends CustomPainter {
  MetroMapPainter({
    required this.layout,
    required this.network,
    required this.selectedLine,
    required this.glow,
    required this.routeLegs,
    required this.surface,
  });

  final MetroMapLayout layout;
  final NetworkData network;
  final int? selectedLine;
  final double glow;
  final List<RouteLeg> routeLegs;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in network.lines) {
      final color = parseHexColor(line.colorHex);
      final active = selectedLine == null || selectedLine == line.id;
      for (final track in layout.paths) {
        if (track.lineId != line.id) continue;
        final path = _pathThrough(track.ids);
        if (path == null) continue;
        if (selectedLine == line.id) {
          canvas.drawPath(
            path,
            Paint()
              ..color = color.withValues(alpha: 0.18 + 0.25 * glow)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 26
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
          );
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = color.withValues(alpha: active ? 1 : 0.2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 9
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }

    for (final leg in routeLegs) {
      final color = parseHexColor(network.lineById(leg.lineId)?.colorHex ?? '');
      final path = _pathThrough(leg.stationIds);
      if (path == null) continue;
      canvas.drawPath(
        path,
        Paint()
          ..color = surface
          ..style = PaintingStyle.stroke
          ..strokeWidth = 17
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 11
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    for (final station in network.stations) {
      final point = layout.points[station.id];
      if (point == null) continue;
      final serving = network.linesServing(station.id);
      final color = serving.isEmpty
          ? surface
          : parseHexColor(serving.first.colorHex);
      final active =
          selectedLine == null ||
          serving.any((line) => line.id == selectedLine);
      final radius = serving.length > 1 ? 6.5 : 4.0;
      canvas.drawCircle(
        point,
        radius,
        Paint()..color = surface.withValues(alpha: active ? 1 : 0.85),
      );
      canvas.drawCircle(
        point,
        radius,
        Paint()
          ..color = color.withValues(alpha: active ? 1 : 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }
  }

  Path? _pathThrough(List<String> ids) {
    final points = [
      for (final id in ids)
        if (layout.points[id] != null) layout.points[id]!,
    ];
    if (points.length < 2) return null;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(MetroMapPainter oldDelegate) =>
      oldDelegate.selectedLine != selectedLine ||
      oldDelegate.glow != glow ||
      oldDelegate.routeLegs != routeLegs ||
      oldDelegate.network != network ||
      oldDelegate.surface != surface;
}
