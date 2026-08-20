import 'dart:convert';

import 'package:obmind/core/utils/uuid_v4.dart';
import 'package:obmind/features/mind_map/domain/models/layout_type.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_theme_id.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parse_issue.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parse_result.dart';

final _h1Pattern = RegExp(r'^#\s+(.*)$');
final _headingPattern = RegExp(r'^#{2,}\s+');
final _unorderedListPattern = RegExp(r'^(\s*)-\s+(.*)$');
final _otherListPattern = RegExp(r'^(\s*)[*+]\s+');
final _orderedListPattern = RegExp(r'^\s*\d+\.\s+');
final _blockquotePattern = RegExp(r'^\s*>');
final _codeFencePattern = RegExp(r'^(\s*)```');
final _tablePattern = RegExp(r'^\s*\|');
final _wikiLinkPattern = RegExp(r'\[\[');
final _obmindCommentPattern = RegExp(
  r'^(.*?)(?:\s*<!--\s*obmind:([^>]*)-->)\s*$',
);
final _attributePattern = RegExp(r'(\w+)=([^\s]+)');

/// Parses Format v0.1 Markdown into a [MindMapDocument].
///
/// Unsupported constructs are reported as issues. Application decides whether
/// the original file may be overwritten.
final class MarkdownParser {
  MarkdownParser({NodeId Function()? generateId})
    : _generateId = generateId ?? (() => NodeId(generateUuidV4()));

  final NodeId Function() _generateId;

  MarkdownParseResult parse(String markdown) {
    final issues = <MarkdownParseIssue>[];
    final normalized = markdown.replaceFirst('\uFEFF', '');
    final lines = const LineSplitter().convert(normalized);

    final frontmatter = _parseFrontmatter(lines, issues);
    if (frontmatter.unknownMajorVersion) {
      return MarkdownParseResult(issues: List.unmodifiable(issues));
    }

    final bodyStart = frontmatter.bodyStart;
    _NodeBuilder? root;
    var seenRoot = false;
    var inCodeFence = false;
    final stack = <_NodeBuilder>[];
    final seenIds = <String>{};

    for (var i = bodyStart; i < lines.length; i++) {
      final lineNumber = i + 1;
      final line = lines[i];
      if (inCodeFence) {
        issues.add(
          MarkdownParseIssue(
            code: MarkdownParseIssueCode.unsupportedBlock,
            message: 'unsupported code block',
            line: lineNumber,
          ),
        );
        if (_codeFencePattern.hasMatch(line)) {
          inCodeFence = false;
        }
        continue;
      }

      if (line.trim().isEmpty) {
        continue;
      }

      if (_codeFencePattern.hasMatch(line)) {
        inCodeFence = true;
        issues.add(
          MarkdownParseIssue(
            code: MarkdownParseIssueCode.unsupportedBlock,
            message: 'unsupported code block',
            line: lineNumber,
          ),
        );
        continue;
      }

      if (_tablePattern.hasMatch(line) ||
          _blockquotePattern.hasMatch(line) ||
          _orderedListPattern.hasMatch(line) ||
          _otherListPattern.hasMatch(line) ||
          _headingPattern.hasMatch(line) ||
          _wikiLinkPattern.hasMatch(line)) {
        issues.add(
          MarkdownParseIssue(
            code: MarkdownParseIssueCode.unsupportedBlock,
            message: 'unsupported Markdown construct',
            line: lineNumber,
          ),
        );
        continue;
      }

      final h1Match = _h1Pattern.firstMatch(line);
      if (h1Match != null) {
        final parsed = _parseNodeLine(
          h1Match.group(1)!,
          lineNumber,
          issues,
          seenIds,
        );
        if (seenRoot) {
          issues.add(
            MarkdownParseIssue(
              code: MarkdownParseIssueCode.multipleRoots,
              message: 'multiple H1 headings are not supported',
              line: lineNumber,
            ),
          );
          continue;
        }
        seenRoot = true;
        root = parsed;
        stack
          ..clear()
          ..add(parsed);
        continue;
      }

      final listMatch = _unorderedListPattern.firstMatch(line);
      if (listMatch != null) {
        if (root == null) {
          issues.add(
            MarkdownParseIssue(
              code: MarkdownParseIssueCode.unsupportedBlock,
              message: 'list item appeared before H1',
              line: lineNumber,
            ),
          );
          continue;
        }
        final spaces = listMatch.group(1)!.length;
        if (spaces.isOdd) {
          issues.add(
            MarkdownParseIssue(
              code: MarkdownParseIssueCode.irregularIndent,
              message: 'list indent should use 2 spaces per level',
              line: lineNumber,
            ),
          );
        }
        var level = spaces ~/ 2;
        if (level >= stack.length) {
          issues.add(
            MarkdownParseIssue(
              code: MarkdownParseIssueCode.irregularIndent,
              message: 'list item skipped a parent level',
              line: lineNumber,
            ),
          );
          level = stack.length - 1;
        }
        final node = _parseNodeLine(
          listMatch.group(2)!,
          lineNumber,
          issues,
          seenIds,
        );
        stack.removeRange(level + 1, stack.length);
        stack[level].children.add(node);
        stack.add(node);
        continue;
      }

      issues.add(
        MarkdownParseIssue(
          code: MarkdownParseIssueCode.unsupportedBlock,
          message: 'unsupported Markdown construct',
          line: lineNumber,
        ),
      );
    }

    if (inCodeFence) {
      issues.add(
        const MarkdownParseIssue(
          code: MarkdownParseIssueCode.unsupportedBlock,
          message: 'unclosed code block',
        ),
      );
    }

    if (root == null) {
      issues.add(
        const MarkdownParseIssue(
          code: MarkdownParseIssueCode.missingRoot,
          message: 'Markdown is missing an H1 root heading',
          severity: MarkdownParseIssueSeverity.error,
        ),
      );
      return MarkdownParseResult(issues: List.unmodifiable(issues));
    }

    return MarkdownParseResult(
      document: MindMapDocument(
        root: root.build(),
        theme: frontmatter.theme,
        layout: frontmatter.layout,
        formatVersion: frontmatter.version,
        extraObmindFields: frontmatter.extraObmindFields,
      ),
      issues: List.unmodifiable(issues),
    );
  }

