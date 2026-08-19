import 'package:flutter/material.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/features/mind_map/application/create_markdown_in_folder.dart';
import 'package:obmind/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.createMarkdownInFolder});

  final CreateMarkdownInFolder? createMarkdownInFolder;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final createMarkdownInFolder = widget.createMarkdownInFolder;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.appTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.homeMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (createMarkdownInFolder != null) ...[
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _createMarkdown(createMarkdownInFolder),
                  child: Text(l10n.pickFolderAndCreateMarkdown),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createMarkdown(CreateMarkdownInFolder useCase) async {
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final file = await useCase();
      if (!mounted) {
        return;
      }
      final messenger = ScaffoldMessenger.of(context);
      if (file == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.folderPickCancelled)),
        );
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.markdownCreated(file.displayName))),
      );
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to create Markdown in the picked folder',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.folderPickFailed)));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}
