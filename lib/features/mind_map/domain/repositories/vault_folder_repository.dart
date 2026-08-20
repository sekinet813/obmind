import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Persists the chosen vault folder token in Infrastructure.
abstract interface class VaultFolderRepository {
  Future<MindMapLocation?> load();

  Future<void> save(MindMapLocation location);

  Future<void> clear();
}
