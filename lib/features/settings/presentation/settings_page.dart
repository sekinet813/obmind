import 'package:flutter/material.dart';
import 'package:obmind/app/app_info.dart';
import 'package:obmind/app/app_locale_controller.dart';
import 'package:obmind/app/app_theme_controller.dart';
import 'package:obmind/app/widgets/paper_surface.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/features/mind_map/application/load_vault_folder.dart';
import 'package:obmind/features/mind_map/application/select_vault_folder.dart';
import 'package:obmind/features/settings/domain/app_locale_preference.dart';
import 'package:obmind/features/settings/domain/app_theme_preference.dart';
import 'package:obmind/features/settings/presentation/privacy_policy_page.dart';
import 'package:obmind/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.loadVaultFolder,
    required this.selectVaultFolder,
    this.localeController,
    this.themeController,
    this.appName = AppInfo.name,
    this.versionName = AppInfo.versionName,
  });

  final LoadVaultFolder loadVaultFolder;
  final SelectVaultFolder selectVaultFolder;
  final AppLocaleController? localeController;
  final AppThemeController? themeController;
  final String appName;
  final String versionName;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  VaultFolderStatus _status = const VaultFolderStatus.unset();
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final status = await widget.loadVaultFolder();
    if (mounted) {
      setState(() => _status = status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final statusText = switch (_status.kind) {
      VaultFolderKind.ready => l10n.vaultConfigured,
      VaultFolderKind.revoked => l10n.vaultPermissionLost,
      VaultFolderKind.unset => l10n.vaultNotConfigured,
    };
    final localeController = widget.localeController;
    final themeController = widget.themeController;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          PaperSurface(
            padding: const EdgeInsets.all(20),
            child: Text(statusText, style: theme.textTheme.bodyLarge),
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('changeVaultFolder'),
            onPressed: _busy ? null : _changeVault,
            child: Text(
              _status.kind == VaultFolderKind.unset
                  ? l10n.selectVaultFolder
                  : l10n.changeVaultFolder,
            ),
          ),
          if (localeController != null) ...[
            const SizedBox(height: 32),
            Text(
              l10n.languageSettingsTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: localeController,
              builder: (context, _) {
                return RadioGroup<AppLocalePreference>(
                  groupValue: localeController.preference,
                  onChanged: (value) {
                    if (value != null) {
                      localeController.setPreference(value);
                    }
                  },
                  child: Column(
                    children: [
                      for (final preference in AppLocalePreference.values)
                        RadioListTile<AppLocalePreference>(
                          key: Key('locale_${preference.name}'),
                          title: Text(_languageLabel(l10n, preference)),
                          value: preference,
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
          if (themeController != null) ...[
            const SizedBox(height: 32),
            Text(
              l10n.appearanceSettingsTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: themeController,
              builder: (context, _) {
                return RadioGroup<AppThemePreference>(
                  groupValue: themeController.preference,
                  onChanged: (value) {
                    if (value != null) {
                      themeController.setPreference(value);
                    }
                  },
                  child: Column(
                    children: [
                      for (final preference in AppThemePreference.values)
                        RadioListTile<AppThemePreference>(
                          key: Key('theme_${preference.name}'),
                          title: Text(_themeLabel(l10n, preference)),
                          value: preference,
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 32),
          Text(l10n.appAbout, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          PaperSurface(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.appName, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  widget.versionName,
                  key: const Key('appInfo'),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextButton(
                  key: const Key('openLicenses'),
                  onPressed: () {
                    showLicensePage(
                      context: context,
                      applicationName: widget.appName,
                      applicationVersion: widget.versionName,
                    );
                  },
                  child: Text(l10n.openSourceLicenses),
                ),
                TextButton(
                  key: const Key('openPrivacyPolicy'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                  child: Text(l10n.privacyPolicyTitle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _languageLabel(AppLocalizations l10n, AppLocalePreference preference) {
    return switch (preference) {
      AppLocalePreference.system => l10n.languageSystem,
      AppLocalePreference.ja => l10n.languageJapanese,
      AppLocalePreference.en => l10n.languageEnglish,
    };
  }

  String _themeLabel(AppLocalizations l10n, AppThemePreference preference) {
    return switch (preference) {
      AppThemePreference.system => l10n.themeSystem,
      AppThemePreference.light => l10n.themeLight,
      AppThemePreference.dark => l10n.themeDark,
    };
  }

  Future<void> _changeVault() async {
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final folder = await widget.selectVaultFolder();
      if (!mounted) {
        return;
      }
      if (folder == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.folderPickCancelled)));
        return;
      }
      await _refresh();
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to change vault folder',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.folderPickFailed)));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}
