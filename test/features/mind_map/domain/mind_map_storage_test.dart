import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

class _MemoryMindMapStorage implements MindMapStorage {
  final Map<String, String> files = {};

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
    final markdown = files[location.token];
    if (markdown == null) {
      throw const MindMapStorageException('missing file');
    }
    final slash = location.token.lastIndexOf('/');
    final parent = slash == -1 ? '' : location.token.substring(0, slash);
    final newToken = parent.isEmpty
        ? newDisplayName
        : '$parent/$newDisplayName';
    if (newToken != location.token && files.containsKey(newToken)) {
      throw const MindMapStorageException('name already exists');
    }
    files.remove(location.token);
    files[newToken] = markdown;
    return MindMapFile(
      location: MindMapLocation(newToken),
      displayName: newDisplayName,
    );
  }

  @override
  Future<void> delete(MindMapLocation location) async {
    if (!files.containsKey(location.token)) {
      throw const MindMapStorageException('missing file');
    }
    files.remove(location.token);
  }

  @override
  Future<List<MindMapFile>> list(MindMapLocation folder) async {
    return files.entries
        .map(
          (entry) => MindMapFile(
            location: MindMapLocation(entry.key),
            displayName: entry.key,
          ),
        )
        .toList();
  }

  @override
  Future<String> read(MindMapLocation location) async {
    final markdown = files[location.token];
    if (markdown == null) {
      throw StateError('missing file');
    }
    return markdown;
  }

  @override
  Future<void> write(MindMapLocation location, String markdown) async {
    files[location.token] = markdown;
  }
}

void main() {
  test('MindMapStorage can be implemented without OS types', () async {
    final storage = _MemoryMindMapStorage();
    const location = MindMapLocation('maps/idea.md');

    await storage.write(location, '# Root\n');

    expect(await storage.read(location), '# Root\n');
    expect(await storage.list(const MindMapLocation('maps')), hasLength(1));
  });

  test(
    'create writes markdown under a folder token without OS types',
    () async {
      final storage = _MemoryMindMapStorage();
      const folder = MindMapLocation('maps');

      final file = await storage.create(
        folder,
        'idea.md',
        markdown: '# Root\n',
      );

      expect(file.displayName, 'idea.md');
      expect(await storage.read(file.location), '# Root\n');
    },
  );

  test('rename changes the display name without rewriting markdown', () async {
    final storage = _MemoryMindMapStorage();
    const folder = MindMapLocation('maps');
    final file = await storage.create(folder, 'idea.md', markdown: '# Root\n');

    final renamed = await storage.rename(file.location, 'renamed.md');

    expect(renamed.displayName, 'renamed.md');
    expect(await storage.read(renamed.location), '# Root\n');
    expect(() => storage.read(file.location), throwsA(isA<StateError>()));
  });

  test('rename refuses to overwrite an existing file', () async {
    final storage = _MemoryMindMapStorage();
    const folder = MindMapLocation('maps');
    await storage.create(folder, 'a.md', markdown: '# A\n');
    final file = await storage.create(folder, 'b.md', markdown: '# B\n');

    expect(
      () => storage.rename(file.location, 'a.md'),
      throwsA(isA<MindMapStorageException>()),
    );
    expect(await storage.read(file.location), '# B\n');
  });

  test('delete removes the file and fails when missing', () async {
    final storage = _MemoryMindMapStorage();
    const folder = MindMapLocation('maps');
    final file = await storage.create(folder, 'idea.md', markdown: '# Root\n');

    await storage.delete(file.location);

    expect(() => storage.read(file.location), throwsA(isA<StateError>()));
    expect(
      () => storage.delete(file.location),
      throwsA(isA<MindMapStorageException>()),
    );
  });

  test('failed write does not empty existing markdown', () async {
    final storage = _ThrowingWriteStorage();
    const location = MindMapLocation('maps/idea.md');
    storage.files[location.token] = '# Root\n';

    expect(
      () => storage.write(location, ''),
      throwsA(isA<MindMapStorageException>()),
    );
    expect(await storage.read(location), '# Root\n');
  });
}

class _ThrowingWriteStorage extends _MemoryMindMapStorage {
  @override
  Future<void> write(MindMapLocation location, String markdown) async {
    throw const MindMapStorageException('write failed');
  }
}
