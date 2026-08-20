import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/settings/domain/app_locale_preference.dart';
import 'package:obmind/features/settings/infrastructure/shared_preferences_app_locale_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to system when unset', () async {
    final repository = await SharedPreferencesAppLocaleRepository.create();
    expect(await repository.load(), AppLocalePreference.system);
  });

  test('saves and loads ja and en', () async {
    final repository = await SharedPreferencesAppLocaleRepository.create();

    await repository.save(AppLocalePreference.en);
    expect(await repository.load(), AppLocalePreference.en);

    await repository.save(AppLocalePreference.ja);
    expect(await repository.load(), AppLocalePreference.ja);

    await repository.save(AppLocalePreference.system);
    expect(await repository.load(), AppLocalePreference.system);
  });

  test('unknown stored value falls back to system', () async {
    SharedPreferences.setMockInitialValues({appLocaleKey: 'fr'});
    final repository = await SharedPreferencesAppLocaleRepository.create();
    expect(await repository.load(), AppLocalePreference.system);
  });
}
