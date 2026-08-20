import 'package:flutter/material.dart';
import 'package:obmind/features/settings/domain/app_locale_preference.dart';
import 'package:obmind/features/settings/domain/app_locale_repository.dart';

/// Holds the saved language preference and notifies [MaterialApp] to rebuild.
final class AppLocaleController extends ChangeNotifier {
  AppLocaleController({
    required AppLocaleRepository repository,
    AppLocalePreference initial = AppLocalePreference.system,
  }) : _repository = repository,
       _preference = initial;

  final AppLocaleRepository _repository;
  AppLocalePreference _preference;

  AppLocalePreference get preference => _preference;

  /// Explicit locale for [MaterialApp], or null to follow the device.
  Locale? get materialLocale => switch (_preference) {
    AppLocalePreference.system => null,
    AppLocalePreference.ja => const Locale('ja'),
    AppLocalePreference.en => const Locale('en'),
  };

  Future<void> setPreference(AppLocalePreference preference) async {
    if (_preference == preference) {
      return;
    }
    _preference = preference;
    notifyListeners();
    await _repository.save(preference);
  }

  static Future<AppLocaleController> create(
    AppLocaleRepository repository,
  ) async {
    final initial = await repository.load();
    return AppLocaleController(repository: repository, initial: initial);
  }
}

/// Resolves device / preferred locales to ja or en. Unsupported → ja.
Locale? resolveAppLocale(
  List<Locale>? locales,
  Iterable<Locale> supportedLocales,
) {
  if (locales != null) {
    for (final locale in locales) {
      for (final supported in supportedLocales) {
        if (supported.languageCode == locale.languageCode) {
          return Locale(supported.languageCode);
        }
      }
    }
  }
  return const Locale('ja');
}
