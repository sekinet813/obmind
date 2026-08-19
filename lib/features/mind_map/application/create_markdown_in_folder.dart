import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

const pocMarkdownFileName = 'obmind-poc.md';

const pocMarkdownContents = '# Obmind\n\nこのファイルはObmindのStorage PoCで作成されました。\n';

/// Picks a user folder and creates a Markdown file there.
final class CreateMarkdownInFolder {
  const CreateMarkdownInFolder({required this.picker, required this.storage});

  final MindMapFolderPicker picker;
  final MindMapStorage storage;

  Future<MindMapFile?> call({
    String displayName = pocMarkdownFileName,
    String markdown = pocMarkdownContents,
  }) async {
    final folder = await picker.pickFolder();
    if (folder == null) {
      return null;
    }
    return storage.create(folder, displayName, markdown: markdown);
  }
}
