import 'dart:async';

import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Debounces [SaveMindMap] so edits do not write on every keystroke or tap.
final class AutosaveMindMap {
  AutosaveMindMap({
    required this.saveMindMap,
    this.debounce = const Duration(milliseconds: 800),
  });

  final SaveMindMap saveMindMap;
  final Duration debounce;

  Timer? _timer;
  MindMapLocation? _pendingLocation;
  MindMapDocument? _pendingDocument;
  Future<void>? _inFlight;

  void schedule(MindMapLocation location, MindMapDocument document) {
    _pendingLocation = location;
    _pendingDocument = document;
    _timer?.cancel();
    _timer = Timer(debounce, () {
      unawaited(_runSave());
    });
  }

  /// Saves immediately when a debounced write is pending.
  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;
    await _runSave();
  }

  Future<void> _runSave() async {
    final location = _pendingLocation;
    final document = _pendingDocument;
    if (location == null || document == null) {
      return;
    }

    _pendingLocation = null;
    _pendingDocument = null;

    while (_inFlight != null) {
      await _inFlight;
    }

    _inFlight = saveMindMap(location, document);
    try {
      await _inFlight;
    } finally {
      _inFlight = null;
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
