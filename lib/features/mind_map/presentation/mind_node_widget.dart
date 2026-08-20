import 'package:flutter/material.dart';

/// Visual node for a mind map. Coordinates are applied by the viewport, not here.
class MindNodeWidget extends StatelessWidget {
  const MindNodeWidget({
    super.key,
    required this.text,
    this.collapsed = false,
    this.selected = false,
    this.onTap,
  });

  final String text;
  final bool collapsed;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: text,
      button: onTap != null,
      selected: selected,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? scheme.primary : scheme.outlineVariant,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (collapsed) ...[
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(text, maxLines: 3, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
