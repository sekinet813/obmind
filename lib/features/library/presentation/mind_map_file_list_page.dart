import 'package:flutter/material.dart';
import 'package:obmind/app/widgets/paper_surface.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/features/library/application/mind_map_file_query.dart';
import 'package:obmind/features/library/application/mind_map_preview_layout.dart';
import 'package:obmind/features/library/application/mind_map_search_index.dart';
import 'package:obmind/features/library/domain/library_view_mode.dart';
import 'package:obmind/features/library/domain/library_view_mode_repository.dart';
import 'package:obmind/features/library/presentation/mind_map_preview_tile.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/features/mind_map/application/delete_mind_map.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/recent_mind_maps.dart';
import 'package:obmind/features/mind_map/application/rename_mind_map.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_page.dart';
import 'package:obmind/l10n/app_localizations.dart';

/// Shows Markdown files from a picked folder and opens one as a mind map.
class MindMapFileListPage extends StatefulWidget {
  const MindMapFileListPage({
    super.key,
    required this.files,
    required this.loadMindMap,
    required this.saveMindMap,
    this.renameMindMap,
    this.deleteMindMap,
    this.createMarkdownInFolder,
    this.vaultFolder,
    this.onOpenSettings,
    this.asHome = false,
    this.recordRecentMindMap,
    this.removeRecentMindMap,
    this.viewModeRepository,
  });

  final List<MindMapFile> files;
  final LoadMindMap loadMindMap;
  final SaveMindMap saveMindMap;
  final RenameMindMap? renameMindMap;
  final DeleteMindMap? deleteMindMap;
  final CreateMarkdownInFolder? createMarkdownInFolder;
  final MindMapLocation? vaultFolder;
  final VoidCallback? onOpenSettings;
  final bool asHome;
  final RecordRecentMindMap? recordRecentMindMap;
  final RemoveRecentMindMap? removeRecentMindMap;
  final LibraryViewModeRepository? viewModeRepository;

  @override
  State<MindMapFileListPage> createState() => _MindMapFileListPageState();
}

class _MindMapFileListPageState extends State<MindMapFileListPage> {
  late List<MindMapFile> _files;
  late final MindMapSearchIndex _searchIndex;
  var _query = '';
  var _viewMode = LibraryViewMode.list;
  Map<String, List<String>> _nodeTextsByToken = const {};
  Map<String, MindMapPreviewLayout?> _previewsByToken = const {};

  @override
  void initState() {
    super.initState();
    _files = List<MindMapFile>.from(widget.files);
    _searchIndex = MindMapSearchIndex(loadMindMap: widget.loadMindMap);
    _indexFiles();
    _loadViewMode();
  }

