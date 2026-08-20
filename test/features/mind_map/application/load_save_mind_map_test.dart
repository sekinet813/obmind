import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/mind_map_tree.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
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
}

void main() {
  const location = MindMapLocation('file');
  const serializer = MarkdownSerializer();
  var nextGeneratedId = 0;

  NodeId generatedId() => NodeId('generated-${nextGeneratedId += 1}');

  test('LoadMindMap parses Markdown from storage', () async {
    nextGeneratedId = 0;
    final storage = _MemoryStorage()
      ..files[location.token] = '# Root\n\n- Child\n';
    final loadMindMap = LoadMindMap(
      storage: storage,
      parser: MarkdownParser(generateId: generatedId),
    );

    final result = await loadMindMap(location);

    expect(result.document.title, 'Root');
    expect(result.document.root.children.single.text, 'Child');
    expect(result.hasUnsupportedContent, isFalse);
  });

  test('LoadMindMap throws when Markdown cannot be parsed', () async {
    final storage = _MemoryStorage()
      ..files[location.token] = '- Child without root\n';
    final loadMindMap = LoadMindMap(storage: storage, parser: MarkdownParser());

    await expectLater(
      loadMindMap(location),
      throwsA(isA<LoadMindMapException>()),
    );
  });

  test('LoadMindMap reports unsupported content without failing', () async {
    nextGeneratedId = 0;
    final storage = _MemoryStorage()
      ..files[location.token] = '# Root\n\nParagraph text\n';
    final loadMindMap = LoadMindMap(
      storage: storage,
      parser: MarkdownParser(generateId: generatedId),
    );

    final result = await loadMindMap(location);

    expect(result.document.title, 'Root');
    expect(result.hasUnsupportedContent, isTrue);
  });

  test('SaveMindMap serializes and writes through storage', () async {
    final storage = _MemoryStorage();
    final saveMindMap = SaveMindMap(storage: storage, serializer: serializer);
    final document = MindMapDocument(
      root: MindNode(id: NodeId('root'), text: 'Root'),
    );

    await saveMindMap(location, document);

    final markdown = storage.files[location.token]!;
    expect(markdown, contains('# Root'));
    expect(markdown, contains('obmind:'));
  });

  test('load then save round-trips tree structure', () async {
    nextGeneratedId = 0;
    final storage = _MemoryStorage()
      ..files[location.token] = '''
# Root

- A
  - A1
- B
''';
    final loadMindMap = LoadMindMap(
      storage: storage,
      parser: MarkdownParser(generateId: generatedId),
    );
    final saveMindMap = SaveMindMap(storage: storage, serializer: serializer);

    final loaded = await loadMindMap(location);
    var document = loaded.document;
    document = MindMapTree.addChild(
      document,
      document.root.id,
      MindNode(id: NodeId('new'), text: 'C'),
    );
    await saveMindMap(location, document);

    final reloaded = await loadMindMap(location);
    expect(reloaded.document.root.children.map((n) => n.text), ['A', 'B', 'C']);
  });
}
