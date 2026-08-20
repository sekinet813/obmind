import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:obmind/features/library/application/mind_map_preview_layout.dart';

/// Scaled-down layout sketch. Avoids building [InteractiveViewer] per file.
class MindMapPreviewTile extends StatelessWidget {
  const MindMapPreviewTile({super.key, required this.layout});

  final MindMapPreviewLayout? layout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (layout == null || layout!.boxes.isEmpty) {
      return ColoredBox(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.description_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: CustomPaint(
        painter: _PreviewPainter(
          layout: layout!,
          nodeColor: theme.colorScheme.primary.withValues(alpha: 0.55),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  const _PreviewPainter({required this.layout, required this.nodeColor});

  final MindMapPreviewLayout layout;
  final Color nodeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(
      size.width / layout.width,
      size.height / layout.height,
    );
    final dx = (size.width - layout.width * scale) / 2;
    final dy = (size.height - layout.height * scale) / 2;
    final paint = Paint()..color = nodeColor;
    for (final box in layout.boxes) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            dx + box.x * scale,
            dy + box.y * scale,
            math.max(box.width * scale, 2),
            math.max(box.height * scale, 2),
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PreviewPainter oldDelegate) {
    return oldDelegate.layout != layout || oldDelegate.nodeColor != nodeColor;
  }
}
