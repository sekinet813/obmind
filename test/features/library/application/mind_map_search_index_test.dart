import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/library/application/mind_map_search_index.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parser.dart';

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
  Future<String> read(MindMapLocation location) async {
    final markdown = files[location.token];
    if (markdown == null) {
      throw const MindMapStorageException('missing');
    }
    return markdown;
  }

  @override
  Future<void> write(MindMapLocation location, String markdown) async {
    files[location.token] = markdown;
  }
}

void main() {
  test('indexes node texts and skips unreadable files', () async {
    final storage = _MemoryStorage();
    final readable = await storage.create(
      const MindMapLocation('vault'),
      'ok.md',
      markdown: '# Root\n\n- Child idea\n',
    );
    final broken = await storage.create(
      const MindMapLocation('vault'),
      'broken.md',
      markdown: 'no heading here\n',
    );
    final missing = MindMapFile(
      location: const MindMapLocation('vault/missing.md'),
      displayName: 'missing.md',
    );
    final index = MindMapSearchIndex(
      loadMindMap: LoadMindMap(storage: storage, parser: MarkdownParser()),
    );

    final texts = await index.ensureIndexed([readable, broken, missing]);

    expect(texts[readable.location.token], ['Root', 'Child idea']);
    expect(texts[broken.location.token], isEmpty);
    expect(texts[missing.location.token], isEmpty);
  });

  test('reuses cached texts until invalidated', () async {
    final storage = _MemoryStorage();
    final file = await storage.create(
      const MindMapLocation('vault'),
      'ok.md',
      markdown: '# First\n',
    );
    final index = MindMapSearchIndex(
      loadMindMap: LoadMindMap(storage: storage, parser: MarkdownParser()),
    );

    await index.ensureIndexed([file]);
    storage.files[file.location.token] = '# Second\n';
    expect((await index.ensureIndexed([file]))[file.location.token], ['First']);

    index.invalidate(file.location);
    expect((await index.ensureIndexed([file]))[file.location.token], [
      'Second',
    ]);
  });
}
