import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_serializer.dart';

/// Serializes a [MindMapDocument] and writes it through [MindMapStorage].
final class SaveMindMap {
  const SaveMindMap({required this.storage, required this.serializer});

  final MindMapStorage storage;
  final MarkdownSerializer serializer;

  Future<void> call(MindMapLocation location, MindMapDocument document) {
    final markdown = serializer.serialize(document);
    return storage.write(location, markdown);
  }
}
