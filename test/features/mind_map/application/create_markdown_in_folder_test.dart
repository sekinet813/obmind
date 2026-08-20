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
  Future<List<MindMapFile>> list(MindMapLocation folder) async => [];

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

    expect(file?.displayName, pocMarkdownFileName);
    expect(await storage.read(file!.location), pocMarkdownContents);
    expect(picker.pickCount, 1);
    final parsed = MarkdownParser().parse(pocMarkdownContents);
    expect(parsed.isSuccess, isTrue);
    expect(parsed.document!.layout, LayoutType.radial);
    expect(pocMarkdownContents, contains('layout: radial'));
  });

  test('creates markdown in a provided folder without picking again', () async {
    final picker = _FakeFolderPicker(const MindMapLocation('tree-uri'));
    final storage = _MemoryStorage();
    final useCase = CreateMarkdownInFolder(picker: picker, storage: storage);

    final file = await useCase(folder: const MindMapLocation('tree-uri'));

    expect(file?.displayName, pocMarkdownFileName);
    expect(picker.pickCount, 0);
  });

  test('returns null when the user cancels the picker', () async {
    final picker = _FakeFolderPicker(null);
    final storage = _MemoryStorage();
    final useCase = CreateMarkdownInFolder(picker: picker, storage: storage);

    expect(await useCase(), isNull);
    expect(storage.files, isEmpty);
  });
}
