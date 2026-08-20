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
  test('provides visually distinct themes without coupling layout', () {
    expect(MindMapDesignTemplate.values, hasLength(greaterThanOrEqualTo(3)));
    expect(
      MindMapDesignTemplate.values.map((template) => template.theme).toSet(),
      hasLength(MindMapDesignTemplate.values.length),
    );

    final scheme = ObmindTheme.lightColorScheme;
    final looks = [
      for (final template in MindMapDesignTemplate.values)
        (
          mindMapCanvasThemeFor(template.theme, scheme).nodeRadius,
          mindMapCanvasThemeFor(template.theme, scheme).edgeColor,
        ),
    ];
    expect(looks.toSet(), hasLength(MindMapDesignTemplate.values.length));
  });

  test('applying a template keeps the current layout', () {
    final document = MindMapDocument(
      root: MindNode(id: const NodeId('root'), text: 'Root'),
      layout: LayoutType.radial,
    );
    final applied = document.copyWith(theme: MindMapDesignTemplate.paper.theme);
    final markdown = const MarkdownSerializer().serialize(applied);

    expect(applied.layout, LayoutType.radial);
    expect(markdown, contains('theme: soft'));
    expect(markdown, contains('layout: radial'));
    expect(MindMapDesignTemplate.paper.matches(applied), isTrue);
    expect(MindMapDesignTemplate.paper.matches(document), isFalse);
    expect(MindMapDesignTemplate.values, hasLength(4));
    expect(
      MindMapDesignTemplate.values.map((template) => template.theme).toSet(),
      containsAll([
        MindMapDesignTemplate.paper.theme,
        MindMapDesignTemplate.inkwell.theme,
        MindMapDesignTemplate.dark.theme,
        MindMapDesignTemplate.minimal.theme,
      ]),
    );
  });
}
