import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

class _MemoryMindMapStorage implements MindMapStorage {
  final Map<String, String> files = {};

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
}
