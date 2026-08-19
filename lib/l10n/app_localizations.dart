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
  /// **'Markdownを正本とする、Local-firstなマインドマップアプリです。'**
  String get homeMessage;

  /// No description provided for @pickFolderAndCreateMarkdown.
  ///
  /// In ja, this message translates to:
  /// **'フォルダを選んでMarkdownを作成'**
  String get pickFolderAndCreateMarkdown;

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

  /// No description provided for @openMarkdown.
  ///
  /// In ja, this message translates to:
  /// **'Markdownを開いて編集'**
  String get openMarkdown;

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
