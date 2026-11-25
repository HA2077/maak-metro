import 'models/models.dart';
import 'routing_graph.dart';

List<RouteLeg> buildLegs(List<NodeKey> path, RoutingGraph graph) {
  if (path.isEmpty) return const <RouteLeg>[];

  final segments = <List<NodeKey>>[];
  var segment = <NodeKey>[path.first];
  for (var i = 1; i < path.length; i++) {
    final node = path[i];
    if (node.lineId != segment.last.lineId) {
      segments.add(segment);
      segment = <NodeKey>[node];
      continue;
    }
    segment.add(node);
  }
  segments.add(segment);

  final legs = <RouteLeg>[];
  for (final nodes in segments) {
    var start = 0;
    String? branch;
    int? forkIndex;
    for (var i = 0; i < nodes.length; i++) {
      final nodeBranch = graph.branchOf(nodes[i]);
      if (nodeBranch == 'main') {
        forkIndex = i;
        continue;
      }
      if (branch == null) {
        branch = nodeBranch;
        continue;
      }
      if (nodeBranch == branch) continue;

      if (forkIndex == null || forkIndex <= start) {
        throw StateError(
          'Branch change from $branch to $nodeBranch has no fork station',
        );
      }
      legs.add(_leg(nodes.sublist(start, forkIndex + 1), graph, branch));
      start = forkIndex;
      branch = nodeBranch;
    }
    legs.add(_leg(nodes.sublist(start), graph, branch));
  }

  return List.unmodifiable(legs);
}

RouteLeg _leg(List<NodeKey> nodes, RoutingGraph graph, String? branch) {
  for (final node in nodes) {
    final nodeBranch = graph.branchOf(node);
    if (nodeBranch != 'main') {
      branch = nodeBranch;
      break;
    }
  }
  return RouteLeg(
    lineId: nodes.first.lineId,
    branch: branch ?? 'main',
    stationIds: [for (final node in nodes) node.stationId],
  );
}
