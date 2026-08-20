import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/models/layout_type.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_theme_id.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parser.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_serializer.dart';

void main() {
  late int nextId;
  late MarkdownParser parser;
  const serializer = MarkdownSerializer();

  setUp(() {
    nextId = 0;
    parser = MarkdownParser(
      generateId: () {
        nextId += 1;
        return NodeId('generated-$nextId');
      },
    );
  });

  MindMapDocument parseClean(String markdown) {
    final result = parser.parse(markdown);
    expect(result.document, isNotNull);
    return result.document!;
  }

  test(
    'round-trips tree, text, ids, order, collapsed, theme, layout, version',
    () {
      const markdown = '''
---
obmind:
  version: 1
  theme: soft
  layout: horizontal
---

# 新サービス <!-- obmind:id=root collapsed=true -->

- 課題 <!-- obmind:id=problem -->
  - データロックイン <!-- obmind:id=lockin collapsed=true extra=keep -->
  - 月額料金 <!-- obmind:id=price -->
- 解決策 <!-- obmind:id=solution -->
''';

      final first = parseClean(markdown);
      final second = parseClean(serializer.serialize(first));

      expectSameMeaning(first, second);
      expect(second.formatVersion, 1);
      expect(second.theme, MindMapThemeId.soft);
      expect(second.layout, LayoutType.horizontal);
      expect(second.root.collapsed, isTrue);
      expect(second.root.children.first.children.first.collapsed, isTrue);
      expect(second.root.children.first.children.first.metadata, {
        'extra': 'keep',
      });
      expect(second.nodeIds.map((id) => id.value), [
        'root',
        'problem',
        'lockin',
        'price',
        'solution',
      ]);
    },
  );

  test(
    'assigns missing ids on import and keeps them on the next round-trip',
    () {
      const markdown = '''
# Root

- A
  - A1
- B
''';

      final imported = parser.parse(markdown);
      expect(imported.issues, isNotEmpty);
      final first = imported.document!;
      final serialized = serializer.serialize(first);
      final second = parser.parse(serialized);

      expect(second.issues, isEmpty);
      expectSameMeaning(first, second.document!);
      expect(first.nodeIds.map((id) => id.value), [
        'generated-1',
        'generated-2',
        'generated-3',
        'generated-4',
      ]);
    },
  );

  test('round-trips unknown obmind frontmatter keys', () {
    const markdown = '''
---
obmind:
  version: 1
  theme: dark
  layout: horizontal
  experimental: yes
---

# Root <!-- obmind:id=root -->
''';

    final first = parseClean(markdown);
    final second = parseClean(serializer.serialize(first));

    expectSameMeaning(first, second);
    expect(second.extraObmindFields, {'experimental': 'yes'});
    expect(second.theme, MindMapThemeId.dark);
  });

  test('round-trips radial layout', () {
    const markdown = '''
---
obmind:
  version: 1
  theme: minimal
  layout: radial
---

# Root <!-- obmind:id=root -->

- Child <!-- obmind:id=child -->
''';

    final first = parseClean(markdown);
    final second = parseClean(serializer.serialize(first));

    expectSameMeaning(first, second);
    expect(second.layout, LayoutType.radial);
  });

  test('round-trips unknown layout values', () {
    const markdown = '''
---
obmind:
  version: 1
  theme: minimal
  layout: honeycomb
---

# Root <!-- obmind:id=root -->
''';

    final first = parser.parse(markdown).document!;
    final second = parseClean(serializer.serialize(first));

    expect(first.layout, LayoutType.horizontal);
    expect(second.layout, LayoutType.horizontal);
    expect(second.extraObmindFields, {'layout': 'honeycomb'});
  });

  test('files written by Obmind parse back without warnings', () {
    final document = parseClean('''
# Solo <!-- obmind:id=solo -->
''');
    final result = parser.parse(serializer.serialize(document));

    expect(result.issues, isEmpty);
    expectSameMeaning(document, result.document!);
  });
}

void expectSameMeaning(MindMapDocument a, MindMapDocument b) {
  expect(a.formatVersion, b.formatVersion);
  expect(a.theme, b.theme);
  expect(a.layout, b.layout);
  expect(a.extraObmindFields, b.extraObmindFields);
  expectSameNode(a.root, b.root);
}

void expectSameNode(MindNode a, MindNode b) {
  expect(a.id, b.id);
  expect(a.text, b.text);
  expect(a.collapsed, b.collapsed);
  expect(a.metadata, b.metadata);
  expect(a.children.length, b.children.length);
  for (var i = 0; i < a.children.length; i++) {
    expectSameNode(a.children[i], b.children[i]);
  }
}
