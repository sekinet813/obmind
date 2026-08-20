import 'dart:ui';

import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/domain/mind_map_tree.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

/// Drop result for a node drag gesture.
sealed class NodeDragResolution {
  const NodeDragResolution();
}

/// Reorder within the current parent.
final class ReorderNodeDrag extends NodeDragResolution {
  const ReorderNodeDrag(this.newIndex);

  final int newIndex;
}

/// Reparent under another node.
final class ReparentNodeDrag extends NodeDragResolution {
  const ReparentNodeDrag(this.newParentId, {this.index});

  final NodeId newParentId;
  final int? index;
}

/// Resolves a layout-space drop point into a tree change.
NodeDragResolution? resolveNodeDrag({
  required MindMapDocument document,
  required MindMapLayout layout,
  required NodeId draggedId,
  required Offset layoutPoint,
}) {
  if (document.root.id == draggedId) {
    return null;
  }
  final dragged = _find(document.root, draggedId);
  if (dragged == null) {
    return null;
  }
  final excluded = dragged.depthFirst.map((node) => node.id).toSet();
  final targetId = _hitTest(layout, layoutPoint, excluded);
  if (targetId == null) {
    return null;
  }

  final draggedLocation = _locate(document.root, draggedId);
  final draggedParent = draggedLocation?.parent;
  if (draggedLocation == null || draggedParent == null) {
    return null;
  }
  final siblings = draggedParent.children;
  final currentIndex = draggedLocation.index;

  final targetLocation = _locate(document.root, targetId);
  final targetParent = targetLocation?.parent;
  if (targetLocation == null || targetParent == null) {
    return null;
  }

  if (targetParent.id == draggedParent.id) {
    var newIndex = targetLocation.index;
    final targetLayout = layout[targetId];
    if (targetLayout != null &&
        layoutPoint.dy > targetLayout.y + targetLayout.height / 2) {
      newIndex += 1;
    }
    newIndex = newIndex.clamp(0, siblings.length - 1);
    if (newIndex == currentIndex) {
      return null;
    }
    return ReorderNodeDrag(newIndex);
  }

  if (MindMapTree.wouldCreateCycle(document, draggedId, targetId)) {
    return null;
  }
  return ReparentNodeDrag(targetId);
}

NodeId? _hitTest(MindMapLayout layout, Offset point, Set<NodeId> excluded) {
  NodeId? best;
  var bestArea = double.infinity;

  for (final entry in layout.nodes.entries) {
    if (excluded.contains(entry.key)) {
      continue;
    }
    final rect = Rect.fromLTWH(
      entry.value.x,
      entry.value.y,
      entry.value.width,
      entry.value.height,
    );
    if (!rect.contains(point)) {
      continue;
    }
    final area = rect.width * rect.height;
    if (area <= bestArea) {
      best = entry.key;
      bestArea = area;
    }
  }
  return best;
}

MindNode? _find(MindNode root, NodeId id) {
  for (final node in root.depthFirst) {
    if (node.id == id) {
      return node;
    }
  }
  return null;
}

class _NodeLocation {
  const _NodeLocation({
    required this.node,
    required this.parent,
    required this.index,
  });

  final MindNode node;
  final MindNode parent;
  final int index;
}

_NodeLocation? _locate(MindNode root, NodeId id) {
  for (var i = 0; i < root.children.length; i++) {
    final child = root.children[i];
    if (child.id == id) {
      return _NodeLocation(node: child, parent: root, index: i);
    }
    final nested = _locate(child, id);
    if (nested != null) {
      return nested;
    }
  }
  return null;
}
