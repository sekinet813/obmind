import 'dart:math' as math;

import 'package:obmind/features/library/application/mind_map_preview_layout.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engines.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Cached node texts and preview layouts for Library. Does not write Markdown.
final class MindMapSearchIndex {
  MindMapSearchIndex({required this.loadMindMap});

  final LoadMindMap loadMindMap;
  final Map<String, List<String>> _nodeTextsByToken = {};
  final Map<String, MindMapPreviewLayout?> _previewsByToken = {};

  Map<String, List<String>> get nodeTextsByToken =>
      Map<String, List<String>>.unmodifiable(_nodeTextsByToken);

  Map<String, MindMapPreviewLayout?> get previewsByToken =>
      Map<String, MindMapPreviewLayout?>.unmodifiable(_previewsByToken);

  void invalidate(MindMapLocation location) {
    _nodeTextsByToken.remove(location.token);
    _previewsByToken.remove(location.token);
  }

  /// Reads each file through [LoadMindMap] and caches node texts and layouts.
  ///
  /// Parse or read failures are stored as empty texts and a null preview so
  /// filename search still works and the rest of the index can continue.
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
        _previewsByToken[token] = previewLayoutOf(
          layoutEngineFor(
            loaded.document.layout,
          ).layout(loaded.document, nodeSizes: const {}),
        );
      } catch (_) {
        _nodeTextsByToken[token] = const [];
        _previewsByToken[token] = null;
      }
    }
    return nodeTextsByToken;
  }
}

MindMapPreviewLayout previewLayoutOf(MindMapLayout layout) {
  if (layout.nodes.isEmpty) {
    return const MindMapPreviewLayout(boxes: [], width: 1, height: 1);
  }
  var minX = double.infinity;
  var minY = double.infinity;
  for (final node in layout.nodes.values) {
    minX = math.min(minX, node.x);
    minY = math.min(minY, node.y);
  }
  return MindMapPreviewLayout(
    boxes: [
      for (final node in layout.nodes.values)
        MindMapPreviewBox(
          x: node.x - minX,
          y: node.y - minY,
          width: node.width,
          height: node.height,
        ),
    ],
    width: math.max(layout.width, 1),
    height: math.max(layout.height, 1),
  );
}
