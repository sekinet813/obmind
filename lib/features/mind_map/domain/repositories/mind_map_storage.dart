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

/// Opaque revision captured when Markdown was last read successfully.
final class MindMapRevision {
  const MindMapRevision(this.token);

  final String token;

  @override
  bool operator ==(Object other) {
    return other is MindMapRevision && other.token == token;
  }

  @override
  int get hashCode => token.hashCode;
}

/// Raised when a file changed externally since it was loaded.
final class MindMapStorageConflictException implements Exception {
  const MindMapStorageConflictException([
    this.message = 'file changed externally',
  ]);

  final String message;

  @override
  String toString() => 'MindMapStorageConflictException: $message';
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

  /// Changes the file display name. Markdown contents must stay unchanged.
  ///
  /// Rejects empty names, illegal characters, and collisions. Must not
  /// overwrite an existing file.
  Future<MindMapFile> rename(MindMapLocation location, String newDisplayName);

  /// Deletes the Markdown file at [location].
  ///
  /// Must not report success if the file still exists.
  Future<void> delete(MindMapLocation location);
}
