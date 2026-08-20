import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Persists recently opened mind map files outside Markdown.
abstract interface class RecentMindMapsRepository {
  Future<List<MindMapFile>> list();

  Future<void> record(MindMapFile file);

  Future<void> remove(MindMapLocation location);
}
