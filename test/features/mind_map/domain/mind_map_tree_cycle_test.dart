import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/mind_map_tree.dart';
import 'package:obmind/features/mind_map/domain/mind_map_tree_exception.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

void main() {
  MindNode node(String id, {List<MindNode> children = const []}) {
    return MindNode(id: NodeId(id), text: id, children: children);
  }

  late MindMapDocument document;

  setUp(() {
    document = MindMapDocument(
      root: node(
        'root',
        children: [
          node(
            'a',
            children: [
              node('a1', children: [node('a11')]),
            ],
          ),
          node('b'),
        ],
      ),
    );
  });

  test('refuses to move a node under itself', () {
    expect(
      MindMapTree.wouldCreateCycle(document, NodeId('a'), NodeId('a')),
      isTrue,
    );
    expect(
      () => MindMapTree.move(document, NodeId('a'), NodeId('a')),
      throwsA(
        isA<MindMapTreeException>().having(
          (error) => error.error,
          'error',
          MindMapTreeError.cycle,
        ),
      ),
    );
    expect(document.nodeIds.map((id) => id.value), [
      'root',
      'a',
      'a1',
      'a11',
      'b',
    ]);
  });

  test('refuses to move a node under a descendant', () {
    expect(
      MindMapTree.wouldCreateCycle(document, NodeId('a'), NodeId('a11')),
      isTrue,
    );
    expect(
      () => MindMapTree.move(document, NodeId('a'), NodeId('a11')),
      throwsA(
        isA<MindMapTreeException>().having(
          (error) => error.error,
          'error',
          MindMapTreeError.cycle,
        ),
      ),
    );
  });

  test('allows moving a node under a non-descendant', () {
    expect(
      MindMapTree.wouldCreateCycle(document, NodeId('a1'), NodeId('b')),
      isFalse,
    );

    final updated = MindMapTree.move(document, NodeId('a1'), NodeId('b'));

    expect(updated.nodeIds.map((id) => id.value), [
      'root',
      'a',
      'b',
      'a1',
      'a11',
    ]);
  });
}
