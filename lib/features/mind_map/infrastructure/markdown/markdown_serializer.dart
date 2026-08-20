import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';

/// Writes a [MindMapDocument] as Format v0.1 Markdown.
final class MarkdownSerializer {
  const MarkdownSerializer();

  String serialize(MindMapDocument document) {
    final buffer = StringBuffer()
      ..writeln('---')
      ..writeln('obmind:')
      ..writeln('  version: ${document.formatVersion}');
    final extras = Map<String, String>.of(document.extraObmindFields);
    final themeValue = extras.remove('theme') ?? document.theme.name;
    buffer.writeln('  theme: $themeValue');
    final layoutValue = extras.remove('layout') ?? document.layout.name;
    buffer.writeln('  layout: $layoutValue');
    final extraKeys = extras.keys.toList()..sort();
    for (final key in extraKeys) {
      buffer.writeln('  $key: ${extras[key]}');
    }
    buffer
      ..writeln('---')
      ..writeln()
      ..writeln('# ${_nodeLine(document.root)}');
    if (document.root.children.isNotEmpty) {
      buffer.writeln();
      _writeChildren(buffer, document.root.children, 0);
    }
    return buffer.toString();
  }

  void _writeChildren(StringBuffer buffer, List<MindNode> children, int level) {
    final indent = '  ' * level;
    for (final child in children) {
      buffer.writeln('$indent- ${_nodeLine(child)}');
      _writeChildren(buffer, child.children, level + 1);
    }
  }

  String _nodeLine(MindNode node) {
    final attributes = StringBuffer('id=${node.id.value}');
    if (node.collapsed) {
      attributes.write(' collapsed=true');
    }
    final extraKeys = node.metadata.keys.toList()..sort();
    for (final key in extraKeys) {
      attributes.write(' $key=${node.metadata[key]}');
    }
    return '${node.text} <!-- obmind:$attributes -->';
  }
}
