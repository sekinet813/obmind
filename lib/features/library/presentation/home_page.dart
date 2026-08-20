import 'package:flutter/material.dart';
import 'package:obmind/app/app_locale_controller.dart';
import 'package:obmind/app/app_theme_controller.dart';
import 'package:obmind/app/widgets/paper_surface.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/features/library/domain/library_view_mode_repository.dart';
import 'package:obmind/features/library/presentation/mind_map_file_list_page.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/features/mind_map/application/delete_mind_map.dart';
import 'package:obmind/features/mind_map/application/list_mind_map_files.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/load_vault_folder.dart';
import 'package:obmind/features/mind_map/application/recent_mind_maps.dart';
import 'package:obmind/features/mind_map/application/rename_mind_map.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/application/select_vault_folder.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/presentation/mind_map_page.dart';
import 'package:obmind/features/settings/presentation/settings_page.dart';
import 'package:obmind/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.createMarkdownInFolder,
    this.listMindMapFiles,
    this.loadMindMap,
    this.saveMindMap,
    this.listRecentMindMaps,
    this.recordRecentMindMap,
    this.removeRecentMindMap,
    this.renameMindMap,
    this.deleteMindMap,
    this.loadVaultFolder,
    this.selectVaultFolder,
    this.libraryViewModeRepository,
    this.localeController,
    this.themeController,
  });

  final CreateMarkdownInFolder? createMarkdownInFolder;
  final ListMindMapFiles? listMindMapFiles;
  final LoadMindMap? loadMindMap;
  final SaveMindMap? saveMindMap;
  final ListRecentMindMaps? listRecentMindMaps;
  final RecordRecentMindMap? recordRecentMindMap;
  final RemoveRecentMindMap? removeRecentMindMap;
  final RenameMindMap? renameMindMap;
  final DeleteMindMap? deleteMindMap;
  final LoadVaultFolder? loadVaultFolder;
  final SelectVaultFolder? selectVaultFolder;
  final LibraryViewModeRepository? libraryViewModeRepository;
  final AppLocaleController? localeController;
  final AppThemeController? themeController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _busy = false;
  List<MindMapFile> _recentFiles = const [];
  VaultFolderStatus _vault = const VaultFolderStatus.unset();
  List<MindMapFile>? _libraryFiles;

  @override
  void initState() {
    super.initState();
    _loadRecent();
    _loadVault();
  }

  Future<void> _loadVault() async {
    final loadVaultFolder = widget.loadVaultFolder;
    if (loadVaultFolder == null) {
      return;
    }
    try {
      final status = await loadVaultFolder();
      if (!mounted) {
        return;
      }
      if (status.isReady &&
          status.folder != null &&
          widget.listMindMapFiles != null) {
        try {
          final listed = await widget.listMindMapFiles!(status.folder!);
          if (mounted) {
            setState(() {
              _vault = status;
              _libraryFiles = listed;
            });
          }
          return;
        } on MindMapStorageException catch (error, stackTrace) {
          appLogger.error(
            'Failed to list vault Markdown files',
            error: error,
            stackTrace: stackTrace,
          );
          if (mounted) {
            setState(() {
              _vault = VaultFolderStatus.revoked(status.folder!);
              _libraryFiles = null;
            });
          }
          return;
        }
      }
      setState(() {
        _vault = status;
        _libraryFiles = null;
      });
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to load vault folder',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _loadRecent() async {
    final listRecent = widget.listRecentMindMaps;
    if (listRecent == null) {
      return;
    }
    try {
      final recent = await listRecent();
      if (mounted) {
        setState(() => _recentFiles = recent);
      }
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to load recent mind maps',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final createMarkdownInFolder = widget.createMarkdownInFolder;

    if (_vault.isReady &&
        _libraryFiles != null &&
        widget.loadMindMap != null &&
        widget.saveMindMap != null) {
      return MindMapFileListPage(
        files: _libraryFiles!,
        loadMindMap: widget.loadMindMap!,
        saveMindMap: widget.saveMindMap!,
        renameMindMap: widget.renameMindMap,
        deleteMindMap: widget.deleteMindMap,
        createMarkdownInFolder: createMarkdownInFolder,
        vaultFolder: _vault.folder,
        asHome: true,
        onOpenSettings:
            widget.loadVaultFolder != null && widget.selectVaultFolder != null
            ? _openSettings
            : null,
        recordRecentMindMap: widget.recordRecentMindMap,
        removeRecentMindMap: widget.removeRecentMindMap,
        viewModeRepository: widget.libraryViewModeRepository,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (widget.loadVaultFolder != null &&
              widget.selectVaultFolder != null)
            IconButton(
              key: const Key('openSettings'),
              tooltip: l10n.settingsTitle,
              onPressed: _busy ? null : _openSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          PaperSurface(
            padding: const EdgeInsets.all(20),
            child:
                widget.loadVaultFolder != null &&
                    _vault.kind == VaultFolderKind.unset
                ? Column(
                    children: [
                      Text(
                        l10n.vaultOnboardingTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.vaultOnboardingBody,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  )
                : Text(
                    l10n.homeMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
          ),
          if (_recentFiles.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(l10n.recentMindMaps, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final file in _recentFiles) ...[
              PaperSurface(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                onTap: _busy ? null : () => _openMindMap(file),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        file.displayName,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ],
          if (widget.loadVaultFolder != null) ...[
            if (_vault.kind == VaultFolderKind.unset) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _selectVault,
                child: Text(l10n.selectVaultFolder),
              ),
            ] else if (_vault.kind == VaultFolderKind.revoked) ...[
              const SizedBox(height: 24),
              Text(
                l10n.vaultPermissionLost,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _busy ? null : _selectVault,
                child: Text(l10n.changeVaultFolder),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _selectVault() async {
    final selectVaultFolder = widget.selectVaultFolder;
    if (selectVaultFolder == null) {
      return;
    }
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final folder = await selectVaultFolder();
      if (!mounted) {
        return;
      }
      if (folder == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.folderPickCancelled)));
        return;
      }
      await _loadVault();
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to select vault folder',
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

  Future<void> _openSettings() async {
    final loadVaultFolder = widget.loadVaultFolder;
    final selectVaultFolder = widget.selectVaultFolder;
    if (loadVaultFolder == null || selectVaultFolder == null) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SettingsPage(
          loadVaultFolder: loadVaultFolder,
          selectVaultFolder: selectVaultFolder,
          localeController: widget.localeController,
          themeController: widget.themeController,
        ),
      ),
    );
    await _loadVault();
  }

  Future<void> _openMindMap(MindMapFile file) async {
    final loadMindMap = widget.loadMindMap;
    final saveMindMap = widget.saveMindMap;
    if (loadMindMap == null || saveMindMap == null) {
      return;
    }
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final loaded = await loadMindMap(file.location);
      await widget.recordRecentMindMap?.call(file);
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => MindMapPage(
            file: file,
            document: loaded.document,
            saveMindMap: saveMindMap,
            renameMindMap: widget.renameMindMap,
            revision: loaded.revision,
            readOnly: loaded.hasUnsupportedContent,
          ),
        ),
      );
      await _loadRecent();
    } on LoadMindMapException catch (error, stackTrace) {
      appLogger.error(
        'Failed to load mind map',
        error: error,
        stackTrace: stackTrace,
      );
      await widget.removeRecentMindMap?.call(file.location);
      await _loadRecent();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.mindMapLoadFailed)));
    } on MindMapStorageException catch (error, stackTrace) {
      appLogger.error(
        'Failed to read mind map file',
        error: error,
        stackTrace: stackTrace,
      );
      await widget.removeRecentMindMap?.call(file.location);
      await _loadRecent();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.recentMindMapUnavailable)));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}