  _Frontmatter _parseFrontmatter(
    List<String> lines,
    List<MarkdownParseIssue> issues,
  ) {
    if (lines.isEmpty || lines.first.trim() != '---') {
      return const _Frontmatter(bodyStart: 0);
    }

    var closing = -1;
    for (var i = 1; i < lines.length; i++) {
      if (lines[i].trim() == '---') {
        closing = i;
        break;
      }
    }
    if (closing < 0) {
      issues.add(
        const MarkdownParseIssue(
          code: MarkdownParseIssueCode.unclosedFrontmatter,
          message: 'frontmatter is missing a closing ---',
          severity: MarkdownParseIssueSeverity.warning,
        ),
      );
      return const _Frontmatter(bodyStart: 0);
    }

    var inObmind = false;
    var sawObmind = false;
    var unknownMajor = false;
    var version = 1;
    var theme = MindMapThemeId.minimal;
    var layout = LayoutType.horizontal;
    final extra = <String, String>{};

    for (var i = 1; i < closing; i++) {
      final lineNumber = i + 1;
      final raw = lines[i];
      if (raw.trim().isEmpty) {
        continue;
      }

      final indent = raw.length - raw.trimLeft().length;
      final trimmed = raw.trim();
      if (indent == 0 && trimmed == 'obmind:') {
        inObmind = true;
        sawObmind = true;
        continue;
      }
      if (indent == 0) {
        inObmind = false;
        issues.add(
          MarkdownParseIssue(
            code: MarkdownParseIssueCode.unsupportedFrontmatter,
            message: 'unsupported top-level frontmatter key',
            line: lineNumber,
          ),
        );
        continue;
      }
      if (!inObmind) {
        issues.add(
          MarkdownParseIssue(
            code: MarkdownParseIssueCode.unsupportedFrontmatter,
            message: 'unsupported frontmatter content',
            line: lineNumber,
          ),
        );
        continue;
      }
      if (indent != 2) {
        issues.add(
          MarkdownParseIssue(
            code: MarkdownParseIssueCode.unsupportedFrontmatter,
            message: 'nested frontmatter keys are not supported in v0.1',
            line: lineNumber,
          ),
        );
        continue;
      }

      final colon = trimmed.indexOf(':');
      if (colon <= 0) {
        issues.add(
          MarkdownParseIssue(
            code: MarkdownParseIssueCode.unsupportedFrontmatter,
            message: 'invalid frontmatter line',
            line: lineNumber,
          ),
        );
        continue;
      }
      final key = trimmed.substring(0, colon).trim();
      final value = _unquote(trimmed.substring(colon + 1));
      switch (key) {
        case 'version':
          final parsedVersion = _parseVersion(value);
          if (parsedVersion == null || parsedVersion.$1 != 1) {
            unknownMajor = true;
            issues.add(
              MarkdownParseIssue(
                code: MarkdownParseIssueCode.unknownFormatVersion,
                message: 'unknown Markdown format version "$value"',
                severity: MarkdownParseIssueSeverity.error,
                line: lineNumber,
              ),
            );
          } else {
            version = parsedVersion.$1;
          }
        case 'theme':
          final parsedTheme = _parseTheme(value);
          if (parsedTheme == null) {
            issues.add(
              MarkdownParseIssue(
                code: MarkdownParseIssueCode.unknownTheme,
                message: 'unknown theme "$value"',
                line: lineNumber,
              ),
            );
          } else {
            theme = parsedTheme;
          }
        case 'layout':
          final parsedLayout = _parseLayout(value);
          if (parsedLayout == null) {
            issues.add(
              MarkdownParseIssue(
                code: MarkdownParseIssueCode.unknownLayout,
                message: 'unknown layout "$value"',
                line: lineNumber,
              ),
            );
          } else {
            layout = parsedLayout;
          }
        default:
          extra[key] = value;
      }
    }

    if (!sawObmind) {
      issues.add(
        const MarkdownParseIssue(
          code: MarkdownParseIssueCode.unsupportedFrontmatter,
          message: 'frontmatter is missing an obmind block',
        ),
      );
    }

    return _Frontmatter(
      bodyStart: closing + 1,
      version: version,
      theme: theme,
      layout: layout,
      extraObmindFields: extra,
      unknownMajorVersion: unknownMajor,
    );
  }

