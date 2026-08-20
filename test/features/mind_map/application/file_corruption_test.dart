import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parser.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_serializer.dart';

class _MemoryStorage implements MindMapStorage {
  _MemoryStorage(this.files);

  final Map<String, String> files;

  @override
  Future<MindMapFile> create(
    MindMapLocation folder,
    String displayName, {
    String markdown = '',
  }) async {
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
    if (location.token.contains('fail')) {
      throw const MindMapStorageException('write failed');
    }
    files[location.token] = markdown;
  }
}

void main() {
  const location = MindMapLocation('maps/idea.md');
  const serializer = MarkdownSerializer();

  test('SaveMindMap failure does not empty existing markdown', () async {
    final storage = _MemoryStorage({'maps/idea.md': '# Root\n'});
    final saveMindMap = SaveMindMap(storage: storage, serializer: serializer);
    const failLocation = MindMapLocation('maps/fail.md');
    storage.files[failLocation.token] = '# Keep\n';

    expect(
      () => saveMindMap(
        failLocation,
        MindMapDocument(
          root: MindNode(id: NodeId('root'), text: 'Root'),
        ),
      ),
      throwsA(isA<MindMapStorageException>()),
    );
    expect(storage.files[failLocation.token], '# Keep\n');
  });

  test(
    'LoadMindMap throws instead of silently dropping invalid markdown',
    () async {
      final storage = _MemoryStorage({'maps/idea.md': 'not markdown'});
      final loadMindMap = LoadMindMap(
        storage: storage,
        parser: MarkdownParser(),
      );

      expect(() => loadMindMap(location), throwsA(isA<LoadMindMapException>()));
      expect(storage.files[location.token], 'not markdown');
    },
  );
}
