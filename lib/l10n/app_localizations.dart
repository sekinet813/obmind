import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ja')];

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'Obmind'**
  String get appTitle;

  /// No description provided for @homeMessage.
  ///
  /// In ja, this message translates to:
  /// **'思考はMarkdownファイルとして残る、Local-firstなマインドマップアプリです。'**
  String get homeMessage;

  /// No description provided for @folderPickCancelled.
  ///
  /// In ja, this message translates to:
  /// **'フォルダ選択をキャンセルしました'**
  String get folderPickCancelled;

  /// No description provided for @folderPickFailed.
  ///
  /// In ja, this message translates to:
  /// **'フォルダの選択または保存に失敗しました'**
  String get folderPickFailed;

  /// No description provided for @markdownCreated.
  ///
  /// In ja, this message translates to:
  /// **'{fileName}を作成しました'**
  String markdownCreated(String fileName);

  /// No description provided for @saveMarkdown.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get saveMarkdown;

  /// No description provided for @markdownSaved.
  ///
  /// In ja, this message translates to:
  /// **'保存しました'**
  String get markdownSaved;

  /// No description provided for @markdownSaveFailed.
  ///
  /// In ja, this message translates to:
  /// **'保存に失敗しました。元のファイルは空にしていません'**
  String get markdownSaveFailed;

  /// No description provided for @mindMapLoadFailed.
  ///
  /// In ja, this message translates to:
  /// **'マインドマップとして読み込めませんでした'**
  String get mindMapLoadFailed;

  /// No description provided for @mindMapReadOnlyUnsupported.
  ///
  /// In ja, this message translates to:
  /// **'未対応のMarkdown内容があるため、上書き保存できません'**
  String get mindMapReadOnlyUnsupported;

  /// No description provided for @mindMapExternalChangeBlocked.
  ///
  /// In ja, this message translates to:
  /// **'ファイルが外部で変更されたため、上書き保存を停止しました'**
  String get mindMapExternalChangeBlocked;

  /// No description provided for @recentMindMaps.
  ///
  /// In ja, this message translates to:
  /// **'最近開いた地図'**
  String get recentMindMaps;

  /// No description provided for @recentMindMapUnavailable.
  ///
  /// In ja, this message translates to:
  /// **'ファイルを開けませんでした。最近の一覧から削除しました'**
  String get recentMindMapUnavailable;

  /// No description provided for @noMarkdownFiles.
  ///
  /// In ja, this message translates to:
  /// **'このフォルダにMarkdownがありません'**
  String get noMarkdownFiles;

  /// No description provided for @editMarkdownHint.
  ///
  /// In ja, this message translates to:
  /// **'Markdown'**
  String get editMarkdownHint;

  /// No description provided for @addChildNode.
  ///
  /// In ja, this message translates to:
  /// **'子を追加'**
  String get addChildNode;

  /// No description provided for @addSiblingNode.
  ///
  /// In ja, this message translates to:
  /// **'兄弟を追加'**
  String get addSiblingNode;

  /// No description provided for @newNodeText.
  ///
  /// In ja, this message translates to:
  /// **'新しいノード'**
  String get newNodeText;

  /// No description provided for @deleteNode.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get deleteNode;

  /// No description provided for @collapseNode.
  ///
  /// In ja, this message translates to:
  /// **'折りたたむ'**
  String get collapseNode;

  /// No description provided for @expandNode.
  ///
  /// In ja, this message translates to:
  /// **'展開'**
  String get expandNode;

  /// No description provided for @editNode.
  ///
  /// In ja, this message translates to:
  /// **'編集'**
  String get editNode;

  /// No description provided for @doneEditingNode.
  ///
  /// In ja, this message translates to:
  /// **'完了'**
  String get doneEditingNode;

  /// No description provided for @fitToScreen.
  ///
  /// In ja, this message translates to:
  /// **'全体表示'**
  String get fitToScreen;

  /// No description provided for @centerOnRoot.
  ///
  /// In ja, this message translates to:
  /// **'中心へ戻る'**
  String get centerOnRoot;

  /// No description provided for @zoomIn.
  ///
  /// In ja, this message translates to:
  /// **'拡大'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In ja, this message translates to:
  /// **'縮小'**
  String get zoomOut;

  /// No description provided for @undoEdit.
  ///
  /// In ja, this message translates to:
  /// **'元に戻す'**
  String get undoEdit;

  /// No description provided for @redoEdit.
  ///
  /// In ja, this message translates to:
  /// **'やり直す'**
  String get redoEdit;

  /// No description provided for @renameMindMap.
  ///
  /// In ja, this message translates to:
  /// **'名前を変更'**
  String get renameMindMap;

  /// No description provided for @renameMindMapHint.
  ///
  /// In ja, this message translates to:
  /// **'ファイル名'**
  String get renameMindMapHint;

  /// No description provided for @renameMindMapFailed.
  ///
  /// In ja, this message translates to:
  /// **'名前を変更できませんでした'**
  String get renameMindMapFailed;

  /// No description provided for @renameMindMapInvalidName.
  ///
  /// In ja, this message translates to:
  /// **'使えないファイル名です'**
  String get renameMindMapInvalidName;

  /// No description provided for @renameMindMapDuplicateName.
  ///
  /// In ja, this message translates to:
  /// **'同じ名前のファイルがあります'**
  String get renameMindMapDuplicateName;

  /// No description provided for @deleteMindMap.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get deleteMindMap;

  /// No description provided for @deleteMindMapConfirm.
  ///
  /// In ja, this message translates to:
  /// **'{fileName}を削除しますか？この操作は取り消せません。'**
  String deleteMindMapConfirm(String fileName);

  /// No description provided for @deleteMindMapFailed.
  ///
  /// In ja, this message translates to:
  /// **'削除できませんでした'**
  String get deleteMindMapFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settingsTitle;

  /// No description provided for @selectVaultFolder.
  ///
  /// In ja, this message translates to:
  /// **'保存フォルダを選ぶ'**
  String get selectVaultFolder;

  /// No description provided for @openVaultMindMaps.
  ///
  /// In ja, this message translates to:
  /// **'Markdown一覧を開く'**
  String get openVaultMindMaps;

  /// No description provided for @createInVault.
  ///
  /// In ja, this message translates to:
  /// **'このフォルダにMarkdownを作成'**
  String get createInVault;

  /// No description provided for @changeVaultFolder.
  ///
  /// In ja, this message translates to:
  /// **'保存フォルダを変更'**
  String get changeVaultFolder;

  /// No description provided for @vaultConfigured.
  ///
  /// In ja, this message translates to:
  /// **'保存フォルダは設定済みです'**
  String get vaultConfigured;

  /// No description provided for @vaultNotConfigured.
  ///
  /// In ja, this message translates to:
  /// **'保存フォルダが未設定です'**
  String get vaultNotConfigured;

  /// No description provided for @vaultPermissionLost.
  ///
  /// In ja, this message translates to:
  /// **'フォルダへのアクセス権限がありません。設定から選び直してください'**
  String get vaultPermissionLost;

  /// No description provided for @vaultOnboardingTitle.
  ///
  /// In ja, this message translates to:
  /// **'思考の保存フォルダを選ぶ'**
  String get vaultOnboardingTitle;

  /// No description provided for @vaultOnboardingBody.
  ///
  /// In ja, this message translates to:
  /// **'Obmindは思考をMarkdownファイルとして保存します。ObsidianのVaultなど、普段使っているフォルダを選んでください。キャンセルしてもアプリは終了しません。'**
  String get vaultOnboardingBody;

  /// No description provided for @searchMindMaps.
  ///
  /// In ja, this message translates to:
  /// **'名前やノードで検索'**
  String get searchMindMaps;

  /// No description provided for @noSearchResults.
  ///
  /// In ja, this message translates to:
  /// **'該当するMarkdownがありません'**
  String get noSearchResults;

  /// No description provided for @libraryViewList.
  ///
  /// In ja, this message translates to:
  /// **'リスト表示'**
  String get libraryViewList;

  /// No description provided for @libraryViewTiles.
  ///
  /// In ja, this message translates to:
  /// **'タイル表示'**
  String get libraryViewTiles;

  /// No description provided for @autosaveEnabled.
  ///
  /// In ja, this message translates to:
  /// **'自動保存'**
  String get autosaveEnabled;

  /// No description provided for @savingInProgress.
  ///
  /// In ja, this message translates to:
  /// **'保存中'**
  String get savingInProgress;

  /// No description provided for @layoutMenu.
  ///
  /// In ja, this message translates to:
  /// **'レイアウト'**
  String get layoutMenu;

  /// No description provided for @layoutHorizontal.
  ///
  /// In ja, this message translates to:
  /// **'水平'**
  String get layoutHorizontal;

  /// No description provided for @layoutRadial.
  ///
  /// In ja, this message translates to:
  /// **'放射'**
  String get layoutRadial;

  /// No description provided for @designTemplateMenu.
  ///
  /// In ja, this message translates to:
  /// **'デザイン'**
  String get designTemplateMenu;

  /// No description provided for @designTemplatePaper.
  ///
  /// In ja, this message translates to:
  /// **'ペーパー'**
  String get designTemplatePaper;

  /// No description provided for @designTemplateInkwell.
  ///
  /// In ja, this message translates to:
  /// **'インク'**
  String get designTemplateInkwell;

  /// No description provided for @designTemplateDark.
  ///
  /// In ja, this message translates to:
  /// **'ダーク'**
  String get designTemplateDark;

  /// No description provided for @designTemplateMinimal.
  ///
  /// In ja, this message translates to:
  /// **'ミニマル'**
  String get designTemplateMinimal;

  /// No description provided for @appAbout.
  ///
  /// In ja, this message translates to:
  /// **'アプリ情報'**
  String get appAbout;

  /// No description provided for @openSourceLicenses.
  ///
  /// In ja, this message translates to:
  /// **'オープンソースライセンス'**
  String get openSourceLicenses;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
