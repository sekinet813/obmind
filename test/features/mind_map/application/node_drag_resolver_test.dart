import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/application/node_drag_resolver.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

void main() {
  MindNode node(String id, {List<MindNode> children = const []}) {
    return MindNode(id: NodeId(id), text: id, children: children);
  }

  test('reorders siblings when dropped on a sibling', () {
    final document = MindMapDocument(
      root: node('root', children: [node('a'), node('b'), node('c')]),
    );
    final layout = MindMapLayout(
      nodes: {
        NodeId('a'): NodeLayout(
          id: NodeId('a'),
          x: 100,
          y: 0,
          width: 40,
          height: 20,
        ),
        NodeId('b'): NodeLayout(
          id: NodeId('b'),
          x: 100,
          y: 30,
          width: 40,
          height: 20,
        ),
        NodeId('c'): NodeLayout(
          id: NodeId('c'),
          x: 100,
          y: 60,
          width: 40,
          height: 20,
        ),
      },
      width: 140,
      height: 80,
    );

    final resolution = resolveNodeDrag(
      document: document,
      layout: layout,
      draggedId: const NodeId('c'),
      layoutPoint: const Offset(120, 35),
    );

    expect(resolution, isA<ReorderNodeDrag>());
    expect((resolution! as ReorderNodeDrag).newIndex, 1);
  });

  test('reparents when dropped on a different branch', () {
    final document = MindMapDocument(
      root: node(
        'root',
        children: [
          node('a', children: [node('a1')]),
          node('b'),
        ],
      ),
    );
    final layout = MindMapLayout(
      nodes: {
        NodeId('a1'): NodeLayout(
          id: NodeId('a1'),
          x: 200,
          y: 0,
          width: 40,
          height: 20,
        ),
        NodeId('b'): NodeLayout(
          id: NodeId('b'),
          x: 100,
          y: 40,
          width: 40,
          height: 20,
        ),
      },
      width: 240,
      height: 60,
    );

    final resolution = resolveNodeDrag(
      document: document,
      layout: layout,
      draggedId: const NodeId('a1'),
      layoutPoint: const Offset(120, 45),
    );

    expect(resolution, isA<ReparentNodeDrag>());
    expect((resolution! as ReparentNodeDrag).newParentId, const NodeId('b'));
  });
}