  _NodeBuilder _parseNodeLine(
    String rawText,
    int lineNumber,
    List<MarkdownParseIssue> issues,
    Set<String> seenIds,
  ) {
    var text = rawText.trim();
    var collapsed = false;
    final metadata = <String, String>{};
    NodeId? id;

    final comment = _obmindCommentPattern.firstMatch(text);
    if (comment != null) {
      text = comment.group(1)!.trim();
      for (final match in _attributePattern.allMatches(comment.group(2)!)) {
        final key = match.group(1)!;
        final value = match.group(2)!;
        switch (key) {
          case 'id':
            if (value.isEmpty) {
              continue;
            }
            id = NodeId(value);
          case 'collapsed':
            if (value.toLowerCase() == 'true') {
              collapsed = true;
            } else if (value.toLowerCase() != 'false') {
              metadata[key] = value;
            }
          default:
            metadata[key] = value;
        }
      }
    }

    if (id == null) {
      id = _uniqueId(seenIds);
      issues.add(
        MarkdownParseIssue(
          code: MarkdownParseIssueCode.missingNodeId,
          message: 'assigned a new node id',
          line: lineNumber,
        ),
      );
    } else if (!seenIds.add(id.value)) {
      issues.add(
        MarkdownParseIssue(
          code: MarkdownParseIssueCode.duplicateNodeId,
          message: 'duplicate node id "${id.value}" was replaced',
          line: lineNumber,
        ),
      );
      id = _uniqueId(seenIds);
    }

    return _NodeBuilder(
      id: id,
      text: text,
      collapsed: collapsed,
      metadata: metadata,
    );
  }

  NodeId _uniqueId(Set<String> seenIds) {
    var id = _generateId();
    while (!seenIds.add(id.value)) {
      id = _generateId();
    }
    return id;
  }

  (int, int?)? _parseVersion(String value) {
    final parts = value.split('.');
    final major = int.tryParse(parts.first);
    if (major == null) {
      return null;
    }
    final minor = parts.length > 1 ? int.tryParse(parts[1]) : null;
    return (major, minor);
  }

  MindMapThemeId? _parseTheme(String value) {
    return switch (value) {
      'minimal' => MindMapThemeId.minimal,
      'soft' => MindMapThemeId.soft,
      'dark' => MindMapThemeId.dark,
      _ => null,
    };
  }

  LayoutType? _parseLayout(String value) {
    return switch (value) {
      'horizontal' => LayoutType.horizontal,
      _ => null,
    };
  }

  String _unquote(String value) {
    final trimmed = value.trim();
    if (trimmed.length >= 2) {
      final first = trimmed[0];
      final last = trimmed[trimmed.length - 1];
      if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
        return trimmed.substring(1, trimmed.length - 1);
      }
    }
    return trimmed;
  }
}

final class _Frontmatter {
  const _Frontmatter({
    required this.bodyStart,
    this.version = 1,
    this.theme = MindMapThemeId.minimal,
    this.layout = LayoutType.horizontal,
    this.extraObmindFields = const {},
    this.unknownMajorVersion = false,
  });

  final int bodyStart;
  final int version;
  final MindMapThemeId theme;
  final LayoutType layout;
  final Map<String, String> extraObmindFields;
  final bool unknownMajorVersion;
}

final class _NodeBuilder {
  _NodeBuilder({
    required this.id,
    required this.text,
    required this.collapsed,
    required this.metadata,
  });

  final NodeId id;
  final String text;
  final bool collapsed;
  final Map<String, String> metadata;
  final List<_NodeBuilder> children = [];

  MindNode build() {
    return MindNode(
      id: id,
      text: text,
      collapsed: collapsed,
      metadata: metadata,
      children: children.map((child) => child.build()).toList(growable: false),
    );
  }
}
