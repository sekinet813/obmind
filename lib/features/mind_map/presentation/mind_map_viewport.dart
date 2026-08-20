import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:obmind/features/mind_map/application/layout/horizontal_layout_engine.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/presentation/layout_animation.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_edge_layer.dart';
import 'package:obmind/features/mind_map/presentation/mind_node_widget.dart';
import 'package:obmind/features/mind_map/presentation/theme/mind_map_canvas_theme.dart';

/// Canvas that positions nodes from [LayoutEngine] and pans with one finger.
class MindMapViewport extends StatefulWidget {
  const MindMapViewport({
    super.key,
    required this.document,
    required this.canvasTheme,
    this.layoutEngine = const HorizontalLayoutEngine(),
    this.nodeSizes = const {},
    this.panEnabled = true,
    this.scaleEnabled = true,
    this.minScale = 0.5,
    this.maxScale = 2.5,
    this.selectedId,
    this.editingId,
    this.editingController,
    this.editingFocusNode,
    this.onNodeSelected,
    this.onNodeLongPress,
    this.onNodeDoubleTap,
    this.onNodeDragStart,
    this.onNodeDragUpdate,
    this.onNodeDragEnd,
    this.draggingId,
    this.dropTargetId,
    this.onEditingComplete,
    this.animateLayout = true,
    this.transformationController,
  });

  final MindMapDocument document;
  final MindMapCanvasTheme canvasTheme;
  final LayoutEngine layoutEngine;
  final Map<NodeId, NodeSize> nodeSizes;
  final bool panEnabled;
  final bool scaleEnabled;
  final double minScale;
  final double maxScale;
  final NodeId? selectedId;
  final NodeId? editingId;
  final TextEditingController? editingController;
  final FocusNode? editingFocusNode;
  final ValueChanged<NodeId>? onNodeSelected;
  final ValueChanged<NodeId>? onNodeLongPress;
  final ValueChanged<NodeId>? onNodeDoubleTap;
  final ValueChanged<NodeId>? onNodeDragStart;
  final ValueChanged<Offset>? onNodeDragUpdate;
  final ValueChanged<Offset>? onNodeDragEnd;
  final NodeId? draggingId;
  final NodeId? dropTargetId;
  final VoidCallback? onEditingComplete;
  final bool animateLayout;
  final TransformationController? transformationController;

  @override
  State<MindMapViewport> createState() => MindMapViewportState();
}

