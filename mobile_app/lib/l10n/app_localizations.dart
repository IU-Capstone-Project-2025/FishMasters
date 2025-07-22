import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FishMasters'**
  String get appTitle;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'FishMasters is a community-driven app for fishing enthusiasts. Connect with fellow anglers, share your catches, and explore the best fishing spots.'**
  String get appDescription;

  /// No description provided for @homePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FishMasters'**
  String get homePageTitle;

  /// No description provided for @loginText.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginText;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginTitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @needRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get needRegister;

  /// No description provided for @needLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get needLogin;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get registerTitle;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get registerButton;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// No description provided for @registerText.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerText;

  /// No description provided for @startFishingButton.
  ///
  /// In en, this message translates to:
  /// **'GO'**
  String get startFishingButton;

  /// No description provided for @menuText.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuText;

  /// No description provided for @settingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabel;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// No description provided for @darkModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @notificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsLabel;

  /// No description provided for @fontSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSizeLabel;

  /// No description provided for @profileText.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileText;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreLabel;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutButton;

  /// No description provided for @profilePictureEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Picture'**
  String get profilePictureEditTitle;

  /// No description provided for @uploadPictureButton.
  ///
  /// In en, this message translates to:
  /// **'Upload Picture'**
  String get uploadPictureButton;

  /// No description provided for @myCatchText.
  ///
  /// In en, this message translates to:
  /// **'My Catch'**
  String get myCatchText;

  /// No description provided for @notificationsText.
  ///
  /// In en, this message translates to:
  /// **'NotiFISHcations'**
  String get notificationsText;

  /// No description provided for @replyLabel.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get replyLabel;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @russianLanguage.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get russianLanguage;

  /// No description provided for @chatText.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatText;

  /// No description provided for @messagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get messagePlaceholder;

  /// No description provided for @chatLabel.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatLabel;

  /// No description provided for @closeLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// No description provided for @fishingText.
  ///
  /// In en, this message translates to:
  /// **'Fishing'**
  String get fishingText;

  /// No description provided for @fishingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Fishing in progress...'**
  String get fishingInProgress;

  /// No description provided for @stopFishingButton.
  ///
  /// In en, this message translates to:
  /// **'Stop Fishing'**
  String get stopFishingButton;

  /// No description provided for @elapsedTime.
  ///
  /// In en, this message translates to:
  /// **'Elapsed Time'**
  String get elapsedTime;

  /// No description provided for @fishCaught.
  ///
  /// In en, this message translates to:
  /// **'Fish Caught'**
  String get fishCaught;

  /// No description provided for @addFishButton.
  ///
  /// In en, this message translates to:
  /// **'Add Fish'**
  String get addFishButton;

  /// No description provided for @uploadFishImageText.
  ///
  /// In en, this message translates to:
  /// **'Upload Fish Image'**
  String get uploadFishImageText;

  /// No description provided for @uploadFishImageButton.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadFishImageButton;

  /// No description provided for @loadingMarkersLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading fishing places...'**
  String get loadingMarkersLabel;

  /// No description provided for @fishingLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Fishing Location'**
  String get fishingLocationLabel;

  /// No description provided for @fishNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get fishNameLabel;

  /// No description provided for @noFishNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload an image to get fish name'**
  String get noFishNameLabel;

  /// No description provided for @loadingFishName.
  ///
  /// In en, this message translates to:
  /// **'Loading fish name...'**
  String get loadingFishName;

  /// No description provided for @manualUploadButton.
  ///
  /// In en, this message translates to:
  /// **'Manual Upload'**
  String get manualUploadButton;

  /// No description provided for @fishDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Fish Description'**
  String get fishDescriptionLabel;

  /// No description provided for @searchByDescriptionButton.
  ///
  /// In en, this message translates to:
  /// **'Search by Description'**
  String get searchByDescriptionButton;

  /// No description provided for @selectFishLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Fish:'**
  String get selectFishLabel;

  /// No description provided for @similarityScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Similarity Score'**
  String get similarityScoreLabel;

  /// No description provided for @searchingFishLabel.
  ///
  /// In en, this message translates to:
  /// **'Searching for fish...'**
  String get searchingFishLabel;

  /// No description provided for @noResultsFoundLabel.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFoundLabel;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @uploadButton.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get uploadButton;

  /// No description provided for @noDiscussionTitle.
  ///
  /// In en, this message translates to:
  /// **'No discussion'**
  String get noDiscussionTitle;

  /// No description provided for @noDiscussionContent.
  ///
  /// In en, this message translates to:
  /// **'There are no discussions available for this water body. Want to start one?'**
  String get noDiscussionContent;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @createDiscussionLabel.
  ///
  /// In en, this message translates to:
  /// **'Create Discussion'**
  String get createDiscussionLabel;

  /// No description provided for @errorCreatingDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Error creating discussion'**
  String get errorCreatingDiscussion;

  /// No description provided for @leaderboardText.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardText;

  /// No description provided for @searchPlayersPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search players by name or email...'**
  String get searchPlayersPlaceholder;

  /// No description provided for @backToTopButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Top'**
  String get backToTopButton;

  /// No description provided for @findMeButton.
  ///
  /// In en, this message translates to:
  /// **'Find Me'**
  String get findMeButton;

  /// No description provided for @top10Badge.
  ///
  /// In en, this message translates to:
  /// **'TOP 10'**
  String get top10Badge;

  /// No description provided for @pointsLabel.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get pointsLabel;

  /// No description provided for @searchingLabel.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searchingLabel;

  /// No description provided for @playerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Player not found'**
  String get playerNotFound;

  /// No description provided for @loadingLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Loading leaderboard...'**
  String get loadingLeaderboard;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Dark mode enabled'**
  String get darkModeEnabled;

  /// No description provided for @lightModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Ligth mode enabled'**
  String get lightModeEnabled;

  /// No description provided for @useSystemTheme.
  ///
  /// In en, this message translates to:
  /// **'Use System Theme'**
  String get useSystemTheme;

  /// No description provided for @systemModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'System mode enabled'**
  String get systemModeEnabled;

  /// No description provided for @lessThan.
  ///
  /// In en, this message translates to:
  /// **'Less than an'**
  String get lessThan;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @noFishCaught.
  ///
  /// In en, this message translates to:
  /// **'No fish caught'**
  String get noFishCaught;

  /// No description provided for @noFishCaughtYet.
  ///
  /// In en, this message translates to:
  /// **'No fish caught yet'**
  String get noFishCaughtYet;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @allCaughtFish.
  ///
  /// In en, this message translates to:
  /// **'All caught fish'**
  String get allCaughtFish;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @ongoingSession.
  ///
  /// In en, this message translates to:
  /// **'Ongoing session'**
  String get ongoingSession;

  /// No description provided for @saveLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose this location for fishing'**
  String get saveLocationLabel;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
