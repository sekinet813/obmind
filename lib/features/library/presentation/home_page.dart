import 'package:flutter/material.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/features/mind_map/application/markdown_file_service.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/presentation/markdown_editor_page.dart';
import 'package:obmind/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.createMarkdownInFolder,
    this.folderPicker,
    this.markdownFiles,
  });

  final CreateMarkdownInFolder? createMarkdownInFolder;
  final MindMapFolderPicker? folderPicker;
  final MarkdownFileService? markdownFiles;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final createMarkdownInFolder = widget.createMarkdownInFolder;
    final canOpen = widget.folderPicker != null && widget.markdownFiles != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.appTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.homeMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (createMarkdownInFolder != null) ...[
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _createMarkdown(createMarkdownInFolder),
                  child: Text(l10n.pickFolderAndCreateMarkdown),
                ),
              ],
              if (canOpen) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _busy ? null : _openMarkdown,
                  child: Text(l10n.openMarkdown),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createMarkdown(CreateMarkdownInFolder useCase) async {
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final file = await useCase();
      if (!mounted) {
        return;
      }
      if (file == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.folderPickCancelled)));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.markdownCreated(file.displayName))),
      );
      await _openEditor(file);
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to create Markdown in the picked folder',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.folderPickFailed)));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _openMarkdown() async {
    final picker = widget.folderPicker;
    final files = widget.markdownFiles;
    if (picker == null || files == null) {
      return;
    }
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final folder = await picker.pickFolder();
      if (!mounted) {
        return;
      }
      if (folder == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.folderPickCancelled)));
        return;
      }
      final listed = await files.list(folder);
      if (!mounted) {
        return;
      }
      if (listed.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.noMarkdownFiles)));
        return;
      }
      final selected = listed.length == 1
          ? listed.first
          : await showDialog<MindMapFile>(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: Text(l10n.openMarkdown),
                  children: [
                    for (final file in listed)
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, file),
                        child: Text(file.displayName),
                      ),
                  ],
                );
              },
            );
      if (selected == null || !mounted) {
        return;
      }
      await _openEditor(selected);
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to open Markdown',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.folderPickFailed)));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _openEditor(MindMapFile file) async {
    final markdownFiles = widget.markdownFiles;
    if (markdownFiles == null) {
      return;
    }
    final markdown = await markdownFiles.load(file.location);
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => MarkdownEditorPage(
          file: file,
          initialMarkdown: markdown,
          markdownFiles: markdownFiles,
        ),
      ),
    );
  }
}
