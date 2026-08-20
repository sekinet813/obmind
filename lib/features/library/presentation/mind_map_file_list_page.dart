import 'package:flutter/material.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
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
  });

  final List<MindMapFile> files;
  final LoadMindMap loadMindMap;
  final SaveMindMap saveMindMap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.openMarkdown)),
      body: files.isEmpty
          ? Center(child: Text(l10n.noMarkdownFiles))
          : ListView.separated(
              itemCount: files.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final file = files[index];
                return ListTile(
                  title: Text(file.displayName),
                  onTap: () => _openMindMap(context, file),
                );
              },
            ),
    );
  }

  Future<void> _openMindMap(BuildContext context, MindMapFile file) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final loaded = await loadMindMap(file.location);
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
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.mindMapLoadFailed)));
    }
  }
}
