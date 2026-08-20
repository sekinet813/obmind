import 'package:flutter/material.dart';
import 'package:obmind/l10n/app_localizations.dart';

/// Zoom in / out controls for the mind map canvas.
class MindMapZoomControls extends StatelessWidget {
  const MindMapZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: const Key('zoomIn'),
            tooltip: l10n.zoomIn,
            onPressed: onZoomIn,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            key: const Key('zoomOut'),
            tooltip: l10n.zoomOut,
            onPressed: onZoomOut,
            icon: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
