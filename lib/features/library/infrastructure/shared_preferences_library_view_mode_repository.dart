import 'package:obmind/features/library/domain/library_view_mode.dart';
import 'package:obmind/features/library/domain/library_view_mode_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const libraryViewModeKey = 'library_view_mode';

/// Stores the Library view mode in platform preferences.
final class SharedPreferencesLibraryViewModeRepository
    implements LibraryViewModeRepository {
  SharedPreferencesLibraryViewModeRepository(this._preferences);

  final SharedPreferences _preferences;

  static Future<SharedPreferencesLibraryViewModeRepository> create() async {
    final preferences = await SharedPreferences.getInstance();
    return SharedPreferencesLibraryViewModeRepository(preferences);
  }

  @override
  Future<LibraryViewMode> load() async {
    final value = _preferences.getString(libraryViewModeKey);
    return value == LibraryViewMode.tiles.name
        ? LibraryViewMode.tiles
        : LibraryViewMode.list;
  }

  @override
  Future<void> save(LibraryViewMode mode) async {
    await _preferences.setString(libraryViewModeKey, mode.name);
  }
}
