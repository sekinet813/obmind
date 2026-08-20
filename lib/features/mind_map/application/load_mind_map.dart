import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parse_issue.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parser.dart';

/// Outcome of loading a Markdown file into a [MindMapDocument].
final class LoadMindMapResult {
  const LoadMindMapResult({
    required this.document,
    this.issues = const [],
    this.hasUnsupportedContent = false,
  });

  final MindMapDocument document;
  final List<MarkdownParseIssue> issues;
  final bool hasUnsupportedContent;
}

/// Thrown when Markdown cannot be parsed into a mind map.
final class LoadMindMapException implements Exception {
  const LoadMindMapException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'LoadMindMapException: $message';
}

/// Reads Markdown through [MindMapStorage] and parses it into a document.
final class LoadMindMap {
  const LoadMindMap({required this.storage, required this.parser});

  final MindMapStorage storage;
  final MarkdownParser parser;

  Future<LoadMindMapResult> call(MindMapLocation location) async {
    final markdown = await storage.read(location);
    final result = parser.parse(markdown);
    final document = result.document;
    if (document == null) {
      throw LoadMindMapException(
        'Markdown could not be parsed as a mind map',
        cause: result.issues,
      );
    }
    return LoadMindMapResult(
      document: document,
      issues: result.issues,
      hasUnsupportedContent: result.hasUnsupportedContent,
    );
  }
}
