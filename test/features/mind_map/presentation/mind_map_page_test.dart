import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_page.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_viewport.dart';
import 'package:obmind/features/mind_map/presentation/mind_node_widget.dart';
import 'package:obmind/l10n/app_localizations.dart';

void main() {
  MindNode node(String id, {List<MindNode> children = const []}) {
    return MindNode(id: NodeId(id), text: id, children: children);
  }

  int nextId = 0;

  Widget app(MindMapDocument document, {NodeId? initialSelectedId}) {
    nextId = 0;
    return MaterialApp(
      locale: const Locale('ja'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MindMapPage(
        document: document,
        initialSelectedId: initialSelectedId,
        generateId: () {
          nextId += 1;
          return NodeId('new-$nextId');
        },
      ),
    );
  }

  testWidgets('adds a child under the selected node', (tester) async {
    await tester.pumpWidget(
      app(MindMapDocument(root: node('root', children: [node('a')]))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addChildNode')));
    await tester.pumpAndSettle();

    expect(find.text('新しいノード'), findsOneWidget);
    expect(find.text('a'), findsOneWidget);
  });

  testWidgets('adds a sibling after the selected non-root node', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        MindMapDocument(root: node('root', children: [node('a')])),
        initialSelectedId: const NodeId('a'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addSiblingNode')));
    await tester.pumpAndSettle();

    expect(find.text('新しいノード'), findsOneWidget);
    expect(find.text('a'), findsOneWidget);
  });

  testWidgets('deletes the selected non-root node', (tester) async {
    await tester.pumpWidget(
      app(
        MindMapDocument(root: node('root', children: [node('a')])),
        initialSelectedId: const NodeId('a'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('deleteNode')));
    await tester.pumpAndSettle();

    expect(find.text('a'), findsNothing);
    expect(find.widgetWithText(MindNodeWidget, 'root'), findsOneWidget);
  });

  testWidgets('collapses descendants of the selected node', (tester) async {
    await tester.pumpWidget(
      app(
        MindMapDocument(
          root: node(
            'root',
            children: [
              node('a', children: [node('a1')]),
            ],
          ),
        ),
        initialSelectedId: const NodeId('a'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('toggleCollapsedNode')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(MindNodeWidget, 'a1'), findsNothing);
    expect(find.widgetWithText(MindNodeWidget, 'a'), findsOneWidget);

    await tester.tap(find.text('展開'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(MindNodeWidget, 'a1'), findsOneWidget);
  });

  testWidgets('toggles collapse from the node plus minus button', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        MindMapDocument(
          root: node(
            'root',
            children: [
              node('a', children: [node('a1')]),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(MindNodeWidget, 'a1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('collapseToggle-a')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(MindNodeWidget, 'a1'), findsNothing);
    expect(find.byKey(const Key('toggleCollapsedNode')), findsOneWidget);

    await tester.tap(find.byKey(const Key('collapseToggle-a')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(MindNodeWidget, 'a1'), findsOneWidget);
  });

  testWidgets('exits inline editing with the done action', (tester) async {
    await tester.pumpWidget(
      app(
        MindMapDocument(root: node('root', children: [node('a')])),
        initialSelectedId: const NodeId('a'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('編集'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byKey(const Key('doneEditingNode')), findsOneWidget);
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.panEnabled, isTrue);
    expect(viewer.scaleEnabled, isTrue);

    await tester.enterText(find.byType(TextField), '更新後');
    await tester.tap(find.byKey(const Key('doneEditingNode')));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('更新後'), findsOneWidget);
    expect(find.text('編集'), findsOneWidget);
  });

  testWidgets('exits inline editing when tapping another node', (tester) async {
    await tester.pumpWidget(
      app(
        MindMapDocument(root: node('root', children: [node('a')])),
        initialSelectedId: const NodeId('a'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('編集'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.widgetWithText(MindNodeWidget, 'root'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('編集'), findsOneWidget);
  });

  testWidgets('zoom buttons change scale and stay within min and max', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(MindMapDocument(root: node('root', children: [node('a')]))),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('zoomIn')), findsOneWidget);
    expect(find.byKey(const Key('zoomOut')), findsOneWidget);
    expect(find.byTooltip('全体表示'), findsOneWidget);
    expect(find.byKey(const Key('centerOnRoot')), findsOneWidget);
    expect(find.byTooltip('中心へ戻る'), findsOneWidget);

    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    final controller = viewer.transformationController!;
    final initial = controller.value.getMaxScaleOnAxis();

    await tester.tap(find.byKey(const Key('zoomIn')));
    await tester.pump();
    expect(controller.value.getMaxScaleOnAxis(), greaterThan(initial));

    for (var i = 0; i < 12; i++) {
      await tester.tap(find.byKey(const Key('zoomIn')));
      await tester.pump();
    }
    expect(
      controller.value.getMaxScaleOnAxis(),
      closeTo(viewer.maxScale, 0.001),
    );

    for (var i = 0; i < 16; i++) {
      await tester.tap(find.byKey(const Key('zoomOut')));
      await tester.pump();
    }
    expect(
      controller.value.getMaxScaleOnAxis(),
      closeTo(viewer.minScale, 0.001),
    );
  });

  testWidgets('center on root recenters without using fit-to-screen scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(MindMapDocument(root: node('root', children: [node('a')]))),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(InteractiveViewer), const Offset(120, 80));
    await tester.pump();
    final panned = tester.getCenter(
      find.widgetWithText(MindNodeWidget, 'root'),
    );

    await tester.tap(find.byKey(const Key('centerOnRoot')));
    await tester.pump();

    final viewport = tester.getRect(find.byType(MindMapViewport));
    final centered = tester.getCenter(
      find.widgetWithText(MindNodeWidget, 'root'),
    );
    expect(centered, isNot(panned));
    expect(centered.dx, closeTo(viewport.center.dx, 48));
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 1);
    expect(find.byTooltip('全体表示'), findsOneWidget);
  });

  testWidgets('zoom buttons remain available while editing a node', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        MindMapDocument(root: node('root', children: [node('a')])),
        initialSelectedId: const NodeId('a'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('編集'));
    await tester.pumpAndSettle();

    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.scaleEnabled, isTrue);
    expect(find.byKey(const Key('zoomIn')), findsOneWidget);
    expect(find.byKey(const Key('zoomOut')), findsOneWidget);
  });

  testWidgets('shows the file name, autosave status, and settings action', (
    tester,
  ) async {
    var openedSettings = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MindMapPage(
          document: MindMapDocument(root: node('root')),
          file: const MindMapFile(
            location: MindMapLocation('vault/idea.md'),
            displayName: 'idea.md',
          ),
          onOpenSettings: () => openedSettings = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('idea.md'), findsOneWidget);
    expect(find.text('自動保存'), findsOneWidget);
    expect(find.byKey(const Key('zoomIn')), findsOneWidget);
    await tester.tap(find.byKey(const Key('openMapSettings')));
    await tester.pump();
    expect(openedSettings, isTrue);
  });

  testWidgets('switches layout from the app bar and keeps nodes visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(MindMapDocument(root: node('root', children: [node('a')]))),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('switchLayout')), findsOneWidget);
    expect(find.byIcon(Icons.account_tree_outlined), findsOneWidget);

    await tester.tap(find.byKey(const Key('switchLayout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('layoutRadial')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.hub_outlined), findsOneWidget);
    expect(find.widgetWithText(MindNodeWidget, 'root'), findsOneWidget);
    expect(find.widgetWithText(MindNodeWidget, 'a'), findsOneWidget);

    await tester.tap(find.byKey(const Key('switchLayout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('layoutHorizontal')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.account_tree_outlined), findsOneWidget);
    expect(find.widgetWithText(MindNodeWidget, 'root'), findsOneWidget);
    expect(find.widgetWithText(MindNodeWidget, 'a'), findsOneWidget);
  });

  testWidgets('keeps the editing node above the software keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      app(
        MindMapDocument(root: node('root', children: [node('a')])),
        initialSelectedId: const NodeId('a'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('zoomIn')));
    await tester.pump();
    final scaleBefore = tester
        .widget<InteractiveViewer>(find.byType(InteractiveViewer))
        .transformationController!
        .value
        .getMaxScaleOnAxis();

    await tester.tap(find.text('編集'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    tester.view.viewInsets = const FakeViewPadding(bottom: 360);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();
    await tester.pump();

    final keyboardTop =
        tester.view.physicalSize.height / tester.view.devicePixelRatio - 360;
    final field = tester.getRect(find.byType(TextField));
    expect(field.bottom, lessThanOrEqualTo(keyboardTop));
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(
      viewer.transformationController!.value.getMaxScaleOnAxis(),
      closeTo(scaleBefore, 0.001),
    );
  });
}
