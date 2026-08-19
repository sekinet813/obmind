// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Obmind';

  @override
  String get homeMessage => 'Markdownを正本とする、Local-firstなマインドマップアプリです。';

  @override
  String get pickFolderAndCreateMarkdown => 'フォルダを選んでMarkdownを作成';

  @override
  String get folderPickCancelled => 'フォルダ選択をキャンセルしました';

  @override
  String get folderPickFailed => 'フォルダの選択または保存に失敗しました';

  @override
  String markdownCreated(String fileName) {
    return '$fileNameを作成しました';
  }

  @override
  String get openMarkdown => 'Markdownを開いて編集';

  @override
  String get saveMarkdown => '保存';

  @override
  String get markdownSaved => '保存しました';

  @override
  String get markdownSaveFailed => '保存に失敗しました。元のファイルは空にしていません';

  @override
  String get noMarkdownFiles => 'このフォルダにMarkdownがありません';

  @override
  String get editMarkdownHint => 'Markdown';

  @override
  String get addChildNode => '子を追加';

  @override
  String get addSiblingNode => '兄弟を追加';

  @override
  String get newNodeText => '新しいノード';

  @override
  String get deleteNode => '削除';
}
