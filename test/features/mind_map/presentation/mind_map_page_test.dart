import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_page.dart';
import 'package:obmind/features/mind_map/presentation/mind_node_widget.dart';
import 'package:obmind/l10n/app_localizations.dart';

void main() {
  MindNode node(String id, {List<MindNode> children = const []}) {
    return MindNode(id: NodeId(id), text: id, children: children);
  }

  int nextId = 0;

  Widget app(MindMapDocument document) {
    nextId = 0;
    return MaterialApp(
      locale: const Locale('ja'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MindMapPage(
        document: document,
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

    await tester.tap(find.text('子を追加'));
    await tester.pump();

    expect(find.text('新しいノード'), findsOneWidget);
    expect(find.text('a'), findsOneWidget);
  });

  testWidgets('adds a sibling after the selected non-root node', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(MindMapDocument(root: node('root', children: [node('a')]))),
    );

    await tester.tap(find.text('a'));
    await tester.pump();
    await tester.tap(find.text('兄弟を追加'));
    await tester.pump();

    expect(find.text('新しいノード'), findsOneWidget);
    expect(find.text('a'), findsOneWidget);
  });

  testWidgets('deletes the selected non-root node', (tester) async {
    await tester.pumpWidget(
      app(MindMapDocument(root: node('root', children: [node('a')]))),
    );

    await tester.tap(find.text('a'));
    await tester.pump();
    await tester.tap(find.text('削除'));
    await tester.pump();

    expect(find.text('a'), findsNothing);
    expect(find.widgetWithText(MindNodeWidget, 'root'), findsOneWidget);
  });
}
