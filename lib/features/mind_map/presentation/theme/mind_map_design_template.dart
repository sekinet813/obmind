import 'package:obmind/features/mind_map/domain/models/layout_type.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_theme_id.dart';

/// Presentation preset that pairs a canvas theme with a layout.
///
/// Stored in Markdown as existing `theme` / `layout` Frontmatter, not as a
/// new identifier.
final class MindMapDesignTemplate {
  const MindMapDesignTemplate({
    required this.id,
    required this.theme,
    required this.layout,
  });

  final String id;
  final MindMapThemeId theme;
  final LayoutType layout;

  static const minimalRadial = MindMapDesignTemplate(
    id: 'minimalRadial',
    theme: MindMapThemeId.minimal,
    layout: LayoutType.radial,
  );

  static const softHorizontal = MindMapDesignTemplate(
    id: 'softHorizontal',
    theme: MindMapThemeId.soft,
    layout: LayoutType.horizontal,
  );

  static const darkRadial = MindMapDesignTemplate(
    id: 'darkRadial',
    theme: MindMapThemeId.dark,
    layout: LayoutType.radial,
  );

  static const values = [minimalRadial, softHorizontal, darkRadial];

  static MindMapDesignTemplate? byId(String id) {
    for (final template in values) {
      if (template.id == id) {
        return template;
      }
    }
    return null;
  }

  bool matches(MindMapDocument document) {
    return document.theme == theme && document.layout == layout;
  }
}
