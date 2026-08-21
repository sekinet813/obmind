import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/rename_mind_map.dart';
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

  double nodeRadius(WidgetTester tester, String text) {
    final decorated = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.widgetWithText(MindNodeWidget, text),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    return (decorated.decoration as BoxDecoration).borderRadius!
        .resolve(TextDirection.ltr)
        .topLeft
        .x;
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

    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration!.hintText,
      '新規ノード',
    );
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

    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration!.hintText,
      '新規ノード',
    );
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

  testWidgets('shows the file name and autosave status without settings', (
    tester,
  ) async {
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
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('idea.md'), findsOneWidget);
    expect(find.text('自動保存'), findsOneWidget);
    expect(find.byKey(const Key('saveMindMap')), findsNothing);
    expect(find.text('保存'), findsNothing);
    expect(find.byKey(const Key('zoomIn')), findsOneWidget);
    expect(find.byKey(const Key('switchLayout')), findsOneWidget);
    expect(find.byKey(const Key('openMapSettings')), findsNothing);
    expect(find.byTooltip('設定'), findsNothing);
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

  testWidgets('applies a design theme without changing layout', (tester) async {
    await tester.pumpWidget(
      app(MindMapDocument(root: node('root', children: [node('a')]))),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('switchDesignTemplate')), findsOneWidget);
    expect(find.byIcon(Icons.account_tree_outlined), findsOneWidget);

    await tester.tap(find.byKey(const Key('switchDesignTemplate')));
    await tester.pumpAndSettle();
    expect(find.text('ペーパー'), findsOneWidget);
    expect(find.text('インク'), findsOneWidget);
    expect(find.text('ダーク'), findsOneWidget);
    expect(find.text('ミニマル'), findsOneWidget);
    expect(find.text('ソフト'), findsNothing);
    expect(find.text('ソフト水平'), findsNothing);
    await tester.tap(find.byKey(const Key('designTemplate-soft')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.account_tree_outlined), findsOneWidget);
    expect(nodeRadius(tester, 'root'), 18);

    await tester.tap(find.byKey(const Key('switchDesignTemplate')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('designTemplate-dark')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.account_tree_outlined), findsOneWidget);
    expect(nodeRadius(tester, 'root'), 14);

    await tester.tap(find.byKey(const Key('switchDesignTemplate')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('designTemplate-inkwell')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.account_tree_outlined), findsOneWidget);
    expect(nodeRadius(tester, 'root'), 6);
    expect(find.widgetWithText(MindNodeWidget, 'root'), findsOneWidget);
    expect(find.widgetWithText(MindNodeWidget, 'a'), findsOneWidget);
    expect(find.byKey(const Key('switchLayout')), findsOneWidget);

    await tester.tap(find.byKey(const Key('switchLayout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('layoutRadial')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.hub_outlined), findsOneWidget);
    expect(nodeRadius(tester, 'root'), 6);
  });

  _titleSyncTests();
}

class _RenameStorage implements MindMapStorage {
  _RenameStorage(this.files);

  final Map<String, String> files;

  @override
  Future<MindMapFile> create(
    MindMapLocation folder,
    String displayName, {
    String markdown = '',
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<MindMapFile>> list(MindMapLocation folder) async => [];

  @override
  Future<String> read(MindMapLocation location) async => files[location.token]!;

  @override
  Future<void> write(MindMapLocation location, String markdown) async {
    files[location.token] = markdown;
  }

  @override
  Future<MindMapFile> rename(
    MindMapLocation location,
    String newDisplayName,
  ) async {
    final markdown = files.remove(location.token);
    if (markdown == null) {
      throw const MindMapStorageException('missing file');
    }
    final slash = location.token.lastIndexOf('/');
    final parent = slash == -1 ? '' : location.token.substring(0, slash);
    final newToken = parent.isEmpty
        ? newDisplayName
        : '$parent/$newDisplayName';
    if (files.containsKey(newToken)) {
      files[location.token] = markdown;
      throw const MindMapStorageException('name already exists');
    }
    files[newToken] = markdown;
    return MindMapFile(
      location: MindMapLocation(newToken),
      displayName: newDisplayName,
    );
  }

  @override
  Future<void> delete(MindMapLocation location) async {
    throw UnimplementedError();
  }
}

void _titleSyncTests() {
  Widget app({
    required MindMapDocument document,
    required MindMapFile file,
    required RenameMindMap renameMindMap,
  }) {
    return MaterialApp(
      locale: const Locale('ja'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MindMapPage(
        document: document,
        file: file,
        renameMindMap: renameMindMap,
      ),
    );
  }

  testWidgets('renames the file after root text is committed', (tester) async {
    final storage = _RenameStorage({'vault/old.md': '# root\n'});
    const file = MindMapFile(
      location: MindMapLocation('vault/old.md'),
      displayName: 'old.md',
    );
    await tester.pumpWidget(
      app(
        document: MindMapDocument(
          root: MindNode(id: const NodeId('root'), text: 'root'),
        ),
        file: file,
        renameMindMap: RenameMindMap(storage: storage),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('編集'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '新しい題名');
    await tester.tap(find.byKey(const Key('doneEditingNode')));
    await tester.pumpAndSettle();

    expect(find.text('新しい題名.md'), findsOneWidget);
    expect(storage.files.containsKey('vault/old.md'), isFalse);
    expect(storage.files.keys.single, 'vault/新しい題名.md');
  });

  testWidgets('does not rename while root text is still being typed', (
    tester,
  ) async {
    final storage = _RenameStorage({'vault/old.md': '# root\n'});
    const file = MindMapFile(
      location: MindMapLocation('vault/old.md'),
      displayName: 'old.md',
    );
    await tester.pumpWidget(
      app(
        document: MindMapDocument(
          root: MindNode(id: const NodeId('root'), text: 'root'),
        ),
        file: file,
        renameMindMap: RenameMindMap(storage: storage),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('編集'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '途中');
    await tester.pump();

    expect(storage.files.keys.single, 'vault/old.md');
    expect(find.text('old.md'), findsOneWidget);
  });

  testWidgets('keeps the file when the committed root name is illegal', (
    tester,
  ) async {
    final storage = _RenameStorage({'vault/old.md': '# root\n'});
    const file = MindMapFile(
      location: MindMapLocation('vault/old.md'),
      displayName: 'old.md',
    );
    await tester.pumpWidget(
      app(
        document: MindMapDocument(
          root: MindNode(id: const NodeId('root'), text: 'root'),
        ),
        file: file,
        renameMindMap: RenameMindMap(storage: storage),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('編集'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'a/b');
    await tester.tap(find.byKey(const Key('doneEditingNode')));
    await tester.pumpAndSettle();

    expect(find.text('a/b'), findsOneWidget);
    expect(find.text('使えないファイル名です'), findsOneWidget);
    expect(storage.files.keys.single, 'vault/old.md');
    expect(find.text('old.md'), findsOneWidget);
  });

  testWidgets('does not rename a mismatched file that is only opened', (
    tester,
  ) async {
    final storage = _RenameStorage({'vault/notes.md': '# Different\n'});
    const file = MindMapFile(
      location: MindMapLocation('vault/notes.md'),
      displayName: 'notes.md',
    );
    await tester.pumpWidget(
      app(
        document: MindMapDocument(
          root: MindNode(id: const NodeId('root'), text: 'Different'),
        ),
        file: file,
        renameMindMap: RenameMindMap(storage: storage),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    expect(storage.files, {'vault/notes.md': '# Different\n'});
    expect(find.text('notes.md'), findsOneWidget);
    expect(find.text('Different'), findsOneWidget);
  });
}
