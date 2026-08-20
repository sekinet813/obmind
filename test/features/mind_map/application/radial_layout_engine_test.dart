import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/application/layout/radial_layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

void main() {
  const engine = RadialLayoutEngine(
    radialGap: 40,
    siblingGap: 10,
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

  double centerX(NodeLayout layout) => layout.x + layout.width / 2;

  double centerY(NodeLayout layout) => layout.y + layout.height / 2;

  double distance(NodeLayout a, NodeLayout b) {
    final dx = centerX(a) - centerX(b);
    final dy = centerY(a) - centerY(b);
    return math.sqrt(dx * dx + dy * dy);
  }

  bool overlaps(NodeLayout a, NodeLayout b) {
    return a.x < b.x + b.width &&
        a.x + a.width > b.x &&
        a.y < b.y + b.height &&
        a.y + a.height > b.y;
  }

  test('places the first root child to the right of the root', () {
    final child = node('a');
    final document = MindMapDocument(
      root: node('root', children: [child, node('b')]),
    );

    final layout = engine.layout(document, nodeSizes: sizesFor(document));
    final root = layout[const NodeId('root')]!;
    final a = layout[const NodeId('a')]!;
    final b = layout[const NodeId('b')]!;

    expect(centerX(a), greaterThan(centerX(root)));
    expect(overlaps(root, a), isFalse);
    expect(overlaps(a, b), isFalse);
    expect(document.root.children.first, same(child));
  });

  test('places grandchildren farther out in the parent direction', () {
    final document = MindMapDocument(
      root: node(
        'root',
        children: [
          node('a', children: [node('a1')]),
        ],
      ),
    );

    final layout = engine.layout(document, nodeSizes: sizesFor(document));
    final root = layout[const NodeId('root')]!;
    final a = layout[const NodeId('a')]!;
    final a1 = layout[const NodeId('a1')]!;

    expect(distance(root, a1), greaterThan(distance(root, a)));
    expect(centerX(a1), greaterThan(centerX(a)));
  });

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

  test('does not mutate domain nodes', () {
    final child = node('a');
    final document = MindMapDocument(
      root: node('root', children: [child, node('b')]),
    );

    engine.layout(document, nodeSizes: sizesFor(document));

    expect(document.root.children.first, same(child));
    expect(document.root.children, hasLength(2));
  });

  test('keeps coordinates non-negative', () {
    final document = MindMapDocument(
      root: node('root', children: [node('a'), node('b'), node('c')]),
    );

    final layout = engine.layout(document, nodeSizes: sizesFor(document));

    for (final nodeLayout in layout.nodes.values) {
      expect(nodeLayout.x, greaterThanOrEqualTo(0));
      expect(nodeLayout.y, greaterThanOrEqualTo(0));
    }
    expect(layout.width.isFinite, isTrue);
    expect(layout.height.isFinite, isTrue);
  });

  test('layouts about 100 nodes stably without overlapping siblings', () {
    final document = MindMapDocument(
      root: node('root', children: [for (var i = 0; i < 99; i++) node('n$i')]),
    );
    final sizes = sizesFor(document);

    final first = engine.layout(document, nodeSizes: sizes);
    final second = engine.layout(document, nodeSizes: sizes);

    expect(first.nodes, hasLength(100));
    expect(first.width.isFinite, isTrue);
    expect(first.height.isFinite, isTrue);
    expect(first.width, second.width);
    expect(first.height, second.height);

    final siblings = [for (var i = 0; i < 99; i++) first[NodeId('n$i')]!];
    for (var i = 1; i < siblings.length; i++) {
      expect(overlaps(siblings[i - 1], siblings[i]), isFalse);
    }
    expect(overlaps(siblings.first, siblings.last), isFalse);
  });
}
