import 'package:obmind/features/mind_map/application/recent_mind_maps.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Deletes a mind map file and drops it from Recent when present.
final class DeleteMindMap {
  const DeleteMindMap({required this.storage, this.removeRecentMindMap});

  final MindMapStorage storage;
  final RemoveRecentMindMap? removeRecentMindMap;

  Future<void> call(MindMapFile file) async {
    await storage.delete(file.location);
    await removeRecentMindMap?.call(file.location);
  }
}
