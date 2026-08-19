import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/app/app.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

class _FakePicker implements MindMapFolderPicker {
  @override
  Future<MindMapLocation?> pickFolder() async {
    return const MindMapLocation('folder');
  }
}

class _FakeStorage implements MindMapStorage {
  @override
  Future<MindMapFile> create(
    MindMapLocation folder,
    String displayName, {
    String markdown = '',
  }) async {
    return MindMapFile(
      location: MindMapLocation('${folder.token}/$displayName'),
      displayName: displayName,
    );
  }

  @override
  Future<List<MindMapFile>> list(MindMapLocation folder) async => [];

  @override
  Future<String> read(MindMapLocation location) async => '';

  @override
  Future<void> write(MindMapLocation location, String markdown) async {}
}

void main() {
  testWidgets('日本語の初期画面を表示する', (tester) async {
    await tester.pumpWidget(const ObmindApp());
    await tester.pumpAndSettle();

    expect(find.text('Obmind'), findsOneWidget);
    expect(
      find.text('Markdownを正本とする、Local-firstなマインドマップアプリです。'),
      findsOneWidget,
    );
    expect(find.text('フォルダを選んでMarkdownを作成'), findsNothing);
  });

  testWidgets('フォルダ選択PoCのボタンからMarkdown作成を依頼する', (tester) async {
    final useCase = CreateMarkdownInFolder(
      picker: _FakePicker(),
      storage: _FakeStorage(),
    );

    await tester.pumpWidget(ObmindApp(createMarkdownInFolder: useCase));
    await tester.pumpAndSettle();

    await tester.tap(find.text('フォルダを選んでMarkdownを作成'));
    await tester.pumpAndSettle();

    expect(find.text('obmind-poc.mdを作成しました'), findsOneWidget);
  });
}
