import 'package:app_template/presentation/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('日本語の初期画面を表示する', (tester) async {
    await tester.pumpWidget(const AppTemplate());
    await tester.pumpAndSettle();

    expect(find.text('App Template'), findsOneWidget);
    expect(find.text('このテンプレートからアプリの実装を始めてください。'), findsOneWidget);
  });
}
