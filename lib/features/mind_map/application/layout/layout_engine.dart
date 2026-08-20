import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

/// Measured size of a node, supplied by Presentation.
///
/// Layout engines consume this value and must not depend on Flutter widgets.
final class NodeSize {
  const NodeSize({required this.width, required this.height});

  final double width;
  final double height;
}

/// Computed position and size of one node in layout space.
///
/// This is a display-time value. It is not stored on [MindNode] and is not
/// persisted to Markdown.
final class NodeLayout {
  const NodeLayout({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final NodeId id;
  final double x;
  final double y;
  final double width;
  final double height;
}

/// Layout snapshot for a [MindMapDocument]. Not persisted.
final class MindMapLayout {
  const MindMapLayout({
    required this.nodes,
    required this.width,
    required this.height,
  });

  /// Layouts keyed by node id. Engines may omit collapsed descendants.
  final Map<NodeId, NodeLayout> nodes;
  final double width;
  final double height;

  NodeLayout? operator [](NodeId id) => nodes[id];
}

/// Computes display coordinates from a domain document.
///
/// Implementations must not mutate [MindMapDocument] or write `x` / `y` onto
/// domain nodes. Coordinates stay in [MindMapLayout].
abstract interface class LayoutEngine {
  MindMapLayout layout(
    MindMapDocument document, {
    required Map<NodeId, NodeSize> nodeSizes,
  });
}
