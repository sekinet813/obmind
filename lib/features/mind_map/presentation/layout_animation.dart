import 'dart:ui' show lerpDouble;

import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

/// Interpolates between two layout snapshots for canvas animation.
MindMapLayout lerpMindMapLayout(
  MindMapLayout from,
  MindMapLayout to,
  double t,
) {
  final ids = {...from.nodes.keys, ...to.nodes.keys};
  final nodes = <NodeId, NodeLayout>{};
  for (final id in ids) {
    final a = from[id];
    final b = to[id];
    if (a != null && b != null) {
      nodes[id] = NodeLayout(
        id: id,
        x: lerpDouble(a.x, b.x, t)!,
        y: lerpDouble(a.y, b.y, t)!,
        width: lerpDouble(a.width, b.width, t)!,
        height: lerpDouble(a.height, b.height, t)!,
      );
    } else if (b != null) {
      nodes[id] = NodeLayout(
        id: id,
        x: b.x,
        y: b.y,
        width: b.width * t,
        height: b.height * t,
      );
    }
  }
  return MindMapLayout(
    nodes: nodes,
    width: lerpDouble(from.width, to.width, t)!,
    height: lerpDouble(from.height, to.height, t)!,
  );
}
