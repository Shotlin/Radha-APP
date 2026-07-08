// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'RADHA';

  @override
  String get tagline =>
      'தரவு, ஆரோக்கியம் மற்றும் தணிக்கைக்கான சில்லறை உதவியாளர்.';

  @override
  String get continueLabel => 'தொடரவும்';

  @override
  String get getStarted => 'தொடங்கவும்';

  @override
  String get skip => 'தவிர்';

  @override
  String get next => 'அடுத்து';

  @override
  String get back => 'பின்';

  @override
  String get cancel => 'ரத்து';

  @override
  String get save => 'சேமி';

  @override
  String get delete => 'நீக்கு';

  @override
  String get edit => 'திருத்து';

  @override
  String get add => 'சேர்';

  @override
  String get search => 'தேடு';

  @override
  String get loading => 'ஏற்றுகிறது';

  @override
  String get error => 'ஏதோ தவறு நடந்தது';

  @override
  String get tryAgain => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get done => 'முடிந்தது';

  @override
  String get close => 'மூடு';

  @override
  String get signIn => 'உள்நுழை';

  @override
  String get signOut => 'வெளியேறு';

  @override
  String get mobileNumber => 'மொபைல் எண்';

  @override
  String get enterOtp => 'OTP உள்ளிடவும்';

  @override
  String get verifyOtp => 'OTP சரிபார்க்கவும்';

  @override
  String get resendOtp => 'OTP மீண்டும் அனுப்பு';

  @override
  String get otpSent => 'உங்களுக்கு 6 இலக்க குறியீடு அனுப்பப்பட்டது';

  @override
  String get home => 'முகப்பு';

  @override
  String get scan => 'ஸ்கேன்';

  @override
  String get expiry => 'காலாவதி';

  @override
  String get tasks => 'பணிகள்';

  @override
  String get profile => 'சுயவிவரம்';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get language => 'மொழி';

  @override
  String get scanProduct => 'பொருளை ஸ்கேன் செய்';

  @override
  String get pointAtBarcode => 'பார்கோடில் கேமராவை வையுங்கள்';

  @override
  String get scanAgain => 'மீண்டும் ஸ்கேன் செய்';

  @override
  String get productNotFound => 'பொருள் கிடைக்கவில்லை';

  @override
  String get expiryTracker => 'காலாவதி கண்காணிப்பு';

  @override
  String get addExpiry => 'காலாவதி சேர்';

  @override
  String get expiringSoon => 'விரைவில் காலாவதியாகும்';

  @override
  String get expired => 'காலாவதியானது';

  @override
  String get yourTasks => 'உங்கள் பணிகள்';

  @override
  String get noTasks => 'பணிகள் இல்லை';

  @override
  String get completeTask => 'பணியை முடிக்கவும்';

  @override
  String get welcome => 'வரவேற்கிறோம்';

  @override
  String get welcomeMessage =>
      'விரிதாள்கள் இல்லாமல் உங்கள் சரக்கை ஸ்கேன், கண்காணிக்க, தணிக்கை செய்யுங்கள்.';

  @override
  String get referrals => 'பரிந்துரைகள்';

  @override
  String get shareYourCode => 'உங்கள் குறியீட்டைப் பகிரவும்';

  @override
  String get yourReferralCode => 'உங்கள் பரிந்துரை குறியீடு';

  @override
  String get invitees => 'அழைக்கப்பட்டவர்கள்';

  @override
  String get rewardsEarned => 'சம்பாதித்த வெகுமதிகள்';

  @override
  String get redeemCode => 'குறியீட்டை மீட்க';

  @override
  String get enterReferralCode => 'பரிந்துரை குறியீட்டை உள்ளிடவும்';

  @override
  String get chooseLanguage => 'மொழியைத் தேர்ந்தெடு';

  @override
  String get languageUpdated => 'மொழி புதுப்பிக்கப்பட்டது';

  @override
  String get errorGeneric => 'ஏதோ தவறு நடந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String errorRateLimitOtp(int seconds) {
    return 'அதிக OTP கோரிக்கைகள். $seconds வினாடிகளில் மீண்டும் முயற்சிக்கவும்.';
  }

  @override
  String get errorOtpInvalid => 'OTP தவறானது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorOtpExpired => 'OTP காலாவதியானது. புதிய OTP கோரவும்.';

  @override
  String get errorAuthRequired => 'தொடர உள்நுழையவும்.';

  @override
  String get errorNotFound => 'கிடைக்கவில்லை.';

  @override
  String get ingredientExplainerErrorTitle => 'விளக்கத்தை ஏற்ற முடியவில்லை';

  @override
  String get ingredientExplainerHealthConsiderations => 'ஆரோக்கிய கருத்துகள்';

  @override
  String healthyAlternativesTitle(String productName) {
    return '$productName ஐ விட சிறந்த தேர்வுகள்';
  }

  @override
  String get healthyAlternativesGenericTitle => 'சிறந்த தேர்வுகள்';

  @override
  String get healthyAlternativesEmptyTitle =>
      'ஆரோக்கியமான மாற்றுகள் இன்னும் இல்லை';

  @override
  String get healthyAlternativesEmptyBody =>
      'இதே வகையில் இன்னும் ஆரோக்கியமான மாற்றுகள் கிடைக்கவில்லை.';

  @override
  String get healthyAlternativesErrorTitle => 'மாற்றுகளை ஏற்ற முடியவில்லை';

  @override
  String get healthyAlternativesAddToList => 'ஷாப்பிங் பட்டியலில் சேர்';

  @override
  String get healthyAlternativesView => 'காண்';

  @override
  String get healthyAlternativesAddedToList =>
      'ஷாப்பிங் பட்டியலில் சேர்க்கப்பட்டது';

  @override
  String get healthyAlternativesAddFailed =>
      'ஷாப்பிங் பட்டியலில் சேர்க்க முடியவில்லை';

  @override
  String get savedProductsTitle => 'சேமித்த பொருட்கள்';

  @override
  String get savedProductsEmptyTitle => 'சேமித்த பொருட்கள்';

  @override
  String get savedProductsEmptyBody =>
      'ஸ்கேன் முடிவு திரையில் இருந்து பொருட்களை சேமித்தால் அவை இங்கு காண்பிக்கப்படும்.';

  @override
  String get savedProductsErrorTitle => 'சேமித்த பொருட்களை ஏற்ற முடியவில்லை';

  @override
  String savedProductsSavedOn(String date) {
    return '$date அன்று சேமிக்கப்பட்டது';
  }

  @override
  String get digestTitle => 'RADHA-வுடன் உங்கள் வாரம்';

  @override
  String digestWeekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String digestSavingsHero(String amount) {
    return '₹$amount சேமிப்பு';
  }

  @override
  String digestScansHero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ஸ்கேன்கள்',
      one: '1 ஸ்கேன்',
    );
    return '$_temp0';
  }

  @override
  String get digestHeroEmptyHeadline => 'அமைதியான வாரம்';

  @override
  String get digestScans => 'ஸ்கேன்கள்';

  @override
  String get digestSavedProducts => 'சேமிக்கப்பட்டவை';

  @override
  String get digestExpiringSoon => 'விரைவில் காலாவதி';

  @override
  String digestRecallAlerts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ரிகால் எச்சரிக்கைகள்',
      one: '1 ரிகால் எச்சரிக்கை',
    );
    return '$_temp0';
  }

  @override
  String get digestRecallAlertsBody =>
      'இந்த வாரம் நீங்கள் ஸ்கேன் செய்த தயாரிப்புகளுக்கு புதிய பாதுகாப்பு அறிவிப்புகள் உள்ளன.';

  @override
  String get digestRecallAlertsCta => 'பார்க்க';

  @override
  String get digestTopCategoriesHeader => 'நீங்கள் ஸ்கேன் செய்வது';

  @override
  String get digestHighlightsHeader => 'முக்கியாம்சங்கள்';

  @override
  String get digestContinueScanning => 'தொடர்ந்து ஸ்கேன் செய்';

  @override
  String get digestShare => 'என் வாரத்தைப் பகிர்';

  @override
  String digestShareTemplate(int scans, String savings) {
    return 'இந்த வாரம் நான் $scans தயாரிப்புகளை ஸ்கேன் செய்து RADHA மூலம் ₹$savings சேமித்தேன். முயற்சிக்கவும்: https://radha.app';
  }

  @override
  String get digestEmptyTitle => 'இந்த வாரம் செயல்பாடு இல்லை';

  @override
  String get digestEmptyBody =>
      'உங்கள் வார கதையை உருவாக்க ஸ்கேன் செய்யத் தொடங்குங்கள்.';

  @override
  String get digestErrorTitle => 'வாராந்திர சுருக்கத்தை ஏற்ற முடியவில்லை';

  @override
  String get settingsTitle => 'அமைப்புகள்';

  @override
  String get settingsNotifications => 'அறிவிப்புகள்';

  @override
  String get settingsPushNotifications => 'புஷ் அறிவிப்புகள்';

  @override
  String get settingsPushNotificationsHint =>
      'உங்கள் ஃபோனில் எச்சரிக்கைகள் பெறுங்கள்';

  @override
  String get settingsRecallAlerts => 'ரிகால் எச்சரிக்கைகள்';

  @override
  String get settingsRecallAlertsHint =>
      'ஸ்கேன் செய்த தயாரிப்பு திரும்பப் பெறப்படும்போது அறியுங்கள்';

  @override
  String get settingsWeeklyDigest => 'வாராந்திர சுருக்கம்';

  @override
  String get settingsWeeklyDigestHint => 'ஞாயிறு உங்கள் ஸ்கேன்களின் சுருக்கம்';

  @override
  String get settingsAppearance => 'தோற்றம்';

  @override
  String get settingsTheme => 'தீம்';

  @override
  String get settingsThemeSystem => 'சிஸ்டம்';

  @override
  String get settingsThemeLight => 'ஒளி';

  @override
  String get settingsThemeDark => 'இருள்';

  @override
  String get settingsLanguage => 'மொழி';

  @override
  String get settingsTextSize => 'உரை அளவு';

  @override
  String get settingsTextSizeSmall => 'சிறிய';

  @override
  String get settingsTextSizeStandard => 'வழக்கமான';

  @override
  String get settingsTextSizeLarge => 'பெரிய';

  @override
  String get settingsDataPrivacy => 'தரவு மற்றும் தனியுரிமை';

  @override
  String get settingsAllergens => 'ஒவ்வாமை சுயவிவரம்';

  @override
  String get settingsAllergensHint =>
      'எச்சரிக்க வேண்டிய பொருட்களைத் தேர்ந்தெடுக்கவும்';

  @override
  String get settingsSignOutAll => 'அனைத்து சாதனங்களிலிருந்தும் வெளியேறு';

  @override
  String get settingsSignOutAllConfirmTitle => 'எல்லா இடத்திலும் வெளியேற?';

  @override
  String get settingsSignOutAllConfirmBody =>
      'இந்தக் கணக்கைப் பயன்படுத்தும் ஒவ்வொரு சாதனத்திலும் மீண்டும் உள்நுழைய வேண்டும்.';

  @override
  String get settingsDeleteAccount => 'கணக்கை நீக்கு';

  @override
  String get settingsDeleteAccountTitle => 'கணக்கை நீக்கு';

  @override
  String get settingsDeleteAccountBody =>
      'இது உங்கள் தரவை நிரந்தரமாக நீக்கும். உறுதிப்படுத்த DELETE எனத் தட்டச்சிடவும்.';

  @override
  String get settingsDeleteAccountConfirm => 'DELETE';

  @override
  String get settingsDeleteAccountUnavailable =>
      'உங்கள் கணக்கை நீக்க ஆதரவைத் தொடர்புகொள்ளவும்.';

  @override
  String get settingsDeleteAccountContact => 'ஆதரவைத் தொடர்புகொள்ளவும்';

  @override
  String get settingsAbout => 'பற்றி';

  @override
  String get settingsTerms => 'சேவை விதிமுறைகள்';

  @override
  String get settingsPrivacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get settingsVersion => 'ஆப் பதிப்பு';

  @override
  String settingsVersionValue(String version, String build) {
    return 'பதிப்பு $version ($build)';
  }

  @override
  String get settingsSupport => 'ஆதரவு';

  @override
  String get settingsSupportHint =>
      'உதவி பெறுங்கள், பிழையைப் புகாரளிக்கவும், கருத்துப் பகிரவும்';

  @override
  String get settingsLinkOpenFailed => 'இணைப்பைத் திறக்க முடியவில்லை';

  @override
  String conflictBannerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count முரண்பாடுகள் கவனம் தேவை',
      one: '1 முரண்பாடு கவனம் தேவை',
    );
    return '$_temp0';
  }

  @override
  String get conflictBannerCta => 'தீர்க்க';

  @override
  String get conflictBannerDismiss => 'மூடு';

  @override
  String get conflictResolveTitle => 'ஒத்திசைவு முரண்பாடுகளைத் தீர்க்கவும்';

  @override
  String get conflictResolveSubtitle =>
      'ஒவ்வொரு உருப்படிக்கும் எந்தப் பதிப்பை வைத்திருக்க வேண்டும் எனத் தேர்வு செய்யவும்.';

  @override
  String get conflictUseMine => 'என் பதிப்பைப் பயன்படுத்து';

  @override
  String get conflictUseServer => 'சர்வர் பதிப்பைப் பயன்படுத்து';

  @override
  String get conflictResolved => 'முரண்பாடு தீர்ந்தது';

  @override
  String get conflictResolvedAll => 'அனைத்து முரண்பாடுகளும் தீர்க்கப்பட்டன';

  @override
  String conflictAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count முறை முயற்சித்தது',
      one: '1 முறை முயற்சித்தது',
    );
    return '$_temp0';
  }

  @override
  String get conflictResourceTask => 'பணி';

  @override
  String get conflictResourceExpiry => 'காலாவதி பதிவு';

  @override
  String get conflictResourceScan => 'ஸ்கேன்';

  @override
  String get conflictResourceInventory => 'சரக்கு சரிசெய்தல்';

  @override
  String get conflictResourceGrn => 'GRN உள்ளீடு';

  @override
  String get conflictResourceShoppingList => 'ஷாப்பிங் பட்டியல் உருப்படி';

  @override
  String get conflictResourceGeneric => 'ஒத்திசைவு மாற்றம்';

  @override
  String conflictLocalChangeSummary(String summary) {
    return 'உங்கள் மாற்றம்: $summary';
  }

  @override
  String get supportTitle => 'ஆதரவு';

  @override
  String get supportContactUs => 'எங்களைத் தொடர்புகொள்ளுங்கள்';

  @override
  String get supportEmailUs => 'மின்னஞ்சல் அனுப்பு';

  @override
  String get supportEmailUsHint => 'support@radha.app';

  @override
  String get supportCallUs => 'ஆதரவை அழைக்கவும்';

  @override
  String get supportCallUsHint => 'திங்கள்–வெள்ளி, காலை 9 – மாலை 6 IST';

  @override
  String get supportReportBug => 'பிழையைப் புகாரளிக்கவும்';

  @override
  String get supportBugDescription => 'என்ன நடந்தது?';

  @override
  String get supportBugDescriptionHint =>
      'பிழை நிகழ்ந்தபோது நீங்கள் என்ன செய்து கொண்டிருந்தீர்கள் என விளக்கவும்.';

  @override
  String get supportAttachScreenshot => 'ஸ்கிரீன்ஷாட்டை இணைக்கவும்';

  @override
  String get supportScreenshotAttached => 'ஸ்கிரீன்ஷாட் இணைக்கப்பட்டது';

  @override
  String get supportRemoveScreenshot => 'அகற்று';

  @override
  String get supportSubmit => 'அறிக்கையை அனுப்பு';

  @override
  String get supportSubmitted => 'நன்றி — உங்கள் அறிக்கையைப் பெற்றோம்.';

  @override
  String get supportSubmitFailed =>
      'அனுப்ப முடியவில்லை. தயவு செய்து எங்களுக்கு மின்னஞ்சல் அனுப்புங்கள்.';

  @override
  String get supportBugDescriptionRequired => 'என்ன நடந்தது என்பதை விளக்கவும்.';

  @override
  String get supportFaq => 'அடிக்கடி கேட்கப்படும் கேள்விகள்';

  @override
  String get supportFaqQ1 => 'பார்கோடை எவ்வாறு ஸ்கேன் செய்வது?';

  @override
  String get supportFaqA1 =>
      'ஸ்கேன் தாவலைத் திறக்கவும், கேமராவை பார்கோடில் வைத்து நிலையாக வைத்திருங்கள். தெளிவான குறியீட்டைப் படிக்கும் தருணத்தில் தயாரிப்பு தோன்றும்.';

  @override
  String get supportFaqQ2 => 'தயாரிப்பு தரவுத்தளத்தில் இல்லாவிட்டால் என்ன?';

  @override
  String get supportFaqA2 =>
      'காணப்படவில்லை திரையில் \"தயாரிப்பைச் சேர்\" எனத் தட்டவும். உங்கள் ஸ்டோருடன் இணைக்கப்பட்ட புதிய பதிவை உருவாக்கும்.';

  @override
  String get supportFaqQ3 => 'என் சந்தாவை எப்படி ரத்துசெய்வது?';

  @override
  String get supportFaqA3 =>
      'சுயவிவரம் → சந்தா-வுக்குச் செல்லுங்கள். எப்போது வேண்டுமானாலும் ரத்துசெய்யலாம்; அடுத்த பில்லிங் சுழற்சிக்குப் பிறகு கட்டணம் இல்லை.';

  @override
  String get supportFaqQ4 => 'எனக்கு ரிகால் எச்சரிக்கை ஏன் தோன்றுகிறது?';

  @override
  String get supportFaqA4 =>
      'ஒவ்வொரு ஸ்கேனையும் FSSAI ரிகால் ஃபீடுடன் ஒப்பிடுகிறோம். விற்ற பேட்ச் பட்டியலில் இருந்தால் உங்களுக்கு அறிவிக்கிறோம்.';

  @override
  String get supportFaqQ5 =>
      'என் ஒவ்வாமை சுயவிவரத்தைக் குடும்பத்துடன் எப்படி பகிர்வது?';

  @override
  String get supportFaqA5 =>
      'ஒவ்வாமை சுயவிவரம் தற்போது ஒவ்வொரு கணக்குக்கும் தனியானது. ஒரே குடும்பக் கணக்கில் உள்நுழையவும் அல்லது ஒவ்வொரு ஃபோனிலும் அதே ஒவ்வாமைகளைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get reportsTitle => 'Reports & exports';

  @override
  String get reportsTabAvailable => 'Available';

  @override
  String get reportsTabScheduled => 'Scheduled';

  @override
  String get reportsTabHistory => 'History';

  @override
  String get reportsQuickExportsHeader => 'Quick exports';

  @override
  String get reportsInventorySnapshot => 'Inventory snapshot';

  @override
  String get reportsExpiringItems => 'Expiring items';

  @override
  String get reportsSalesSummary => 'Sales summary';

  @override
  String get reportsAuditLog => 'Audit log';

  @override
  String get reportsGenerate => 'Generate';

  @override
  String get reportsGenerateSuccess => 'Report ready';

  @override
  String get reportsGenerateQueued =>
      'Generation started — we\'ll notify you when it\'s ready';

  @override
  String get reportsGenerateFailed => 'Could not start the report';

  @override
  String get reportsDownloadFailed => 'Could not open the download';

  @override
  String get reportsScheduleNew => 'New schedule';

  @override
  String get reportsScheduleCreate => 'Create schedule';

  @override
  String get reportsScheduleSuccess => 'Schedule created';

  @override
  String get reportsScheduleReportLabel => 'Report';

  @override
  String get reportsScheduleDayOfWeek => 'Day of week';

  @override
  String get reportsScheduleDayOfMonth => 'Day of month';

  @override
  String get reportsScheduleTime => 'Time';

  @override
  String get reportsScheduleFormat => 'Format';

  @override
  String get reportsScheduleActionsTooltip => 'Schedule actions';

  @override
  String get reportsFrequency => 'Frequency';

  @override
  String get reportsFrequencyDaily => 'Daily';

  @override
  String get reportsFrequencyWeekly => 'Weekly';

  @override
  String get reportsFrequencyMonthly => 'Monthly';

  @override
  String get reportsPause => 'Pause';

  @override
  String get reportsResume => 'Resume';

  @override
  String get reportsDelete => 'Delete';

  @override
  String get reportsDeleteScheduleTitle => 'Delete schedule?';

  @override
  String get reportsDeleteScheduleBody =>
      'This recurring schedule will stop firing. Past runs stay in your history.';

  @override
  String reportsLastRun(String when) {
    return 'Last run $when';
  }

  @override
  String get reportsLastRunNever => 'Hasn\'t run yet';

  @override
  String reportsNextRun(String when) {
    return 'Next run $when';
  }

  @override
  String get reportsDownload => 'Download';

  @override
  String get reportsStatusCompleted => 'Ready';

  @override
  String get reportsStatusGenerating => 'Generating';

  @override
  String get reportsStatusFailed => 'Failed';

  @override
  String get reportsStatusCancelled => 'Cancelled';

  @override
  String get reportsStatusExpired => 'Expired';

  @override
  String get reportsEmptyTitle => 'No exports yet';

  @override
  String get reportsEmptyBody =>
      'Generate a report from the Available tab and it\'ll show up here.';

  @override
  String get reportsScheduledEmptyTitle => 'No scheduled reports';

  @override
  String get reportsScheduledEmptyBody =>
      'Tap New schedule to have a report run automatically.';

  @override
  String get reportsErrorTitle => 'Could not load reports';

  @override
  String get ohsTitle => 'Operational health';

  @override
  String get ohsScoreCaption => 'OHS score';

  @override
  String ohsScore(int score) {
    return '$score';
  }

  @override
  String ohsDeltaUp(int value) {
    return '+$value from last week';
  }

  @override
  String ohsDeltaDown(int value) {
    return '-$value from last week';
  }

  @override
  String get ohsDeltaSame => 'No change from last week';

  @override
  String get ohsDeltaUnavailable =>
      'Not enough data for a week-over-week comparison yet';

  @override
  String get ohsCompliance => 'Compliance';

  @override
  String get ohsInventoryHygiene => 'Inventory hygiene';

  @override
  String get ohsAuditCompletion => 'Audit completion';

  @override
  String get ohsActionItemsHeader => 'Action items';

  @override
  String ohsActionExpiry(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expiry alerts need a review',
      one: '1 expiry alert needs a review',
    );
    return '$_temp0';
  }

  @override
  String ohsActionLowStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count low-stock alerts are unresolved',
      one: '1 low-stock alert is unresolved',
    );
    return '$_temp0';
  }

  @override
  String get ohsActionTasks => 'Review open tasks for your store';

  @override
  String get ohsActionNoneBody =>
      'Everything looks good — keep scanning to maintain your score.';

  @override
  String get ohsTrendHeader => 'Trend';

  @override
  String get ohsViewDetailedReports => 'View detailed reports';

  @override
  String get ohsEmptyTitle => 'Build your operational health score';

  @override
  String get ohsEmptyBody => 'Start scanning to build your OHS score.';

  @override
  String get ohsErrorTitle => 'Could not load your dashboard';

  @override
  String get expiryTabNear => 'விரைவில் காலாவதி';

  @override
  String get expiryTabSafe => 'பாதுகாப்பானது';

  @override
  String get expiryCalendarTooltip => 'காலெண்டர் காட்சி';

  @override
  String get expiryEmptyExpiredTitle => 'எதுவும் காலாவதியாகவில்லை';

  @override
  String get expiryEmptyNearTitle => 'எல்லாம் சரி';

  @override
  String get expiryEmptyDefaultTitle => 'இன்னும் பதிவுகள் இல்லை';

  @override
  String get expiryEmptyBody => 'இந்தப் பிரிவில் பதிவுகள் இல்லை.';

  @override
  String expiryProductShort(String id) {
    return 'பொருள் $id';
  }

  @override
  String expiryBatch(String batch) {
    return 'தொகுதி $batch';
  }

  @override
  String expiryQty(String qty) {
    return 'அளவு $qty';
  }

  @override
  String expiryExp(String date) {
    return 'காலாவதி $date';
  }

  @override
  String get expiryPillToday => 'இன்று';

  @override
  String get expiryPillTomorrow => 'நாளை';

  @override
  String expiryPillDays(int days) {
    return '${days}d';
  }

  @override
  String get expiryPillSoon => 'விரைவில்';

  @override
  String get expiryLoadError => 'காலாவதிப் பதிவுகளை ஏற்ற முடியவில்லை.';

  @override
  String get expiryCouldNotLoadSemantic => 'ஏற்ற முடியவில்லை';

  @override
  String get inventoryTitle => 'சரக்கு';

  @override
  String get inventorySearchTooltip => 'சரக்கைத் தேடு';

  @override
  String get inventorySearchHint => 'பொருள் அல்லது EAN மூலம் தேடு...';

  @override
  String get inventoryStockMovement => 'சரக்கு நகர்வு';

  @override
  String get inventoryLowStockAlerts => 'குறைந்த சரக்கு எச்சரிக்கைகள்';

  @override
  String get inventoryLoadError => 'சரக்கை ஏற்ற முடியவில்லை';

  @override
  String get inventoryEmpty => 'சரக்கு உருப்படிகள் எதுவும் இல்லை';

  @override
  String inventoryNoMatches(String query) {
    return '\"$query\" க்கு பொருத்தம் இல்லை';
  }

  @override
  String inventoryProductShort(String id) {
    return 'பொருள் $id';
  }

  @override
  String get inventoryBelowThreshold => 'வரம்புக்குக் கீழே';

  @override
  String get inventoryInStock => 'கையிருப்பில்';

  @override
  String get inventoryUnitsLabel => 'யூனிட்கள்';

  @override
  String get inventoryTotalQuantity => 'மொத்த அளவு';

  @override
  String get inventoryLowStockThreshold => 'குறைந்த சரக்கு வரம்பு';

  @override
  String inventoryQtyUnits(int count) {
    return '$count யூனிட்கள்';
  }

  @override
  String get inventoryBatchLedgerHint =>
      'முழு தொகுதி பேரேட்டைப் பார்க்க \"சரக்கு நகர்வு\" தட்டவும்.';

  @override
  String get inventoryLowStockBadge => 'குறைந்த சரக்கு';

  @override
  String get tasksTitle => 'பணிகள்';

  @override
  String get tasksTabMine => 'என் பணிகள்';

  @override
  String get tasksTabAll => 'அனைத்தும்';

  @override
  String get tasksNewTask => 'புதிய பணி';

  @override
  String get tasksEmptyTitle => 'இங்கே பணிகள் இல்லை';

  @override
  String get tasksEmptyBody =>
      'இந்தக் காட்சிக்கு ஒதுக்கப்பட்ட பணிகள் இங்கே தோன்றும்.';

  @override
  String get tasksLoadError => 'பணிகளை ஏற்ற முடியவில்லை';

  @override
  String get taskEvidence => 'சான்று';

  @override
  String get priorityHigh => 'உயர்';

  @override
  String get priorityMedium => 'நடுத்தர';

  @override
  String get priorityLow => 'குறைந்த';

  @override
  String get priorityUrgent => 'அவசரம்';

  @override
  String get taskStatusOpen => 'திறந்தது';

  @override
  String get taskStatusPending => 'நிலுவையில்';

  @override
  String get taskStatusInProgress => 'செயலில் உள்ளது';

  @override
  String get taskStatusCompleted => 'முடிந்தது';

  @override
  String get taskStatusCancelled => 'ரத்து செய்யப்பட்டது';

  @override
  String get scanTitle => 'ஒரு பொருளை ஸ்கேன் செய்';

  @override
  String get scanAlignHint => 'பார்கோடை சட்டகத்திற்குள் சீரமைக்கவும்';

  @override
  String get scanBatchHint =>
      'தொகுதி பயன்முறை — ஸ்கேன் செய்துகொண்டே இருங்கள், உருப்படிகள் தானாகவே சேர்க்கப்படும்';

  @override
  String scanBatchAdded(String code, int count) {
    return '$code சேர்க்கப்பட்டது · $count ஸ்கேன் செய்யப்பட்டது';
  }

  @override
  String scanBatchDone(int count) {
    return 'முடிந்தது · $count';
  }

  @override
  String get scanLabelAction => 'லேபிளை ஸ்கேன் செய்';

  @override
  String get scanGalleryAction => 'கேலரி';

  @override
  String get scanEnterManually => 'கைமுறையாக உள்ளிடவும்';

  @override
  String get scanBulkAudit => 'மொத்த தணிக்கை';

  @override
  String get scanHistoryAction => 'வரலாறு';

  @override
  String get scanFlash => 'ஃபிளாஷ்';

  @override
  String get scanTroubleTitle => 'ஸ்கேன் செய்வதில் சிக்கலா?';

  @override
  String get scanTroubleBody =>
      'மங்கலான வெளிச்சம் அல்லது சேதமடைந்த பார்கோடா? ஃபிளாஷை இயக்கவும், அல்லது அதற்குப் பதிலாக லேபிளைப் படிக்கவும்.';

  @override
  String get scanGalleryNoBarcode =>
      'பார்கோடு எதுவும் இல்லை. குறிப்பு: பொருட்களைப் படிக்க \'லேபிளை ஸ்கேன் செய்\' பயன்படுத்தவும்.';

  @override
  String get scanInvalidEan =>
      'சரியான EAN-8, EAN-13, அல்லது UPC-A குறியீட்டை உள்ளிடவும்';

  @override
  String get scanWebTitle => 'ஸ்கேன்';

  @override
  String get scanWebUnavailable =>
      'வலையில் கேமரா ஸ்கேனிங் கிடைக்காது.\nபார்கோடை கைமுறையாக உள்ளிடவும்:';

  @override
  String get scanEanFieldLabel => 'EAN / UPC குறியீடு';

  @override
  String get scanEanHintExample => 'எ.கா. 5901234123457';

  @override
  String get scanLookUp => 'தேடு';

  @override
  String get scanEnterBarcode => 'பார்கோடை உள்ளிடவும்';

  @override
  String get scanHistoryTitle => 'ஸ்கேன் வரலாறு';

  @override
  String get scanNoHistory => 'இந்த அமர்வில் இன்னும் ஸ்கேன் இல்லை.';

  @override
  String get homeGreetingMorning => 'காலை வணக்கம்';

  @override
  String get homeGreetingAfternoon => 'மதிய வணக்கம்';

  @override
  String get homeGreetingEvening => 'மாலை வணக்கம்';

  @override
  String get homeGreetingFallbackName => 'நண்பரே';

  @override
  String get homeTrialEnded =>
      'இலவச சோதனை முடிந்தது — அணுகலைத் தொடர அப்கிரேடு செய்யவும்';

  @override
  String homeTrialDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days நாட்கள்',
      one: '1 நாள்',
    );
    return 'இலவச சோதனை · $_temp0 மீதம்';
  }

  @override
  String get homeUpgradeArrow => 'அப்கிரேடு →';

  @override
  String get homeKpiSaved => 'சேமித்தவை';

  @override
  String get homeKpiNearExpiry => 'விரைவில் காலாவதி';

  @override
  String get homeKpiRecallAlerts => 'ரீகால் எச்சரிக்கைகள்';

  @override
  String get homeKpiOpenTasks => 'திறந்த பணிகள்';

  @override
  String get homeKpiLowStock => 'குறைந்த சரக்கு';

  @override
  String get homeEyebrowFoodSafety => 'உணவு பாதுகாப்பு எச்சரிக்கை';

  @override
  String get homeEyebrowToday => 'இன்றைய பணி';

  @override
  String get homeEyebrowHealthScan => 'உங்கள் ஹெல்த் ஸ்கேன்';

  @override
  String get homeEyebrowScanToLearn => 'ஸ்கேன் செய்து அறியுங்கள்';

  @override
  String get homeEyebrowAllClear => 'எல்லாம் சரி';

  @override
  String homeStoryRecall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count ரீகால் செய்யப்பட்ட பொருட்கள் — உங்கள் வீட்டில் உள்ளதைப் பார்க்கவும்',
      one: '1 ரீகால் செய்யப்பட்ட பொருள் — உங்கள் வீட்டில் உள்ளதைப் பார்க்கவும்',
    );
    return '$_temp0';
  }

  @override
  String homeStoryNearExpiryConsumer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count சேமித்த பொருட்கள் இந்த வாரம் காலாவதியாகின்றன — பயன்படுத்துங்கள்',
      one: '1 சேமித்த பொருள் இந்த வாரம் காலாவதியாகிறது — பயன்படுத்துங்கள்',
    );
    return '$_temp0';
  }

  @override
  String get homeStoryKnowWhatYouEat => 'நீங்கள் சாப்பிடுவதை அறியுங்கள்';

  @override
  String get homeStoryScanInside =>
      'எந்த உணவு பார்கோடிலும் கேமராவை வைக்கவும் — உள்ளே என்ன இருக்கிறது என்பதைப் பார்க்கவும்';

  @override
  String homeStoryNearExpiryBusiness(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பொருட்கள் விரைவில் காலாவதி — அலமாரியை காலி செய்யுங்கள்',
      one: '1 பொருள் விரைவில் காலாவதி — அலமாரியை காலி செய்யுங்கள்',
    );
    return '$_temp0';
  }

  @override
  String homeStoryOpenTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பணிகளுக்கு இன்று உங்கள் தேவை',
      one: '1 பணிக்கு இன்று உங்கள் தேவை',
    );
    return '$_temp0';
  }

  @override
  String homeStoryLowStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பொருட்களின் சரக்கு குறைகிறது',
      one: '1 பொருளின் சரக்கு குறைகிறது',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreToday => 'இதோ இன்று உங்கள் கடை';

  @override
  String get homeStoreAllGood =>
      'ஷபாஷ்! உங்கள் கடை இன்று சிறந்த நிலையில் உள்ளது';

  @override
  String get homeCtaViewRecallAlerts => 'ரீகால் எச்சரிக்கைகளைப் பார்க்கவும்';

  @override
  String get homeCtaCheckExpiry => 'காலாவதியைப் பார்க்கவும்';

  @override
  String get homeCtaOpenExpiry => 'காலாவதியைத் திறக்கவும்';

  @override
  String get homeCtaViewTasks => 'பணிகளைப் பார்க்கவும்';

  @override
  String get homeCtaCheckInventory => 'சரக்கைப் பார்க்கவும்';

  @override
  String get homeCtaOpenTasks => 'பணிகளைத் திறக்கவும்';

  @override
  String get homeCtaRunAudit => 'ஒரு விரைவு தணிக்கையை இயக்கவும்';

  @override
  String get homeQuickActions => 'விரைவு செயல்கள்';

  @override
  String get homeQuickScan => 'ஸ்கேன்';

  @override
  String get homeQuickShopping => 'ஷாப்பிங்';

  @override
  String get homeQuickAddExpiry => 'காலாவதி சேர்க்கவும்';

  @override
  String get homeQuickNewTask => 'புதிய பணி';

  @override
  String get homeRecentTasks => 'சமீபத்திய பணிகள்';

  @override
  String get homeSeeAll => 'அனைத்தையும் பார்க்கவும்';

  @override
  String get homeNoOpenTasks => 'திறந்த பணிகள் இல்லை — ஒன்றை உருவாக்கவும்';

  @override
  String homeTaskAssignedTo(String name) {
    return '$name க்கு ஒதுக்கப்பட்டது';
  }

  @override
  String get homeTaskOverdue => 'தாமதம்';

  @override
  String get homeTaskDueToday => 'இன்று செலுத்த வேண்டியது';

  @override
  String get homeTaskDueTomorrow => 'நாளை செலுத்த வேண்டியது';

  @override
  String homeTaskDueInDays(int days) {
    return '$days நாட்களில் செலுத்த வேண்டியது';
  }

  @override
  String homeTaskDueOn(String date) {
    return '$date அன்று செலுத்த வேண்டியது';
  }

  @override
  String get homeHowHelps => 'RADHA உங்களுக்கு எப்படி உதவுகிறது';

  @override
  String get homeScanBarcodeTitle =>
      'எந்த உணவு பார்கோடையும் ஸ்கேன் செய்யுங்கள்';

  @override
  String get homeScanBarcodeBody =>
      'ஹெல்த் மதிப்பீடு, பொருட்கள், எதைக் கவனிக்க வேண்டும் — அனைத்தையும் பார்க்கவும்.';

  @override
  String get homeRecallTitle => 'பாதுகாப்பு ரீகால் எச்சரிக்கைகள்';

  @override
  String get homeRecallBody =>
      'ரீகால் செய்யப்பட்ட உணவுப் பொருட்கள் குறித்து அறிந்திருங்கள்.';

  @override
  String get homePromoKnowFoodEyebrow => 'உங்கள் உணவை அறியுங்கள்';

  @override
  String get homePromoKnowFoodHeadline =>
      'லேபிளை ஸ்கேன் செய்யுங்கள் — உண்மையில் உள்ளே என்ன இருக்கிறது என்பதைப் பார்க்கவும்';

  @override
  String get homePromoKnowFoodCta => 'ஸ்கேன் செய்து அறியுங்கள்';

  @override
  String get homePromoExpiryEyebrow => 'எந்த தேதியையும் தவறவிடாதீர்கள்';

  @override
  String get homePromoExpiryHeadline =>
      'ஒவ்வொரு காலாவதியையும் நழுவுவதற்கு முன் பிடியுங்கள்';

  @override
  String get homePromoExpiryCta => 'காலாவதியைக் கண்காணியுங்கள்';

  @override
  String get homePromoFestiveEyebrow => 'பண்டிகை தேர்வுகள்';

  @override
  String get homePromoFestiveHeadline =>
      'பருவத்தை ஆரோக்கியமான முறையில் வாங்குங்கள்';

  @override
  String get homePromoFestiveCta => 'பொருட்களை உலாவுங்கள்';

  @override
  String get homePromoBazaarEyebrow => 'இன்றைய சந்தை';

  @override
  String get homePromoBazaarHeadline =>
      'நிமிடங்களில் உங்கள் அலமாரிகளை தணிக்கை செய்யுங்கள்';

  @override
  String get homePromoBazaarCta => 'தணிக்கையைத் தொடங்குங்கள்';

  @override
  String get homeShopByCategory => 'வகை வாரியாக வாங்குங்கள்';

  @override
  String get homeShopByCategorySubtitle =>
      'ஸ்கேன் செய்ய அல்லது உலாவ ஒரு பிரிவைத் தட்டவும்';

  @override
  String get onboardingWelcomeValue =>
      'ஸ்கேன் செய்யுங்கள், கண்காணியுங்கள், உங்கள் சரக்கை தணிக்கை செய்யுங்கள் — ஸ்ப்ரெட்ஷீட் இல்லாமல்.';

  @override
  String get onboardingCapabilitiesTitle =>
      'கடை தளத்திற்காக உருவாக்கப்பட்டது,\nஅலுவலகத்திற்காக அல்ல.';

  @override
  String get onboardingCapScanTitle =>
      'ஒரே தட்டில் பொருட்களை ஸ்கேன் செய்யுங்கள்';

  @override
  String get onboardingCapScanBody =>
      'ஹெல்த் மற்றும் ஒப்புதல் முன்கூட்டியே சரிபார்க்கப்பட்ட EAN தேடல்.';

  @override
  String get onboardingCapExpiryTitle =>
      'உங்களுக்கு நஷ்டம் ஏற்படுவதற்கு முன் காலாவதியைப் பிடியுங்கள்';

  @override
  String get onboardingCapExpiryBody =>
      'OCR-உதவியுடன் தேதிகள் மற்றும் வகை வாரியான வரம்புகள்.';

  @override
  String get onboardingCapAuditTitle =>
      'குழு முடிக்கக்கூடிய தணிக்கைகளை இயக்குங்கள்';

  @override
  String get onboardingCapAuditBody =>
      'பணிகள், சான்றுகள் மற்றும் மொத்த ஸ்கேன் அமர்வுகள்.';

  @override
  String get onboardingSegmentTitle => 'நீங்கள் இங்கே யாராக இருக்கிறீர்கள்?';

  @override
  String get onboardingSegmentSubtitle =>
      'மிக நெருக்கமான பொருத்தத்தைத் தேர்ந்தெடுக்கவும். பின்னர் அமைப்புகளில் மாற்றலாம்.';

  @override
  String get segmentPersonalTitle => 'தனிப்பட்ட';

  @override
  String get segmentPersonalBody => 'எனக்காக மட்டுமே வாங்குகிறேன்';

  @override
  String get segmentParentTitle => 'பெற்றோர்';

  @override
  String get segmentParentBody =>
      'என் குடும்பம் / குழந்தைகளுக்காக வாங்குகிறேன்';

  @override
  String get segmentBusinessTitle => 'வணிக உரிமையாளர்';

  @override
  String get segmentBusinessBody => 'நான் ஒரு சிறிய சில்லறை கடை நடத்துகிறேன்';

  @override
  String get segmentPharmacyTitle => 'மருந்தகம்';

  @override
  String get segmentPharmacyBody =>
      'நான் ஒரு மருந்தகம் / கெமிஸ்ட் நடத்துகிறேன்';

  @override
  String get segmentInstitutionTitle => 'நிறுவனம்';

  @override
  String get segmentInstitutionBody => 'பள்ளி / விடுதி / உணவகம்';

  @override
  String get segmentAuditorTitle => 'தணிக்கையாளர் (அழைக்கப்பட்டவர்)';

  @override
  String get segmentAuditorBody => 'என்னிடம் அழைப்புக் குறியீடு உள்ளது';

  @override
  String get allergenTitle => 'ஒவ்வாமைகள்';

  @override
  String get allergenLoadError =>
      'உங்கள் ஒவ்வாமை சுயவிவரத்தை ஏற்ற முடியவில்லை.';

  @override
  String get allergenHeading => 'உங்கள் ஒவ்வாமைகள்';

  @override
  String get allergenIntro =>
      'உங்களுக்கு ஒவ்வாமை ஏற்படுத்தும் எவற்றையும் தட்டவும். ஸ்கேன் செய்யப்பட்ட பொருளில் அவை இருந்தால் நாங்கள் உங்களை எச்சரிப்போம்.';

  @override
  String allergenTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ஒவ்வாமைகள் கண்காணிக்கப்படுகின்றன',
      one: '1 ஒவ்வாமை கண்காணிக்கப்படுகிறது',
    );
    return '$_temp0';
  }

  @override
  String get allergenNoneTracked =>
      'இன்னும் ஒவ்வாமைகள் எதுவும் கண்காணிக்கப்படவில்லை';

  @override
  String get allergenSavedCleared => 'ஒவ்வாமை சுயவிவரம் அழிக்கப்பட்டது.';

  @override
  String get allergenSaved => 'ஒவ்வாமை சுயவிவரம் சேமிக்கப்பட்டது.';

  @override
  String get allergenSaveError => 'உங்கள் ஒவ்வாமைகளை சேமிக்க முடியவில்லை.';

  @override
  String get allergenPeanut => 'வேர்க்கடலை';

  @override
  String get allergenTreeNut => 'மரக் கொட்டை';

  @override
  String get allergenDairy => 'பால் பொருட்கள்';

  @override
  String get allergenEggs => 'முட்டை';

  @override
  String get allergenSoy => 'சோயா';

  @override
  String get allergenWheat => 'கோதுமை';

  @override
  String get allergenFish => 'மீன்';

  @override
  String get allergenShellfish => 'ஓட்டுமீன்';

  @override
  String get allergenSesame => 'எள்';

  @override
  String get allergenGluten => 'குளுட்டன்';

  @override
  String get allergenMustard => 'கடுகு';

  @override
  String get allergenCelery => 'செலரி';

  @override
  String get allergenLupin => 'லூபின்';

  @override
  String get allergenMolluscs => 'மெல்லுடலி';

  @override
  String get allergenSulphites => 'சல்பைட்டுகள்';

  @override
  String get commonSuccess => 'வெற்றி';

  @override
  String lockedFeatureUpgradeTo(String planName) {
    return '$planName க்கு அப்கிரேடு செய்யுங்கள்';
  }

  @override
  String lockedFeaturePlan(String planName) {
    return 'இந்த அம்சம் $planName திட்டத்தின் ஒரு பகுதி.';
  }

  @override
  String get lockedFeatureViewPlans => 'திட்டங்களைப் பார்க்கவும்';

  @override
  String get notFoundSemantic => 'பக்கம் இல்லை';

  @override
  String get notFoundTitle => 'இந்தப் பக்கம் தொலைந்துவிட்டது';

  @override
  String get notFoundBody =>
      'நீங்கள் தேடியதை எங்களால் கண்டுபிடிக்க முடியவில்லை. உங்களை மீண்டும் முகப்புக்கு அழைத்துச் செல்கிறோம்.';

  @override
  String get notFoundBackHome => 'முகப்புக்குத் திரும்பு';

  @override
  String get commonCouldNotLoad => 'ஏற்ற முடியவில்லை';

  @override
  String get sendOtp => 'OTP அனுப்பு';

  @override
  String get otpUseCode => 'குறியீட்டைப் பயன்படுத்து';

  @override
  String get ohsPickStore =>
      'டாஷ்போர்டைத் திறக்கும் முன் ஒரு கடையைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get profileAccount => 'கணக்கு';

  @override
  String get profileManageStores => 'கடைகளை நிர்வகி';

  @override
  String get profileSavedProducts => 'சேமித்த பொருட்கள்';

  @override
  String get profileSubscription => 'சந்தா';

  @override
  String get profilePreferences => 'விருப்பங்கள்';

  @override
  String get profileAllergenProfile => 'ஒவ்வாமை சுயவிவரம்';

  @override
  String get profileShoppingList => 'ஷாப்பிங் பட்டியல்';

  @override
  String get recallTitle => 'ரீகால் எச்சரிக்கைகள்';

  @override
  String recallProductFallback(String id) {
    return 'தயாரிப்பு $id';
  }

  @override
  String recallDate(String date) {
    return 'திரும்பப் பெறப்பட்டது $date';
  }

  @override
  String get recallViewProduct => 'தயாரிப்பைப் பார்';

  @override
  String get recallLoadError => 'ரீகால்களை ஏற்ற முடியவில்லை.';

  @override
  String get recallEmpty => 'செயலில் ரீகால்கள் இல்லை';

  @override
  String get recallEmptyBody =>
      'ஒழுங்குமுறை அமைப்புகளால் வெளியிடப்படும்போது தயாரிப்பு ரீகால் எச்சரிக்கைகள் இங்கே தோன்றும்.';

  @override
  String get referralsLoadError => 'பரிந்துரைகளை ஏற்ற முடியவில்லை.';

  @override
  String get referralsCopyCode => 'குறியீட்டை நகலெடு';

  @override
  String get referralsShareInvite => 'அழைப்பைப் பகிர்';

  @override
  String get referralsCodeCopied => 'குறியீடு நகலெடுக்கப்பட்டது';

  @override
  String get referralsInvitees => 'அழைக்கப்பட்டவர்கள்';

  @override
  String get referralsRewardsEarned => 'பெற்ற வெகுமதிகள்';

  @override
  String get referralsCodeRedeemed => 'குறியீடு பயன்படுத்தப்பட்டது';

  @override
  String get referralsEnterCode => 'ஒரு பரிந்துரைக் குறியீட்டை உள்ளிடவும்';

  @override
  String get referralsRedeem => 'பயன்படுத்து';

  @override
  String get referralsRedeemError => 'குறியீட்டைப் பயன்படுத்த முடியவில்லை';

  @override
  String get referralsRedeemSubtitle =>
      'நண்பரின் அழைப்பு உள்ளதா? கீழே அவர்களின் குறியீட்டை உள்ளிடவும்.';

  @override
  String get commonClear => 'அழி';

  @override
  String get commonShare => 'பகிர்';

  @override
  String get healthSugar => 'சர்க்கரை';

  @override
  String get healthSalt => 'உப்பு';

  @override
  String get healthFat => 'கொழுப்பு';

  @override
  String get healthProcessed => 'பதப்படுத்தப்பட்டது';

  @override
  String get healthChildSuitable => 'குழந்தைகளுக்கு ஏற்றது';

  @override
  String get productDetailsTitle => 'பொருள் விவரங்கள்';

  @override
  String get productDetailLoadError => 'இந்தப் பொருளை ஏற்ற முடியவில்லை';

  @override
  String get productCheckAllergens => 'ஒவ்வாமைகளைச் சரிபார்';

  @override
  String get productExplainIngredients => 'பொருட்களை விளக்கு';

  @override
  String get productSeeHealthierOptions => 'ஆரோக்கியமான தேர்வுகளைப் பார்';

  @override
  String get productViewHealthyAlternatives => 'ஆரோக்கியமான மாற்றுகளைப் பார்';

  @override
  String get productHealthAssessment => 'ஆரோக்கிய மதிப்பீடு';

  @override
  String get productNutritionInfo => 'ஊட்டச்சத்து தகவல்';

  @override
  String get productAllergenCheck => 'ஒவ்வாமை சரிபார்ப்பு';

  @override
  String get productSeeFullExplanation => 'முழு விளக்கத்தைப் பார்';

  @override
  String get productHealthierOptions => 'ஆரோக்கியமான தேர்வுகள்';

  @override
  String get commonYes => 'ஆம்';

  @override
  String get nutritionProtein => 'புரதம்';

  @override
  String get nutritionTotalSugars => 'மொத்த சர்க்கரை';

  @override
  String get nutritionEnergy => 'ஆற்றல்';

  @override
  String get nutritionTotalFat => 'மொத்த கொழுப்பு';

  @override
  String get nutritionSaturatedFat => 'நிறைவுற்ற கொழுப்பு';

  @override
  String get nutritionCarbohydrates => 'கார்போஹைட்ரேட்டுகள்';

  @override
  String get nutritionFibre => 'நார்ச்சத்து';

  @override
  String get nutritionSodium => 'சோடியம்';

  @override
  String get nutritionAll => 'அனைத்து ஊட்டச்சத்துக்கள்';

  @override
  String get nutritionPer100g => '100 கிராமுக்கு';

  @override
  String get nutritionPer50g => '50 கிராமுக்கு';

  @override
  String get productDetailSavedAlert =>
      'சேமிக்கப்பட்டது — இது எப்போதேனும் ரீகால் செய்யப்பட்டால் உங்களுக்கு அறிவிப்போம்.';

  @override
  String get productDetailSaveError =>
      'சேமிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get productDetailWhatYoullLike => 'உங்களுக்கு என்ன பிடிக்கும்';

  @override
  String get productDetailWhatConcern => 'எது உங்களைக் கவலைப்பட வைக்க வேண்டும்';

  @override
  String get productDetailIngredientDeepDive => 'பொருட்கள் ஆழமாக';

  @override
  String get productDetailPersonalisedFlags => 'தனிப்பயன் கொடிகள்';

  @override
  String get productDetailAlreadyBought => 'ஏற்கனவே வாங்கியது';

  @override
  String get productDetailScanToUnlock => 'திறக்க ஸ்கேன் செய்';

  @override
  String get productDetailTitle => 'தயாரிப்பு';

  @override
  String get productDetailSave => 'சேமி';

  @override
  String get productDetailSaved => 'சேமிக்கப்பட்டது';

  @override
  String get productDetailHealthNotRated => 'ஆரோக்கிய மதிப்பீடு இன்னும் இல்லை';

  @override
  String get productDetailHealthNotRatedBody =>
      'இந்த தயாரிப்பின் முழு ஆரோக்கிய பகுப்பாய்வை RADHA இல் கொண்டு வர ஸ்கேன் செய்யவும்.';

  @override
  String get productDetailHealthLabel => 'RADHA ஆரோக்கிய மதிப்பீடு';

  @override
  String get productDetailHighProtein => 'அதிக புரதம்';

  @override
  String get productDetailGoodFibre => 'நல்ல நார்ச்சத்து';

  @override
  String get productDetailMinimallyProcessed => 'குறைந்த பதப்படுத்தல்';

  @override
  String get productDetailHighSugar => 'அதிக சர்க்கரை';

  @override
  String get productDetailHighSatFat => 'அதிக நிறைவுற்ற கொழுப்பு';

  @override
  String get productDetailHighSodium => 'அதிக சோடியம்';

  @override
  String get productDetailUltraProcessed => 'அதிக பதப்படுத்தப்பட்டது';

  @override
  String get productDetailNutritionNote =>
      'தயாரிப்பின் உண்மையான ஊட்டச்சத்து (100 கிராம்) அடிப்படையில்.';

  @override
  String get productDetailKeyNutrients => 'முக்கிய ஊட்டச்சத்துக்கள்';

  @override
  String get productDetailRdaNote => '% தினசரி குறிப்பு உட்கொள்ளல் (பெரியவர்).';

  @override
  String get productDetailForYou => 'உங்களுக்காக';

  @override
  String get productDetailIngredientLockBody =>
      'ஒவ்வொரு பொருளும் பாதுகாப்பு தீர்ப்புடன் விளக்கப்பட்டது — அது என்ன, ஏன் உள்ளது, கவலைப்பட வேண்டுமா என்பதை அறியுங்கள்.';

  @override
  String get productDetailIngredientError =>
      'இந்த பொருட்களை இப்போது விளக்க முடியவில்லை.';

  @override
  String get productDetailAllergenLockBody =>
      'இந்த தயாரிப்பை உங்கள் சேமித்த ஒவ்வாமைகள் மற்றும் ஆரோக்கிய இலக்குகளுடன் ஒப்பிடுங்கள்.';

  @override
  String get productDetailAllergenError => 'இப்போது தனிப்பயனாக்க முடியவில்லை.';

  @override
  String get productDetailNoAllergens =>
      'இந்த தயாரிப்பில் ஒவ்வாமை பொருட்கள் கண்டறியவில்லை.';

  @override
  String productDetailAllergenAvoid(String name) {
    return '$name — நீங்கள் இதை தவிர்க்கிறீர்கள்';
  }

  @override
  String productDetailUnlockWith(String plan) {
    return '$plan மூலம் திறக்கவும்';
  }

  @override
  String get productDetailWouldYouBuy => 'இந்த தயாரிப்பை வாங்குவீர்களா?';

  @override
  String get productDetailThanksForSharing => 'பகிர்ந்தமைக்கு நன்றி!';

  @override
  String get productDetailNutritionNotIn => 'முழு ஊட்டச்சத்து இன்னும் இல்லை';

  @override
  String get productDetailNutritionNotInBody =>
      'உண்மையான ஊட்டச்சத்து மற்றும் ஆரோக்கிய பகுப்பாய்வை RADHA இல் கொண்டு வர இந்த தயாரிப்பின் பார்கோடை ஸ்கேன் செய்யவும்.';

  @override
  String productDetailShareText(String name) {
    return 'RADHA இல் \"$name\" சரிபார்க்கப்பட்டது.';
  }

  @override
  String productDetailShareTextRated(String name, String rating, String label) {
    return 'RADHA இல் \"$name\" சரிபார்க்கப்பட்டது — RADHA ஆரோக்கிய மதிப்பீடு $rating/5 ($label).';
  }

  @override
  String get catalogSearchBarLabel =>
      'உங்களுக்கு பொருந்தும் தயாரிப்பைத் தேடுங்கள்';

  @override
  String get catalogSearchPromptTitle => 'ஒரு தயாரிப்பைக் கண்டுபிடி';

  @override
  String get catalogSearchPromptBody =>
      'ஆரோக்கிய மதிப்பீடு மற்றும் உள்ளடக்கம் காண தயாரிப்பு பெயர் அல்லது பிராண்டால் தேடுங்கள்.';

  @override
  String get commonNo => 'இல்லை';

  @override
  String get scanApprovalNotInAudit => 'ஒப்புதல் நிலை — தணிக்கையில் இல்லை';

  @override
  String get scanApprovalChecking =>
      'அங்கீகரிக்கப்பட்ட பட்டியலைச் சரிபார்க்கிறது…';

  @override
  String get scanApprovalCheckFailed => 'ஒப்புதலைச் சரிபார்க்க முடியவில்லை';

  @override
  String get scanApprovalApproved => 'அங்கீகரிக்கப்பட்டது — பட்டியலில்';

  @override
  String get scanApprovalNoList => 'செயலில் அங்கீகரிக்கப்பட்ட பட்டியல் இல்லை';

  @override
  String get scanApprovalInvalidBarcode => 'தவறான பார்கோடு';

  @override
  String get scanApprovalNotInList => 'அங்கீகரிக்கப்பட்ட பட்டியலில் இல்லை';

  @override
  String scanApprovalStatus(String label) {
    return 'ஒப்புதல் நிலை: $label';
  }

  @override
  String get scanResultAddToExpiry => 'காலாவதியில் சேர்';

  @override
  String get scanResultAddToStock => 'சரக்கில் சேர்';

  @override
  String get scanResultSaveToList => 'பட்டியலில் சேமி';

  @override
  String get scanResultNoProduct => 'பொருள் எதுவும் இல்லை';

  @override
  String get scanResultScanLabel => 'லேபிளை ஸ்கேன் செய்';

  @override
  String get auditRecordError =>
      'ஸ்கேனைப் பதிவு செய்ய முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get auditEndError =>
      'தணிக்கையை முடிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get auditNoStore => 'கடை ஒதுக்கப்படவில்லை';

  @override
  String get auditNoStoreBody =>
      'மொத்த தணிக்கைகள் ஒரு கடையின் அங்கீகரிக்கப்பட்ட EAN பட்டியலுக்கு எதிராக இயங்குகின்றன. உங்களுக்கு ஒரு கடையை ஒதுக்க நிர்வாகியிடம் கேளுங்கள், பிறகு தணிக்கைக்குத் திரும்புங்கள்.';

  @override
  String get auditMatched => 'பொருந்தியது';

  @override
  String get auditNotInList => 'பட்டியலில் இல்லை';

  @override
  String get auditNoList => 'பட்டியல் இல்லை';

  @override
  String get auditInvalid => 'தவறானது';

  @override
  String get auditUnchecked => 'சரிபார்க்கப்படவில்லை';

  @override
  String get commonTotal => 'மொத்தம்';

  @override
  String get auditEnterScanEan => 'EAN ஐ உள்ளிடவும் அல்லது ஸ்கேன் செய்யவும்';

  @override
  String auditStatus(String label) {
    return 'நிலை: $label';
  }

  @override
  String get auditStartAuditing => 'தணிக்கையைத் தொடங்கு';

  @override
  String get auditStartBody =>
      'இந்தக் கடையின் அங்கீகரிக்கப்பட்ட பட்டியலுடன் சரிபார்க்க மேலே EAN ஐ ஸ்கேன் செய்யவும் அல்லது தட்டச்சு செய்யவும். ஒவ்வொரு முடிவும் பொருந்திய அல்லது பட்டியலில்-இல்லை நிலையுடன் இங்கே வரும்.';

  @override
  String get auditTitle => 'மொத்த EAN தணிக்கை';

  @override
  String get auditEndAction => 'தணிக்கை முடி';

  @override
  String get auditEndingAction => 'முடிகிறது…';

  @override
  String get auditEanInvalid =>
      'சரியான EAN-8, EAN-13, அல்லது UPC-A குறியீட்டை உள்ளிடுங்கள்';

  @override
  String auditEndedSummary(int matched, int notMatched) {
    return 'தணிக்கை முடிந்தது — $matched பொருந்தியது, $notMatched பட்டியலில் இல்லை';
  }

  @override
  String get cameraCapture => 'படமெடு';

  @override
  String get labelScanReadError => 'லேபிளைப் படிக்க முடியவில்லை';

  @override
  String get labelScanReadErrorBody =>
      'சிறந்த வெளிச்சத்தில் மீண்டும் முயற்சிக்கவும், நிலையாகப் பிடிக்கவும், சட்டகத்தைப் பொருட்கள் பலகத்தால் நிரப்பவும்.';

  @override
  String get labelScanAnalysisFailed => 'பகுப்பாய்வு தோல்வியடைந்தது';

  @override
  String get labelScanIntro => 'RADHA உங்களுக்காக லேபிளைப் படிக்கிறது';

  @override
  String get labelScanTakePhoto => 'புகைப்படம் எடு';

  @override
  String get labelScanChooseGallery => 'கேலரியில் இருந்து தேர்வு செய்';

  @override
  String get labelScanAnother => 'மற்றொன்றை ஸ்கேன் செய்';

  @override
  String labelScanSeePlans(String plan) {
    return '$plan திட்டங்களைப் பார்';
  }

  @override
  String get labelScanMaybeLater => 'ஒருவேளை பின்னர்';

  @override
  String get labelScanTitle => 'லேபிலை ஸ்கேன் செய்க';

  @override
  String get labelScanNoBarcode => 'பார்கோடு இல்லையா? லேபிலை படிக்கவும்';

  @override
  String get labelScanIdleBody =>
      'பொருட்கள் பட்டியல் பகுதியை நோக்கவும் — உள்ளே என்ன இருக்கிறது என்று சொல்கிறோம். பார்கோடு இல்லாத தயாரிப்புகளுக்கும் வேலை செய்யும்.';

  @override
  String get labelScanFlashNote =>
      'குறைந்த வெளிச்சத்தில் கேமரா ஃபிளாஷ் தானாக இயங்கும்.';

  @override
  String get labelScanReading => 'லேபிலை படிக்கிறோம்…';

  @override
  String get labelScanAnalyzing => 'பொருட்களை பகுப்பாய்வு செய்கிறோம்…';

  @override
  String get labelScanFallbackError =>
      'ஏதோ தவறு நடந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get labelScanResultFallback => 'லேபில் பகுப்பாய்வு';

  @override
  String get labelScanLowConfidence =>
      'குறைந்த நம்பகத்தன்மை — தெளிவான புகைப்படம் சிறந்த முடிவு தரலாம்.';

  @override
  String get labelScanWhatToWatch => 'கவனிக்க வேண்டியவை';

  @override
  String get labelScanIngredients => 'பொருட்கள்';

  @override
  String get labelScanDisclaimer =>
      'RADHA AI மூலம் லேபில் உரையிலிருந்து படிக்கப்பட்டது. சரியான தகவலுக்கு பொட்டலத்தை சரிபார்க்கவும்.';

  @override
  String get labelScanUnlockTitle => 'AI லேபில் வாசிப்பை திறக்கவும்';

  @override
  String get labelScanUnlockBody =>
      'லேபிலை படித்தோம், ஆனால் முழு பகுப்பாய்வு பிரீமியம் அம்சம்.';

  @override
  String scanResultNotFoundBody(String ean) {
    return 'EAN $ean க்கு பட்டியலில் பொருத்தம் இல்லை — ஆனால் நீங்கள் இன்னும் லேபிளைப் படிக்கலாம். பொருட்கள் பலகத்தைப் படமெடுங்கள், உள்ளே என்ன இருக்கிறது என்று சொல்கிறோம்.';
  }

  @override
  String productScore(String score) {
    return 'மதிப்பெண்: $score';
  }

  @override
  String get catalogSearchHint => 'பொருட்கள் அல்லது பிராண்டுகளைத் தேடு';

  @override
  String get catalogNoMatches => 'பொருத்தம் இல்லை';

  @override
  String catalogNoMatchesBody(String query) {
    return '“$query” க்கான பொருட்களை எங்களால் கண்டுபிடிக்க முடியவில்லை. வேறு பெயரை முயற்சிக்கவும், அல்லது பொருளை ஸ்கேன் செய்யவும்.';
  }

  @override
  String get browseTitle => 'பொருட்கள்';

  @override
  String get browseLoadError => 'பொருட்களை ஏற்ற முடியவில்லை';

  @override
  String browseLoadErrorBody(String category) {
    return '$category ஏற்றுவதில் சிக்கல். மீண்டும் முயற்சிக்கவும்.';
  }

  @override
  String get browseSortHealthiest => 'ஆரோக்கியமானவை';

  @override
  String get browseSortAZ => 'A–Z';

  @override
  String get browseFilterVegOnly => 'சைவம் மட்டும்';

  @override
  String get browseVeg => 'வெஜ்';

  @override
  String get browseEmptyVeg => 'இங்கே இன்னும் சைவ பொருட்கள் இல்லை';

  @override
  String browseEmptyVegBody(String category) {
    return 'இப்போது $category இல் எதுவும் சைவ வடிகட்டிக்கு பொருந்தவில்லை.';
  }

  @override
  String get browseShowAll => 'அனைத்தையும் காட்டு';

  @override
  String get browseEmpty => 'இன்னும் பொருட்கள் இல்லை';

  @override
  String browseEmptyBody(String category) {
    return 'நாங்கள் $category பிரிவை நிரப்புகிறோம். அதுவரை, எந்தப் பொருளையும் ஸ்கேன் செய்து அதன் ஆரோக்கியம் மற்றும் காலாவதியைச் சரிபார்க்கவும்.';
  }

  @override
  String referralsShareText(String code) {
    return 'RADHA-வில் என்னுடன் இணையுங்கள்: $code குறியீட்டைப் பயன்படுத்துங்கள்';
  }

  @override
  String get selectStoreEmpty => 'இன்னும் கடைகள் இல்லை';

  @override
  String get selectStoreEmptyBody =>
      'ஒரு கடையில் சேர்க்கப்பட உங்கள் மேலாளரைத் தொடர்பு கொள்ளவும்.';

  @override
  String get selectStoreEmptyDetail =>
      'உங்கள் கணக்கு இன்னும் எந்தக் கடையுடனும் இணைக்கப்படவில்லை. அணுகலுக்கு உங்கள் மேலாளரிடம் கேளுங்கள், பிறகு திரும்பி வந்து ஒன்றைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get selectStoreContactManager => 'உங்கள் மேலாளரைத் தொடர்பு கொள்ளவும்';

  @override
  String get expiryConsumerTitle => 'வணிக கணக்குகளுக்கு';

  @override
  String get expiryConsumerBody =>
      'காலாவதி கண்காணிப்பு ஒரு சில்லறை கடை அம்சம். இதை பயன்படுத்த உங்கள் கணக்கை ஒரு கடையுடன் இணைக்கவும்.';

  @override
  String get tasksConsumerTitle => 'வணிக கணக்குகளுக்கு';

  @override
  String get tasksConsumerBody =>
      'பணி மேலாண்மை ஒரு சில்லறை கடை அம்சம். இதை பயன்படுத்த உங்கள் கணக்கை ஒரு கடையுடன் இணைக்கவும்.';

  @override
  String get languageSavedLocally => 'மொழி உள்ளூரில் மட்டும் சேமிக்கப்பட்டது';

  @override
  String languageSavedLocallyError(String error) {
    return 'மொழி உள்ளூரில் மட்டும் சேமிக்கப்பட்டது: $error';
  }

  @override
  String get signOutConfirmBody =>
      'ஆப்பைப் பயன்படுத்த நீங்கள் OTP உடன் மீண்டும் உள்நுழைய வேண்டும்.';

  @override
  String get scanResultTitle => 'ஸ்கேன் முடிவு';

  @override
  String scanResultShareMessage(String ean) {
    return 'இந்தப் பொருளை RADHA-வில் சரிபார்த்தேன் — பார்கோடு $ean.';
  }

  @override
  String get scanResultHealthHeading => 'ஆரோக்கியம்';

  @override
  String get scanResultAssessmentPending => 'மதிப்பீடு நிலுவையில்';

  @override
  String get scanResultNutritionPending =>
      'இந்தப் பொருள் பட்டியலில் பொருந்தியதும் ஊட்டச்சத்து குறிப்புகள் இங்கே தோன்றும். தரவுத்தளத்தை வளப்படுத்த மேலும் பொருட்களை ஸ்கேன் செய்யுங்கள்.';

  @override
  String get scanResultExplainIngredients => 'சேர்மங்களை விளக்கு';

  @override
  String get scanResultAllergenPrompt =>
      'நீங்கள் தவிர்க்கும் ஏதேனும் ஒன்று ஸ்கேன் செய்யப்பட்ட பொருளில் இருந்தால் உடனடி எச்சரிக்கை பெற உங்கள் ஒவ்வாமை சுயவிவரத்தை அமைக்கவும்.';

  @override
  String scanResultAllergensDeclared(String allergens) {
    return 'Contains: $allergens';
  }

  @override
  String get scanResultNoAllergensDeclared =>
      'No allergens declared on this product\'s label.';

  @override
  String get taskEvidenceRequiredSnack => 'இந்தப் பணியை முடிக்க ஆதாரம் தேவை';

  @override
  String taskMovedTo(String status) {
    return 'பணி $status நிலைக்கு மாற்றப்பட்டது';
  }

  @override
  String get taskUpdateError =>
      'பணியைப் புதுப்பிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String taskAssignedTo(String name) {
    return '$name க்கு ஒதுக்கப்பட்டது';
  }

  @override
  String taskDueOn(String date) {
    return 'காலக்கெடு $date';
  }

  @override
  String get taskPriorityLabel => 'முன்னுரிமை';

  @override
  String get taskEvidenceLabel => 'ஆதாரம்';

  @override
  String get taskEvidencePhotoRequired => 'புகைப்படம் தேவை';

  @override
  String get taskEvidenceNotRequired => 'தேவையில்லை';

  @override
  String taskEvidencePhotosAttached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count புகைப்படங்கள் இணைக்கப்பட்டன',
      one: '1 புகைப்படம் இணைக்கப்பட்டது',
    );
    return '$_temp0';
  }

  @override
  String get taskEvidencePhotoNeeded =>
      'இந்தப் பணியை முடிக்க ஒரு புகைப்படம் தேவை';

  @override
  String get taskTimelineCreated => 'உருவாக்கப்பட்டது';

  @override
  String get taskTimelineStarted => 'தொடங்கப்பட்டது';

  @override
  String get taskActionComplete => 'முடி';

  @override
  String get taskLoadFailed => 'பணியை ஏற்ற முடியவில்லை';

  @override
  String get taskDescriptionLabel => 'விவரம்';

  @override
  String get taskTypeLabel => 'வகை';

  @override
  String get taskActionStart => 'தொடங்கு';

  @override
  String get taskCreateTitle => 'பணியை உருவாக்கு';

  @override
  String get taskCreateCta => 'பணியை உருவாக்கு';

  @override
  String get taskCreatedSnack => 'பணி உருவாக்கப்பட்டது';

  @override
  String get taskCreateError =>
      'பணியை உருவாக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get taskNotAuthorizedTitle => 'அங்கீகாரம் இல்லை';

  @override
  String get taskNotAuthorizedBody =>
      'மேலாளர்கள் மற்றும் நிர்வாகிகள் மட்டுமே பணிகளை உருவாக்க முடியும்.';

  @override
  String get taskTitleLabel => 'தலைப்பு';

  @override
  String get taskTitleHint => 'எ.கா. பால் பிரிவு EAN தணிக்கை';

  @override
  String get taskTitleRequired => 'தலைப்பு அவசியம்';

  @override
  String get taskDescriptionHint => 'ஒதுக்கப்பட்டவருக்கான விருப்ப விவரங்கள்';

  @override
  String get taskStoreLabel => 'கடை';

  @override
  String get taskAssigneeLabel => 'ஒதுக்கப்பட்டவர் (பயனர் ID)';

  @override
  String get taskAssigneeHint => 'பயனர் ID ஐ உள்ளிடவும் அல்லது காலியாக விடவும்';

  @override
  String get taskDueDateLabel => 'காலக்கெடு தேதி';

  @override
  String get taskSelectDate => 'தேதியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get taskRequiresEvidence => 'ஆதாரம் தேவை';

  @override
  String get taskRequiresEvidenceSubtitle =>
      'முடிக்க ஒதுக்கப்பட்டவர் புகைப்படத்தைப் பதிவேற்ற வேண்டும்';

  @override
  String get taskTypeEanAudit => 'EAN தணிக்கை';

  @override
  String get taskTypeExpiryCheck => 'காலாவதி சோதனை';

  @override
  String get taskTypeInventoryCount => 'சரக்கு எண்ணிக்கை';

  @override
  String get taskTypeDisplayVerification => 'காட்சி சரிபார்ப்பு';

  @override
  String get taskTypeCustom => 'தனிப்பயன்';

  @override
  String get checkoutStartError =>
      'செக்அவுட்டைத் தொடங்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get paymentResponseIncomplete => 'கட்டண பதில் முழுமையடையவில்லை.';

  @override
  String get paymentSuccessUpdated =>
      'கட்டணம் வெற்றி. திட்டம் புதுப்பிக்கப்பட்டது.';

  @override
  String get paymentNotVerified => 'கட்டணத்தைச் சரிபார்க்க முடியவில்லை.';

  @override
  String get paymentVerifyFailed =>
      'கட்டண சரிபார்ப்பு தோல்வி. ஆதரவைத் தொடர்பு கொள்ளவும்.';

  @override
  String get paymentCancelled => 'கட்டணம் ரத்து செய்யப்பட்டது.';

  @override
  String paymentFailed(String message) {
    return 'கட்டணம் தோல்வி: $message';
  }

  @override
  String paymentOpeningWallet(String wallet) {
    return '$wallet திறக்கிறது…';
  }

  @override
  String get paymentSheetOpenError => 'கட்டண தாளைத் திறக்க முடியவில்லை.';

  @override
  String get subscriptionLoadError => 'உங்கள் சந்தாவை ஏற்ற முடியவில்லை';

  @override
  String get subscriptionLoadErrorBody =>
      'உங்கள் இணைப்பைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String subscriptionCurrentPlan(String plan) {
    return 'நீங்கள் $plan திட்டத்தில் உள்ளீர்கள்';
  }

  @override
  String subscriptionUpgradeTo(String plan) {
    return '$plan க்கு மேம்படுத்தவும்';
  }

  @override
  String subscriptionChoosePlan(String plan) {
    return '$plan தேர்வு செய்யவும்';
  }

  @override
  String get subscriptionPopular => 'பிரபலம்';

  @override
  String get subscriptionPerMonth => '/மாதம்';

  @override
  String get subscriptionTitle => 'சந்தா';

  @override
  String get subscriptionHeadline => 'RADHA-வின் முழு சக்தியை திறக்கவும்';

  @override
  String get subscriptionChooseAPlan => 'ஒரு திட்டம் தேர்ந்தெடுக்கவும்';

  @override
  String get subscriptionCancelAnytime =>
      'எப்போதும் ரத்து செய்யலாம் · GST உள்ளடக்கியது';

  @override
  String get subscriptionBillingYearly => 'வருடாந்திர';

  @override
  String get subscriptionBillingMonthly => 'மாதாந்திர';

  @override
  String get versionLoading => 'பதிப்பு ஏற்றுகிறது…';

  @override
  String get versionUnavailable => 'பதிப்பு கிடைக்கவில்லை';

  @override
  String appVersionBuild(String version, String build) {
    return 'பதிப்பு $version ($build)';
  }

  @override
  String get shoppingListTitle => 'ஷாப்பிங் பட்டியல்';

  @override
  String get shoppingAddItem => 'பொருளைச் சேர்';

  @override
  String get shoppingLoadError => 'உங்கள் பட்டியலை ஏற்ற முடியவில்லை';

  @override
  String get shoppingLoadErrorBody =>
      'உங்கள் ஷாப்பிங் பட்டியலை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get shoppingEmptyTitle => 'உங்கள் ஷாப்பிங் பட்டியல் காலியாக உள்ளது';

  @override
  String get shoppingEmptyBody =>
      'பொருளைச் சேர்க்க பிளஸ் பொத்தானை அழுத்தவும், அல்லது ஒரு தயாரிப்பு பக்கத்திலிருந்து ஆரோக்கியமான மாற்றுகளைச் சேமிக்கவும்.';

  @override
  String get shoppingUpdateError =>
      'பொருளைப் புதுப்பிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get shoppingDeleteError =>
      'பொருளை நீக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get shoppingAddError =>
      'பொருளைச் சேர்க்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get shoppingAllDone =>
      'எல்லாம் முடிந்தது — அனைத்தும் டிக் செய்யப்பட்டது';

  @override
  String shoppingRemaining(int remaining, int total) {
    return '$total இல் $remaining வாங்க வேண்டியுள்ளது';
  }

  @override
  String shoppingQty(int quantity) {
    return 'அளவு: $quantity';
  }

  @override
  String get shoppingDeleteItem => 'பொருளை நீக்கு';

  @override
  String get shoppingItemNameLabel => 'பொருளின் பெயர்';

  @override
  String get shoppingItemNameHint => 'எ.கா. முழு கோதுமை ரொட்டி';

  @override
  String get shoppingItemNameRequired => 'பொருளின் பெயரை உள்ளிடவும்';

  @override
  String get shoppingItemNameTooLong => '120 எழுத்துகளுக்குள் வைக்கவும்';

  @override
  String get shoppingQuantityLabel => 'அளவு (விருப்பம்)';

  @override
  String get shoppingQuantityInvalid => 'ஒரு நேர்மறை எண்ணை உள்ளிடவும்';

  @override
  String get shoppingQuantityTooHigh => 'இது அசாதாரணமாக அதிகமாகத் தெரிகிறது';

  @override
  String get shoppingAddToList => 'பட்டியலில் சேர்';

  @override
  String get grnTitle => 'பெறப்பட்ட பொருட்கள்';

  @override
  String get grnFilterAll => 'அனைத்தும்';

  @override
  String get grnFilterDraft => 'வரைவு';

  @override
  String get grnFilterPendingReview => 'மதிப்பாய்வு நிலுவையில்';

  @override
  String get grnFilterPosted => 'பதிவு செய்யப்பட்டது';

  @override
  String get grnStatusPending => 'நிலுவையில்';

  @override
  String get grnEmptyTitle => 'இங்கே GRN இல்லை';

  @override
  String get grnEmptyBody =>
      'சப்ளையர் டெலிவரியைப் பதிவு செய்ய ஒரு பொருள்-பெறப்பட்ட குறிப்பை உருவாக்கவும்.';

  @override
  String get grnNew => 'புதிய GRN';

  @override
  String get grnLoadError => 'GRN-களை ஏற்ற முடியவில்லை';

  @override
  String get grnSupplierFallback => 'சப்ளையர்';

  @override
  String get categoryBiscuits => 'பிஸ்கட் & ஸ்நாக்ஸ்';

  @override
  String get categoryBreakfast => 'காலை உணவு & ஸ்ப்ரெட்ஸ்';

  @override
  String get categoryDairy => 'பால் & முட்டை';

  @override
  String get categoryBeverages => 'பானங்கள்';

  @override
  String get categoryStaples => 'அத்தியாவசியங்கள் & தானியங்கள்';

  @override
  String get categoryPersonalCare => 'தனிப்பட்ட பராமரிப்பு';

  @override
  String get categoryHousehold => 'வீட்டுப் பொருட்கள்';

  @override
  String get categoryFrozen => 'உறைந்தவை';

  @override
  String get lowStockTitle => 'குறைந்த இருப்பு எச்சரிக்கைகள்';

  @override
  String get lowStockLoadError => 'எச்சரிக்கைகளை ஏற்ற முடியவில்லை';

  @override
  String get lowStockEmpty => 'அனைத்து இருப்பு நிலைகளும் ஆரோக்கியமாக உள்ளன';

  @override
  String lowStockCurrentThreshold(int quantity, int threshold) {
    return 'தற்போது: $quantity / வரம்பு: $threshold';
  }

  @override
  String get lowStockRestock => 'மீண்டும் நிரப்பு';

  @override
  String get commonRequired => 'தேவை';

  @override
  String get commonOptional => 'விருப்பம்';

  @override
  String get commonQuantity => 'அளவு';

  @override
  String get smTitle => 'சரக்கு நகர்வு';

  @override
  String get smStockIn => 'சரக்கு உள்வரவு';

  @override
  String get smStockOut => 'சரக்கு வெளியேற்றம்';

  @override
  String get smProductLabel => 'பொருள்';

  @override
  String get smProductHint => 'பொருள் ID அல்லது EAN ஐ உள்ளிடவும்';

  @override
  String get smReasonLabel => 'காரணம்';

  @override
  String get smSelectReason => 'காரணத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get smBatchLabel => 'தொகுதி எண்';

  @override
  String get smExpiryLabel => 'காலாவதி தேதி';

  @override
  String get smExpiryOptionalHint => 'விருப்பம் — தேர்வு செய்ய தட்டவும்';

  @override
  String get smNotesLabel => 'குறிப்புகள்';

  @override
  String get smNotesHint => 'விருப்பக் குறிப்புகள்';

  @override
  String get smRecordIn => 'சரக்கு உள்வரவைப் பதிவு செய்';

  @override
  String get smRecordOut => 'சரக்கு வெளியேற்றத்தைப் பதிவு செய்';

  @override
  String get smStockInRecorded => 'சரக்கு உள்வரவு பதிவு செய்யப்பட்டது';

  @override
  String get smStockOutRecorded => 'சரக்கு வெளியேற்றம் பதிவு செய்யப்பட்டது';

  @override
  String get smRecordError =>
      'சரக்கு நகர்வைப் பதிவு செய்ய முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get smInsufficientStock => 'இந்த நகர்வுக்கு போதிய சரக்கு இல்லை';

  @override
  String get smReasonPurchase => 'கொள்முதல்';

  @override
  String get smReasonReturn => 'திரும்பப் பெறுதல்';

  @override
  String get smReasonAdjustment => 'சரிசெய்தல்';

  @override
  String get smReasonTransfer => 'மாற்றம்';

  @override
  String get smReasonDamage => 'சேதம்';

  @override
  String get smReasonExpiryRemoval => 'காலாவதி அகற்றல்';

  @override
  String get smReasonOther => 'மற்றவை';

  @override
  String get grnInvoiceDateRequired => 'இன்வாய்ஸ் தேதி அவசியம்';

  @override
  String get grnCreateError =>
      'GRN ஐ உருவாக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get grnSupplierInvoiceSection => 'சப்ளையர் & இன்வாய்ஸ்';

  @override
  String get grnSupplierNameLabel => 'சப்ளையர் பெயர்';

  @override
  String get grnSupplierNameHint => 'சப்ளையர் பெயரை உள்ளிடவும்';

  @override
  String get grnSupplierRequired => 'சப்ளையர் அவசியம்';

  @override
  String get grnInvoiceNumberLabel => 'இன்வாய்ஸ் எண்';

  @override
  String get grnInvoiceNumberHint => 'இன்வாய்ஸ் எண்ணை உள்ளிடவும்';

  @override
  String get grnInvoiceNumberRequired => 'இன்வாய்ஸ் எண் அவசியம்';

  @override
  String get grnInvoiceDateLabel => 'இன்வாய்ஸ் தேதி *';

  @override
  String get grnExpectedDeliveryLabel => 'எதிர்பார்க்கப்படும் டெலிவரி தேதி';

  @override
  String get grnCreateDraft => 'வரைவு GRN ஐ உருவாக்கு';

  @override
  String get grnSelectDate => 'தேதியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get expiryCalendarTitle => 'காலாவதி நாட்காட்டி';

  @override
  String get expiryCalendarLoadError => 'நாட்காட்டி தரவை ஏற்ற முடியவில்லை.';

  @override
  String get expiryCalendarTapHint => 'விவரங்களைப் பார்க்க ஒரு நாளைத் தட்டவும்';

  @override
  String get expiryCalendarNoRecords => 'இந்த நாளுக்கு காலாவதி பதிவுகள் இல்லை';

  @override
  String expiryCalendarSummaryFor(String date) {
    return '$date இன் சுருக்கம்';
  }

  @override
  String get exTitle => 'புதிய காலாவதி பதிவு';

  @override
  String get exMfgAfterExpiry =>
      'உற்பத்தி தேதி காலாவதி தேதிக்குப் பிறகு இருக்க முடியாது';

  @override
  String get exSelectMfg => 'உற்பத்தி தேதியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get exSelectExpiry => 'காலாவதி தேதியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get exExpiryRequired => 'காலாவதி தேதி அவசியம்';

  @override
  String get exCreated => 'காலாவதி பதிவு உருவாக்கப்பட்டது';

  @override
  String get exOfflineQueued =>
      'நீங்கள் ஆஃப்லைனில் உள்ளீர்கள் — ஆன்லைனுக்கு வரும்போது பதிவு ஒத்திசைக்கப்படும்';

  @override
  String get exSubmitError => 'ஏதோ தவறு நடந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get exNotSet => 'அமைக்கப்படவில்லை';

  @override
  String get exProductIdLabel => 'பொருள் ID';

  @override
  String get exProductIdHint =>
      'பொருள் ID ஐ உள்ளிடவும் அல்லது பார்கோடு ஸ்கேன் செய்யவும்';

  @override
  String get exMfgLabel => 'உற்பத்தி தேதி';

  @override
  String get exExpiryLabel => 'காலாவதி தேதி *';

  @override
  String get exBatchLabel => 'தொகுதி எண்';

  @override
  String get exLocationLabel => 'இடம்';

  @override
  String get exLocationHint => 'அலமாரி / பாதை / மண்டலம்';

  @override
  String get exSaveRecord => 'பதிவைச் சேமி';

  @override
  String get exOcrSemantic => 'RADHA உங்களுக்காக தேதியைப் படிக்கிறது';

  @override
  String get exOcrTitle => 'பேக்கிலிருந்து தேதியை ஸ்கேன் செய்யுங்கள்';

  @override
  String get exOcrSubtitle => 'நாங்கள் உங்களுக்காக MFG / EXP ஐப் படிப்போம்';

  @override
  String get grnItemsTitle => 'GRN பொருட்கள்';

  @override
  String get grnItemAdded => 'பொருள் சேர்க்கப்பட்டது';

  @override
  String get grnItemSavedOffline =>
      'ஆஃப்லைனில் சேமிக்கப்பட்டது — ஆன்லைனுக்கு வரும்போது ஒத்திசைக்கப்படும்';

  @override
  String get grnItemAddError =>
      'பொருளைச் சேர்க்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get grnAddItemFirst =>
      'பதிவு செய்வதற்கு முன் குறைந்தது ஒரு பொருளைச் சேர்க்கவும்';

  @override
  String get grnPosted =>
      'GRN பதிவு செய்யப்பட்டது — சரக்கு புதுப்பிக்கப்பட்டது';

  @override
  String get grnPostQueued => 'வரிசையில் — ஆன்லைனுக்கு வரும்போது பதிவாகும்';

  @override
  String get grnPostError =>
      'GRN ஐப் பதிவு செய்ய முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get grnNoItems => 'இதுவரை பொருட்கள் சேர்க்கப்படவில்லை';

  @override
  String get grnNoItemsHint =>
      'பொருட்களைச் சேர்க்க கீழே உள்ள பொத்தானைத் தட்டவும்';

  @override
  String grnTotalQty(String qty) {
    return 'மொத்த அளவு: $qty';
  }

  @override
  String grnTotalValue(String value) {
    return 'மொத்தம்: ₹$value';
  }

  @override
  String get grnAddItem => 'பொருளைச் சேர்';

  @override
  String get grnPostGrn => 'GRN பதிவு செய்';

  @override
  String get grnPostHint =>
      'பதிவு செய்தால் சரக்கு புதுப்பிக்கப்பட்டு குறைந்த-சரக்கு எச்சரிக்கைகள் தீர்க்கப்படும்.';

  @override
  String grnInvoiceLabel(String number) {
    return 'இன்வாய்ஸ் $number';
  }

  @override
  String grnBatchTag(String batch) {
    return 'தொகுதி $batch';
  }

  @override
  String get grnBarcodeLabel => 'பார்கோடு (EAN / UPC)';

  @override
  String get grnBarcodeHint => '8–13 இலக்கங்கள்';

  @override
  String get grnProductNameLabel => 'பொருளின் பெயர்';

  @override
  String get grnMustBePositive => '0 ஐ விட அதிகமாக இருக்க வேண்டும்';

  @override
  String get grnBatchNumberOptional => 'தொகுதி எண் (விருப்பம்)';

  @override
  String get grnMfgDateLabel => 'உற்பத்தி தேதி';

  @override
  String get grnExpiryDateLabel => 'காலாவதி தேதி';

  @override
  String get grnUnitPriceLabel => 'அலகு விலை (₹)';

  @override
  String get grnMustBeNonNeg => '0 அல்லது அதிகமாக இருக்க வேண்டும்';
}
