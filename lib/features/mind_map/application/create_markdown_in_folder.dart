import 'package:obmind/features/mind_map/domain/mind_map_file_name.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Default Markdown for maps created in the app.
///
/// Existing files without `layout` stay horizontal. Only new files write
/// `layout: radial`. Root text matches [title] so it stays aligned with the
/// file name chosen at creation.
String defaultNewMapMarkdown(String title) {
  return '''
---
obmind:
  version: 1
  theme: minimal
  layout: radial
---

# $title
''';
}

/// Historical template kept for parse compatibility. New maps use
/// [defaultNewMapMarkdown] instead.
const historicalTemplateMarkdown = '''
---
obmind:
  version: 1
  theme: minimal
  layout: radial
---

# Obmind
''';

/// Picks a user folder and creates a Markdown file there.
final class CreateMarkdownInFolder {
  const CreateMarkdownInFolder({required this.picker, required this.storage});

  final MindMapFolderPicker picker;
  final MindMapStorage storage;

  Future<MindMapFile?> call({
    MindMapLocation? folder,
    String? displayName,
    String? markdown,
  }) async {
    final target = folder ?? await picker.pickFolder();
    if (target == null) {
      return null;
    }
    final name = displayName == null
        ? MindMapFileName.nextNewMapName(
            (await storage.list(target)).map((file) => file.displayName),
          )
        : MindMapFileName.normalize(displayName);
    final contents =
        markdown ?? defaultNewMapMarkdown(MindMapFileName.stem(name));
    return storage.create(target, name, markdown: contents);
  }
}
