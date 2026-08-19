import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/models/layout_type.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_theme_id.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_serializer.dart';

void main() {
  const serializer = MarkdownSerializer();

  MindNode node(
    String id, {
    String? text,
    List<MindNode> children = const [],
    bool collapsed = false,
    Map<String, String> metadata = const {},
  }) {
    return MindNode(
      id: NodeId(id),
      text: text ?? id,
      children: children,
      collapsed: collapsed,
      metadata: metadata,
    );
  }

  test('writes frontmatter, H1, and 2-space nested lists in spec order', () {
    final document = MindMapDocument(
      root: node(
        'root',
        text: '新サービス',
        children: [
          node(
            'problem',
            text: '課題',
            children: [
              node('lockin', text: 'データロックイン'),
              node('price', text: '月額料金'),
            ],
          ),
          node(
            'solution',
            text: '解決策',
            children: [
              node('markdown', text: 'Markdown'),
              node('local-first', text: 'Local-first'),
            ],
          ),
        ],
      ),
    );

    expect(serializer.serialize(document), '''
---
obmind:
  version: 1
  theme: minimal
  layout: horizontal
---

# 新サービス <!-- obmind:id=root -->

- 課題 <!-- obmind:id=problem -->
  - データロックイン <!-- obmind:id=lockin -->
  - 月額料金 <!-- obmind:id=price -->
- 解決策 <!-- obmind:id=solution -->
  - Markdown <!-- obmind:id=markdown -->
  - Local-first <!-- obmind:id=local-first -->
''');
  });

  test('writes collapsed and unknown attributes back into comments', () {
    final document = MindMapDocument(
      theme: MindMapThemeId.dark,
      extraObmindFields: const {'experimental': 'yes'},
      root: node(
        'root',
        text: 'Root',
        collapsed: true,
        metadata: const {'extra': 'keep'},
        children: [node('child', text: 'Child')],
      ),
    );

    final markdown = serializer.serialize(document);

    expect(markdown, contains('theme: dark'));
    expect(markdown, contains('experimental: yes'));
    expect(
      markdown,
      contains('# Root <!-- obmind:id=root collapsed=true extra=keep -->'),
    );
    expect(markdown, contains('- Child <!-- obmind:id=child -->'));
    expect(markdown, isNot(contains('collapsed=false')));
  });

  test('omits the list block when the root has no children', () {
    final document = MindMapDocument(root: node('root', text: 'Solo'));

    expect(serializer.serialize(document), '''
---
obmind:
  version: 1
  theme: minimal
  layout: horizontal
---

# Solo <!-- obmind:id=root -->
''');
  });

  test('preserves child order', () {
    final document = MindMapDocument(
      layout: LayoutType.horizontal,
      root: node(
        'root',
        text: 'Root',
        children: [
          node('b', text: 'B'),
          node('a', text: 'A'),
        ],
      ),
    );

    final markdown = serializer.serialize(document);
    expect(markdown.indexOf('- B'), lessThan(markdown.indexOf('- A')));
  });
}
