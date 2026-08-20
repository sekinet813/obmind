import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/app/obmind_theme.dart';
import 'package:obmind/features/mind_map/domain/models/layout_type.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_serializer.dart';
import 'package:obmind/features/mind_map/presentation/theme/mind_map_canvas_theme.dart';
import 'package:obmind/features/mind_map/presentation/theme/mind_map_design_template.dart';

void main() {
  test('provides at least three visually distinct theme and layout pairs', () {
    expect(MindMapDesignTemplate.values, hasLength(greaterThanOrEqualTo(3)));
    expect(
      MindMapDesignTemplate.values.map((template) => template.theme).toSet(),
      hasLength(greaterThan(1)),
    );
    expect(
      MindMapDesignTemplate.values.map((template) => template.layout).toSet(),
      hasLength(greaterThan(1)),
    );

    final scheme = ObmindTheme.lightColorScheme;
    final looks = [
      for (final template in MindMapDesignTemplate.values)
        (
          template.layout,
          mindMapCanvasThemeFor(template.theme, scheme).nodeRadius,
          mindMapCanvasThemeFor(template.theme, scheme).edgeColor,
        ),
    ];
    expect(looks.toSet(), hasLength(MindMapDesignTemplate.values.length));
  });

  test('serializes templates as existing theme and layout frontmatter', () {
    final document = MindMapDocument(
      root: MindNode(id: const NodeId('root'), text: 'Root'),
    );
    final applied = document.copyWith(
      theme: MindMapDesignTemplate.softHorizontal.theme,
      layout: MindMapDesignTemplate.softHorizontal.layout,
    );
    final markdown = const MarkdownSerializer().serialize(applied);

    expect(markdown, contains('theme: soft'));
    expect(markdown, contains('layout: horizontal'));
    expect(applied.layout, LayoutType.horizontal);
  });
}
