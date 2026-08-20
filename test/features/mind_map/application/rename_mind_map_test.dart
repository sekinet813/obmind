import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/recent_mind_maps.dart';
import 'package:obmind/features/mind_map/application/rename_mind_map.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/domain/repositories/recent_mind_maps_repository.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parser.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_serializer.dart';

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
    final markdown = files.remove(location.token);
    if (markdown == null) {
      throw const MindMapStorageException('missing file');
    }
    final slash = location.token.lastIndexOf('/');
    final parent = slash == -1 ? '' : location.token.substring(0, slash);
    final newToken = parent.isEmpty
        ? newDisplayName
        : '$parent/$newDisplayName';
    if (files.containsKey(newToken)) {
      files[location.token] = markdown;
      throw const MindMapStorageException('name already exists');
    }
    files[newToken] = markdown;
    return MindMapFile(
      location: MindMapLocation(newToken),
      displayName: newDisplayName,
    );
  }

  @override
  Future<void> delete(MindMapLocation location) async {
    throw UnimplementedError();
  }
}

class _MemoryRecent implements RecentMindMapsRepository {
  final entries = <MindMapFile>[];

  @override
  Future<List<MindMapFile>> list() async => List.unmodifiable(entries);

  @override
  Future<void> record(MindMapFile file) async {
    entries.removeWhere((entry) => entry.location.token == file.location.token);
    entries.insert(0, file);
  }

  @override
  Future<void> remove(MindMapLocation location) async {
    entries.removeWhere((entry) => entry.location.token == location.token);
  }
}

void main() {
  test('renames a file and keeps markdown contents', () async {
    final storage = _MemoryStorage();
    const folder = MindMapLocation('vault');
    final file = await storage.create(folder, 'old.md', markdown: '# Keep\n');

    final renamed = await RenameMindMap(storage: storage)(file, 'new');

    expect(renamed.displayName, 'new.md');
    expect(await storage.read(renamed.location), '# Keep\n');
  });

  test('rejects empty and illegal names without touching the file', () async {
    final storage = _MemoryStorage();
    final file = await storage.create(
      const MindMapLocation('vault'),
      'old.md',
      markdown: '# Keep\n',
    );
    final rename = RenameMindMap(storage: storage);

    expect(() => rename(file, '   '), throwsA(isA<MindMapStorageException>()));
    expect(
      () => rename(file, 'a/b.md'),
      throwsA(isA<MindMapStorageException>()),
    );
    expect(await storage.read(file.location), '# Keep\n');
  });

  test('updates a recent entry after rename', () async {
    final storage = _MemoryStorage();
    final recent = _MemoryRecent();
    final file = await storage.create(
      const MindMapLocation('vault'),
      'old.md',
      markdown: '# Keep\n',
    );
    await recent.record(file);

    final renamed = await RenameMindMap(
      storage: storage,
      listRecentMindMaps: ListRecentMindMaps(recent),
      recordRecentMindMap: RecordRecentMindMap(recent),
      removeRecentMindMap: RemoveRecentMindMap(recent),
    )(file, 'new.md');

    final listed = await recent.list();
    expect(listed, hasLength(1));
    expect(listed.single.displayName, 'new.md');
    expect(listed.single.location, renamed.location);
  });

  RenameMindMap syncingRename(_MemoryStorage storage) {
    return RenameMindMap(
      storage: storage,
      loadMindMap: LoadMindMap(storage: storage, parser: MarkdownParser()),
      saveMindMap: SaveMindMap(
        storage: storage,
        serializer: const MarkdownSerializer(),
      ),
    );
  }

  test('updates root text when renaming from the library', () async {
    final storage = _MemoryStorage();
    final file = await storage.create(
      const MindMapLocation('vault'),
      'old.md',
      markdown: '# Old\n\n- Child\n',
    );

    final renamed = await syncingRename(storage)(file, 'New Title');

    expect(renamed.displayName, 'New Title.md');
    expect(storage.files.containsKey(file.location.token), isFalse);
    final markdown = await storage.read(renamed.location);
    expect(markdown, contains('# New Title'));
    expect(markdown, contains('Child'));
    expect(markdown, isNot(contains('# Old')));
  });

  test('does not overwrite another file when the name is taken', () async {
    final storage = _MemoryStorage();
    final file = await storage.create(
      const MindMapLocation('vault'),
      'old.md',
      markdown: '# Old\n',
    );
    await storage.create(
      const MindMapLocation('vault'),
      'taken.md',
      markdown: '# Keep\n',
    );

    expect(
      () => syncingRename(storage)(file, 'taken'),
      throwsA(isA<MindMapStorageException>()),
    );
    expect(await storage.read(file.location), '# Old\n');
    expect(
      await storage.read(const MindMapLocation('vault/taken.md')),
      '# Keep\n',
    );
  });

  test('rejects illegal names without rewriting markdown', () async {
    final storage = _MemoryStorage();
    final file = await storage.create(
      const MindMapLocation('vault'),
      'old.md',
      markdown: '# Old\n',
    );

    expect(
      () => syncingRename(storage)(file, 'a/b'),
      throwsA(isA<MindMapStorageException>()),
    );
    expect(await storage.read(file.location), '# Old\n');
  });

  test('does not rewrite unsupported markdown when renaming', () async {
    final storage = _MemoryStorage();
    const original = '# Root\n\nParagraph that cannot round-trip\n';
    final file = await storage.create(
      const MindMapLocation('vault'),
      'old.md',
      markdown: original,
    );

    final renamed = await syncingRename(storage)(file, 'kept');

    expect(renamed.displayName, 'kept.md');
    expect(await storage.read(renamed.location), original);
  });
}
