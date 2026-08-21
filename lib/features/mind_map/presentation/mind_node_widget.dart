import 'package:flutter/material.dart';
import 'package:obmind/features/mind_map/presentation/collapse_toggle_placement.dart';
import 'package:obmind/features/mind_map/presentation/theme/mind_map_canvas_theme.dart';

/// Visual node for a mind map. Coordinates are applied by the viewport, not here.
class MindNodeWidget extends StatelessWidget {
  const MindNodeWidget({
    super.key,
    required this.text,
    required this.theme,
    this.collapsed = false,
    this.selected = false,
    this.editing = false,
    this.hasChildren = false,
    this.collapseToggleDirection = const Offset(1, 0),
    this.controller,
    this.focusNode,
    this.emptyPlaceholder,
    this.onEditingComplete,
    this.onToggleCollapsed,
    this.collapseToggleKey,
  });

  final String text;
  final MindMapCanvasTheme theme;
  final bool collapsed;
  final bool selected;
  final bool editing;
  final bool hasChildren;

  /// Points from the node center toward the branch / edge.
  final Offset collapseToggleDirection;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? emptyPlaceholder;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onToggleCollapsed;
  final Key? collapseToggleKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text.isEmpty ? emptyPlaceholder : text,
      textField: editing,
      selected: selected,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 80, minHeight: 56),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final nodeSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final toggleCenter = collapseToggleCenter(
                nodeSize,
                collapseToggleDirection,
              );
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.nodeSelectedBackground
                            : theme.nodeBackground,
                        borderRadius: BorderRadius.circular(theme.nodeRadius),
                        border: Border.all(
                          color: selected
                              ? theme.nodeSelectedBorder
                              : theme.nodeBorder,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: theme.nodePadding,
                        child: editing
                            ? TextField(
                                controller: controller,
                                focusNode: focusNode,
                                autofocus: true,
                                minLines: 1,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                textInputAction: TextInputAction.done,
                                style: TextStyle(
                                  color: theme.onNodeText,
                                  fontSize: theme.nodeFontSize,
                                  height: theme.nodeLineHeight,
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ).copyWith(hintText: emptyPlaceholder),
                                onEditingComplete: onEditingComplete,
                                onSubmitted: (_) => onEditingComplete?.call(),
                                onTapOutside: (_) => onEditingComplete?.call(),
                              )
                            : Center(
                                child: Text(
                                  text.isEmpty ? emptyPlaceholder ?? '' : text,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.onNodeText,
                                    fontSize: theme.nodeFontSize,
                                    height: theme.nodeLineHeight,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (hasChildren && onToggleCollapsed != null && !editing)
                    Positioned(
                      left: toggleCenter.dx - kCollapseToggleHitSize / 2,
                      top: toggleCenter.dy - kCollapseToggleHitSize / 2,
                      width: kCollapseToggleHitSize,
                      height: kCollapseToggleHitSize,
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerUp: (_) => onToggleCollapsed?.call(),
                        child: Center(
                          child: Material(
                            color: theme.nodeBackground,
                            shape: CircleBorder(
                              side: BorderSide(color: theme.nodeBorder),
                            ),
                            child: SizedBox.square(
                              dimension: kCollapseToggleVisualSize,
                              child: Icon(
                                key: collapseToggleKey,
                                collapsed ? Icons.add : Icons.remove,
                                size: 16,
                                color: theme.collapsedIconColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