class MindMapViewportState extends State<MindMapViewport>
    with SingleTickerProviderStateMixin {
  static const _layoutAnimationDuration = Duration(milliseconds: 250);

  AnimationController? _layoutController;
  MindMapLayout? _fromLayout;
  MindMapLayout? _targetLayout;
  TransformationController? _ownedController;
  final _layoutKey = GlobalKey();

  TransformationController get _transformationController =>
      widget.transformationController ?? _ownedController!;

  @override
  void initState() {
    super.initState();
    if (widget.transformationController == null) {
      _ownedController = TransformationController();
    }
    _targetLayout = widget.layoutEngine.layout(
      widget.document,
      nodeSizes: widget.nodeSizes,
    );
    if (widget.animateLayout) {
      _layoutController = AnimationController(
        vsync: this,
        duration: _layoutAnimationDuration,
      )..value = 1;
      _layoutController!.addListener(_onLayoutTick);
    }
  }

  void _onLayoutTick() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(MindMapViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextLayout = widget.layoutEngine.layout(
      widget.document,
      nodeSizes: widget.nodeSizes,
    );
    if (oldWidget.document != widget.document && widget.animateLayout) {
      _fromLayout = _animatedLayout(_targetLayout ?? nextLayout);
      _targetLayout = nextLayout;
      _layoutController!
        ..value = 0
        ..forward();
    } else {
      _targetLayout = nextLayout;
    }
  }

  MindMapLayout _animatedLayout(MindMapLayout fallback) {
    final from = _fromLayout;
    final to = _targetLayout ?? fallback;
    final controller = _layoutController;
    if (from == null || controller == null || controller.value >= 1) {
      return to;
    }
    return lerpMindMapLayout(
      from,
      to,
      Curves.easeInOut.transform(controller.value),
    );
  }

  /// Current layout used for drag hit testing.
  MindMapLayout get currentLayout => _animatedLayout(
    widget.layoutEngine.layout(widget.document, nodeSizes: widget.nodeSizes),
  );

  /// Converts a global pointer position into layout coordinates.
  Offset globalToLayout(Offset global) {
    final context = _layoutKey.currentContext;
    if (context == null) {
      return Offset.zero;
    }
    final box = context.findRenderObject()! as RenderBox;
    return box.globalToLocal(global);
  }

  /// Fits the full layout into the current viewport size.
  void fitToScreen(Size viewportSize) {
    final layout = _targetLayout;
    if (layout == null || viewportSize.isEmpty) {
      return;
    }
    const padding = 24.0;
    final availableWidth = math.max(viewportSize.width - padding * 2, 1);
    final availableHeight = math.max(viewportSize.height - padding * 2, 1);
    final scale = math
        .min(availableWidth / layout.width, availableHeight / layout.height)
        .clamp(widget.minScale, widget.maxScale);
    final dx = (viewportSize.width - layout.width * scale) / 2;
    final dy = (viewportSize.height - layout.height * scale) / 2;
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  void dispose() {
    _layoutController?.removeListener(_onLayoutTick);
    _layoutController?.dispose();
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = _animatedLayout(
      widget.layoutEngine.layout(widget.document, nodeSizes: widget.nodeSizes),
    );

    return ColoredBox(
      color: widget.canvasTheme.canvasBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return InteractiveViewer(
            transformationController: _transformationController,
            panEnabled: widget.panEnabled && widget.draggingId == null,
            scaleEnabled: widget.scaleEnabled && widget.draggingId == null,
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            constrained: false,
            child: SizedBox(
              key: _layoutKey,
              width: layout.width,
              height: layout.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  MindMapEdgeLayer(
                    document: widget.document,
                    layout: layout,
                    color: widget.canvasTheme.edgeColor,
                  ),
                  for (final node in widget.document.root.depthFirst)
                    if (layout[node.id] != null)
                      Positioned(
                        key: ValueKey(node.id.value),
                        left: layout[node.id]!.x,
                        top: layout[node.id]!.y,
                        width: layout[node.id]!.width,
                        height: layout[node.id]!.height,
                        child: _NodeGestureTarget(
                          enabled: widget.editingId == null,
                          dragging: widget.draggingId == node.id,
                          onTap: widget.onNodeSelected == null
                              ? null
                              : () => widget.onNodeSelected!(node.id),
                          onLongPress: widget.onNodeLongPress == null
                              ? null
                              : () => widget.onNodeLongPress!(node.id),
                          onDoubleTap: widget.onNodeDoubleTap == null
                              ? null
                              : () => widget.onNodeDoubleTap!(node.id),
                          onDragStart: widget.onNodeDragStart == null
                              ? null
                              : () => widget.onNodeDragStart!(node.id),
                          onDragUpdate: widget.onNodeDragUpdate,
                          onDragEnd: widget.onNodeDragEnd,
                          child: MindNodeWidget(
                            text: node.text,
                            theme: widget.canvasTheme,
                            collapsed: node.collapsed,
                            selected:
                                widget.selectedId == node.id ||
                                widget.dropTargetId == node.id,
                            editing: widget.editingId == node.id,
                            controller: widget.editingController,
                            focusNode: widget.editingFocusNode,
                            onEditingComplete: widget.onEditingComplete,
                          ),
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NodeGestureTarget extends StatelessWidget {
  const _NodeGestureTarget({
    required this.child,
    required this.enabled,
    this.dragging = false,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  final Widget child;
  final bool enabled;
  final bool dragging;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onDragStart;
  final ValueChanged<Offset>? onDragUpdate;
  final ValueChanged<Offset>? onDragEnd;

  @override
  Widget build(BuildContext context) {
    final content = Opacity(opacity: dragging ? 0.65 : 1, child: child);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      onLongPress: enabled && onDragStart == null ? onLongPress : null,
      onDoubleTap: enabled ? onDoubleTap : null,
      onLongPressStart: enabled && onDragStart != null
          ? (_) => onDragStart!()
          : null,
      onLongPressMoveUpdate: enabled && onDragUpdate != null
          ? (details) {
              final box = context.findRenderObject()! as RenderBox;
              onDragUpdate!(box.localToGlobal(details.localPosition));
            }
          : null,
      onLongPressEnd: enabled && onDragEnd != null
          ? (details) {
              final box = context.findRenderObject()! as RenderBox;
              onDragEnd!(box.localToGlobal(details.localPosition));
            }
          : null,
      child: content,
    );
  }
}
