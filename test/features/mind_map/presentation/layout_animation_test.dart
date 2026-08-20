import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/presentation/layout_animation.dart';

void main() {
  test('lerpMindMapLayout interpolates node positions', () {
    final from = MindMapLayout(
      nodes: {
        NodeId('a'): NodeLayout(
          id: NodeId('a'),
          x: 0,
          y: 0,
          width: 100,
          height: 40,
        ),
      },
      width: 100,
      height: 40,
    );
    final to = MindMapLayout(
      nodes: {
        NodeId('a'): NodeLayout(
          id: NodeId('a'),
          x: 100,
          y: 50,
          width: 120,
          height: 48,
        ),
      },
      width: 220,
      height: 98,
    );

    final mid = lerpMindMapLayout(from, to, 0.5);

    expect(mid[const NodeId('a')]!.x, 50);
    expect(mid[const NodeId('a')]!.y, 25);
    expect(mid.width, 160);
    expect(mid.height, 69);
  });
}
