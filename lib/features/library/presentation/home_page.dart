import 'package:flutter/material.dart';
import 'package:obmind/app/widgets/paper_surface.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/features/library/presentation/mind_map_file_list_page.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/features/mind_map/application/delete_mind_map.dart';
import 'package:obmind/features/mind_map/application/list_mind_map_files.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/recent_mind_maps.dart';
import 'package:obmind/features/mind_map/application/rename_mind_map.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_page.dart';
import 'package:obmind/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.createMarkdownInFolder,
    this.folderPicker,
    this.listMindMapFiles,
    this.loadMindMap,
    this.saveMindMap,
    this.listRecentMindMaps,
    this.recordRecentMindMap,
    this.removeRecentMindMap,
    this.renameMindMap,
    this.deleteMindMap,
  });

  final CreateMarkdownInFolder? createMarkdownInFolder;
  final MindMapFolderPicker? folderPicker;
  final ListMindMapFiles? listMindMapFiles;
  final LoadMindMap? loadMindMap;
  final SaveMindMap? saveMindMap;
  final ListRecentMindMaps? listRecentMindMaps;
  final RecordRecentMindMap? recordRecentMindMap;
  final RemoveRecentMindMap? removeRecentMindMap;
  final RenameMindMap? renameMindMap;
  final DeleteMindMap? deleteMindMap;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _busy = false;
  List<MindMapFile> _recentFiles = const [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final listRecent = widget.listRecentMindMaps;
    if (listRecent == null) {
      return;
    }
    try {
      final recent = await listRecent();
      if (mounted) {
        setState(() => _recentFiles = recent);
      }
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to load recent mind maps',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final createMarkdownInFolder = widget.createMarkdownInFolder;
    final canOpen =
        widget.folderPicker != null &&
        widget.listMindMapFiles != null &&
        widget.loadMindMap != null &&
        widget.saveMindMap != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          PaperSurface(
            padding: const EdgeInsets.all(20),
            child: Text(
              l10n.homeMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          if (_recentFiles.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(l10n.recentMindMaps, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final file in _recentFiles) ...[
              PaperSurface(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                onTap: _busy ? null : () => _openMindMap(file),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        file.displayName,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ],
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
              onPressed: _busy ? null : _openFileList,
              child: Text(l10n.openMarkdown),
            ),
          ],
        ],
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
      await _openMindMap(file);
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

  Future<void> _openFileList() async {
    final picker = widget.folderPicker;
    final listMindMapFiles = widget.listMindMapFiles;
    final loadMindMap = widget.loadMindMap;
    final saveMindMap = widget.saveMindMap;
    if (picker == null ||
        listMindMapFiles == null ||
        loadMindMap == null ||
        saveMindMap == null) {
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
      final listed = await listMindMapFiles(folder);
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => MindMapFileListPage(
            files: listed,
            loadMindMap: loadMindMap,
            saveMindMap: saveMindMap,
            recordRecentMindMap: widget.recordRecentMindMap,
            removeRecentMindMap: widget.removeRecentMindMap,
            renameMindMap: widget.renameMindMap,
            deleteMindMap: widget.deleteMindMap,
          ),
        ),
      );
      await _loadRecent();
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to list Markdown files',
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

  Future<void> _openMindMap(MindMapFile file) async {
    final loadMindMap = widget.loadMindMap;
    final saveMindMap = widget.saveMindMap;
    if (loadMindMap == null || saveMindMap == null) {
      return;
    }
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final loaded = await loadMindMap(file.location);
      await widget.recordRecentMindMap?.call(file);
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => MindMapPage(
            file: file,
            document: loaded.document,
            saveMindMap: saveMindMap,
            revision: loaded.revision,
            readOnly: loaded.hasUnsupportedContent,
          ),
        ),
      );
      await _loadRecent();
    } on LoadMindMapException catch (error, stackTrace) {
      appLogger.error(
        'Failed to load mind map',
        error: error,
        stackTrace: stackTrace,
      );
      await widget.removeRecentMindMap?.call(file.location);
      await _loadRecent();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.mindMapLoadFailed)));
    } on MindMapStorageException catch (error, stackTrace) {
      appLogger.error(
        'Failed to read mind map file',
        error: error,
        stackTrace: stackTrace,
      );
      await widget.removeRecentMindMap?.call(file.location);
      await _loadRecent();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.recentMindMapUnavailable)));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}
