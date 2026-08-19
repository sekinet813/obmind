import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/app/app.dart';

void main() {
  testWidgets('日本語の初期画面を表示する', (tester) async {
    await tester.pumpWidget(const ObmindApp());
    await tester.pumpAndSettle();

    expect(find.text('Obmind'), findsOneWidget);
    expect(
      find.text('Markdownを正本とする、Local-firstなマインドマップアプリです。'),
      findsOneWidget,
    );
  });
}
