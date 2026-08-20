import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:obmind/features/library/presentation/home_page.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/markdown_file_service.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/l10n/app_localizations.dart';

class ObmindApp extends StatelessWidget {
  const ObmindApp({
    super.key,
    this.createMarkdownInFolder,
    this.folderPicker,
    this.markdownFiles,
    this.loadMindMap,
    this.saveMindMap,
  });

  final CreateMarkdownInFolder? createMarkdownInFolder;
  final MindMapFolderPicker? folderPicker;
  final MarkdownFileService? markdownFiles;
  final LoadMindMap? loadMindMap;
  final SaveMindMap? saveMindMap;

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(
        createMarkdownInFolder: createMarkdownInFolder,
        folderPicker: folderPicker,
        markdownFiles: markdownFiles,
        loadMindMap: loadMindMap,
        saveMindMap: saveMindMap,
      ),
    );
  }
}
