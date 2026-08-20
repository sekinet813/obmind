import 'package:obmind/features/settings/domain/app_locale_preference.dart';
import 'package:obmind/features/settings/domain/app_locale_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const appLocaleKey = 'app_locale';

/// Stores the app language preference in platform preferences.
final class SharedPreferencesAppLocaleRepository
    implements AppLocaleRepository {
  SharedPreferencesAppLocaleRepository(this._preferences);

  final SharedPreferences _preferences;

  static Future<SharedPreferencesAppLocaleRepository> create() async {
    final preferences = await SharedPreferences.getInstance();
    return SharedPreferencesAppLocaleRepository(preferences);
  }

  @override
  Future<AppLocalePreference> load() async {
    final value = _preferences.getString(appLocaleKey);
    return switch (value) {
      'ja' => AppLocalePreference.ja,
      'en' => AppLocalePreference.en,
      _ => AppLocalePreference.system,
    };
  }

  @override
  Future<void> save(AppLocalePreference preference) async {
    await _preferences.setString(appLocaleKey, preference.name);
  }
}
