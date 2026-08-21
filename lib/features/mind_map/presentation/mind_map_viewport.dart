import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engines.dart';
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
    this.layoutEngine,
    this.nodeSizes = const {},
    this.panEnabled = true,
    this.scaleEnabled = true,
    this.minScale = 0.5,
    this.maxScale = 2.5,
    this.selectedId,
    this.editingId,
    this.editingController,
    this.editingFocusNode,
    this.emptyNodePlaceholder,
    this.onNodeSelected,
    this.onNodeLongPress,
    this.onNodeDoubleTap,
    this.onNodeDragStart,
    this.onNodeDragUpdate,
    this.onNodeDragEnd,
    this.draggingId,
    this.dropTargetId,
    this.onEditingComplete,
    this.onToggleCollapsed,
    this.animateLayout = true,
    this.transformationController,
    this.centerPadding = EdgeInsets.zero,
  });

  final MindMapDocument document;
  final MindMapCanvasTheme canvasTheme;

  /// When null, the engine is chosen from [MindMapDocument.layout].
  final LayoutEngine? layoutEngine;
  final Map<NodeId, NodeSize> nodeSizes;
  final bool panEnabled;
  final bool scaleEnabled;
  final double minScale;
  final double maxScale;
  final NodeId? selectedId;
  final NodeId? editingId;
  final TextEditingController? editingController;
  final FocusNode? editingFocusNode;
  final String? emptyNodePlaceholder;
  final ValueChanged<NodeId>? onNodeSelected;
  final ValueChanged<NodeId>? onNodeLongPress;
  final ValueChanged<NodeId>? onNodeDoubleTap;
  final ValueChanged<NodeId>? onNodeDragStart;
  final ValueChanged<Offset>? onNodeDragUpdate;
  final ValueChanged<Offset>? onNodeDragEnd;
  final NodeId? draggingId;
  final NodeId? dropTargetId;
  final VoidCallback? onEditingComplete;
  final ValueChanged<NodeId>? onToggleCollapsed;
  final bool animateLayout;
  final TransformationController? transformationController;

  /// Insets of the visible canvas used when centering the root on open.
  ///
  /// AppBar is already outside this widget. Bottom context actions can be
  /// reserved here so the root is not hidden behind them.
  final EdgeInsets centerPadding;

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
  var _didCenterOnOpen = false;
  Offset _boundsOrigin = Offset.zero;
  NodeId? _ensuredEditingId;
  EdgeInsets _ensuredViewInsets = EdgeInsets.zero;
  Size? _ensuredViewportSize;

  TransformationController get _transformationController =>
      widget.transformationController ?? _ownedController!;

  @override
  void initState() {
    super.initState();
    if (widget.transformationController == null) {
      _ownedController = TransformationController();
    }
    _targetLayout = _layoutEngine.layout(
      widget.document,
      nodeSizes: widget.nodeSizes,
    );
    _boundsOrigin = _originOf(_targetLayout!);
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
      _syncBoundsOrigin(_animatedLayout(_targetLayout!));
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(MindMapViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextLayout = _layoutEngine.layout(
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
      _syncBoundsOrigin(nextLayout);
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

  LayoutEngine get _layoutEngine =>
      widget.layoutEngine ?? layoutEngineFor(widget.document.layout);

  /// Current layout used for drag hit testing.
  MindMapLayout get currentLayout => _animatedLayout(
    _layoutEngine.layout(widget.document, nodeSizes: widget.nodeSizes),
  );

  /// Converts a global pointer position into layout coordinates.
  Offset globalToLayout(Offset global) {
    final context = _layoutKey.currentContext;
    if (context == null) {
      return Offset.zero;
    }
    final box = context.findRenderObject()! as RenderBox;
    return box.globalToLocal(global) + _originOf(currentLayout);
  }

  /// Places the root node near the center of the visible canvas.
  ///
  /// Uses a readable scale of 1.0 (clamped to min / max). Does not shrink the
  /// whole map. Pan / zoom are not persisted.
  void centerOnRoot(Size viewportSize) {
    final layout = _targetLayout;
    if (layout == null || viewportSize.isEmpty) {
      return;
    }
    final root = layout[widget.document.root.id];
    if (root == null) {
      return;
    }
    final padding = widget.centerPadding;
    final availableWidth = math.max(viewportSize.width - padding.horizontal, 1);
    final availableHeight = math.max(viewportSize.height - padding.vertical, 1);
    final scale = 1.0.clamp(widget.minScale, widget.maxScale);
    final origin = _originOf(layout);
    final rootCenterX = root.x + root.width / 2 - origin.dx;
    final rootCenterY = root.y + root.height / 2 - origin.dy;
    final viewCenterX = padding.left + availableWidth / 2;
    final viewCenterY = padding.top + availableHeight / 2;
    final dx = viewCenterX - rootCenterX * scale;
    final dy = viewCenterY - rootCenterY * scale;
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  /// Pans just enough for [id] to sit inside the visible canvas.
  ///
  /// Does not change scale or persist coordinates. Keyboard overlap is
  /// subtracted so an editing node stays above the IME.
  void ensureNodeVisible(NodeId id, Size viewportSize) {
    final layout = _targetLayout;
    if (layout == null || viewportSize.isEmpty) {
      return;
    }
    final node = layout[id];
    if (node == null) {
      return;
    }
    final origin = _originOf(layout);
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale <= 0) {
      return;
    }
    final tx = _transformationController.value.storage[12];
    final ty = _transformationController.value.storage[13];
    final padding = widget.centerPadding;
    final keyboardOverlap = _keyboardOverlap(viewportSize);
    const margin = 16.0;
    final view = Rect.fromLTWH(
      padding.left + margin,
      padding.top + margin,
      math.max(viewportSize.width - padding.horizontal - margin * 2, 1),
      math.max(
        viewportSize.height - padding.vertical - keyboardOverlap - margin * 2,
        1,
      ),
    );
    final left = (node.x - origin.dx) * scale + tx;
    final top = (node.y - origin.dy) * scale + ty;
    final right = left + node.width * scale;
    final bottom = top + node.height * scale;

    var dx = 0.0;
    var dy = 0.0;
    if (left < view.left && right <= view.right) {
      dx = view.left - left;
    } else if (right > view.right && left >= view.left) {
      dx = view.right - right;
    }
    if (top < view.top && bottom <= view.bottom) {
      dy = view.top - top;
    } else if (bottom > view.bottom && top >= view.top) {
      dy = view.bottom - bottom;
    }
    if (dx == 0 && dy == 0) {
      return;
    }
    final next = Matrix4.copy(_transformationController.value);
    next.storage[12] += dx;
    next.storage[13] += dy;
    _transformationController.value = next;
  }

  /// How much of [viewportSize] is covered by the software keyboard.
  ///
  /// Scaffold may already shrink the body; this only counts remaining overlap.
  double _keyboardOverlap(Size viewportSize) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return 0;
    }
    final view = View.of(context);
    final keyboard = MediaQueryData.fromView(view).viewInsets.bottom;
    if (keyboard <= 0) {
      return 0;
    }
    final viewportBottom = box.localToGlobal(Offset(0, viewportSize.height)).dy;
    final screenHeight = view.physicalSize.height / view.devicePixelRatio;
    return math.max(0, viewportBottom - (screenHeight - keyboard));
  }

  void _scheduleInitialCenter(Size viewportSize) {
    if (_didCenterOnOpen) {
      return;
    }
    _didCenterOnOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      centerOnRoot(viewportSize);
    });
  }

  /// Pans the editing node above the keyboard without changing zoom.
  void _scheduleEnsureEditingVisible(Size viewportSize) {
    final id = widget.editingId;
    final insets = MediaQueryData.fromView(View.of(context)).viewInsets;
    if (id == null) {
      _ensuredEditingId = null;
      _ensuredViewInsets = insets;
      _ensuredViewportSize = viewportSize;
      return;
    }
    if (id == _ensuredEditingId &&
        insets == _ensuredViewInsets &&
        _ensuredViewportSize == viewportSize) {
      return;
    }
    _ensuredEditingId = id;
    _ensuredViewInsets = insets;
    _ensuredViewportSize = viewportSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.editingId != id) {
        return;
      }
      ensureNodeVisible(id, viewportSize);
    });
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
      ..scaleByDouble(scale, scale, scale, 1);
  }

  static const zoomStep = 1.25;

  /// Zooms in around the viewport center without storing coordinates in Domain.
  void zoomIn() => zoomBy(zoomStep);

  /// Zooms out around the viewport center without storing coordinates in Domain.
  void zoomOut() => zoomBy(1 / zoomStep);

  /// Multiplies the current scale by [factor] and clamps to min / max scale.
  void zoomBy(double factor) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || box.size.isEmpty) {
      return;
    }
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale <= 0) {
      return;
    }
    final nextScale = (currentScale * factor).clamp(
      widget.minScale,
      widget.maxScale,
    );
    if ((nextScale - currentScale).abs() < 0.0001) {
      return;
    }
    final cx = box.size.width / 2;
    final cy = box.size.height / 2;
    final sceneFocal = _transformationController.toScene(Offset(cx, cy));
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(cx, cy, 0, 1)
      ..scaleByDouble(nextScale, nextScale, nextScale, 1)
      ..translateByDouble(-sceneFocal.dx, -sceneFocal.dy, 0, 1);
  }

  void _syncBoundsOrigin(MindMapLayout layout) {
    final origin = _originOf(layout);
    if (_didCenterOnOpen && origin != _boundsOrigin) {
      final scale = _transformationController.value.getMaxScaleOnAxis();
      final matrix = Matrix4.copy(_transformationController.value);
      matrix.storage[12] += (origin.dx - _boundsOrigin.dx) * scale;
      matrix.storage[13] += (origin.dy - _boundsOrigin.dy) * scale;
      _transformationController.value = matrix;
    }
    _boundsOrigin = origin;
  }

  static Offset _originOf(MindMapLayout layout) {
    if (layout.nodes.isEmpty) {
      return Offset.zero;
    }
    var minX = double.infinity;
    var minY = double.infinity;
    for (final node in layout.nodes.values) {
      minX = math.min(minX, node.x);
      minY = math.min(minY, node.y);
    }
    return Offset(minX, minY);
  }

  static MindMapLayout _shiftedLayout(MindMapLayout layout, Offset origin) {
    if (origin == Offset.zero) {
      return layout;
    }
    return MindMapLayout(
      nodes: {
        for (final entry in layout.nodes.entries)
          entry.key: NodeLayout(
            id: entry.value.id,
            x: entry.value.x - origin.dx,
            y: entry.value.y - origin.dy,
            width: entry.value.width,
            height: entry.value.height,
          ),
      },
      width: layout.width,
      height: layout.height,
    );
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
      _layoutEngine.layout(widget.document, nodeSizes: widget.nodeSizes),
    );
    final origin = _originOf(layout);
    final displayLayout = _shiftedLayout(layout, origin);

    return ColoredBox(
      color: widget.canvasTheme.canvasBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.hasBoundedWidth &&
              constraints.hasBoundedHeight &&
              constraints.maxWidth > 0 &&
              constraints.maxHeight > 0) {
            final viewportSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            _scheduleInitialCenter(viewportSize);
            _scheduleEnsureEditingVisible(viewportSize);
          }
          return InteractiveViewer(
            transformationController: _transformationController,
            panEnabled: widget.panEnabled && widget.draggingId == null,
            scaleEnabled: widget.scaleEnabled && widget.draggingId == null,
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            constrained: false,
            child: SizedBox(
              key: _layoutKey,
              width: displayLayout.width,
              height: displayLayout.height,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: widget.editingId == null
                    ? null
                    : widget.onEditingComplete,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    MindMapEdgeLayer(
                      document: widget.document,
                      layout: displayLayout,
                      color: widget.canvasTheme.edgeColor,
                    ),
                    for (final node in widget.document.root.depthFirst)
                      if (displayLayout[node.id] != null)
                        Positioned(
                          key: ValueKey(node.id.value),
                          left: displayLayout[node.id]!.x,
                          top: displayLayout[node.id]!.y,
                          width: displayLayout[node.id]!.width,
                          height: displayLayout[node.id]!.height,
                          child: _NodeGestureTarget(
                            tapEnabled: widget.editingId != node.id,
                            dragEnabled: widget.editingId == null,
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
                              hasChildren: node.children.isNotEmpty,
                              controller: widget.editingController,
                              focusNode: widget.editingFocusNode,
                              emptyPlaceholder: widget.emptyNodePlaceholder,
                              onEditingComplete: widget.onEditingComplete,
                              collapseToggleKey: Key(
                                'collapseToggle-${node.id.value}',
                              ),
                              onToggleCollapsed:
                                  widget.onToggleCollapsed == null ||
                                      widget.editingId != null
                                  ? null
                                  : () => widget.onToggleCollapsed!(node.id),
                            ),
                          ),
                        ),
                  ],
                ),
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
    required this.tapEnabled,
    required this.dragEnabled,
    this.dragging = false,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  final Widget child;
  final bool tapEnabled;
  final bool dragEnabled;
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
      onTap: tapEnabled ? onTap : null,
      onLongPress: dragEnabled && onDragStart == null ? onLongPress : null,
      onDoubleTap: dragEnabled ? onDoubleTap : null,
      onLongPressStart: dragEnabled && onDragStart != null
          ? (_) => onDragStart!()
          : null,
      onLongPressMoveUpdate: dragEnabled && onDragUpdate != null
          ? (details) {
              final box = context.findRenderObject()! as RenderBox;
              onDragUpdate!(box.localToGlobal(details.localPosition));
            }
          : null,
      onLongPressEnd: dragEnabled && onDragEnd != null
          ? (details) {
              final box = context.findRenderObject()! as RenderBox;
              onDragEnd!(box.localToGlobal(details.localPosition));
            }
          : null,
      child: content,
    );
  }
}
