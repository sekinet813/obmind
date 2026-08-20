/// Why a Markdown file could not be interpreted cleanly.
enum MarkdownParseIssueCode {
  missingRoot,
  unknownFormatVersion,
  unclosedFrontmatter,
  unsupportedFrontmatter,
  unsupportedBlock,
  missingNodeId,
  duplicateNodeId,
  irregularIndent,
  multipleRoots,
  unknownTheme,
  unknownLayout,
}

enum MarkdownParseIssueSeverity { warning, error }

/// A parse warning or error. Application decides whether saving is safe.
final class MarkdownParseIssue {
  const MarkdownParseIssue({
    required this.code,
    required this.message,
    this.severity = MarkdownParseIssueSeverity.warning,
    this.line,
  });

  final MarkdownParseIssueCode code;
  final String message;
  final MarkdownParseIssueSeverity severity;
  final int? line;

  bool get isError => severity == MarkdownParseIssueSeverity.error;
}
