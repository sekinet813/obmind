/// Persistent identifier for a mind map node.
///
/// Generated as a UUID string. Humans are not expected to edit this value.
final class NodeId {
  const NodeId(this.value);

  final String value;

  @override
  bool operator ==(Object other) {
    return other is NodeId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
