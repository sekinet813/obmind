import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/infrastructure/shared_preferences_vault_folder_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists the vault folder token without exposing OS types', () async {
    final repository = await SharedPreferencesVaultFolderRepository.create();
    const folder = MindMapLocation('content://tree/primary');

    await repository.save(folder);

    expect(await repository.load(), folder);
    expect(
      (await SharedPreferences.getInstance()).getString(vaultFolderTokenKey),
      folder.token,
    );
  });

  test('clear removes the persisted vault folder', () async {
    SharedPreferences.setMockInitialValues({
      vaultFolderTokenKey: 'content://tree/primary',
    });
    final repository = await SharedPreferencesVaultFolderRepository.create();

    await repository.clear();

    expect(await repository.load(), isNull);
  });
}
