import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/layout_type.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';

/// Intersection of the ray from [node] center toward [target] with the node rect.
Offset edgeAnchor(NodeLayout node, Offset target) {
  final center = Offset(node.x + node.width / 2, node.y + node.height / 2);
  final dx = target.dx - center.dx;
  final dy = target.dy - center.dy;
  if (dx.abs() < 1e-9 && dy.abs() < 1e-9) {
    return center;
  }
  final tx = dx.abs() < 1e-9 ? double.infinity : (node.width / 2) / dx.abs();
  final ty = dy.abs() < 1e-9 ? double.infinity : (node.height / 2) / dy.abs();
  final t = math.min(tx, ty);
  return Offset(center.dx + t * dx, center.dy + t * dy);
}

/// Draws parent-to-child edges from [MindMapLayout]. Missing layouts are skipped.
final class MindMapEdgePainter extends CustomPainter {
  const MindMapEdgePainter({
    required this.document,
    required this.layout,
    required this.color,
    this.strokeWidth = 1.5,
  });

  final MindMapDocument document;
  final MindMapLayout layout;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _paintEdges(canvas, paint, document.root);
  }

  void _paintEdges(Canvas canvas, Paint paint, MindNode parent) {
    final parentLayout = layout[parent.id];
    for (final child in parent.children) {
      final childLayout = layout[child.id];
      if (parentLayout != null && childLayout != null) {
        canvas.drawPath(_edgePath(parentLayout, childLayout), paint);
      }
      _paintEdges(canvas, paint, child);
    }
  }

  Path _edgePath(NodeLayout parentLayout, NodeLayout childLayout) {
    if (document.layout == LayoutType.radial) {
      final parentCenter = Offset(
        parentLayout.x + parentLayout.width / 2,
        parentLayout.y + parentLayout.height / 2,
      );
      final childCenter = Offset(
        childLayout.x + childLayout.width / 2,
        childLayout.y + childLayout.height / 2,
      );
      final start = edgeAnchor(parentLayout, childCenter);
      final end = edgeAnchor(childLayout, parentCenter);
      return _curvedPath(start, end);
    }

    final start = Offset(
      parentLayout.x + parentLayout.width,
      parentLayout.y + parentLayout.height / 2,
    );
    final end = Offset(childLayout.x, childLayout.y + childLayout.height / 2);
    final midX = (start.dx + end.dx) / 2;
    return Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);
  }

  Path _curvedPath(Offset start, Offset end) {
    final dx = (end.dx - start.dx).abs();
    final dy = (end.dy - start.dy).abs();
    final path = Path()..moveTo(start.dx, start.dy);
    if (dx >= dy) {
      final midX = (start.dx + end.dx) / 2;
      path.cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);
    } else {
      final midY = (start.dy + end.dy) / 2;
      path.cubicTo(start.dx, midY, end.dx, midY, end.dx, end.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant MindMapEdgePainter oldDelegate) {
    return oldDelegate.document != document ||
        oldDelegate.layout != layout ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Edge layer sized to the layout bounds.
class MindMapEdgeLayer extends StatelessWidget {
  const MindMapEdgeLayer({
    super.key,
    required this.document,
    required this.layout,
    this.color,
  });

  final MindMapDocument document;
  final MindMapLayout layout;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: const ValueKey('mind-map-edges'),
      size: Size(layout.width, layout.height),
      painter: MindMapEdgePainter(
        document: document,
        layout: layout,
        color: color ?? Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
