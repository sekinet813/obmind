import 'package:obmind/features/mind_map/domain/models/layout_type.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_theme_id.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

/// In-memory mind map. Markdown on disk remains the source of truth.
///
/// Display coordinates are computed by a layout engine, not stored here.
final class MindMapDocument {
  MindMapDocument({
    this.id,
    required this.root,
    this.theme = MindMapThemeId.minimal,
    this.layout = LayoutType.horizontal,
  }) {
    _ensureUniqueNodeIds();
  }

  /// Optional document identity, independent from the file location.
  final String? id;

  final MindNode root;
  final MindMapThemeId theme;
  final LayoutType layout;

  /// Same as [MindNode.text] on [root].
  String get title => root.text;

  List<NodeId> get nodeIds =>
      root.depthFirst.map((node) => node.id).toList(growable: false);

  MindMapDocument copyWith({
    String? id,
    MindNode? root,
    MindMapThemeId? theme,
    LayoutType? layout,
    bool clearId = false,
  }) {
    return MindMapDocument(
      id: clearId ? null : (id ?? this.id),
      root: root ?? this.root,
      theme: theme ?? this.theme,
      layout: layout ?? this.layout,
    );
  }

  void _ensureUniqueNodeIds() {
    final seen = <String>{};
    for (final node in root.depthFirst) {
      final value = node.id.value;
      if (value.isEmpty) {
        throw ArgumentError.value(node.id, 'id', 'NodeId must not be empty');
      }
      if (!seen.add(value)) {
        throw ArgumentError.value(
          node.id,
          'id',
          'duplicate NodeId in document',
        );
      }
    }
  }
}
