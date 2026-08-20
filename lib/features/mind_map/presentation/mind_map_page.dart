import 'package:flutter/material.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/core/utils/uuid_v4.dart';
import 'package:obmind/features/mind_map/application/autosave_mind_map.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/application/mind_map_edit_history.dart';
import 'package:obmind/features/mind_map/application/node_drag_resolver.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/mind_map_tree.dart';
import 'package:obmind/features/mind_map/domain/mind_map_tree_exception.dart';
import 'package:obmind/features/mind_map/domain/models/layout_type.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/models/mind_node.dart';
import 'package:obmind/features/mind_map/domain/models/node_id.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_context_actions.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_viewport.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_zoom_controls.dart';
import 'package:obmind/features/mind_map/presentation/theme/mind_map_canvas_theme.dart';
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
    this.initialSelectedId,
  });

  final MindMapDocument document;
  final MindMapFile? file;
  final SaveMindMap? saveMindMap;
  final MindMapRevision? revision;
  final bool readOnly;
  final NodeId Function()? generateId;
  final NodeId? initialSelectedId;

  @override
  State<MindMapPage> createState() => _MindMapPageState();
}

class _MindMapPageState extends State<MindMapPage> {
  final _viewportKey = GlobalKey<MindMapViewportState>();
  final _editController = TextEditingController();
  final _editFocusNode = FocusNode();

  late MindMapDocument _document;
  late MindMapEditHistory _history;
  NodeId? _selectedId;
  NodeId? _editingId;
  NodeId? _draggingId;
  NodeId? _dropTargetId;
  var _saving = false;
  var _externallyModified = false;
  AutosaveMindMap? _autosave;
  MindMapRevision? _revision;

  @override
  void initState() {
    super.initState();
    _document = widget.document;
    _history = MindMapEditHistory(_document);
    _selectedId = widget.initialSelectedId ?? _document.root.id;
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
    _editController.dispose();
    _editFocusNode.dispose();
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

  void _mutateDocument(MindMapDocument next, {NodeId? selectedId}) {
    setState(() {
      _history.push(next);
      _document = _history.present;
      if (selectedId != null) {
        _selectedId = selectedId;
      }
    });
    _scheduleAutosave();
  }

  void _undo() {
    if (widget.readOnly || _externallyModified) {
      return;
    }
    final restored = _history.undo();
    if (restored == null) {
      return;
    }
    setState(() {
      _document = restored;
      _selectedId = _node(_selectedId ?? restored.root.id) == null
          ? restored.root.id
          : _selectedId;
      _editingId = null;
    });
    _scheduleAutosave();
  }

  void _redo() {
    if (widget.readOnly || _externallyModified) {
      return;
    }
    final restored = _history.redo();
    if (restored == null) {
      return;
    }
    setState(() {
      _document = restored;
      _selectedId = _node(_selectedId ?? restored.root.id) == null
          ? restored.root.id
          : _selectedId;
      _editingId = null;
    });
    _scheduleAutosave();
  }

  void _applyDragResolution(NodeDragResolution resolution, NodeId draggedId) {
    try {
      final MindMapDocument next;
      switch (resolution) {
        case ReorderNodeDrag(:final newIndex):
          next = MindMapTree.reorder(_document, draggedId, newIndex);
        case ReparentNodeDrag(:final newParentId, :final index):
          next = MindMapTree.move(
            _document,
            draggedId,
            newParentId,
            index: index,
          );
      }
      _mutateDocument(next, selectedId: draggedId);
    } on MindMapTreeException {
      // Cycle or invalid move is ignored.
    }
  }

  void _onNodeDragStart(NodeId id) {
    if (widget.readOnly || _externallyModified || _editingId != null) {
      return;
    }
    setState(() {
      _selectedId = id;
      _draggingId = id;
      _dropTargetId = null;
    });
  }

  void _onNodeDragUpdate(Offset globalPosition) {
    final draggingId = _draggingId;
    if (draggingId == null) {
      return;
    }
    final layoutPoint =
        _viewportKey.currentState?.globalToLayout(globalPosition) ??
        Offset.zero;
    final layout = _viewportKey.currentState?.currentLayout;
    if (layout == null) {
      return;
    }
    final resolution = resolveNodeDrag(
      document: _document,
      layout: layout,
      draggedId: draggingId,
      layoutPoint: layoutPoint,
    );
    final dropTarget = switch (resolution) {
      ReparentNodeDrag(:final newParentId) => newParentId,
      ReorderNodeDrag() => _hitNodeAt(layout, layoutPoint, draggingId),
      null => null,
    };
    if (_dropTargetId != dropTarget) {
      setState(() => _dropTargetId = dropTarget);
    }
  }

  NodeId? _hitNodeAt(MindMapLayout layout, Offset point, NodeId exclude) {
    NodeId? best;
    var bestArea = double.infinity;
    for (final entry in layout.nodes.entries) {
      if (entry.key == exclude) {
        continue;
      }
      final nodeLayout = entry.value;
      final rect = Rect.fromLTWH(
        nodeLayout.x,
        nodeLayout.y,
        nodeLayout.width,
        nodeLayout.height,
      );
      if (!rect.contains(point)) {
        continue;
      }
      final area = rect.width * rect.height;
      if (area <= bestArea) {
        best = entry.key;
        bestArea = area;
      }
    }
    return best;
  }

  void _onNodeDragEnd(Offset globalPosition) {
    final draggingId = _draggingId;
    if (draggingId == null) {
      return;
    }
    final layoutPoint =
        _viewportKey.currentState?.globalToLayout(globalPosition) ??
        Offset.zero;
    final layout = _viewportKey.currentState?.currentLayout;
    if (layout != null) {
      final resolution = resolveNodeDrag(
        document: _document,
        layout: layout,
        draggedId: draggingId,
        layoutPoint: layoutPoint,
      );
      if (resolution != null) {
        _applyDragResolution(resolution, draggingId);
      }
    }
    setState(() {
      _draggingId = null;
      _dropTargetId = null;
    });
  }

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
    _mutateDocument(
      MindMapTree.addChild(_document, parentId, child),
      selectedId: child.id,
    );
    _ensureAddedNodeVisible(child.id);
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
    _mutateDocument(
      MindMapTree.addSibling(_document, siblingId, sibling),
      selectedId: sibling.id,
    );
    _ensureAddedNodeVisible(sibling.id);
  }

