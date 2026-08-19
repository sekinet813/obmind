import 'package:obmind/features/mind_map/domain/mind_map_tree_exception.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';

/// Immutable Add / Delete / Move / Reorder operations on a mind map tree.
final class MindMapTree {
  const MindMapTree._();

  static MindMapDocument addChild(
    MindMapDocument document,
    NodeId parentId,
    MindNode child, {
    int? index,
  }) {
    _ensureNewIds(document, child);
    final parent = _find(document.root, parentId);
    if (parent == null) {
      throw MindMapTreeException(MindMapTreeError.nodeNotFound, parentId.value);
    }
    return document.copyWith(
      root: _update(document.root, parentId, (node) {
        final children = [...node.children];
        final at = (index ?? children.length).clamp(0, children.length);
        children.insert(at, child);
        return node.copyWith(children: children);
      }),
    );
  }

  static MindMapDocument addSibling(
    MindMapDocument document,
    NodeId siblingId,
    MindNode newNode,
  ) {
    if (document.root.id == siblingId) {
      throw const MindMapTreeException(MindMapTreeError.cannotAddSiblingOfRoot);
    }
    final location = _locate(document.root, siblingId);
    if (location == null || location.parent == null) {
      throw MindMapTreeException(
        MindMapTreeError.nodeNotFound,
        siblingId.value,
      );
    }
    return addChild(
      document,
      location.parent!.id,
      newNode,
      index: location.index + 1,
    );
  }

  static MindMapDocument delete(MindMapDocument document, NodeId id) {
    if (document.root.id == id) {
      throw const MindMapTreeException(MindMapTreeError.cannotDeleteRoot);
    }
    if (_find(document.root, id) == null) {
      throw MindMapTreeException(MindMapTreeError.nodeNotFound, id.value);
    }
    return document.copyWith(root: _remove(document.root, id));
  }

  static MindMapDocument move(
    MindMapDocument document,
    NodeId id,
    NodeId newParentId, {
    int? index,
  }) {
    if (document.root.id == id) {
      throw const MindMapTreeException(MindMapTreeError.cannotMoveRoot);
    }
    final moving = _find(document.root, id);
    final newParent = _find(document.root, newParentId);
    if (moving == null) {
      throw MindMapTreeException(MindMapTreeError.nodeNotFound, id.value);
    }
    if (newParent == null) {
      throw MindMapTreeException(
        MindMapTreeError.nodeNotFound,
        newParentId.value,
      );
    }
    if (wouldCreateCycle(document, id, newParentId)) {
      throw const MindMapTreeException(MindMapTreeError.cycle);
    }

    final without = _remove(document.root, id);
    return document.copyWith(
      root: _update(without, newParentId, (node) {
        final children = [...node.children];
        final at = (index ?? children.length).clamp(0, children.length);
        children.insert(at, moving);
        return node.copyWith(children: children);
      }),
    );
  }

  /// True when [id] would become an ancestor of itself under [newParentId].
  static bool wouldCreateCycle(
    MindMapDocument document,
    NodeId id,
    NodeId newParentId,
  ) {
    if (id == newParentId) {
      return true;
    }
    final moving = _find(document.root, id);
    if (moving == null) {
      return false;
    }
    return _find(moving, newParentId) != null;
  }

  static MindMapDocument reorder(
    MindMapDocument document,
    NodeId id,
    int newIndex,
  ) {
    if (document.root.id == id) {
      throw const MindMapTreeException(MindMapTreeError.cannotMoveRoot);
    }
    final location = _locate(document.root, id);
    if (location == null || location.parent == null) {
      throw MindMapTreeException(MindMapTreeError.nodeNotFound, id.value);
    }
    final siblings = [...location.parent!.children];
    final clamped = newIndex.clamp(0, siblings.length - 1);
    siblings.removeAt(location.index);
    siblings.insert(clamped, location.node);
    return document.copyWith(
      root: _update(
        document.root,
        location.parent!.id,
        (node) => node.copyWith(children: siblings),
      ),
    );
  }

  static void _ensureNewIds(MindMapDocument document, MindNode incoming) {
    final existing = document.nodeIds.map((id) => id.value).toSet();
    for (final node in incoming.depthFirst) {
      if (!existing.add(node.id.value)) {
        throw MindMapTreeException(
          MindMapTreeError.duplicateNodeId,
          node.id.value,
        );
      }
    }
  }

  static MindNode? _find(MindNode root, NodeId id) {
    for (final node in root.depthFirst) {
      if (node.id == id) {
        return node;
      }
    }
    return null;
  }

  static _NodeLocation? _locate(MindNode root, NodeId id) {
    if (root.id == id) {
      return _NodeLocation(node: root);
    }
    for (var i = 0; i < root.children.length; i++) {
      final child = root.children[i];
      if (child.id == id) {
        return _NodeLocation(node: child, parent: root, index: i);
      }
      final nested = _locate(child, id);
      if (nested != null) {
        return nested;
      }
    }
    return null;
  }

  static MindNode _update(
    MindNode node,
    NodeId id,
    MindNode Function(MindNode current) replace,
  ) {
    if (node.id == id) {
      return replace(node);
    }
    return node.copyWith(
      children: [
        for (final child in node.children) _update(child, id, replace),
      ],
    );
  }

  static MindNode _remove(MindNode node, NodeId id) {
    return node.copyWith(
      children: [
        for (final child in node.children)
          if (child.id != id) _remove(child, id),
      ],
    );
  }
}

final class _NodeLocation {
  const _NodeLocation({required this.node, this.parent, this.index = -1});

  final MindNode node;
  final MindNode? parent;
  final int index;
}
