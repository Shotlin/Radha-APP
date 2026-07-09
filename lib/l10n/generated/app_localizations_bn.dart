// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'RADHA';

  @override
  String get tagline => 'ডেটা, স্বাস্থ্য এবং অডিটের জন্য খুচরা সহকারী।';

  @override
  String get continueLabel => 'চালিয়ে যান';

  @override
  String get getStarted => 'শুরু করুন';

  @override
  String get skip => 'এড়িয়ে যান';

  @override
  String get next => 'পরবর্তী';

  @override
  String get back => 'পিছনে';

  @override
  String get cancel => 'বাতিল';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get delete => 'মুছুন';

  @override
  String get edit => 'সম্পাদনা';

  @override
  String get add => 'যোগ করুন';

  @override
  String get search => 'অনুসন্ধান';

  @override
  String get loading => 'লোড হচ্ছে';

  @override
  String get error => 'কিছু ভুল হয়েছে';

  @override
  String get tryAgain => 'আবার চেষ্টা করুন';

  @override
  String get done => 'সম্পন্ন';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get signIn => 'সাইন ইন';

  @override
  String get signOut => 'সাইন আউট';

  @override
  String get mobileNumber => 'মোবাইল নম্বর';

  @override
  String get enterOtp => 'OTP লিখুন';

  @override
  String get verifyOtp => 'OTP যাচাই করুন';

  @override
  String get resendOtp => 'OTP পুনরায় পাঠান';

  @override
  String get otpSent => 'আমরা আপনাকে একটি 6-অঙ্কের কোড পাঠিয়েছি';

  @override
  String get home => 'হোম';

  @override
  String get scan => 'স্ক্যান';

  @override
  String get expiry => 'মেয়াদ';

  @override
  String get tasks => 'কাজ';

  @override
  String get profile => 'প্রোফাইল';

  @override
  String get settings => 'সেটিংস';

  @override
  String get language => 'ভাষা';

  @override
  String get scanProduct => 'পণ্য স্ক্যান করুন';

  @override
  String get pointAtBarcode => 'আপনার ক্যামেরা বারকোডে রাখুন';

  @override
  String get scanAgain => 'আবার স্ক্যান করুন';

  @override
  String get productNotFound => 'পণ্য পাওয়া যায়নি';

  @override
  String get expiryTracker => 'মেয়াদ ট্র্যাকার';

  @override
  String get addExpiry => 'মেয়াদ যোগ করুন';

  @override
  String get expiringSoon => 'শীঘ্রই মেয়াদ শেষ হবে';

  @override
  String get expired => 'মেয়াদ শেষ';

  @override
  String get yourTasks => 'আপনার কাজ';

  @override
  String get noTasks => 'কোনো কাজ নেই';

  @override
  String get completeTask => 'কাজ সম্পূর্ণ করুন';

  @override
  String get welcome => 'স্বাগতম';

  @override
  String get welcomeMessage =>
      'স্প্রেডশিট ছাড়াই আপনার স্টক স্ক্যান, ট্র্যাক ও অডিট করুন।';

  @override
  String get referrals => 'রেফারাল';

  @override
  String get shareYourCode => 'আপনার কোড শেয়ার করুন';

  @override
  String get yourReferralCode => 'আপনার রেফারাল কোড';

  @override
  String get invitees => 'আমন্ত্রিত';

  @override
  String get rewardsEarned => 'অর্জিত পুরস্কার';

  @override
  String get redeemCode => 'কোড রিডিম করুন';

  @override
  String get enterReferralCode => 'রেফারাল কোড লিখুন';

  @override
  String get chooseLanguage => 'ভাষা নির্বাচন করুন';

  @override
  String get languageUpdated => 'ভাষা আপডেট হয়েছে';

  @override
  String get errorGeneric => 'কিছু ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String errorRateLimitOtp(int seconds) {
    return 'অনেক বেশি OTP অনুরোধ। $seconds সেকেন্ডে আবার চেষ্টা করুন।';
  }

  @override
  String get errorOtpInvalid => 'OTP ভুল। আবার চেষ্টা করুন।';

  @override
  String get errorOtpExpired => 'OTP-এর মেয়াদ শেষ। নতুন একটি অনুরোধ করুন।';

  @override
  String get errorAuthRequired => 'চালিয়ে যেতে সাইন ইন করুন।';

  @override
  String get errorNotFound => 'পাওয়া যায়নি।';

  @override
  String get ingredientExplainerErrorTitle => 'ব্যাখ্যা লোড করা যায়নি';

  @override
  String get ingredientExplainerHealthConsiderations => 'স্বাস্থ্য বিবেচনা';

  @override
  String healthyAlternativesTitle(String productName) {
    return '$productName এর চেয়ে ভালো বিকল্প';
  }

  @override
  String get healthyAlternativesGenericTitle => 'ভালো বিকল্প';

  @override
  String get healthyAlternativesEmptyTitle => 'এখনও স্বাস্থ্যকর বিকল্প নেই';

  @override
  String get healthyAlternativesEmptyBody =>
      'একই বিভাগে এখনও স্বাস্থ্যকর বিকল্প পাওয়া যায়নি।';

  @override
  String get healthyAlternativesErrorTitle => 'বিকল্প লোড করা যায়নি';

  @override
  String get healthyAlternativesAddToList => 'শপিং তালিকায় যোগ করুন';

  @override
  String get healthyAlternativesView => 'দেখুন';

  @override
  String get healthyAlternativesAddedToList => 'শপিং তালিকায় যোগ করা হয়েছে';

  @override
  String get healthyAlternativesAddFailed => 'শপিং তালিকায় যোগ করা যায়নি';

  @override
  String get savedProductsTitle => 'সংরক্ষিত পণ্য';

  @override
  String get savedProductsEmptyTitle => 'সংরক্ষিত পণ্য';

  @override
  String get savedProductsEmptyBody =>
      'স্ক্যান ফলাফল স্ক্রিন থেকে পণ্য সংরক্ষণ করলে সেগুলো এখানে দেখা যাবে।';

  @override
  String get savedProductsErrorTitle => 'সংরক্ষিত পণ্য লোড করা যায়নি';

  @override
  String savedProductsSavedOn(String date) {
    return '$date-এ সংরক্ষিত';
  }

  @override
  String get digestTitle => 'RADHA-এর সঙ্গে আপনার সপ্তাহ';

  @override
  String digestWeekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String digestSavingsHero(String amount) {
    return '₹$amount সাশ্রয়';
  }

  @override
  String digestScansHero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি স্ক্যান',
      one: '1টি স্ক্যান',
    );
    return '$_temp0';
  }

  @override
  String get digestHeroEmptyHeadline => 'একটি শান্ত সপ্তাহ';

  @override
  String get digestScans => 'স্ক্যান';

  @override
  String get digestSavedProducts => 'সংরক্ষিত';

  @override
  String get digestExpiringSoon => 'শীঘ্রই মেয়াদ শেষ';

  @override
  String digestRecallAlerts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি রিকল অ্যালার্ট',
      one: '1টি রিকল অ্যালার্ট',
    );
    return '$_temp0';
  }

  @override
  String get digestRecallAlertsBody =>
      'এই সপ্তাহে স্ক্যান করা পণ্যগুলির নতুন সুরক্ষা পরামর্শ আছে।';

  @override
  String get digestRecallAlertsCta => 'দেখুন';

  @override
  String get digestTopCategoriesHeader => 'আপনি কী স্ক্যান করছেন';

  @override
  String get digestHighlightsHeader => 'মুখ্য বিষয়';

  @override
  String get digestContinueScanning => 'স্ক্যান চালিয়ে যান';

  @override
  String get digestShare => 'আমার সপ্তাহ শেয়ার করুন';

  @override
  String digestShareTemplate(int scans, String savings) {
    return 'আমি এই সপ্তাহে $scansটি পণ্য স্ক্যান করেছি এবং RADHA দিয়ে ₹$savings সাশ্রয় করেছি। চেষ্টা করুন: https://radha.app';
  }

  @override
  String get digestEmptyTitle => 'এই সপ্তাহে কোনো কার্যকলাপ নেই';

  @override
  String get digestEmptyBody => 'আপনার সাপ্তাহিক গল্প গড়তে স্ক্যান শুরু করুন।';

  @override
  String get digestErrorTitle => 'সাপ্তাহিক সারাংশ লোড করা যায়নি';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsNotifications => 'নোটিফিকেশন';

  @override
  String get settingsPushNotifications => 'পুশ নোটিফিকেশন';

  @override
  String get settingsPushNotificationsHint => 'আপনার ফোনে অ্যালার্ট পান';

  @override
  String get settingsRecallAlerts => 'রিকল অ্যালার্ট';

  @override
  String get settingsRecallAlertsHint =>
      'স্ক্যান করা পণ্য রিকল হলে জানিয়ে দেব';

  @override
  String get settingsWeeklyDigest => 'সাপ্তাহিক সারাংশ';

  @override
  String get settingsWeeklyDigestHint =>
      'রবিবার আপনার স্ক্যান ও সাশ্রয়ের সারাংশ';

  @override
  String get settingsAppearance => 'চেহারা';

  @override
  String get settingsTheme => 'থিম';

  @override
  String get settingsThemeSystem => 'সিস্টেম';

  @override
  String get settingsThemeLight => 'লাইট';

  @override
  String get settingsThemeDark => 'ডার্ক';

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get settingsTextSize => 'টেক্সট আকার';

  @override
  String get settingsTextSizeSmall => 'ছোট';

  @override
  String get settingsTextSizeStandard => 'মান';

  @override
  String get settingsTextSizeLarge => 'বড়';

  @override
  String get settingsDataPrivacy => 'ডেটা ও গোপনীয়তা';

  @override
  String get settingsAllergens => 'অ্যালার্জি প্রোফাইল';

  @override
  String get settingsAllergensHint =>
      'যে উপাদানের ব্যাপারে সতর্ক করতে হবে তা বাছুন';

  @override
  String get settingsSignOutAll => 'সব ডিভাইস থেকে সাইন আউট';

  @override
  String get settingsSignOutAllConfirmTitle => 'সর্বত্র সাইন আউট?';

  @override
  String get settingsSignOutAllConfirmBody =>
      'এই অ্যাকাউন্ট ব্যবহার করা প্রতিটি ডিভাইসে আবার সাইন ইন করতে হবে।';

  @override
  String get settingsDeleteAccount => 'অ্যাকাউন্ট মুছুন';

  @override
  String get settingsDeleteAccountTitle => 'অ্যাকাউন্ট মুছুন';

  @override
  String get settingsDeleteAccountBody =>
      'এটি আপনার ডেটা স্থায়ীভাবে মুছে ফেলবে। নিশ্চিত করতে DELETE টাইপ করুন।';

  @override
  String get settingsDeleteAccountConfirm => 'DELETE';

  @override
  String get settingsDeleteAccountUnavailable =>
      'অ্যাকাউন্ট মুছতে সাপোর্টের সাথে যোগাযোগ করুন।';

  @override
  String get settingsDeleteAccountContact => 'সাপোর্টের সাথে যোগাযোগ করুন';

  @override
  String get settingsAbout => 'সম্পর্কে';

  @override
  String get settingsTerms => 'পরিষেবার শর্তাবলি';

  @override
  String get settingsPrivacyPolicy => 'গোপনীয়তা নীতি';

  @override
  String get settingsVersion => 'অ্যাপ সংস্করণ';

  @override
  String settingsVersionValue(String version, String build) {
    return 'সংস্করণ $version ($build)';
  }

  @override
  String get settingsSupport => 'সাপোর্ট';

  @override
  String get settingsSupportHint =>
      'সাহায্য পান, বাগ রিপোর্ট করুন, বা মতামত দিন';

  @override
  String get settingsLinkOpenFailed => 'লিঙ্ক খোলা যায়নি';

  @override
  String conflictBannerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি দ্বন্দ্বে আপনার মনোযোগ দরকার',
      one: '1টি দ্বন্দ্বে আপনার মনোযোগ দরকার',
    );
    return '$_temp0';
  }

  @override
  String get conflictBannerCta => 'সমাধান করুন';

  @override
  String get conflictBannerDismiss => 'বন্ধ করুন';

  @override
  String get conflictResolveTitle => 'সিঙ্ক দ্বন্দ্ব সমাধান করুন';

  @override
  String get conflictResolveSubtitle =>
      'প্রতিটি আইটেমের জন্য কোন সংস্করণ রাখবেন তা বাছাই করুন।';

  @override
  String get conflictUseMine => 'আমার সংস্করণ রাখুন';

  @override
  String get conflictUseServer => 'সার্ভারের সংস্করণ রাখুন';

  @override
  String get conflictResolved => 'দ্বন্দ্ব সমাধান হয়েছে';

  @override
  String get conflictResolvedAll => 'সব দ্বন্দ্ব সমাধান হয়েছে';

  @override
  String conflictAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count বার চেষ্টা করা হয়েছে',
      one: '1 বার চেষ্টা করা হয়েছে',
    );
    return '$_temp0';
  }

  @override
  String get conflictResourceTask => 'কাজ';

  @override
  String get conflictResourceExpiry => 'মেয়াদ রেকর্ড';

  @override
  String get conflictResourceScan => 'স্ক্যান';

  @override
  String get conflictResourceInventory => 'স্টক সমন্বয়';

  @override
  String get conflictResourceGrn => 'GRN এন্ট্রি';

  @override
  String get conflictResourceShoppingList => 'শপিং তালিকা আইটেম';

  @override
  String get conflictResourceGeneric => 'সিঙ্ক পরিবর্তন';

  @override
  String conflictLocalChangeSummary(String summary) {
    return 'আপনার পরিবর্তন: $summary';
  }

  @override
  String get supportTitle => 'সাপোর্ট';

  @override
  String get supportContactUs => 'আমাদের সাথে যোগাযোগ করুন';

  @override
  String get supportEmailUs => 'ইমেইল করুন';

  @override
  String get supportEmailUsHint => 'support@radha.app';

  @override
  String get supportCallUs => 'সাপোর্টে কল করুন';

  @override
  String get supportCallUsHint => 'সোম–শুক্র, সকাল ৯ – সন্ধ্যা ৬ IST';

  @override
  String get supportReportBug => 'বাগ রিপোর্ট করুন';

  @override
  String get supportBugDescription => 'কী হয়েছিল?';

  @override
  String get supportBugDescriptionHint =>
      'যখন সমস্যা হয়েছিল তখন আপনি কী করছিলেন বর্ণনা করুন।';

  @override
  String get supportAttachScreenshot => 'স্ক্রিনশট সংযুক্ত করুন';

  @override
  String get supportScreenshotAttached => 'স্ক্রিনশট সংযুক্ত হয়েছে';

  @override
  String get supportRemoveScreenshot => 'সরান';

  @override
  String get supportSubmit => 'রিপোর্ট পাঠান';

  @override
  String get supportSubmitted => 'ধন্যবাদ — আপনার রিপোর্ট পেয়েছি।';

  @override
  String get supportSubmitFailed =>
      'পাঠানো যায়নি। দয়া করে আমাদের ইমেইল করুন।';

  @override
  String get supportBugDescriptionRequired =>
      'অনুগ্রহ করে কী হয়েছিল বর্ণনা করুন।';

  @override
  String get supportFaq => 'সাধারণ জিজ্ঞাসা';

  @override
  String get supportFaqQ1 => 'বারকোড কীভাবে স্ক্যান করব?';

  @override
  String get supportFaqA1 =>
      'স্ক্যান ট্যাব খুলে ক্যামেরা বারকোডে রাখুন এবং স্থির রাখুন। পরিষ্কার কোড পড়ার সাথে সাথে পণ্যটি দেখা যাবে।';

  @override
  String get supportFaqQ2 => 'পণ্যটি ডেটাবেসে না থাকলে কী?';

  @override
  String get supportFaqA2 =>
      'পাওয়া-যায়নি স্ক্রিনে \"পণ্য যোগ করুন\" ট্যাপ করুন। এটি আপনার স্টোরের সাথে যুক্ত নতুন এন্ট্রি তৈরি করবে।';

  @override
  String get supportFaqQ3 => 'আমি আমার সাবস্ক্রিপশন কীভাবে বাতিল করব?';

  @override
  String get supportFaqA3 =>
      'প্রোফাইল → সাবস্ক্রিপশনে যান। যেকোনো সময় বাতিল করতে পারেন; পরবর্তী বিলিং চক্রের পরে চার্জ নেই।';

  @override
  String get supportFaqQ4 => 'আমি কেন রিকল অ্যালার্ট দেখছি?';

  @override
  String get supportFaqA4 =>
      'প্রতিটি স্ক্যানকে FSSAI রিকল ফিডের সাথে মিলিয়ে দেখি। আপনি যে ব্যাচ বিক্রি করেছেন তা তালিকায় থাকলে আপনাকে জানিয়ে দিই।';

  @override
  String get supportFaqQ5 =>
      'আমার অ্যালার্জি প্রোফাইল পরিবারের সাথে কীভাবে শেয়ার করব?';

  @override
  String get supportFaqA5 =>
      'অ্যালার্জি প্রোফাইল এখন প্রতি অ্যাকাউন্টে আলাদা। একই পরিবারের অ্যাকাউন্টে সাইন ইন করুন বা প্রতিটি ফোনে একই অ্যালার্জি বেছে নিন।';

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
  String get expiryTabNear => 'শীঘ্রই মেয়াদ';

  @override
  String get expiryTabSafe => 'নিরাপদ';

  @override
  String get expiryCalendarTooltip => 'ক্যালেন্ডার ভিউ';

  @override
  String get expiryEmptyExpiredTitle => 'কিছুই মেয়াদোত্তীর্ণ নয়';

  @override
  String get expiryEmptyNearTitle => 'সব ঠিক আছে';

  @override
  String get expiryEmptyDefaultTitle => 'এখনও কোনো রেকর্ড নেই';

  @override
  String get expiryEmptyBody => 'এই বিভাগে কোনো রেকর্ড নেই।';

  @override
  String expiryProductShort(String id) {
    return 'পণ্য $id';
  }

  @override
  String expiryBatch(String batch) {
    return 'ব্যাচ $batch';
  }

  @override
  String expiryQty(String qty) {
    return 'পরিমাণ $qty';
  }

  @override
  String expiryExp(String date) {
    return 'মেয়াদ $date';
  }

  @override
  String get expiryPillToday => 'আজ';

  @override
  String get expiryPillTomorrow => 'আগামীকাল';

  @override
  String expiryPillDays(int days) {
    return '${days}d';
  }

  @override
  String get expiryPillSoon => 'শীঘ্রই';

  @override
  String get expiryLoadError => 'মেয়াদের রেকর্ড লোড করা যায়নি।';

  @override
  String get expiryCouldNotLoadSemantic => 'লোড করা যায়নি';

  @override
  String get inventoryTitle => 'ইনভেন্টরি';

  @override
  String get inventorySearchTooltip => 'ইনভেন্টরি খুঁজুন';

  @override
  String get inventorySearchHint => 'পণ্য বা EAN দিয়ে খুঁজুন...';

  @override
  String get inventoryStockMovement => 'স্টক মুভমেন্ট';

  @override
  String get inventoryLowStockAlerts => 'কম স্টক সতর্কতা';

  @override
  String get inventoryLoadError => 'ইনভেন্টরি লোড করা যায়নি';

  @override
  String get inventoryEmpty => 'কোনো ইনভেন্টরি আইটেম পাওয়া যায়নি';

  @override
  String inventoryNoMatches(String query) {
    return '\"$query\" এর জন্য কোনো মিল নেই';
  }

  @override
  String inventoryProductShort(String id) {
    return 'পণ্য $id';
  }

  @override
  String get inventoryBelowThreshold => 'সীমার নিচে';

  @override
  String get inventoryInStock => 'স্টকে আছে';

  @override
  String get inventoryUnitsLabel => 'ইউনিট';

  @override
  String get inventoryTotalQuantity => 'মোট পরিমাণ';

  @override
  String get inventoryLowStockThreshold => 'কম-স্টক সীমা';

  @override
  String inventoryQtyUnits(int count) {
    return '$count ইউনিট';
  }

  @override
  String get inventoryBatchLedgerHint =>
      'সম্পূর্ণ ব্যাচ লেজার দেখতে \"স্টক মুভমেন্ট\" ট্যাপ করুন।';

  @override
  String get inventoryLowStockBadge => 'কম স্টক';

  @override
  String get tasksTitle => 'কাজ';

  @override
  String get tasksTabMine => 'আমার কাজ';

  @override
  String get tasksTabAll => 'সব';

  @override
  String get tasksNewTask => 'নতুন কাজ';

  @override
  String get tasksEmptyTitle => 'এখানে কোনো কাজ নেই';

  @override
  String get tasksEmptyBody => 'এই ভিউতে বরাদ্দ করা কাজগুলি এখানে দেখা যাবে।';

  @override
  String get tasksLoadError => 'কাজ লোড করা যায়নি';

  @override
  String get taskEvidence => 'প্রমাণ';

  @override
  String get priorityHigh => 'উচ্চ';

  @override
  String get priorityMedium => 'মাঝারি';

  @override
  String get priorityLow => 'নিম্ন';

  @override
  String get priorityUrgent => 'জরুরি';

  @override
  String get taskStatusOpen => 'খোলা';

  @override
  String get taskStatusPending => 'মুলতুবি';

  @override
  String get taskStatusInProgress => 'চলমান';

  @override
  String get taskStatusCompleted => 'সম্পন্ন';

  @override
  String get taskStatusCancelled => 'বাতিল';

  @override
  String get scanTitle => 'একটি পণ্য স্ক্যান করুন';

  @override
  String get scanAlignHint => 'ফ্রেমের মধ্যে বারকোড সারিবদ্ধ করুন';

  @override
  String scanCandidateVerifying(String code, int streak, int required) {
    return 'Verifying $code — $streak/$required reads agree';
  }

  @override
  String get scanCandidateVerified => 'Verified — ready to proceed';

  @override
  String get scanProceed => 'Proceed';

  @override
  String get scanBatchHint =>
      'ব্যাচ মোড — স্ক্যান করতে থাকুন, আইটেম স্বয়ংক্রিয়ভাবে যোগ হবে';

  @override
  String scanBatchAdded(String code, int count) {
    return '$code যোগ করা হয়েছে · $count স্ক্যান করা হয়েছে';
  }

  @override
  String scanBatchDone(int count) {
    return 'সম্পন্ন · $count';
  }

  @override
  String get scanLabelAction => 'লেবেল স্ক্যান';

  @override
  String get scanGalleryAction => 'গ্যালারি';

  @override
  String get scanEnterManually => 'ম্যানুয়ালি লিখুন';

  @override
  String get scanBulkAudit => 'বাল্ক অডিট';

  @override
  String get scanHistoryAction => 'ইতিহাস';

  @override
  String get scanFlash => 'ফ্ল্যাশ';

  @override
  String get scanTroubleTitle => 'স্ক্যান করতে সমস্যা?';

  @override
  String get scanTroubleBody =>
      'কম আলো বা ক্ষতিগ্রস্ত বারকোড? ফ্ল্যাশ চালু করুন, অথবা পরিবর্তে লেবেল পড়ুন।';

  @override
  String get scanGalleryNoBarcode =>
      'কোনো বারকোড পাওয়া যায়নি। টিপ: উপাদান পড়তে \'লেবেল স্ক্যান\' ব্যবহার করুন।';

  @override
  String get scanInvalidEan => 'একটি বৈধ EAN-8, EAN-13, বা UPC-A কোড লিখুন';

  @override
  String get scanWebTitle => 'স্ক্যান';

  @override
  String get scanWebUnavailable =>
      'ওয়েবে ক্যামেরা স্ক্যানিং উপলব্ধ নয়।\nবারকোড ম্যানুয়ালি লিখুন:';

  @override
  String get scanEanFieldLabel => 'EAN / UPC কোড';

  @override
  String get scanEanHintExample => 'যেমন 5901234123457';

  @override
  String get scanLookUp => 'খুঁজুন';

  @override
  String get scanEnterBarcode => 'বারকোড লিখুন';

  @override
  String get scanHistoryTitle => 'স্ক্যান ইতিহাস';

  @override
  String get scanNoHistory => 'এই সেশনে এখনও কোনো স্ক্যান নেই।';

  @override
  String get homeGreetingMorning => 'সুপ্রভাত';

  @override
  String get homeGreetingAfternoon => 'শুভ অপরাহ্ন';

  @override
  String get homeGreetingEvening => 'শুভ সন্ধ্যা';

  @override
  String get homeGreetingFallbackName => 'বন্ধু';

  @override
  String get homeTrialEnded =>
      'ফ্রি ট্রায়াল শেষ — অ্যাক্সেস ধরে রাখতে আপগ্রেড করুন';

  @override
  String homeTrialDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days দিন',
      one: '1 দিন',
    );
    return 'ফ্রি ট্রায়াল · $_temp0 বাকি';
  }

  @override
  String get homeUpgradeArrow => 'আপগ্রেড →';

  @override
  String get homeKpiSaved => 'সংরক্ষিত';

  @override
  String get homeKpiNearExpiry => 'শীঘ্রই মেয়াদ';

  @override
  String get homeKpiRecallAlerts => 'রিকল সতর্কতা';

  @override
  String get homeKpiOpenTasks => 'খোলা কাজ';

  @override
  String get homeKpiLowStock => 'কম স্টক';

  @override
  String get homeEyebrowFoodSafety => 'খাদ্য সুরক্ষা সতর্কতা';

  @override
  String get homeEyebrowToday => 'আজকের কাজ';

  @override
  String get homeEyebrowHealthScan => 'আপনার হেলথ স্ক্যান';

  @override
  String get homeEyebrowScanToLearn => 'স্ক্যান করে জানুন';

  @override
  String get homeEyebrowAllClear => 'সব ঠিক আছে';

  @override
  String homeStoryRecall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি রিকল করা পণ্য — দেখুন আপনার বাড়িতে কী আছে',
      one: '1টি রিকল করা পণ্য — দেখুন আপনার বাড়িতে কী আছে',
    );
    return '$_temp0';
  }

  @override
  String homeStoryNearExpiryConsumer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$countটি সংরক্ষিত আইটেম এই সপ্তাহে মেয়াদ শেষ হচ্ছে — ব্যবহার করুন',
      one: '1টি সংরক্ষিত আইটেম এই সপ্তাহে মেয়াদ শেষ হচ্ছে — ব্যবহার করুন',
    );
    return '$_temp0';
  }

  @override
  String get homeStoryKnowWhatYouEat => 'আপনি কী খান তা জানুন';

  @override
  String get homeStoryScanInside =>
      'যেকোনো খাদ্য বারকোডে ক্যামেরা তাক করুন — ভেতরে কী আছে দেখুন';

  @override
  String homeStoryNearExpiryBusiness(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি আইটেম শীঘ্রই মেয়াদ — তাক পরিষ্কার করুন',
      one: '1টি আইটেম শীঘ্রই মেয়াদ — তাক পরিষ্কার করুন',
    );
    return '$_temp0';
  }

  @override
  String homeStoryOpenTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি কাজে আজ আপনাকে দরকার',
      one: '1টি কাজে আজ আপনাকে দরকার',
    );
    return '$_temp0';
  }

  @override
  String homeStoryLowStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি আইটেমের স্টক কমে যাচ্ছে',
      one: '1টি আইটেমের স্টক কমে যাচ্ছে',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreToday => 'এই যে আজ আপনার দোকান';

  @override
  String get homeStoreAllGood => 'শাবাশ! আপনার দোকান আজ দারুণ অবস্থায় আছে';

  @override
  String get homeCtaViewRecallAlerts => 'রিকল সতর্কতা দেখুন';

  @override
  String get homeCtaCheckExpiry => 'মেয়াদ দেখুন';

  @override
  String get homeCtaOpenExpiry => 'মেয়াদ খুলুন';

  @override
  String get homeCtaViewTasks => 'কাজ দেখুন';

  @override
  String get homeCtaCheckInventory => 'ইনভেন্টরি দেখুন';

  @override
  String get homeCtaOpenTasks => 'কাজ খুলুন';

  @override
  String get homeCtaRunAudit => 'একটি দ্রুত অডিট চালান';

  @override
  String get homeQuickActions => 'দ্রুত ক্রিয়া';

  @override
  String get homeQuickScan => 'স্ক্যান';

  @override
  String get homeQuickShopping => 'শপিং';

  @override
  String get homeQuickAddExpiry => 'মেয়াদ যোগ করুন';

  @override
  String get homeQuickNewTask => 'নতুন কাজ';

  @override
  String get homeRecentTasks => 'সাম্প্রতিক কাজ';

  @override
  String get homeSeeAll => 'সব দেখুন';

  @override
  String get homeNoOpenTasks => 'কোনো খোলা কাজ নেই — একটি তৈরি করুন';

  @override
  String homeTaskAssignedTo(String name) {
    return '$name কে বরাদ্দ করা হয়েছে';
  }

  @override
  String get homeTaskOverdue => 'বকেয়া';

  @override
  String get homeTaskDueToday => 'আজ দেয়';

  @override
  String get homeTaskDueTomorrow => 'আগামীকাল দেয়';

  @override
  String homeTaskDueInDays(int days) {
    return '$days দিনে দেয়';
  }

  @override
  String homeTaskDueOn(String date) {
    return 'দেয় $date';
  }

  @override
  String get homeHowHelps => 'RADHA কীভাবে আপনাকে সাহায্য করে';

  @override
  String get homeScanBarcodeTitle => 'যেকোনো খাদ্য বারকোড স্ক্যান করুন';

  @override
  String get homeScanBarcodeBody =>
      'হেলথ রেটিং, উপাদান, এবং কী লক্ষ্য রাখতে হবে — সব দেখুন।';

  @override
  String get homeRecallTitle => 'সুরক্ষা রিকল সতর্কতা';

  @override
  String get homeRecallBody => 'রিকল করা খাদ্য পণ্য সম্পর্কে অবগত থাকুন।';

  @override
  String get homePromoKnowFoodEyebrow => 'আপনার খাবার জানুন';

  @override
  String get homePromoKnowFoodHeadline =>
      'লেবেল স্ক্যান করুন — সত্যিই ভেতরে কী আছে দেখুন';

  @override
  String get homePromoKnowFoodCta => 'স্ক্যান করে জানুন';

  @override
  String get homePromoExpiryEyebrow => 'কোনো তারিখ মিস করবেন না';

  @override
  String get homePromoExpiryHeadline =>
      'প্রতিটি মেয়াদ হাতছাড়া হওয়ার আগে ধরুন';

  @override
  String get homePromoExpiryCta => 'মেয়াদ ট্র্যাক করুন';

  @override
  String get homePromoFestiveEyebrow => 'উৎসবের বাছাই';

  @override
  String get homePromoFestiveHeadline =>
      'মরশুমের কেনাকাটা করুন, স্বাস্থ্যকর উপায়ে';

  @override
  String get homePromoFestiveCta => 'পণ্য ব্রাউজ করুন';

  @override
  String get homePromoBazaarEyebrow => 'আজকের বাজার';

  @override
  String get homePromoBazaarHeadline => 'মিনিটেই আপনার তাক অডিট করুন';

  @override
  String get homePromoBazaarCta => 'অডিট শুরু করুন';

  @override
  String get homeShopByCategory => 'বিভাগ অনুযায়ী কিনুন';

  @override
  String get homeShopByCategorySubtitle =>
      'স্ক্যান বা ব্রাউজ করতে একটি আইলে ট্যাপ করুন';

  @override
  String get onboardingWelcomeValue =>
      'স্ক্যান করুন, ট্র্যাক করুন, আপনার স্টক অডিট করুন — স্প্রেডশিট ছাড়াই।';

  @override
  String get onboardingCapabilitiesTitle =>
      'দোকানের মেঝের জন্য তৈরি,\nব্যাক অফিসের জন্য নয়।';

  @override
  String get onboardingCapScanTitle => 'এক ট্যাপে পণ্য স্ক্যান করুন';

  @override
  String get onboardingCapScanBody =>
      'হেলথ এবং অনুমোদন পূর্ব-যাচাইকৃত EAN লুকআপ।';

  @override
  String get onboardingCapExpiryTitle => 'ক্ষতির আগে মেয়াদ ধরুন';

  @override
  String get onboardingCapExpiryBody =>
      'OCR-সহায়ক তারিখ এবং প্রতি-বিভাগ সীমা।';

  @override
  String get onboardingCapAuditTitle => 'এমন অডিট চালান যা দল শেষ করতে পারে';

  @override
  String get onboardingCapAuditBody => 'কাজ, প্রমাণ এবং বাল্ক স্ক্যান সেশন।';

  @override
  String get onboardingSegmentTitle => 'আপনি এখানে কে হিসেবে আছেন?';

  @override
  String get onboardingSegmentSubtitle =>
      'সবচেয়ে কাছের বিকল্পটি বেছে নিন। আপনি পরে সেটিংসে পরিবর্তন করতে পারবেন।';

  @override
  String get segmentPersonalTitle => 'ব্যক্তিগত';

  @override
  String get segmentPersonalBody => 'শুধু নিজের জন্য কেনাকাটা';

  @override
  String get segmentParentTitle => 'অভিভাবক';

  @override
  String get segmentParentBody => 'আমার পরিবার / সন্তানদের জন্য কেনাকাটা';

  @override
  String get segmentBusinessTitle => 'ব্যবসার মালিক';

  @override
  String get segmentBusinessBody => 'আমি একটি ছোট খুচরা দোকান চালাই';

  @override
  String get segmentPharmacyTitle => 'ফার্মেসি';

  @override
  String get segmentPharmacyBody => 'আমি একটি ফার্মেসি / কেমিস্ট চালাই';

  @override
  String get segmentInstitutionTitle => 'প্রতিষ্ঠান';

  @override
  String get segmentInstitutionBody => 'স্কুল / হোস্টেল / ক্যান্টিন';

  @override
  String get segmentAuditorTitle => 'অডিটর (আমন্ত্রিত)';

  @override
  String get segmentAuditorBody => 'আমার কাছে একটি আমন্ত্রণ কোড আছে';

  @override
  String get allergenTitle => 'অ্যালার্জেন';

  @override
  String get allergenLoadError => 'আপনার অ্যালার্জেন প্রোফাইল লোড করা যায়নি।';

  @override
  String get allergenHeading => 'আপনার অ্যালার্জেন';

  @override
  String get allergenIntro =>
      'আপনার যেগুলিতে প্রতিক্রিয়া হয় সেই অ্যালার্জেনগুলিতে ট্যাপ করুন। স্ক্যান করা পণ্যে সেগুলি থাকলে আমরা আপনাকে সতর্ক করব।';

  @override
  String allergenTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি অ্যালার্জেন ট্র্যাক করা হচ্ছে',
      one: '1টি অ্যালার্জেন ট্র্যাক করা হচ্ছে',
    );
    return '$_temp0';
  }

  @override
  String get allergenNoneTracked => 'এখনও কোনো অ্যালার্জেন ট্র্যাক করা হয়নি';

  @override
  String get allergenSavedCleared => 'অ্যালার্জেন প্রোফাইল সাফ করা হয়েছে।';

  @override
  String get allergenSaved => 'অ্যালার্জেন প্রোফাইল সংরক্ষিত হয়েছে।';

  @override
  String get allergenSaveError => 'আপনার অ্যালার্জেন সংরক্ষণ করা যায়নি।';

  @override
  String get allergenPeanut => 'চিনাবাদাম';

  @override
  String get allergenTreeNut => 'গাছের বাদাম';

  @override
  String get allergenDairy => 'দুগ্ধজাত';

  @override
  String get allergenEggs => 'ডিম';

  @override
  String get allergenSoy => 'সয়া';

  @override
  String get allergenWheat => 'গম';

  @override
  String get allergenFish => 'মাছ';

  @override
  String get allergenShellfish => 'শেলফিশ';

  @override
  String get allergenSesame => 'তিল';

  @override
  String get allergenGluten => 'গ্লুটেন';

  @override
  String get allergenMustard => 'সরিষা';

  @override
  String get allergenCelery => 'সেলারি';

  @override
  String get allergenLupin => 'লুপিন';

  @override
  String get allergenMolluscs => 'মলাস্ক';

  @override
  String get allergenSulphites => 'সালফাইট';

  @override
  String get commonSuccess => 'সফল';

  @override
  String lockedFeatureUpgradeTo(String planName) {
    return '$planName এ আপগ্রেড করুন';
  }

  @override
  String lockedFeaturePlan(String planName) {
    return 'এই বৈশিষ্ট্যটি $planName প্ল্যানের অংশ।';
  }

  @override
  String get lockedFeatureViewPlans => 'প্ল্যান দেখুন';

  @override
  String get notFoundSemantic => 'পৃষ্ঠা পাওয়া যায়নি';

  @override
  String get notFoundTitle => 'এই পৃষ্ঠাটি হারিয়ে গেছে';

  @override
  String get notFoundBody =>
      'আপনি যা খুঁজছিলেন তা আমরা খুঁজে পাইনি। চলুন আপনাকে আবার হোমে নিয়ে যাই।';

  @override
  String get notFoundBackHome => 'হোমে ফিরুন';

  @override
  String get commonCouldNotLoad => 'লোড করা যায়নি';

  @override
  String get sendOtp => 'OTP পাঠান';

  @override
  String get otpUseCode => 'কোড ব্যবহার করুন';

  @override
  String get ohsPickStore => 'ড্যাশবোর্ড খোলার আগে একটি স্টোর বেছে নিন।';

  @override
  String get profileAccount => 'অ্যাকাউন্ট';

  @override
  String get profileManageStores => 'স্টোর পরিচালনা';

  @override
  String get profileSavedProducts => 'সংরক্ষিত পণ্য';

  @override
  String get profileSubscription => 'সাবস্ক্রিপশন';

  @override
  String get profilePreferences => 'পছন্দসমূহ';

  @override
  String get profileAllergenProfile => 'অ্যালার্জেন প্রোফাইল';

  @override
  String get profileShoppingList => 'শপিং তালিকা';

  @override
  String get recallTitle => 'রিকল সতর্কতা';

  @override
  String recallProductFallback(String id) {
    return 'পণ্য $id';
  }

  @override
  String recallDate(String date) {
    return 'প্রত্যাহার করা হয়েছে $date';
  }

  @override
  String get recallViewProduct => 'পণ্য দেখুন';

  @override
  String get recallLoadError => 'রিকল লোড করা যায়নি।';

  @override
  String get recallEmpty => 'কোনো সক্রিয় রিকল নেই';

  @override
  String get recallEmptyBody =>
      'নিয়ন্ত্রক সংস্থা কর্তৃক জারি করা হলে পণ্য রিকল সতর্কতা এখানে দেখা যাবে।';

  @override
  String get referralsLoadError => 'রেফারেল লোড করা যায়নি।';

  @override
  String get referralsCopyCode => 'কোড কপি করুন';

  @override
  String get referralsShareInvite => 'আমন্ত্রণ শেয়ার করুন';

  @override
  String get referralsCodeCopied => 'কোড কপি হয়েছে';

  @override
  String get referralsInvitees => 'আমন্ত্রিতরা';

  @override
  String get referralsRewardsEarned => 'অর্জিত পুরস্কার';

  @override
  String get referralsCodeRedeemed => 'কোড রিডিম হয়েছে';

  @override
  String get referralsEnterCode => 'একটি রেফারেল কোড লিখুন';

  @override
  String get referralsRedeem => 'রিডিম করুন';

  @override
  String get referralsRedeemError => 'কোড রিডিম করা যায়নি';

  @override
  String get referralsRedeemSubtitle =>
      'বন্ধুর আমন্ত্রণ আছে? নিচে তাদের কোড লিখুন।';

  @override
  String get commonClear => 'সাফ করুন';

  @override
  String get commonShare => 'শেয়ার করুন';

  @override
  String get healthSugar => 'চিনি';

  @override
  String get healthSalt => 'লবণ';

  @override
  String get healthFat => 'চর্বি';

  @override
  String get healthProcessed => 'প্রক্রিয়াজাত';

  @override
  String get healthChildSuitable => 'শিশুদের জন্য উপযুক্ত';

  @override
  String get productDetailsTitle => 'পণ্যের বিবরণ';

  @override
  String get productDetailLoadError => 'এই পণ্যটি লোড করা যায়নি';

  @override
  String get productCheckAllergens => 'অ্যালার্জেন যাচাই করুন';

  @override
  String get productExplainIngredients => 'উপাদান ব্যাখ্যা করুন';

  @override
  String get productSeeHealthierOptions => 'স্বাস্থ্যকর বিকল্প দেখুন';

  @override
  String get productViewHealthyAlternatives => 'স্বাস্থ্যকর বিকল্প দেখুন';

  @override
  String get productHealthAssessment => 'স্বাস্থ্য মূল্যায়ন';

  @override
  String get productNutritionInfo => 'পুষ্টি তথ্য';

  @override
  String get productAllergenCheck => 'অ্যালার্জেন যাচাই';

  @override
  String get productSeeFullExplanation => 'সম্পূর্ণ ব্যাখ্যা দেখুন';

  @override
  String get productHealthierOptions => 'স্বাস্থ্যকর বিকল্প';

  @override
  String get commonYes => 'হ্যাঁ';

  @override
  String get nutritionProtein => 'প্রোটিন';

  @override
  String get nutritionTotalSugars => 'মোট চিনি';

  @override
  String get nutritionEnergy => 'শক্তি';

  @override
  String get nutritionTotalFat => 'মোট চর্বি';

  @override
  String get nutritionSaturatedFat => 'স্যাচুরেটেড ফ্যাট';

  @override
  String get nutritionCarbohydrates => 'কার্বোহাইড্রেট';

  @override
  String get nutritionFibre => 'ফাইবার';

  @override
  String get nutritionSodium => 'সোডিয়াম';

  @override
  String get nutritionAll => 'সব পুষ্টি উপাদান';

  @override
  String get nutritionPer100g => 'প্রতি 100 গ্রাম';

  @override
  String get nutritionPer50g => 'প্রতি 50 গ্রাম';

  @override
  String get productDetailSavedAlert =>
      'সংরক্ষিত — কখনও রিকল হলে আমরা আপনাকে সতর্ক করব।';

  @override
  String get productDetailSaveError => 'সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get productDetailWhatYoullLike => 'আপনি যা পছন্দ করবেন';

  @override
  String get productDetailWhatConcern => 'কী আপনাকে চিন্তিত করবে';

  @override
  String get productDetailIngredientDeepDive => 'উপাদানের গভীর বিশ্লেষণ';

  @override
  String get productDetailPersonalisedFlags => 'ব্যক্তিগতকৃত ফ্ল্যাগ';

  @override
  String get productDetailAlreadyBought => 'ইতিমধ্যে কেনা';

  @override
  String get productDetailScanToUnlock => 'আনলক করতে স্ক্যান করুন';

  @override
  String get productDetailTitle => 'পণ্য';

  @override
  String get productDetailSave => 'সেভ করুন';

  @override
  String get productDetailSaved => 'সেভ হয়েছে';

  @override
  String get productDetailHealthNotRated => 'স্বাস্থ্য রেটিং এখনও আসেনি';

  @override
  String get productDetailHealthNotRatedBody =>
      'এই পণ্যের সম্পূর্ণ স্বাস্থ্য বিশ্লেষণ RADHA-তে আনতে স্ক্যান করুন।';

  @override
  String get productDetailHealthLabel => 'RADHA স্বাস্থ্য রেটিং';

  @override
  String get productDetailHighProtein => 'উচ্চ প্রোটিন';

  @override
  String get productDetailGoodFibre => 'ভালো আঁশ';

  @override
  String get productDetailMinimallyProcessed => 'ন্যূনতম প্রক্রিয়াজাত';

  @override
  String get productDetailHighSugar => 'উচ্চ চিনি';

  @override
  String get productDetailHighSatFat => 'উচ্চ সম্পৃক্ত চর্বি';

  @override
  String get productDetailHighSodium => 'উচ্চ সোডিয়াম';

  @override
  String get productDetailUltraProcessed => 'অতি-প্রক্রিয়াজাত';

  @override
  String get productDetailNutritionNote =>
      'পণ্যের প্রকৃত পুষ্টিমান (প্রতি ১০০ গ্রাম) এর উপর ভিত্তি করে।';

  @override
  String get productDetailKeyNutrients => 'মূল পুষ্টি উপাদান';

  @override
  String get productDetailRdaNote =>
      '% দৈনিক প্রস্তাবিত পরিমাণ (প্রাপ্তবয়স্ক)।';

  @override
  String get productDetailForYou => 'আপনার জন্য';

  @override
  String get productDetailIngredientLockBody =>
      'প্রতিটি উপাদানের নিরাপত্তা রায়সহ ব্যাখ্যা দেখুন।';

  @override
  String get productDetailIngredientError =>
      'এই মুহূর্তে উপাদানগুলি ব্যাখ্যা করা সম্ভব হয়নি।';

  @override
  String get productDetailAllergenLockBody =>
      'এই পণ্যটি আপনার সংরক্ষিত অ্যালার্জেন এবং স্বাস্থ্য লক্ষ্যের বিপরীতে মিলিয়ে দেখুন।';

  @override
  String get productDetailAllergenError => 'এখন ব্যক্তিগতকরণ করা সম্ভব হয়নি।';

  @override
  String get productDetailNoAllergens =>
      'এই পণ্যে কোনো অ্যালার্জেন পাওয়া যায়নি।';

  @override
  String productDetailAllergenAvoid(String name) {
    return '$name — আপনি এটি এড়িয়ে চলেন';
  }

  @override
  String productDetailUnlockWith(String plan) {
    return '$plan দিয়ে আনলক করুন';
  }

  @override
  String get productDetailWouldYouBuy => 'আপনি কি এই পণ্যটি কিনবেন?';

  @override
  String get productDetailThanksForSharing => 'শেয়ার করার জন্য ধন্যবাদ!';

  @override
  String get productDetailNutritionNotIn => 'সম্পূর্ণ পুষ্টি তথ্য এখনও আসেনি';

  @override
  String get productDetailNutritionNotInBody =>
      'প্রকৃত পুষ্টি ও স্বাস্থ্য বিশ্লেষণ RADHA-তে আনতে এই পণ্যের বারকোড স্ক্যান করুন।';

  @override
  String productDetailShareText(String name) {
    return 'RADHA-তে \"$name\" যাচাই করা হয়েছে।';
  }

  @override
  String productDetailShareTextRated(String name, String rating, String label) {
    return 'RADHA-তে \"$name\" যাচাই করা হয়েছে — RADHA স্বাস্থ্য রেটিং $rating/5 ($label)।';
  }

  @override
  String get catalogSearchBarLabel => 'আপনার পছন্দের পণ্য খুঁজুন';

  @override
  String get catalogSearchPromptTitle => 'একটি পণ্য খুঁজুন';

  @override
  String get catalogSearchPromptBody =>
      'স্বাস্থ্য রেটিং এবং ভেতরে কী আছে তা দেখতে পণ্যের নাম বা ব্র্যান্ড দিয়ে অনুসন্ধান করুন।';

  @override
  String get commonNo => 'না';

  @override
  String get scanApprovalNotInAudit => 'অনুমোদন স্ট্যাটাস — অডিটে নেই';

  @override
  String get scanApprovalChecking => 'অনুমোদিত তালিকা যাচাই করা হচ্ছে…';

  @override
  String get scanApprovalCheckFailed => 'অনুমোদন যাচাই করা যায়নি';

  @override
  String get scanApprovalApproved => 'অনুমোদিত — তালিকায়';

  @override
  String get scanApprovalNoList => 'কোনো অনুমোদিত তালিকা সক্রিয় নেই';

  @override
  String get scanApprovalInvalidBarcode => 'অবৈধ বারকোড';

  @override
  String get scanApprovalNotInList => 'অনুমোদিত তালিকায় নেই';

  @override
  String scanApprovalStatus(String label) {
    return 'অনুমোদন স্ট্যাটাস: $label';
  }

  @override
  String get scanResultAddToExpiry => 'মেয়াদে যোগ করুন';

  @override
  String get scanResultAddToStock => 'স্টকে যোগ করুন';

  @override
  String get scanResultSaveToList => 'তালিকায় সংরক্ষণ করুন';

  @override
  String get scanResultNoProduct => 'কোনো পণ্য পাওয়া যায়নি';

  @override
  String get scanResultScanLabel => 'লেবেল স্ক্যান করুন';

  @override
  String get auditRecordError => 'স্ক্যান রেকর্ড করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get auditEndError => 'অডিট শেষ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get auditNoStore => 'কোনো স্টোর বরাদ্দ নেই';

  @override
  String get auditNoStoreBody =>
      'বাল্ক অডিট একটি স্টোরের অনুমোদিত EAN তালিকার বিপরীতে চলে। একজন অ্যাডমিনকে আপনাকে একটি স্টোর বরাদ্দ করতে বলুন, তারপর অডিটে ফিরে আসুন।';

  @override
  String get auditMatched => 'মিলেছে';

  @override
  String get auditNotInList => 'তালিকায় নেই';

  @override
  String get auditNoList => 'কোনো তালিকা নেই';

  @override
  String get auditInvalid => 'অবৈধ';

  @override
  String get auditUnchecked => 'অযাচাইকৃত';

  @override
  String get commonTotal => 'মোট';

  @override
  String get auditEnterScanEan => 'EAN লিখুন বা স্ক্যান করুন';

  @override
  String auditStatus(String label) {
    return 'স্ট্যাটাস: $label';
  }

  @override
  String get auditStartAuditing => 'অডিট শুরু করুন';

  @override
  String get auditStartBody =>
      'এই স্টোরের অনুমোদিত তালিকার সাথে যাচাই করতে উপরে EAN স্ক্যান বা টাইপ করুন। প্রতিটি ফলাফল মিলেছে বা তালিকায়-নেই স্ট্যাটাস নিয়ে এখানে আসে।';

  @override
  String get auditTitle => 'বাল্ক EAN অডিট';

  @override
  String get auditEndAction => 'অডিট শেষ করুন';

  @override
  String get auditEndingAction => 'শেষ হচ্ছে…';

  @override
  String get auditEanInvalid => 'একটি বৈধ EAN-8, EAN-13, বা UPC-A কোড দিন';

  @override
  String auditEndedSummary(int matched, int notMatched) {
    return 'অডিট শেষ — $matched মিলেছে, $notMatched তালিকায় নেই';
  }

  @override
  String get cameraCapture => 'ক্যাপচার করুন';

  @override
  String get labelScanReadError => 'লেবেল পড়া যায়নি';

  @override
  String get labelScanReadErrorBody =>
      'ভালো আলোতে আবার চেষ্টা করুন, স্থির রাখুন, এবং ফ্রেমটি উপাদান প্যানেল দিয়ে পূর্ণ করুন।';

  @override
  String get labelScanAnalysisFailed => 'বিশ্লেষণ ব্যর্থ';

  @override
  String get labelScanIntro => 'RADHA আপনার জন্য লেবেল পড়ে';

  @override
  String get labelScanTakePhoto => 'ছবি তুলুন';

  @override
  String get labelScanChooseGallery => 'গ্যালারি থেকে বেছে নিন';

  @override
  String get labelScanAnother => 'আরেকটি স্ক্যান করুন';

  @override
  String labelScanSeePlans(String plan) {
    return '$plan প্ল্যান দেখুন';
  }

  @override
  String get labelScanMaybeLater => 'হয়তো পরে';

  @override
  String get labelScanTitle => 'লেবেল স্ক্যান করুন';

  @override
  String get labelScanNoBarcode => 'বারকোড নেই? লেবেল পড়ুন';

  @override
  String get labelScanIdleBody =>
      'উপাদান প্যানেলের দিকে পয়েন্ট করুন — আমরা পড়ে বলব ভেতরে কী আছে। বারকোড ছাড়া পণ্যেও কাজ করে।';

  @override
  String get labelScanFlashNote =>
      'কম আলোতে ক্যামেরা ফ্ল্যাশ স্বয়ংক্রিয়ভাবে চালু হয়।';

  @override
  String get labelScanReading => 'লেবেল পড়া হচ্ছে…';

  @override
  String get labelScanAnalyzing => 'উপাদান বিশ্লেষণ করা হচ্ছে…';

  @override
  String get labelScanFallbackError =>
      'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get labelScanResultFallback => 'লেবেল বিশ্লেষণ';

  @override
  String get labelScanLowConfidence =>
      'কম আস্থা — স্পষ্ট ছবি আরও ভালো ফলাফল দিতে পারে।';

  @override
  String get labelScanWhatToWatch => 'সতর্ক থাকুন';

  @override
  String get labelScanIngredients => 'উপাদান';

  @override
  String get labelScanDisclaimer =>
      'RADHA AI লেবেল পাঠ্য থেকে পড়েছে। সঠিক তথ্যের জন্য প্যাক পরীক্ষা করুন।';

  @override
  String get labelScanUnlockTitle => 'AI লেবেল রিডিং আনলক করুন';

  @override
  String get labelScanUnlockBody =>
      'আমরা লেবেল পড়েছি, কিন্তু সম্পূর্ণ বিশ্লেষণ প্রিমিয়াম ফিচার।';

  @override
  String scanResultNotFoundBody(String ean) {
    return 'EAN $ean এর জন্য ক্যাটালগে কোনো মিল নেই — তবে আপনি এখনও লেবেল পড়তে পারেন। উপাদান প্যানেলের ছবি তুলুন, আমরা বলব ভেতরে কী আছে।';
  }

  @override
  String productScore(String score) {
    return 'স্কোর: $score';
  }

  @override
  String get catalogSearchHint => 'পণ্য বা ব্র্যান্ড খুঁজুন';

  @override
  String get catalogNoMatches => 'কোনো মিল নেই';

  @override
  String catalogNoMatchesBody(String query) {
    return '“$query” এর জন্য আমরা পণ্য খুঁজে পাইনি। অন্য নাম চেষ্টা করুন, বা পরিবর্তে আইটেমটি স্ক্যান করুন।';
  }

  @override
  String get browseTitle => 'পণ্য';

  @override
  String get browseLoadError => 'পণ্য লোড করা যায়নি';

  @override
  String browseLoadErrorBody(String category) {
    return '$category লোড করতে সমস্যা হয়েছে। আবার চেষ্টা করুন।';
  }

  @override
  String get browseSortHealthiest => 'সবচেয়ে স্বাস্থ্যকর';

  @override
  String get browseSortAZ => 'A–Z';

  @override
  String get browseFilterVegOnly => 'শুধু নিরামিষ';

  @override
  String get browseVeg => 'ভেজ';

  @override
  String get browseEmptyVeg => 'এখানে এখনও কোনো নিরামিষ আইটেম নেই';

  @override
  String browseEmptyVegBody(String category) {
    return 'এই মুহূর্তে $category এ কিছুই নিরামিষ ফিল্টারের সাথে মেলে না।';
  }

  @override
  String get browseShowAll => 'সব দেখান';

  @override
  String get browseEmpty => 'এখনও কোনো পণ্য নেই';

  @override
  String browseEmptyBody(String category) {
    return 'আমরা $category বিভাগটি স্টক করছি। ইতিমধ্যে, যেকোনো আইটেম স্ক্যান করে তার স্বাস্থ্য ও মেয়াদ দেখুন।';
  }

  @override
  String referralsShareText(String code) {
    return 'RADHA-তে আমার সাথে যোগ দিন: $code কোড ব্যবহার করুন';
  }

  @override
  String get selectStoreEmpty => 'এখনও কোনো স্টোর নেই';

  @override
  String get selectStoreEmptyBody =>
      'একটি স্টোরে যুক্ত হতে আপনার ম্যানেজারের সাথে যোগাযোগ করুন।';

  @override
  String get selectStoreEmptyDetail =>
      'আপনার অ্যাকাউন্ট এখনও কোনো স্টোরের সাথে যুক্ত নয়। অ্যাক্সেসের জন্য আপনার ম্যানেজারকে বলুন, তারপর ফিরে এসে একটি বেছে নিন।';

  @override
  String get selectStoreContactManager => 'আপনার ম্যানেজারের সাথে যোগাযোগ করুন';

  @override
  String get expiryConsumerTitle => 'ব্যবসায়িক অ্যাকাউন্টের জন্য';

  @override
  String get expiryConsumerBody =>
      'মেয়াদ শেষ হওয়ার ট্র্যাকিং একটি খুচরা দোকানের বৈশিষ্ট্য। এটি ব্যবহার করতে আপনার অ্যাকাউন্ট একটি দোকানে সংযুক্ত করুন।';

  @override
  String get tasksConsumerTitle => 'ব্যবসায়িক অ্যাকাউন্টের জন্য';

  @override
  String get tasksConsumerBody =>
      'টাস্ক ম্যানেজমেন্ট একটি খুচরা দোকানের বৈশিষ্ট্য। এটি ব্যবহার করতে আপনার অ্যাকাউন্ট একটি দোকানে সংযুক্ত করুন।';

  @override
  String get languageSavedLocally => 'ভাষা শুধুমাত্র স্থানীয়ভাবে সংরক্ষিত';

  @override
  String languageSavedLocallyError(String error) {
    return 'ভাষা শুধুমাত্র স্থানীয়ভাবে সংরক্ষিত: $error';
  }

  @override
  String get signOutConfirmBody =>
      'অ্যাপ ব্যবহার করতে আপনাকে OTP দিয়ে আবার সাইন ইন করতে হবে।';

  @override
  String get scanResultTitle => 'স্ক্যান ফলাফল';

  @override
  String scanResultShareMessage(String ean) {
    return 'আমি এই পণ্যটি RADHA-তে যাচাই করেছি — বারকোড $ean।';
  }

  @override
  String get scanResultHealthHeading => 'স্বাস্থ্য';

  @override
  String get scanResultAssessmentPending => 'মূল্যায়ন বাকি';

  @override
  String get scanResultNutritionPending =>
      'এই পণ্যটি ক্যাটালগে মিলে গেলে এখানে পুষ্টি সংকেত দেখা যাবে। ডেটাবেস সমৃদ্ধ করতে আরও পণ্য স্ক্যান করুন।';

  @override
  String get scanResultExplainIngredients => 'উপাদান ব্যাখ্যা করুন';

  @override
  String get scanResultAllergenPrompt =>
      'আপনি যা এড়িয়ে চলেন তা স্ক্যান করা পণ্যে থাকলে তাৎক্ষণিক সতর্কতা পেতে আপনার অ্যালার্জেন প্রোফাইল সেট করুন।';

  @override
  String scanResultAllergensDeclared(String allergens) {
    return 'Contains: $allergens';
  }

  @override
  String get scanResultNoAllergensDeclared =>
      'No allergens declared on this product\'s label.';

  @override
  String get taskEvidenceRequiredSnack =>
      'এই কাজটি সম্পূর্ণ করতে প্রমাণ প্রয়োজন';

  @override
  String taskMovedTo(String status) {
    return 'কাজটি $status-এ সরানো হয়েছে';
  }

  @override
  String get taskUpdateError => 'কাজটি আপডেট করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String taskAssignedTo(String name) {
    return '$name-কে বরাদ্দ করা হয়েছে';
  }

  @override
  String taskDueOn(String date) {
    return 'নির্ধারিত $date';
  }

  @override
  String get taskPriorityLabel => 'অগ্রাধিকার';

  @override
  String get taskEvidenceLabel => 'প্রমাণ';

  @override
  String get taskEvidencePhotoRequired => 'ছবি প্রয়োজন';

  @override
  String get taskEvidenceNotRequired => 'প্রয়োজন নেই';

  @override
  String taskEvidencePhotosAttached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ছবি সংযুক্ত',
      one: '1টি ছবি সংযুক্ত',
    );
    return '$_temp0';
  }

  @override
  String get taskEvidencePhotoNeeded =>
      'এই কাজটি সম্পূর্ণ করতে একটি ছবি প্রয়োজন';

  @override
  String get taskTimelineCreated => 'তৈরি হয়েছে';

  @override
  String get taskTimelineStarted => 'শুরু হয়েছে';

  @override
  String get taskActionComplete => 'সম্পূর্ণ করুন';

  @override
  String get taskLoadFailed => 'কাজ লোড করা যায়নি';

  @override
  String get taskDescriptionLabel => 'বিবরণ';

  @override
  String get taskTypeLabel => 'ধরন';

  @override
  String get taskActionStart => 'শুরু করুন';

  @override
  String get taskCreateTitle => 'কাজ তৈরি করুন';

  @override
  String get taskCreateCta => 'কাজ তৈরি করুন';

  @override
  String get taskCreatedSnack => 'কাজ তৈরি হয়েছে';

  @override
  String get taskCreateError => 'কাজ তৈরি করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get taskNotAuthorizedTitle => 'অনুমোদিত নয়';

  @override
  String get taskNotAuthorizedBody =>
      'শুধুমাত্র ম্যানেজার এবং অ্যাডমিন কাজ তৈরি করতে পারেন।';

  @override
  String get taskTitleLabel => 'শিরোনাম';

  @override
  String get taskTitleHint => 'যেমন ডেইরি বিভাগের EAN অডিট';

  @override
  String get taskTitleRequired => 'শিরোনাম প্রয়োজন';

  @override
  String get taskDescriptionHint => 'অ্যাসাইনির জন্য ঐচ্ছিক বিবরণ';

  @override
  String get taskStoreLabel => 'স্টোর';

  @override
  String get taskAssigneeLabel => 'অ্যাসাইনি (ইউজার ID)';

  @override
  String get taskAssigneeHint => 'ইউজার ID লিখুন বা খালি রাখুন';

  @override
  String get taskDueDateLabel => 'নির্ধারিত তারিখ';

  @override
  String get taskSelectDate => 'তারিখ নির্বাচন করুন';

  @override
  String get taskRequiresEvidence => 'প্রমাণ প্রয়োজন';

  @override
  String get taskRequiresEvidenceSubtitle =>
      'সম্পূর্ণ করতে অ্যাসাইনিকে একটি ছবি আপলোড করতে হবে';

  @override
  String get taskTypeEanAudit => 'EAN অডিট';

  @override
  String get taskTypeExpiryCheck => 'মেয়াদ পরীক্ষা';

  @override
  String get taskTypeInventoryCount => 'ইনভেন্টরি গণনা';

  @override
  String get taskTypeDisplayVerification => 'ডিসপ্লে যাচাই';

  @override
  String get taskTypeCustom => 'কাস্টম';

  @override
  String get checkoutStartError => 'চেকআউট শুরু করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get paymentResponseIncomplete => 'পেমেন্ট প্রতিক্রিয়া অসম্পূর্ণ ছিল।';

  @override
  String get paymentSuccessUpdated => 'পেমেন্ট সফল। প্ল্যান আপডেট হয়েছে।';

  @override
  String get paymentNotVerified => 'পেমেন্ট যাচাই করা যায়নি।';

  @override
  String get paymentVerifyFailed =>
      'পেমেন্ট যাচাই ব্যর্থ। সহায়তার সাথে যোগাযোগ করুন।';

  @override
  String get paymentCancelled => 'পেমেন্ট বাতিল করা হয়েছে।';

  @override
  String paymentFailed(String message) {
    return 'পেমেন্ট ব্যর্থ: $message';
  }

  @override
  String paymentOpeningWallet(String wallet) {
    return '$wallet খোলা হচ্ছে…';
  }

  @override
  String get paymentSheetOpenError => 'পেমেন্ট শিট খোলা যায়নি।';

  @override
  String get subscriptionLoadError => 'আপনার সাবস্ক্রিপশন লোড করা যায়নি';

  @override
  String get subscriptionLoadErrorBody =>
      'আপনার সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';

  @override
  String subscriptionCurrentPlan(String plan) {
    return 'আপনি $plan-এ আছেন';
  }

  @override
  String subscriptionUpgradeTo(String plan) {
    return '$plan-এ আপগ্রেড করুন';
  }

  @override
  String subscriptionChoosePlan(String plan) {
    return '$plan বেছে নিন';
  }

  @override
  String get subscriptionPopular => 'জনপ্রিয়';

  @override
  String get subscriptionPerMonth => '/মাস';

  @override
  String get subscriptionTitle => 'সাবস্ক্রিপশন';

  @override
  String get subscriptionHeadline => 'RADHA-এর পূর্ণ শক্তি আনলক করুন';

  @override
  String get subscriptionChooseAPlan => 'একটি প্ল্যান বেছে নিন';

  @override
  String get subscriptionCancelAnytime =>
      'যেকোনো সময় বাতিল করুন · GST অন্তর্ভুক্ত';

  @override
  String get subscriptionBillingYearly => 'বার্ষিক';

  @override
  String get subscriptionBillingMonthly => 'মাসিক';

  @override
  String get versionLoading => 'সংস্করণ লোড হচ্ছে…';

  @override
  String get versionUnavailable => 'সংস্করণ অনুপলব্ধ';

  @override
  String appVersionBuild(String version, String build) {
    return 'সংস্করণ $version ($build)';
  }

  @override
  String get shoppingListTitle => 'শপিং তালিকা';

  @override
  String get shoppingAddItem => 'আইটেম যোগ করুন';

  @override
  String get shoppingLoadError => 'আপনার তালিকা লোড করা যায়নি';

  @override
  String get shoppingLoadErrorBody =>
      'আপনার শপিং তালিকা লোড করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get shoppingEmptyTitle => 'আপনার শপিং তালিকা খালি';

  @override
  String get shoppingEmptyBody =>
      'একটি আইটেম যোগ করতে প্লাস বোতাম টিপুন, অথবা একটি পণ্য পৃষ্ঠা থেকে স্বাস্থ্যকর বিকল্প সংরক্ষণ করুন।';

  @override
  String get shoppingUpdateError => 'আইটেম আপডেট করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get shoppingDeleteError => 'আইটেম মুছে ফেলা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get shoppingAddError => 'আইটেম যোগ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get shoppingAllDone => 'সব হয়ে গেছে — সবকিছু টিক করা হয়েছে';

  @override
  String shoppingRemaining(int remaining, int total) {
    return '$totalটির মধ্যে $remainingটি কেনা বাকি';
  }

  @override
  String shoppingQty(int quantity) {
    return 'পরিমাণ: $quantity';
  }

  @override
  String get shoppingDeleteItem => 'আইটেম মুছুন';

  @override
  String get shoppingItemNameLabel => 'আইটেমের নাম';

  @override
  String get shoppingItemNameHint => 'যেমন হোল হুইট ব্রেড';

  @override
  String get shoppingItemNameRequired => 'আইটেমের নাম লিখুন';

  @override
  String get shoppingItemNameTooLong => 'এটি 120 অক্ষরের মধ্যে রাখুন';

  @override
  String get shoppingQuantityLabel => 'পরিমাণ (ঐচ্ছিক)';

  @override
  String get shoppingQuantityInvalid => 'একটি ধনাত্মক সংখ্যা লিখুন';

  @override
  String get shoppingQuantityTooHigh => 'এটি অস্বাভাবিকভাবে বেশি মনে হচ্ছে';

  @override
  String get shoppingAddToList => 'তালিকায় যোগ করুন';

  @override
  String get grnTitle => 'প্রাপ্ত পণ্য';

  @override
  String get grnFilterAll => 'সব';

  @override
  String get grnFilterDraft => 'খসড়া';

  @override
  String get grnFilterPendingReview => 'পর্যালোচনা বাকি';

  @override
  String get grnFilterPosted => 'পোস্ট করা হয়েছে';

  @override
  String get grnStatusPending => 'বাকি';

  @override
  String get grnEmptyTitle => 'এখানে কোনো GRN নেই';

  @override
  String get grnEmptyBody =>
      'সরবরাহকারীর ডেলিভারি লগ করতে একটি গুডস-রিসিভড নোট তৈরি করুন।';

  @override
  String get grnNew => 'নতুন GRN';

  @override
  String get grnLoadError => 'GRN লোড করা যায়নি';

  @override
  String get grnSupplierFallback => 'সরবরাহকারী';

  @override
  String get categoryBiscuits => 'বিস্কুট ও স্ন্যাকস';

  @override
  String get categoryBreakfast => 'প্রাতরাশ ও স্প্রেড';

  @override
  String get categoryDairy => 'দুগ্ধ ও ডিম';

  @override
  String get categoryBeverages => 'পানীয়';

  @override
  String get categoryStaples => 'প্রধান খাদ্য ও শস্য';

  @override
  String get categoryPersonalCare => 'ব্যক্তিগত পরিচর্যা';

  @override
  String get categoryHousehold => 'গৃহস্থালি';

  @override
  String get categoryFrozen => 'হিমায়িত';

  @override
  String get lowStockTitle => 'কম স্টক সতর্কতা';

  @override
  String get lowStockLoadError => 'সতর্কতা লোড করা যায়নি';

  @override
  String get lowStockEmpty => 'সব স্টক স্তর স্বাস্থ্যকর';

  @override
  String lowStockCurrentThreshold(int quantity, int threshold) {
    return 'বর্তমান: $quantity / সীমা: $threshold';
  }

  @override
  String get lowStockRestock => 'পুনরায় স্টক করুন';

  @override
  String get commonRequired => 'আবশ্যক';

  @override
  String get commonOptional => 'ঐচ্ছিক';

  @override
  String get commonQuantity => 'পরিমাণ';

  @override
  String get smTitle => 'স্টক মুভমেন্ট';

  @override
  String get smStockIn => 'স্টক ইন';

  @override
  String get smStockOut => 'স্টক আউট';

  @override
  String get smProductLabel => 'পণ্য';

  @override
  String get smProductHint => 'পণ্য ID বা EAN লিখুন';

  @override
  String get smReasonLabel => 'কারণ';

  @override
  String get smSelectReason => 'কারণ নির্বাচন করুন';

  @override
  String get smBatchLabel => 'ব্যাচ নম্বর';

  @override
  String get smExpiryLabel => 'মেয়াদ তারিখ';

  @override
  String get smExpiryOptionalHint => 'ঐচ্ছিক — নির্বাচন করতে ট্যাপ করুন';

  @override
  String get smNotesLabel => 'নোট';

  @override
  String get smNotesHint => 'ঐচ্ছিক নোট';

  @override
  String get smRecordIn => 'স্টক ইন রেকর্ড করুন';

  @override
  String get smRecordOut => 'স্টক আউট রেকর্ড করুন';

  @override
  String get smStockInRecorded => 'স্টক-ইন রেকর্ড হয়েছে';

  @override
  String get smStockOutRecorded => 'স্টক-আউট রেকর্ড হয়েছে';

  @override
  String get smRecordError =>
      'স্টক মুভমেন্ট রেকর্ড করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get smInsufficientStock => 'এই মুভমেন্টের জন্য অপর্যাপ্ত স্টক';

  @override
  String get smReasonPurchase => 'ক্রয়';

  @override
  String get smReasonReturn => 'ফেরত';

  @override
  String get smReasonAdjustment => 'সমন্বয়';

  @override
  String get smReasonTransfer => 'স্থানান্তর';

  @override
  String get smReasonDamage => 'ক্ষতি';

  @override
  String get smReasonExpiryRemoval => 'মেয়াদ অপসারণ';

  @override
  String get smReasonOther => 'অন্যান্য';

  @override
  String get grnInvoiceDateRequired => 'ইনভয়েস তারিখ আবশ্যক';

  @override
  String get grnCreateError => 'GRN তৈরি করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get grnSupplierInvoiceSection => 'সরবরাহকারী ও ইনভয়েস';

  @override
  String get grnSupplierNameLabel => 'সরবরাহকারীর নাম';

  @override
  String get grnSupplierNameHint => 'সরবরাহকারীর নাম লিখুন';

  @override
  String get grnSupplierRequired => 'সরবরাহকারী আবশ্যক';

  @override
  String get grnInvoiceNumberLabel => 'ইনভয়েস নম্বর';

  @override
  String get grnInvoiceNumberHint => 'ইনভয়েস নম্বর লিখুন';

  @override
  String get grnInvoiceNumberRequired => 'ইনভয়েস নম্বর আবশ্যক';

  @override
  String get grnInvoiceDateLabel => 'ইনভয়েস তারিখ *';

  @override
  String get grnExpectedDeliveryLabel => 'প্রত্যাশিত ডেলিভারি তারিখ';

  @override
  String get grnCreateDraft => 'খসড়া GRN তৈরি করুন';

  @override
  String get grnSelectDate => 'তারিখ নির্বাচন করুন';

  @override
  String get expiryCalendarTitle => 'মেয়াদ ক্যালেন্ডার';

  @override
  String get expiryCalendarLoadError => 'ক্যালেন্ডার ডেটা লোড করা যায়নি।';

  @override
  String get expiryCalendarTapHint => 'বিস্তারিত দেখতে একটি দিনে ট্যাপ করুন';

  @override
  String get expiryCalendarNoRecords => 'এই দিনের জন্য কোনো মেয়াদ রেকর্ড নেই';

  @override
  String expiryCalendarSummaryFor(String date) {
    return '$date-এর সারসংক্ষেপ';
  }

  @override
  String get exTitle => 'নতুন মেয়াদ রেকর্ড';

  @override
  String get exMfgAfterExpiry => 'উৎপাদন তারিখ মেয়াদ তারিখের পরে হতে পারে না';

  @override
  String get exSelectMfg => 'উৎপাদন তারিখ নির্বাচন করুন';

  @override
  String get exSelectExpiry => 'মেয়াদ তারিখ নির্বাচন করুন';

  @override
  String get exExpiryRequired => 'মেয়াদ তারিখ আবশ্যক';

  @override
  String get exCreated => 'মেয়াদ রেকর্ড তৈরি হয়েছে';

  @override
  String get exOfflineQueued =>
      'আপনি অফলাইনে আছেন — অনলাইনে এলে রেকর্ড সিঙ্ক হবে';

  @override
  String get exSubmitError => 'কিছু ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get exNotSet => 'সেট করা হয়নি';

  @override
  String get exProductIdLabel => 'পণ্য ID';

  @override
  String get exProductIdHint => 'পণ্য ID লিখুন বা বারকোড স্ক্যান করুন';

  @override
  String get exMfgLabel => 'উৎপাদন তারিখ';

  @override
  String get exExpiryLabel => 'মেয়াদ তারিখ *';

  @override
  String get exBatchLabel => 'ব্যাচ নম্বর';

  @override
  String get exLocationLabel => 'অবস্থান';

  @override
  String get exLocationHint => 'তাক / আইল / জোন';

  @override
  String get exSaveRecord => 'রেকর্ড সংরক্ষণ করুন';

  @override
  String get exOcrSemantic => 'RADHA আপনার জন্য তারিখ পড়ে';

  @override
  String get exOcrTitle => 'প্যাক থেকে তারিখ স্ক্যান করুন';

  @override
  String get exOcrSubtitle => 'আমরা আপনার জন্য MFG / EXP পড়ব';

  @override
  String get grnItemsTitle => 'GRN আইটেম';

  @override
  String get grnItemAdded => 'আইটেম যোগ করা হয়েছে';

  @override
  String get grnItemSavedOffline => 'অফলাইনে সংরক্ষিত — অনলাইনে এলে সিঙ্ক হবে';

  @override
  String get grnItemAddError => 'আইটেম যোগ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get grnAddItemFirst => 'পোস্ট করার আগে অন্তত একটি আইটেম যোগ করুন';

  @override
  String get grnPosted => 'GRN পোস্ট হয়েছে — স্টক আপডেট হয়েছে';

  @override
  String get grnPostQueued => 'সারিতে — অনলাইনে এলে পোস্ট হবে';

  @override
  String get grnPostError => 'GRN পোস্ট করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get grnNoItems => 'এখনও কোনো আইটেম যোগ করা হয়নি';

  @override
  String get grnNoItemsHint => 'আইটেম যোগ করতে নিচের বোতামে ট্যাপ করুন';

  @override
  String grnTotalQty(String qty) {
    return 'মোট পরিমাণ: $qty';
  }

  @override
  String grnTotalValue(String value) {
    return 'মোট: ₹$value';
  }

  @override
  String get grnAddItem => 'আইটেম যোগ করুন';

  @override
  String get grnPostGrn => 'GRN পোস্ট করুন';

  @override
  String get grnPostHint =>
      'পোস্ট করলে স্টক আপডেট হয় এবং কম-স্টক সতর্কতা সমাধান হয়।';

  @override
  String grnInvoiceLabel(String number) {
    return 'ইনভয়েস $number';
  }

  @override
  String grnBatchTag(String batch) {
    return 'ব্যাচ $batch';
  }

  @override
  String get grnBarcodeLabel => 'বারকোড (EAN / UPC)';

  @override
  String get grnBarcodeHint => '8–13 অঙ্ক';

  @override
  String get grnProductNameLabel => 'পণ্যের নাম';

  @override
  String get grnMustBePositive => '0 এর বেশি হতে হবে';

  @override
  String get grnBatchNumberOptional => 'ব্যাচ নম্বর (ঐচ্ছিক)';

  @override
  String get grnMfgDateLabel => 'উৎপাদন তারিখ';

  @override
  String get grnExpiryDateLabel => 'মেয়াদ তারিখ';

  @override
  String get grnUnitPriceLabel => 'একক মূল্য (₹)';

  @override
  String get grnMustBeNonNeg => '0 বা তার বেশি হতে হবে';
}
