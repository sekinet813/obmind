import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/layout/horizontal_layout_engine.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

void main() {
  const engine = HorizontalLayoutEngine(
    horizontalGap: 40,
    verticalGap: 10,
    fallbackSize: NodeSize(width: 80, height: 40),
  );

  MindNode node(
    String id, {
    List<MindNode> children = const [],
    bool collapsed = false,
  }) {
    return MindNode(
      id: NodeId(id),
      text: id,
      children: children,
      collapsed: collapsed,
    );
  }

  Map<NodeId, NodeSize> sizesFor(
    MindMapDocument document, {
    double width = 80,
    double height = 40,
  }) {
    return {
      for (final n in document.root.depthFirst)
        n.id: NodeSize(width: width, height: height),
    };
  }

  bool overlaps(NodeLayout a, NodeLayout b) {
    return a.x < b.x + b.width &&
        a.x + a.width > b.x &&
        a.y < b.y + b.height &&
        a.y + a.height > b.y;
  }

  test(
    'places children to the right of the parent without overlapping siblings',
    () {
      final child = node('a');
      final document = MindMapDocument(
        root: node('root', children: [child, node('b')]),
      );
      final sizes = sizesFor(document);

      final layout = engine.layout(document, nodeSizes: sizes);
      final root = layout[const NodeId('root')]!;
      final a = layout[const NodeId('a')]!;
      final b = layout[const NodeId('b')]!;

      expect(a.x, root.x + root.width + 40);
      expect(b.x, a.x);
      expect(b.y, greaterThanOrEqualTo(a.y + a.height + 10));
      expect(overlaps(a, b), isFalse);
      expect(overlaps(root, a), isFalse);
      expect(document.root.children.first, same(child));
    },
  );

  test('omits collapsed descendants from the layout', () {
    final document = MindMapDocument(
      root: node(
        'root',
        children: [
          node('hidden', collapsed: true, children: [node('secret')]),
          node('visible'),
        ],
      ),
    );

    final layout = engine.layout(document, nodeSizes: sizesFor(document));

    expect(layout[const NodeId('hidden')], isNotNull);
    expect(layout[const NodeId('secret')], isNull);
    expect(layout[const NodeId('visible')], isNotNull);
  });

  test('same input produces a stable layout', () {
    final document = MindMapDocument(
      root: node(
        'root',
        children: [
          node('a', children: [node('a1'), node('a2')]),
          node('b'),
        ],
      ),
    );
    final sizes = sizesFor(document);

    final first = engine.layout(document, nodeSizes: sizes);
    final second = engine.layout(document, nodeSizes: sizes);

    expect(first.width, second.width);
    expect(first.height, second.height);
    for (final id in first.nodes.keys) {
      expect(first[id]!.x, second[id]!.x);
      expect(first[id]!.y, second[id]!.y);
    }
  });

  test('keys layouts by NodeId even when texts match', () {
    final document = MindMapDocument(
      root: MindNode(
        id: const NodeId('root-id'),
        text: 'タイトル',
        children: [MindNode(id: const NodeId('child-id'), text: 'タイトル')],
      ),
    );

    final layout = engine.layout(
      document,
      nodeSizes: {
        const NodeId('root-id'): const NodeSize(width: 10, height: 10),
        const NodeId('child-id'): const NodeSize(width: 10, height: 10),
      },
    );

    expect(layout[const NodeId('root-id')], isNotNull);
    expect(layout[const NodeId('child-id')], isNotNull);
    expect(
      layout[const NodeId('child-id')]!.x,
      greaterThan(layout[const NodeId('root-id')]!.x),
    );
  });
}
