import 'package:flutter/material.dart';
import 'package:obmind/app/widgets/paper_surface.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/recent_mind_maps.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_page.dart';
import 'package:obmind/l10n/app_localizations.dart';

/// Shows Markdown files from a picked folder and opens one as a mind map.
class MindMapFileListPage extends StatelessWidget {
  const MindMapFileListPage({
    super.key,
    required this.files,
    required this.loadMindMap,
    required this.saveMindMap,
    this.recordRecentMindMap,
    this.removeRecentMindMap,
  });

  final List<MindMapFile> files;
  final LoadMindMap loadMindMap;
  final SaveMindMap saveMindMap;
  final RecordRecentMindMap? recordRecentMindMap;
  final RemoveRecentMindMap? removeRecentMindMap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.openMarkdown)),
      body: files.isEmpty
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
              itemCount: files.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final file = files[index];
                return PaperSurface(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  onTap: () => _openMindMap(context, file),
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
                );
              },
            ),
    );
  }

  Future<void> _openMindMap(BuildContext context, MindMapFile file) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final loaded = await loadMindMap(file.location);
      await recordRecentMindMap?.call(file);
      if (!context.mounted) {
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
    } on LoadMindMapException catch (error, stackTrace) {
      appLogger.error(
        'Failed to load mind map',
        error: error,
        stackTrace: stackTrace,
      );
      await removeRecentMindMap?.call(file.location);
      if (!context.mounted) {
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
      await removeRecentMindMap?.call(file.location);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.recentMindMapUnavailable)));
    }
  }
}
