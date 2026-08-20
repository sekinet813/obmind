import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:obmind/app/app.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/features/mind_map/application/delete_mind_map.dart';
import 'package:obmind/features/mind_map/application/list_mind_map_files.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/recent_mind_maps.dart';
import 'package:obmind/features/mind_map/application/rename_mind_map.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/infrastructure/android_document_storage.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parser.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_serializer.dart';
import 'package:obmind/features/mind_map/infrastructure/shared_preferences_recent_mind_maps_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureAppLogging(suppressDebug: kReleaseMode);
  runApp(await _buildApp());
}

Future<Widget> _buildApp() async {
  if (defaultTargetPlatform != TargetPlatform.android) {
    return const ObmindApp();
  }
  final storage = AndroidDocumentStorage();
  const serializer = MarkdownSerializer();
  final recentRepository =
      await SharedPreferencesRecentMindMapsRepository.create();
  return ObmindApp(
    createMarkdownInFolder: CreateMarkdownInFolder(
      picker: storage,
      storage: storage,
    ),
    folderPicker: storage,
    listMindMapFiles: ListMindMapFiles(storage),
    loadMindMap: LoadMindMap(storage: storage, parser: MarkdownParser()),
    saveMindMap: SaveMindMap(storage: storage, serializer: serializer),
    listRecentMindMaps: ListRecentMindMaps(recentRepository),
    recordRecentMindMap: RecordRecentMindMap(recentRepository),
    removeRecentMindMap: RemoveRecentMindMap(recentRepository),
    renameMindMap: RenameMindMap(
      storage: storage,
      listRecentMindMaps: ListRecentMindMaps(recentRepository),
      recordRecentMindMap: RecordRecentMindMap(recentRepository),
      removeRecentMindMap: RemoveRecentMindMap(recentRepository),
    ),
    deleteMindMap: DeleteMindMap(
      storage: storage,
      removeRecentMindMap: RemoveRecentMindMap(recentRepository),
    ),
  );
}
