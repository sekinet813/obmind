import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/domain/repositories/vault_folder_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const vaultFolderTokenKey = 'vault_folder_token';

/// Stores the vault folder token in platform preferences.
final class SharedPreferencesVaultFolderRepository
    implements VaultFolderRepository {
  SharedPreferencesVaultFolderRepository(this._preferences);

  final SharedPreferences _preferences;

  static Future<SharedPreferencesVaultFolderRepository> create() async {
    final preferences = await SharedPreferences.getInstance();
    return SharedPreferencesVaultFolderRepository(preferences);
  }

  @override
  Future<MindMapLocation?> load() async {
    final token = _preferences.getString(vaultFolderTokenKey);
    if (token == null || token.isEmpty) {
      return null;
    }
    return MindMapLocation(token);
  }

  @override
  Future<void> save(MindMapLocation location) async {
    await _preferences.setString(vaultFolderTokenKey, location.token);
  }

  @override
  Future<void> clear() async {
    await _preferences.remove(vaultFolderTokenKey);
  }
}
