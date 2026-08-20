import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/domain/repositories/vault_folder_repository.dart';

/// Loads the persisted vault and reports whether access is still granted.
final class LoadVaultFolder {
  const LoadVaultFolder({required this.vault, required this.picker});

  final VaultFolderRepository vault;
  final MindMapFolderPicker picker;

  Future<VaultFolderStatus> call() async {
    final folder = await vault.load();
    if (folder == null) {
      return const VaultFolderStatus.unset();
    }
    try {
      final accessible = await picker.hasAccess(folder);
      if (!accessible) {
        return VaultFolderStatus.revoked(folder);
      }
      return VaultFolderStatus.ready(folder);
    } catch (_) {
      return VaultFolderStatus.revoked(folder);
    }
  }
}

enum VaultFolderKind { unset, ready, revoked }

final class VaultFolderStatus {
  const VaultFolderStatus._(this.kind, this.folder);

  const VaultFolderStatus.unset() : this._(VaultFolderKind.unset, null);

  const VaultFolderStatus.ready(MindMapLocation folder)
    : this._(VaultFolderKind.ready, folder);

  const VaultFolderStatus.revoked(MindMapLocation folder)
    : this._(VaultFolderKind.revoked, folder);

  final VaultFolderKind kind;
  final MindMapLocation? folder;

  bool get isReady => kind == VaultFolderKind.ready;
}
