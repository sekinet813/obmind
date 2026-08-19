import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Load and save Markdown through [MindMapStorage] without OS types.
final class MarkdownFileService {
  const MarkdownFileService(this.storage);

  final MindMapStorage storage;

  Future<String> load(MindMapLocation location) => storage.read(location);

  Future<void> save(MindMapLocation location, String markdown) {
    return storage.write(location, markdown);
  }

  Future<List<MindMapFile>> list(MindMapLocation folder) =>
      storage.list(folder);
}
