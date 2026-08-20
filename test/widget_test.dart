import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/app/app.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/features/mind_map/application/list_mind_map_files.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/markdown_file_service.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parser.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_serializer.dart';
import 'package:obmind/features/mind_map/presentation/markdown_editor_page.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_page.dart';
import 'package:obmind/l10n/app_localizations.dart';

class _FakePicker implements MindMapFolderPicker {
  @override
  Future<MindMapLocation?> pickFolder() async {
    return const MindMapLocation('folder');
  }

  @override
  Future<bool> hasAccess(MindMapLocation folder) async => true;
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
  Future<MindMapFile> rename(
    MindMapLocation location,
    String newDisplayName,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(MindMapLocation location) async {
    throw UnimplementedError();
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
  Future<MindMapFile> rename(
    MindMapLocation location,
    String newDisplayName,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(MindMapLocation location) async {
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

Widget _androidApp(_MemoryStorage storage) {
  const serializer = MarkdownSerializer();
  final picker = _FakePicker();
  return ObmindApp(
    createMarkdownInFolder: CreateMarkdownInFolder(
      picker: picker,
      storage: storage,
    ),
    folderPicker: picker,
    listMindMapFiles: ListMindMapFiles(storage),
    loadMindMap: LoadMindMap(storage: storage, parser: MarkdownParser()),
    saveMindMap: SaveMindMap(storage: storage, serializer: serializer),
  );
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

  testWidgets('作成したMarkdownをマインドマップとして開いて保存する', (tester) async {
    final storage = _MemoryStorage();
    await tester.pumpWidget(_androidApp(storage));
    await tester.pumpAndSettle();

    await tester.tap(find.text('フォルダを選んでMarkdownを作成'));
    await tester.pumpAndSettle();

    expect(find.text('obmind-poc.mdを作成しました'), findsOneWidget);
    expect(find.byType(MindMapPage), findsOneWidget);
    expect(find.text('Obmind'), findsWidgets);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addChildNode')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveMindMap')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final saved = storage.files.values.single;
    expect(saved, contains('# Obmind'));
    expect(saved, contains('新しいノード'));
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
