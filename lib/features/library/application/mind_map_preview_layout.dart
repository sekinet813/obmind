/// Lightweight layout snapshot for Library tiles. Not persisted to Markdown.
final class MindMapPreviewLayout {
  const MindMapPreviewLayout({
    required this.boxes,
    required this.width,
    required this.height,
  });

  final List<MindMapPreviewBox> boxes;
  final double width;
  final double height;
}

final class MindMapPreviewBox {
  const MindMapPreviewBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;
}
