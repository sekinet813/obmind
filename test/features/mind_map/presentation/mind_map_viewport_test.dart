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

  testWidgets('centers the root in the viewport when a map is opened', (
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
    await tester.pump();

    final viewport = tester.getRect(find.byType(MindMapViewport));
    final rootCenter = tester.getCenter(find.text('root'));
    expect(rootCenter.dx, closeTo(viewport.center.dx, 24));
    expect(rootCenter.dy, closeTo(viewport.center.dy, 24));
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 1);
  });

  testWidgets('centers the root for radial layout without shrinking', (
    tester,
  ) async {
    final document = MindMapDocument(
      layout: LayoutType.radial,
      root: node('root', children: [for (var i = 0; i < 12; i++) node('n$i')]),
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
    await tester.pump();

    final viewport = tester.getRect(find.byType(MindMapViewport));
    final rootCenter = tester.getCenter(find.text('root'));
    expect(rootCenter.dx, closeTo(viewport.center.dx, 24));
    expect(rootCenter.dy, closeTo(viewport.center.dy, 24));
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 1);
  });

  testWidgets('keeps a user pan after the initial root centering', (
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
    await tester.pump();

    await tester.drag(find.byType(InteractiveViewer), const Offset(80, 50));
    await tester.pump();
    final afterPan = tester.getCenter(find.text('root'));

    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getCenter(find.text('root')), afterPan);
  });

  testWidgets('reserves bottom padding so root stays in the canvas', (
    tester,
  ) async {
    final document = MindMapDocument(root: node('root'));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MindMapViewport(
            document: document,
            canvasTheme: testCanvasTheme(),
            centerPadding: const EdgeInsets.only(bottom: 80),
          ),
        ),
      ),
    );
    await tester.pump();

    final viewport = tester.getRect(find.byType(MindMapViewport));
    final rootCenter = tester.getCenter(find.text('root'));
    final expectedY = viewport.top + (viewport.height - 80) / 2;
    expect(rootCenter.dx, closeTo(viewport.center.dx, 24));
    expect(rootCenter.dy, closeTo(expectedY, 24));
    expect(rootCenter.dy, lessThan(viewport.bottom - 80));
  });

  testWidgets('keeps the root on screen when radial children are added', (
    tester,
  ) async {
    final viewportKey = GlobalKey<MindMapViewportState>();

    Widget app(MindMapDocument document) {
      return MaterialApp(
        home: Scaffold(
          body: MindMapViewport(
            key: viewportKey,
            document: document,
            canvasTheme: testCanvasTheme(),
          ),
        ),
      );
    }

    await tester.pumpWidget(
      app(
        MindMapDocument(
          layout: LayoutType.radial,
          root: node('root', children: [node('a')]),
        ),
      ),
    );
    await tester.pump();
    final before = tester.getCenter(find.text('root'));

    await tester.pumpWidget(
      app(
        MindMapDocument(
          layout: LayoutType.radial,
          root: node('root', children: [node('a'), node('b')]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final after = tester.getCenter(find.text('root'));
    expect(after.dx, closeTo(before.dx, 8));
    expect(after.dy, closeTo(before.dy, 8));
  });

  testWidgets('ensureNodeVisible pans a node back into the canvas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(240, 240);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final document = MindMapDocument(
      root: node('root', children: [node('child')]),
    );
    final viewportKey = GlobalKey<MindMapViewportState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MindMapViewport(
            key: viewportKey,
            document: document,
            canvasTheme: testCanvasTheme(),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.drag(find.byType(InteractiveViewer), const Offset(-280, 0));
    await tester.pump();

    final size = tester.getSize(find.byType(MindMapViewport));
    viewportKey.currentState!.ensureNodeVisible(const NodeId('child'), size);
    await tester.pump();

    final viewport = tester.getRect(find.byType(MindMapViewport));
    final childRect = tester.getRect(find.text('child'));
    expect(viewport.overlaps(childRect), isTrue);
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 1);
  });
}
