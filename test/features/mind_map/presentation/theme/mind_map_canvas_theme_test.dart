import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/app/brand_colors.dart';
import 'package:obmind/app/obmind_theme.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_theme_id.dart';
import 'package:obmind/features/mind_map/presentation/theme/mind_map_canvas_theme.dart';

void main() {
  test('minimal, soft, and dark themes are visually distinct', () {
    final scheme = ObmindTheme.lightColorScheme;
    final minimal = mindMapCanvasThemeFor(MindMapThemeId.minimal, scheme);
    final soft = mindMapCanvasThemeFor(MindMapThemeId.soft, scheme);
    final dark = mindMapCanvasThemeFor(MindMapThemeId.dark, scheme);

    expect(minimal.nodeRadius, isNot(soft.nodeRadius));
    expect(soft.nodePadding, isNot(dark.nodePadding));
    expect(dark.edgeColor, isNot(minimal.edgeColor));
  });

  test('canvas background uses brand cream in light mode', () {
    final theme = mindMapCanvasThemeFor(
      MindMapThemeId.minimal,
      ObmindTheme.lightColorScheme,
    );

    expect(theme.canvasBackground, BrandColors.cream);
  });

  test('canvas background uses brand dark cream in dark mode', () {
    final theme = mindMapCanvasThemeFor(
      MindMapThemeId.minimal,
      ObmindTheme.darkColorScheme,
    );

    expect(theme.canvasBackground, BrandColors.creamDark);
  });
}
