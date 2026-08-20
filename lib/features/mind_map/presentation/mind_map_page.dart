import 'package:flutter/material.dart';
import 'package:obmind/core/utils/uuid_v4.dart';
import 'package:obmind/features/mind_map/domain/mind_map_tree.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_viewport.dart';
import 'package:obmind/l10n/app_localizations.dart';

/// Canvas editing shell. Tree changes go through [MindMapTree].
class MindMapPage extends StatefulWidget {
  const MindMapPage({super.key, required this.document, this.generateId});

  final MindMapDocument document;
  final NodeId Function()? generateId;

  @override
  State<MindMapPage> createState() => _MindMapPageState();
}

class _MindMapPageState extends State<MindMapPage> {
  late MindMapDocument _document;
  NodeId? _selectedId;

  @override
  void initState() {
    super.initState();
    _document = widget.document;
    _selectedId = _document.root.id;
  }

  NodeId _newId() => widget.generateId?.call() ?? NodeId(generateUuidV4());

  void _addChild() {
    final parentId = _selectedId;
    if (parentId == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final child = MindNode(id: _newId(), text: l10n.newNodeText);
    setState(() {
      _document = MindMapTree.addChild(_document, parentId, child);
      _selectedId = child.id;
    });
  }

  void _addSibling() {
    final siblingId = _selectedId;
    if (siblingId == null || siblingId == _document.root.id) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final sibling = MindNode(id: _newId(), text: l10n.newNodeText);
    setState(() {
      _document = MindMapTree.addSibling(_document, siblingId, sibling);
      _selectedId = sibling.id;
    });
  }

  NodeId? _parentId(NodeId id) {
    for (final node in _document.root.depthFirst) {
      for (final child in node.children) {
        if (child.id == id) {
          return node.id;
        }
      }
    }
    return null;
  }

  void _deleteSelected() {
    final id = _selectedId;
    if (id == null || id == _document.root.id) {
      return;
    }
    final parentId = _parentId(id);
    setState(() {
      _document = MindMapTree.delete(_document, id);
      _selectedId = parentId ?? _document.root.id;
    });
  }

  MindNode? _node(NodeId id) {
    for (final node in _document.root.depthFirst) {
      if (node.id == id) {
        return node;
      }
    }
    return null;
  }

  void _toggleCollapsed() {
    final id = _selectedId;
    final node = id == null ? null : _node(id);
    if (node == null || node.children.isEmpty) {
      return;
    }
    setState(() {
      _document = MindMapTree.setCollapsed(_document, id!, !node.collapsed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canAddSibling =
        _selectedId != null && _selectedId != _document.root.id;
    final canDelete = canAddSibling;
    final selected = _selectedId == null ? null : _node(_selectedId!);
    final canToggleCollapsed = selected != null && selected.children.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(_document.title)),
      body: MindMapViewport(
        document: _document,
        selectedId: _selectedId,
        onNodeSelected: (id) => setState(() => _selectedId = id),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Wrap(
            spacing: 4,
            children: [
              TextButton.icon(
                onPressed: _selectedId == null ? null : _addChild,
                icon: const Icon(Icons.subdirectory_arrow_right),
                label: Text(l10n.addChildNode),
              ),
              TextButton.icon(
                onPressed: canAddSibling ? _addSibling : null,
                icon: const Icon(Icons.arrow_downward),
                label: Text(l10n.addSiblingNode),
              ),
              TextButton.icon(
                onPressed: canDelete ? _deleteSelected : null,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.deleteNode),
              ),
              TextButton.icon(
                onPressed: canToggleCollapsed ? _toggleCollapsed : null,
                icon: Icon(
                  selected?.collapsed == true
                      ? Icons.unfold_more
                      : Icons.unfold_less,
                ),
                label: Text(
                  selected?.collapsed == true
                      ? l10n.expandNode
                      : l10n.collapseNode,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
