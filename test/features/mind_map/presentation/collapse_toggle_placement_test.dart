import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/presentation/collapse_toggle_placement.dart';

void main() {
  test('places the toggle on the right edge by default', () {
    final center = collapseToggleCenter(const Size(100, 40), Offset.zero);
    expect(center.dx, closeTo(100 - kCollapseToggleInset, 0.01));
    expect(center.dy, closeTo(20, 0.01));
  });

  test('places the toggle on the left edge for a leftward branch', () {
    final center = collapseToggleCenter(
      const Size(100, 40),
      const Offset(-1, 0),
    );
    expect(center.dx, closeTo(kCollapseToggleInset, 0.01));
    expect(center.dy, closeTo(20, 0.01));
  });

  test('places the toggle on the top edge for an upward branch', () {
    final center = collapseToggleCenter(
      const Size(100, 40),
      const Offset(0, -1),
    );
    expect(center.dx, closeTo(50, 0.01));
    expect(center.dy, closeTo(kCollapseToggleInset, 0.01));
  });

  test('averages visible children for the toggle direction', () {
    final parent = MindNode(
      id: const NodeId('p'),
      text: 'p',
      children: [
        MindNode(id: const NodeId('a'), text: 'a'),
        MindNode(id: const NodeId('b'), text: 'b'),
      ],
    );
    const parentLayout = NodeLayout(
      id: NodeId('p'),
      x: 100,
      y: 100,
      width: 80,
      height: 40,
    );
    final layout = MindMapLayout(
      nodes: {
        const NodeId('p'): parentLayout,
        const NodeId('a'): const NodeLayout(
          id: NodeId('a'),
          x: 220,
          y: 40,
          width: 80,
          height: 40,
        ),
        const NodeId('b'): const NodeLayout(
          id: NodeId('b'),
          x: 220,
          y: 160,
          width: 80,
          height: 40,
        ),
      },
      width: 400,
      height: 300,
    );

    final direction = collapseToggleDirection(
      node: parent,
      nodeLayout: parentLayout,
      layout: layout,
    );
    expect(direction.dx, greaterThan(0));
    expect(direction.dy, closeTo(0, 0.01));
  });

  test('uses outward parent direction when collapsed', () {
    final parent = MindNode(id: const NodeId('root'), text: 'root');
    final node = MindNode(
      id: const NodeId('left'),
      text: 'left',
      collapsed: true,
      children: [MindNode(id: const NodeId('child'), text: 'child')],
    );
    const nodeLayout = NodeLayout(
      id: NodeId('left'),
      x: 0,
      y: 100,
      width: 80,
      height: 40,
    );
    final layout = MindMapLayout(
      nodes: {
        const NodeId('root'): const NodeLayout(
          id: NodeId('root'),
          x: 200,
          y: 100,
          width: 80,
          height: 40,
        ),
        const NodeId('left'): nodeLayout,
      },
      width: 400,
      height: 300,
    );

    final direction = collapseToggleDirection(
      node: node,
      nodeLayout: nodeLayout,
      layout: layout,
      parent: parent,
    );
    expect(direction.dx, lessThan(0));
  });
}
