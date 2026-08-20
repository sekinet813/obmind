import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parse_issue.dart';

/// Outcome of parsing Markdown into a [MindMapDocument].
final class MarkdownParseResult {
  const MarkdownParseResult({this.document, this.issues = const []});

  final MindMapDocument? document;
  final List<MarkdownParseIssue> issues;

  bool get isSuccess => document != null;

  bool get hasErrors => issues.any((issue) => issue.isError);

  /// True when the file contains constructs v0.1 does not round-trip.
  ///
  /// Application must not overwrite such a file without explicit confirmation.
  bool get hasUnsupportedContent => issues.any(
    (issue) =>
        issue.code == MarkdownParseIssueCode.unsupportedBlock ||
        issue.code == MarkdownParseIssueCode.unsupportedFrontmatter ||
        issue.code == MarkdownParseIssueCode.unclosedFrontmatter ||
        issue.code == MarkdownParseIssueCode.multipleRoots,
  );
}
