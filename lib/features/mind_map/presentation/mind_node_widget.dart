import 'package:flutter/material.dart';
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
    this.controller,
    this.focusNode,
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
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onToggleCollapsed;
  final Key? collapseToggleKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      textField: editing,
      selected: selected,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected
                  ? theme.nodeSelectedBackground
                  : theme.nodeBackground,
              borderRadius: BorderRadius.circular(theme.nodeRadius),
              border: Border.all(
                color: selected ? theme.nodeSelectedBorder : theme.nodeBorder,
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
                      maxLines: 3,
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
                      ),
                      onEditingComplete: onEditingComplete,
                      onSubmitted: (_) => onEditingComplete?.call(),
                      onTapOutside: (_) => onEditingComplete?.call(),
                    )
                  : Row(
                      children: [
                        if (hasChildren &&
                            onToggleCollapsed != null &&
                            !editing) ...[
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Listener(
                              behavior: HitTestBehavior.opaque,
                              onPointerUp: (_) => onToggleCollapsed?.call(),
                              child: Icon(
                                key: collapseToggleKey,
                                collapsed ? Icons.add : Icons.remove,
                                size: 16,
                                color: theme.collapsedIconColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              text,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.onNodeText,
                                fontSize: theme.nodeFontSize,
                                height: theme.nodeLineHeight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
