import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_viewport.dart';
import 'test_canvas_theme.dart';

void main() {
  MindNode node(String id, {List<MindNode> children = const []}) {
    return MindNode(id: NodeId(id), text: id, children: children);
  }

  testWidgets('shows nodes and enables one-finger pan and pinch zoom', (
    tester,
  ) async {
    final document = MindMapDocument(
      root: node('root', children: [node('child')]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MindMapViewport(
            document: document,
            canvasTheme: testCanvasTheme(),
          ),
        ),
      ),
    );

    expect(find.text('root'), findsOneWidget);
    expect(find.text('child'), findsOneWidget);
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.panEnabled, isTrue);
    expect(viewer.scaleEnabled, isTrue);
    expect(viewer.minScale, 0.5);
    expect(viewer.maxScale, 2.5);
  });

  testWidgets('builds a canvas with about 100 nodes', (tester) async {
    final document = MindMapDocument(
      root: node('root', children: [for (var i = 0; i < 99; i++) node('n$i')]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MindMapViewport(
            document: document,
            canvasTheme: testCanvasTheme(),
          ),
        ),
      ),
    );

    expect(find.text('root'), findsOneWidget);
    expect(find.text('n0'), findsOneWidget);
    expect(find.text('n98'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('builds a canvas with about 200 nodes', (tester) async {
    final document = MindMapDocument(
      root: node('root', children: [for (var i = 0; i < 199; i++) node('n$i')]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MindMapViewport(
            document: document,
            canvasTheme: testCanvasTheme(),
          ),
        ),
      ),
    );

    expect(find.text('root'), findsOneWidget);
    expect(find.text('n0'), findsOneWidget);
    expect(find.text('n198'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selects a node on tap without storing coordinates', (
    tester,
  ) async {
    final document = MindMapDocument(
      root: node('root', children: [node('child')]),
    );
    NodeId? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MindMapViewport(
            document: document,
            canvasTheme: testCanvasTheme(),
            selectedId: const NodeId('root'),
            onNodeSelected: (id) => selected = id,
          ),
        ),
      ),
    );

    await tester.tap(find.text('child'));
    await tester.pump();

    expect(selected, const NodeId('child'));
  });
}
