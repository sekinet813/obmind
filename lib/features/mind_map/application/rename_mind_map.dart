import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/recent_mind_maps.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/mind_map_file_name.dart';
import 'package:obmind/features/mind_map/domain/mind_map_tree.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Renames a mind map file and optionally updates Root text to match.
final class RenameMindMap {
  const RenameMindMap({
    required this.storage,
    this.loadMindMap,
    this.saveMindMap,
    this.listRecentMindMaps,
    this.recordRecentMindMap,
    this.removeRecentMindMap,
  });

  final MindMapStorage storage;
  final LoadMindMap? loadMindMap;
  final SaveMindMap? saveMindMap;
  final ListRecentMindMaps? listRecentMindMaps;
  final RecordRecentMindMap? recordRecentMindMap;
  final RemoveRecentMindMap? removeRecentMindMap;

  Future<MindMapFile> call(
    MindMapFile file,
    String newDisplayName, {
    bool updateRootText = true,
  }) async {
    final name = MindMapFileName.normalize(newDisplayName);
    if (name == file.displayName) {
      return file;
    }
    final recent = await listRecentMindMaps?.call() ?? const <MindMapFile>[];
    final wasRecent = recent.any(
      (entry) => entry.location.token == file.location.token,
    );
    final loaded = updateRootText ? await _loadForRootSync(file) : null;
    final renamed = await storage.rename(file.location, name);
    if (wasRecent) {
      await removeRecentMindMap?.call(file.location);
      await recordRecentMindMap?.call(renamed);
    }
    if (loaded != null) {
      await _syncRootText(renamed, loaded, MindMapFileName.stem(name));
    }
    return renamed;
  }

  Future<LoadMindMapResult?> _loadForRootSync(MindMapFile file) async {
    final loadMindMap = this.loadMindMap;
    if (loadMindMap == null || saveMindMap == null) {
      return null;
    }
    try {
      final loaded = await loadMindMap(file.location);
      if (loaded.hasUnsupportedContent) {
        return null;
      }
      return loaded;
    } on LoadMindMapException {
      return null;
    }
  }

  Future<void> _syncRootText(
    MindMapFile renamed,
    LoadMindMapResult loaded,
    String title,
  ) async {
    final saveMindMap = this.saveMindMap;
    if (saveMindMap == null || loaded.document.root.text == title) {
      return;
    }
    final updated = MindMapTree.updateText(
      loaded.document,
      loaded.document.root.id,
      title,
    );
    try {
      await saveMindMap(
        renamed.location,
        updated,
        ifUnchangedSince: loaded.revision,
      );
    } on MindMapStorageConflictException {
      // Keep the renamed file. Do not overwrite a changed document.
    }
  }
}
