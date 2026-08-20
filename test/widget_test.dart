import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/app/app.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/features/mind_map/application/markdown_file_service.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/presentation/markdown_editor_page.dart';
import 'package:obmind/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class _FakePicker implements MindMapFolderPicker {
  @override
  Future<MindMapLocation?> pickFolder() async {
    return const MindMapLocation('folder');
  }
}

class _MemoryStorage implements MindMapStorage {
  final files = <String, String>{};

  @override
  Future<MindMapFile> create(
    MindMapLocation folder,
    String displayName, {
    String markdown = '',
  }) async {
    final location = MindMapLocation('${folder.token}/$displayName');
    files[location.token] = markdown;
    return MindMapFile(location: location, displayName: displayName);
  }

  @override
  Future<List<MindMapFile>> list(MindMapLocation folder) async {
    return files.entries
        .map(
          (entry) => MindMapFile(
            location: MindMapLocation(entry.key),
            displayName: entry.key.split('/').last,
          ),
        )
        .toList();
  }

  @override
  Future<String> read(MindMapLocation location) async => files[location.token]!;

  @override
  Future<void> write(MindMapLocation location, String markdown) async {
    files[location.token] = markdown;
  }
}

class _FailingWriteStorage implements MindMapStorage {
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
  Future<String> read(MindMapLocation location) async => 'original';

  @override
  Future<void> write(MindMapLocation location, String markdown) async {
    throw const MindMapStorageException('disk full');
  }
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

  testWidgets('作成したMarkdownを読み込んで編集画面を開く', (tester) async {
    final storage = _MemoryStorage();
    final picker = _FakePicker();
    await tester.pumpWidget(
      ObmindApp(
        createMarkdownInFolder: CreateMarkdownInFolder(
          picker: picker,
          storage: storage,
        ),
        folderPicker: picker,
        markdownFiles: MarkdownFileService(storage),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('フォルダを選んでMarkdownを作成'));
    await tester.pumpAndSettle();

    expect(find.text('obmind-poc.mdを作成しました'), findsOneWidget);
    expect(find.text(pocMarkdownContents), findsOneWidget);

    await tester.enterText(find.byType(TextField), '# Edited\n');
    await tester.tap(find.byKey(const Key('saveMarkdown')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(storage.files.values.single, '# Edited\n');
  });

  testWidgets('保存失敗でも編集中のテキストを消さない', (tester) async {
    const file = MindMapFile(
      location: MindMapLocation('file'),
      displayName: 'idea.md',
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MarkdownEditorPage(
          file: file,
          initialMarkdown: 'original',
          markdownFiles: MarkdownFileService(_FailingWriteStorage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'edited');
    await tester.tap(find.byKey(const Key('saveMarkdown')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('保存に失敗しました。元のファイルは空にしていません'), findsOneWidget);
    expect(find.text('edited'), findsOneWidget);
  });
}
