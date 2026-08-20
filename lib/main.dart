import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:obmind/app/app.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/features/mind_map/application/load_mind_map.dart';
import 'package:obmind/features/mind_map/application/markdown_file_service.dart';
import 'package:obmind/features/mind_map/application/save_mind_map.dart';
import 'package:obmind/features/mind_map/infrastructure/android_document_storage.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_parser.dart';
import 'package:obmind/features/mind_map/infrastructure/markdown/markdown_serializer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureAppLogging(suppressDebug: kReleaseMode);
  runApp(_buildApp());
}

Widget _buildApp() {
  if (defaultTargetPlatform != TargetPlatform.android) {
    return const ObmindApp();
  }
  final storage = AndroidDocumentStorage();
  const serializer = MarkdownSerializer();
  return ObmindApp(
    createMarkdownInFolder: CreateMarkdownInFolder(
      picker: storage,
      storage: storage,
    ),
    folderPicker: storage,
    markdownFiles: MarkdownFileService(storage),
    loadMindMap: LoadMindMap(storage: storage, parser: MarkdownParser()),
    saveMindMap: SaveMindMap(storage: storage, serializer: serializer),
  );
}
