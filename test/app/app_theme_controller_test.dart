import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/app/app_theme_controller.dart';
import 'package:obmind/features/settings/domain/app_theme_preference.dart';
import 'package:obmind/features/settings/domain/app_theme_repository.dart';

class _MemoryThemeRepository implements AppThemeRepository {
  AppThemePreference preference = AppThemePreference.system;

  @override
  Future<AppThemePreference> load() async => preference;

  @override
  Future<void> save(AppThemePreference next) async {
    preference = next;
  }
}

void main() {
  test('maps preference to ThemeMode', () {
    final repository = _MemoryThemeRepository();
    final controller = AppThemeController(
      repository: repository,
      initial: AppThemePreference.system,
    );

    expect(controller.themeMode, ThemeMode.system);

    controller.setPreference(AppThemePreference.light);
    expect(controller.themeMode, ThemeMode.light);
    expect(repository.preference, AppThemePreference.light);

    controller.setPreference(AppThemePreference.dark);
    expect(controller.themeMode, ThemeMode.dark);
    expect(repository.preference, AppThemePreference.dark);
  });

  test('create loads initial preference from repository', () async {
    final repository = _MemoryThemeRepository()
      ..preference = AppThemePreference.dark;
    final controller = await AppThemeController.create(repository);
    expect(controller.preference, AppThemePreference.dark);
    expect(controller.themeMode, ThemeMode.dark);
  });

  test('setPreference is a no-op when unchanged', () async {
    final repository = _MemoryThemeRepository();
    final controller = AppThemeController(
      repository: repository,
      initial: AppThemePreference.light,
    );
    var notifications = 0;
    controller.addListener(() => notifications++);

    await controller.setPreference(AppThemePreference.light);
    expect(notifications, 0);
  });
}
