import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';

/// Painted diameter of the +/- control.
const double kCollapseToggleVisualSize = 24;

/// Tappable diameter. Larger than the visual so the control is easier to hit
/// without changing how big it looks.
const double kCollapseToggleHitSize = 44;

/// How far the visual center sits inward from the node edge along the branch.
const double kCollapseToggleInset = 4;

/// Local center of the collapse toggle inside a node of [nodeSize].
///
/// [direction] points from the node center toward the branch (children, or
/// outward from the parent when collapsed). Defaults to the right edge.
Offset collapseToggleCenter(Size nodeSize, Offset direction) {
  final center = Offset(nodeSize.width / 2, nodeSize.height / 2);
  var dx = direction.dx;
  var dy = direction.dy;
  if (dx.abs() < 1e-9 && dy.abs() < 1e-9) {
    dx = 1;
    dy = 0;
  }
  final tx = dx.abs() < 1e-9
      ? double.infinity
      : (nodeSize.width / 2) / dx.abs();
  final ty = dy.abs() < 1e-9
      ? double.infinity
      : (nodeSize.height / 2) / dy.abs();
  final t = math.min(tx, ty);
  final onEdge = Offset(center.dx + t * dx, center.dy + t * dy);
  final length = math.sqrt(dx * dx + dy * dy);
  final ux = dx / length;
  final uy = dy / length;
  return onEdge - Offset(ux * kCollapseToggleInset, uy * kCollapseToggleInset);
}

/// Branch direction for placing the collapse toggle on [node].
///
/// Prefers the average of visible children. When collapsed (or children are
/// missing from layout), uses the outward vector from [parent] to [node].
/// Falls back to rightward when neither is available (e.g. collapsed root).
Offset collapseToggleDirection({
  required MindNode node,
  required NodeLayout nodeLayout,
  required MindMapLayout layout,
  MindNode? parent,
}) {
  if (!node.collapsed) {
    var dx = 0.0;
    var dy = 0.0;
    var count = 0;
    final cx = nodeLayout.x + nodeLayout.width / 2;
    final cy = nodeLayout.y + nodeLayout.height / 2;
    for (final child in node.children) {
      final childLayout = layout[child.id];
      if (childLayout == null) {
        continue;
      }
      dx += (childLayout.x + childLayout.width / 2) - cx;
      dy += (childLayout.y + childLayout.height / 2) - cy;
      count++;
    }
    if (count > 0) {
      return Offset(dx, dy);
    }
  }

  if (parent != null) {
    final parentLayout = layout[parent.id];
    if (parentLayout != null) {
      return Offset(
        (nodeLayout.x + nodeLayout.width / 2) -
            (parentLayout.x + parentLayout.width / 2),
        (nodeLayout.y + nodeLayout.height / 2) -
            (parentLayout.y + parentLayout.height / 2),
      );
    }
  }

  return const Offset(1, 0);
}
