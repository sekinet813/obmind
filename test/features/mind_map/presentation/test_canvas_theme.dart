import 'package:flutter/material.dart';
import 'package:obmind/app/obmind_theme.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_theme_id.dart';
import 'package:obmind/features/mind_map/presentation/theme/mind_map_canvas_theme.dart';

MindMapCanvasTheme testCanvasTheme([Brightness brightness = Brightness.light]) {
  final scheme = brightness == Brightness.dark
      ? ObmindTheme.darkColorScheme
      : ObmindTheme.lightColorScheme;
  return mindMapCanvasThemeFor(MindMapThemeId.minimal, scheme);
}
