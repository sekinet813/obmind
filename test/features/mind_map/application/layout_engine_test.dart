import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

/// Sequential layout used only to prove the Domain → Layout contract.
class _SequentialLayoutEngine implements LayoutEngine {
  static const _fallback = NodeSize(width: 80, height: 40);
  static const _gap = 16.0;

  @override
  MindMapLayout layout(
    MindMapDocument document, {
    required Map<NodeId, NodeSize> nodeSizes,
  }) {
    final nodes = <NodeId, NodeLayout>{};
    var x = 0.0;
    var maxHeight = 0.0;

    for (final node in document.root.depthFirst) {
      final size = nodeSizes[node.id] ?? _fallback;
      nodes[node.id] = NodeLayout(
        id: node.id,
        x: x,
        y: 0,
        width: size.width,
        height: size.height,
      );
      x += size.width + _gap;
      if (size.height > maxHeight) {
        maxHeight = size.height;
      }
    }

    final width = nodes.isEmpty ? 0.0 : x - _gap;
    return MindMapLayout(
      nodes: Map.unmodifiable(nodes),
      width: width,
      height: maxHeight,
    );
  }
}

void main() {
  MindNode node(String id, {List<MindNode> children = const []}) {
    return MindNode(id: NodeId(id), text: id, children: children);
  }

  test('layout engine returns NodeLayout without mutating the document', () {
    final child = node('a');
    final document = MindMapDocument(
      root: node('root', children: [child, node('b')]),
    );
    final sizes = {
      const NodeId('root'): const NodeSize(width: 100, height: 40),
      const NodeId('a'): const NodeSize(width: 80, height: 40),
      const NodeId('b'): const NodeSize(width: 80, height: 48),
    };

    final layout = _SequentialLayoutEngine().layout(document, nodeSizes: sizes);

    expect(layout.nodes.keys.map((id) => id.value), ['root', 'a', 'b']);
    expect(layout[const NodeId('root')]?.x, 0);
    expect(layout[const NodeId('a')]?.x, 100 + 16);
    expect(layout.width, 100 + 16 + 80 + 16 + 80);
    expect(layout.height, 48);

    expect(document.root.children, hasLength(2));
    expect(document.root.children.first, same(child));
    expect(document.nodeIds.map((id) => id.value), ['root', 'a', 'b']);
  });

  test('NodeLayout is keyed by NodeId, not by display text', () {
    final document = MindMapDocument(
      root: MindNode(
        id: const NodeId('root-id'),
        text: 'タイトル',
        children: [MindNode(id: const NodeId('child-id'), text: 'タイトル')],
      ),
    );

    final layout = _SequentialLayoutEngine().layout(
      document,
      nodeSizes: {
        const NodeId('root-id'): const NodeSize(width: 10, height: 10),
        const NodeId('child-id'): const NodeSize(width: 10, height: 10),
      },
    );

    expect(layout[const NodeId('root-id')], isNotNull);
    expect(layout[const NodeId('child-id')], isNotNull);
    expect(layout.nodes, hasLength(2));
  });
}
