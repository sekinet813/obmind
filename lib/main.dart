import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:obmind/app/app.dart';
import 'package:obmind/core/logging/app_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureAppLogging(suppressDebug: kReleaseMode);
  runApp(const ObmindApp());
}
