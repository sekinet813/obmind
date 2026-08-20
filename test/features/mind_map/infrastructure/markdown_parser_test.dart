import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/models/layout_type.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_theme_id.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parse_issue.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parser.dart';

void main() {
  late int nextId;
  late MarkdownParser parser;

  setUp(() {
    nextId = 0;
    parser = MarkdownParser(
      generateId: () {
        nextId += 1;
        return NodeId('generated-$nextId');
      },
    );
  });

  test('parses format v0.1 H1 and nested unordered lists', () {
    const markdown = '''
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
''';

    final result = parser.parse(markdown);

    expect(result.isSuccess, isTrue);
    expect(result.issues, isEmpty);
    final document = result.document!;
    expect(document.formatVersion, 1);
    expect(document.theme, MindMapThemeId.minimal);
    expect(document.layout, LayoutType.horizontal);
    expect(document.title, '新サービス');
    expect(document.nodeIds.map((id) => id.value), [
      'root',
      'problem',
      'lockin',
      'price',
      'solution',
      'markdown',
      'local-first',
    ]);
    expect(document.root.children.map((node) => node.text), ['課題', '解決策']);
    expect(document.root.children.first.children.map((node) => node.text), [
      'データロックイン',
      '月額料金',
    ]);
  });

  test('parses radial layout from frontmatter', () {
    const markdown = '''
---
obmind:
  version: 1
  theme: minimal
  layout: radial
---

# Root <!-- obmind:id=root -->
''';

    final result = parser.parse(markdown);

    expect(result.isSuccess, isTrue);
    expect(result.issues, isEmpty);
    expect(result.document!.layout, LayoutType.radial);
  });

  test('preserves unknown layout values without using them for display', () {
    const markdown = '''
---
obmind:
  version: 1
  theme: minimal
  layout: honeycomb
---

# Root <!-- obmind:id=root -->
''';

    final result = parser.parse(markdown);

    expect(result.document!.layout, LayoutType.horizontal);
    expect(result.document!.extraObmindFields, {'layout': 'honeycomb'});
    expect(
      result.issues.map((issue) => issue.code),
      contains(MarkdownParseIssueCode.unknownLayout),
    );
    expect(result.hasUnsupportedContent, isFalse);
  });

  test('assigns ids to simple markdown without comments', () {
    const markdown = '''
# Root

- A
  - A1
- B
''';

    final result = parser.parse(markdown);
    final document = result.document!;

    expect(result.isSuccess, isTrue);
    expect(
      result.issues.every(
        (issue) => issue.code == MarkdownParseIssueCode.missingNodeId,
      ),
      isTrue,
    );
    expect(document.nodeIds.map((id) => id.value), [
      'generated-1',
      'generated-2',
      'generated-3',
      'generated-4',
    ]);
    expect(document.root.children.map((node) => node.text), ['A', 'B']);
    expect(document.root.children.first.children.single.text, 'A1');
  });

  test('preserves collapsed and unknown comment attributes', () {
    const markdown = '''
# Root <!-- obmind:id=root collapsed=true extra=keep -->

- Child <!-- obmind:id=child collapsed=false -->
''';

    final result = parser.parse(markdown);
    final root = result.document!.root;

    expect(root.collapsed, isTrue);
    expect(root.metadata, {'extra': 'keep'});
    expect(root.children.single.collapsed, isFalse);
  });

  test('preserves unknown obmind frontmatter keys', () {
    const markdown = '''
---
obmind:
  version: 1
  theme: soft
  layout: horizontal
  experimental: yes
---

# Root <!-- obmind:id=root -->
''';

    final result = parser.parse(markdown);

    expect(result.document!.theme, MindMapThemeId.soft);
    expect(result.document!.extraObmindFields, {'experimental': 'yes'});
    expect(result.hasUnsupportedContent, isFalse);
  });

  test('fails closed on unknown format major version', () {
    const markdown = '''
---
obmind:
  version: 2
---

# Root <!-- obmind:id=root -->
''';

    final result = parser.parse(markdown);

    expect(result.document, isNull);
    expect(result.hasErrors, isTrue);
    expect(
      result.issues.map((issue) => issue.code),
      contains(MarkdownParseIssueCode.unknownFormatVersion),
    );
  });

  test('fails when H1 root is missing', () {
    const markdown = '''
- Child
''';

    final result = parser.parse(markdown);

    expect(result.document, isNull);
    expect(
      result.issues.map((issue) => issue.code),
      contains(MarkdownParseIssueCode.missingRoot),
    );
  });

  test('warns on unsupported blocks instead of dropping them silently', () {
    const markdown = '''
# Root <!-- obmind:id=root -->

- Child <!-- obmind:id=child -->

```
code
```

| a | b |
| --- | --- |

> quote

1. ordered

## Extra heading

[[Wiki Link]]
''';

    final result = parser.parse(markdown);

    expect(result.isSuccess, isTrue);
    expect(result.hasUnsupportedContent, isTrue);
    expect(
      result.issues.where(
        (issue) => issue.code == MarkdownParseIssueCode.unsupportedBlock,
      ),
      isNotEmpty,
    );
    expect(result.document!.root.children.single.id.value, 'child');
  });

  test('warns on a second H1 without using it as another root', () {
    const markdown = '''
# Root <!-- obmind:id=root -->

# Extra <!-- obmind:id=extra -->
''';

    final result = parser.parse(markdown);

    expect(result.document!.root.id.value, 'root');
    expect(result.document!.root.children, isEmpty);
    expect(result.hasUnsupportedContent, isTrue);
    expect(
      result.issues.map((issue) => issue.code),
      contains(MarkdownParseIssueCode.multipleRoots),
    );
  });

  test('replaces duplicate node ids', () {
    const markdown = '''
# Root <!-- obmind:id=dup -->

- Child <!-- obmind:id=dup -->
''';

    final result = parser.parse(markdown);

    expect(result.document!.nodeIds.map((id) => id.value), [
      'dup',
      'generated-1',
    ]);
    expect(
      result.issues.map((issue) => issue.code),
      contains(MarkdownParseIssueCode.duplicateNodeId),
    );
  });
}
