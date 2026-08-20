import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/library/domain/library_view_mode.dart';
import 'package:obmind/features/library/infrastructure/shared_preferences_library_view_mode_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists the library view mode without writing markdown', () async {
    final repository =
        await SharedPreferencesLibraryViewModeRepository.create();

    expect(await repository.load(), LibraryViewMode.list);
    await repository.save(LibraryViewMode.tiles);
    expect(await repository.load(), LibraryViewMode.tiles);
    expect(
      (await SharedPreferences.getInstance()).getString(libraryViewModeKey),
      'tiles',
    );
  });
}
