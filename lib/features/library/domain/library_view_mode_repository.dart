import 'package:obmind/features/library/domain/library_view_mode.dart';

/// Persists the Library list / tile preference. Not a Markdown write.
abstract interface class LibraryViewModeRepository {
  Future<LibraryViewMode> load();

  Future<void> save(LibraryViewMode mode);
}
