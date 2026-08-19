import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_viewport.dart';

void main() {
  MindNode node(String id, {List<MindNode> children = const []}) {
    return MindNode(id: NodeId(id), text: id, children: children);
  }

  testWidgets('shows nodes and enables one-finger pan', (tester) async {
    final document = MindMapDocument(
      root: node('root', children: [node('child')]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MindMapViewport(document: document)),
      ),
    );

    expect(find.text('root'), findsOneWidget);
    expect(find.text('child'), findsOneWidget);
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.panEnabled, isTrue);
    expect(viewer.scaleEnabled, isFalse);
  });
}
