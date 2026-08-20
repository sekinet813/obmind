import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/autosave_mind_map.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_revision.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_serializer.dart';

class _CountingStorage implements MindMapStorage {
  _CountingStorage();

  var writeCount = 0;
  final files = <String, String>{};

  @override
  Future<MindMapFile> create(
    MindMapLocation folder,
    String displayName, {
    String markdown = '',
  }) async {
    throw UnimplementedError();
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
    writeCount += 1;
    files[location.token] = markdown;
  }
}

MindMapDocument document(String title) {
  return MindMapDocument(
    root: MindNode(id: NodeId('root'), text: title),
  );
}

void main() {
  const location = MindMapLocation('file');
  const serializer = MarkdownSerializer();

  test('debounces repeated schedule calls into one save', () async {
    final storage = _CountingStorage()..files[location.token] = '';
    final autosave = AutosaveMindMap(
      saveMindMap: SaveMindMap(storage: storage, serializer: serializer),
      initialRevision: MarkdownRevision.fromMarkdown(''),
      debounce: const Duration(milliseconds: 50),
    );
    addTearDown(autosave.dispose);

    autosave.schedule(location, document('a'));
    autosave.schedule(location, document('b'));
    autosave.schedule(location, document('c'));

    expect(storage.writeCount, 0);
    await Future<void>.delayed(const Duration(milliseconds: 70));
    expect(storage.writeCount, 1);
    expect(storage.files[location.token], contains('# c'));
  });

  test('flush saves immediately without waiting for debounce', () async {
    final storage = _CountingStorage()..files[location.token] = '';
    final autosave = AutosaveMindMap(
      saveMindMap: SaveMindMap(storage: storage, serializer: serializer),
      initialRevision: MarkdownRevision.fromMarkdown(''),
      debounce: const Duration(seconds: 5),
    );
    addTearDown(autosave.dispose);

    autosave.schedule(location, document('now'));
    expect(storage.writeCount, 0);

    await autosave.flush();
    expect(storage.writeCount, 1);
    expect(storage.files[location.token], contains('# now'));
  });
}
