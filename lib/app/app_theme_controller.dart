import 'package:flutter/material.dart';
import 'package:obmind/features/settings/domain/app_theme_preference.dart';
import 'package:obmind/features/settings/domain/app_theme_repository.dart';

/// Holds the saved appearance preference and notifies [MaterialApp] to rebuild.
final class AppThemeController extends ChangeNotifier {
  AppThemeController({
    required AppThemeRepository repository,
    AppThemePreference initial = AppThemePreference.system,
  }) : _repository = repository,
       _preference = initial;

  final AppThemeRepository _repository;
  AppThemePreference _preference;

  AppThemePreference get preference => _preference;

  /// Explicit theme mode for [MaterialApp].
  ThemeMode get themeMode => switch (_preference) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };

  Future<void> setPreference(AppThemePreference preference) async {
    if (_preference == preference) {
      return;
    }
    _preference = preference;
    notifyListeners();
    await _repository.save(preference);
  }

  static Future<AppThemeController> create(
    AppThemeRepository repository,
  ) async {
    final initial = await repository.load();
    return AppThemeController(repository: repository, initial: initial);
  }
}
