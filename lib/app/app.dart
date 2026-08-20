import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ja'),
      theme: ObmindTheme.light(),
      darkTheme: ObmindTheme.dark(),
      themeMode: ThemeMode.system,
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
      ),
    );
  }
}
