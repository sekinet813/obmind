import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/delete_mind_map.dart';
import 'package:obmind/features/mind_map/application/recent_mind_maps.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/domain/repositories/recent_mind_maps_repository.dart';

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
  test('deletes the file and removes it from recent', () async {
    final storage = _MemoryStorage();
    final recent = _MemoryRecent();
    final file = await storage.create(
      const MindMapLocation('vault'),
      'idea.md',
      markdown: '# Root\n',
    );
    await recent.record(file);

    await DeleteMindMap(
      storage: storage,
      removeRecentMindMap: RemoveRecentMindMap(recent),
    )(file);

    expect(storage.files.containsKey(file.location.token), isFalse);
    expect(await recent.list(), isEmpty);
  });

  test('does not drop recent when delete fails', () async {
    final storage = _MemoryStorage()..deleteShouldFail = true;
    final recent = _MemoryRecent();
    final file = await storage.create(
      const MindMapLocation('vault'),
      'idea.md',
      markdown: '# Root\n',
    );
    await recent.record(file);

    expect(
      () => DeleteMindMap(
        storage: storage,
        removeRecentMindMap: RemoveRecentMindMap(recent),
      )(file),
      throwsA(isA<MindMapStorageException>()),
    );
    expect(storage.files[file.location.token], '# Root\n');
    expect(await recent.list(), hasLength(1));
  });
}
