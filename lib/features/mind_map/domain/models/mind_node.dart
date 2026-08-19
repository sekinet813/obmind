import 'package:obmind/features/mind_map/domain/models/node_id.dart';

/// A node in a mind map tree.
///
/// Display coordinates are not part of this model. Layout engines compute
/// [NodeLayout] outside Domain.
final class MindNode {
  MindNode({
    required this.id,
    required this.text,
    List<MindNode> children = const [],
    this.collapsed = false,
    Map<String, String> metadata = const {},
  }) : children = List<MindNode>.unmodifiable(children),
       metadata = Map<String, String>.unmodifiable(metadata);

  final NodeId id;
  final String text;
  final List<MindNode> children;
  final bool collapsed;

  /// Unknown Markdown comment attributes preserved for round-trip.
  final Map<String, String> metadata;

  /// This node followed by descendants in depth-first order.
  Iterable<MindNode> get depthFirst sync* {
    yield this;
    for (final child in children) {
      yield* child.depthFirst;
    }
  }

  MindNode copyWith({
    NodeId? id,
    String? text,
    List<MindNode>? children,
    bool? collapsed,
    Map<String, String>? metadata,
  }) {
    return MindNode(
      id: id ?? this.id,
      text: text ?? this.text,
      children: children ?? this.children,
      collapsed: collapsed ?? this.collapsed,
      metadata: metadata ?? this.metadata,
    );
  }
}
