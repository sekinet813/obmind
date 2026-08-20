import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/mind_map_tree.dart';
import 'package:obmind/features/mind_map/domain/mind_map_tree_exception.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

void main() {
  MindNode node(String id, {String? text, List<MindNode> children = const []}) {
    return MindNode(id: NodeId(id), text: text ?? id, children: children);
  }

  MindMapDocument documentWith(MindNode root) => MindMapDocument(root: root);

  test('addChild appends a child and keeps sibling order', () {
    final original = documentWith(
      node('root', children: [node('a'), node('b')]),
    );

    final updated = MindMapTree.addChild(original, NodeId('a'), node('a1'));

    expect(
      original.root.children.singleWhere((n) => n.id.value == 'a').children,
      isEmpty,
    );
    expect(updated.nodeIds.map((id) => id.value), ['root', 'a', 'a1', 'b']);
    expect(updated.root.children.map((child) => child.id.value), ['a', 'b']);
  });

  test('addChild inserts at an index', () {
    final original = documentWith(
      node('root', children: [node('a'), node('c')]),
    );

    final updated = MindMapTree.addChild(
      original,
      NodeId('root'),
      node('b'),
      index: 1,
    );

    expect(updated.root.children.map((child) => child.id.value), [
      'a',
      'b',
      'c',
    ]);
  });

  test('addSibling inserts after the target', () {
    final original = documentWith(
      node('root', children: [node('a'), node('c')]),
    );

    final updated = MindMapTree.addSibling(original, NodeId('a'), node('b'));

    expect(updated.root.children.map((child) => child.id.value), [
      'a',
      'b',
      'c',
    ]);
  });

  test('addSibling of root is rejected', () {
    final original = documentWith(node('root', children: [node('a')]));

    expect(
      () => MindMapTree.addSibling(original, NodeId('root'), node('b')),
      throwsA(
        isA<MindMapTreeException>().having(
          (error) => error.error,
          'error',
          MindMapTreeError.cannotAddSiblingOfRoot,
        ),
      ),
    );
  });

  test('delete removes a subtree and keeps remaining order', () {
    final original = documentWith(
      node(
        'root',
        children: [
          node('a', children: [node('a1')]),
          node('b'),
        ],
      ),
    );

    final updated = MindMapTree.delete(original, NodeId('a'));

    expect(updated.nodeIds.map((id) => id.value), ['root', 'b']);
    expect(original.nodeIds, hasLength(4));
  });

  test('delete refuses to remove the root', () {
    final original = documentWith(node('root', children: [node('a')]));

    expect(
      () => MindMapTree.delete(original, NodeId('root')),
      throwsA(
        isA<MindMapTreeException>().having(
          (error) => error.error,
          'error',
          MindMapTreeError.cannotDeleteRoot,
        ),
      ),
    );
  });

  test('move reparents a node and preserves remaining order', () {
    final original = documentWith(
      node(
        'root',
        children: [
          node('a', children: [node('a1')]),
          node('b'),
        ],
      ),
    );

    final updated = MindMapTree.move(original, NodeId('a1'), NodeId('b'));

    expect(updated.nodeIds.map((id) => id.value), ['root', 'a', 'b', 'a1']);
    expect(updated.root.children.last.children.single.id.value, 'a1');
  });

  test('reorder changes sibling index without changing parent', () {
    final original = documentWith(
      node('root', children: [node('a'), node('b'), node('c')]),
    );

    final updated = MindMapTree.reorder(original, NodeId('c'), 0);

    expect(updated.root.children.map((child) => child.id.value), [
      'c',
      'a',
      'b',
    ]);
  });

  test('setCollapsed hides descendants without removing them', () {
    final original = documentWith(
      node(
        'root',
        children: [
          node('a', children: [node('a1')]),
        ],
      ),
    );

    final collapsed = MindMapTree.setCollapsed(original, NodeId('a'), true);

    expect(collapsed.root.children.single.collapsed, isTrue);
    expect(collapsed.root.children.single.children.single.id.value, 'a1');
    expect(original.root.children.single.collapsed, isFalse);
  });

  test('updateText changes node label without altering ids', () {
    final original = documentWith(node('root', children: [node('a')]));

    final updated = MindMapTree.updateText(original, NodeId('a'), 'Renamed');

    expect(updated.root.children.single.text, 'Renamed');
    expect(updated.root.children.single.id.value, 'a');
    expect(original.root.children.single.text, 'a');
  });

  test('operations reject unknown ids and duplicate ids', () {
    final original = documentWith(node('root', children: [node('a')]));

    expect(
      () => MindMapTree.addChild(original, NodeId('missing'), node('b')),
      throwsA(
        isA<MindMapTreeException>().having(
          (error) => error.error,
          'error',
          MindMapTreeError.nodeNotFound,
        ),
      ),
    );
    expect(
      () => MindMapTree.addChild(original, NodeId('root'), node('a')),
      throwsA(
        isA<MindMapTreeException>().having(
          (error) => error.error,
          'error',
          MindMapTreeError.duplicateNodeId,
        ),
      ),
    );
    expect(
      () => MindMapTree.delete(original, NodeId('missing')),
      throwsA(
        isA<MindMapTreeException>().having(
          (error) => error.error,
          'error',
          MindMapTreeError.nodeNotFound,
        ),
      ),
    );
  });
}
