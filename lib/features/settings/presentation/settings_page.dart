import 'package:flutter/material.dart';
import 'package:obmind/app/app_info.dart';
import 'package:obmind/app/widgets/paper_surface.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/features/mind_map/application/load_vault_folder.dart';
import 'package:obmind/features/mind_map/application/select_vault_folder.dart';
import 'package:obmind/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.loadVaultFolder,
    required this.selectVaultFolder,
    this.appName = AppInfo.name,
    this.versionName = AppInfo.versionName,
  });

  final LoadVaultFolder loadVaultFolder;
  final SelectVaultFolder selectVaultFolder;
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
              ],
            ),
          ),
        ],
      ),
    );
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
