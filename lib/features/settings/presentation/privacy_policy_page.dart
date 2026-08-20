import 'package:flutter/material.dart';
import 'package:obmind/app/widgets/paper_surface.dart';
import 'package:obmind/l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          PaperSurface(
            padding: const EdgeInsets.all(20),
            child: SelectableText(
              l10n.privacyPolicyBody.trim(),
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
