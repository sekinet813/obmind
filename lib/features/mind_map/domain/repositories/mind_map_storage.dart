/// Opaque handle for a file or folder.
///
/// Path strings, content URIs, and security-scoped bookmarks stay in
/// Infrastructure. Domain only passes this token through [MindMapStorage].
final class MindMapLocation {
  const MindMapLocation(this.token);

  final String token;

  @override
  bool operator ==(Object other) {
    return other is MindMapLocation && other.token == token;
  }

  @override
  int get hashCode => token.hashCode;
}

/// A Markdown file discovered under a folder [MindMapLocation].
final class MindMapFile {
  const MindMapFile({required this.location, required this.displayName});

  final MindMapLocation location;
  final String displayName;
}

/// Failure from a storage operation. Does not carry OS types.
final class MindMapStorageException implements Exception {
  const MindMapStorageException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'MindMapStorageException: $message';
}

/// Read and write Markdown without exposing OS file APIs to Domain.
abstract interface class MindMapStorage {
  Future<String> read(MindMapLocation location);

  Future<void> write(MindMapLocation location, String markdown);

  Future<List<MindMapFile>> list(MindMapLocation folder);

  /// Creates a Markdown file in [folder] and writes [markdown].
  Future<MindMapFile> create(
    MindMapLocation folder,
    String displayName, {
    String markdown = '',
  });
}
