import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/presentation/mind_node_widget.dart';

void main() {
  testWidgets('shows node text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MindNodeWidget(text: '課題')),
      ),
    );

    expect(find.text('課題'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('shows a collapsed marker without hiding the text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MindNodeWidget(text: '折りたたみ', collapsed: true)),
      ),
    );

    expect(find.text('折りたたみ'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });
}
