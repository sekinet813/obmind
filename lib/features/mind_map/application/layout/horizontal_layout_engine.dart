import 'dart:math' as math;

import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

/// Left-to-right mind map layout. Coordinates stay in [MindMapLayout].
final class HorizontalLayoutEngine implements LayoutEngine {
  const HorizontalLayoutEngine({
    this.horizontalGap = 48,
    this.verticalGap = 16,
    this.fallbackSize = const NodeSize(width: 160, height: 64),
  });

  final double horizontalGap;
  final double verticalGap;
  final NodeSize fallbackSize;

  @override
  MindMapLayout layout(
    MindMapDocument document, {
    required Map<NodeId, NodeSize> nodeSizes,
  }) {
    final tree = _measure(document.root, nodeSizes);
    final nodes = <NodeId, NodeLayout>{};
    _place(tree, 0, 0, nodes);

    var width = 0.0;
    var height = 0.0;
    for (final layout in nodes.values) {
      width = math.max(width, layout.x + layout.width);
      height = math.max(height, layout.y + layout.height);
    }
    return MindMapLayout(
      nodes: Map.unmodifiable(nodes),
      width: width,
      height: height,
    );
  }

  _MeasuredNode _measure(MindNode node, Map<NodeId, NodeSize> nodeSizes) {
    final size = nodeSizes[node.id] ?? fallbackSize;
    if (node.collapsed || node.children.isEmpty) {
      return _MeasuredNode(node: node, size: size, height: size.height);
    }
    final children = [
      for (final child in node.children) _measure(child, nodeSizes),
    ];
    var contentHeight = 0.0;
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        contentHeight += verticalGap;
      }
      contentHeight += children[i].height;
    }
    return _MeasuredNode(
      node: node,
      size: size,
      children: children,
      height: math.max(size.height, contentHeight),
    );
  }

  void _place(
    _MeasuredNode tree,
    double x,
    double top,
    Map<NodeId, NodeLayout> nodes,
  ) {
    nodes[tree.node.id] = NodeLayout(
      id: tree.node.id,
      x: x,
      y: top + (tree.height - tree.size.height) / 2,
      width: tree.size.width,
      height: tree.size.height,
    );
    if (tree.children.isEmpty) {
      return;
    }
    var contentHeight = 0.0;
    for (var i = 0; i < tree.children.length; i++) {
      if (i > 0) {
        contentHeight += verticalGap;
      }
      contentHeight += tree.children[i].height;
    }
    var childTop = top + (tree.height - contentHeight) / 2;
    final childX = x + tree.size.width + horizontalGap;
    for (final child in tree.children) {
      _place(child, childX, childTop, nodes);
      childTop += child.height + verticalGap;
    }
  }
}

final class _MeasuredNode {
  const _MeasuredNode({
    required this.node,
    required this.size,
    this.children = const [],
    required this.height,
  });

  final MindNode node;
  final NodeSize size;
  final List<_MeasuredNode> children;
  final double height;
}
