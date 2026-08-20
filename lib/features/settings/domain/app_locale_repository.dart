import 'package:obmind/features/settings/domain/app_locale_preference.dart';

/// Persists the app language preference. Not a Markdown write.
abstract interface class AppLocaleRepository {
  Future<AppLocalePreference> load();

  Future<void> save(AppLocalePreference preference);
}
