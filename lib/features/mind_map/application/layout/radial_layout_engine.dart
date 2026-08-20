import 'dart:math' as math;

import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

/// Radial mind map layout.
///
/// Root children are spaced evenly around the root. Deeper nodes grow outward
/// in that child's direction, like a rotated horizontal branch. Coordinates
/// stay in [MindMapLayout]. Domain nodes are not mutated.
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

  @override
  MindMapLayout layout(
    MindMapDocument document, {
    required Map<NodeId, NodeSize> nodeSizes,
  }) {
    final root = document.root;
    final rootSize = nodeSizes[root.id] ?? fallbackSize;
    final placed = <NodeId, NodeLayout>{};
    placed[root.id] = _fromCenter(root.id, rootSize, 0, 0);

    final visibleChildren = root.collapsed || root.children.isEmpty
        ? const <MindNode>[]
        : root.children;
    final childCount = visibleChildren.length;
    if (childCount > 0) {
      final delta = _fullCircle / childCount;
      final childTrees = [
        for (var i = 0; i < childCount; i++)
          _measure(visibleChildren[i], nodeSizes, angle: i * delta),
      ];
      final radius = _rootChildRadius(rootSize, childTrees, delta);
      for (var i = 0; i < childCount; i++) {
        final angle = i * delta;
        _placeBranch(
          childTrees[i],
          cx: math.cos(angle) * radius,
          cy: math.sin(angle) * radius,
          angle: angle,
          nodes: placed,
        );
      }
    }

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

  double _rootChildRadius(
    NodeSize rootSize,
    List<_RadialNode> children,
    double delta,
  ) {
    var radius = 0.0;
    for (var i = 0; i < children.length; i++) {
      final angle = i * delta;
      radius = math.max(
        radius,
        _halfExtent(rootSize, angle) +
            radialGap +
            _halfExtent(children[i].size, angle),
      );
    }
    if (children.length < 2) {
      return radius;
    }
    final sinHalf = math.sin(delta / 2);
    if (sinHalf <= 1e-6) {
      return radius;
    }
    for (var i = 0; i < children.length; i++) {
      final next = children[(i + 1) % children.length];
      final separation =
          (children[i].thickness + next.thickness) / 2 + siblingGap;
      radius = math.max(radius, separation / (2 * sinHalf));
    }
    return radius;
  }

  _RadialNode _measure(
    MindNode node,
    Map<NodeId, NodeSize> nodeSizes, {
    required double angle,
  }) {
    final size = nodeSizes[node.id] ?? fallbackSize;
    if (node.collapsed || node.children.isEmpty) {
      return _RadialNode(
        node: node,
        size: size,
        thickness: _crossSize(size, angle),
      );
    }
    final children = [
      for (final child in node.children)
        _measure(child, nodeSizes, angle: angle),
    ];
    var content = 0.0;
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        content += siblingGap;
      }
      content += children[i].thickness;
    }
    return _RadialNode(
      node: node,
      size: size,
      children: children,
      thickness: math.max(_crossSize(size, angle), content),
    );
  }

  void _placeBranch(
    _RadialNode tree, {
    required double cx,
    required double cy,
    required double angle,
    required Map<NodeId, NodeLayout> nodes,
  }) {
    nodes[tree.node.id] = _fromCenter(tree.node.id, tree.size, cx, cy);
    if (tree.children.isEmpty) {
      return;
    }

    final dx = math.cos(angle);
    final dy = math.sin(angle);
    final px = -math.sin(angle);
    final py = math.cos(angle);

    var content = 0.0;
    for (var i = 0; i < tree.children.length; i++) {
      if (i > 0) {
        content += siblingGap;
      }
      content += tree.children[i].thickness;
    }

    var childCross = -content / 2;
    for (final child in tree.children) {
      final along =
          _halfExtent(tree.size, angle) +
          radialGap +
          _halfExtent(child.size, angle);
      final cross = childCross + child.thickness / 2;
      _placeBranch(
        child,
        cx: cx + dx * along + px * cross,
        cy: cy + dy * along + py * cross,
        angle: angle,
        nodes: nodes,
      );
      childCross += child.thickness + siblingGap;
    }
  }

  NodeLayout _fromCenter(NodeId id, NodeSize size, double cx, double cy) {
    return NodeLayout(
      id: id,
      x: cx - size.width / 2,
      y: cy - size.height / 2,
      width: size.width,
      height: size.height,
    );
  }

  double _halfExtent(NodeSize size, double angle) {
    return (size.width * math.cos(angle).abs() +
            size.height * math.sin(angle).abs()) /
        2;
  }

  double _crossSize(NodeSize size, double angle) {
    return size.width * math.sin(angle).abs() +
        size.height * math.cos(angle).abs();
  }
}

final class _RadialNode {
  const _RadialNode({
    required this.node,
    required this.size,
    this.children = const [],
    required this.thickness,
  });

  final MindNode node;
  final NodeSize size;
  final List<_RadialNode> children;
  final double thickness;
}
