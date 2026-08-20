import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Cached node texts used by Library search. Does not write Markdown.
final class MindMapSearchIndex {
  MindMapSearchIndex({required this.loadMindMap});

  final LoadMindMap loadMindMap;
  final Map<String, List<String>> _nodeTextsByToken = {};

  Map<String, List<String>> get nodeTextsByToken =>
      Map<String, List<String>>.unmodifiable(_nodeTextsByToken);

  void invalidate(MindMapLocation location) {
    _nodeTextsByToken.remove(location.token);
  }

  /// Reads each file through [LoadMindMap] and caches node texts.
  ///
  /// Parse or read failures are stored as empty texts so filename search
  /// still works and the rest of the index can continue.
  Future<Map<String, List<String>>> ensureIndexed(
    List<MindMapFile> files,
  ) async {
    for (final file in files) {
      final token = file.location.token;
      if (_nodeTextsByToken.containsKey(token)) {
        continue;
      }
      try {
        final loaded = await loadMindMap(file.location);
        _nodeTextsByToken[token] = [
          for (final node in loaded.document.root.depthFirst) node.text,
        ];
      } catch (_) {
        _nodeTextsByToken[token] = const [];
      }
    }
    return nodeTextsByToken;
  }
}
