import 'package:obmind/features/settings/domain/app_theme_preference.dart';
import 'package:obmind/features/settings/domain/app_theme_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const appThemeKey = 'app_theme';

/// Stores the app appearance preference in platform preferences.
final class SharedPreferencesAppThemeRepository implements AppThemeRepository {
  SharedPreferencesAppThemeRepository(this._preferences);

  final SharedPreferences _preferences;

  static Future<SharedPreferencesAppThemeRepository> create() async {
    final preferences = await SharedPreferences.getInstance();
    return SharedPreferencesAppThemeRepository(preferences);
  }

  @override
  Future<AppThemePreference> load() async {
    final value = _preferences.getString(appThemeKey);
    return switch (value) {
      'light' => AppThemePreference.light,
      'dark' => AppThemePreference.dark,
      _ => AppThemePreference.system,
    };
  }

  @override
  Future<void> save(AppThemePreference preference) async {
    await _preferences.setString(appThemeKey, preference.name);
  }
}
