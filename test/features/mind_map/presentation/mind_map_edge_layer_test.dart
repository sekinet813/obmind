import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/layout/horizontal_layout_engine.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/application/layout/radial_layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/layout_type.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_edge_layer.dart';

void main() {
  MindNode node(String id, {List<MindNode> children = const []}) {
    return MindNode(id: NodeId(id), text: id, children: children);
  }

  testWidgets('paints edges for parent-child pairs present in the layout', (
    tester,
  ) async {
    final document = MindMapDocument(
      root: node('root', children: [node('a'), node('b')]),
    );
    final layout = const HorizontalLayoutEngine().layout(
      document,
      nodeSizes: {
        for (final item in document.root.depthFirst)
          item.id: const NodeSize(width: 80, height: 40),
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MindMapEdgeLayer(
            document: document,
            layout: layout,
            color: const Color(0xFF000000),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('mind-map-edges')), paints..path());
  });

  testWidgets('skips edges when the child is omitted from layout', (
    tester,
  ) async {
    final document = MindMapDocument(
      root: node('root', children: [node('hidden')]),
    );
    final layout = MindMapLayout(
      nodes: {
        const NodeId('root'): const NodeLayout(
          id: NodeId('root'),
          x: 0,
          y: 0,
          width: 80,
          height: 40,
        ),
      },
      width: 80,
      height: 40,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MindMapEdgeLayer(
            document: document,
            layout: layout,
            color: const Color(0xFF000000),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('mind-map-edges')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('anchors radial edges on the facing sides of parent and child', () {
    const parent = NodeLayout(
      id: NodeId('root'),
      x: 100,
      y: 100,
      width: 80,
      height: 40,
    );
    const leftChild = NodeLayout(
      id: NodeId('left'),
      x: 0,
      y: 100,
      width: 80,
      height: 40,
    );
    const rightChild = NodeLayout(
      id: NodeId('right'),
      x: 200,
      y: 100,
      width: 80,
      height: 40,
    );

    final parentCenter = Offset(parent.x + parent.width / 2, parent.y + 20);
    final leftCenter = Offset(leftChild.x + 40, leftChild.y + 20);
    final rightCenter = Offset(rightChild.x + 40, rightChild.y + 20);

    final toLeft = edgeAnchor(parent, leftCenter);
    final fromLeft = edgeAnchor(leftChild, parentCenter);
    expect(toLeft.dx, closeTo(parent.x, 0.001));
    expect(fromLeft.dx, closeTo(leftChild.x + leftChild.width, 0.001));

    final toRight = edgeAnchor(parent, rightCenter);
    final fromRight = edgeAnchor(rightChild, parentCenter);
    expect(toRight.dx, closeTo(parent.x + parent.width, 0.001));
    expect(fromRight.dx, closeTo(rightChild.x, 0.001));
  });

  testWidgets('paints radial edges for children around the root', (
    tester,
  ) async {
    final document = MindMapDocument(
      layout: LayoutType.radial,
      root: node(
        'root',
        children: [node('a'), node('b'), node('c'), node('d')],
      ),
    );
    final layout = const RadialLayoutEngine().layout(
      document,
      nodeSizes: {
        for (final item in document.root.depthFirst)
          item.id: const NodeSize(width: 80, height: 40),
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MindMapEdgeLayer(
            document: document,
            layout: layout,
            color: const Color(0xFF000000),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('mind-map-edges')), paints..path());
    expect(tester.takeException(), isNull);
  });
}
