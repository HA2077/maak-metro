import 'route_leg.dart';

class RouteResult {
  const RouteResult({
    required this.fromId,
    required this.toId,
    required this.legs,
    required this.stationCount,
    required this.transfers,
    required this.estimatedMinutes,
    required this.fareEgp,
  });

  final String fromId;
  final String toId;
  final List<RouteLeg> legs;
  final int stationCount;
  final int transfers;
  final double estimatedMinutes;
  final int fareEgp;
}
