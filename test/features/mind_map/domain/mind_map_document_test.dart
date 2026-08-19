import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/models/layout_type.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_theme_id.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

void main() {
  MindNode node(
    String id, {
    String? text,
    List<MindNode> children = const [],
    bool collapsed = false,
  }) {
    return MindNode(
      id: NodeId(id),
      text: text ?? id,
      children: children,
      collapsed: collapsed,
    );
  }

  test('title matches root text', () {
    final document = MindMapDocument(root: node('root', text: '新サービス'));

    expect(document.title, '新サービス');
    expect(document.theme, MindMapThemeId.minimal);
    expect(document.layout, LayoutType.horizontal);
  });

  test('preserves child order in depth-first traversal', () {
    final document = MindMapDocument(
      root: node(
        'root',
        children: [
          node('a', children: [node('a1'), node('a2')]),
          node('b'),
        ],
      ),
    );

    expect(document.nodeIds.map((id) => id.value), [
      'root',
      'a',
      'a1',
      'a2',
      'b',
    ]);
  });

  test('copyWith replaces children without mutating the original', () {
    final originalChild = node('a');
    final original = node('root', children: [originalChild]);
    final copied = original.copyWith(
      text: 'Root',
      collapsed: true,
      children: [node('b'), originalChild],
    );

    expect(original.text, 'root');
    expect(original.collapsed, isFalse);
    expect(original.children, hasLength(1));
    expect(copied.text, 'Root');
    expect(copied.collapsed, isTrue);
    expect(copied.children.map((child) => child.id.value), ['b', 'a']);
  });

  test('rejects duplicate node ids', () {
    expect(
      () => MindMapDocument(
        root: node('root', children: [node('dup'), node('dup')]),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('rejects empty node ids', () {
    expect(
      () => MindMapDocument(root: node('')),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('copyWith on document re-validates unique ids', () {
    final document = MindMapDocument(root: node('root', children: [node('a')]));

    expect(
      () => document.copyWith(root: node('root', children: [node('root')])),
      throwsA(isA<ArgumentError>()),
    );
  });
}
