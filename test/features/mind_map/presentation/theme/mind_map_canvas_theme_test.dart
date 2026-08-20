import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_theme_id.dart';
import 'package:obmind/features/mind_map/presentation/theme/mind_map_canvas_theme.dart';

void main() {
  test('minimal, soft, and dark themes are visually distinct', () {
    final scheme = ThemeData(useMaterial3: true).colorScheme;
    final minimal = mindMapCanvasThemeFor(MindMapThemeId.minimal, scheme);
    final soft = mindMapCanvasThemeFor(MindMapThemeId.soft, scheme);
    final dark = mindMapCanvasThemeFor(MindMapThemeId.dark, scheme);

    expect(minimal.nodeRadius, isNot(soft.nodeRadius));
    expect(soft.nodePadding, isNot(dark.nodePadding));
    expect(dark.edgeColor, isNot(minimal.edgeColor));
  });
}
