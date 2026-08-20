import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/recent_mind_maps.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/domain/repositories/recent_mind_maps_repository.dart';

class _MemoryRecentMindMapsRepository implements RecentMindMapsRepository {
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

MindMapFile file(String name) {
  return MindMapFile(location: MindMapLocation('loc/$name'), displayName: name);
}

void main() {
  test('records recent files with newest first and deduplicates', () async {
    final repository = _MemoryRecentMindMapsRepository();
    final record = RecordRecentMindMap(repository);
    final listRecent = ListRecentMindMaps(repository);

    await record(file('a.md'));
    await record(file('b.md'));
    await record(file('a.md'));

    expect((await listRecent()).map((entry) => entry.displayName), [
      'a.md',
      'b.md',
    ]);
  });

  test('remove drops stale entries after permission loss', () async {
    final repository = _MemoryRecentMindMapsRepository();
    final record = RecordRecentMindMap(repository);
    final remove = RemoveRecentMindMap(repository);
    final listRecent = ListRecentMindMaps(repository);
    final stale = file('gone.md');

    await record(stale);
    await remove(stale.location);

    expect(await listRecent(), isEmpty);
  });
}
