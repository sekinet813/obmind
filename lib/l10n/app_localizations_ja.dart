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
  String get mindMapLoadFailed => 'マインドマップとして読み込めませんでした';

  @override
  String get mindMapReadOnlyUnsupported => '未対応のMarkdown内容があるため、上書き保存できません';

  @override
  String get mindMapExternalChangeBlocked => 'ファイルが外部で変更されたため、上書き保存を停止しました';

  @override
  String get recentMindMaps => '最近開いた地図';

  @override
  String get recentMindMapUnavailable => 'ファイルを開けませんでした。最近の一覧から削除しました';

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

  @override
  String get collapseNode => '折りたたむ';

  @override
  String get expandNode => '展開';

  @override
  String get editNode => '編集';

  @override
  String get doneEditingNode => '完了';

  @override
  String get fitToScreen => '全体表示';

  @override
  String get zoomIn => '拡大';

  @override
  String get zoomOut => '縮小';

  @override
  String get undoEdit => '元に戻す';

  @override
  String get redoEdit => 'やり直す';

  @override
  String get renameMindMap => '名前を変更';

  @override
  String get renameMindMapHint => 'ファイル名';

  @override
  String get renameMindMapFailed => '名前を変更できませんでした';

  @override
  String get renameMindMapInvalidName => '使えないファイル名です';

  @override
  String get renameMindMapDuplicateName => '同じ名前のファイルがあります';

  @override
  String get deleteMindMap => '削除';

  @override
  String deleteMindMapConfirm(String fileName) {
    return '$fileNameを削除しますか？この操作は取り消せません。';
  }

  @override
  String get deleteMindMapFailed => '削除できませんでした';

  @override
  String get settingsTitle => '設定';

  @override
  String get selectVaultFolder => '正本フォルダを選ぶ';

  @override
  String get openVaultMindMaps => 'Markdown一覧を開く';

  @override
  String get createInVault => 'このフォルダにMarkdownを作成';

  @override
  String get changeVaultFolder => '正本フォルダを変更';

  @override
  String get vaultConfigured => '正本フォルダは設定済みです';

  @override
  String get vaultNotConfigured => '正本フォルダが未設定です';

  @override
  String get vaultPermissionLost => 'フォルダへのアクセス権限がありません。設定から選び直してください';

  @override
  String get vaultOnboardingTitle => '思考の正本フォルダを選ぶ';

  @override
  String get vaultOnboardingBody =>
      'ObmindはMarkdownファイルを正本にします。ObsidianのVaultなど、普段使っているフォルダを選んでください。キャンセルしてもアプリは終了しません。';

  @override
  String get searchMindMaps => 'ファイル名で検索';

  @override
  String get noSearchResults => '該当するMarkdownがありません';

  @override
  String get autosaveEnabled => '自動保存';

  @override
  String get savingInProgress => '保存中';
}