  @override
  void didUpdateWidget(covariant MindMapFileListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.files, oldWidget.files)) {
      _files = List<MindMapFile>.from(widget.files);
      _indexFiles();
    }
  }

  Future<void> _indexFiles() async {
    final indexed = await _searchIndex.ensureIndexed(_files);
    if (mounted) {
      setState(() {
        _nodeTextsByToken = indexed;
        _previewsByToken = _searchIndex.previewsByToken;
      });
    }
  }

  Future<void> _loadViewMode() async {
    final repository = widget.viewModeRepository;
    if (repository == null) {
      return;
    }
    final mode = await repository.load();
    if (mounted) {
      setState(() => _viewMode = mode);
    }
  }

  Future<void> _toggleViewMode() async {
    final next = _viewMode == LibraryViewMode.list
        ? LibraryViewMode.tiles
        : LibraryViewMode.list;
    setState(() => _viewMode = next);
    await widget.viewModeRepository?.save(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: widget.asHome
            ? Row(
                children: [
                  Image.asset(
                    'assets/brand/app_icon.png',
                    key: const Key('libraryAppIcon'),
                    width: 28,
                    height: 28,
                    filterQuality: FilterQuality.medium,
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: Text(l10n.appTitle)),
                ],
              )
            : Text(l10n.openMarkdown),
        actions: [
          if (_files.isNotEmpty)
            IconButton(
              key: const Key('toggleLibraryView'),
              tooltip: _viewMode == LibraryViewMode.list
                  ? l10n.libraryViewTiles
                  : l10n.libraryViewList,
              onPressed: _toggleViewMode,
              icon: Icon(
                _viewMode == LibraryViewMode.list
                    ? Icons.grid_view_outlined
                    : Icons.view_list_outlined,
              ),
            ),
          if (widget.onOpenSettings != null)
            IconButton(
              key: const Key('openSettings'),
              tooltip: l10n.settingsTitle,
              onPressed: widget.onOpenSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
        ],
      ),
      floatingActionButton: widget.createMarkdownInFolder == null
          ? null
          : FloatingActionButton(
              key: const Key('createMindMap'),
              tooltip: l10n.createInVault,
              onPressed: _createMindMap,
              child: const Icon(Icons.add),
            ),
      body: _files.isEmpty
          ? Center(
              child: PaperSurface(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.noMarkdownFiles,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    if (widget.createMarkdownInFolder != null) ...[
                      const SizedBox(height: 16),
                      FilledButton(
                        key: const Key('createMindMapEmpty'),
                        onPressed: _createMindMap,
                        child: Text(l10n.createInVault),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    key: const Key('searchMindMaps'),
                    decoration: InputDecoration(
                      hintText: l10n.searchMindMaps,
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final visible = queryMindMapFiles(
                        _files,
                        query: _query,
                        nodeTextsByToken: _nodeTextsByToken,
                      );
                      if (visible.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.noSearchResults,
                            style: theme.textTheme.bodyLarge,
                          ),
                        );
                      }
                      if (_viewMode == LibraryViewMode.tiles) {
                        return GridView.builder(
                          key: const Key('libraryTileGrid'),
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1.05,
                              ),
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            return _tileCard(context, visible[index], l10n);
                          },
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final file = visible[index];
                          return PaperSurface(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            onTap: () => _openMindMap(file),
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
                                _fileMenu(file, l10n, theme),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _tileCard(
    BuildContext context,
    MindMapFile file,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    return PaperSurface(
      onTap: () => _openMindMap(file),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: MindMapPreviewTile(
                  key: Key('mindMapPreview-${file.displayName}'),
                  layout: _previewsByToken[file.location.token],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 0, 8),
                  child: Text(
                    file.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              _fileMenu(file, l10n, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fileMenu(MindMapFile file, AppLocalizations l10n, ThemeData theme) {
    if (widget.renameMindMap == null && widget.deleteMindMap == null) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return PopupMenuButton<String>(
      key: Key('renameMenu-${file.displayName}'),
      onSelected: (value) {
        if (value == 'rename') {
          _renameMindMap(file);
        } else if (value == 'delete') {
          _deleteMindMap(file);
        }
      },
      itemBuilder: (context) => [
        if (widget.renameMindMap != null)
          PopupMenuItem(value: 'rename', child: Text(l10n.renameMindMap)),
        if (widget.deleteMindMap != null)
          PopupMenuItem(value: 'delete', child: Text(l10n.deleteMindMap)),
      ],
    );
  }

  Future<void> _createMindMap() async {
    final createMarkdownInFolder = widget.createMarkdownInFolder;
    if (createMarkdownInFolder == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    try {
      final file = await createMarkdownInFolder(folder: widget.vaultFolder);
      if (!mounted) {
        return;
      }
      if (file == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.folderPickCancelled)));
        return;
      }
      setState(() => _files = [..._files, file]);
      await _indexFiles();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.markdownCreated(file.displayName))),
      );
      await _openMindMap(file);
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to create Markdown in the vault folder',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.folderPickFailed)));
    }
  }

  Future<void> _renameMindMap(MindMapFile file) async {
    final renameMindMap = widget.renameMindMap;
    if (renameMindMap == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: file.displayName);
    final nextName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.renameMindMap),
          content: TextField(
            key: const Key('renameMindMapField'),
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: l10n.renameMindMapHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              key: const Key('confirmRenameMindMap'),
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(l10n.renameMindMap),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (nextName == null || !mounted) {
      return;
    }
    try {
      final renamed = await renameMindMap(file, nextName);
      if (!mounted) {
        return;
      }
      _searchIndex.invalidate(file.location);
      _searchIndex.invalidate(renamed.location);
      setState(() {
        _files = [
          for (final entry in _files)
            if (entry.location.token == file.location.token) renamed else entry,
        ];
      });
      await _indexFiles();
    } on MindMapStorageException catch (error, stackTrace) {
      appLogger.error(
        'Failed to rename mind map',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      final message = switch (error.message) {
        'invalid file name' => l10n.renameMindMapInvalidName,
        'name already exists' => l10n.renameMindMapDuplicateName,
        _ => l10n.renameMindMapFailed,
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _deleteMindMap(MindMapFile file) async {
    final deleteMindMap = widget.deleteMindMap;
    if (deleteMindMap == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteMindMap),
          content: Text(l10n.deleteMindMapConfirm(file.displayName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              key: const Key('confirmDeleteMindMap'),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deleteMindMap),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    try {
      await deleteMindMap(file);
      if (!mounted) {
        return;
      }
      _searchIndex.invalidate(file.location);
      setState(() {
        _files = [
          for (final entry in _files)
            if (entry.location.token != file.location.token) entry,
        ];
      });
    } on MindMapStorageException catch (error, stackTrace) {
      appLogger.error(
        'Failed to delete mind map',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.deleteMindMapFailed)));
    }
  }

  Future<void> _openMindMap(MindMapFile file) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final loaded = await widget.loadMindMap(file.location);
      await widget.recordRecentMindMap?.call(file);
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => MindMapPage(
            file: file,
            document: loaded.document,
            saveMindMap: widget.saveMindMap,
            renameMindMap: widget.renameMindMap,
            revision: loaded.revision,
            readOnly: loaded.hasUnsupportedContent,
          ),
        ),
      );
      _searchIndex.invalidate(file.location);
      if (mounted) {
        await _indexFiles();
      }
    } on LoadMindMapException catch (error, stackTrace) {
      appLogger.error(
        'Failed to load mind map',
        error: error,
        stackTrace: stackTrace,
      );
      await widget.removeRecentMindMap?.call(file.location);
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
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.recentMindMapUnavailable)));
    }
  }
}
