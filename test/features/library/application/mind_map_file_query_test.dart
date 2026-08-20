import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/library/application/mind_map_file_query.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

MindMapFile file(String name) {
  return MindMapFile(location: MindMapLocation(name), displayName: name);
}

void main() {
  test('sorts by display name and filters by substring', () {
    final files = [file('zeta.md'), file('alpha.md'), file('beta.md')];

    expect(queryMindMapFiles(files).map((entry) => entry.displayName), [
      'alpha.md',
      'beta.md',
      'zeta.md',
    ]);
    expect(
      queryMindMapFiles(files, query: 'et').map((entry) => entry.displayName),
      ['beta.md', 'zeta.md'],
    );
  });

  test('matches node text as well as the file name', () {
    final files = [file('notes.md'), file('plan.md'), file('other.md')];
    final texts = {
      'notes.md': ['買い物リスト'],
      'plan.md': ['Release'],
      'other.md': ['無関係'],
    };

    expect(
      queryMindMapFiles(
        files,
        query: 'notes',
        nodeTextsByToken: texts,
      ).map((entry) => entry.displayName),
      ['notes.md'],
    );
    expect(
      queryMindMapFiles(
        files,
        query: '買い物',
        nodeTextsByToken: texts,
      ).map((entry) => entry.displayName),
      ['notes.md'],
    );
    expect(
      queryMindMapFiles(files, query: 'missing', nodeTextsByToken: texts),
      isEmpty,
    );
  });

  test('keeps a parse-failed file when the name still matches', () {
    final files = [file('broken.md'), file('ok.md')];
    expect(
      queryMindMapFiles(
        files,
        query: 'broken',
        nodeTextsByToken: const {
          'broken.md': [],
          'ok.md': ['Root'],
        },
      ).map((entry) => entry.displayName),
      ['broken.md'],
    );
  });

  test('filters 200 files without writing markdown', () {
    final files = [
      for (var index = 200; index >= 1; index -= 1)
        file('map-${index.toString().padLeft(3, '0')}.md'),
    ];

    final listed = queryMindMapFiles(files, query: 'map-00');

    expect(listed, hasLength(9));
    expect(listed.first.displayName, 'map-001.md');
    expect(listed.last.displayName, 'map-009.md');
  });
}
