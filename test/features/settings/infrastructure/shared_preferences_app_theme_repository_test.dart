import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/settings/domain/app_theme_preference.dart';
import 'package:obmind/features/settings/infrastructure/shared_preferences_app_theme_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to system when unset', () async {
    final repository = await SharedPreferencesAppThemeRepository.create();
    expect(await repository.load(), AppThemePreference.system);
  });

  test('saves and loads light and dark', () async {
    final repository = await SharedPreferencesAppThemeRepository.create();

    await repository.save(AppThemePreference.light);
    expect(await repository.load(), AppThemePreference.light);

    await repository.save(AppThemePreference.dark);
    expect(await repository.load(), AppThemePreference.dark);

    await repository.save(AppThemePreference.system);
    expect(await repository.load(), AppThemePreference.system);
  });

  test('unknown stored value falls back to system', () async {
    SharedPreferences.setMockInitialValues({appThemeKey: 'sepia'});
    final repository = await SharedPreferencesAppThemeRepository.create();
    expect(await repository.load(), AppThemePreference.system);
  });
}
