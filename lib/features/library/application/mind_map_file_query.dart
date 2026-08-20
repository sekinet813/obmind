import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Filters and sorts library files in memory. Does not write Markdown.
List<MindMapFile> queryMindMapFiles(
  List<MindMapFile> files, {
  String query = '',
  Map<String, Iterable<String>> nodeTextsByToken = const {},
}) {
  final needle = query.trim().toLowerCase();
  final filtered = needle.isEmpty
      ? List<MindMapFile>.from(files)
      : files.where((file) {
          if (file.displayName.toLowerCase().contains(needle)) {
            return true;
          }
          final texts = nodeTextsByToken[file.location.token];
          if (texts == null) {
            return false;
          }
          return texts.any((text) => text.toLowerCase().contains(needle));
        }).toList();
  filtered.sort((left, right) {
    return left.displayName.toLowerCase().compareTo(
      right.displayName.toLowerCase(),
    );
  });
  return filtered;
}
