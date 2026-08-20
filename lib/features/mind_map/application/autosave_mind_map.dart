import 'dart:async';

import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/models/mind_map_document.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Debounces [SaveMindMap] so edits do not write on every keystroke or tap.
final class AutosaveMindMap {
  AutosaveMindMap({
    required this.saveMindMap,
    required MindMapRevision initialRevision,
    this.debounce = const Duration(milliseconds: 800),
    this.onConflict,
  }) : _revision = initialRevision;

  final SaveMindMap saveMindMap;
  final Duration debounce;
  final void Function()? onConflict;

  MindMapRevision _revision;
  Timer? _timer;
  MindMapLocation? _pendingLocation;
  MindMapDocument? _pendingDocument;
  Future<void>? _inFlight;

  MindMapRevision get revision => _revision;

  void schedule(MindMapLocation location, MindMapDocument document) {
    _pendingLocation = location;
    _pendingDocument = document;
    _timer?.cancel();
    _timer = Timer(debounce, () {
      unawaited(() async {
        try {
          await _runSave();
        } on MindMapStorageConflictException {
          // Handled through [onConflict].
        }
      }());
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

    _inFlight = _save(location, document);
    try {
      await _inFlight;
    } finally {
      _inFlight = null;
    }
  }

  Future<void> _save(MindMapLocation location, MindMapDocument document) async {
    try {
      _revision = await saveMindMap(
        location,
        document,
        ifUnchangedSince: _revision,
      );
    } on MindMapStorageConflictException {
      onConflict?.call();
      rethrow;
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
