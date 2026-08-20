import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/app/app.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/features/mind_map/application/list_mind_map_files.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/load_vault_folder.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/application/select_vault_folder.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/domain/repositories/vault_folder_repository.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parser.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_serializer.dart';

class _MemoryVault implements VaultFolderRepository {
  MindMapLocation? folder;

  @override
  Future<MindMapLocation?> load() async => folder;

  @override
  Future<void> save(MindMapLocation location) async {
    folder = location;
  }

  @override
  Future<void> clear() async {
    folder = null;
  }
}

class _FakePicker implements MindMapFolderPicker {
  var pickCount = 0;
  var accessible = true;

  @override
  Future<MindMapLocation?> pickFolder() async {
    pickCount += 1;
    return const MindMapLocation('folder');
  }

  @override
  Future<bool> hasAccess(MindMapLocation folder) async => accessible;
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
        .where((entry) => entry.key.startsWith('${folder.token}/'))
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
}

void main() {
  testWidgets('asks for a vault folder only when it is unset', (tester) async {
    final storage = _MemoryStorage();
    final picker = _FakePicker();
    final vault = _MemoryVault();
    await tester.pumpWidget(
      ObmindApp(
        createMarkdownInFolder: CreateMarkdownInFolder(
          picker: picker,
          storage: storage,
        ),
        listMindMapFiles: ListMindMapFiles(storage),
        loadMindMap: LoadMindMap(storage: storage, parser: MarkdownParser()),
        saveMindMap: SaveMindMap(
          storage: storage,
          serializer: const MarkdownSerializer(),
        ),
        loadVaultFolder: LoadVaultFolder(vault: vault, picker: picker),
        selectVaultFolder: SelectVaultFolder(picker: picker, vault: vault),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('保存フォルダを選ぶ'), findsOneWidget);
    expect(find.text('思考の保存フォルダを選ぶ'), findsOneWidget);
    expect(find.textContaining('Markdownファイルとして保存します'), findsOneWidget);
    expect(find.textContaining('正本'), findsNothing);
    expect(find.textContaining('キャンセルしてもアプリは終了しません'), findsOneWidget);
    expect(find.text('フォルダを選んでMarkdownを作成'), findsNothing);
    expect(find.text('Markdownを開いて編集'), findsNothing);

    await tester.tap(find.text('保存フォルダを選ぶ'));
    await tester.pumpAndSettle();

    expect(find.text('このフォルダにMarkdownがありません'), findsOneWidget);
    expect(find.text('Markdown一覧を開く'), findsNothing);
    expect(picker.pickCount, 1);

    await tester.tap(find.byKey(const Key('createMindMapEmpty')));
    await tester.pumpAndSettle();

    expect(picker.pickCount, 1);
    expect(storage.files.keys.single, 'folder/新規マインドマップ.md');
  });

  testWidgets('shows vault files on launch when the folder is already set', (
    tester,
  ) async {
    final storage = _MemoryStorage()..files['folder/idea.md'] = '# Root\n';
    final picker = _FakePicker();
    final vault = _MemoryVault()..folder = const MindMapLocation('folder');
    await tester.pumpWidget(
      ObmindApp(
        listMindMapFiles: ListMindMapFiles(storage),
        loadMindMap: LoadMindMap(storage: storage, parser: MarkdownParser()),
        saveMindMap: SaveMindMap(
          storage: storage,
          serializer: const MarkdownSerializer(),
        ),
        loadVaultFolder: LoadVaultFolder(vault: vault, picker: picker),
        selectVaultFolder: SelectVaultFolder(picker: picker, vault: vault),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('idea.md'), findsOneWidget);
    expect(find.text('保存フォルダを選ぶ'), findsNothing);
    expect(find.byKey(const Key('openSettings')), findsOneWidget);
    expect(find.byKey(const Key('libraryAppIcon')), findsOneWidget);
  });

  testWidgets('shows a reason when vault access is revoked', (tester) async {
    final storage = _MemoryStorage();
    final picker = _FakePicker()..accessible = false;
    final vault = _MemoryVault()..folder = const MindMapLocation('folder');
    await tester.pumpWidget(
      ObmindApp(
        listMindMapFiles: ListMindMapFiles(storage),
        loadMindMap: LoadMindMap(storage: storage, parser: MarkdownParser()),
        saveMindMap: SaveMindMap(
          storage: storage,
          serializer: const MarkdownSerializer(),
        ),
        loadVaultFolder: LoadVaultFolder(vault: vault, picker: picker),
        selectVaultFolder: SelectVaultFolder(picker: picker, vault: vault),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('アクセス権限がありません'), findsOneWidget);
    expect(find.text('Markdown一覧を開く'), findsNothing);
  });
}