  void _ensureAddedNodeVisible(NodeId id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final renderBox =
          _viewportKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) {
        return;
      }
      _viewportKey.currentState?.ensureNodeVisible(id, renderBox.size);
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
    if (widget.readOnly || _externallyModified) {
      return;
    }
    final id = _selectedId;
    if (id == null || id == _document.root.id) {
      return;
    }
    final parentId = _parentId(id);
    _mutateDocument(
      MindMapTree.delete(_document, id),
      selectedId: parentId ?? _document.root.id,
    );
  }

  MindNode? _node(NodeId id) {
    for (final node in _document.root.depthFirst) {
      if (node.id == id) {
        return node;
      }
    }
    return null;
  }

  void _toggleCollapsed([NodeId? id]) {
    if (widget.readOnly || _externallyModified) {
      return;
    }
    final targetId = id ?? _selectedId;
    final node = targetId == null ? null : _node(targetId);
    if (node == null || node.children.isEmpty) {
      return;
    }
    _mutateDocument(
      MindMapTree.setCollapsed(_document, targetId!, !node.collapsed),
      selectedId: targetId,
    );
  }

  void _startEditing(NodeId id) {
    if (widget.readOnly || _externallyModified) {
      return;
    }
    final node = _node(id);
    if (node == null) {
      return;
    }
    setState(() {
      _selectedId = id;
      _editingId = id;
      _editController.text = node.text;
    });
    _editFocusNode.requestFocus();
  }

  void _commitEditing() {
    final id = _editingId;
    if (id == null) {
      return;
    }
    final text = _editController.text.trim();
    final node = _node(id);
    if (node != null && text.isNotEmpty && text != node.text) {
      _mutateDocument(MindMapTree.updateText(_document, id, text));
      setState(() => _editingId = null);
    } else {
      setState(() => _editingId = null);
    }
    _editFocusNode.unfocus();
  }

  void _setLayout(LayoutType layout) {
    if (widget.readOnly || _externallyModified || _document.layout == layout) {
      return;
    }
    final extra = Map<String, String>.of(_document.extraObmindFields)
      ..remove('layout');
    _mutateDocument(
      _document.copyWith(layout: layout, extraObmindFields: extra),
    );
  }

  void _fitToScreen() {
    final renderBox =
        _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return;
    }
    _viewportKey.currentState?.fitToScreen(renderBox.size);
  }

  void _zoomIn() => _viewportKey.currentState?.zoomIn();

  void _zoomOut() => _viewportKey.currentState?.zoomOut();

  void _centerOnRoot() {
    final renderBox =
        _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return;
    }
    _viewportKey.currentState?.centerOnRoot(renderBox.size);
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
    final canvasTheme = mindMapCanvasThemeFor(
      _document.theme,
      Theme.of(context).colorScheme,
    );
    final showContextActions =
        canEdit && _selectedId != null && _draggingId == null;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.file?.displayName ?? _document.title,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.file != null && !_externallyModified)
              Text(
                _saving ? l10n.savingInProgress : l10n.autosaveEnabled,
                style: Theme.of(context).textTheme.labelSmall,
              ),
          ],
        ),
        actions: [
          if (canEdit) ...[
            IconButton(
              tooltip: l10n.undoEdit,
              onPressed: _history.canUndo ? _undo : null,
              icon: const Icon(Icons.undo),
            ),
            IconButton(
              tooltip: l10n.redoEdit,
              onPressed: _history.canRedo ? _redo : null,
              icon: const Icon(Icons.redo),
            ),
          ],
          IconButton(
            tooltip: l10n.fitToScreen,
            onPressed: _fitToScreen,
            icon: const Icon(Icons.fit_screen_outlined),
          ),
          PopupMenuButton<LayoutType>(
            key: const Key('switchLayout'),
            tooltip: l10n.layoutMenu,
            enabled: canEdit,
            icon: Icon(
              _document.layout == LayoutType.radial
                  ? Icons.hub_outlined
                  : Icons.account_tree_outlined,
            ),
            initialValue: _document.layout,
            onSelected: _setLayout,
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                key: const Key('layoutHorizontal'),
                value: LayoutType.horizontal,
                checked: _document.layout == LayoutType.horizontal,
                child: Text(l10n.layoutHorizontal),
              ),
              CheckedPopupMenuItem(
                key: const Key('layoutRadial'),
                value: LayoutType.radial,
                checked: _document.layout == LayoutType.radial,
                child: Text(l10n.layoutRadial),
              ),
            ],
          ),
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
            child: Stack(
              children: [
                MindMapViewport(
                  key: _viewportKey,
                  document: _document,
                  canvasTheme: canvasTheme,
                  centerPadding: const EdgeInsets.only(bottom: 80),
                  selectedId: _selectedId,
                  editingId: _editingId,
                  editingController: _editController,
                  editingFocusNode: _editFocusNode,
                  onNodeSelected: (id) {
                    if (_editingId != null) {
                      _commitEditing();
                    }
                    setState(() => _selectedId = id);
                  },
                  onNodeLongPress: (id) {
                    setState(() => _selectedId = id);
                  },
                  onNodeDoubleTap: _startEditing,
                  draggingId: _draggingId,
                  dropTargetId: _dropTargetId,
                  onNodeDragStart: canEdit ? _onNodeDragStart : null,
                  onNodeDragUpdate: canEdit ? _onNodeDragUpdate : null,
                  onNodeDragEnd: canEdit ? _onNodeDragEnd : null,
                  onEditingComplete: _commitEditing,
                  onToggleCollapsed: canEdit ? _toggleCollapsed : null,
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: MindMapZoomControls(
                    onZoomIn: _zoomIn,
                    onZoomOut: _zoomOut,
                    onCenterOnRoot: _centerOnRoot,
                  ),
                ),
                if (showContextActions)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: MindMapContextActions(
                      canAddSibling: canAddSibling,
                      canDelete: canDelete,
                      canToggleCollapsed: canToggleCollapsed,
                      collapsed: selected?.collapsed == true,
                      canEdit: canEdit,
                      onEdit: () => _startEditing(_selectedId!),
                      onDoneEditing: _editingId == null ? null : _commitEditing,
                      onAddChild: _addChild,
                      onAddSibling: _addSibling,
                      onDelete: _deleteSelected,
                      onToggleCollapsed: _toggleCollapsed,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
