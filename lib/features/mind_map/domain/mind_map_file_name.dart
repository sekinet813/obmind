import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Display-name rules for Markdown mind map files.
abstract final class MindMapFileName {
  static final _invalidCharacters = RegExp(r'[\\/:*?"<>|\u0000]');

  /// Default display name for maps created in the app, without extension.
  static const defaultNewMapBase = '新規マインドマップ';

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

  /// Display title without `.md` / `.markdown`, preserving the original case.
  static String stem(String displayName) {
    return _stemFromNormalized(normalize(displayName));
  }

  /// Picks `[baseName].md`, then `(1)` `(2)` … using the first free number.
  ///
  /// [baseName] defaults to [defaultNewMapBase] (Japanese). Presentation
  /// passes a localized name; Domain stays free of Flutter l10n.
  static String nextNewMapName(
    Iterable<String> existingDisplayNames, {
    String baseName = defaultNewMapBase,
  }) {
    final taken = <String>{
      for (final name in existingDisplayNames) _comparableStem(normalize(name)),
    };
    final base = baseName.trim().isEmpty ? defaultNewMapBase : baseName.trim();
    if (!taken.contains(_comparableStem(base))) {
      return normalize(base);
    }
    for (var index = 1; index < 10000; index++) {
      final candidate = '$base ($index)';
      if (!taken.contains(_comparableStem(candidate))) {
        return normalize(candidate);
      }
    }
    throw const MindMapStorageException(
      'could not allocate a unique file name',
    );
  }

  static String _comparableStem(String normalizedOrRaw) {
    return _stemFromNormalized(normalize(normalizedOrRaw)).toLowerCase();
  }

  static String _stemFromNormalized(String normalized) {
    final lower = normalized.toLowerCase();
    if (lower.endsWith('.markdown')) {
      return normalized.substring(0, normalized.length - '.markdown'.length);
    }
    return normalized.substring(0, normalized.length - '.md'.length);
  }
}
