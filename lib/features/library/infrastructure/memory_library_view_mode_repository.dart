import 'package:obmind/features/library/domain/library_view_mode.dart';
import 'package:obmind/features/library/domain/library_view_mode_repository.dart';

/// In-memory view mode for tests and platforms without a repository.
final class MemoryLibraryViewModeRepository
    implements LibraryViewModeRepository {
  MemoryLibraryViewModeRepository([this._mode = LibraryViewMode.list]);

  LibraryViewMode _mode;

  @override
  Future<LibraryViewMode> load() async => _mode;

  @override
  Future<void> save(LibraryViewMode mode) async {
    _mode = mode;
  }
}
