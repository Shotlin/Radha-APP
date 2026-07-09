import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
    Locale('ta'),
    Locale('te'),
  ];

  /// App name (brand mark, do not translate).
  ///
  /// In en, this message translates to:
  /// **'RADHA'**
  String get appName;

  /// One-line app tagline shown on splash and onboarding.
  ///
  /// In en, this message translates to:
  /// **'Retail Assistant for Data, Health & Audits.'**
  String get tagline;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumber;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'We sent you a 6-digit code'**
  String get otpSent;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @expiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get expiry;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @scanProduct.
  ///
  /// In en, this message translates to:
  /// **'Scan a product'**
  String get scanProduct;

  /// No description provided for @pointAtBarcode.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at a barcode'**
  String get pointAtBarcode;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get scanAgain;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @expiryTracker.
  ///
  /// In en, this message translates to:
  /// **'Expiry tracker'**
  String get expiryTracker;

  /// No description provided for @addExpiry.
  ///
  /// In en, this message translates to:
  /// **'Add expiry'**
  String get addExpiry;

  /// No description provided for @expiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get expiringSoon;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @yourTasks.
  ///
  /// In en, this message translates to:
  /// **'Your tasks'**
  String get yourTasks;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasks;

  /// No description provided for @completeTask.
  ///
  /// In en, this message translates to:
  /// **'Complete task'**
  String get completeTask;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Scan, track, audit your stock without the spreadsheets.'**
  String get welcomeMessage;

  /// No description provided for @referrals.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get referrals;

  /// No description provided for @shareYourCode.
  ///
  /// In en, this message translates to:
  /// **'Share your code'**
  String get shareYourCode;

  /// No description provided for @yourReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Your referral code'**
  String get yourReferralCode;

  /// No description provided for @invitees.
  ///
  /// In en, this message translates to:
  /// **'Invitees'**
  String get invitees;

  /// No description provided for @rewardsEarned.
  ///
  /// In en, this message translates to:
  /// **'Rewards earned'**
  String get rewardsEarned;

  /// No description provided for @redeemCode.
  ///
  /// In en, this message translates to:
  /// **'Redeem code'**
  String get redeemCode;

  /// No description provided for @enterReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Enter a referral code'**
  String get enterReferralCode;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageUpdated;

  /// Fallback error shown when the backend returns no recognised code.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// OTP rate limit (HTTP 429) — backend code E3007 or generic E1004.
  ///
  /// In en, this message translates to:
  /// **'Too many OTP requests. Try again in {seconds} seconds.'**
  String errorRateLimitOtp(int seconds);

  /// OTP did not verify (E3005).
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please try again.'**
  String get errorOtpInvalid;

  /// OTP request window elapsed (E3006).
  ///
  /// In en, this message translates to:
  /// **'OTP expired. Please request a new one.'**
  String get errorOtpExpired;

  /// Session missing / token expired (E3000, E3002).
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get errorAuthRequired;

  /// Generic 404 (E5000).
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get errorNotFound;

  /// Title shown when fetching an ingredient explanation fails (FE-19).
  ///
  /// In en, this message translates to:
  /// **'Could not load explanation'**
  String get ingredientExplainerErrorTitle;

  /// Section header above the bullet list on the ingredient explainer screen (FE-19).
  ///
  /// In en, this message translates to:
  /// **'Health considerations'**
  String get ingredientExplainerHealthConsiderations;

  /// AppBar title on the healthy alternatives screen (FE-22) when the source product name is known.
  ///
  /// In en, this message translates to:
  /// **'Better choices than {productName}'**
  String healthyAlternativesTitle(String productName);

  /// AppBar title on the healthy alternatives screen (FE-22) when the source product name is unavailable.
  ///
  /// In en, this message translates to:
  /// **'Better choices'**
  String get healthyAlternativesGenericTitle;

  /// Empty-state title on the healthy alternatives screen (FE-22).
  ///
  /// In en, this message translates to:
  /// **'No healthier alternatives yet'**
  String get healthyAlternativesEmptyTitle;

  /// Empty-state body on the healthy alternatives screen (FE-22).
  ///
  /// In en, this message translates to:
  /// **'No healthier alternatives found in the same category yet.'**
  String get healthyAlternativesEmptyBody;

  /// Error-state title on the healthy alternatives screen (FE-22).
  ///
  /// In en, this message translates to:
  /// **'Could not load alternatives'**
  String get healthyAlternativesErrorTitle;

  /// CTA on each alternative card to add the item to the shopping list (FE-22).
  ///
  /// In en, this message translates to:
  /// **'Add to shopping list'**
  String get healthyAlternativesAddToList;

  /// Primary CTA on each alternative card to open the product's scan-result page (FE-22).
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get healthyAlternativesView;

  /// Snackbar confirmation after adding an alternative to the shopping list (FE-22).
  ///
  /// In en, this message translates to:
  /// **'Added to your shopping list'**
  String get healthyAlternativesAddedToList;

  /// Snackbar shown when adding an alternative to the shopping list fails (FE-22).
  ///
  /// In en, this message translates to:
  /// **'Could not add to shopping list'**
  String get healthyAlternativesAddFailed;

  /// AppBar title on the saved products screen (FE-16).
  ///
  /// In en, this message translates to:
  /// **'Saved products'**
  String get savedProductsTitle;

  /// Empty-state title on the saved products screen (FE-16).
  ///
  /// In en, this message translates to:
  /// **'Saved products'**
  String get savedProductsEmptyTitle;

  /// Empty-state body on the saved products screen (FE-16).
  ///
  /// In en, this message translates to:
  /// **'Save products from the scan result screen to see them here.'**
  String get savedProductsEmptyBody;

  /// Error-state title on the saved products screen (FE-16).
  ///
  /// In en, this message translates to:
  /// **'Could not load saved products'**
  String get savedProductsErrorTitle;

  /// Subtitle showing when a saved product was bookmarked (FE-16).
  ///
  /// In en, this message translates to:
  /// **'Saved {date}'**
  String savedProductsSavedOn(String date);

  /// Hero headline on the weekly digest landing screen (FE-24).
  ///
  /// In en, this message translates to:
  /// **'Your week with RADHA'**
  String get digestTitle;

  /// Subtitle below the digest hero showing the week range, e.g. 'May 19 – May 25, 2026' (FE-24).
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String digestWeekRange(String start, String end);

  /// Hero metric on the weekly digest when estimated savings is greater than zero (FE-24).
  ///
  /// In en, this message translates to:
  /// **'₹{amount} saved'**
  String digestSavingsHero(String amount);

  /// Hero metric on the weekly digest when savings is zero — falls back to scan count (FE-24).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 scan} other{{count} scans}}'**
  String digestScansHero(int count);

  /// Hero metric headline shown when the user has no activity for the week (FE-24).
  ///
  /// In en, this message translates to:
  /// **'A quiet week'**
  String get digestHeroEmptyHeadline;

  /// Stat label for total scans (FE-24).
  ///
  /// In en, this message translates to:
  /// **'Scans'**
  String get digestScans;

  /// Stat label for saved products count (FE-24).
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get digestSavedProducts;

  /// Stat label for items expiring this week (FE-24).
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get digestExpiringSoon;

  /// Headline on the recall alerts call-out card (FE-24).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recall alert} other{{count} recall alerts}}'**
  String digestRecallAlerts(int count);

  /// Body copy on the recall alerts call-out card (FE-24).
  ///
  /// In en, this message translates to:
  /// **'Products you scanned this week have new safety advisories.'**
  String get digestRecallAlertsBody;

  /// CTA on the recall alerts call-out card linking to /recall-alerts (FE-24).
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get digestRecallAlertsCta;

  /// Section header above the top categories bar list (FE-24).
  ///
  /// In en, this message translates to:
  /// **'What you\'re scanning'**
  String get digestTopCategoriesHeader;

  /// Section header above the health highlights bullet list (FE-24).
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get digestHighlightsHeader;

  /// Primary CTA in the digest action footer routing to /scan (FE-24).
  ///
  /// In en, this message translates to:
  /// **'Continue scanning'**
  String get digestContinueScanning;

  /// Secondary text CTA in the digest footer that opens the native share sheet (FE-24).
  ///
  /// In en, this message translates to:
  /// **'Share my week'**
  String get digestShare;

  /// Body of the native share intent fired from the weekly digest screen (FE-24).
  ///
  /// In en, this message translates to:
  /// **'I scanned {scans} products this week and saved ₹{savings} with RADHA. Try it: https://radha.app'**
  String digestShareTemplate(int scans, String savings);

  /// Empty-state title on the weekly digest screen (FE-24).
  ///
  /// In en, this message translates to:
  /// **'No activity this week'**
  String get digestEmptyTitle;

  /// Empty-state body on the weekly digest screen (FE-24).
  ///
  /// In en, this message translates to:
  /// **'Start scanning to build your weekly story.'**
  String get digestEmptyBody;

  /// Error-state title on the weekly digest screen (FE-24).
  ///
  /// In en, this message translates to:
  /// **'Could not load your weekly digest'**
  String get digestErrorTitle;

  /// AppBar title for the Settings hub (FE-32).
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Notifications section header in Settings hub (FE-32).
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get settingsPushNotifications;

  /// No description provided for @settingsPushNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Get alerts on your phone'**
  String get settingsPushNotificationsHint;

  /// No description provided for @settingsRecallAlerts.
  ///
  /// In en, this message translates to:
  /// **'Recall alerts'**
  String get settingsRecallAlerts;

  /// No description provided for @settingsRecallAlertsHint.
  ///
  /// In en, this message translates to:
  /// **'Be told when a product you scanned is recalled'**
  String get settingsRecallAlertsHint;

  /// No description provided for @settingsWeeklyDigest.
  ///
  /// In en, this message translates to:
  /// **'Weekly digest'**
  String get settingsWeeklyDigest;

  /// No description provided for @settingsWeeklyDigestHint.
  ///
  /// In en, this message translates to:
  /// **'Sunday summary of your scans and savings'**
  String get settingsWeeklyDigestHint;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get settingsTextSize;

  /// No description provided for @settingsTextSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get settingsTextSizeSmall;

  /// No description provided for @settingsTextSizeStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get settingsTextSizeStandard;

  /// No description provided for @settingsTextSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get settingsTextSizeLarge;

  /// No description provided for @settingsDataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & privacy'**
  String get settingsDataPrivacy;

  /// No description provided for @settingsAllergens.
  ///
  /// In en, this message translates to:
  /// **'Allergen profile'**
  String get settingsAllergens;

  /// No description provided for @settingsAllergensHint.
  ///
  /// In en, this message translates to:
  /// **'Pick the ingredients we should warn you about'**
  String get settingsAllergensHint;

  /// No description provided for @settingsSignOutAll.
  ///
  /// In en, this message translates to:
  /// **'Sign out from all devices'**
  String get settingsSignOutAll;

  /// No description provided for @settingsSignOutAllConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out everywhere?'**
  String get settingsSignOutAllConfirmTitle;

  /// No description provided for @settingsSignOutAllConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again on every device that uses this account.'**
  String get settingsSignOutAllConfirmBody;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your data. Type DELETE to confirm.'**
  String get settingsDeleteAccountBody;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsDeleteAccountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Contact support to delete your account.'**
  String get settingsDeleteAccountUnavailable;

  /// No description provided for @settingsDeleteAccountContact.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get settingsDeleteAccountContact;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get settingsTerms;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settingsVersion;

  /// Subtitle on the App version row in Settings hub.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String settingsVersionValue(String version, String build);

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @settingsSupportHint.
  ///
  /// In en, this message translates to:
  /// **'Get help, report a bug, or share feedback'**
  String get settingsSupportHint;

  /// No description provided for @settingsLinkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get settingsLinkOpenFailed;

  /// Sticky banner shown when the offline queue has unresolved sync conflicts (FE-34).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 conflict needs your attention} other{{count} conflicts need your attention}}'**
  String conflictBannerCount(int count);

  /// No description provided for @conflictBannerCta.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get conflictBannerCta;

  /// No description provided for @conflictBannerDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get conflictBannerDismiss;

  /// No description provided for @conflictResolveTitle.
  ///
  /// In en, this message translates to:
  /// **'Resolve sync conflicts'**
  String get conflictResolveTitle;

  /// No description provided for @conflictResolveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick which version to keep for each item.'**
  String get conflictResolveSubtitle;

  /// No description provided for @conflictUseMine.
  ///
  /// In en, this message translates to:
  /// **'Use my version'**
  String get conflictUseMine;

  /// No description provided for @conflictUseServer.
  ///
  /// In en, this message translates to:
  /// **'Use server version'**
  String get conflictUseServer;

  /// No description provided for @conflictResolved.
  ///
  /// In en, this message translates to:
  /// **'Conflict resolved'**
  String get conflictResolved;

  /// No description provided for @conflictResolvedAll.
  ///
  /// In en, this message translates to:
  /// **'All conflicts resolved'**
  String get conflictResolvedAll;

  /// Sub-label on a conflict card showing how many sync attempts have been made.
  ///
  /// In en, this message translates to:
  /// **'Tried {count, plural, =1{1 time} other{{count} times}}'**
  String conflictAttempts(int count);

  /// No description provided for @conflictResourceTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get conflictResourceTask;

  /// No description provided for @conflictResourceExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry record'**
  String get conflictResourceExpiry;

  /// No description provided for @conflictResourceScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get conflictResourceScan;

  /// No description provided for @conflictResourceInventory.
  ///
  /// In en, this message translates to:
  /// **'Stock adjustment'**
  String get conflictResourceInventory;

  /// No description provided for @conflictResourceGrn.
  ///
  /// In en, this message translates to:
  /// **'GRN entry'**
  String get conflictResourceGrn;

  /// No description provided for @conflictResourceShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping list item'**
  String get conflictResourceShoppingList;

  /// No description provided for @conflictResourceGeneric.
  ///
  /// In en, this message translates to:
  /// **'Sync change'**
  String get conflictResourceGeneric;

  /// One-line summary of the user's local edit shown on a conflict card (FE-34).
  ///
  /// In en, this message translates to:
  /// **'Your change: {summary}'**
  String conflictLocalChangeSummary(String summary);

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTitle;

  /// No description provided for @supportContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get supportContactUs;

  /// No description provided for @supportEmailUs.
  ///
  /// In en, this message translates to:
  /// **'Email us'**
  String get supportEmailUs;

  /// No description provided for @supportEmailUsHint.
  ///
  /// In en, this message translates to:
  /// **'support@radha.app'**
  String get supportEmailUsHint;

  /// No description provided for @supportCallUs.
  ///
  /// In en, this message translates to:
  /// **'Call support'**
  String get supportCallUs;

  /// No description provided for @supportCallUsHint.
  ///
  /// In en, this message translates to:
  /// **'Mon–Fri, 9am–6pm IST'**
  String get supportCallUsHint;

  /// No description provided for @supportReportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get supportReportBug;

  /// No description provided for @supportBugDescription.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get supportBugDescription;

  /// No description provided for @supportBugDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what you were doing when it broke.'**
  String get supportBugDescriptionHint;

  /// No description provided for @supportAttachScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Attach screenshot'**
  String get supportAttachScreenshot;

  /// No description provided for @supportScreenshotAttached.
  ///
  /// In en, this message translates to:
  /// **'Screenshot attached'**
  String get supportScreenshotAttached;

  /// No description provided for @supportRemoveScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get supportRemoveScreenshot;

  /// No description provided for @supportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get supportSubmit;

  /// No description provided for @supportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thanks — we received your report.'**
  String get supportSubmitted;

  /// No description provided for @supportSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send. Please email us instead.'**
  String get supportSubmitFailed;

  /// No description provided for @supportBugDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please describe what happened.'**
  String get supportBugDescriptionRequired;

  /// No description provided for @supportFaq.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get supportFaq;

  /// No description provided for @supportFaqQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I scan a barcode?'**
  String get supportFaqQ1;

  /// No description provided for @supportFaqA1.
  ///
  /// In en, this message translates to:
  /// **'Open the Scan tab, point your camera at the barcode, and hold steady. We\'ll find the product the moment we read a clean code.'**
  String get supportFaqA1;

  /// No description provided for @supportFaqQ2.
  ///
  /// In en, this message translates to:
  /// **'What if a product isn\'t in the database?'**
  String get supportFaqQ2;

  /// No description provided for @supportFaqA2.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add product\" on the not-found screen and we\'ll create a new entry tied to your store. The catalog grows for everyone over time.'**
  String get supportFaqA2;

  /// No description provided for @supportFaqQ3.
  ///
  /// In en, this message translates to:
  /// **'How do I cancel my subscription?'**
  String get supportFaqQ3;

  /// No description provided for @supportFaqA3.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile → Subscription. You can cancel anytime; we don\'t charge after the next billing cycle starts.'**
  String get supportFaqA3;

  /// No description provided for @supportFaqQ4.
  ///
  /// In en, this message translates to:
  /// **'Why am I seeing a recall alert?'**
  String get supportFaqQ4;

  /// No description provided for @supportFaqA4.
  ///
  /// In en, this message translates to:
  /// **'We match every scan against the FSSAI recall feed. If a batch you sold is on the list, we surface it so you can pull stock and notify customers.'**
  String get supportFaqA4;

  /// No description provided for @supportFaqQ5.
  ///
  /// In en, this message translates to:
  /// **'How do I share my allergen profile with family?'**
  String get supportFaqQ5;

  /// No description provided for @supportFaqA5.
  ///
  /// In en, this message translates to:
  /// **'Allergen profiles are per-account today. Share them with family by signing in on the same household account, or pick the same allergens on each phone.'**
  String get supportFaqA5;

  /// AppBar title on the Reports & Exports screen (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Reports & exports'**
  String get reportsTitle;

  /// Tab label for the Available section (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get reportsTabAvailable;

  /// Tab label for the Scheduled section (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get reportsTabScheduled;

  /// Tab label for the History section (FE-30).
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get reportsTabHistory;

  /// Section header above the 2x2 quick-exports grid (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Quick exports'**
  String get reportsQuickExportsHeader;

  /// Quick-export tile title for the inventory snapshot (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Inventory snapshot'**
  String get reportsInventorySnapshot;

  /// Quick-export tile title for the expiring items report (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Expiring items'**
  String get reportsExpiringItems;

  /// Quick-export tile title for the sales summary (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Sales summary'**
  String get reportsSalesSummary;

  /// Quick-export tile title for the audit log (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get reportsAuditLog;

  /// Primary CTA in the export config bottom sheet (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get reportsGenerate;

  /// Snackbar confirming the export download was opened (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Report ready'**
  String get reportsGenerateSuccess;

  /// Snackbar shown when a generate request was accepted but the file isn't downloadable yet (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Generation started — we\'ll notify you when it\'s ready'**
  String get reportsGenerateQueued;

  /// Snackbar shown when the generate API call fails outright (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Could not start the report'**
  String get reportsGenerateFailed;

  /// Snackbar shown when the presigned URL fails to launch (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Could not open the download'**
  String get reportsDownloadFailed;

  /// FAB label on the Scheduled tab (FE-30).
  ///
  /// In en, this message translates to:
  /// **'New schedule'**
  String get reportsScheduleNew;

  /// Primary CTA in the scheduler bottom sheet (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Create schedule'**
  String get reportsScheduleCreate;

  /// Snackbar confirming a new recurring schedule was created (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Schedule created'**
  String get reportsScheduleSuccess;

  /// Section label in the scheduler bottom sheet selecting which report to schedule (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportsScheduleReportLabel;

  /// Section label in the scheduler bottom sheet selecting which weekday to fire on (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Day of week'**
  String get reportsScheduleDayOfWeek;

  /// Section label in the scheduler bottom sheet selecting which day of the month to fire on (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Day of month'**
  String get reportsScheduleDayOfMonth;

  /// Section label in the scheduler bottom sheet selecting the hour to fire (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reportsScheduleTime;

  /// Section label in the scheduler bottom sheet selecting the export format (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get reportsScheduleFormat;

  /// Tooltip on the per-row schedule actions menu (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Schedule actions'**
  String get reportsScheduleActionsTooltip;

  /// Section label in the scheduler bottom sheet selecting how often the report fires (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get reportsFrequency;

  /// Daily-frequency choice (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get reportsFrequencyDaily;

  /// Weekly-frequency choice (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get reportsFrequencyWeekly;

  /// Monthly-frequency choice (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get reportsFrequencyMonthly;

  /// Per-row action label that pauses a recurring schedule (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get reportsPause;

  /// Per-row action label that resumes a paused schedule (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get reportsResume;

  /// Per-row destructive action label for a recurring schedule (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get reportsDelete;

  /// Confirmation dialog title shown before cancelling a recurring schedule (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Delete schedule?'**
  String get reportsDeleteScheduleTitle;

  /// Confirmation dialog body for cancelling a recurring schedule (FE-30).
  ///
  /// In en, this message translates to:
  /// **'This recurring schedule will stop firing. Past runs stay in your history.'**
  String get reportsDeleteScheduleBody;

  /// Subtitle on a scheduled-report row showing when the schedule last fired (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Last run {when}'**
  String reportsLastRun(String when);

  /// Subtitle on a scheduled-report row that hasn't fired yet (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Hasn\'t run yet'**
  String get reportsLastRunNever;

  /// Subtitle on a scheduled-report row showing the next firing time (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Next run {when}'**
  String reportsNextRun(String when);

  /// Tooltip / label on a per-row download icon button on the History tab (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get reportsDownload;

  /// Status pill label for a completed report (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get reportsStatusCompleted;

  /// Status pill label for a pending or in-flight report (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Generating'**
  String get reportsStatusGenerating;

  /// Status pill label for a failed report (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get reportsStatusFailed;

  /// Status pill label for a cancelled report (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get reportsStatusCancelled;

  /// Status pill label for a report whose artefacts have expired (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get reportsStatusExpired;

  /// Empty-state title on the History tab (FE-30).
  ///
  /// In en, this message translates to:
  /// **'No exports yet'**
  String get reportsEmptyTitle;

  /// Empty-state body on the History tab (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Generate a report from the Available tab and it\'ll show up here.'**
  String get reportsEmptyBody;

  /// Empty-state title on the Scheduled tab (FE-30).
  ///
  /// In en, this message translates to:
  /// **'No scheduled reports'**
  String get reportsScheduledEmptyTitle;

  /// Empty-state body on the Scheduled tab (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Tap New schedule to have a report run automatically.'**
  String get reportsScheduledEmptyBody;

  /// Error-state title shown when the reports list fails to load (FE-30).
  ///
  /// In en, this message translates to:
  /// **'Could not load reports'**
  String get reportsErrorTitle;

  /// AppBar / hero title on the OHS Dashboard screen (FE-26).
  ///
  /// In en, this message translates to:
  /// **'Operational health'**
  String get ohsTitle;

  /// Eyebrow caption above the headline OHS score (FE-26).
  ///
  /// In en, this message translates to:
  /// **'OHS score'**
  String get ohsScoreCaption;

  /// Headline OHS score, rendered in JetBrains Mono. The placeholder is the integer 0-100 derived from the dashboard summary (FE-26).
  ///
  /// In en, this message translates to:
  /// **'{score}'**
  String ohsScore(int score);

  /// Subtitle below the OHS score when the week-over-week delta is positive (FE-26).
  ///
  /// In en, this message translates to:
  /// **'+{value} from last week'**
  String ohsDeltaUp(int value);

  /// Subtitle below the OHS score when the week-over-week delta is negative (FE-26).
  ///
  /// In en, this message translates to:
  /// **'-{value} from last week'**
  String ohsDeltaDown(int value);

  /// Subtitle below the OHS score when this week matches last week (FE-26).
  ///
  /// In en, this message translates to:
  /// **'No change from last week'**
  String get ohsDeltaSame;

  /// Subtitle below the OHS score when there's no prior week to compare to (FE-26).
  ///
  /// In en, this message translates to:
  /// **'Not enough data for a week-over-week comparison yet'**
  String get ohsDeltaUnavailable;

  /// Bento card label for the compliance dimension (FE-26).
  ///
  /// In en, this message translates to:
  /// **'Compliance'**
  String get ohsCompliance;

  /// Bento card label for the inventory-hygiene dimension (FE-26).
  ///
  /// In en, this message translates to:
  /// **'Inventory hygiene'**
  String get ohsInventoryHygiene;

  /// Bento card label for the audit-completion dimension (FE-26).
  ///
  /// In en, this message translates to:
  /// **'Audit completion'**
  String get ohsAuditCompletion;

  /// Section header above the list of recommended next actions (FE-26).
  ///
  /// In en, this message translates to:
  /// **'Action items'**
  String get ohsActionItemsHeader;

  /// Action-item label that routes to /expiry (FE-26).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expiry alert needs a review} other{{count} expiry alerts need a review}}'**
  String ohsActionExpiry(int count);

  /// Action-item label that routes to /inventory/low-stock-alerts (FE-26).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 low-stock alert is unresolved} other{{count} low-stock alerts are unresolved}}'**
  String ohsActionLowStock(int count);

  /// Action-item label that routes to /tasks (FE-26).
  ///
  /// In en, this message translates to:
  /// **'Review open tasks for your store'**
  String get ohsActionTasks;

  /// Body shown in the action-items area when no callable counters are non-zero (FE-26).
  ///
  /// In en, this message translates to:
  /// **'Everything looks good — keep scanning to maintain your score.'**
  String get ohsActionNoneBody;

  /// Section header above the 7-bar weekly trend (FE-26).
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get ohsTrendHeader;

  /// Primary footer CTA on the OHS dashboard, routing to /reports (FE-26).
  ///
  /// In en, this message translates to:
  /// **'View detailed reports'**
  String get ohsViewDetailedReports;

  /// Empty-state title on the OHS dashboard (FE-26).
  ///
  /// In en, this message translates to:
  /// **'Build your operational health score'**
  String get ohsEmptyTitle;

  /// Empty-state body on the OHS dashboard (FE-26).
  ///
  /// In en, this message translates to:
  /// **'Start scanning to build your OHS score.'**
  String get ohsEmptyBody;

  /// Error-state title on the OHS dashboard (FE-26).
  ///
  /// In en, this message translates to:
  /// **'Could not load your dashboard'**
  String get ohsErrorTitle;

  /// Expiry list segmented tab — items approaching expiry.
  ///
  /// In en, this message translates to:
  /// **'Near-expiry'**
  String get expiryTabNear;

  /// Expiry list segmented tab / pill — items with comfortable shelf life.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get expiryTabSafe;

  /// Tooltip for the calendar-view action on the expiry list.
  ///
  /// In en, this message translates to:
  /// **'Calendar view'**
  String get expiryCalendarTooltip;

  /// Empty-state title on the Expired tab.
  ///
  /// In en, this message translates to:
  /// **'Nothing expired'**
  String get expiryEmptyExpiredTitle;

  /// Empty-state title on the Near-expiry tab.
  ///
  /// In en, this message translates to:
  /// **'All clear'**
  String get expiryEmptyNearTitle;

  /// Empty-state title on the Safe / default expiry tab.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get expiryEmptyDefaultTitle;

  /// Empty-state body shared by all expiry tabs.
  ///
  /// In en, this message translates to:
  /// **'No records in this category.'**
  String get expiryEmptyBody;

  /// Fallback product label using a short id token until product names join server-side.
  ///
  /// In en, this message translates to:
  /// **'Product {id}'**
  String expiryProductShort(String id);

  /// Batch-number chip in the expiry tile subtitle.
  ///
  /// In en, this message translates to:
  /// **'Batch {batch}'**
  String expiryBatch(String batch);

  /// Quantity chip in the expiry tile subtitle.
  ///
  /// In en, this message translates to:
  /// **'Qty {qty}'**
  String expiryQty(String qty);

  /// Expiry-date chip in the expiry tile subtitle.
  ///
  /// In en, this message translates to:
  /// **'Exp {date}'**
  String expiryExp(String date);

  /// Day-count pill when the item expires today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get expiryPillToday;

  /// Day-count pill when the item expires tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get expiryPillTomorrow;

  /// Compact day-count pill, e.g. 5d. The 'd' unit stays latin in all locales for the mono pill.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String expiryPillDays(int days);

  /// Day-count pill fallback when only a near-expiry status is known.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get expiryPillSoon;

  /// Error-state body on the expiry list.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load expiry records.'**
  String get expiryLoadError;

  /// Accessibility label for the error-state companion illustration. Reused across list screens.
  ///
  /// In en, this message translates to:
  /// **'Could not load'**
  String get expiryCouldNotLoadSemantic;

  /// Inventory list screen AppBar title.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryTitle;

  /// Tooltip for the search action on the inventory list.
  ///
  /// In en, this message translates to:
  /// **'Search inventory'**
  String get inventorySearchTooltip;

  /// Placeholder text in the inventory search field.
  ///
  /// In en, this message translates to:
  /// **'Search by product or EAN...'**
  String get inventorySearchHint;

  /// Quick-action button → stock movement ledger.
  ///
  /// In en, this message translates to:
  /// **'Stock Movement'**
  String get inventoryStockMovement;

  /// Quick-action button → low-stock alerts.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alerts'**
  String get inventoryLowStockAlerts;

  /// Error-state body on the inventory list.
  ///
  /// In en, this message translates to:
  /// **'Failed to load inventory'**
  String get inventoryLoadError;

  /// Empty-state text when no inventory items exist.
  ///
  /// In en, this message translates to:
  /// **'No inventory items found'**
  String get inventoryEmpty;

  /// Empty-state text when a search yields no results.
  ///
  /// In en, this message translates to:
  /// **'No matches for \"{query}\"'**
  String inventoryNoMatches(String query);

  /// Fallback product label until product names join server-side.
  ///
  /// In en, this message translates to:
  /// **'Product {id}'**
  String inventoryProductShort(String id);

  /// Status line when quantity is under the low-stock threshold.
  ///
  /// In en, this message translates to:
  /// **'Below threshold'**
  String get inventoryBelowThreshold;

  /// Status line when quantity is at or above the threshold.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inventoryInStock;

  /// Small unit label beneath the quantity number on an inventory tile.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get inventoryUnitsLabel;

  /// Expanded-detail label for total quantity on hand.
  ///
  /// In en, this message translates to:
  /// **'Total quantity'**
  String get inventoryTotalQuantity;

  /// Expanded-detail label for the configured low-stock threshold.
  ///
  /// In en, this message translates to:
  /// **'Low-stock threshold'**
  String get inventoryLowStockThreshold;

  /// Quantity-with-unit value, e.g. 12 units.
  ///
  /// In en, this message translates to:
  /// **'{count} units'**
  String inventoryQtyUnits(int count);

  /// Hint in the expanded inventory detail pointing to the stock-movement ledger.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Stock movement\" to view the full batch ledger.'**
  String get inventoryBatchLedgerHint;

  /// Pill badge shown on tiles below their low-stock threshold.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get inventoryLowStockBadge;

  /// Tasks list screen AppBar title.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// Tasks filter tab — tasks assigned to the current user.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get tasksTabMine;

  /// Tasks filter tab — all tasks regardless of assignee.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tasksTabAll;

  /// Manager-only FAB label to create a task.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get tasksNewTask;

  /// Empty-state title on a tasks tab.
  ///
  /// In en, this message translates to:
  /// **'No tasks here'**
  String get tasksEmptyTitle;

  /// Empty-state body on a tasks tab.
  ///
  /// In en, this message translates to:
  /// **'Tasks assigned to this view will show up here.'**
  String get tasksEmptyBody;

  /// Error-state body on the tasks list.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tasks'**
  String get tasksLoadError;

  /// Meta chip indicating a task requires photo evidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get taskEvidence;

  /// Shared severity label — high priority.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// Shared severity label — medium priority.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// Shared severity label — low priority.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// Shared severity label — urgent priority.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

  /// Task status label — open / default.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get taskStatusOpen;

  /// Task status label — pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get taskStatusPending;

  /// Task status label — in progress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get taskStatusInProgress;

  /// Task status label / Completed filter tab.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskStatusCompleted;

  /// Task status label — cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get taskStatusCancelled;

  /// Camera scanner top-bar title.
  ///
  /// In en, this message translates to:
  /// **'Scan a product'**
  String get scanTitle;

  /// Default guidance pill under the scan frame.
  ///
  /// In en, this message translates to:
  /// **'Align the barcode within the frame'**
  String get scanAlignHint;

  /// Shown under the scan frame while a detected barcode is still being cross-checked across multiple frames, before Proceed unlocks.
  ///
  /// In en, this message translates to:
  /// **'Verifying {code} — {streak}/{required} reads agree'**
  String scanCandidateVerifying(String code, int streak, int required);

  /// Shown under the scan frame once a barcode has agreed across enough consecutive reads to trust.
  ///
  /// In en, this message translates to:
  /// **'Verified — ready to proceed'**
  String get scanCandidateVerified;

  /// Button that confirms the verified scanned barcode and opens its product result.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get scanProceed;

  /// Guidance pill shown while batch (continuous) scan mode is on.
  ///
  /// In en, this message translates to:
  /// **'Batch mode — keep scanning, items add automatically'**
  String get scanBatchHint;

  /// Snackbar after a batch-mode scan adds an item.
  ///
  /// In en, this message translates to:
  /// **'Added {code} · {count} scanned'**
  String scanBatchAdded(String code, int count);

  /// Finish-batch pill button with running scanned count.
  ///
  /// In en, this message translates to:
  /// **'Done · {count}'**
  String scanBatchDone(int count);

  /// Action to OCR-scan the product label instead of the barcode.
  ///
  /// In en, this message translates to:
  /// **'Scan label'**
  String get scanLabelAction;

  /// Action to pick a barcode image from the gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get scanGalleryAction;

  /// Action to type a barcode by hand.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get scanEnterManually;

  /// Action to open the bulk EAN audit flow.
  ///
  /// In en, this message translates to:
  /// **'Bulk audit'**
  String get scanBulkAudit;

  /// Action to open this session's scan history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get scanHistoryAction;

  /// Torch toggle label in the trouble-scanning card.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get scanFlash;

  /// Title of the low-light / damaged-barcode rescue card.
  ///
  /// In en, this message translates to:
  /// **'Trouble scanning?'**
  String get scanTroubleTitle;

  /// Body of the trouble-scanning rescue card.
  ///
  /// In en, this message translates to:
  /// **'Low light or a damaged barcode? Turn on the flash, or read the label instead.'**
  String get scanTroubleBody;

  /// Snackbar when a gallery image has no readable barcode.
  ///
  /// In en, this message translates to:
  /// **'No barcode found. Tip: use \'Scan label\' to read the ingredients.'**
  String get scanGalleryNoBarcode;

  /// Validation message for an invalid barcode entry.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid EAN-8, EAN-13, or UPC-A code'**
  String get scanInvalidEan;

  /// AppBar title on the web manual-entry fallback.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanWebTitle;

  /// Explanation on the web fallback where camera scanning is unsupported.
  ///
  /// In en, this message translates to:
  /// **'Camera scanning is not available on web.\nEnter a barcode manually:'**
  String get scanWebUnavailable;

  /// Label for the barcode text field on the web fallback.
  ///
  /// In en, this message translates to:
  /// **'EAN / UPC Code'**
  String get scanEanFieldLabel;

  /// Example barcode placeholder in entry fields.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5901234123457'**
  String get scanEanHintExample;

  /// Button to look up a manually entered barcode.
  ///
  /// In en, this message translates to:
  /// **'Look up'**
  String get scanLookUp;

  /// Title of the manual barcode entry bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Enter barcode'**
  String get scanEnterBarcode;

  /// Title of the scan history bottom sheet / button.
  ///
  /// In en, this message translates to:
  /// **'Scan history'**
  String get scanHistoryTitle;

  /// Empty state inside the scan history sheet.
  ///
  /// In en, this message translates to:
  /// **'No scans yet this session.'**
  String get scanNoHistory;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// Greeting name placeholder when the user has no resolvable name.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get homeGreetingFallbackName;

  /// No description provided for @homeTrialEnded.
  ///
  /// In en, this message translates to:
  /// **'Free trial ended — upgrade to keep access'**
  String get homeTrialEnded;

  /// Business-mode trial ribbon with remaining days.
  ///
  /// In en, this message translates to:
  /// **'Free trial · {days, plural, =1{1 day} other{{days} days}} left'**
  String homeTrialDaysLeft(int days);

  /// No description provided for @homeUpgradeArrow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade →'**
  String get homeUpgradeArrow;

  /// No description provided for @homeKpiSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get homeKpiSaved;

  /// No description provided for @homeKpiNearExpiry.
  ///
  /// In en, this message translates to:
  /// **'Near expiry'**
  String get homeKpiNearExpiry;

  /// No description provided for @homeKpiRecallAlerts.
  ///
  /// In en, this message translates to:
  /// **'Recall alerts'**
  String get homeKpiRecallAlerts;

  /// No description provided for @homeKpiOpenTasks.
  ///
  /// In en, this message translates to:
  /// **'Open tasks'**
  String get homeKpiOpenTasks;

  /// No description provided for @homeKpiLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get homeKpiLowStock;

  /// No description provided for @homeEyebrowFoodSafety.
  ///
  /// In en, this message translates to:
  /// **'FOOD SAFETY ALERT'**
  String get homeEyebrowFoodSafety;

  /// Story-banner eyebrow — brand Hinglish for 'today's work'. Keep the brand voice in English; translate naturally elsewhere.
  ///
  /// In en, this message translates to:
  /// **'AAJ KA KAAM · TODAY'**
  String get homeEyebrowToday;

  /// No description provided for @homeEyebrowHealthScan.
  ///
  /// In en, this message translates to:
  /// **'YOUR HEALTH SCAN'**
  String get homeEyebrowHealthScan;

  /// No description provided for @homeEyebrowScanToLearn.
  ///
  /// In en, this message translates to:
  /// **'SCAN TO LEARN'**
  String get homeEyebrowScanToLearn;

  /// No description provided for @homeEyebrowAllClear.
  ///
  /// In en, this message translates to:
  /// **'ALL CLEAR'**
  String get homeEyebrowAllClear;

  /// Consumer story headline when recall alerts exist.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recalled product — check what you have at home} other{{count} recalled products — check what you have at home}}'**
  String homeStoryRecall(int count);

  /// Consumer story headline for near-expiry saved items.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 saved item expires this week — use it up} other{{count} saved items expire this week — use them up}}'**
  String homeStoryNearExpiryConsumer(int count);

  /// No description provided for @homeStoryKnowWhatYouEat.
  ///
  /// In en, this message translates to:
  /// **'Know what you eat'**
  String get homeStoryKnowWhatYouEat;

  /// No description provided for @homeStoryScanInside.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at any food barcode — see what\'s inside'**
  String get homeStoryScanInside;

  /// Business story headline for items near expiry.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item near expiry — clear the shelf} other{{count} items near expiry — clear the shelf}}'**
  String homeStoryNearExpiryBusiness(int count);

  /// Business story headline for open tasks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task needs you today} other{{count} tasks need you today}}'**
  String homeStoryOpenTasks(int count);

  /// Business story headline for low-stock items.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item running low on stock} other{{count} items running low on stock}}'**
  String homeStoryLowStock(int count);

  /// No description provided for @homeStoreToday.
  ///
  /// In en, this message translates to:
  /// **'Here\'s your store today'**
  String get homeStoreToday;

  /// All-clear business headline. 'Shabaash' = well done (brand voice).
  ///
  /// In en, this message translates to:
  /// **'Shabaash! Your store\'s in great shape today'**
  String get homeStoreAllGood;

  /// No description provided for @homeCtaViewRecallAlerts.
  ///
  /// In en, this message translates to:
  /// **'View recall alerts'**
  String get homeCtaViewRecallAlerts;

  /// No description provided for @homeCtaCheckExpiry.
  ///
  /// In en, this message translates to:
  /// **'Check expiry'**
  String get homeCtaCheckExpiry;

  /// No description provided for @homeCtaOpenExpiry.
  ///
  /// In en, this message translates to:
  /// **'Open expiry'**
  String get homeCtaOpenExpiry;

  /// No description provided for @homeCtaViewTasks.
  ///
  /// In en, this message translates to:
  /// **'View tasks'**
  String get homeCtaViewTasks;

  /// No description provided for @homeCtaCheckInventory.
  ///
  /// In en, this message translates to:
  /// **'Check inventory'**
  String get homeCtaCheckInventory;

  /// No description provided for @homeCtaOpenTasks.
  ///
  /// In en, this message translates to:
  /// **'Open tasks'**
  String get homeCtaOpenTasks;

  /// No description provided for @homeCtaRunAudit.
  ///
  /// In en, this message translates to:
  /// **'Run a quick audit'**
  String get homeCtaRunAudit;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActions;

  /// No description provided for @homeQuickScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get homeQuickScan;

  /// No description provided for @homeQuickShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get homeQuickShopping;

  /// No description provided for @homeQuickAddExpiry.
  ///
  /// In en, this message translates to:
  /// **'Add Expiry'**
  String get homeQuickAddExpiry;

  /// No description provided for @homeQuickNewTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get homeQuickNewTask;

  /// No description provided for @homeRecentTasks.
  ///
  /// In en, this message translates to:
  /// **'Recent tasks'**
  String get homeRecentTasks;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeNoOpenTasks.
  ///
  /// In en, this message translates to:
  /// **'No open tasks — create one'**
  String get homeNoOpenTasks;

  /// Recent-task meta line — assignee.
  ///
  /// In en, this message translates to:
  /// **'Assigned to {name}'**
  String homeTaskAssignedTo(String name);

  /// No description provided for @homeTaskOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get homeTaskOverdue;

  /// No description provided for @homeTaskDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get homeTaskDueToday;

  /// No description provided for @homeTaskDueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get homeTaskDueTomorrow;

  /// Recent-task meta line — due in N days (N is always 2+).
  ///
  /// In en, this message translates to:
  /// **'Due in {days} days'**
  String homeTaskDueInDays(int days);

  /// Recent-task meta line — fallback raw due date.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String homeTaskDueOn(String date);

  /// No description provided for @homeHowHelps.
  ///
  /// In en, this message translates to:
  /// **'How RADHA helps you'**
  String get homeHowHelps;

  /// No description provided for @homeScanBarcodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan any food barcode'**
  String get homeScanBarcodeTitle;

  /// No description provided for @homeScanBarcodeBody.
  ///
  /// In en, this message translates to:
  /// **'See the health rating, ingredients, and what to watch out for.'**
  String get homeScanBarcodeBody;

  /// No description provided for @homeRecallTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety recall alerts'**
  String get homeRecallTitle;

  /// No description provided for @homeRecallBody.
  ///
  /// In en, this message translates to:
  /// **'Stay informed about recalled food products.'**
  String get homeRecallBody;

  /// No description provided for @homePromoKnowFoodEyebrow.
  ///
  /// In en, this message translates to:
  /// **'KNOW YOUR FOOD'**
  String get homePromoKnowFoodEyebrow;

  /// No description provided for @homePromoKnowFoodHeadline.
  ///
  /// In en, this message translates to:
  /// **'Scan the label — see what\'s really inside'**
  String get homePromoKnowFoodHeadline;

  /// No description provided for @homePromoKnowFoodCta.
  ///
  /// In en, this message translates to:
  /// **'Scan & learn'**
  String get homePromoKnowFoodCta;

  /// No description provided for @homePromoExpiryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'NEVER MISS A DATE'**
  String get homePromoExpiryEyebrow;

  /// No description provided for @homePromoExpiryHeadline.
  ///
  /// In en, this message translates to:
  /// **'Catch every expiry before it slips away'**
  String get homePromoExpiryHeadline;

  /// No description provided for @homePromoExpiryCta.
  ///
  /// In en, this message translates to:
  /// **'Track expiry'**
  String get homePromoExpiryCta;

  /// No description provided for @homePromoFestiveEyebrow.
  ///
  /// In en, this message translates to:
  /// **'FESTIVE PICKS'**
  String get homePromoFestiveEyebrow;

  /// No description provided for @homePromoFestiveHeadline.
  ///
  /// In en, this message translates to:
  /// **'Shop the season, the healthy way'**
  String get homePromoFestiveHeadline;

  /// No description provided for @homePromoFestiveCta.
  ///
  /// In en, this message translates to:
  /// **'Browse products'**
  String get homePromoFestiveCta;

  /// Business promo eyebrow — brand Hinglish for 'today's market'.
  ///
  /// In en, this message translates to:
  /// **'AAJ KA BAZAAR'**
  String get homePromoBazaarEyebrow;

  /// No description provided for @homePromoBazaarHeadline.
  ///
  /// In en, this message translates to:
  /// **'Audit your shelves in minutes'**
  String get homePromoBazaarHeadline;

  /// No description provided for @homePromoBazaarCta.
  ///
  /// In en, this message translates to:
  /// **'Start an audit'**
  String get homePromoBazaarCta;

  /// No description provided for @homeShopByCategory.
  ///
  /// In en, this message translates to:
  /// **'Shop by category'**
  String get homeShopByCategory;

  /// No description provided for @homeShopByCategorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap an aisle to scan or browse its products'**
  String get homeShopByCategorySubtitle;

  /// Welcome-page value proposition (onboarding page 1).
  ///
  /// In en, this message translates to:
  /// **'Scan, track, audit your stock without the spreadsheets.'**
  String get onboardingWelcomeValue;

  /// Capabilities-page headline (onboarding page 2). Keeps the line break.
  ///
  /// In en, this message translates to:
  /// **'Built for the floor,\nnot the back office.'**
  String get onboardingCapabilitiesTitle;

  /// No description provided for @onboardingCapScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan products in one tap'**
  String get onboardingCapScanTitle;

  /// No description provided for @onboardingCapScanBody.
  ///
  /// In en, this message translates to:
  /// **'EAN lookup with health and approval pre-checked.'**
  String get onboardingCapScanBody;

  /// No description provided for @onboardingCapExpiryTitle.
  ///
  /// In en, this message translates to:
  /// **'Catch expiry before it costs you'**
  String get onboardingCapExpiryTitle;

  /// No description provided for @onboardingCapExpiryBody.
  ///
  /// In en, this message translates to:
  /// **'OCR-assisted dates and per-category thresholds.'**
  String get onboardingCapExpiryBody;

  /// No description provided for @onboardingCapAuditTitle.
  ///
  /// In en, this message translates to:
  /// **'Run audits the team can finish'**
  String get onboardingCapAuditTitle;

  /// No description provided for @onboardingCapAuditBody.
  ///
  /// In en, this message translates to:
  /// **'Tasks, evidence and bulk scan sessions.'**
  String get onboardingCapAuditBody;

  /// Segment-selector page headline (onboarding page 3).
  ///
  /// In en, this message translates to:
  /// **'Who are you here as?'**
  String get onboardingSegmentTitle;

  /// No description provided for @onboardingSegmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the closest fit. You can change later in Settings.'**
  String get onboardingSegmentSubtitle;

  /// No description provided for @segmentPersonalTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get segmentPersonalTitle;

  /// No description provided for @segmentPersonalBody.
  ///
  /// In en, this message translates to:
  /// **'Just shopping for myself'**
  String get segmentPersonalBody;

  /// No description provided for @segmentParentTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get segmentParentTitle;

  /// No description provided for @segmentParentBody.
  ///
  /// In en, this message translates to:
  /// **'Shopping for my family / kids'**
  String get segmentParentBody;

  /// No description provided for @segmentBusinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Business owner'**
  String get segmentBusinessTitle;

  /// No description provided for @segmentBusinessBody.
  ///
  /// In en, this message translates to:
  /// **'I run a small retail store'**
  String get segmentBusinessBody;

  /// No description provided for @segmentPharmacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get segmentPharmacyTitle;

  /// No description provided for @segmentPharmacyBody.
  ///
  /// In en, this message translates to:
  /// **'I run a pharmacy / chemist'**
  String get segmentPharmacyBody;

  /// No description provided for @segmentInstitutionTitle.
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get segmentInstitutionTitle;

  /// No description provided for @segmentInstitutionBody.
  ///
  /// In en, this message translates to:
  /// **'School / hostel / canteen'**
  String get segmentInstitutionBody;

  /// No description provided for @segmentAuditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Auditor (invited)'**
  String get segmentAuditorTitle;

  /// No description provided for @segmentAuditorBody.
  ///
  /// In en, this message translates to:
  /// **'I have an invite code'**
  String get segmentAuditorBody;

  /// Allergen profile screen AppBar title.
  ///
  /// In en, this message translates to:
  /// **'Allergens'**
  String get allergenTitle;

  /// No description provided for @allergenLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your allergen profile.'**
  String get allergenLoadError;

  /// No description provided for @allergenHeading.
  ///
  /// In en, this message translates to:
  /// **'Your allergens'**
  String get allergenHeading;

  /// No description provided for @allergenIntro.
  ///
  /// In en, this message translates to:
  /// **'Tap any allergens you react to. We will warn you when a scanned product contains them.'**
  String get allergenIntro;

  /// Selection summary count of tracked allergens.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 allergen tracked} other{{count} allergens tracked}}'**
  String allergenTracked(int count);

  /// No description provided for @allergenNoneTracked.
  ///
  /// In en, this message translates to:
  /// **'No allergens tracked yet'**
  String get allergenNoneTracked;

  /// No description provided for @allergenSavedCleared.
  ///
  /// In en, this message translates to:
  /// **'Allergen profile cleared.'**
  String get allergenSavedCleared;

  /// No description provided for @allergenSaved.
  ///
  /// In en, this message translates to:
  /// **'Allergen profile saved.'**
  String get allergenSaved;

  /// No description provided for @allergenSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your allergens.'**
  String get allergenSaveError;

  /// No description provided for @allergenPeanut.
  ///
  /// In en, this message translates to:
  /// **'Peanut'**
  String get allergenPeanut;

  /// No description provided for @allergenTreeNut.
  ///
  /// In en, this message translates to:
  /// **'Tree nut'**
  String get allergenTreeNut;

  /// No description provided for @allergenDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get allergenDairy;

  /// No description provided for @allergenEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get allergenEggs;

  /// No description provided for @allergenSoy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get allergenSoy;

  /// No description provided for @allergenWheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get allergenWheat;

  /// No description provided for @allergenFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get allergenFish;

  /// No description provided for @allergenShellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get allergenShellfish;

  /// No description provided for @allergenSesame.
  ///
  /// In en, this message translates to:
  /// **'Sesame'**
  String get allergenSesame;

  /// No description provided for @allergenGluten.
  ///
  /// In en, this message translates to:
  /// **'Gluten'**
  String get allergenGluten;

  /// No description provided for @allergenMustard.
  ///
  /// In en, this message translates to:
  /// **'Mustard'**
  String get allergenMustard;

  /// No description provided for @allergenCelery.
  ///
  /// In en, this message translates to:
  /// **'Celery'**
  String get allergenCelery;

  /// No description provided for @allergenLupin.
  ///
  /// In en, this message translates to:
  /// **'Lupin'**
  String get allergenLupin;

  /// No description provided for @allergenMolluscs.
  ///
  /// In en, this message translates to:
  /// **'Molluscs'**
  String get allergenMolluscs;

  /// No description provided for @allergenSulphites.
  ///
  /// In en, this message translates to:
  /// **'Sulphites'**
  String get allergenSulphites;

  /// Generic success semantic label (celebration).
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// Locked-feature overlay title.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to {planName}'**
  String lockedFeatureUpgradeTo(String planName);

  /// Locked-feature overlay body.
  ///
  /// In en, this message translates to:
  /// **'This feature is part of the {planName} plan.'**
  String lockedFeaturePlan(String planName);

  /// No description provided for @lockedFeatureViewPlans.
  ///
  /// In en, this message translates to:
  /// **'View plans'**
  String get lockedFeatureViewPlans;

  /// No description provided for @notFoundSemantic.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundSemantic;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'This page wandered off'**
  String get notFoundTitle;

  /// No description provided for @notFoundBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for. Let\'s get you back home.'**
  String get notFoundBody;

  /// No description provided for @notFoundBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get notFoundBackHome;

  /// Generic load-failure label / error-illustration semantic, reused across screens.
  ///
  /// In en, this message translates to:
  /// **'Could not load'**
  String get commonCouldNotLoad;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @otpUseCode.
  ///
  /// In en, this message translates to:
  /// **'Use code'**
  String get otpUseCode;

  /// No description provided for @ohsPickStore.
  ///
  /// In en, this message translates to:
  /// **'Pick a store before opening the dashboard.'**
  String get ohsPickStore;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileManageStores.
  ///
  /// In en, this message translates to:
  /// **'Manage stores'**
  String get profileManageStores;

  /// No description provided for @profileSavedProducts.
  ///
  /// In en, this message translates to:
  /// **'Saved products'**
  String get profileSavedProducts;

  /// No description provided for @profileSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get profileSubscription;

  /// No description provided for @profilePreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferences;

  /// No description provided for @profileAllergenProfile.
  ///
  /// In en, this message translates to:
  /// **'Allergen profile'**
  String get profileAllergenProfile;

  /// No description provided for @profileShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get profileShoppingList;

  /// AppBar title for the recall alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Recall alerts'**
  String get recallTitle;

  /// Fallback row title when the backend has not denormalised the product name onto the alert.
  ///
  /// In en, this message translates to:
  /// **'Product {id}'**
  String recallProductFallback(String id);

  /// Date sub-label on a recall row.
  ///
  /// In en, this message translates to:
  /// **'Recalled {date}'**
  String recallDate(String date);

  /// CTA link on a tappable recall row.
  ///
  /// In en, this message translates to:
  /// **'View product'**
  String get recallViewProduct;

  /// No description provided for @recallLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load recalls.'**
  String get recallLoadError;

  /// No description provided for @recallEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active recalls'**
  String get recallEmpty;

  /// No description provided for @recallEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'You will see product recall alerts here as they are issued by regulatory bodies.'**
  String get recallEmptyBody;

  /// No description provided for @referralsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load referrals.'**
  String get referralsLoadError;

  /// No description provided for @referralsCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get referralsCopyCode;

  /// No description provided for @referralsShareInvite.
  ///
  /// In en, this message translates to:
  /// **'Share invite'**
  String get referralsShareInvite;

  /// No description provided for @referralsCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get referralsCodeCopied;

  /// No description provided for @referralsInvitees.
  ///
  /// In en, this message translates to:
  /// **'Invitees'**
  String get referralsInvitees;

  /// No description provided for @referralsRewardsEarned.
  ///
  /// In en, this message translates to:
  /// **'Rewards earned'**
  String get referralsRewardsEarned;

  /// No description provided for @referralsCodeRedeemed.
  ///
  /// In en, this message translates to:
  /// **'Code redeemed'**
  String get referralsCodeRedeemed;

  /// No description provided for @referralsEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter a referral code'**
  String get referralsEnterCode;

  /// No description provided for @referralsRedeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get referralsRedeem;

  /// No description provided for @referralsRedeemError.
  ///
  /// In en, this message translates to:
  /// **'Could not redeem code'**
  String get referralsRedeemError;

  /// No description provided for @referralsRedeemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Have a friend\'s invite? Enter their code below.'**
  String get referralsRedeemSubtitle;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @healthSugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get healthSugar;

  /// No description provided for @healthSalt.
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get healthSalt;

  /// No description provided for @healthFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get healthFat;

  /// No description provided for @healthProcessed.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get healthProcessed;

  /// No description provided for @healthChildSuitable.
  ///
  /// In en, this message translates to:
  /// **'Child-suitable'**
  String get healthChildSuitable;

  /// No description provided for @productDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetailsTitle;

  /// No description provided for @productDetailLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this product'**
  String get productDetailLoadError;

  /// No description provided for @productCheckAllergens.
  ///
  /// In en, this message translates to:
  /// **'Check allergens'**
  String get productCheckAllergens;

  /// No description provided for @productExplainIngredients.
  ///
  /// In en, this message translates to:
  /// **'Explain ingredients'**
  String get productExplainIngredients;

  /// No description provided for @productSeeHealthierOptions.
  ///
  /// In en, this message translates to:
  /// **'See healthier options'**
  String get productSeeHealthierOptions;

  /// No description provided for @productViewHealthyAlternatives.
  ///
  /// In en, this message translates to:
  /// **'View healthy alternatives'**
  String get productViewHealthyAlternatives;

  /// No description provided for @productHealthAssessment.
  ///
  /// In en, this message translates to:
  /// **'Health Assessment'**
  String get productHealthAssessment;

  /// No description provided for @productNutritionInfo.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Info'**
  String get productNutritionInfo;

  /// No description provided for @productAllergenCheck.
  ///
  /// In en, this message translates to:
  /// **'Allergen Check'**
  String get productAllergenCheck;

  /// No description provided for @productSeeFullExplanation.
  ///
  /// In en, this message translates to:
  /// **'See full explanation'**
  String get productSeeFullExplanation;

  /// No description provided for @productHealthierOptions.
  ///
  /// In en, this message translates to:
  /// **'Healthier Options'**
  String get productHealthierOptions;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @nutritionProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get nutritionProtein;

  /// No description provided for @nutritionTotalSugars.
  ///
  /// In en, this message translates to:
  /// **'Total Sugars'**
  String get nutritionTotalSugars;

  /// No description provided for @nutritionEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get nutritionEnergy;

  /// No description provided for @nutritionTotalFat.
  ///
  /// In en, this message translates to:
  /// **'Total Fat'**
  String get nutritionTotalFat;

  /// No description provided for @nutritionSaturatedFat.
  ///
  /// In en, this message translates to:
  /// **'Saturated Fat'**
  String get nutritionSaturatedFat;

  /// No description provided for @nutritionCarbohydrates.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get nutritionCarbohydrates;

  /// No description provided for @nutritionFibre.
  ///
  /// In en, this message translates to:
  /// **'Fibre'**
  String get nutritionFibre;

  /// No description provided for @nutritionSodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get nutritionSodium;

  /// No description provided for @nutritionAll.
  ///
  /// In en, this message translates to:
  /// **'All nutrients'**
  String get nutritionAll;

  /// No description provided for @nutritionPer100g.
  ///
  /// In en, this message translates to:
  /// **'Per 100 g'**
  String get nutritionPer100g;

  /// No description provided for @nutritionPer50g.
  ///
  /// In en, this message translates to:
  /// **'Per 50 g'**
  String get nutritionPer50g;

  /// No description provided for @productDetailSavedAlert.
  ///
  /// In en, this message translates to:
  /// **'Saved — we\'ll alert you if it\'s ever recalled.'**
  String get productDetailSavedAlert;

  /// No description provided for @productDetailSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please try again.'**
  String get productDetailSaveError;

  /// No description provided for @productDetailWhatYoullLike.
  ///
  /// In en, this message translates to:
  /// **'What you\'ll like'**
  String get productDetailWhatYoullLike;

  /// No description provided for @productDetailWhatConcern.
  ///
  /// In en, this message translates to:
  /// **'What should concern you'**
  String get productDetailWhatConcern;

  /// No description provided for @productDetailIngredientDeepDive.
  ///
  /// In en, this message translates to:
  /// **'Ingredient deep-dive'**
  String get productDetailIngredientDeepDive;

  /// No description provided for @productDetailPersonalisedFlags.
  ///
  /// In en, this message translates to:
  /// **'Personalised flags'**
  String get productDetailPersonalisedFlags;

  /// No description provided for @productDetailAlreadyBought.
  ///
  /// In en, this message translates to:
  /// **'Already bought'**
  String get productDetailAlreadyBought;

  /// No description provided for @productDetailScanToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Scan to unlock'**
  String get productDetailScanToUnlock;

  /// Generic AppBar title for the product detail screen.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productDetailTitle;

  /// Tooltip for the save/bookmark heart button (unsaved state).
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get productDetailSave;

  /// Tooltip for the save/bookmark heart button (saved state).
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get productDetailSaved;

  /// Title shown when the product has no health rating yet.
  ///
  /// In en, this message translates to:
  /// **'Health rating not in yet'**
  String get productDetailHealthNotRated;

  /// Body shown when the product has no health rating yet.
  ///
  /// In en, this message translates to:
  /// **'Scan this product to pull its full health analysis into RADHA.'**
  String get productDetailHealthNotRatedBody;

  /// Section label above the numeric health score.
  ///
  /// In en, this message translates to:
  /// **'RADHA Health Rating'**
  String get productDetailHealthLabel;

  /// No description provided for @productDetailHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High protein'**
  String get productDetailHighProtein;

  /// No description provided for @productDetailGoodFibre.
  ///
  /// In en, this message translates to:
  /// **'Good fibre'**
  String get productDetailGoodFibre;

  /// No description provided for @productDetailMinimallyProcessed.
  ///
  /// In en, this message translates to:
  /// **'Minimally processed'**
  String get productDetailMinimallyProcessed;

  /// No description provided for @productDetailHighSugar.
  ///
  /// In en, this message translates to:
  /// **'High sugar'**
  String get productDetailHighSugar;

  /// No description provided for @productDetailHighSatFat.
  ///
  /// In en, this message translates to:
  /// **'High saturated fat'**
  String get productDetailHighSatFat;

  /// No description provided for @productDetailHighSodium.
  ///
  /// In en, this message translates to:
  /// **'High sodium'**
  String get productDetailHighSodium;

  /// No description provided for @productDetailUltraProcessed.
  ///
  /// In en, this message translates to:
  /// **'Ultra-processed'**
  String get productDetailUltraProcessed;

  /// Italic disclaimer below the nutrition insight badges.
  ///
  /// In en, this message translates to:
  /// **'Based on the product\'s real nutrition (per 100 g).'**
  String get productDetailNutritionNote;

  /// Section heading for the key-nutrients card.
  ///
  /// In en, this message translates to:
  /// **'Key nutrients'**
  String get productDetailKeyNutrients;

  /// Footer note in the all-nutrients bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'% of reference daily intake (adult).'**
  String get productDetailRdaNote;

  /// Secondary label next to the RADHA Plus badge.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get productDetailForYou;

  /// Subtitle in the locked ingredient deep-dive card.
  ///
  /// In en, this message translates to:
  /// **'See every ingredient explained with a safety verdict — what it is, why it\'s there, and whether to worry.'**
  String get productDetailIngredientLockBody;

  /// Error state inside the ingredient deep-dive card.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t explain these ingredients right now.'**
  String get productDetailIngredientError;

  /// Subtitle in the locked For-You allergen card.
  ///
  /// In en, this message translates to:
  /// **'Match this product against your saved allergens & health goals — we\'ll flag what\'s right (or wrong) for you.'**
  String get productDetailAllergenLockBody;

  /// Error state inside the For-You allergen card.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t personalise this right now.'**
  String get productDetailAllergenError;

  /// Success message when the product has zero allergen matches.
  ///
  /// In en, this message translates to:
  /// **'No allergens detected in this product.'**
  String get productDetailNoAllergens;

  /// Label on an allergen chip when it matches the user's profile.
  ///
  /// In en, this message translates to:
  /// **'{name} — you avoid this'**
  String productDetailAllergenAvoid(String name);

  /// CTA button label in a locked Plus feature card.
  ///
  /// In en, this message translates to:
  /// **'Unlock with {plan}'**
  String productDetailUnlockWith(String plan);

  /// Title of the Would-you-buy engagement widget (unanswered).
  ///
  /// In en, this message translates to:
  /// **'Would you buy this product?'**
  String get productDetailWouldYouBuy;

  /// Title of the Would-you-buy widget after the user has answered.
  ///
  /// In en, this message translates to:
  /// **'Thanks for sharing!'**
  String get productDetailThanksForSharing;

  /// Title of the scan-to-unlock card when nutrition data is missing.
  ///
  /// In en, this message translates to:
  /// **'Full nutrition isn\'t in yet'**
  String get productDetailNutritionNotIn;

  /// Body of the scan-to-unlock card when nutrition data is missing.
  ///
  /// In en, this message translates to:
  /// **'Scan this product\'s barcode to pull its real nutrition & health analysis into RADHA — it only takes a second.'**
  String get productDetailNutritionNotInBody;

  /// Share text when the product has no health rating.
  ///
  /// In en, this message translates to:
  /// **'Checked \"{name}\" on RADHA.'**
  String productDetailShareText(String name);

  /// Share text when the product has a health rating.
  ///
  /// In en, this message translates to:
  /// **'Checked \"{name}\" on RADHA — RADHA health rating {rating}/5 ({label}).'**
  String productDetailShareTextRated(String name, String rating, String label);

  /// Placeholder text in the tappable search-bar pill on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Search products to find what fits you'**
  String get catalogSearchBarLabel;

  /// Title in the idle search prompt (before the user types).
  ///
  /// In en, this message translates to:
  /// **'Find a product'**
  String get catalogSearchPromptTitle;

  /// Body in the idle search prompt.
  ///
  /// In en, this message translates to:
  /// **'Search by product name or brand to see its health rating and what\'s inside.'**
  String get catalogSearchPromptBody;

  /// Generic negative response chip.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @scanApprovalNotInAudit.
  ///
  /// In en, this message translates to:
  /// **'Approval status — not in an audit'**
  String get scanApprovalNotInAudit;

  /// No description provided for @scanApprovalChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking approved list…'**
  String get scanApprovalChecking;

  /// No description provided for @scanApprovalCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check approval'**
  String get scanApprovalCheckFailed;

  /// No description provided for @scanApprovalApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved — in list'**
  String get scanApprovalApproved;

  /// No description provided for @scanApprovalNoList.
  ///
  /// In en, this message translates to:
  /// **'No approved list active'**
  String get scanApprovalNoList;

  /// No description provided for @scanApprovalInvalidBarcode.
  ///
  /// In en, this message translates to:
  /// **'Invalid barcode'**
  String get scanApprovalInvalidBarcode;

  /// No description provided for @scanApprovalNotInList.
  ///
  /// In en, this message translates to:
  /// **'Not in approved list'**
  String get scanApprovalNotInList;

  /// Accessibility label summarising the approval-status pill.
  ///
  /// In en, this message translates to:
  /// **'Approval status: {label}'**
  String scanApprovalStatus(String label);

  /// No description provided for @scanResultAddToExpiry.
  ///
  /// In en, this message translates to:
  /// **'Add to expiry'**
  String get scanResultAddToExpiry;

  /// No description provided for @scanResultAddToStock.
  ///
  /// In en, this message translates to:
  /// **'Add to stock'**
  String get scanResultAddToStock;

  /// No description provided for @scanResultSaveToList.
  ///
  /// In en, this message translates to:
  /// **'Save to list'**
  String get scanResultSaveToList;

  /// No description provided for @scanResultNoProduct.
  ///
  /// In en, this message translates to:
  /// **'No product found'**
  String get scanResultNoProduct;

  /// No description provided for @scanResultScanLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan the label'**
  String get scanResultScanLabel;

  /// No description provided for @auditRecordError.
  ///
  /// In en, this message translates to:
  /// **'Could not record the scan. Please try again.'**
  String get auditRecordError;

  /// No description provided for @auditEndError.
  ///
  /// In en, this message translates to:
  /// **'Could not end the audit. Please try again.'**
  String get auditEndError;

  /// No description provided for @auditNoStore.
  ///
  /// In en, this message translates to:
  /// **'No store assigned'**
  String get auditNoStore;

  /// No description provided for @auditNoStoreBody.
  ///
  /// In en, this message translates to:
  /// **'Bulk audits run against a store\'s approved EAN list. Ask an admin to assign you a store, then come back to audit.'**
  String get auditNoStoreBody;

  /// No description provided for @auditMatched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get auditMatched;

  /// No description provided for @auditNotInList.
  ///
  /// In en, this message translates to:
  /// **'Not in list'**
  String get auditNotInList;

  /// No description provided for @auditNoList.
  ///
  /// In en, this message translates to:
  /// **'No list'**
  String get auditNoList;

  /// No description provided for @auditInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get auditInvalid;

  /// No description provided for @auditUnchecked.
  ///
  /// In en, this message translates to:
  /// **'Unchecked'**
  String get auditUnchecked;

  /// No description provided for @commonTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get commonTotal;

  /// No description provided for @auditEnterScanEan.
  ///
  /// In en, this message translates to:
  /// **'Enter or scan EAN'**
  String get auditEnterScanEan;

  /// Accessibility label for the audit status pill.
  ///
  /// In en, this message translates to:
  /// **'Status: {label}'**
  String auditStatus(String label);

  /// No description provided for @auditStartAuditing.
  ///
  /// In en, this message translates to:
  /// **'Start auditing'**
  String get auditStartAuditing;

  /// No description provided for @auditStartBody.
  ///
  /// In en, this message translates to:
  /// **'Scan or type an EAN above to check it against this store\'s approved list. Each result lands here with a matched or not-in-list status.'**
  String get auditStartBody;

  /// AppBar title for the bulk EAN audit screen.
  ///
  /// In en, this message translates to:
  /// **'Bulk EAN Audit'**
  String get auditTitle;

  /// Action button label to finish the audit session.
  ///
  /// In en, this message translates to:
  /// **'End audit'**
  String get auditEndAction;

  /// Action button label while the audit is being ended.
  ///
  /// In en, this message translates to:
  /// **'Ending…'**
  String get auditEndingAction;

  /// Inline validation error when the user types an invalid EAN.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid EAN-8, EAN-13, or UPC-A code'**
  String get auditEanInvalid;

  /// Snackbar shown after the audit session closes.
  ///
  /// In en, this message translates to:
  /// **'Audit ended — {matched} matched, {notMatched} not in list'**
  String auditEndedSummary(int matched, int notMatched);

  /// No description provided for @cameraCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get cameraCapture;

  /// No description provided for @labelScanReadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the label'**
  String get labelScanReadError;

  /// No description provided for @labelScanReadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Try again in better light, hold steady, and fill the frame with the ingredients panel.'**
  String get labelScanReadErrorBody;

  /// No description provided for @labelScanAnalysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed'**
  String get labelScanAnalysisFailed;

  /// No description provided for @labelScanIntro.
  ///
  /// In en, this message translates to:
  /// **'RADHA reads the label for you'**
  String get labelScanIntro;

  /// No description provided for @labelScanTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get labelScanTakePhoto;

  /// No description provided for @labelScanChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get labelScanChooseGallery;

  /// No description provided for @labelScanAnother.
  ///
  /// In en, this message translates to:
  /// **'Scan another'**
  String get labelScanAnother;

  /// Upgrade CTA on the locked label-scan view.
  ///
  /// In en, this message translates to:
  /// **'See {plan} plans'**
  String labelScanSeePlans(String plan);

  /// No description provided for @labelScanMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get labelScanMaybeLater;

  /// No description provided for @labelScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the label'**
  String get labelScanTitle;

  /// No description provided for @labelScanNoBarcode.
  ///
  /// In en, this message translates to:
  /// **'No barcode? Read the label instead'**
  String get labelScanNoBarcode;

  /// No description provided for @labelScanIdleBody.
  ///
  /// In en, this message translates to:
  /// **'Point at the ingredients panel — we\'ll read it and tell you what\'s inside. Works on products without a barcode.'**
  String get labelScanIdleBody;

  /// No description provided for @labelScanFlashNote.
  ///
  /// In en, this message translates to:
  /// **'In low light your camera flash turns on automatically.'**
  String get labelScanFlashNote;

  /// No description provided for @labelScanReading.
  ///
  /// In en, this message translates to:
  /// **'Reading the label…'**
  String get labelScanReading;

  /// No description provided for @labelScanAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing ingredients…'**
  String get labelScanAnalyzing;

  /// No description provided for @labelScanFallbackError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get labelScanFallbackError;

  /// No description provided for @labelScanResultFallback.
  ///
  /// In en, this message translates to:
  /// **'Label analysis'**
  String get labelScanResultFallback;

  /// No description provided for @labelScanLowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Low confidence — a clearer photo may improve this.'**
  String get labelScanLowConfidence;

  /// No description provided for @labelScanWhatToWatch.
  ///
  /// In en, this message translates to:
  /// **'What to watch'**
  String get labelScanWhatToWatch;

  /// No description provided for @labelScanIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get labelScanIngredients;

  /// No description provided for @labelScanDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Read by RADHA AI from the label text. Always check the pack for the most accurate information.'**
  String get labelScanDisclaimer;

  /// No description provided for @labelScanUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock AI label reading'**
  String get labelScanUnlockTitle;

  /// No description provided for @labelScanUnlockBody.
  ///
  /// In en, this message translates to:
  /// **'We read the label, but the full ingredient & health breakdown is a premium feature.'**
  String get labelScanUnlockBody;

  /// Body on the scan-result not-found state.
  ///
  /// In en, this message translates to:
  /// **'No catalog match for EAN {ean} — but you can still read the label. Snap the ingredients panel and we\'ll tell you what\'s inside.'**
  String scanResultNotFoundBody(String ean);

  /// Health score badge on a healthier-alternative card.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String productScore(String score);

  /// No description provided for @catalogSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products or brands'**
  String get catalogSearchHint;

  /// No description provided for @catalogNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get catalogNoMatches;

  /// Empty-state body on catalog search when a query has no results.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find products for “{query}”. Try a different name, or scan the item instead.'**
  String catalogNoMatchesBody(String query);

  /// No description provided for @browseTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get browseTitle;

  /// No description provided for @browseLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load products'**
  String get browseLoadError;

  /// Error-state body on product browse.
  ///
  /// In en, this message translates to:
  /// **'We hit a snag loading {category}. Please try again.'**
  String browseLoadErrorBody(String category);

  /// No description provided for @browseSortHealthiest.
  ///
  /// In en, this message translates to:
  /// **'Healthiest'**
  String get browseSortHealthiest;

  /// No description provided for @browseSortAZ.
  ///
  /// In en, this message translates to:
  /// **'A–Z'**
  String get browseSortAZ;

  /// No description provided for @browseFilterVegOnly.
  ///
  /// In en, this message translates to:
  /// **'Veg only'**
  String get browseFilterVegOnly;

  /// No description provided for @browseVeg.
  ///
  /// In en, this message translates to:
  /// **'Veg'**
  String get browseVeg;

  /// No description provided for @browseEmptyVeg.
  ///
  /// In en, this message translates to:
  /// **'No veg items here yet'**
  String get browseEmptyVeg;

  /// Empty-state body when the veg filter yields nothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing in {category} matches the veg filter right now.'**
  String browseEmptyVegBody(String category);

  /// No description provided for @browseShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get browseShowAll;

  /// No description provided for @browseEmpty.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get browseEmpty;

  /// Empty-state body when a category has no products yet.
  ///
  /// In en, this message translates to:
  /// **'We\'re stocking the {category} aisle. Meanwhile, scan any item to check its health and expiry.'**
  String browseEmptyBody(String category);

  /// Share-sheet message body when inviting a friend.
  ///
  /// In en, this message translates to:
  /// **'Join me on RADHA: use code {code}'**
  String referralsShareText(String code);

  /// No description provided for @selectStoreEmpty.
  ///
  /// In en, this message translates to:
  /// **'No stores yet'**
  String get selectStoreEmpty;

  /// No description provided for @selectStoreEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Reach out to your manager to be added to a store.'**
  String get selectStoreEmptyBody;

  /// No description provided for @selectStoreEmptyDetail.
  ///
  /// In en, this message translates to:
  /// **'Your account is not associated with any store yet. Ask your manager to grant access, then come back to pick one.'**
  String get selectStoreEmptyDetail;

  /// No description provided for @selectStoreContactManager.
  ///
  /// In en, this message translates to:
  /// **'Contact your manager'**
  String get selectStoreContactManager;

  /// No description provided for @expiryConsumerTitle.
  ///
  /// In en, this message translates to:
  /// **'For business accounts'**
  String get expiryConsumerTitle;

  /// No description provided for @expiryConsumerBody.
  ///
  /// In en, this message translates to:
  /// **'Expiry tracking is a retail-store feature. To use it, connect your account to a store.'**
  String get expiryConsumerBody;

  /// No description provided for @tasksConsumerTitle.
  ///
  /// In en, this message translates to:
  /// **'For business accounts'**
  String get tasksConsumerTitle;

  /// No description provided for @tasksConsumerBody.
  ///
  /// In en, this message translates to:
  /// **'Task management is a retail-store feature. To use it, connect your account to a store.'**
  String get tasksConsumerBody;

  /// No description provided for @languageSavedLocally.
  ///
  /// In en, this message translates to:
  /// **'Language saved locally only'**
  String get languageSavedLocally;

  /// Shown when a language change persisted on-device but the server sync failed.
  ///
  /// In en, this message translates to:
  /// **'Language saved locally only: {error}'**
  String languageSavedLocallyError(String error);

  /// No description provided for @signOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again with an OTP to use the app.'**
  String get signOutConfirmBody;

  /// No description provided for @scanResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan result'**
  String get scanResultTitle;

  /// Share-sheet message body from the scan result screen.
  ///
  /// In en, this message translates to:
  /// **'I checked this product on RADHA — barcode {ean}.'**
  String scanResultShareMessage(String ean);

  /// No description provided for @scanResultHealthHeading.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get scanResultHealthHeading;

  /// No description provided for @scanResultAssessmentPending.
  ///
  /// In en, this message translates to:
  /// **'Assessment pending'**
  String get scanResultAssessmentPending;

  /// No description provided for @scanResultNutritionPending.
  ///
  /// In en, this message translates to:
  /// **'Nutrition flags appear here once this product is matched in the catalog. Scan more items to enrich the database.'**
  String get scanResultNutritionPending;

  /// No description provided for @scanResultExplainIngredients.
  ///
  /// In en, this message translates to:
  /// **'Explain ingredients'**
  String get scanResultExplainIngredients;

  /// No description provided for @scanResultAllergenPrompt.
  ///
  /// In en, this message translates to:
  /// **'Set up your allergen profile to get instant warnings when a scanned product contains something you avoid.'**
  String get scanResultAllergenPrompt;

  /// Real declared allergens for the scanned product, comma-joined by the caller.
  ///
  /// In en, this message translates to:
  /// **'Contains: {allergens}'**
  String scanResultAllergensDeclared(String allergens);

  /// No description provided for @scanResultNoAllergensDeclared.
  ///
  /// In en, this message translates to:
  /// **'No allergens declared on this product\'s label.'**
  String get scanResultNoAllergensDeclared;

  /// No description provided for @taskEvidenceRequiredSnack.
  ///
  /// In en, this message translates to:
  /// **'Evidence is required to complete this task'**
  String get taskEvidenceRequiredSnack;

  /// Snackbar after a task status transition.
  ///
  /// In en, this message translates to:
  /// **'Task moved to {status}'**
  String taskMovedTo(String status);

  /// No description provided for @taskUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update the task. Please try again.'**
  String get taskUpdateError;

  /// Task detail meta line — who the task is assigned to.
  ///
  /// In en, this message translates to:
  /// **'Assigned to {name}'**
  String taskAssignedTo(String name);

  /// Task detail meta line — due date.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String taskDueOn(String date);

  /// No description provided for @taskPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get taskPriorityLabel;

  /// No description provided for @taskEvidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get taskEvidenceLabel;

  /// No description provided for @taskEvidencePhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Photo required'**
  String get taskEvidencePhotoRequired;

  /// No description provided for @taskEvidenceNotRequired.
  ///
  /// In en, this message translates to:
  /// **'Not required'**
  String get taskEvidenceNotRequired;

  /// Evidence section — number of attached photos.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo attached} other{{count} photos attached}}'**
  String taskEvidencePhotosAttached(int count);

  /// No description provided for @taskEvidencePhotoNeeded.
  ///
  /// In en, this message translates to:
  /// **'A photo is required to complete this task'**
  String get taskEvidencePhotoNeeded;

  /// No description provided for @taskTimelineCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get taskTimelineCreated;

  /// No description provided for @taskTimelineStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get taskTimelineStarted;

  /// No description provided for @taskActionComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get taskActionComplete;

  /// No description provided for @taskLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load task'**
  String get taskLoadFailed;

  /// No description provided for @taskDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDescriptionLabel;

  /// No description provided for @taskTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get taskTypeLabel;

  /// No description provided for @taskActionStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get taskActionStart;

  /// No description provided for @taskCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get taskCreateTitle;

  /// No description provided for @taskCreateCta.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get taskCreateCta;

  /// No description provided for @taskCreatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Task created'**
  String get taskCreatedSnack;

  /// No description provided for @taskCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create the task. Please try again.'**
  String get taskCreateError;

  /// No description provided for @taskNotAuthorizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not authorized'**
  String get taskNotAuthorizedTitle;

  /// No description provided for @taskNotAuthorizedBody.
  ///
  /// In en, this message translates to:
  /// **'Only managers and admins can create tasks.'**
  String get taskNotAuthorizedBody;

  /// No description provided for @taskTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskTitleLabel;

  /// No description provided for @taskTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Audit dairy aisle EANs'**
  String get taskTitleHint;

  /// No description provided for @taskTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get taskTitleRequired;

  /// No description provided for @taskDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Optional details for the assignee'**
  String get taskDescriptionHint;

  /// No description provided for @taskStoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get taskStoreLabel;

  /// No description provided for @taskAssigneeLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignee (user ID)'**
  String get taskAssigneeLabel;

  /// No description provided for @taskAssigneeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter user ID or leave blank'**
  String get taskAssigneeHint;

  /// No description provided for @taskDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get taskDueDateLabel;

  /// No description provided for @taskSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get taskSelectDate;

  /// No description provided for @taskRequiresEvidence.
  ///
  /// In en, this message translates to:
  /// **'Requires evidence'**
  String get taskRequiresEvidence;

  /// No description provided for @taskRequiresEvidenceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assignee must upload a photo to complete'**
  String get taskRequiresEvidenceSubtitle;

  /// No description provided for @taskTypeEanAudit.
  ///
  /// In en, this message translates to:
  /// **'EAN Audit'**
  String get taskTypeEanAudit;

  /// No description provided for @taskTypeExpiryCheck.
  ///
  /// In en, this message translates to:
  /// **'Expiry Check'**
  String get taskTypeExpiryCheck;

  /// No description provided for @taskTypeInventoryCount.
  ///
  /// In en, this message translates to:
  /// **'Inventory Count'**
  String get taskTypeInventoryCount;

  /// No description provided for @taskTypeDisplayVerification.
  ///
  /// In en, this message translates to:
  /// **'Display Verification'**
  String get taskTypeDisplayVerification;

  /// No description provided for @taskTypeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get taskTypeCustom;

  /// No description provided for @checkoutStartError.
  ///
  /// In en, this message translates to:
  /// **'Could not start checkout. Please try again.'**
  String get checkoutStartError;

  /// No description provided for @paymentResponseIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Payment response was incomplete.'**
  String get paymentResponseIncomplete;

  /// No description provided for @paymentSuccessUpdated.
  ///
  /// In en, this message translates to:
  /// **'Payment successful. Plan updated.'**
  String get paymentSuccessUpdated;

  /// No description provided for @paymentNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Payment could not be verified.'**
  String get paymentNotVerified;

  /// No description provided for @paymentVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment verification failed. Please contact support.'**
  String get paymentVerifyFailed;

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled.'**
  String get paymentCancelled;

  /// Snackbar when Razorpay reports a payment failure.
  ///
  /// In en, this message translates to:
  /// **'Payment failed: {message}'**
  String paymentFailed(String message);

  /// Snackbar when an external wallet app is opened.
  ///
  /// In en, this message translates to:
  /// **'Opening {wallet}…'**
  String paymentOpeningWallet(String wallet);

  /// No description provided for @paymentSheetOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the payment sheet.'**
  String get paymentSheetOpenError;

  /// No description provided for @subscriptionLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your subscription'**
  String get subscriptionLoadError;

  /// No description provided for @subscriptionLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get subscriptionLoadErrorBody;

  /// Badge on the user's currently-active plan card.
  ///
  /// In en, this message translates to:
  /// **'You\'re on {plan}'**
  String subscriptionCurrentPlan(String plan);

  /// CTA to upgrade to a higher plan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to {plan}'**
  String subscriptionUpgradeTo(String plan);

  /// CTA to choose a plan.
  ///
  /// In en, this message translates to:
  /// **'Choose {plan}'**
  String subscriptionChoosePlan(String plan);

  /// No description provided for @subscriptionPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get subscriptionPopular;

  /// No description provided for @subscriptionPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/mo'**
  String get subscriptionPerMonth;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionHeadline.
  ///
  /// In en, this message translates to:
  /// **'Unlock RADHA\'s full picture'**
  String get subscriptionHeadline;

  /// No description provided for @subscriptionChooseAPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get subscriptionChooseAPlan;

  /// No description provided for @subscriptionCancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime · GST included'**
  String get subscriptionCancelAnytime;

  /// No description provided for @subscriptionBillingYearly.
  ///
  /// In en, this message translates to:
  /// **'yearly'**
  String get subscriptionBillingYearly;

  /// No description provided for @subscriptionBillingMonthly.
  ///
  /// In en, this message translates to:
  /// **'monthly'**
  String get subscriptionBillingMonthly;

  /// No description provided for @versionLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading version…'**
  String get versionLoading;

  /// No description provided for @versionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Version unavailable'**
  String get versionUnavailable;

  /// App version string shown in the About card.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String appVersionBuild(String version, String build);

  /// No description provided for @shoppingListTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingListTitle;

  /// No description provided for @shoppingAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get shoppingAddItem;

  /// No description provided for @shoppingLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your list'**
  String get shoppingLoadError;

  /// No description provided for @shoppingLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your shopping list. Please try again.'**
  String get shoppingLoadErrorBody;

  /// No description provided for @shoppingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your shopping list is empty'**
  String get shoppingEmptyTitle;

  /// No description provided for @shoppingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the plus button to add an item, or save healthy alternatives from a product page.'**
  String get shoppingEmptyBody;

  /// No description provided for @shoppingUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update the item. Please try again.'**
  String get shoppingUpdateError;

  /// No description provided for @shoppingDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the item. Please try again.'**
  String get shoppingDeleteError;

  /// No description provided for @shoppingAddError.
  ///
  /// In en, this message translates to:
  /// **'Could not add the item. Please try again.'**
  String get shoppingAddError;

  /// No description provided for @shoppingAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done — everything ticked off'**
  String get shoppingAllDone;

  /// Progress header — items still to buy.
  ///
  /// In en, this message translates to:
  /// **'{remaining} of {total} left to buy'**
  String shoppingRemaining(int remaining, int total);

  /// Quantity line on a shopping-list row.
  ///
  /// In en, this message translates to:
  /// **'Qty: {quantity}'**
  String shoppingQty(int quantity);

  /// No description provided for @shoppingDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get shoppingDeleteItem;

  /// No description provided for @shoppingItemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get shoppingItemNameLabel;

  /// No description provided for @shoppingItemNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Whole wheat bread'**
  String get shoppingItemNameHint;

  /// No description provided for @shoppingItemNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an item name'**
  String get shoppingItemNameRequired;

  /// No description provided for @shoppingItemNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep it under 120 characters'**
  String get shoppingItemNameTooLong;

  /// No description provided for @shoppingQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity (optional)'**
  String get shoppingQuantityLabel;

  /// No description provided for @shoppingQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive number'**
  String get shoppingQuantityInvalid;

  /// No description provided for @shoppingQuantityTooHigh.
  ///
  /// In en, this message translates to:
  /// **'That seems unreasonably high'**
  String get shoppingQuantityTooHigh;

  /// No description provided for @shoppingAddToList.
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get shoppingAddToList;

  /// No description provided for @grnTitle.
  ///
  /// In en, this message translates to:
  /// **'Goods received'**
  String get grnTitle;

  /// No description provided for @grnFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get grnFilterAll;

  /// No description provided for @grnFilterDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get grnFilterDraft;

  /// No description provided for @grnFilterPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get grnFilterPendingReview;

  /// No description provided for @grnFilterPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get grnFilterPosted;

  /// No description provided for @grnStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get grnStatusPending;

  /// No description provided for @grnEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No GRNs here'**
  String get grnEmptyTitle;

  /// No description provided for @grnEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a goods-received note to log a supplier delivery.'**
  String get grnEmptyBody;

  /// No description provided for @grnNew.
  ///
  /// In en, this message translates to:
  /// **'New GRN'**
  String get grnNew;

  /// No description provided for @grnLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load GRNs'**
  String get grnLoadError;

  /// No description provided for @grnSupplierFallback.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get grnSupplierFallback;

  /// No description provided for @categoryBiscuits.
  ///
  /// In en, this message translates to:
  /// **'Biscuits & Snacks'**
  String get categoryBiscuits;

  /// No description provided for @categoryBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast & Spreads'**
  String get categoryBreakfast;

  /// No description provided for @categoryDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy & Eggs'**
  String get categoryDairy;

  /// No description provided for @categoryBeverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get categoryBeverages;

  /// No description provided for @categoryStaples.
  ///
  /// In en, this message translates to:
  /// **'Staples & Grains'**
  String get categoryStaples;

  /// No description provided for @categoryPersonalCare.
  ///
  /// In en, this message translates to:
  /// **'Personal Care'**
  String get categoryPersonalCare;

  /// No description provided for @categoryHousehold.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get categoryHousehold;

  /// No description provided for @categoryFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get categoryFrozen;

  /// No description provided for @lowStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Low stock alerts'**
  String get lowStockTitle;

  /// No description provided for @lowStockLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load alerts'**
  String get lowStockLoadError;

  /// No description provided for @lowStockEmpty.
  ///
  /// In en, this message translates to:
  /// **'All stock levels are healthy'**
  String get lowStockEmpty;

  /// Quantity vs low-stock threshold on an alert row.
  ///
  /// In en, this message translates to:
  /// **'Current: {quantity} / Threshold: {threshold}'**
  String lowStockCurrentThreshold(int quantity, int threshold);

  /// No description provided for @lowStockRestock.
  ///
  /// In en, this message translates to:
  /// **'Restock'**
  String get lowStockRestock;

  /// No description provided for @commonRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// No description provided for @commonOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get commonOptional;

  /// No description provided for @commonQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get commonQuantity;

  /// No description provided for @smTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock movement'**
  String get smTitle;

  /// No description provided for @smStockIn.
  ///
  /// In en, this message translates to:
  /// **'Stock In'**
  String get smStockIn;

  /// No description provided for @smStockOut.
  ///
  /// In en, this message translates to:
  /// **'Stock Out'**
  String get smStockOut;

  /// No description provided for @smProductLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get smProductLabel;

  /// No description provided for @smProductHint.
  ///
  /// In en, this message translates to:
  /// **'Enter product ID or EAN'**
  String get smProductHint;

  /// No description provided for @smReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get smReasonLabel;

  /// No description provided for @smSelectReason.
  ///
  /// In en, this message translates to:
  /// **'Select reason'**
  String get smSelectReason;

  /// No description provided for @smBatchLabel.
  ///
  /// In en, this message translates to:
  /// **'Batch number'**
  String get smBatchLabel;

  /// No description provided for @smExpiryLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get smExpiryLabel;

  /// No description provided for @smExpiryOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — tap to select'**
  String get smExpiryOptionalHint;

  /// No description provided for @smNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get smNotesLabel;

  /// No description provided for @smNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Optional notes'**
  String get smNotesHint;

  /// No description provided for @smRecordIn.
  ///
  /// In en, this message translates to:
  /// **'Record stock in'**
  String get smRecordIn;

  /// No description provided for @smRecordOut.
  ///
  /// In en, this message translates to:
  /// **'Record stock out'**
  String get smRecordOut;

  /// No description provided for @smStockInRecorded.
  ///
  /// In en, this message translates to:
  /// **'Stock-in recorded'**
  String get smStockInRecorded;

  /// No description provided for @smStockOutRecorded.
  ///
  /// In en, this message translates to:
  /// **'Stock-out recorded'**
  String get smStockOutRecorded;

  /// No description provided for @smRecordError.
  ///
  /// In en, this message translates to:
  /// **'Could not record the stock movement. Please try again.'**
  String get smRecordError;

  /// No description provided for @smInsufficientStock.
  ///
  /// In en, this message translates to:
  /// **'Insufficient stock for this movement'**
  String get smInsufficientStock;

  /// No description provided for @smReasonPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get smReasonPurchase;

  /// No description provided for @smReasonReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get smReasonReturn;

  /// No description provided for @smReasonAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get smReasonAdjustment;

  /// No description provided for @smReasonTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get smReasonTransfer;

  /// No description provided for @smReasonDamage.
  ///
  /// In en, this message translates to:
  /// **'Damage'**
  String get smReasonDamage;

  /// No description provided for @smReasonExpiryRemoval.
  ///
  /// In en, this message translates to:
  /// **'Expiry removal'**
  String get smReasonExpiryRemoval;

  /// No description provided for @smReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get smReasonOther;

  /// No description provided for @grnInvoiceDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Invoice date is required'**
  String get grnInvoiceDateRequired;

  /// No description provided for @grnCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create the GRN. Please try again.'**
  String get grnCreateError;

  /// No description provided for @grnSupplierInvoiceSection.
  ///
  /// In en, this message translates to:
  /// **'Supplier & invoice'**
  String get grnSupplierInvoiceSection;

  /// No description provided for @grnSupplierNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier name'**
  String get grnSupplierNameLabel;

  /// No description provided for @grnSupplierNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter supplier name'**
  String get grnSupplierNameHint;

  /// No description provided for @grnSupplierRequired.
  ///
  /// In en, this message translates to:
  /// **'Supplier is required'**
  String get grnSupplierRequired;

  /// No description provided for @grnInvoiceNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice number'**
  String get grnInvoiceNumberLabel;

  /// No description provided for @grnInvoiceNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter invoice number'**
  String get grnInvoiceNumberHint;

  /// No description provided for @grnInvoiceNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Invoice number is required'**
  String get grnInvoiceNumberRequired;

  /// No description provided for @grnInvoiceDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice date *'**
  String get grnInvoiceDateLabel;

  /// No description provided for @grnExpectedDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected delivery date'**
  String get grnExpectedDeliveryLabel;

  /// No description provided for @grnCreateDraft.
  ///
  /// In en, this message translates to:
  /// **'Create Draft GRN'**
  String get grnCreateDraft;

  /// No description provided for @grnSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get grnSelectDate;

  /// No description provided for @expiryCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Expiry calendar'**
  String get expiryCalendarTitle;

  /// No description provided for @expiryCalendarLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load calendar data.'**
  String get expiryCalendarLoadError;

  /// No description provided for @expiryCalendarTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to see details'**
  String get expiryCalendarTapHint;

  /// No description provided for @expiryCalendarNoRecords.
  ///
  /// In en, this message translates to:
  /// **'No expiry records for this day'**
  String get expiryCalendarNoRecords;

  /// Header above the selected day's expiry summary.
  ///
  /// In en, this message translates to:
  /// **'Summary for {date}'**
  String expiryCalendarSummaryFor(String date);

  /// No description provided for @exTitle.
  ///
  /// In en, this message translates to:
  /// **'New Expiry Record'**
  String get exTitle;

  /// No description provided for @exMfgAfterExpiry.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing date cannot be after expiry date'**
  String get exMfgAfterExpiry;

  /// No description provided for @exSelectMfg.
  ///
  /// In en, this message translates to:
  /// **'Select manufacturing date'**
  String get exSelectMfg;

  /// No description provided for @exSelectExpiry.
  ///
  /// In en, this message translates to:
  /// **'Select expiry date'**
  String get exSelectExpiry;

  /// No description provided for @exExpiryRequired.
  ///
  /// In en, this message translates to:
  /// **'Expiry date is required'**
  String get exExpiryRequired;

  /// No description provided for @exCreated.
  ///
  /// In en, this message translates to:
  /// **'Expiry record created'**
  String get exCreated;

  /// No description provided for @exOfflineQueued.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — record will sync when you\'re back online'**
  String get exOfflineQueued;

  /// No description provided for @exSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get exSubmitError;

  /// No description provided for @exNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get exNotSet;

  /// No description provided for @exProductIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Product ID'**
  String get exProductIdLabel;

  /// No description provided for @exProductIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter product ID or scan barcode'**
  String get exProductIdHint;

  /// No description provided for @exMfgLabel.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing Date'**
  String get exMfgLabel;

  /// No description provided for @exExpiryLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date *'**
  String get exExpiryLabel;

  /// No description provided for @exBatchLabel.
  ///
  /// In en, this message translates to:
  /// **'Batch Number'**
  String get exBatchLabel;

  /// No description provided for @exLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get exLocationLabel;

  /// No description provided for @exLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Shelf / aisle / zone'**
  String get exLocationHint;

  /// No description provided for @exSaveRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Record'**
  String get exSaveRecord;

  /// No description provided for @exOcrSemantic.
  ///
  /// In en, this message translates to:
  /// **'RADHA reads the date for you'**
  String get exOcrSemantic;

  /// No description provided for @exOcrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the date off the pack'**
  String get exOcrTitle;

  /// No description provided for @exOcrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll read MFG / EXP for you'**
  String get exOcrSubtitle;

  /// No description provided for @grnItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'GRN items'**
  String get grnItemsTitle;

  /// No description provided for @grnItemAdded.
  ///
  /// In en, this message translates to:
  /// **'Item added'**
  String get grnItemAdded;

  /// No description provided for @grnItemSavedOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved offline — it\'ll sync when you\'re back online'**
  String get grnItemSavedOffline;

  /// No description provided for @grnItemAddError.
  ///
  /// In en, this message translates to:
  /// **'Could not add item. Please try again.'**
  String get grnItemAddError;

  /// No description provided for @grnAddItemFirst.
  ///
  /// In en, this message translates to:
  /// **'Add at least one item before posting'**
  String get grnAddItemFirst;

  /// No description provided for @grnPosted.
  ///
  /// In en, this message translates to:
  /// **'GRN posted — stock updated'**
  String get grnPosted;

  /// No description provided for @grnPostQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued — it\'ll post when you\'re back online'**
  String get grnPostQueued;

  /// No description provided for @grnPostError.
  ///
  /// In en, this message translates to:
  /// **'Could not post GRN. Please try again.'**
  String get grnPostError;

  /// No description provided for @grnNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items added yet'**
  String get grnNoItems;

  /// No description provided for @grnNoItemsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to add items'**
  String get grnNoItemsHint;

  /// Running total of received quantity in the GRN items footer.
  ///
  /// In en, this message translates to:
  /// **'Total Qty: {qty}'**
  String grnTotalQty(String qty);

  /// Running total value in the GRN items footer.
  ///
  /// In en, this message translates to:
  /// **'Total: ₹{value}'**
  String grnTotalValue(String value);

  /// No description provided for @grnAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get grnAddItem;

  /// No description provided for @grnPostGrn.
  ///
  /// In en, this message translates to:
  /// **'Post GRN'**
  String get grnPostGrn;

  /// No description provided for @grnPostHint.
  ///
  /// In en, this message translates to:
  /// **'Posting updates stock & resolves low-stock alerts.'**
  String get grnPostHint;

  /// Invoice-number line on the GRN header card.
  ///
  /// In en, this message translates to:
  /// **'Invoice {number}'**
  String grnInvoiceLabel(String number);

  /// Batch chip in a GRN item line.
  ///
  /// In en, this message translates to:
  /// **'Batch {batch}'**
  String grnBatchTag(String batch);

  /// No description provided for @grnBarcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode (EAN / UPC)'**
  String get grnBarcodeLabel;

  /// No description provided for @grnBarcodeHint.
  ///
  /// In en, this message translates to:
  /// **'8–13 digits'**
  String get grnBarcodeHint;

  /// No description provided for @grnProductNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get grnProductNameLabel;

  /// No description provided for @grnMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Must be > 0'**
  String get grnMustBePositive;

  /// No description provided for @grnBatchNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Batch number (optional)'**
  String get grnBatchNumberOptional;

  /// No description provided for @grnMfgDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing date'**
  String get grnMfgDateLabel;

  /// No description provided for @grnExpiryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get grnExpiryDateLabel;

  /// No description provided for @grnUnitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit price (₹)'**
  String get grnUnitPriceLabel;

  /// No description provided for @grnMustBeNonNeg.
  ///
  /// In en, this message translates to:
  /// **'Must be >= 0'**
  String get grnMustBeNonNeg;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bn',
    'en',
    'hi',
    'mr',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
