import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/presentation/mind_node_widget.dart';
import 'test_canvas_theme.dart';

void main() {
  testWidgets('shows node text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 160,
            height: 48,
            child: MindNodeWidget(text: '課題', theme: testCanvasTheme()),
          ),
        ),
      ),
    );

    expect(find.text('課題'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
    expect(find.byIcon(Icons.remove), findsNothing);
  });

  testWidgets('shows a plus toggle on collapsed nodes with children', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 160,
            height: 48,
            child: MindNodeWidget(
              text: '折りたたみ',
              theme: testCanvasTheme(),
              collapsed: true,
              hasChildren: true,
              onToggleCollapsed: () => tapped = true,
              collapseToggleKey: const Key('collapseToggle-a'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('折りたたみ'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsNothing);

    await tester.tap(find.byKey(const Key('collapseToggle-a')));
    expect(tapped, isTrue);
  });

  testWidgets('shows a minus toggle on expanded nodes with children', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 160,
            height: 48,
            child: MindNodeWidget(
              text: '展開中',
              theme: testCanvasTheme(),
              hasChildren: true,
              onToggleCollapsed: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.remove), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);
  });
}
