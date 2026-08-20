import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/domain/repositories/vault_folder_repository.dart';

/// Picks a folder and stores it as the vault location.
final class SelectVaultFolder {
  const SelectVaultFolder({required this.picker, required this.vault});

  final MindMapFolderPicker picker;
  final VaultFolderRepository vault;

  Future<MindMapLocation?> call() async {
    final folder = await picker.pickFolder();
    if (folder == null) {
      return null;
    }
    await vault.save(folder);
    return folder;
  }
}
