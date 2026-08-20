import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Lets the user choose a folder. OS picker UI stays in Infrastructure.
abstract interface class MindMapFolderPicker {
  Future<MindMapLocation?> pickFolder();

  /// Returns false when persisted access is missing or revoked.
  Future<bool> hasAccess(MindMapLocation folder);
}
