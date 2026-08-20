import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/library/presentation/mind_map_file_list_page.dart';
import 'package:obmind/features/mind_map/application/delete_mind_map.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parser.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_serializer.dart';
import 'package:obmind/l10n/app_localizations.dart';

class _MemoryStorage implements MindMapStorage {
  final files = <String, String>{};
  var deleteShouldFail = false;

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
  Future<List<MindMapFile>> list(MindMapLocation folder) async => [];

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
    if (deleteShouldFail || !files.containsKey(location.token)) {
      throw const MindMapStorageException('delete failed');
    }
    files.remove(location.token);
  }
}

void main() {
  late _MemoryStorage storage;
  late MindMapFile file;

  setUp(() async {
    storage = _MemoryStorage();
    file = await storage.create(
      const MindMapLocation('vault'),
      'idea.md',
      markdown: '# Root\n',
    );
  });

  Widget app() {
    return MaterialApp(
      locale: const Locale('ja'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MindMapFileListPage(
        files: [file],
        loadMindMap: LoadMindMap(storage: storage, parser: MarkdownParser()),
        saveMindMap: SaveMindMap(
          storage: storage,
          serializer: const MarkdownSerializer(),
        ),
        deleteMindMap: DeleteMindMap(storage: storage),
      ),
    );
  }

  testWidgets('asks for confirmation before deleting a mind map file', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('renameMenu-${file.displayName}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('削除').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('idea.mdを削除しますか'), findsOneWidget);

    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    expect(storage.files[file.location.token], '# Root\n');
    expect(find.text('idea.md'), findsOneWidget);
  });

  testWidgets('deletes a mind map after confirmation', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('renameMenu-${file.displayName}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('削除').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmDeleteMindMap')));
    await tester.pumpAndSettle();

    expect(storage.files.containsKey(file.location.token), isFalse);
    expect(find.text('idea.md'), findsNothing);
    expect(find.text('このフォルダにMarkdownがありません'), findsOneWidget);
  });

  testWidgets('keeps the file when delete fails', (tester) async {
    storage.deleteShouldFail = true;
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('renameMenu-${file.displayName}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('削除').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmDeleteMindMap')));
    await tester.pumpAndSettle();

    expect(storage.files[file.location.token], '# Root\n');
    expect(find.text('idea.md'), findsOneWidget);
    expect(find.text('削除できませんでした'), findsOneWidget);
  });

  testWidgets('sorts files by name and filters by search query', (
    tester,
  ) async {
    final zeta = await storage.create(
      const MindMapLocation('vault'),
      'zeta.md',
      markdown: '# Z\n',
    );
    final alpha = await storage.create(
      const MindMapLocation('vault'),
      'alpha.md',
      markdown: '# A\n',
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MindMapFileListPage(
          files: [zeta, alpha],
          loadMindMap: LoadMindMap(storage: storage, parser: MarkdownParser()),
          saveMindMap: SaveMindMap(
            storage: storage,
            serializer: const MarkdownSerializer(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('alpha.md'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('alpha.md')).dy,
      lessThan(tester.getTopLeft(find.text('zeta.md')).dy),
    );

    await tester.enterText(find.byKey(const Key('searchMindMaps')), 'zet');
    await tester.pumpAndSettle();

    expect(find.text('zeta.md'), findsOneWidget);
    expect(find.text('alpha.md'), findsNothing);
  });

  testWidgets('filters the list by node text', (tester) async {
    final notes = await storage.create(
      const MindMapLocation('vault'),
      'notes.md',
      markdown: '# 買い物リスト\n\n- 牛乳\n',
    );
    final plan = await storage.create(
      const MindMapLocation('vault'),
      'plan.md',
      markdown: '# Release\n',
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MindMapFileListPage(
          files: [notes, plan],
          loadMindMap: LoadMindMap(storage: storage, parser: MarkdownParser()),
          saveMindMap: SaveMindMap(
            storage: storage,
            serializer: const MarkdownSerializer(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('名前やノードで検索'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('searchMindMaps')), '牛乳');
    await tester.pumpAndSettle();

    expect(find.text('notes.md'), findsOneWidget);
    expect(find.text('plan.md'), findsNothing);
  });
}
