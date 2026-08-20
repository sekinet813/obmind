import 'package:flutter/material.dart';
import 'package:obmind/app/brand_colors.dart';
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
  final isDark = scheme.brightness == Brightness.dark;
  final canvasBackground = isDark ? BrandColors.creamDark : BrandColors.cream;

  switch (id) {
    case MindMapThemeId.minimal:
      return MindMapCanvasTheme(
        canvasBackground: canvasBackground,
        nodeBackground: isDark
            ? BrandColors.creamDarkElevated
            : BrandColors.creamElevated,
        nodeSelectedBackground: scheme.primaryContainer,
        nodeBorder: scheme.outlineVariant,
        nodeSelectedBorder: BrandColors.salmon,
        edgeColor: scheme.outline,
        onNodeText: scheme.onSurface,
        collapsedIconColor: scheme.onSurfaceVariant,
        nodeRadius: 10,
        nodePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        nodeFontSize: 14,
        nodeLineHeight: 1.3,
      );
    case MindMapThemeId.soft:
      return MindMapCanvasTheme(
        canvasBackground: canvasBackground,
        nodeBackground: isDark ? scheme.surfaceContainerHigh : Colors.white,
        nodeSelectedBackground: scheme.secondaryContainer,
        nodeBorder: BrandColors.sage.withValues(alpha: isDark ? 0.5 : 0.4),
        nodeSelectedBorder: BrandColors.mustard,
        edgeColor: BrandColors.sage.withValues(alpha: 0.75),
        onNodeText: scheme.onSurface,
        collapsedIconColor: BrandColors.sage,
        nodeRadius: 18,
        nodePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        nodeFontSize: 15,
        nodeLineHeight: 1.35,
      );
    case MindMapThemeId.dark:
      return MindMapCanvasTheme(
        canvasBackground: canvasBackground,
        nodeBackground: scheme.surfaceContainerHighest,
        nodeSelectedBackground: scheme.tertiaryContainer,
        nodeBorder: scheme.outline,
        nodeSelectedBorder: BrandColors.sage,
        edgeColor: BrandColors.salmon.withValues(alpha: 0.7),
        onNodeText: scheme.onSurface,
        collapsedIconColor: BrandColors.salmon,
        nodeRadius: 14,
        nodePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        nodeFontSize: 14,
        nodeLineHeight: 1.3,
      );
  }
}
