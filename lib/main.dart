import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:obmind/app/app.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/features/mind_map/infrastructure/android_document_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureAppLogging(suppressDebug: kReleaseMode);
  runApp(ObmindApp(createMarkdownInFolder: _createMarkdownInFolder()));
}

CreateMarkdownInFolder? _createMarkdownInFolder() {
  if (defaultTargetPlatform != TargetPlatform.android) {
    return null;
  }
  final storage = AndroidDocumentStorage();
  return CreateMarkdownInFolder(picker: storage, storage: storage);
}
