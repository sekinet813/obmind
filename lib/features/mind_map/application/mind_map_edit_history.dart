import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';

/// In-memory undo / redo stack. Not persisted to Markdown.
final class MindMapEditHistory {
  MindMapEditHistory(MindMapDocument initial) : _present = initial;

  MindMapDocument _present;
  final List<MindMapDocument> _undoStack = [];
  final List<MindMapDocument> _redoStack = [];

  MindMapDocument get present => _present;

  bool get canUndo => _undoStack.isNotEmpty;

  bool get canRedo => _redoStack.isNotEmpty;

  void push(MindMapDocument next) {
    _undoStack.add(_present);
    _present = next;
    _redoStack.clear();
  }

  MindMapDocument? undo() {
    if (_undoStack.isEmpty) {
      return null;
    }
    _redoStack.add(_present);
    _present = _undoStack.removeLast();
    return _present;
  }

  MindMapDocument? redo() {
    if (_redoStack.isEmpty) {
      return null;
    }
    _undoStack.add(_present);
    _present = _redoStack.removeLast();
    return _present;
  }
}
