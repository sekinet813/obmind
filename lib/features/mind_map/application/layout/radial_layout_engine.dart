import 'dart:math' as math;

import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

/// Radial mind map layout. Root sits near the center; children fan outward.
///
/// Coordinates stay in [MindMapLayout]. Domain nodes are not mutated.
final class RadialLayoutEngine implements LayoutEngine {
  const RadialLayoutEngine({
    this.radialGap = 48,
    this.siblingGap = 16,
    this.fallbackSize = const NodeSize(width: 80, height: 40),
  });

  final double radialGap;
  final double siblingGap;
  final NodeSize fallbackSize;

  static const _fullCircle = 2 * math.pi;
  static const _maxChildFan = math.pi;

  @override
  MindMapLayout layout(
    MindMapDocument document, {
    required Map<NodeId, NodeSize> nodeSizes,
  }) {
    final tree = _measure(document.root, nodeSizes);
    final placed = <NodeId, NodeLayout>{};
    _place(
      tree,
      angle: 0,
      span: _fullCircle,
      radius: 0,
      isRoot: true,
      nodes: placed,
    );

    var minX = 0.0;
    var minY = 0.0;
    for (final node in placed.values) {
      minX = math.min(minX, node.x);
      minY = math.min(minY, node.y);
    }

    final shifted = <NodeId, NodeLayout>{};
    var width = 0.0;
    var height = 0.0;
    for (final entry in placed.entries) {
      final node = entry.value;
      final layout = NodeLayout(
        id: node.id,
        x: node.x - minX,
        y: node.y - minY,
        width: node.width,
        height: node.height,
      );
      shifted[entry.key] = layout;
      width = math.max(width, layout.x + layout.width);
      height = math.max(height, layout.y + layout.height);
    }

    return MindMapLayout(
      nodes: Map.unmodifiable(shifted),
      width: width,
      height: height,
    );
  }

  _RadialNode _measure(MindNode node, Map<NodeId, NodeSize> nodeSizes) {
    final size = nodeSizes[node.id] ?? fallbackSize;
    if (node.collapsed || node.children.isEmpty) {
      return _RadialNode(node: node, size: size, weight: 1);
    }
    final children = [
      for (final child in node.children) _measure(child, nodeSizes),
    ];
    var weight = 0;
    for (final child in children) {
      weight += child.weight;
    }
    return _RadialNode(
      node: node,
      size: size,
      children: children,
      weight: math.max(1, weight),
    );
  }

  void _place(
    _RadialNode tree, {
    required double angle,
    required double span,
    required double radius,
    required bool isRoot,
    required Map<NodeId, NodeLayout> nodes,
  }) {
    final centerX = math.cos(angle) * radius;
    final centerY = math.sin(angle) * radius;
    nodes[tree.node.id] = NodeLayout(
      id: tree.node.id,
      x: centerX - tree.size.width / 2,
      y: centerY - tree.size.height / 2,
      width: tree.size.width,
      height: tree.size.height,
    );
    if (tree.children.isEmpty) {
      return;
    }

    final childRadius = _radiusForChildren(
      parentRadius: radius,
      parentSize: tree.size,
      children: tree.children,
      angleSpan: isRoot ? _fullCircle : math.min(span, _maxChildFan),
    );
    _placeChildren(
      tree.children,
      parentAngle: angle,
      parentSpan: span,
      childRadius: childRadius,
      isRoot: isRoot,
      nodes: nodes,
    );
  }

  void _placeChildren(
    List<_RadialNode> children, {
    required double parentAngle,
    required double parentSpan,
    required double childRadius,
    required bool isRoot,
    required Map<NodeId, NodeLayout> nodes,
  }) {
    var totalWeight = 0;
    for (final child in children) {
      totalWeight += child.weight;
    }
    if (totalWeight == 0) {
      return;
    }

    final fanSpan = isRoot ? _fullCircle : math.min(parentSpan, _maxChildFan);
    final spans = [
      for (final child in children) fanSpan * child.weight / totalWeight,
    ];
    var start = isRoot ? -spans.first / 2 : parentAngle - fanSpan / 2;
    for (var i = 0; i < children.length; i++) {
      final childSpan = spans[i];
      final childAngle = start + childSpan / 2;
      _place(
        children[i],
        angle: childAngle,
        span: childSpan,
        radius: childRadius,
        isRoot: false,
        nodes: nodes,
      );
      start += childSpan;
    }
  }

  double _radiusForChildren({
    required double parentRadius,
    required NodeSize parentSize,
    required List<_RadialNode> children,
    required double angleSpan,
  }) {
    final parentExtent = math.max(parentSize.width, parentSize.height) / 2;
    var maxChildExtent = 0.0;
    var arc = 0.0;
    for (var i = 0; i < children.length; i++) {
      final size = children[i].size;
      final extent = math.max(size.width, size.height);
      maxChildExtent = math.max(maxChildExtent, extent / 2);
      arc += extent;
      if (i < children.length - 1) {
        arc += siblingGap;
      }
    }
    final fromParent = parentRadius + parentExtent + radialGap + maxChildExtent;
    final fromArc = angleSpan > 1e-6 ? arc / angleSpan : fromParent;
    return math.max(fromParent, fromArc);
  }
}

final class _RadialNode {
  const _RadialNode({
    required this.node,
    required this.size,
    this.children = const [],
    required this.weight,
  });

  final MindNode node;
  final NodeSize size;
  final List<_RadialNode> children;
  final int weight;
}
