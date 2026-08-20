// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Obmind';

  @override
  String get homeMessage =>
      'A local-first mind map app. Your thoughts stay as Markdown files.';

  @override
  String get folderPickCancelled => 'Folder selection was cancelled';

  @override
  String get folderPickFailed => 'Could not select the folder or save to it';

  @override
  String markdownCreated(String fileName) {
    return 'Created $fileName';
  }

  @override
  String get saveMarkdown => 'Save';

  @override
  String get markdownSaved => 'Saved';

  @override
  String get markdownSaveFailed =>
      'Save failed. The original file was left unchanged';

  @override
  String get mindMapLoadFailed => 'Could not load as a mind map';

  @override
  String get mindMapReadOnlyUnsupported =>
      'Unsupported Markdown content. Overwrite save is disabled';

  @override
  String get mindMapExternalChangeBlocked =>
      'The file changed externally. Overwrite save was stopped';

  @override
  String get recentMindMaps => 'Recent maps';

  @override
  String get recentMindMapUnavailable =>
      'Could not open the file. Removed it from recent maps';

  @override
  String get noMarkdownFiles => 'No Markdown files in this folder';

  @override
  String get editMarkdownHint => 'Markdown';

  @override
  String get addChildNode => 'Add child';

  @override
  String get addSiblingNode => 'Add sibling';

  @override
  String get newNodeText => 'New node';

  @override
  String get newMindMapName => 'New Mind Map';

  @override
  String get deleteNode => 'Delete';

  @override
  String get collapseNode => 'Collapse';

  @override
  String get expandNode => 'Expand';

  @override
  String get editNode => 'Edit';

  @override
  String get doneEditingNode => 'Done';

  @override
  String get fitToScreen => 'Fit to screen';

  @override
  String get centerOnRoot => 'Center on root';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get undoEdit => 'Undo';

  @override
  String get redoEdit => 'Redo';

  @override
  String get renameMindMap => 'Rename';

  @override
  String get renameMindMapHint => 'File name';

  @override
  String get renameMindMapFailed => 'Could not rename';

  @override
  String get renameMindMapInvalidName => 'Invalid file name';

  @override
  String get renameMindMapDuplicateName =>
      'A file with that name already exists';

  @override
  String get deleteMindMap => 'Delete';

  @override
  String deleteMindMapConfirm(String fileName) {
    return 'Delete $fileName? This cannot be undone.';
  }

  @override
  String get deleteMindMapFailed => 'Could not delete';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get selectVaultFolder => 'Choose save folder';

  @override
  String get openVaultMindMaps => 'Open Markdown list';

  @override
  String get createInVault => 'Create Markdown in this folder';

  @override
  String get changeVaultFolder => 'Change save folder';

  @override
  String get vaultConfigured => 'Save folder is set';

  @override
  String get vaultNotConfigured => 'Save folder is not set';

  @override
  String get vaultPermissionLost =>
      'No access to the folder. Choose it again in Settings';

  @override
  String get vaultOnboardingTitle => 'Choose a folder for your thoughts';

  @override
  String get vaultOnboardingBody =>
      'Obmind saves your thoughts as Markdown files. Pick a folder you already use, such as an Obsidian vault. Cancelling does not quit the app.';

  @override
  String get searchMindMaps => 'Search by name or node';

  @override
  String get noSearchResults => 'No matching Markdown files';

  @override
  String get libraryViewList => 'List view';

  @override
  String get libraryViewTiles => 'Tile view';

  @override
  String get autosaveEnabled => 'Autosave';

  @override
  String get savingInProgress => 'Saving';

  @override
  String get layoutMenu => 'Layout';

  @override
  String get layoutHorizontal => 'Horizontal';

  @override
  String get layoutRadial => 'Radial';

  @override
  String get designTemplateMenu => 'Design';

  @override
  String get designTemplatePaper => 'Paper';

  @override
  String get designTemplateInkwell => 'Ink';

  @override
  String get designTemplateDark => 'Dark';

  @override
  String get designTemplateMinimal => 'Minimal';

  @override
  String get appAbout => 'About';

  @override
  String get openSourceLicenses => 'Open-source licenses';

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get privacyPolicyBody =>
      'Obmind is a local-first mind map app with no accounts and no proprietary servers. Your thoughts stay as Markdown files in the folder you choose.\n\nData we do not collect\n\nObmind does not collect personal information such as your name, email address, location, contacts, or advertising IDs. It does not send data for analytics or ads. No account is required.\n\nHow files are handled\n\nMind map content stays on your device and in the save folder you choose. Obmind reads and writes Markdown in that folder only to show, edit, and save maps. It does not access folders you have not chosen.\n\nSettings needed to use the app—such as the save folder location, recent maps, and list view preferences—are stored only on your device. They are never sent to an Obmind server. There is no proprietary server.\n\nSharing with third parties\n\nNeither your thoughts nor on-device settings are sent to third parties. There is no automatic upload to the cloud. Whether files live in another app or cloud service depends on where you placed the folder you chose.\n\nIf you delete the app\n\nUninstalling Obmind leaves Markdown files in the folder you chose. Only app settings stored on the device are removed.';

  @override
  String get languageSettingsTitle => 'Language';

  @override
  String get languageSystem => 'Device language';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get appearanceSettingsTitle => 'Appearance';

  @override
  String get themeSystem => 'Device theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';
}
