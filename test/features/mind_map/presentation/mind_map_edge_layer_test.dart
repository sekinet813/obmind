import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/layout/horizontal_layout_engine.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
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
}
