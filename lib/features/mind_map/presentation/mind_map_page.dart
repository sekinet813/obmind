import 'package:flutter/material.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/core/utils/uuid_v4.dart';
import 'package:obmind/features/mind_map/application/autosave_mind_map.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/mind_map_tree.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_viewport.dart';
import 'package:obmind/l10n/app_localizations.dart';

/// Canvas editing shell. Tree changes go through [MindMapTree].
class MindMapPage extends StatefulWidget {
  const MindMapPage({
    super.key,
    required this.document,
    this.file,
    this.saveMindMap,
    this.revision,
    this.readOnly = false,
    this.generateId,
  });

  final MindMapDocument document;
  final MindMapFile? file;
  final SaveMindMap? saveMindMap;
  final MindMapRevision? revision;
  final bool readOnly;
  final NodeId Function()? generateId;

  @override
  State<MindMapPage> createState() => _MindMapPageState();
}

class _MindMapPageState extends State<MindMapPage> {
  late MindMapDocument _document;
  NodeId? _selectedId;
  var _saving = false;
  var _externallyModified = false;
  AutosaveMindMap? _autosave;
  MindMapRevision? _revision;

  @override
  void initState() {
    super.initState();
    _document = widget.document;
    _selectedId = _document.root.id;
    _revision = widget.revision;
    final saveMindMap = widget.saveMindMap;
    final revision = _revision;
    if (saveMindMap != null &&
        widget.file != null &&
        revision != null &&
        !widget.readOnly) {
      _autosave = AutosaveMindMap(
        saveMindMap: saveMindMap,
        initialRevision: revision,
        onConflict: () {
          if (mounted) {
            _handleSaveConflict();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _autosave?.dispose();
    super.dispose();
  }

  void _scheduleAutosave() {
    if (_externallyModified) {
      return;
    }
    final file = widget.file;
    final autosave = _autosave;
    if (file == null || autosave == null || widget.readOnly) {
      return;
    }
    autosave.schedule(file.location, _document);
  }

  void _handleSaveConflict() {
    _autosave?.dispose();
    _autosave = null;
    setState(() => _externallyModified = true);
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.mindMapExternalChangeBlocked)));
  }

  NodeId _newId() => widget.generateId?.call() ?? NodeId(generateUuidV4());

  void _addChild() {
    if (widget.readOnly || _externallyModified) {
      return;
    }
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
    _scheduleAutosave();
  }

  void _addSibling() {
    if (widget.readOnly || _externallyModified) {
      return;
    }
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
    _scheduleAutosave();
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
    if (widget.readOnly || _externallyModified) {
      return;
    }
    final id = _selectedId;
    if (id == null || id == _document.root.id) {
      return;
    }
    final parentId = _parentId(id);
    setState(() {
      _document = MindMapTree.delete(_document, id);
      _selectedId = parentId ?? _document.root.id;
    });
    _scheduleAutosave();
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
    if (widget.readOnly || _externallyModified) {
      return;
    }
    final id = _selectedId;
    final node = id == null ? null : _node(id);
    if (node == null || node.children.isEmpty) {
      return;
    }
    setState(() {
      _document = MindMapTree.setCollapsed(_document, id!, !node.collapsed);
    });
    _scheduleAutosave();
  }

  Future<void> _save() async {
    final file = widget.file;
    if (file == null || widget.readOnly || _externallyModified) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      final autosave = _autosave;
      if (autosave != null) {
        await autosave.flush();
        _revision = autosave.revision;
      } else {
        final saveMindMap = widget.saveMindMap;
        final revision = _revision;
        if (saveMindMap == null || revision == null) {
          return;
        }
        _revision = await saveMindMap(
          file.location,
          _document,
          ifUnchangedSince: revision,
        );
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.markdownSaved)));
    } on MindMapStorageConflictException {
      if (!mounted) {
        return;
      }
      _handleSaveConflict();
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to save mind map',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.markdownSaveFailed)));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canEdit = !widget.readOnly && !_externallyModified;
    final canAddSibling =
        canEdit && _selectedId != null && _selectedId != _document.root.id;
    final canDelete = canAddSibling;
    final selected = _selectedId == null ? null : _node(_selectedId!);
    final canToggleCollapsed = selected != null && selected.children.isNotEmpty;
    final canSave =
        canEdit && widget.saveMindMap != null && widget.file != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file?.displayName ?? _document.title),
        actions: [
          if (canSave)
            TextButton(
              key: const Key('saveMindMap'),
              onPressed: _saving ? null : _save,
              child: Text(l10n.saveMarkdown),
            ),
        ],
      ),
      body: Column(
        children: [
          if (widget.readOnly || _externallyModified)
            MaterialBanner(
              content: Text(
                _externallyModified
                    ? l10n.mindMapExternalChangeBlocked
                    : l10n.mindMapReadOnlyUnsupported,
              ),
              actions: const [SizedBox.shrink()],
            ),
          Expanded(
            child: MindMapViewport(
              document: _document,
              selectedId: _selectedId,
              onNodeSelected: (id) => setState(() => _selectedId = id),
            ),
          ),
        ],
      ),
      bottomNavigationBar: canEdit
          ? SafeArea(
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
            )
          : null,
    );
  }
}
