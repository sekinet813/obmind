import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/features/mind_map/domain/models/layout_type.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parser.dart';

class _FakeFolderPicker implements MindMapFolderPicker {
  _FakeFolderPicker(this.folder);

  final MindMapLocation? folder;
  var pickCount = 0;

  @override
  Future<MindMapLocation?> pickFolder() async {
    pickCount += 1;
    return folder;
  }

  @override
  Future<bool> hasAccess(MindMapLocation folder) async => folder == this.folder;
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
    final prefix = '${folder.token}/';
    return [
      for (final token in files.keys)
        if (token.startsWith(prefix))
          MindMapFile(
            location: MindMapLocation(token),
            displayName: token.substring(prefix.length),
          ),
    ];
  }

  @override
  Future<String> read(MindMapLocation location) async => files[location.token]!;

  @override
  Future<void> write(MindMapLocation location, String markdown) async {
    files[location.token] = markdown;
  }
}

void main() {
  test('creates markdown after a folder is picked', () async {
    final picker = _FakeFolderPicker(const MindMapLocation('tree-uri'));
    final storage = _MemoryStorage();
    final useCase = CreateMarkdownInFolder(picker: picker, storage: storage);

    final file = await useCase();

    expect(file?.displayName, '新規マインドマップ.md');
    final markdown = await storage.read(file!.location);
    expect(markdown, contains('# 新規マインドマップ\n'));
    expect(markdown, isNot(contains('# Obmind')));
    expect(picker.pickCount, 1);
    final parsed = MarkdownParser().parse(markdown);
    expect(parsed.isSuccess, isTrue);
    expect(parsed.document!.title, '新規マインドマップ');
    expect(parsed.document!.layout, LayoutType.radial);
    expect(markdown, contains('layout: radial'));
  });

  test('creates markdown in a provided folder without picking again', () async {
    final picker = _FakeFolderPicker(const MindMapLocation('tree-uri'));
    final storage = _MemoryStorage();
    final useCase = CreateMarkdownInFolder(picker: picker, storage: storage);

    final file = await useCase(folder: const MindMapLocation('tree-uri'));

    expect(file?.displayName, '新規マインドマップ.md');
    expect(picker.pickCount, 0);
  });

  test('does not overwrite an existing default name', () async {
    final picker = _FakeFolderPicker(const MindMapLocation('tree-uri'));
    final storage = _MemoryStorage();
    final useCase = CreateMarkdownInFolder(picker: picker, storage: storage);
    const folder = MindMapLocation('tree-uri');

    await useCase(folder: folder);
    final second = await useCase(folder: folder);

    expect(second?.displayName, '新規マインドマップ (1).md');
    expect(storage.files.keys, contains('tree-uri/新規マインドマップ.md'));
    expect(storage.files.keys, contains('tree-uri/新規マインドマップ (1).md'));
    expect(await storage.read(second!.location), contains('# 新規マインドマップ (1)\n'));
  });

  test('returns null when the user cancels the picker', () async {
    final picker = _FakeFolderPicker(null);
    final storage = _MemoryStorage();
    final useCase = CreateMarkdownInFolder(picker: picker, storage: storage);

    expect(await useCase(), isNull);
    expect(storage.files, isEmpty);
  });

  test('keeps the historical template when markdown is provided', () async {
    final picker = _FakeFolderPicker(const MindMapLocation('tree-uri'));
    final storage = _MemoryStorage();
    final useCase = CreateMarkdownInFolder(picker: picker, storage: storage);

    final file = await useCase(markdown: historicalTemplateMarkdown);

    expect(file?.displayName, '新規マインドマップ.md');
    final markdown = await storage.read(file!.location);
    expect(markdown, contains('# Obmind\n'));
    expect(MarkdownParser().parse(markdown).isSuccess, isTrue);
  });
}
