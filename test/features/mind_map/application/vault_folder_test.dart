import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/load_vault_folder.dart';
import 'package:obmind/features/mind_map/application/select_vault_folder.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/domain/repositories/vault_folder_repository.dart';

class _MemoryVault implements VaultFolderRepository {
  MindMapLocation? folder;

  @override
  Future<MindMapLocation?> load() async => folder;

  @override
  Future<void> save(MindMapLocation location) async {
    folder = location;
  }

  @override
  Future<void> clear() async {
    folder = null;
  }
}

class _FakePicker implements MindMapFolderPicker {
  _FakePicker({this.picked, this.accessible = true});

  MindMapLocation? picked;
  var accessible = true;
  var pickCount = 0;

  @override
  Future<MindMapLocation?> pickFolder() async {
    pickCount += 1;
    return picked;
  }

  @override
  Future<bool> hasAccess(MindMapLocation folder) async => accessible;
}

void main() {
  test('selects a folder and stores it as the vault', () async {
    final vault = _MemoryVault();
    const folder = MindMapLocation('vault');
    final picker = _FakePicker(picked: folder);

    final selected = await SelectVaultFolder(picker: picker, vault: vault)();

    expect(selected, folder);
    expect(await vault.load(), folder);
    expect(picker.pickCount, 1);
  });

  test('does not store a vault when the picker is cancelled', () async {
    final vault = _MemoryVault();
    final picker = _FakePicker();

    expect(await SelectVaultFolder(picker: picker, vault: vault)(), isNull);
    expect(await vault.load(), isNull);
  });

  test('reports ready, unset, and revoked vault states', () async {
    final vault = _MemoryVault();
    const folder = MindMapLocation('vault');
    final picker = _FakePicker(accessible: true);
    final load = LoadVaultFolder(vault: vault, picker: picker);

    expect((await load()).kind, VaultFolderKind.unset);

    await vault.save(folder);
    expect((await load()).kind, VaultFolderKind.ready);

    picker.accessible = false;
    expect((await load()).kind, VaultFolderKind.revoked);
  });
}
