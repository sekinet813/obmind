import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

const pocMarkdownFileName = 'obmind-poc.md';

const pocMarkdownContents = '# Obmind\n';

/// Picks a user folder and creates a Markdown file there.
final class CreateMarkdownInFolder {
  const CreateMarkdownInFolder({required this.picker, required this.storage});

  final MindMapFolderPicker picker;
  final MindMapStorage storage;

  Future<MindMapFile?> call({
    MindMapLocation? folder,
    String displayName = pocMarkdownFileName,
    String markdown = pocMarkdownContents,
  }) async {
    final target = folder ?? await picker.pickFolder();
    if (target == null) {
      return null;
    }
    return storage.create(target, displayName, markdown: markdown);
  }
}
