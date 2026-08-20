import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:obmind/app/app_locale_controller.dart';
import 'package:obmind/app/app_theme_controller.dart';
import 'package:obmind/app/obmind_theme.dart';
import 'package:obmind/features/library/domain/library_view_mode_repository.dart';
import 'package:obmind/features/library/presentation/home_page.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/features/mind_map/application/delete_mind_map.dart';
import 'package:obmind/features/mind_map/application/list_mind_map_files.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/load_vault_folder.dart';
import 'package:obmind/features/mind_map/application/recent_mind_maps.dart';
import 'package:obmind/features/mind_map/application/rename_mind_map.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/application/select_vault_folder.dart';
import 'package:obmind/l10n/app_localizations.dart';

class ObmindApp extends StatelessWidget {
  const ObmindApp({
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
  Widget build(BuildContext context) {
    final locale = localeController;
    final theme = themeController;
    final listenables = <Listenable>[?locale, ?theme];
    if (listenables.isEmpty) {
      return _buildApp(locale: const Locale('ja'), themeMode: ThemeMode.system);
    }
    return ListenableBuilder(
      listenable: Listenable.merge(listenables),
      builder: (context, _) {
        return _buildApp(
          locale: locale != null ? locale.materialLocale : const Locale('ja'),
          themeMode: theme?.themeMode ?? ThemeMode.system,
        );
      },
    );
  }

  Widget _buildApp({required Locale? locale, required ThemeMode themeMode}) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      localeListResolutionCallback: resolveAppLocale,
      theme: ObmindTheme.light(),
      darkTheme: ObmindTheme.dark(),
      themeMode: themeMode,
      home: HomePage(
        createMarkdownInFolder: createMarkdownInFolder,
        listMindMapFiles: listMindMapFiles,
        loadMindMap: loadMindMap,
        saveMindMap: saveMindMap,
        listRecentMindMaps: listRecentMindMaps,
        recordRecentMindMap: recordRecentMindMap,
        removeRecentMindMap: removeRecentMindMap,
        renameMindMap: renameMindMap,
        deleteMindMap: deleteMindMap,
        loadVaultFolder: loadVaultFolder,
        selectVaultFolder: selectVaultFolder,
        libraryViewModeRepository: libraryViewModeRepository,
        localeController: localeController,
        themeController: themeController,
      ),
    );
  }
}
