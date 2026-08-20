import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/models/layout_type.dart';
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

  testWidgets('keeps pan and zoom enabled while a node is editing', (
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
            editingId: const NodeId('child'),
            editingController: TextEditingController(text: 'child'),
            onEditingComplete: () {},
          ),
        ),
      ),
    );

    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.panEnabled, isTrue);
    expect(viewer.scaleEnabled, isTrue);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('zoomBy clamps to min and max scale', (tester) async {
    final document = MindMapDocument(root: node('root'));
    final controller = TransformationController();
    final viewportKey = GlobalKey<MindMapViewportState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MindMapViewport(
            key: viewportKey,
            document: document,
            canvasTheme: testCanvasTheme(),
            transformationController: controller,
            minScale: 0.5,
            maxScale: 2.5,
          ),
        ),
      ),
    );

    viewportKey.currentState!.zoomIn();
    await tester.pump();
    expect(controller.value.getMaxScaleOnAxis(), closeTo(1.25, 0.001));

    for (var i = 0; i < 10; i++) {
      viewportKey.currentState!.zoomIn();
    }
    await tester.pump();
    expect(controller.value.getMaxScaleOnAxis(), 2.5);

    for (var i = 0; i < 14; i++) {
      viewportKey.currentState!.zoomOut();
    }
    await tester.pump();
    expect(controller.value.getMaxScaleOnAxis(), 0.5);
  });

  testWidgets('uses radial layout when the document layout is radial', (
    tester,
  ) async {
    final document = MindMapDocument(
      layout: LayoutType.radial,
      root: node('root', children: [node('a'), node('b')]),
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
    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
