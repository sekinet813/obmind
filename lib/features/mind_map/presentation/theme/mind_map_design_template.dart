import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_theme_id.dart';

/// Presentation preset for canvas colors and node / edge style.
///
/// Layout is independent. Stored in Markdown as the existing `theme`
/// Frontmatter key, not as a new identifier.
final class MindMapDesignTemplate {
  const MindMapDesignTemplate({required this.id, required this.theme});

  final String id;
  final MindMapThemeId theme;

  static const paper = MindMapDesignTemplate(
    id: 'soft',
    theme: MindMapThemeId.soft,
  );

  static const inkwell = MindMapDesignTemplate(
    id: 'inkwell',
    theme: MindMapThemeId.inkwell,
  );

  static const dark = MindMapDesignTemplate(
    id: 'dark',
    theme: MindMapThemeId.dark,
  );

  static const minimal = MindMapDesignTemplate(
    id: 'minimal',
    theme: MindMapThemeId.minimal,
  );

  static const values = [paper, inkwell, dark, minimal];

  static MindMapDesignTemplate? byId(String id) {
    for (final template in values) {
      if (template.id == id) {
        return template;
      }
    }
    return null;
  }

  bool matches(MindMapDocument document) => document.theme == theme;
}
