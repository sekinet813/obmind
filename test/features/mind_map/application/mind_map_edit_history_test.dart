import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/mind_map_edit_history.dart';
import 'package:obmind/features/mind_map/domain/mind_map_tree.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

void main() {
  MindMapDocument doc(String title) {
    return MindMapDocument(
      root: MindNode(id: const NodeId('root'), text: title),
    );
  }

  test('undo and redo restore prior tree states', () {
    final history = MindMapEditHistory(doc('one'));
    final child = MindNode(id: const NodeId('child'), text: 'child');
    history.push(
      MindMapTree.addChild(history.present, const NodeId('root'), child),
    );

    expect(history.present.root.children, isNotEmpty);

    final undone = history.undo();
    expect(undone?.title, 'one');
    expect(history.canRedo, isTrue);

    final redone = history.redo();
    expect(redone?.root.children.single.text, 'child');
  });
}
