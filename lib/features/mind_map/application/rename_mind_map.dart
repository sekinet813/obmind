import 'package:obmind/features/mind_map/application/recent_mind_maps.dart';
import 'package:obmind/features/mind_map/domain/mind_map_file_name.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Renames a mind map file without rewriting Markdown contents.
final class RenameMindMap {
  const RenameMindMap({
    required this.storage,
    this.listRecentMindMaps,
    this.recordRecentMindMap,
    this.removeRecentMindMap,
  });

  final MindMapStorage storage;
  final ListRecentMindMaps? listRecentMindMaps;
  final RecordRecentMindMap? recordRecentMindMap;
  final RemoveRecentMindMap? removeRecentMindMap;

  Future<MindMapFile> call(MindMapFile file, String newDisplayName) async {
    final name = MindMapFileName.normalize(newDisplayName);
    if (name == file.displayName) {
      return file;
    }
    final recent = await listRecentMindMaps?.call() ?? const <MindMapFile>[];
    final wasRecent = recent.any(
      (entry) => entry.location.token == file.location.token,
    );
    final renamed = await storage.rename(file.location, name);
    if (wasRecent) {
      await removeRecentMindMap?.call(file.location);
      await recordRecentMindMap?.call(renamed);
    }
    return renamed;
  }
}
