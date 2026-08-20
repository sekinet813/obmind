import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Display-name rules for Markdown mind map files.
abstract final class MindMapFileName {
  static final _invalidCharacters = RegExp(r'[\\/:*?"<>|\u0000]');

  /// Trims, appends `.md` when missing, and rejects empty or illegal names.
  static String normalize(String raw) {
    var name = raw.trim();
    if (name.isEmpty) {
      throw const MindMapStorageException('invalid file name');
    }
    final lower = name.toLowerCase();
    if (!lower.endsWith('.md') && !lower.endsWith('.markdown')) {
      name = '$name.md';
    }
    if (name == '.md' ||
        name == '.markdown' ||
        _invalidCharacters.hasMatch(name)) {
      throw const MindMapStorageException('invalid file name');
    }
    return name;
  }
}
