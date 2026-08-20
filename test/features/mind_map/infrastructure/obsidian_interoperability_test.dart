import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parser.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_serializer.dart';

void main() {
  final parser = MarkdownParser();
  const serializer = MarkdownSerializer();

  test('round-trips Obsidian-style vault markdown', () {
    const markdown = '''
---
obmind:
  version: 1
  theme: soft
  layout: horizontal
---

# Project <!-- obmind:id=root -->

- Research [[Backlinks]] <!-- obmind:id=research -->
  - Notes from meeting <!-- obmind:id=notes -->
- Launch <!-- obmind:id=launch -->
''';

    final first = parser.parse(markdown);
    expect(first.document, isNotNull);

    final serialized = serializer.serialize(first.document!);
    expect(serialized, contains('# Project'));
    expect(serialized, contains('- Research [[Backlinks]]'));
    expect(serialized, contains('obmind:'));

    final second = parser.parse(serialized);
    expect(second.document, isNotNull);
    expect(second.document!.root.children.first.text, 'Research [[Backlinks]]');
  });
}
