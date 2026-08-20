import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Lists Markdown files in a folder through [MindMapStorage].
final class ListMindMapFiles {
  const ListMindMapFiles(this.storage);

  final MindMapStorage storage;

  Future<List<MindMapFile>> call(MindMapLocation folder) =>
      storage.list(folder);
}
