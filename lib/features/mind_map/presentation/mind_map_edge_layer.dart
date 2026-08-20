import 'package:flutter/material.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';

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
        final start = Offset(
          parentLayout.x + parentLayout.width,
          parentLayout.y + parentLayout.height / 2,
        );
        final end = Offset(
          childLayout.x,
          childLayout.y + childLayout.height / 2,
        );
        final midX = (start.dx + end.dx) / 2;
        final path = Path()
          ..moveTo(start.dx, start.dy)
          ..cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);
        canvas.drawPath(path, paint);
      }
      _paintEdges(canvas, paint, child);
    }
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
