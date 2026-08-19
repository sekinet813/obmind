/// Why a tree operation was rejected.
enum MindMapTreeError {
  nodeNotFound,
  cannotDeleteRoot,
  cannotMoveRoot,
  cannotAddSiblingOfRoot,
  duplicateNodeId,
  cycle,
}

/// Failure from Add / Delete / Move / Reorder.
final class MindMapTreeException implements Exception {
  const MindMapTreeException(this.error, [this.message]);

  final MindMapTreeError error;
  final String? message;

  @override
  String toString() {
    final detail = message == null ? '' : ': $message';
    return 'MindMapTreeException.${error.name}$detail';
  }
}
