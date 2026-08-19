import 'package:flutter/material.dart';
import 'package:obmind/features/mind_map/application/layout/horizontal_layout_engine.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_edge_layer.dart';
import 'package:obmind/features/mind_map/presentation/mind_node_widget.dart';

/// Canvas that positions nodes from [LayoutEngine] and pans with one finger.
class MindMapViewport extends StatelessWidget {
  const MindMapViewport({
    super.key,
    required this.document,
    this.layoutEngine = const HorizontalLayoutEngine(),
    this.nodeSizes = const {},
    this.panEnabled = true,
    this.scaleEnabled = true,
    this.minScale = 0.5,
    this.maxScale = 2.5,
    this.selectedId,
    this.onNodeSelected,
  });

  final MindMapDocument document;
  final LayoutEngine layoutEngine;
  final Map<NodeId, NodeSize> nodeSizes;
  final bool panEnabled;
  final bool scaleEnabled;
  final double minScale;
  final double maxScale;
  final NodeId? selectedId;
  final ValueChanged<NodeId>? onNodeSelected;

  @override
  Widget build(BuildContext context) {
    final layout = layoutEngine.layout(document, nodeSizes: nodeSizes);
    return InteractiveViewer(
      panEnabled: panEnabled,
      scaleEnabled: scaleEnabled,
      minScale: minScale,
      maxScale: maxScale,
      constrained: false,
      child: SizedBox(
        width: layout.width,
        height: layout.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            MindMapEdgeLayer(document: document, layout: layout),
            for (final node in document.root.depthFirst)
              if (layout[node.id] != null)
                Positioned(
                  key: ValueKey(node.id.value),
                  left: layout[node.id]!.x,
                  top: layout[node.id]!.y,
                  width: layout[node.id]!.width,
                  height: layout[node.id]!.height,
                  child: MindNodeWidget(
                    text: node.text,
                    collapsed: node.collapsed,
                    selected: selectedId == node.id,
                    onTap: onNodeSelected == null
                        ? null
                        : () => onNodeSelected!(node.id),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
