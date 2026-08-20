import 'package:flutter/material.dart';
import 'package:obmind/app/widgets/paper_surface.dart';
import 'package:obmind/core/logging/app_logger.dart';
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
    this.recordRecentMindMap,
    this.removeRecentMindMap,
  });

  final List<MindMapFile> files;
  final LoadMindMap loadMindMap;
  final SaveMindMap saveMindMap;
  final RenameMindMap? renameMindMap;
  final DeleteMindMap? deleteMindMap;
  final RecordRecentMindMap? recordRecentMindMap;
  final RemoveRecentMindMap? removeRecentMindMap;

  @override
  State<MindMapFileListPage> createState() => _MindMapFileListPageState();
}

class _MindMapFileListPageState extends State<MindMapFileListPage> {
  late List<MindMapFile> _files;

  @override
  void initState() {
    super.initState();
    _files = List<MindMapFile>.from(widget.files);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.openMarkdown)),
      body: _files.isEmpty
          ? Center(
              child: PaperSurface(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.noMarkdownFiles,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _files.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final file = _files[index];
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
                      if (widget.renameMindMap != null ||
                          widget.deleteMindMap != null)
                        PopupMenuButton<String>(
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
                              PopupMenuItem(
                                value: 'rename',
                                child: Text(l10n.renameMindMap),
                              ),
                            if (widget.deleteMindMap != null)
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(l10n.deleteMindMap),
                              ),
                          ],
                        )
                      else
                        Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                );
              },
            ),
    );
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
      setState(() {
        _files = [
          for (final entry in _files)
            if (entry.location.token == file.location.token) renamed else entry,
        ];
      });
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
            revision: loaded.revision,
            readOnly: loaded.hasUnsupportedContent,
          ),
        ),
      );
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
