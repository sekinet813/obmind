import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:obmind/app/obmind_theme.dart';
import 'package:obmind/features/library/presentation/home_page.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/features/mind_map/application/list_mind_map_files.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/recent_mind_maps.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/l10n/app_localizations.dart';

class ObmindApp extends StatelessWidget {
  const ObmindApp({
    super.key,
    this.createMarkdownInFolder,
    this.folderPicker,
    this.listMindMapFiles,
    this.loadMindMap,
    this.saveMindMap,
    this.listRecentMindMaps,
    this.recordRecentMindMap,
    this.removeRecentMindMap,
  });

  final CreateMarkdownInFolder? createMarkdownInFolder;
  final MindMapFolderPicker? folderPicker;
  final ListMindMapFiles? listMindMapFiles;
  final LoadMindMap? loadMindMap;
  final SaveMindMap? saveMindMap;
  final ListRecentMindMaps? listRecentMindMaps;
  final RecordRecentMindMap? recordRecentMindMap;
  final RemoveRecentMindMap? removeRecentMindMap;

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
        folderPicker: folderPicker,
        listMindMapFiles: listMindMapFiles,
        loadMindMap: loadMindMap,
        saveMindMap: saveMindMap,
        listRecentMindMaps: listRecentMindMaps,
        recordRecentMindMap: recordRecentMindMap,
        removeRecentMindMap: removeRecentMindMap,
      ),
    );
  }
}
