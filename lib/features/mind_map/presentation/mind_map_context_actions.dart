import 'package:flutter/material.dart';
import 'package:obmind/l10n/app_localizations.dart';

/// Context actions shown only for the selected node.
class MindMapContextActions extends StatelessWidget {
  const MindMapContextActions({
    super.key,
    required this.canAddSibling,
    required this.canDelete,
    required this.canToggleCollapsed,
    required this.collapsed,
    required this.onAddChild,
    required this.onAddSibling,
    required this.onDelete,
    required this.onToggleCollapsed,
    this.onEdit,
    this.canEdit = false,
  });

  final bool canAddSibling;
  final bool canDelete;
  final bool canToggleCollapsed;
  final bool collapsed;
  final VoidCallback onAddChild;
  final VoidCallback onAddSibling;
  final VoidCallback onDelete;
  final VoidCallback onToggleCollapsed;
  final VoidCallback? onEdit;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Wrap(
          spacing: 0,
          children: [
            if (canEdit && onEdit != null)
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.editNode),
              ),
            TextButton.icon(
              key: const Key('addChildNode'),
              onPressed: onAddChild,
              icon: const Icon(Icons.subdirectory_arrow_right),
              label: Text(l10n.addChildNode),
            ),
            TextButton.icon(
              key: const Key('addSiblingNode'),
              onPressed: canAddSibling ? onAddSibling : null,
              icon: const Icon(Icons.arrow_downward),
              label: Text(l10n.addSiblingNode),
            ),
            TextButton.icon(
              key: const Key('deleteNode'),
              onPressed: canDelete ? onDelete : null,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.deleteNode),
            ),
            TextButton.icon(
              key: const Key('toggleCollapsedNode'),
              onPressed: canToggleCollapsed ? onToggleCollapsed : null,
              icon: Icon(collapsed ? Icons.unfold_more : Icons.unfold_less),
              label: Text(collapsed ? l10n.expandNode : l10n.collapseNode),
            ),
          ],
        ),
      ),
    );
  }
}
