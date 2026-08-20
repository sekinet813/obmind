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
