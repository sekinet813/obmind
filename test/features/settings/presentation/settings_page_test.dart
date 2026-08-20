import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/load_vault_folder.dart';
import 'package:obmind/features/mind_map/application/select_vault_folder.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/domain/repositories/vault_folder_repository.dart';
import 'package:obmind/features/settings/presentation/settings_page.dart';
import 'package:obmind/l10n/app_localizations.dart';

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
  @override
  Future<MindMapLocation?> pickFolder() async {
    return const MindMapLocation('vault');
  }

  @override
  Future<bool> hasAccess(MindMapLocation folder) async => true;
}

void main() {
  testWidgets('settings can select a vault folder after it was unset', (
    tester,
  ) async {
    final vault = _MemoryVault();
    final picker = _FakePicker();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsPage(
          loadVaultFolder: LoadVaultFolder(vault: vault, picker: picker),
          selectVaultFolder: SelectVaultFolder(picker: picker, vault: vault),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('保存フォルダが未設定です'), findsOneWidget);

    await tester.tap(find.byKey(const Key('changeVaultFolder')));
    await tester.pumpAndSettle();

    expect(find.text('保存フォルダは設定済みです'), findsOneWidget);
    expect(await vault.load(), const MindMapLocation('vault'));
  });

  testWidgets('shows the app name, version, and a licenses entry', (
    tester,
  ) async {
    final vault = _MemoryVault();
    final picker = _FakePicker();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsPage(
          loadVaultFolder: LoadVaultFolder(vault: vault, picker: picker),
          selectVaultFolder: SelectVaultFolder(picker: picker, vault: vault),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('appInfo')), findsOneWidget);
    expect(find.text('Obmind'), findsWidgets);
    expect(find.text('1.0.0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('openLicenses')));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('opens the in-app privacy policy from settings', (tester) async {
    final vault = _MemoryVault();
    final picker = _FakePicker();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsPage(
          loadVaultFolder: LoadVaultFolder(vault: vault, picker: picker),
          selectVaultFolder: SelectVaultFolder(picker: picker, vault: vault),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('openPrivacyPolicy')));
    await tester.pumpAndSettle();

    expect(find.text('プライバシーポリシー'), findsWidgets);
    expect(find.textContaining('独自のサーバーも持たない'), findsOneWidget);
    expect(find.textContaining('第三者へ送信しません'), findsOneWidget);
    expect(find.textContaining('正本'), findsNothing);
  });
}
