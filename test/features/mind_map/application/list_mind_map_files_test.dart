import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/list_mind_map_files.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

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
}

void main() {
  test('lists markdown files in a folder through storage', () async {
    final storage = _MemoryStorage()
      ..files['vault/a.md'] = '# A\n'
      ..files['vault/b.md'] = '# B\n'
      ..files['other/c.md'] = '# C\n';
    final listMindMapFiles = ListMindMapFiles(storage);

    final listed = await listMindMapFiles(const MindMapLocation('vault'));

    expect(listed.map((file) => file.displayName), ['a.md', 'b.md']);
  });
}
