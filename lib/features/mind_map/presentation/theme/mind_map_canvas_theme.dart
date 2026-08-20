import 'package:flutter/material.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_theme_id.dart';

/// Presentation-side colors and shapes for a mind map theme.
final class MindMapCanvasTheme {
  const MindMapCanvasTheme({
    required this.canvasBackground,
    required this.nodeBackground,
    required this.nodeSelectedBackground,
    required this.nodeBorder,
    required this.nodeSelectedBorder,
    required this.edgeColor,
    required this.onNodeText,
    required this.collapsedIconColor,
    required this.nodeRadius,
    required this.nodePadding,
    required this.nodeFontSize,
    required this.nodeLineHeight,
  });

  final Color canvasBackground;
  final Color nodeBackground;
  final Color nodeSelectedBackground;
  final Color nodeBorder;
  final Color nodeSelectedBorder;
  final Color edgeColor;
  final Color onNodeText;
  final Color collapsedIconColor;
  final double nodeRadius;
  final EdgeInsets nodePadding;
  final double nodeFontSize;
  final double nodeLineHeight;
}

MindMapCanvasTheme mindMapCanvasThemeFor(
  MindMapThemeId id,
  ColorScheme scheme,
) {
  switch (id) {
    case MindMapThemeId.minimal:
      return MindMapCanvasTheme(
        canvasBackground: scheme.surface,
        nodeBackground: scheme.surfaceContainerLowest,
        nodeSelectedBackground: scheme.primaryContainer,
        nodeBorder: scheme.outline,
        nodeSelectedBorder: scheme.primary,
        edgeColor: scheme.outline,
        onNodeText: scheme.onSurface,
        collapsedIconColor: scheme.onSurfaceVariant,
        nodeRadius: 8,
        nodePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        nodeFontSize: 14,
        nodeLineHeight: 1.3,
      );
    case MindMapThemeId.soft:
      return MindMapCanvasTheme(
        canvasBackground: scheme.surfaceContainerLowest,
        nodeBackground: scheme.surfaceContainerHigh,
        nodeSelectedBackground: scheme.secondaryContainer,
        nodeBorder: scheme.outlineVariant,
        nodeSelectedBorder: scheme.secondary,
        edgeColor: scheme.secondary.withValues(alpha: 0.7),
        onNodeText: scheme.onSurface,
        collapsedIconColor: scheme.secondary,
        nodeRadius: 16,
        nodePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        nodeFontSize: 15,
        nodeLineHeight: 1.35,
      );
    case MindMapThemeId.dark:
      return MindMapCanvasTheme(
        canvasBackground: scheme.surface,
        nodeBackground: scheme.surfaceContainerHighest,
        nodeSelectedBackground: scheme.tertiaryContainer,
        nodeBorder: scheme.outline,
        nodeSelectedBorder: scheme.tertiary,
        edgeColor: scheme.tertiary.withValues(alpha: 0.8),
        onNodeText: scheme.onSurface,
        collapsedIconColor: scheme.tertiary,
        nodeRadius: 12,
        nodePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        nodeFontSize: 14,
        nodeLineHeight: 1.3,
      );
  }
}
