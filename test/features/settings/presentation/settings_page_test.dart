import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/app/app.dart';
import 'package:obmind/app/app_locale_controller.dart';
import 'package:obmind/app/app_theme_controller.dart';
import 'package:obmind/features/mind_map/application/load_vault_folder.dart';
import 'package:obmind/features/mind_map/application/select_vault_folder.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/domain/repositories/vault_folder_repository.dart';
import 'package:obmind/features/settings/domain/app_locale_preference.dart';
import 'package:obmind/features/settings/domain/app_locale_repository.dart';
import 'package:obmind/features/settings/domain/app_theme_preference.dart';
import 'package:obmind/features/settings/domain/app_theme_repository.dart';
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

class _MemoryLocaleRepository implements AppLocaleRepository {
  AppLocalePreference preference = AppLocalePreference.system;

  @override
  Future<AppLocalePreference> load() async => preference;

  @override
  Future<void> save(AppLocalePreference next) async {
    preference = next;
  }
}

class _MemoryThemeRepository implements AppThemeRepository {
  AppThemePreference preference = AppThemePreference.system;

  @override
  Future<AppThemePreference> load() async => preference;

  @override
  Future<void> save(AppThemePreference next) async {
    preference = next;
  }
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

  testWidgets('shows English privacy policy when locale is English', (
    tester,
  ) async {
    final vault = _MemoryVault();
    final picker = _FakePicker();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
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

    expect(find.text('Privacy policy'), findsWidgets);
    expect(find.textContaining('no proprietary servers'), findsOneWidget);
    expect(find.textContaining('正本'), findsNothing);
  });

  testWidgets('switching language in settings updates home copy', (
    tester,
  ) async {
    final vault = _MemoryVault();
    final picker = _FakePicker();
    final localeRepository = _MemoryLocaleRepository();
    final localeController = AppLocaleController(
      repository: localeRepository,
      initial: AppLocalePreference.ja,
    );

    await tester.pumpWidget(
      ObmindApp(
        loadVaultFolder: LoadVaultFolder(vault: vault, picker: picker),
        selectVaultFolder: SelectVaultFolder(picker: picker, vault: vault),
        localeController: localeController,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('思考の保存フォルダを選ぶ'), findsOneWidget);
    expect(find.textContaining('Markdownファイルとして保存します'), findsOneWidget);

    await tester.tap(find.byKey(const Key('openSettings')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('locale_en')));
    await tester.pumpAndSettle();

    expect(localeController.preference, AppLocalePreference.en);
    expect(localeRepository.preference, AppLocalePreference.en);
    expect(find.text('Device language'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Choose a folder for your thoughts'), findsOneWidget);
    expect(
      find.textContaining('saves your thoughts as Markdown files'),
      findsOneWidget,
    );
  });

  testWidgets('switching appearance in settings updates MaterialApp theme', (
    tester,
  ) async {
    final vault = _MemoryVault();
    final picker = _FakePicker();
    final themeRepository = _MemoryThemeRepository();
    final themeController = AppThemeController(
      repository: themeRepository,
      initial: AppThemePreference.dark,
    );

    await tester.pumpWidget(
      ObmindApp(
        loadVaultFolder: LoadVaultFolder(vault: vault, picker: picker),
        selectVaultFolder: SelectVaultFolder(picker: picker, vault: vault),
        themeController: themeController,
      ),
    );
    await tester.pumpAndSettle();

    expect(themeController.themeMode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.dark,
    );

    await tester.tap(find.byKey(const Key('openSettings')));
    await tester.pumpAndSettle();

    expect(find.text('外観'), findsOneWidget);

    await tester.tap(find.byKey(const Key('theme_light')));
    await tester.pumpAndSettle();

    expect(themeController.preference, AppThemePreference.light);
    expect(themeRepository.preference, AppThemePreference.light);
    expect(themeController.themeMode, ThemeMode.light);
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.light,
    );
  });
}
