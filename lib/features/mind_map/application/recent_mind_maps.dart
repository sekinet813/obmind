import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/domain/repositories/recent_mind_maps_repository.dart';

/// Returns recently opened mind map files.
final class ListRecentMindMaps {
  const ListRecentMindMaps(this.repository);

  final RecentMindMapsRepository repository;

  Future<List<MindMapFile>> call() => repository.list();
}

/// Records a mind map file as recently opened.
final class RecordRecentMindMap {
  const RecordRecentMindMap(this.repository);

  final RecentMindMapsRepository repository;

  Future<void> call(MindMapFile file) => repository.record(file);
}

/// Removes a stale recent entry after permission loss or missing files.
final class RemoveRecentMindMap {
  const RemoveRecentMindMap(this.repository);

  final RecentMindMapsRepository repository;

  Future<void> call(MindMapLocation location) => repository.remove(location);
}
