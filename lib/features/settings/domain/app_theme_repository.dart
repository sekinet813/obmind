import 'package:obmind/features/settings/domain/app_theme_preference.dart';

/// Persists the app appearance preference. Not a Markdown write.
abstract interface class AppThemeRepository {
  Future<AppThemePreference> load();

  Future<void> save(AppThemePreference preference);
}
