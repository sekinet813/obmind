import 'package:flutter/material.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/features/mind_map/application/markdown_file_service.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/l10n/app_localizations.dart';

class MarkdownEditorPage extends StatefulWidget {
  const MarkdownEditorPage({
    super.key,
    required this.file,
    required this.initialMarkdown,
    required this.markdownFiles,
  });

  final MindMapFile file;
  final String initialMarkdown;
  final MarkdownFileService markdownFiles;

  @override
  State<MarkdownEditorPage> createState() => _MarkdownEditorPageState();
}

class _MarkdownEditorPageState extends State<MarkdownEditorPage> {
  late final TextEditingController _controller;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMarkdown);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.displayName),
        actions: [
          TextButton(
            key: const Key('saveMarkdown'),
            onPressed: _busy ? null : _save,
            child: Text(l10n.saveMarkdown),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _controller,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: l10n.editMarkdownHint,
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final markdown = _controller.text;
    setState(() => _busy = true);
    try {
      await widget.markdownFiles.save(widget.file.location, markdown);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.markdownSaved)));
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to save Markdown',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.markdownSaveFailed)));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}
